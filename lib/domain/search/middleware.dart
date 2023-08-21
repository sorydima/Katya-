import 'package:redux/redux.dart';
import 'package:katya/domain/events/messages/storage.dart';
import 'package:katya/domain/index.dart';
import 'package:katya/domain/search/actions.dart';
import 'package:katya/global/libraries/storage/database.dart';
import 'package:katya/global/print.dart';

///
/// Storage Middleware
///
/// Saves store data to cold storage based
/// on which redux actions are fired.
///
searchMiddleware(ColdStorageDatabase? coldStorage) {
  return (
    Store<AppState> store,
    dynamic actionRaw,
    NextDispatcher next,
  ) async {
    next(actionRaw);

    if (coldStorage == null) {
      console.warn('storage is null, skipping saving cold storage data!!!', title: 'searchMiddleware');
      return;
    }

    switch (actionRaw.runtimeType) {
      case SearchMessages:
        final action = actionRaw as SearchMessages;
        final results = await searchMessagesStored(action.searchText, storage: coldStorage);
        store.dispatch(SearchMessageResults(results: results));
        break;
      default:
        break;
    }
  };
}
