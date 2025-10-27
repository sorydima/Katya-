import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:katya/store/call/actions.dart';
import 'package:katya/store/call/session_bus.dart';
import 'package:katya/store/index.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key, required this.roomId, this.video = true, this.callId, this.remoteOfferSdp});
  final String roomId;
  final bool video;
  final String? callId;
  final String? remoteOfferSdp;

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _pc;
  MediaStream? _localStream;
  bool _micOn = true;
  bool _camOn = true;
  StreamSubscription? _candSub;
  StreamSubscription? _hangSub;
  String? _callId;
  bool _isAnswerer = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    final config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ]
    };
    final constraints = {'mandatory': {}, 'optional': []};
    _pc = await createPeerConnection(config, constraints);
    _pc!.onIceCandidate = (RTCIceCandidate c) {
      if (_callId != null && c.candidate != null) {
        final cand = {
          'candidate': c.candidate,
          'sdpMLineIndex': c.sdpMLineIndex,
          'sdpMid': c.sdpMid,
        };
        StoreProvider.of<AppState>(context).dispatch(
          sendCallCandidates(roomId: widget.roomId, callId: _callId!, candidates: [cand]),
        );
      }
    };
    // Subscribe to remote ICE candidates
    _candSub = CallSessionBus().candidateStream.listen((data) async {
      if (data['call_id'] != _callId) return;
      final List<dynamic> list = data['candidates'] ?? [];
      for (final c in list) {
        final ice = RTCIceCandidate(c['candidate'], c['sdpMid'], c['sdpMLineIndex'] ?? c['sdpMLineIndex']);
        await _pc?.addCandidate(ice);
      }
    });

    _hangSub = CallSessionBus().hangupStream.listen((data) async {
      if (data['call_id'] != _callId) return;
      Navigator.of(context).maybePop();
    });

    _pc!.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        _remoteRenderer.srcObject = event.streams[0];
      }
    };

    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': widget.video
          ? {
              'facingMode': 'user',
            }
          : false,
    };
    _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    _localRenderer.srcObject = _localStream;

    for (final track in _localStream!.getTracks()) {
      await _pc!.addTrack(track, _localStream!);
    }

    // If navigated with remote offer, act as answerer
    if (widget.remoteOfferSdp != null && widget.callId != null) {
      _isAnswerer = true;
      _callId = widget.callId;
      final remoteDesc = RTCSessionDescription(widget.remoteOfferSdp, 'offer');
      await _pc!.setRemoteDescription(remoteDesc);
      final answer = await _pc!.createAnswer();
      await _pc!.setLocalDescription(answer);
      StoreProvider.of<AppState>(context).dispatch(
        sendCallAnswer(roomId: widget.roomId, callId: _callId!, sdp: answer.sdp!),
      );
    } else {
      // act as offerer
      final offer = await _pc!.createOffer();
      await _pc!.setLocalDescription(offer);
      final id = await StoreProvider.of<AppState>(context).dispatch(
        sendCallInvite(roomId: widget.roomId, sdp: offer.sdp!),
      ) as String?;
      _callId = id;
    }
  }

  // Hooks for signaling integration
  Future<void> applyRemoteDescription(String sdp, String type) async {
    final desc = RTCSessionDescription(sdp, type);
    await _pc?.setRemoteDescription(desc);
  }

  Future<void> addRemoteCandidate(String sdpMid, int sdpMlineIndex, String candidate) async {
    final ice = RTCIceCandidate(candidate, sdpMid, sdpMlineIndex);
    await _pc?.addCandidate(ice);
  }

  @override
  void dispose() {
    _candSub?.cancel();
    _hangSub?.cancel();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _localStream?.getTracks().forEach((t) => t.stop());
    _pc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.video ? 'Video Call' : 'Voice Call'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black,
              child: RTCVideoView(
                _remoteRenderer,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                mirror: false,
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 16,
            width: 120,
            height: 160,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ColoredBox(
                color: Colors.black54,
                child: RTCVideoView(
                  _localRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  mirror: true,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    heroTag: 'flip',
                    backgroundColor: Colors.white24,
                    onPressed: () async {
                      final tracks = _localStream?.getVideoTracks();
                      if (tracks != null && tracks.isNotEmpty) {
                        await Helper.switchCamera(tracks.first);
                      }
                    },
                    child: const Icon(Icons.cameraswitch),
                  ),
                  FloatingActionButton(
                    heroTag: 'mic',
                    backgroundColor: Colors.white24,
                    onPressed: () {
                      _micOn = !_micOn;
                      _localStream?.getAudioTracks().forEach((t) => t.enabled = _micOn);
                      setState(() {});
                    },
                    child: Icon(_micOn ? Icons.mic : Icons.mic_off),
                  ),
                  if (widget.video)
                    FloatingActionButton(
                      heroTag: 'cam',
                      backgroundColor: Colors.white24,
                      onPressed: () {
                        _camOn = !_camOn;
                        _localStream?.getVideoTracks().forEach((t) => t.enabled = _camOn);
                        setState(() {});
                      },
                      child: Icon(_camOn ? Icons.videocam : Icons.videocam_off),
                    ),
                  FloatingActionButton(
                    heroTag: 'end',
                    backgroundColor: Colors.red,
                    onPressed: () {
                      if (_callId != null) {
                        StoreProvider.of<AppState>(context).dispatch(
                          sendCallHangup(roomId: widget.roomId, callId: _callId!),
                        );
                      }
                      Navigator.of(context).pop();
                    },
                    child: const Icon(Icons.call_end),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
