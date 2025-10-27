import 'package:katya/store/index.dart';
import 'package:katya/store/security/rate_limit/actions.dart';
import 'package:katya/store/security/rate_limit/model.dart';
import 'package:redux/redux.dart';

RateLimitRule rateLimitReducer(RateLimitRule state, dynamic action) {
  if (action is SetRateLimitRule) {
    return action.rule;
  }

  if (action is IncrementLoginAttempts) {
    final identifier = action.identifier;
    final currentCount = state.attemptCounts[identifier] ?? 0;

    // Create new maps to ensure proper state updates
    final newAttemptCounts = Map<String, int>.from(state.attemptCounts);
    newAttemptCounts[identifier] = currentCount + 1;

    return state.copyWith(attemptCounts: newAttemptCounts);
  }

  if (action is ResetLoginAttempts) {
    final newAttemptCounts = Map<String, int>.from(state.attemptCounts);
    newAttemptCounts.remove(action.identifier);

    return state.copyWith(attemptCounts: newAttemptCounts);
  }

  if (action is LockoutUser) {
    final newLockouts = Map<String, DateTime>.from(state.lockouts);
    newLockouts[action.identifier] = action.expiryTime;

    return state.copyWith(lockouts: newLockouts);
  }

  if (action is ClearExpiredLockouts) {
    final now = DateTime.now();
    final expiredKeys =
        state.lockouts.entries.where((entry) => entry.value.isBefore(now)).map((entry) => entry.key).toList();

    if (expiredKeys.isEmpty) return state;

    final newLockouts = Map<String, DateTime>.from(state.lockouts);
    for (final key in expiredKeys) {
      newLockouts.remove(key);
    }

    return state.copyWith(lockouts: newLockouts);
  }

  return state;
}

// Middleware for handling rate limiting
List<Middleware<AppState>> createRateLimitMiddleware() {
  return [
    TypedMiddleware<AppState, IncrementLoginAttempts>(
      (store, action, next) async {
        try {
          next(action);

          final state = store.state.rateLimitRule;
          final identifier = action.identifier;
          final currentAttempts = state.attemptCounts[identifier] ?? 0;

          // Check if we've reached the maximum attempts
          if (currentAttempts + 1 >= state.maxAttempts) {
            final expiryTime = DateTime.now().add(state.lockoutDuration);
            store.dispatch(LockoutUser(
              identifier: identifier,
              expiryTime: expiryTime,
            ));

            // Log this security event
            store.dispatch(AddSecurityEvent(
              event: SecurityEvent(
                id: 'rate_limit_${DateTime.now().millisecondsSinceEpoch}',
                type: SecurityEventType.accountLocked,
                description: 'Account locked due to too many failed login attempts',
                timestamp: DateTime.now(),
                metadata: {
                  'identifier': identifier,
                  'lockout_until': expiryTime.toIso8601String(),
                },
              ),
            ));
          }
        } catch (e) {
          store.dispatch(RateLimitError(
            message: 'Failed to process login attempt: $e',
            stackTrace: StackTrace.current,
          ));
        }
      },
    ).call,
    TypedMiddleware<AppState, ResetLoginAttempts>(
      (store, action, next) async {
        try {
          next(action);

          // Also clear any existing lockout for this identifier
          final state = store.state.rateLimitRule;
          if (state.lockouts.containsKey(action.identifier)) {
            final newLockouts = Map<String, DateTime>.from(state.lockouts);
            newLockouts.remove(action.identifier);

            store.dispatch(SetRateLimitRule(
              rule: state.copyWith(lockouts: newLockouts),
            ));

            // Log this security event
            store.dispatch(AddSecurityEvent(
              event: SecurityEvent(
                id: 'rate_limit_reset_${DateTime.now().millisecondsSinceEpoch}',
                type: SecurityEventType.accountUnlocked,
                description: 'Login attempts reset',
                timestamp: DateTime.now(),
                metadata: {
                  'identifier': action.identifier,
                },
              ),
            ));
          }
        } catch (e) {
          store.dispatch(RateLimitError(
            message: 'Failed to reset login attempts: $e',
            stackTrace: StackTrace.current,
          ));
        }
      },
    ).call,
    // Clean up expired lockouts on app start and periodically
    TypedMiddleware<AppState, dynamic>(
      (store, action, next) async {
        // Only run cleanup on specific actions to avoid performance issues
        const cleanupActions = [
          'app/init',
          'app/foreground',
        ];

        if (cleanupActions.contains(action.type)) {
          store.dispatch(const ClearExpiredLockouts());
        }

        next(action);
      },
    ).call,
  ];
}
