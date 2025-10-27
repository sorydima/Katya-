import 'package:katya/global/libs/matrix/index.dart';
import 'package:katya/store/index.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:uuid/uuid.dart';

class CallInviteSent {
  final String callId;
  CallInviteSent(this.callId);
}

class CallAnswerSent {
  final String callId;
  CallAnswerSent(this.callId);
}

class CallCandidatesSent {
  final String callId;
  CallCandidatesSent(this.callId);
}

class CallHangupSent {
  final String callId;
  CallHangupSent(this.callId);
}

String _txn() => DateTime.now().millisecondsSinceEpoch.toString();

ThunkAction<AppState> sendCallInvite({
  required String roomId,
  required String sdp,
  String type = 'offer',
  String? callId,
  int lifetimeMs = 60000,
}) {
  return (Store<AppState> store) async {
    final id = callId ?? const Uuid().v4();
    final content = {
      'call_id': id,
      'lifetime': lifetimeMs,
      'offer': {
        'type': type,
        'sdp': sdp,
      },
      'version': 1,
    };
    await MatrixApi.sendRoomEvent(
      protocol: store.state.authStore.protocol,
      homeserver: store.state.authStore.user.homeserver,
      accessToken: store.state.authStore.user.accessToken,
      roomId: roomId,
      eventType: 'm.call.invite',
      trxId: _txn(),
      content: content,
    );
    store.dispatch(CallInviteSent(id));
    return id;
  };
}

ThunkAction<AppState> sendCallAnswer({
  required String roomId,
  required String callId,
  required String sdp,
  String type = 'answer',
}) {
  return (Store<AppState> store) async {
    final content = {
      'call_id': callId,
      'answer': {
        'type': type,
        'sdp': sdp,
      },
      'version': 1,
    };
    await MatrixApi.sendRoomEvent(
      protocol: store.state.authStore.protocol,
      homeserver: store.state.authStore.user.homeserver,
      accessToken: store.state.authStore.user.accessToken,
      roomId: roomId,
      eventType: 'm.call.answer',
      trxId: _txn(),
      content: content,
    );
    store.dispatch(CallAnswerSent(callId));
  };
}

ThunkAction<AppState> sendCallCandidates({
  required String roomId,
  required String callId,
  required List<Map<String, dynamic>> candidates,
}) {
  return (Store<AppState> store) async {
    final content = {
      'call_id': callId,
      'candidates': candidates,
      'version': 1,
    };
    await MatrixApi.sendRoomEvent(
      protocol: store.state.authStore.protocol,
      homeserver: store.state.authStore.user.homeserver,
      accessToken: store.state.authStore.user.accessToken,
      roomId: roomId,
      eventType: 'm.call.candidates',
      trxId: _txn(),
      content: content,
    );
    store.dispatch(CallCandidatesSent(callId));
  };
}

ThunkAction<AppState> sendCallHangup({
  required String roomId,
  required String callId,
  String reason = 'user_hangup',
}) {
  return (Store<AppState> store) async {
    final content = {
      'call_id': callId,
      'reason': reason,
      'version': 1,
    };
    await MatrixApi.sendRoomEvent(
      protocol: store.state.authStore.protocol,
      homeserver: store.state.authStore.user.homeserver,
      accessToken: store.state.authStore.user.accessToken,
      roomId: roomId,
      eventType: 'm.call.hangup',
      trxId: _txn(),
      content: content,
    );
    store.dispatch(CallHangupSent(callId));
  };
}
