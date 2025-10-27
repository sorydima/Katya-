import 'dart:async';

class CallSessionBus {
  factory CallSessionBus() => _instance;
  CallSessionBus._internal();
  static final CallSessionBus _instance = CallSessionBus._internal();

  final StreamController<Map<String, dynamic>> _candidateCtrl = StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _hangupCtrl = StreamController.broadcast();

  Stream<Map<String, dynamic>> get candidateStream => _candidateCtrl.stream;
  Stream<Map<String, dynamic>> get hangupStream => _hangupCtrl.stream;

  void publishCandidates({required String callId, required List<dynamic> candidates}) {
    _candidateCtrl.add({'call_id': callId, 'candidates': candidates});
  }

  void publishHangup({required String callId}) {
    _hangupCtrl.add({'call_id': callId});
  }
}
