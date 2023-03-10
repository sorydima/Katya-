import 'package:redux/redux.dart';
import 'package:katya/store/events/actions.dart';
import 'package:katya/store/events/reactions/actions.dart';
import 'package:katya/store/events/redaction/actions.dart';
import 'package:katya/store/index.dart';
import 'package:katya/store/rooms/actions.dart';

///
/// Auth Middleware
///
/// Prevents firing any authenticated mutations
///
///
authMiddleware<State>(
  Store<AppState> store,
  dynamic action,
  NextDispatcher next,
) {
  switch (action.runtimeType) {
    case AddMessages:
    case AddReactions:
    case SaveRedactions:
    case UpdateRoom:
      if (store.state.authStore.user.accessToken == null) {
        return;
      }
      next(action);
      break;
    default:
      next(action);
      break;
  }
}
