import 'package:katya/store/security/rate_limit/model.dart';

class SetRateLimitRule {
  final RateLimitRule rule;
  const SetRateLimitRule({required this.rule});
}

class SetRateLimitLoading {
  final bool loading;
  const SetRateLimitLoading({required this.loading});
}

class IncrementLoginAttempts {
  final String identifier;
  final DateTime timestamp;

  const IncrementLoginAttempts({
    required this.identifier,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ResetLoginAttempts {
  final String identifier;
  const ResetLoginAttempts({required this.identifier});
}

class LockoutUser {
  final String identifier;
  final DateTime expiryTime;

  const LockoutUser({
    required this.identifier,
    required this.expiryTime,
  });
}

class ClearExpiredLockouts {
  const ClearExpiredLockouts();
}

class RateLimitError {
  final String message;
  final StackTrace? stackTrace;

  const RateLimitError({
    required this.message,
    this.stackTrace,
  });

  @override
  String toString() => 'RateLimitError(message: $message, stackTrace: $stackTrace)';
}
