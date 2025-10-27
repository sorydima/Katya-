import 'package:equatable/equatable.dart';
import 'package:katya/store/security/notifications/model.dart';

class SetSecurityNotificationSettings {
  final SecurityNotificationSettings settings;
  const SetSecurityNotificationSettings({required this.settings});
}

class ToggleSecurityNotifications {
  final bool enabled;
  const ToggleSecurityNotifications({required this.enabled});
}

class UpdateNotificationPreference {
  final String preferenceType;
  final NotificationPreference preference;
  const UpdateNotificationPreference({
    required this.preferenceType,
    required this.preference,
  });
}

class AddNotificationEmail {
  final String email;
  const AddNotificationEmail({required this.email});
}

class RemoveNotificationEmail {
  final String email;
  const RemoveNotificationEmail({required this.email});
}

class SetNotificationSoundEnabled {
  final bool enabled;
  const SetNotificationSoundEnabled({required this.enabled});
}

class SetNotificationVibrationEnabled {
  final bool enabled;
  const SetNotificationVibrationEnabled({required this.enabled});
}

class SetInAppBannersEnabled {
  final bool enabled;
  const SetInAppBannersEnabled({required this.enabled});
}

class MarkNotificationsAsRead {
  final DateTime timestamp;
  const MarkNotificationsAsRead({required this.timestamp});
}

class SecurityNotificationError extends Equatable {
  final String message;
  final StackTrace? stackTrace;
  final String? code;

  const SecurityNotificationError({
    required this.message,
    this.stackTrace,
    this.code,
  });

  @override
  List<Object?> get props => [message, stackTrace, code];

  @override
  String toString() => 'SecurityNotificationError(message: $message, code: $code)';
}
