import 'package:katya/store/index.dart';
import 'package:katya/store/security/ip_whitelist/actions.dart';
import 'package:katya/store/security/ip_whitelist/model.dart';
import 'package:redux/redux.dart';

class IPWhitelistState {
  final bool isLoading;
  final bool isEnabled;
  final List<IPWhitelistRule> rules;
  final String? error;

  const IPWhitelistState({
    this.isLoading = false,
    this.isEnabled = false,
    this.rules = const [],
    this.error,
  });

  IPWhitelistState copyWith({
    bool? isLoading,
    bool? isEnabled,
    List<IPWhitelistRule>? rules,
    String? error,
  }) {
    return IPWhitelistState(
      isLoading: isLoading ?? this.isLoading,
      isEnabled: isEnabled ?? this.isEnabled,
      rules: rules ?? this.rules,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is IPWhitelistState &&
        other.isLoading == isLoading &&
        other.isEnabled == isEnabled &&
        other.rules == rules &&
        other.error == error;
  }

  @override
  int get hashCode {
    return isLoading.hashCode ^ isEnabled.hashCode ^ rules.hashCode ^ error.hashCode;
  }
}

IPWhitelistState ipWhitelistReducer(IPWhitelistState state, dynamic action) {
  if (action is SetIPWhitelistLoading) {
    return state.copyWith(isLoading: action.loading);
  }

  if (action is SetIPWhitelistEnabled) {
    return state.copyWith(isEnabled: action.enabled);
  }

  if (action is LoadIPWhitelistRules) {
    return state.copyWith(isLoading: true, error: null);
  }

  if (action is AddIPWhitelistRule) {
    return state.copyWith(
      rules: [...state.rules, action.rule],
      error: null,
    );
  }

  if (action is UpdateIPWhitelistRule) {
    return state.copyWith(
      rules: state.rules.map((rule) => rule.id == action.rule.id ? action.rule : rule).toList(),
      error: null,
    );
  }

  if (action is RemoveIPWhitelistRule) {
    return state.copyWith(
      rules: state.rules.where((rule) => rule.id != action.ruleId).toList(),
      error: null,
    );
  }

  if (action is IPWhitelistError) {
    return state.copyWith(error: action.message);
  }

  return state;
}

// Middleware for handling async operations
List<Middleware<AppState>> createIPWhitelistMiddleware() {
  return [
    TypedMiddleware<AppState, LoadIPWhitelistRules>(
      (store, action, next) async {
        next(const SetIPWhitelistLoading(loading: true));
        try {
          // TODO: Implement actual API call to load rules
          await Future.delayed(const Duration(milliseconds: 500));
          // For now, we'll just set some mock data
          final mockRules = [
            IPWhitelistRule(
              id: '1',
              name: 'Home Network',
              ipAddress: '192.168.1.100',
              subnetMask: '255.255.255.0',
              isActive: true,
            ),
          ];

          // Add mock rules to the store
          for (final rule in mockRules) {
            next(AddIPWhitelistRule(rule: rule));
          }

          next(const SetIPWhitelistEnabled(enabled: true));
        } catch (e) {
          next(IPWhitelistError(
            message: 'Failed to load IP whitelist rules: $e',
            stackTrace: StackTrace.current,
          ));
        } finally {
          next(const SetIPWhitelistLoading(loading: false));
        }
      },
    ).call,
    TypedMiddleware<AppState, AddIPWhitelistRule>(
      (store, action, next) async {
        try {
          // TODO: Implement actual API call to add rule
          await Future.delayed(const Duration(milliseconds: 300));
          next(action);
        } catch (e) {
          next(IPWhitelistError(
            message: 'Failed to add IP whitelist rule: $e',
            stackTrace: StackTrace.current,
          ));
        }
      },
    ).call,
    TypedMiddleware<AppState, UpdateIPWhitelistRule>(
      (store, action, next) async {
        try {
          // TODO: Implement actual API call to update rule
          await Future.delayed(const Duration(milliseconds: 300));
          next(action);
        } catch (e) {
          next(IPWhitelistError(
            message: 'Failed to update IP whitelist rule: $e',
            stackTrace: StackTrace.current,
          ));
        }
      },
    ).call,
    TypedMiddleware<AppState, RemoveIPWhitelistRule>(
      (store, action, next) async {
        try {
          // TODO: Implement actual API call to remove rule
          await Future.delayed(const Duration(milliseconds: 300));
          next(action);
        } catch (e) {
          next(IPWhitelistError(
            message: 'Failed to remove IP whitelist rule: $e',
            stackTrace: StackTrace.current,
          ));
        }
      },
    ).call,
    TypedMiddleware<AppState, SetIPWhitelistEnabled>(
      (store, action, next) async {
        try {
          // TODO: Implement actual API call to update enabled status
          await Future.delayed(const Duration(milliseconds: 300));
          next(action);
        } catch (e) {
          next(IPWhitelistError(
            message: 'Failed to update IP whitelist status: $e',
            stackTrace: StackTrace.current,
          ));
        }
      },
    ).call,
  ];
}
