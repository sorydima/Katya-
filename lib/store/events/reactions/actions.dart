import 'package:collection/collection.dart' show IterableExtension;
import 'package:katya/global/libs/matrix/index.dart';
import 'package:katya/global/print.dart';
import 'package:katya/services/token_gate_service.dart';
import 'package:katya/store/events/messages/model.dart';
import 'package:katya/store/events/reactions/model.dart';
import 'package:katya/store/events/redaction/actions.dart';
import 'package:katya/store/index.dart';
import 'package:katya/store/rooms/actions.dart';
import 'package:katya/store/rooms/room/model.dart';
import 'package:katya/utils/room_utils.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

class AddReactions {
  final String? roomId;
  final List<Reaction>? reactions;
  AddReactions({this.roomId, this.reactions});
}

class LoadReactions {
  final Map<String, List<Reaction>> reactionsMap;
  LoadReactions({required this.reactionsMap});
}

ThunkAction<AppState> addReactions({
  List<Reaction> reactions = const [],
}) =>
    (Store<AppState> store) {
      if (reactions.isEmpty) return;
      return store.dispatch(AddReactions(reactions: reactions));
    };

ThunkAction<AppState> toggleReaction({
  Room? room,
  Message? message,
  String? emoji,
}) {
  return (Store<AppState> store) async {
    final user = store.state.authStore.user;

    final reaction =
        message!.reactions.firstWhereOrNull((reaction) => reaction.sender == user.userId && reaction.body == emoji);

    if (reaction == null) {
      store.dispatch(sendReaction(message: message, room: room, emoji: emoji));
    } else {
      store.dispatch(sendRedaction(event: reaction, room: room));
    }
  };
}

///
/// Send Reaction
///
ThunkAction<AppState> sendReaction({
  Room? room,
  Message? message,
  String? emoji,
}) {
  return (Store<AppState> store) async {
    if (room == null || message == null || emoji == null) {
      return false;
    }

    // Check token gate access if room has token gate enabled
    if (room.tokenGateConfig?.isEnabled == true) {
      final tokenGateService = TokenGateService();
      final hasAccess = await checkRoomAccess(
        room: room,
        userId: store.state.authStore.user.userId,
        tokenGateService: tokenGateService,
      );

      if (!hasAccess) {
        final errorMessage = getTokenGateErrorMessage(room.tokenGateConfig);
        print('Cannot react: $errorMessage - Token gate access denied');
        return false;
      }
    }

    store.dispatch(UpdateRoom(id: room.id, sending: true));
    try {
      await MatrixApi.sendReaction(
        trxId: DateTime.now().millisecond.toString(),
        accessToken: store.state.authStore.user.accessToken,
        homeserver: store.state.authStore.user.homeserver,
        roomId: room.id,
        messageId: message.id,
        reaction: emoji,
      );

      return true;
    } catch (error) {
      log.error('[sendReaction] $error');
      print('Failed to send reaction: $error');
      return false;
    } finally {
      store.dispatch(UpdateRoom(id: room.id, sending: false));
    }
  };
}
