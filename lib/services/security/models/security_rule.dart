import 'package:equatable/equatable.dart';

/// Правило безопасности
class SecurityRule extends Equatable {
  final String ruleId;
  final String name;
  final RuleType type;
  final Map<String, dynamic> conditions;
  final List<RuleAction> actions;

  const SecurityRule({
    required this.ruleId,
    required this.name,
    required this.type,
    required this.conditions,
    required this.actions,
  });

  @override
  List<Object?> get props => [ruleId, name, type, conditions, actions];
}

/// Типы правил
enum RuleType { authentication, authorization, encryption, monitoring }

/// Действия правил
enum RuleAction { allow, block, require, warn, log }
