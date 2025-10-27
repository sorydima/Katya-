import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:katya/global/libs/matrix/constants.dart';
import 'package:katya/global/libs/matrix/index.dart' as MatrixLib;
import 'package:katya/global/print.dart';
import 'package:katya/services/token_gate_service.dart';
import 'package:katya/store/alerts/actions.dart';
import 'package:katya/store/crypto/actions.dart';
import 'package:katya/store/crypto/events/actions.dart';
import 'package:katya/store/events/actions.dart';
import 'package:katya/store/events/messages/formatters.dart';
import 'package:katya/store/events/messages/model.dart';
import 'package:katya/store/events/reactions/model.dart';
import 'package:katya/store/events/selectors.dart';
import 'package:katya/store/index.dart';
import 'package:katya/store/media/encryption.dart';
import 'package:katya/store/rooms/actions.dart';
import 'package:katya/store/rooms/room/model.dart';
import 'package:katya/store/user/model.dart';
import 'package:katya/utils/token_gate_utils.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

class UpdateMessage {
  final Message message;

  const UpdateMessage({required this.message});

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UpdateMessage && runtimeType == other.runtimeType && message == other.message;

  @override
  int get hashCode => message.hashCode;
}

ThunkAction<AppState> syncRoom({required String roomId}) {
  return (Store<AppState> store) async {
    // Simple implementation - in a real app, this would sync room state
    print('Syncing room: $roomId');
  };
}

Future<List<Message>> reviseMessages({
  List<Message>? messages,
  List<Message>? existing,
  Map<String, List<Reaction>>? reactions,
}) async {
  return compute(reviseMessagesThreaded, {
    'reactions': reactions,
    'messages': (messages ?? []) + (existing ?? []),
  });
}

ThunkAction<AppState> mutateMessages({
  List<Message>? messages,
  List<Message>? existing,
  Map<String, List<Reaction>>? reactionsMap,
}) {
  return (Store<AppState> store) async {
    final reactions = reactionsMap ?? store.state.eventStore.reactions;

    final revisedMessages = await compute(reviseMessagesThreaded, {
      'reactions': reactions,
      'messages': (messages ?? []) + (existing ?? []),
    });

    return revisedMessages;
  };
}

ThunkAction<AppState> mutateMessagesRoom({required Room room}) {
  return (Store<AppState> store) async {
    final messages = store.state.eventStore.messages[room.id];
    final decrypted = store.state.eventStore.messagesDecrypted[room.id];
    final reactions = store.state.eventStore.reactions;

    final mutations = [
      compute(reviseMessagesThreaded, {
        'messages': messages,
        'reactions': reactions,
      })
    ];

    if (room.encryptionEnabled) {
      mutations.add(compute(reviseMessagesThreaded, {
        'messages': decrypted,
        'reactions': reactions,
      }));
    }

    final messagesLists = await Future.wait(mutations);

    await store.dispatch(addMessages(
      roomId: room.id,
      messages: messagesLists[0],
    ));

    if (room.encryptionEnabled) {
      await store.dispatch(addMessagesDecrypted(
        roomId: room.id,
        messages: messagesLists[1],
      ));
    }
  };
}

ThunkAction<AppState> mutateMessagesAll() {
  return (Store<AppState> store) async {
    final rooms = store.state.roomStore.roomList;

    final messages = store.state.eventStore.messages;
    final decrypted = store.state.eventStore.messagesDecrypted;
    final reactions = store.state.eventStore.reactions;

    final messagesUpdated = <String, List<Message>>{};
    final decryptedUpdated = <String, List<Message>>{};

    await Future.forEach(rooms, (Room room) async {
      try {
        final messagesRoom = messages[room.id];
        final messagesDecryptedRoom = decrypted[room.id];

        final messagesRoomUpdated = reviseMessages(
          messages: messagesRoom,
          reactions: reactions,
        );

        final decryptedRoomUpdated = !room.encryptionEnabled
            ? Future.value(<Message>[])
            : reviseMessages(
                messages: messagesDecryptedRoom,
                reactions: reactions,
              );

        final allUpdated = await Future.wait([
          messagesRoomUpdated,
          decryptedRoomUpdated,
        ]);

        messagesUpdated.addAll({room.id: allUpdated[0]});
        decryptedUpdated.addAll({room.id: allUpdated[1]});
      } catch (error) {
        log.error('[mutateMessagesAll] ${room.id} $error');
      }
    });

    store.dispatch(SetMessages(all: messagesUpdated));
    store.dispatch(SetMessagesDecrypted(all: decryptedUpdated));
  };
}

/// Edit an existing message
ThunkAction<AppState> editMessage(
  Store<AppState> store, {
  required Room room,
  required Message message,
  required String newBody,
}) {
  return (Store<AppState> store) async {
    try {
      final user = store.state.authStore.user;

      // Create a new message with updated content
      final editedMessage = message.copyMessageWith(
        body: newBody,
        edited: true,
        replacement: true,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      // Update local state immediately for better UX
      store.dispatch(UpdateMessage(message: editedMessage));

      // Send the edit to the server
      await MatrixLib.MatrixApi.sendEvent(
        protocol: store.state.authStore.protocol,
        homeserver: user.homeserver,
        accessToken: user.accessToken,
        roomId: room.id,
        eventType: 'm.room.message',
        content: {
          'msgtype': message.msgtype,
          'body': newBody,
          'm.new_content': {
            'msgtype': message.msgtype,
            'body': newBody,
          },
          'm.relates_to': {
            'rel_type': 'm.replace',
            'event_id': message.eventId,
          },
        },
      );

      // Refresh the room to get the latest state
      store.dispatch(syncRoom(roomId: room.id));

      return true;
    } catch (error) {
      // Revert the local change if the server update fails
      store.dispatch(UpdateMessage(message: message));
      rethrow;
    }
  };
}

// TODO: need to rework to remove old outbox message
ThunkAction<AppState> sendMessageExisting({
  required String roomId,
  required Message message,
  Message? related,
  bool edit = false,
}) {
  return (Store<AppState> store) async {
    final room = store.state.roomStore.rooms[roomId]!;

    store.dispatch(DeleteOutboxMessage(
      message: message,
    ));

    if (room.encryptionEnabled) {
      return store.dispatch(
        sendMessageEncrypted(
          roomId: room.id,
          message: message,
          related: related,
          edit: edit,
        ),
      );
    }

    return store.dispatch(
      sendMessage(
        roomId: room.id,
        message: message,
        related: related,
        edit: edit,
      ),
    );
  };
}

/// Send Message
ThunkAction<AppState> sendMessage({
  required String roomId,
  required Message message,
  Message? related,
  File? file,
  bool edit = false,
}) {
  return (Store<AppState> store) async {
    final room = store.state.roomStore.rooms[roomId]!;
    final tokenGateService = TokenGateService();

    // Check token gate access before sending message
    if (room.tokenGateConfig?.isEnabled == true) {
      final hasAccess = await checkTokenGateAccess(
        room: room,
        userId: store.state.authStore.user.userId,
        tokenGateService: tokenGateService,
      );

      if (!hasAccess) {
        store.dispatch(addAlert(
          message: 'You do not have permission to send messages in this room',
          error: 'Token gate access denied',
          origin: 'sendMessage',
        ));
        return false;
      }
    }

    // if you're incredibly unlucky, and fast, you could have a problem here
    final tempId = Random.secure().nextInt(1 << 32).toString();

    int? sent;
    Message? pending;

    try {
      store.dispatch(UpdateRoom(id: room.id, sending: true));

      final reply = store.state.roomStore.rooms[room.id]!.reply;
      final userId = store.state.authStore.user.userId!;

      // pending outbox message
      pending = await formatMessageContent(
        tempId: tempId,
        userId: userId,
        message: message,
        related: related,
        room: room,
        file: file,
        edit: edit,
      );

      if (reply != null && reply.body != null) {
        pending = formatMessageReply(room, pending, reply);
      }

      // Save unsent message to outbox
      if (!edit) {
        store.dispatch(SaveOutboxMessage(
          tempId: tempId,
          pendingMessage: pending,
        ));
      }

      final data = await MatrixLib.MatrixApi.sendMessage(
        protocol: store.state.authStore.protocol,
        homeserver: store.state.authStore.user.homeserver,
        accessToken: store.state.authStore.user.accessToken,
        roomId: room.id,
        message: pending.content,
        trxId: DateTime.now().millisecond.toString(),
      );

      if (data['errcode'] != null) {
        // edits will not have outbox messages
        if (!edit) {
          store.dispatch(SaveOutboxMessage(
            tempId: tempId,
            pendingMessage: pending.copyMessageWith(
              timestamp: DateTime.now().millisecondsSinceEpoch,
              syncing: false,
              failed: true,
            ),
          ));
        }

        throw data['error'];
      }

      // mark a successfully sent
      sent = DateTime.now().millisecondsSinceEpoch;

      // Update sent message with event id but needs
      // to be syncing to remove from outbox
      if (!edit) {
        store.dispatch(SaveOutboxMessage(
          tempId: tempId,
          pendingMessage: pending.copyMessageWith(
            id: data['event_id'],
            timestamp: DateTime.now().millisecondsSinceEpoch,
            syncing: true,
          ),
        ));
      }

      return true;
    } catch (error) {
      // dont show error notifications for common networking issues
      if (error is! SocketException) {
        store.dispatch(addAlert(
          error: error,
          message: error.toString(),
          origin: 'sendMessage',
        ));
      }

      // if the message has not been successfully sent
      if (pending != null && sent == null) {
        store.dispatch(SaveOutboxMessage(
          tempId: tempId,
          pendingMessage: pending.copyMessageWith(
            timestamp: DateTime.now().millisecondsSinceEpoch,
            pending: false,
            syncing: false,
            failed: true,
          ),
        ));
      }
      return false;
    } finally {
      store.dispatch(UpdateRoom(
        id: room.id,
        sending: false,
        reply: Message(
          id: 'empty',
          sender: store.state.authStore.user.userId ?? '',
          timestamp: DateTime.now().millisecondsSinceEpoch,
          type: 'm.room.message',
          roomId: room.id,
        ),
      ));
    }
  };
}

/// Send Encrypted Messages
///
/// Specifically for sending encrypted messages using megolm
ThunkAction<AppState> sendMessageEncrypted({
  required String roomId,
  required Message message, // temp - contains all unencrypted info being sent
  Message? related,
  File? file,
  EncryptInfo? info,
  bool edit = false,
}) {
  return (Store<AppState> store) async {
    final room = store.state.roomStore.rooms[roomId]!;
    final tokenGateService = TokenGateService();

    // Check token gate access before sending encrypted message
    if (room.tokenGateConfig?.isEnabled == true) {
      final hasAccess = await checkTokenGateAccess(
        room: room,
        userId: store.state.authStore.user.userId,
        tokenGateService: tokenGateService,
      );

      if (!hasAccess) {
        store.dispatch(addAlert(
          message: 'You do not have permission to send messages in this room',
          error: 'Token gate access denied',
          origin: 'sendMessageEncrypted',
        ));
        return false;
      }
    }

    try {
      final userId = store.state.authStore.user.userId!;

      store.dispatch(UpdateRoom(id: room.id, sending: true));

      // send the key session - if one hasn't been sent
      // or created - to every user within the room
      await store.dispatch(updateKeySessions(room: room));

      // Save unsent message to outbox
      final tempId = Random.secure().nextInt(1 << 32).toString();
      final reply = room.reply;
      final hasReply = reply != null && reply.body != null;
      final hasReplacement = related != null && related.id != null;

      // pending outbox message
      final Message pending = await formatMessageContent(
        tempId: tempId,
        userId: userId,
        message: message,
        related: related,
        room: room,
        file: file,
        info: info,
        edit: edit,
      );

      // spec requires some data is unencrypted
      final unencryptedData = {};

      // if (hasReply) {
      //  unencryptedData['m.relates_to'] = {
      //    'm.in_reply_to': {'event_id': reply.id}
      //  };

      //   pending = formatMessageReply(room, pending, reply);
      // }

      // if (hasReplacement) {
      //   unencryptedData['m.relates_to'] = {
      //     'event_id': related.id,
      //     'rel_type': RelationTypes.replace,
      //   };
      // }

      if (!edit) {
        store.dispatch(SaveOutboxMessage(
          tempId: tempId,
          pendingMessage: pending,
        ));
      }

      // Encrypt the message event
      final encryptedEvent = await store.dispatch(
        encryptMessageContent(
          roomId: room.id,
          content: pending.content,
          eventType: EventTypes.message,
        ),
      );

      final data = await MatrixLib.MatrixApi.sendMessageEncrypted(
        protocol: store.state.authStore.protocol,
        homeserver: store.state.authStore.user.homeserver,
        unencryptedData: unencryptedData,
        accessToken: store.state.authStore.user.accessToken,
        trxId: DateTime.now().millisecond.toString(),
        roomId: room.id,
        senderKey: encryptedEvent['sender_key'],
        ciphertext: encryptedEvent['ciphertext'],
        sessionId: encryptedEvent['session_id'],
        deviceId: store.state.authStore.user.deviceId,
      );

      if (data['errcode'] != null) {
        store.dispatch(SaveOutboxMessage(
          tempId: tempId,
          pendingMessage: pending.copyMessageWith(
            timestamp: DateTime.now().millisecondsSinceEpoch,
            pending: false,
            syncing: false,
            failed: true,
          ),
        ));

        throw data['error'];
      }

      if (!edit) {
        store.dispatch(SaveOutboxMessage(
          tempId: tempId,
          pendingMessage: pending.copyMessageWith(
            id: data['event_id'],
            timestamp: DateTime.now().millisecondsSinceEpoch,
            syncing: true,
          ),
        ));
      }

      return true;
    } catch (error) {
      store.dispatch(
        addAlert(
          error: error,
          message: error.toString(),
          origin: 'sendMessageEncrypted',
        ),
      );
      return false;
    } finally {
      store.dispatch(UpdateRoom(id: roomId, sending: false, reply: const Message(id: '', sender: '', timestamp: 0, type: '', roomId: '')));
    }
  };
}

Future<bool> isMessageDeletable({required Message message, User? user, Room? room}) async {
  try {
    final powerLevels = await MatrixLib.MatrixApi.fetchPowerLevels(
      room: room,
      homeserver: user!.homeserver,
      accessToken: user.accessToken,
    );

    final powerLevelUser = powerLevels['users'];
    final userLevel = powerLevelUser[user.userId];

    if (userLevel == null && message.sender != user.userId) {
      return false;
    }

    if (message.sender == user.userId || userLevel > 0) {
      return true;
    }

    return false;
  } catch (error) {
    log.debug('[isMessageDeletable] $error');
    return false;
  }
}
