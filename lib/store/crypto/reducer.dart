import 'package:katya/store/crypto/keys/actions.dart';
import 'package:katya/store/crypto/sessions/actions.dart';
import 'package:katya/store/crypto/sessions/model.dart';

import './actions.dart';
import './state.dart';

CryptoStore cryptoReducer([CryptoStore state = const CryptoStore(), dynamic action]) {
  switch (action.runtimeType) {
    case SetOlmAccount:
      return state.copyWith(
        olmAccount: action.olmAccount,
      );
    case SetOlmAccountBackup:
      return state.copyWith(
        olmAccountKey: action.olmAccountKey,
      );
    case SetDeviceKeys:
      return state.copyWith(
        deviceKeys: action.deviceKeys,
      );
    case SetDeviceKeysOwned:
      return state.copyWith(
        deviceKeysOwned: action.deviceKeysOwned,
      );
    case SetOneTimeKeysCounts:
      return state.copyWith(
        oneTimeKeysCounts: action.oneTimeKeysCounts,
      );
    case SetOneTimeKeysStable:
      final action0 = action as SetOneTimeKeysStable;
      return state.copyWith(
        oneTimeKeysStable: action0.stable,
      );
    case SetOneTimeKeysClaimed:
      return state.copyWith(
        oneTimeKeysClaimed: action.oneTimeKeys,
      );
    case AddKeySession:
      final action0 = action as AddKeySession;

      final keySessions = Map<String, Map<String, String>>.from(
        state.keySessions,
      );

      final sessionId = action0.sessionId;
      final sessionNew = action0.session;

      // Update sessions by their ID for a certain identityKey (sender_key)
      keySessions.update(
        action0.identityKey,
        (session) => session
          ..update(
            sessionId,
            (value) => sessionNew,
            ifAbsent: () => sessionNew,
          ),
        ifAbsent: () => {sessionId: sessionNew},
      );

      return state.copyWith(
        keySessions: keySessions,
      );
    case AddMessageSessionOutbound:
      final action0 = action as AddMessageSessionOutbound;
      final outboundMessageSessions = Map<String, String>.from(
        state.outboundMessageSessions,
      );

      outboundMessageSessions.update(
        action0.roomId,
        (sessionCurrent) => action0.session,
        ifAbsent: () => action0.session,
      );

      return state.copyWith(
        outboundMessageSessions: outboundMessageSessions,
      );
    case AddMessageSessionInbound:
      final action0 = action as AddMessageSessionInbound;

      final roomId = action0.roomId;
      final senderKey = action0.senderKey;
      final sessionNew = action0.session;
      final messageIndex = action0.messageIndex;

      final messageSessions = Map<String, Map<String, List<MessageSession>>>.from(
        state.messageSessionsInbound,
      );

      final messageSessionNew = MessageSession(
        index: messageIndex,
        serialized: sessionNew, // already pickled
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      // new message session updates
      messageSessions.update(
        roomId,
        (identitySessions) => identitySessions
          ..update(
            senderKey,
            (sessions) => sessions..insert(0, messageSessionNew),
            ifAbsent: () => [messageSessionNew],
          ),
        ifAbsent: () => {
          senderKey: [messageSessionNew],
        },
      );

      return state.copyWith(
        messageSessionsInbound: messageSessions,
      );

    // TODO: make this work synchronously?? [combineMessageSesssions](./converters.dart)
    case AddMessageSessionsInbound:
      final action0 = action as AddMessageSessionsInbound;

      final messageSessionsNew = action0.sessions;

      final messageSessionsExisting = Map<String, Map<String, List<MessageSession>>>.from(
        state.messageSessionsInbound,
      );

      // prepend session keys to an array per spec
      for (final roomSessions in messageSessionsNew.entries) {
        final roomId = roomSessions.key;
        final sessions = roomSessions.value;

        for (final messsageSessions in sessions.entries) {
          final senderKey = messsageSessions.key;
          final sessionsSerialized = messsageSessions.value;

          for (final session in sessionsSerialized) {
            messageSessionsExisting.update(
              roomId,
              (identitySessions) => identitySessions
                ..update(
                  senderKey,
                  (sessions) => sessions.toList()..insert(0, session),
                  ifAbsent: () => [session],
                ),
              ifAbsent: () => {
                senderKey: [session],
              },
            );
          }
        }
      }

      return state.copyWith(
        messageSessionsInbound: messageSessionsExisting,
      );
    case SetMessageSessionsInbound:
      final action0 = action as SetMessageSessionsInbound;

      return state.copyWith(
        messageSessionsInbound: action0.sessions,
      );
    case ToggleDeviceKeysExist:
      return state.copyWith(
        deviceKeysExist: action.existence,
      );
    case ResetCrypto:
      return const CryptoStore();
    default:
      return state;
  }
}
