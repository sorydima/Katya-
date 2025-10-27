import 'package:equatable/equatable.dart';

class RateLimitRule extends Equatable {
  final int maxAttempts;
  final Duration timeWindow;
  final Duration lockoutDuration;
  final bool enabled;
  final Map<String, int> attemptCounts; // key: identifier (e.g., IP or username), value: attempt count
  final Map<String, DateTime> lockouts; // key: identifier, value: lockout expiry time

  const RateLimitRule({
    this.maxAttempts = 5,
    Duration? timeWindow,
    Duration? lockoutDuration,
    this.enabled = true,
    Map<String, int>? attemptCounts,
    Map<String, DateTime>? lockouts,
  })  : timeWindow = timeWindow ?? const Duration(minutes: 15),
        lockoutDuration = lockoutDuration ?? const Duration(minutes = 30),
        attemptCounts = attemptCounts ?? const {},
        lockouts = lockouts ?? const {};

  @override
  List<Object?> get props => [
        maxAttempts,
        timeWindow,
        lockoutDuration,
        enabled,
        attemptCounts,
        lockouts,
      ];

  RateLimitRule copyWith({
    int? maxAttempts,
    Duration? timeWindow,
    Duration? lockoutDuration,
    bool? enabled,
    Map<String, int>? attemptCounts,
    Map<String, DateTime>? lockouts,
  }) {
    return RateLimitRule(
      maxAttempts: maxAttempts ?? this.maxAttempts,
      timeWindow: timeWindow ?? this.timeWindow,
      lockoutDuration: lockoutDuration ?? this.lockoutDuration,
      enabled: enabled ?? this.enabled,
      attemptCounts: attemptCounts ?? this.attemptCounts,
      lockouts: lockouts ?? this.lockouts,
    );
  }

  bool isLockedOut(String identifier) {
    final lockoutTime = lockouts[identifier];
    if (lockoutTime == null) return false;
    
    // If lockout has expired, remove it and return false
    if (DateTime.now().isAfter(lockoutTime)) {
      return false;
    }
    
    return true;
  }

  int getRemainingAttempts(String identifier) {
    if (isLockedOut(identifier)) {
      return 0;
    }
    
    final attempts = attemptCounts[identifier] ?? 0;
    return maxAttempts - attempts;
  }

  DateTime? getLockoutTime(String identifier) {
    return lockouts[identifier];
  }

  String formatLockoutTime(String identifier) {
    final lockoutTime = getLockoutTime(identifier);
    if (lockoutTime == null) return '';
    
    final remaining = lockoutTime.difference(DateTime.now());
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    
    if (minutes > 0) {
      return '$minutes minute${minutes > 1 ? 's' : ''} ${seconds > 0 ? 'and $seconds second${seconds > 1 ? 's' : ''}' : ''}';
    }
    
    return '$seconds second${seconds != 1 ? 's' : ''}';
  }
}
