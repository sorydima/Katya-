import 'package:redux/redux.dart';
import 'package:katya/global/print.dart';
import 'package:katya/store/auth/actions.dart';
import 'package:katya/store/auth/context/actions.dart';
import 'package:katya/store/crypto/actions.dart';
import 'package:katya/store/crypto/keys/actions.dart';
import 'package:katya/store/crypto/sessions/actions.dart';
import 'package:katya/store/events/actions.dart';
import 'package:katya/store/index.dart';
import 'package:katya/store/rooms/actions.dart';
import 'package:katya/store/sync/actions.dart';

///
/// Cache Middleware
///
/// Saves store data to cold storage based
/// on which redux actions are fired.
///
bool cacheMiddleware(Store<AppState> store, dynamic action) {
  switch (action.runtimeType) {
    case AddAvailableUser:
    case RemoveAvailableUser:
    case UpdateRoom:
    case SetRoom:
    case RemoveRoom:
    case DeleteMessage:
    case DeleteOutboxMessage:
    case SetOlmAccountBackup:
    case SetDeviceKeysOwned:
    case AddKeySession:
    case AddMessageSessionInbound:
    case AddMessageSessionOutbound:
    case SetUser:
    case ResetCrypto:
    case ResetUser:
      log.info('[initStore] persistor saving from ${action.runtimeType}');
      return true;
    case SetSynced:
      return ((action as SetSynced).synced ?? false) &&
          !store.state.syncStore.synced;
    default:
      return false;
  }
}
