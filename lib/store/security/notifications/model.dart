import 'package:equatable/equatable.dart';
import 'package:katya/store/security/events/model.dart';

enum NotificationPreference {
  none,       // No notifications
  push,       // Push notifications only
  email,      // Email notifications only
  all,        // Both push and email notifications
}

class SecurityNotificationSettings extends Equatable {
  final bool enabled;
  final NotificationPreference failedLoginAttempts;
  final NotificationPreference newDeviceLogin;
  final NotificationPreference passwordChange;
  final NotificationPreference twoFactorDisabled;
  final NotificationPreference suspiciousActivity;
  final bool showInAppBanners;
  final bool playSound;
  final bool vibrate;
  final List<String> emailAddresses;
  final DateTime? lastNotified;

  const SecurityNotificationSettings({
    this.enabled = true,
    this.failedLoginAttempts = NotificationPreference.all,
    this.newDeviceLogin = NotificationPreference.all,
    this.passwordChange = NotificationPreference.all,
    this.twoFactorDisabled = NotificationPreference.all,
    this.suspiciousActivity = NotificationPreference.all,
    this.showInAppBanners = true,
    this.playSound = true,
    this.vibrate = true,
    this.emailAddresses = const [],
    this.lastNotified,
  });

  @override
  List<Object?> get props => [
        enabled,
        failedLoginAttempts,
        newDeviceLogin,
        passwordChange,
        twoFactorDisabled,
        suspiciousActivity,
        showInAppBanners,
        playSound,
        vibrate,
        emailAddresses,
        lastNotified,
      ];

  SecurityNotificationSettings copyWith({
    bool? enabled,
    NotificationPreference? failedLoginAttempts,
    NotificationPreference? newDeviceLogin,
    NotificationPreference? passwordChange,
    NotificationPreference? twoFactorDisabled,
    NotificationPreference? suspiciousActivity,
    bool? showInAppBanners,
    bool? playSound,
    bool? vibrate,
    List<String>? emailAddresses,
    DateTime? lastNotified,
  }) {
    return SecurityNotificationSettings(
      enabled: enabled ?? this.enabled,
      failedLoginAttempts: failedLoginAttempts ?? this.failedLoginAttempts,
      newDeviceLogin: newDeviceLogin ?? this.newDeviceLogin,
      passwordChange: passwordChange ?? this.passwordChange,
      twoFactorDisabled: twoFactorDisabled ?? this.twoFactorDisabled,
      suspiciousActivity: suspiciousActivity ?? this.suspiciousActivity,
      showInAppBanners: showInAppBanners ?? this.showInAppBanners,
      playSound: playSound ?? this.playSound,
      vibrate: vibrate ?? this.vibrate,
      emailAddresses: emailAddresses ?? this.emailAddresses,
      lastNotified: lastNotified ?? this.lastNotified,
    );
  }

  bool shouldNotify(SecurityEventType eventType) {
    if (!enabled) return false;

    final preference = _getPreferenceForEvent(eventType);
    return preference != NotificationPreference.none;
  }

  bool shouldShowBanner(SecurityEventType eventType) {
    if (!enabled || !showInAppBanners) return false;
    return shouldNotify(eventType);
  }

  bool shouldSendPush(SecurityEventType eventType) {
    final preference = _getPreferenceForEvent(eventType);
    return preference == NotificationPreference.push || 
           preference == NotificationPreference.all;
  }

  bool shouldSendEmail(SecurityEventType eventType) {
    final preference = _getPreferenceForEvent(eventType);
    return (preference == NotificationPreference.email || 
            preference == NotificationPreference.all) &&
           emailAddresses.isNotEmpty;
  }

  NotificationPreference _getPreferenceForEvent(SecurityEventType eventType) {
    switch (eventType) {
      case SecurityEventType.failedLogin:
      case SecurityEventType.accountLocked:
        return failedLoginAttempts;
      case SecurityEventType.newDeviceLogin:
      case SecurityEventType.deviceVerified:
        return newDeviceLogin;
      case SecurityEventType.passwordChanged:
      case SecurityEventType.passwordResetRequested:
        return passwordChange;
      case SecurityEventType.twoFactorDisabled:
      case SecurityEventType.twoFactorEnabled:
        return twoFactorDisabled;
      case SecurityEventType.suspiciousActivity:
      case SecurityEventType.unusualLocation:
      case SecurityEventType.unusualTime:
        return suspiciousActivity;
      default:
        return NotificationPreference.none;
    }
  }
}
