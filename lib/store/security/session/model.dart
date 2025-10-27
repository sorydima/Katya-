import 'package:equatable/equatable.dart';

enum SessionTimeoutAction {
  lock,
  logout,
  prompt,
}

class SessionSettings extends Equatable {
  final bool enabled;
  final Duration timeoutDuration;
  final SessionTimeoutAction action;
  final bool showTimeoutWarning;
  final Duration warningTime;
  final DateTime? lastActivityTime;
  final bool isLocked;

  const SessionSettings({
    this.enabled = false,
    this.timeoutDuration = const Duration(minutes: 15),
    this.action = SessionTimeoutAction.lock,
    this.showTimeoutWarning = true,
    this.warningTime = const Duration(minutes: 1),
    this.lastActivityTime,
    this.isLocked = false,
  });

  @override
  List<Object?> get props => [
        enabled,
        timeoutDuration,
        action,
        showTimeoutWarning,
        warningTime,
        lastActivityTime,
        isLocked,
      ];

  SessionSettings copyWith({
    bool? enabled,
    Duration? timeoutDuration,
    SessionTimeoutAction? action,
    bool? showTimeoutWarning,
    Duration? warningTime,
    DateTime? lastActivityTime,
    bool? isLocked,
  }) {
    return SessionSettings(
      enabled: enabled ?? this.enabled,
      timeoutDuration: timeoutDuration ?? this.timeoutDuration,
      action: action ?? this.action,
      showTimeoutWarning: showTimeoutWarning ?? this.showTimeoutWarning,
      warningTime: warningTime ?? this.warningTime,
      lastActivityTime: lastActivityTime ?? this.lastActivityTime,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'timeoutDurationInMinutes': timeoutDuration.inMinutes,
      'action': action.toString(),
      'showTimeoutWarning': showTimeoutWarning,
      'warningTimeInSeconds': warningTime.inSeconds,
      'lastActivityTime': lastActivityTime?.toIso8601String(),
      'isLocked': isLocked,
    };
  }

  factory SessionSettings.fromJson(Map<String, dynamic> json) {
    return SessionSettings(
      enabled: json['enabled'] as bool? ?? false,
      timeoutDuration: Duration(
        minutes: json['timeoutDurationInMinutes'] as int? ?? 15,
      ),
      action: SessionTimeoutAction.values.firstWhere(
        (e) => e.toString() == json['action'],
        orElse: () => SessionTimeoutAction.lock,
      ),
      showTimeoutWarning: json['showTimeoutWarning'] as bool? ?? true,
      warningTime: Duration(
        seconds: json['warningTimeInSeconds'] as int? ?? 60,
      ),
      lastActivityTime: json['lastActivityTime'] != null
          ? DateTime.parse(json['lastActivityTime'] as String)
          : null,
      isLocked: json['isLocked'] as bool? ?? false,
    );
  }
}
