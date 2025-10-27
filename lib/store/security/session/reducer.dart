import 'package:katya/store/index.dart';
import 'package:katya/store/security/session/actions.dart';
import 'package:katya/store/security/session/model.dart';
import 'package:redux/redux.dart';

SessionSettings sessionReducer(SessionSettings state, dynamic action) {
  if (action is SetSessionSettings) {
    return action.settings;
  }

  if (action is UpdateLastActivityTime) {
    return state.copyWith(lastActivityTime: action.time);
  }

  if (action is LockSession) {
    return state.copyWith(isLocked: true);
  }

  if (action is UnlockSession) {
    return state.copyWith(isLocked: false);
  }

  if (action is ShowSessionTimeoutWarning) {
    return state.copyWith(showTimeoutWarning: action.show);
  }

  return state;
}

// Middleware for handling session timeout
List<Middleware<AppState>> createSessionMiddleware() {
  return [
    TypedMiddleware<AppState, SetSessionSettings>(
      (store, action, next) async {
        try {
          next(const SetSessionLoading(true));
          // TODO: Save settings to secure storage
          await Future.delayed(const Duration(milliseconds: 500));
          next(action);
        } catch (e) {
          next(SessionError(
            message: 'Failed to update session settings: $e',
            stackTrace: StackTrace.current,
          ));
        } finally {
          next(const SetSessionLoading(false));
        }
      },
    ).call,
    TypedMiddleware<AppState, UpdateLastActivityTime>(
      (store, action, next) {
        // Update last activity time
        next(action);

        // Reset any existing timer
        store.state.sessionTimer?.cancel();

        // Only set up a new timer if session timeout is enabled
        if (store.state.sessionSettings.enabled) {
          final timeoutDuration = store.state.sessionSettings.timeoutDuration;
          final warningTime = store.state.sessionSettings.wunningTime;

          // Set a timer to show warning before timeout
          if (store.state.sessionSettings.showTimeoutWarning) {
            final warningTimer = Timer(
              timeoutDuration - warningTime,
              () {
                store.dispatch(const ShowSessionTimeoutWarning(true));
              },
            );

            // Store the timer in the state so it can be cancelled
            store.dispatch(SetSessionTimer(warningTimer));
          }

          // Set the main timeout timer
          final timeoutTimer = Timer(
            timeoutDuration,
            () {
              // Cancel the warning timer if it exists
              store.state.sessionTimer?.cancel();

              // Take action based on the selected action
              switch (store.state.sessionSettings.action) {
                case SessionTimeoutAction.lock:
                  store.dispatch(const LockSession());
                case SessionTimeoutAction.logout:
                  // TODO: Implement logout logic
                  break;
                case SessionTimeoutAction.prompt:
                  // Show a dialog to the user
                  // This would need to be handled in the UI layer
                  break;
              }
            },
          );

          // Store the timer in the state so it can be cancelled
          store.dispatch(SetSessionTimer(timeoutTimer));
        }
      },
    ).call,
    TypedMiddleware<AppState, LockSession>(
      (store, action, next) async {
        try {
          // TODO: Save locked state to secure storage
          next(action);

          // Show lock screen or navigate to auth screen
          // This would be handled in the UI layer
        } catch (e) {
          next(SessionError(
            message: 'Failed to lock session: $e',
            stackTrace: StackTrace.current,
          ));
        }
      },
    ).call,
    TypedMiddleware<AppState, ShowSessionTimeoutWarning>(
      (store, action, next) {
        // Show a warning dialog to the user
        // This would be handled in the UI layer
        next(action);
      },
    ).call,
  ];
}
