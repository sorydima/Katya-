import 'package:redux/redux.dart';
import 'package:katya/global/print.dart';
import 'package:katya/storage/database.dart';
import 'package:katya/store/events/messages/storage.dart';
import 'package:katya/store/index.dart';
import 'package:katya/store/search/actions.dart';

///
/// Storage Middleware
///
/// Saves store data to cold storage based
/// on which redux actions are fired.
///
searchMiddleware(StorageDatabase? coldStorage) {
  return (
    Store<AppState> store,
    dynamic action,
    NextDispatcher next,
  ) async {
    next(action);

    if (coldStorage == null) {
      log.warn('storage is null, skipping saving cold storage data!!!', title: 'searchMiddleware');
      return;
    }

    switch (action.runtimeType) {
      case SearchMessages:
        final _action = action as SearchMessages;
        final results = await searchMessagesStored(_action.searchText, storage: coldStorage);
        store.dispatch(SearchMessageResults(results: results));
        break;
      default:
        break;
    }
  };
}
