import 'package:katya/store/index.dart';
import 'package:katya/store/security/notifications/actions.dart';
import 'package:katya/store/security/notifications/model.dart';
import 'package:redux/redux.dart';

SecurityNotificationSettings securityNotificationReducer(
  SecurityNotificationSettings state,
  dynamic action,
) {
  if (action is SetSecurityNotificationSettings) {
    return action.settings;
  }

  if (action is ToggleSecurityNotifications) {
    return state.copyWith(enabled: action.enabled);
  }

  if (action is UpdateNotificationPreference) {
    switch (action.preferenceType) {
      case 'failedLoginAttempts':
        return state.copyWith(failedLoginAttempts: action.preference);
      case 'newDeviceLogin':
        return state.copyWith(newDeviceLogin: action.preference);
      case 'passwordChange':
        return state.copyWith(passwordChange: action.preference);
      case 'twoFactorDisabled':
        return state.copyWith(twoFactorDisabled: action.preference);
      case 'suspiciousActivity':
        return state.copyWith(suspiciousActivity: action.preference);
      default:
        return state;
    }
  }

  if (action is AddNotificationEmail) {
    if (state.emailAddresses.contains(action.email)) {
      return state;
    }
    return state.copyWith(
      emailAddresses: [...state.emailAddresses, action.email],
    );
  }

  if (action is RemoveNotificationEmail) {
    if (!state.emailAddresses.contains(action.email)) {
      return state;
    }
    return state.copyWith(
      emailAddresses: state.emailAddresses.where((email) => email != action.email).toList(),
    );
  }

  if (action is SetNotificationSoundEnabled) {
    return state.copyWith(playSound: action.enabled);
  }

  if (action is SetNotificationVibrationEnabled) {
    return state.copyWith(vibrate: action.enabled);
  }

  if (action is SetInAppBannersEnabled) {
    return state.copyWith(showInAppBanners: action.enabled);
  }

  if (action is MarkNotificationsAsRead) {
    return state.copyWith(lastNotified: action.timestamp);
  }

  return state;
}

List<Middleware<AppState>> createSecurityNotificationMiddleware() {
  return [
    TypedMiddleware<AppState, SetSecurityNotificationSettings>(
      (store, action, next) async {
        try {
          // TODO: Save settings to secure storage
          next(action);
        } catch (e) {
          store.dispatch(
            SecurityNotificationError(
              message: 'Failed to update notification settings: $e',
              stackTrace: StackTrace.current,
            ),
          );
        }
      },
    ).call,
    TypedMiddleware<AppState, AddNotificationEmail>(
      (store, action, next) async {
        try {
          // Validate email format
          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
          if (!emailRegex.hasMatch(action.email)) {
            throw const FormatException('Invalid email format');
          }

          // Check for duplicates
          final state = store.state.securityNotificationSettings;
          if (state.emailAddresses.contains(action.email)) {
            throw const FormatException('Email already added');
          }

          // TODO: Verify email address by sending a verification email

          next(action);
        } catch (e) {
          store.dispatch(
            SecurityNotificationError(
              message: 'Failed to add email: $e',
              stackTrace: StackTrace.current,
              code: 'add_email_failed',
            ),
          );
        }
      },
    ).call,
    TypedMiddleware<AppState, RemoveNotificationEmail>(
      (store, action, next) async {
        try {
          // Ensure at least one email remains if notifications are enabled
          final state = store.state.securityNotificationSettings;
          if (state.emailAddresses.length <= 1 &&
              (state.shouldSendEmail(SecurityEventType.suspiciousActivity) ||
                  state.shouldSendEmail(SecurityEventType.failedLogin))) {
            throw const FormatException('At least one email address is required');
          }

          next(action);
        } catch (e) {
          store.dispatch(
            SecurityNotificationError(
              message: 'Failed to remove email: $e',
              stackTrace: StackTrace.current,
              code: 'remove_email_failed',
            ),
          );
        }
      },
    ).call,
  ];
}
