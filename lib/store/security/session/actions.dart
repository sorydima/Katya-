import 'package:katya/store/security/session/model.dart';

class SetSessionSettings {
  final SessionSettings settings;
  const SetSessionSettings({required this.settings});
}

class SetSessionLoading {
  final bool loading;
  const SetSessionLoading({required this.loading});
}

class UpdateLastActivityTime {
  final DateTime time;
  const UpdateLastActivityTime({required this.time});
}

class LockSession {
  const LockSession();
}

class UnlockSession {
  const UnlockSession();
}

class ShowSessionTimeoutWarning {
  final bool show;
  const ShowSessionTimeoutWarning({required this.show});
}

class SessionError {
  final String message;
  final StackTrace? stackTrace;

  const SessionError({
    required this.message,
    this.stackTrace,
  });

  @override
  String toString() => 'SessionError(message: $message, stackTrace: $stackTrace)';
}
