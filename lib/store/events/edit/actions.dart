import 'package:katya/global/libs/matrix/index.dart' as MatrixLib;
import 'package:katya/global/print.dart';
import 'package:katya/store/index.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

class EditMessage {
  final String eventId;
  final String roomId;
  final String? newContent;
  final bool isEdit;

  EditMessage({
    required this.eventId,
    required this.roomId,
    this.newContent,
    this.isEdit = false,
  });
}

class SetMessageEdit {
  final String eventId;
  final bool isEditing;

  SetMessageEdit({
    required this.eventId,
    this.isEditing = false,
  });
}

ThunkAction<AppState> editMessage({
  required String eventId,
  required String roomId,
  required String newContent,
}) {
  return (Store<AppState> store) async {
    try {
      final user = store.state.authStore.user;

      // Get the original event from the room's messages
      final roomMessages = store.state.eventStore.messages[roomId] ?? [];
      final event = roomMessages.firstWhere(
        (msg) => msg.id == eventId,
        orElse: () => throw 'Message not found',
      );

      // Update the message locally first for immediate feedback
      store.dispatch(EditMessage(
        eventId: eventId,
        roomId: roomId,
        newContent: newContent,
        isEdit: true,
      ));

      // Send the edit to the server
      await MatrixLib.MatrixApi.sendEvent(
        protocol: store.state.authStore.protocol,
        homeserver: user.homeserver,
        accessToken: user.accessToken,
        roomId: roomId,
        eventType: 'm.room.message',
        content: {
          'msgtype': event.msgtype ?? 'm.text',
          'body': newContent,
          'm.new_content': {
            'msgtype': event.msgtype ?? 'm.text',
            'body': newContent,
          },
          'm.relates_to': {
            'rel_type': 'm.replace',
            'event_id': eventId,
          },
        },
      );

      log.info('Message edited successfully');
    } catch (error) {
      log.error('Error editing message: $error');
      rethrow;
    }
  };
}

ThunkAction<AppState> deleteMessage({
  required String eventId,
  required String roomId,
  String? reason,
}) {
  return (Store<AppState> store) async {
    try {
      final user = store.state.authStore.user;

      // Redact the message
      await MatrixLib.MatrixApi.redactEvent(
        protocol: store.state.authStore.protocol,
        homeserver: user.homeserver,
        accessToken: user.accessToken,
        roomId: roomId,
        eventId: eventId,
        trxId: 'm${DateTime.now().millisecondsSinceEpoch}',
      );

      log.info('Message deleted successfully');
    } catch (error) {
      log.error('Error deleting message: $error');
      rethrow;
    }
  };
}

ThunkAction<AppState> toggleMessageEdit(String eventId, {bool isEditing = true}) {
  return (Store<AppState> store) {
    store.dispatch(SetMessageEdit(
      eventId: eventId,
      isEditing: isEditing,
    ));
  };
}
