import 'package:katya/global/print.dart';
import 'package:katya/storage/database.dart';
import 'package:katya/store/index.dart';
import 'package:katya/store/user/actions.dart';
import 'package:katya/store/user/storage.dart';
import 'package:redux/redux.dart';

///
/// Load Storage Middleware
///
/// Loads storage data from cold storage
/// based  on which redux actions are fired.
///
Future<void> Function(Store<AppState> store, dynamic action, NextDispatcher next) loadStorageMiddleware(
    StorageDatabase? storage) {
  return (
    Store<AppState> store,
    dynamic action,
    NextDispatcher next,
  ) async {
    try {
      if (storage == null) {
        log.warn(
          'storage is null, skipping saving cold storage data!!!',
          title: 'storageMiddleware',
        );
        return;
      }

      switch (action.runtimeType) {
        case LoadUsers:
          final action = action as LoadUsers;
          loadUserAsync() async {
            final loadedUsers = await loadUsers(storage: storage, ids: action.userIds ?? []);

            store.dispatch(SetUsers(users: loadedUsers));
          }

          loadUserAsync();
        default:
          break;
      }
    } catch (error) {
      log.error('[loadStorageMiddleware] $error');
    }

    next(action);
  };
}
