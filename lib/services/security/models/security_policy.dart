import 'package:equatable/equatable.dart';

/// Тип политики безопасности
enum PolicyType {
  authentication,
  authorization,
  encryption,
  audit,
}

/// Модель политики безопасности
class SecurityPolicy extends Equatable {
  final String id;
  final String name;
  final PolicyType type;
  final String description;
  final bool isEnabled;
  final Map<String, dynamic>? configuration;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SecurityPolicy({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.isEnabled,
    this.configuration,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        description,
        isEnabled,
        configuration,
        createdAt,
        updatedAt,
      ];

  SecurityPolicy copyWith({
    String? id,
    String? name,
    PolicyType? type,
    String? description,
    bool? isEnabled,
    Map<String, dynamic>? configuration,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SecurityPolicy(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      isEnabled: isEnabled ?? this.isEnabled,
      configuration: configuration ?? this.configuration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory SecurityPolicy.fromJson(Map<String, dynamic> json) {
    return SecurityPolicy(
      id: json['id'] as String,
      name: json['name'] as String,
      type: PolicyType.values.firstWhere(
        (e) => e.toString() == 'PolicyType.${json['type']}',
        orElse: () => PolicyType.authentication,
      ),
      description: json['description'] as String,
      isEnabled: json['isEnabled'] as bool,
      configuration: json['configuration'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'description': description,
      'isEnabled': isEnabled,
      'configuration': configuration,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
