import 'package:equatable/equatable.dart';

/// Формат импорта данных
enum ImportFormat {
  json,
  csv,
  xml,
  excel,
}

/// Результат импорта данных
class ImportResult extends Equatable {
  final String id;
  final ImportFormat format;
  final int totalRecords;
  final int successfulRecords;
  final int failedRecords;
  final List<String> errors;
  final List<String> warnings;
  final DateTime importedAt;
  final Map<String, dynamic>? metadata;

  const ImportResult({
    required this.id,
    required this.format,
    required this.totalRecords,
    required this.successfulRecords,
    required this.failedRecords,
    required this.errors,
    required this.warnings,
    required this.importedAt,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        format,
        totalRecords,
        successfulRecords,
        failedRecords,
        errors,
        warnings,
        importedAt,
        metadata,
      ];

  ImportResult copyWith({
    String? id,
    ImportFormat? format,
    int? totalRecords,
    int? successfulRecords,
    int? failedRecords,
    List<String>? errors,
    List<String>? warnings,
    DateTime? importedAt,
    Map<String, dynamic>? metadata,
  }) {
    return ImportResult(
      id: id ?? this.id,
      format: format ?? this.format,
      totalRecords: totalRecords ?? this.totalRecords,
      successfulRecords: successfulRecords ?? this.successfulRecords,
      failedRecords: failedRecords ?? this.failedRecords,
      errors: errors ?? this.errors,
      warnings: warnings ?? this.warnings,
      importedAt: importedAt ?? this.importedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  factory ImportResult.fromJson(Map<String, dynamic> json) {
    return ImportResult(
      id: json['id'] as String,
      format: ImportFormat.values.firstWhere(
        (e) => e.toString() == 'ImportFormat.${json['format']}',
        orElse: () => ImportFormat.json,
      ),
      totalRecords: json['totalRecords'] as int,
      successfulRecords: json['successfulRecords'] as int,
      failedRecords: json['failedRecords'] as int,
      errors: List<String>.from(json['errors'] as List),
      warnings: List<String>.from(json['warnings'] as List),
      importedAt: DateTime.parse(json['importedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'format': format.toString().split('.').last,
      'totalRecords': totalRecords,
      'successfulRecords': successfulRecords,
      'failedRecords': failedRecords,
      'errors': errors,
      'warnings': warnings,
      'importedAt': importedAt.toIso8601String(),
      'metadata': metadata,
    };
  }
}

/// Бизнес-правило для валидации данных
class BusinessRule extends Equatable {
  final String id;
  final String name;
  final String description;
  final String field;
  final String condition;
  final String message;
  final bool isActive;

  const BusinessRule({
    required this.id,
    required this.name,
    required this.description,
    required this.field,
    required this.condition,
    required this.message,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        field,
        condition,
        message,
        isActive,
      ];

  BusinessRule copyWith({
    String? id,
    String? name,
    String? description,
    String? field,
    String? condition,
    String? message,
    bool? isActive,
  }) {
    return BusinessRule(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      field: field ?? this.field,
      condition: condition ?? this.condition,
      message: message ?? this.message,
      isActive: isActive ?? this.isActive,
    );
  }

  factory BusinessRule.fromJson(Map<String, dynamic> json) {
    return BusinessRule(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      field: json['field'] as String,
      condition: json['condition'] as String,
      message: json['message'] as String,
      isActive: json['isActive'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'field': field,
      'condition': condition,
      'message': message,
      'isActive': isActive,
    };
  }
}
