import 'package:flutter/material.dart';
import 'package:katya/views/navigation.dart';

class IncomingCallScreen extends StatelessWidget {
  const IncomingCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final roomId = args?['roomId'] as String? ?? '';
    final callId = args?['callId'] as String? ?? '';
    final sdp = args?['sdp'] as String? ?? '';
    final video = args?['video'] as bool? ?? true;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Incoming ${video ? 'video' : 'voice'} call',
                  style: const TextStyle(color: Colors.white, fontSize: 20)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    backgroundColor: Colors.red,
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Icon(Icons.call_end),
                  ),
                  const SizedBox(width: 48),
                  FloatingActionButton(
                    backgroundColor: Colors.green,
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, Routes.call, arguments: {
                        'roomId': roomId,
                        'video': video,
                        'callId': callId,
                        'remoteOfferSdp': sdp,
                      });
                    },
                    child: const Icon(Icons.call),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
