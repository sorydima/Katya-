import 'package:katya/global/print.dart';
import 'package:katya/storage/database.dart';
import 'package:katya/store/auth/actions.dart';
import 'package:katya/store/auth/context/actions.dart';
import 'package:katya/store/auth/storage.dart';
import 'package:katya/store/crypto/actions.dart';
import 'package:katya/store/crypto/keys/actions.dart';
import 'package:katya/store/crypto/sessions/actions.dart';
import 'package:katya/store/crypto/sessions/storage.dart';
import 'package:katya/store/crypto/storage.dart';
import 'package:katya/store/events/actions.dart';
import 'package:katya/store/events/messages/storage.dart';
import 'package:katya/store/events/reactions/actions.dart';
import 'package:katya/store/events/reactions/storage.dart';
import 'package:katya/store/events/receipts/actions.dart';
import 'package:katya/store/events/receipts/storage.dart';
import 'package:katya/store/events/redaction/actions.dart';
import 'package:katya/store/index.dart';
import 'package:katya/store/media/actions.dart';
import 'package:katya/store/media/model.dart';
import 'package:katya/store/media/storage.dart';
import 'package:katya/store/rooms/actions.dart';
import 'package:katya/store/rooms/storage.dart';
import 'package:katya/store/settings/actions.dart';
import 'package:katya/store/settings/chat-settings/actions.dart';
import 'package:katya/store/settings/notification-settings/actions.dart';
import 'package:katya/store/settings/privacy-settings/actions.dart';
import 'package:katya/store/settings/privacy-settings/storage.dart';
import 'package:katya/store/settings/proxy-settings/actions.dart';
import 'package:katya/store/settings/storage-settings/actions.dart';
import 'package:katya/store/settings/storage.dart';
import 'package:katya/store/settings/theme-settings/actions.dart';
import 'package:katya/store/sync/service/storage.dart';
import 'package:katya/store/user/actions.dart';
import 'package:katya/store/user/storage.dart';
import 'package:redux/redux.dart';

///
/// Storage Middleware
///
/// Saves state data to cold storage based
/// on which redux actions are fired.
///
Null Function(Store<AppState> store, dynamic action, NextDispatcher next) saveStorageMiddleware(
    StorageDatabase? storage) {
  return (
    Store<AppState> store,
    dynamic action,
    NextDispatcher next,
  ) {
    next(action);

    if (storage == null) {
      log.warn('storage is null, skipping saving cold storage data!!!', title: 'storageMiddleware');
      return;
    }

    switch (action.runtimeType) {
      case AddAvailableUser:
      case RemoveAvailableUser:
      case SetUser:
        saveAuth(store.state.authStore, storage: storage);
      case SetUsers:
        final setUsersAction = action as SetUsers;
        saveUsers(setUsersAction.users ?? {}, storage: storage);
      case UpdateMediaCache:
        final updateMediaAction = action as UpdateMediaCache;

        // dont save decrypted images
        final decrypting = store.state.mediaStore.mediaStatus[updateMediaAction.mxcUri] == MediaStatus.DECRYPTING.value;
        if (decrypting) return;

        saveMedia(updateMediaAction.mxcUri, updateMediaAction.data,
            info: updateMediaAction.info, type: updateMediaAction.type, storage: storage);
      case UpdateRoom:
        final updateRoomAction = action as UpdateRoom;
        final rooms = store.state.roomStore.rooms;
        final isSending = updateRoomAction.sending != null;
        final isDrafting = updateRoomAction.draft != null;
        final isLastRead = updateRoomAction.lastRead != null;

        if ((isSending || isDrafting || isLastRead) && rooms.containsKey(updateRoomAction.id)) {
          final room = rooms[updateRoomAction.id];
          saveRoom(room!, storage: storage);
        }
      case RemoveRoom:
        final removeRoomAction = action as RemoveRoom;
        final room = store.state.roomStore.rooms[removeRoomAction.roomId];
        if (room != null) {
          deleteRooms({room.id: room}, storage: storage);
        }
      case AddReactions:
        final addReactionsAction = action as AddReactions;
        saveReactions(addReactionsAction.reactions ?? [], storage: storage);
      case SaveRedactions:
        final saveRedactionsAction = action as SaveRedactions;
        saveMessagesRedacted(saveRedactionsAction.redactions ?? [], storage: storage);
        saveReactionsRedacted(saveRedactionsAction.redactions ?? [], storage: storage);
      case SetReceipts:
        final setReceiptsAction = action as SetReceipts;
        final isSynced = store.state.syncStore.synced;
        // NOTE: prevents saving read receipts until a Full Sync is completed
        saveReceipts(setReceiptsAction.receipts ?? {}, storage: storage, ready: isSynced);
      case SetRoom:
        final setRoomAction = action as SetRoom;
        final room = setRoomAction.room;
        saveRooms({room.id: room}, storage: storage);
      case DeleteMessage:
        final deleteMessageAction = action as DeleteMessage;
        saveMessages([deleteMessageAction.message], storage: storage);
      case DeleteOutboxMessage:
        final deleteOutboxAction = action as DeleteOutboxMessage;
        deleteMessages([deleteOutboxAction.message], storage: storage);
      case AddMessages:
        final addMessagesAction = action as AddMessages;
        saveMessages(addMessagesAction.messages, storage: storage);
      case AddMessagesDecrypted:
        final addMessagesDecryptedAction = action as AddMessagesDecrypted;
        saveDecrypted(addMessagesDecryptedAction.messages, storage: storage);
      case SetThemeType:
      case SetPrimaryColor:
      case SetAvatarShape:
      case SetAccentColor:
      case SetAppBarColor:
      case SetFontName:
      case SetFontSize:
      case SetMessageSize:
      case SetRoomPrimaryColor:
      case SetDevices:
      case SetLanguage:
      case ToggleEnterSend:
      case ToggleAutocorrect:
      case ToggleSuggestions:
      case ToggleRoomTypeBadges:
      case ToggleMembershipEvents:
      case ToggleNotifications:
      case ToggleTypingIndicators:
      case ToggleTimeFormat:
      case SetReadReceipts:
      case SetSyncInterval:
      case SetMainFabLocation:
      case SetMainFabType:
      case ToggleAutoDownload:
      case ToggleProxy:
      case SetProxyHost:
      case SetProxyPort:
      case SetKeyBackupInterval:
      case SetKeyBackupLocation:
      case ToggleProxyAuthentication:
      case SetProxyUsername:
      case SetProxyPassword:
      case SetLastBackupMillis:
        saveSettings(store.state.settingsStore, storage: storage);
      case SetKeyBackupPassword:
        final setKeyBackupPasswordAction = action as SetKeyBackupPassword;
        saveBackupPassword(password: setKeyBackupPasswordAction.password);
      case LogAppAgreement:
        saveTermsAgreement(timestamp: int.parse(store.state.settingsStore.alphaAgreement ?? '0'));
      case SetOlmAccountBackup:
      case SetDeviceKeysOwned:
      case ToggleDeviceKeysExist:
      case SetDeviceKeys:
      case SetOneTimeKeysCounts:
      case SetOneTimeKeysClaimed:
      case AddMessageSessionOutbound:
      case UpdateMessageSessionOutbound:
      case AddKeySession:
      case ResetCrypto:
        saveCrypto(store.state.cryptoStore, storage: storage);
      case AddMessageSessionInbound:
        final addMessageSessionInboundAction = action as AddMessageSessionInbound;
        saveMessageSessionInbound(
          roomId: addMessageSessionInboundAction.roomId,
          identityKey: addMessageSessionInboundAction.senderKey,
          session: addMessageSessionInboundAction.session,
          messageIndex: addMessageSessionInboundAction.messageIndex,
          storage: storage,
        );
      case SaveMessageSessionsInbound:
        saveMessageSessionsInbound(
          store.state.cryptoStore.messageSessionsInbound,
          storage: storage,
        );
      case SetNotificationSettings:
        // handles updating the background sync thread with new chat settings
        saveNotificationSettings(
          settings: store.state.settingsStore.notificationSettings,
        );
        saveSettings(store.state.settingsStore, storage: storage);

      default:
        break;
    }
  };
}
