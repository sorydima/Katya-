import 'package:equatable/equatable.dart';

/// Сервис для валидации данных при экспорте и импорте
class DataValidationService {
  static final DataValidationService _instance = DataValidationService._internal();

  factory DataValidationService() => _instance;

  DataValidationService._internal();

  /// Валидация структуры данных
  Future<ValidationResult> validateDataStructure({
    required Map<String, dynamic> data,
    required Map<String, dynamic> schema,
    bool strict = true,
  }) async {
    try {
      final List<String> errors = [];
      final List<String> warnings = [];

      // Валидация обязательных полей
      if (schema.containsKey('required')) {
        final List<String> requiredFields = List<String>.from(schema['required']);
        for (final String field in requiredFields) {
          if (!data.containsKey(field)) {
            errors.add('Required field missing: $field');
          }
        }
      }

      // Валидация типов полей
      if (schema.containsKey('properties')) {
        final Map<String, dynamic> properties = schema['properties'];
        for (final MapEntry<String, dynamic> entry in data.entries) {
          if (properties.containsKey(entry.key)) {
            final Map<String, dynamic> fieldSchema = properties[entry.key];
            final ValidationResult fieldValidation = _validateField(
              entry.key,
              entry.value,
              fieldSchema,
              strict,
            );
            errors.addAll(fieldValidation.errors);
            warnings.addAll(fieldValidation.warnings);
          } else if (strict) {
            errors.add('Unexpected field: ${entry.key}');
          } else {
            warnings.add('Unexpected field: ${entry.key}');
          }
        }
      }

      // Валидация ограничений
      if (schema.containsKey('constraints')) {
        final Map<String, dynamic> constraints = schema['constraints'];
        final ValidationResult constraintValidation = _validateConstraints(data, constraints);
        errors.addAll(constraintValidation.errors);
        warnings.addAll(constraintValidation.warnings);
      }

      return ValidationResult(
        isValid: errors.isEmpty,
        errors: errors,
        warnings: warnings,
      );
    } catch (e) {
      return ValidationResult(
        isValid: false,
        errors: ['Validation failed: $e'],
        warnings: const [],
      );
    }
  }

  /// Валидация данных CSV
  Future<ValidationResult> validateCsvData({
    required List<Map<String, dynamic>> data,
    required List<String> expectedColumns,
    Map<String, dynamic>? columnTypes,
    Map<String, dynamic>? constraints,
  }) async {
    try {
      final List<String> errors = [];
      final List<String> warnings = [];

      if (data.isEmpty) {
        errors.add('CSV data is empty');
        return ValidationResult(
          isValid: false,
          errors: errors,
          warnings: warnings,
        );
      }

      // Проверка наличия всех ожидаемых колонок
      final Set<String> actualColumns = data.first.keys.toSet();
      final Set<String> missingColumns = expectedColumns.toSet().difference(actualColumns);
      if (missingColumns.isNotEmpty) {
        errors.add('Missing columns: ${missingColumns.join(', ')}');
      }

      // Проверка типов данных в колонках
      if (columnTypes != null) {
        for (final MapEntry<String, dynamic> typeEntry in columnTypes.entries) {
          final String columnName = typeEntry.key;
          final String expectedType = typeEntry.value.toString();

          for (int i = 0; i < data.length; i++) {
            final dynamic value = data[i][columnName];
            if (value != null) {
              final ValidationResult typeValidation = _validateDataType(
                value,
                expectedType,
                'Row ${i + 1}, Column $columnName',
              );
              errors.addAll(typeValidation.errors);
              warnings.addAll(typeValidation.warnings);
            }
          }
        }
      }

      // Проверка ограничений
      if (constraints != null) {
        for (final MapEntry<String, dynamic> constraint in constraints.entries) {
          final String columnName = constraint.key;
          final Map<String, dynamic> columnConstraints = constraint.value;

          for (int i = 0; i < data.length; i++) {
            final dynamic value = data[i][columnName];
            if (value != null) {
              final ValidationResult constraintValidation = _validateFieldConstraints(
                value,
                columnConstraints,
                'Row ${i + 1}, Column $columnName',
              );
              errors.addAll(constraintValidation.errors);
              warnings.addAll(constraintValidation.warnings);
            }
          }
        }
      }

      return ValidationResult(
        isValid: errors.isEmpty,
        errors: errors,
        warnings: warnings,
      );
    } catch (e) {
      return ValidationResult(
        isValid: false,
        errors: ['CSV validation failed: $e'],
        warnings: const [],
      );
    }
  }

  /// Валидация JSON схемы
  Future<ValidationResult> validateJsonSchema({
    required Map<String, dynamic> schema,
  }) async {
    try {
      final List<String> errors = [];
      final List<String> warnings = [];

      // Проверка обязательных полей схемы
      if (!schema.containsKey('type')) {
        errors.add('Schema must contain a "type" field');
      }

      // Валидация типа схемы
      final String? schemaType = schema['type'];
      if (schemaType != null && !['object', 'array'].contains(schemaType)) {
        errors.add('Schema type must be "object" or "array"');
      }

      // Валидация свойств
      if (schema.containsKey('properties')) {
        final dynamic properties = schema['properties'];
        if (properties is! Map<String, dynamic>) {
          errors.add('Properties must be an object');
        } else {
          for (final MapEntry<String, dynamic> property in properties.entries) {
            final ValidationResult propertyValidation = _validatePropertySchema(
              property.key,
              property.value,
            );
            errors.addAll(propertyValidation.errors);
            warnings.addAll(propertyValidation.warnings);
          }
        }
      }

      // Валидация обязательных полей
      if (schema.containsKey('required')) {
        final dynamic required = schema['required'];
        if (required is! List) {
          errors.add('Required must be an array');
        } else {
          final List<String> requiredFields = required.cast<String>();
          if (schema.containsKey('properties')) {
            final Map<String, dynamic> properties = schema['properties'];
            for (final String field in requiredFields) {
              if (!properties.containsKey(field)) {
                errors.add('Required field "$field" not defined in properties');
              }
            }
          }
        }
      }

      return ValidationResult(
        isValid: errors.isEmpty,
        errors: errors,
        warnings: warnings,
      );
    } catch (e) {
      return ValidationResult(
        isValid: false,
        errors: ['Schema validation failed: $e'],
        warnings: const [],
      );
    }
  }

  /// Валидация данных на соответствие бизнес-правилам
  Future<ValidationResult> validateBusinessRules({
    required Map<String, dynamic> data,
    required List<BusinessRule> rules,
  }) async {
    try {
      final List<String> errors = [];
      final List<String> warnings = [];

      for (final BusinessRule rule in rules) {
        final ValidationResult ruleValidation = await _validateBusinessRule(data, rule);
        errors.addAll(ruleValidation.errors);
        warnings.addAll(ruleValidation.warnings);
      }

      return ValidationResult(
        isValid: errors.isEmpty,
        errors: errors,
        warnings: warnings,
      );
    } catch (e) {
      return ValidationResult(
        isValid: false,
        errors: ['Business rules validation failed: $e'],
        warnings: const [],
      );
    }
  }

  /// Валидация целостности данных
  Future<ValidationResult> validateDataIntegrity({
    required Map<String, dynamic> data,
    required List<IntegrityConstraint> constraints,
  }) async {
    try {
      final List<String> errors = [];
      final List<String> warnings = [];

      for (final IntegrityConstraint constraint in constraints) {
        final ValidationResult constraintValidation = await _validateIntegrityConstraint(data, constraint);
        errors.addAll(constraintValidation.errors);
        warnings.addAll(constraintValidation.warnings);
      }

      return ValidationResult(
        isValid: errors.isEmpty,
        errors: errors,
        warnings: warnings,
      );
    } catch (e) {
      return ValidationResult(
        isValid: false,
        errors: ['Data integrity validation failed: $e'],
        warnings: const [],
      );
    }
  }

  /// Вспомогательные методы

  ValidationResult _validateField(
    String fieldName,
    dynamic value,
    Map<String, dynamic> fieldSchema,
    bool strict,
  ) {
    final List<String> errors = [];
    final List<String> warnings = [];

    // Валидация типа
    if (fieldSchema.containsKey('type')) {
      final String expectedType = fieldSchema['type'];
      final ValidationResult typeValidation = _validateDataType(value, expectedType, fieldName);
      errors.addAll(typeValidation.errors);
      warnings.addAll(typeValidation.warnings);
    }

    // Валидация ограничений
    final ValidationResult constraintValidation = _validateFieldConstraints(value, fieldSchema, fieldName);
    errors.addAll(constraintValidation.errors);
    warnings.addAll(constraintValidation.warnings);

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  ValidationResult _validateDataType(dynamic value, String expectedType, String context) {
    final List<String> errors = [];
    final List<String> warnings = [];

    switch (expectedType) {
      case 'string':
        if (value is! String) {
          errors.add('$context: Expected string, got ${value.runtimeType}');
        }
      case 'number':
        if (value is! num) {
          errors.add('$context: Expected number, got ${value.runtimeType}');
        }
      case 'integer':
        if (value is! int) {
          errors.add('$context: Expected integer, got ${value.runtimeType}');
        }
      case 'boolean':
        if (value is! bool) {
          errors.add('$context: Expected boolean, got ${value.runtimeType}');
        }
      case 'array':
        if (value is! List) {
          errors.add('$context: Expected array, got ${value.runtimeType}');
        }
      case 'object':
        if (value is! Map) {
          errors.add('$context: Expected object, got ${value.runtimeType}');
        }
      case 'date':
        if (value is String) {
          try {
            DateTime.parse(value);
          } catch (e) {
            errors.add('$context: Invalid date format');
          }
        } else {
          errors.add('$context: Expected date string, got ${value.runtimeType}');
        }
      case 'email':
        if (value is String) {
          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
            errors.add('$context: Invalid email format');
          }
        } else {
          errors.add('$context: Expected email string, got ${value.runtimeType}');
        }
      case 'url':
        if (value is String) {
          if (!RegExp('^https?://').hasMatch(value)) {
            errors.add('$context: Invalid URL format');
          }
        } else {
          errors.add('$context: Expected URL string, got ${value.runtimeType}');
        }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  ValidationResult _validateFieldConstraints(
    dynamic value,
    Map<String, dynamic> constraints,
    String context,
  ) {
    final List<String> errors = [];
    final List<String> warnings = [];

    for (final MapEntry<String, dynamic> constraint in constraints.entries) {
      final String constraintType = constraint.key;
      final dynamic constraintValue = constraint.value;

      switch (constraintType) {
        case 'minLength':
          if (value is String && value.length < constraintValue) {
            errors.add('$context: String too short (min: $constraintValue)');
          }
        case 'maxLength':
          if (value is String && value.length > constraintValue) {
            errors.add('$context: String too long (max: $constraintValue)');
          }
        case 'min':
          if (value is num && value < constraintValue) {
            errors.add('$context: Value too small (min: $constraintValue)');
          }
        case 'max':
          if (value is num && value > constraintValue) {
            errors.add('$context: Value too large (max: $constraintValue)');
          }
        case 'pattern':
          if (value is String && !RegExp(constraintValue).hasMatch(value)) {
            errors.add('$context: Value does not match pattern');
          }
        case 'enum':
          if (constraintValue is List && !constraintValue.contains(value)) {
            errors.add('$context: Value not in allowed values: ${constraintValue.join(', ')}');
          }
        case 'required':
          if (constraintValue == true && (value == null || value == '')) {
            errors.add('$context: Field is required');
          }
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  ValidationResult _validateConstraints(
    Map<String, dynamic> data,
    Map<String, dynamic> constraints,
  ) {
    final List<String> errors = [];
    final List<String> warnings = [];

    for (final MapEntry<String, dynamic> constraint in constraints.entries) {
      final String constraintType = constraint.key;
      final dynamic constraintValue = constraint.value;

      switch (constraintType) {
        case 'unique':
          if (constraintValue is List) {
            final Set<dynamic> seen = {};
            for (final String field in constraintValue) {
              final dynamic value = data[field];
              if (seen.contains(value)) {
                errors.add('Duplicate value for field: $field');
              }
              seen.add(value);
            }
          }
        case 'conditional':
          if (constraintValue is Map) {
            final String condition = constraintValue['condition'] ?? '';
            final String field = constraintValue['field'] ?? '';
            final dynamic expectedValue = constraintValue['value'];

            if (condition == 'if' && data.containsKey(field) && data[field] == expectedValue) {
              // Проверяем дополнительные условия
              if (constraintValue.containsKey('then')) {
                final Map<String, dynamic> thenConditions = constraintValue['then'];
                for (final MapEntry<String, dynamic> thenCondition in thenConditions.entries) {
                  if (!data.containsKey(thenCondition.key) || data[thenCondition.key] != thenCondition.value) {
                    errors.add('Conditional requirement not met: ${thenCondition.key}');
                  }
                }
              }
            }
          }
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  ValidationResult _validatePropertySchema(String propertyName, dynamic propertySchema) {
    final List<String> errors = [];
    final List<String> warnings = [];

    if (propertySchema is! Map<String, dynamic>) {
      errors.add('Property "$propertyName" schema must be an object');
      return ValidationResult(
        isValid: false,
        errors: errors,
        warnings: warnings,
      );
    }

    // Проверка типа
    if (propertySchema.containsKey('type')) {
      final String type = propertySchema['type'];
      if (!['string', 'number', 'integer', 'boolean', 'array', 'object', 'date', 'email', 'url'].contains(type)) {
        errors.add('Property "$propertyName" has invalid type: $type');
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  Future<ValidationResult> _validateBusinessRule(
    Map<String, dynamic> data,
    BusinessRule rule,
  ) async {
    final List<String> errors = [];
    final List<String> warnings = [];

    try {
      switch (rule.type) {
        case BusinessRuleType.custom:
          // Выполнение пользовательского правила
          if (rule.validator != null) {
            final bool isValid = await rule.validator!(data);
            if (!isValid) {
              errors.add(rule.message);
            }
          }
        case BusinessRuleType.range:
          if (rule.field != null && rule.minValue != null && rule.maxValue != null) {
            final dynamic value = data[rule.field];
            if (value is num) {
              if (value < rule.minValue! || value > rule.maxValue!) {
                errors.add('${rule.field}: Value must be between ${rule.minValue} and ${rule.maxValue}');
              }
            }
          }
        case BusinessRuleType.format:
          if (rule.field != null && rule.pattern != null) {
            final dynamic value = data[rule.field];
            if (value is String && !RegExp(rule.pattern!).hasMatch(value)) {
              errors.add('${rule.field}: Value does not match required format');
            }
          }
      }
    } catch (e) {
      errors.add('Business rule validation error: $e');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  Future<ValidationResult> _validateIntegrityConstraint(
    Map<String, dynamic> data,
    IntegrityConstraint constraint,
  ) async {
    final List<String> errors = [];
    final List<String> warnings = [];

    try {
      switch (constraint.type) {
        case IntegrityConstraintType.foreignKey:
          // Проверка внешнего ключа
          if (constraint.referenceField != null && constraint.referenceTable != null) {
            // Здесь должна быть логика проверки существования записи в связанной таблице
            // Для демонстрации просто проверяем, что поле не пустое
            final dynamic value = data[constraint.field];
            if (value == null || value == '') {
              errors.add('${constraint.field}: Foreign key cannot be empty');
            }
          }
        case IntegrityConstraintType.unique:
          // Проверка уникальности
          if (constraint.fields != null) {
            final Set<String> seen = {};
            for (final String field in constraint.fields!) {
              final dynamic value = data[field];
              final String key = '$field:$value';
              if (seen.contains(key)) {
                errors.add('Duplicate value for unique constraint: $field');
              }
              seen.add(key);
            }
          }
        case IntegrityConstraintType.check:
          // Проверка условия
          if (constraint.condition != null) {
            final bool conditionMet = await constraint.condition!(data);
            if (!conditionMet) {
              errors.add('Check constraint failed: ${constraint.description}');
            }
          }
      }
    } catch (e) {
      errors.add('Integrity constraint validation error: $e');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }
}

/// Результат валидации
class ValidationResult extends Equatable {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  @override
  List<Object?> get props => [isValid, errors, warnings];
}

/// Бизнес-правило
class BusinessRule extends Equatable {
  final String name;
  final String message;
  final BusinessRuleType type;
  final String? field;
  final dynamic minValue;
  final dynamic maxValue;
  final String? pattern;
  final Future<bool> Function(Map<String, dynamic>)? validator;

  const BusinessRule({
    required this.name,
    required this.message,
    required this.type,
    this.field,
    this.minValue,
    this.maxValue,
    this.pattern,
    this.validator,
  });

  @override
  List<Object?> get props => [name, message, type, field, minValue, maxValue, pattern, validator];
}

/// Типы бизнес-правил
enum BusinessRuleType {
  custom,
  range,
  format,
}

/// Ограничение целостности
class IntegrityConstraint extends Equatable {
  final String name;
  final String? description;
  final IntegrityConstraintType type;
  final String? field;
  final List<String>? fields;
  final String? referenceField;
  final String? referenceTable;
  final Future<bool> Function(Map<String, dynamic>)? condition;

  const IntegrityConstraint({
    required this.name,
    this.description,
    required this.type,
    this.field,
    this.fields,
    this.referenceField,
    this.referenceTable,
    this.condition,
  });

  @override
  List<Object?> get props => [name, description, type, field, fields, referenceField, referenceTable, condition];
}

/// Типы ограничений целостности
enum IntegrityConstraintType {
  foreignKey,
  unique,
  check,
}
