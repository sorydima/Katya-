import 'package:katya/store/security/ip_whitelist/model.dart';

class SetIPWhitelistLoading {
  final bool loading;
  const SetIPWhitelistLoading({required this.loading});
}

class LoadIPWhitelistRules {
  const LoadIPWhitelistRules();
}

class AddIPWhitelistRule {
  final IPWhitelistRule rule;
  const AddIPWhitelistRule({required this.rule});
}

class UpdateIPWhitelistRule {
  final IPWhitelistRule rule;
  const UpdateIPWhitelistRule({required this.rule});
}

class RemoveIPWhitelistRule {
  final String ruleId;
  const RemoveIPWhitelistRule({required this.ruleId});
}

class SetIPWhitelistEnabled {
  final bool enabled;
  const SetIPWhitelistEnabled({required this.enabled});
}

class IPWhitelistError {
  final String message;
  final StackTrace? stackTrace;

  const IPWhitelistError({
    required this.message,
    this.stackTrace,
  });

  @override
  String toString() => 'IPWhitelistError(message: $message, stackTrace: $stackTrace)';
}
