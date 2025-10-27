import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:path/path.dart' as path;

/// Сервис для импорта данных из различных форматов
class DataImportService {
  static final DataImportService _instance = DataImportService._internal();

  factory DataImportService() => _instance;

  DataImportService._internal();

  /// Импорт данных из JSON файла
  Future<ImportResult> importFromJson({
    required String filePath,
    bool validateSchema = true,
    Map<String, dynamic>? schema,
    bool preserveMetadata = true,
  }) async {
    try {
      final File file = File(filePath);
      if (!await file.exists()) {
        return ImportResult(
          success: false,
          error: 'File does not exist: $filePath',
          format: ImportFormat.json,
        );
      }

      final String content = await file.readAsString();
      final Map<String, dynamic> jsonData = jsonDecode(content);

      // Валидация схемы
      if (validateSchema && schema != null) {
        final ValidationResult validation = _validateJsonSchema(jsonData, schema);
        if (!validation.isValid) {
          return ImportResult(
            success: false,
            error: 'Schema validation failed: ${validation.errors.join(', ')}',
            format: ImportFormat.json,
          );
        }
      }

      final Map<String, dynamic> data = (jsonData['data'] ?? jsonData) as Map<String, dynamic>;
      final Map<String, dynamic>? metadata = preserveMetadata ? (jsonData['metadata'] as Map<String, dynamic>?) : null;

      return ImportResult(
        success: true,
        data: data,
        metadata: metadata,
        recordCount: _countRecords(data),
        format: ImportFormat.json,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        error: 'Failed to import JSON: $e',
        format: ImportFormat.json,
      );
    }
  }

  /// Импорт данных из CSV файла
  Future<ImportResult> importFromCsv({
    required String filePath,
    String delimiter = ',',
    bool hasHeaders = true,
    List<String>? expectedColumns,
    bool validateData = true,
  }) async {
    try {
      final File file = File(filePath);
      if (!await file.exists()) {
        return ImportResult(
          success: false,
          error: 'File does not exist: $filePath',
          format: ImportFormat.csv,
        );
      }

      final List<String> lines = await file.readAsLines();
      final List<String> dataLines = lines.where((line) => line.trim().isNotEmpty && !line.startsWith('#')).toList();

      if (dataLines.isEmpty) {
        return const ImportResult(
          success: false,
          error: 'No data found in CSV file',
          format: ImportFormat.csv,
        );
      }

      List<String> headers;
      final List<Map<String, dynamic>> data = [];

      if (hasHeaders) {
        headers = _parseCsvLine(dataLines.first, delimiter);
        dataLines.removeAt(0);
      } else {
        // Генерируем заголовки если их нет
        headers = List.generate(
          _parseCsvLine(dataLines.first, delimiter).length,
          (index) => 'column_$index',
        );
      }

      // Валидация колонок
      if (expectedColumns != null) {
        final Set<String> missingColumns = expectedColumns.toSet().difference(headers.toSet());
        if (missingColumns.isNotEmpty) {
          return ImportResult(
            success: false,
            error: 'Missing required columns: ${missingColumns.join(', ')}',
            format: ImportFormat.csv,
          );
        }
      }

      // Парсинг данных
      for (final String line in dataLines) {
        final List<String> values = _parseCsvLine(line, delimiter);
        if (values.length != headers.length) {
          if (validateData) {
            return ImportResult(
              success: false,
              error: 'Column count mismatch in line: $line',
              format: ImportFormat.csv,
            );
          }
          continue; // Пропускаем некорректные строки
        }

        final Map<String, dynamic> row = {};
        for (int i = 0; i < headers.length; i++) {
          row[headers[i]] = _parseCsvValue(values[i]);
        }
        data.add(row);
      }

      return ImportResult(
        success: true,
        data: {'records': data},
        recordCount: data.length,
        format: ImportFormat.csv,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        error: 'Failed to import CSV: $e',
        format: ImportFormat.csv,
      );
    }
  }

  /// Импорт данных из XML файла
  Future<ImportResult> importFromXml({
    required String filePath,
    String rootElement = 'data',
    bool validateSchema = true,
    Map<String, dynamic>? schema,
  }) async {
    try {
      final File file = File(filePath);
      if (!await file.exists()) {
        return ImportResult(
          success: false,
          error: 'File does not exist: $filePath',
          format: ImportFormat.xml,
        );
      }

      final String content = await file.readAsString();
      final Map<String, dynamic> xmlData = _parseXmlContent(content, rootElement);

      // Валидация схемы
      if (validateSchema && schema != null) {
        final ValidationResult validation = _validateJsonSchema(xmlData, schema);
        if (!validation.isValid) {
          return ImportResult(
            success: false,
            error: 'Schema validation failed: ${validation.errors.join(', ')}',
            format: ImportFormat.xml,
          );
        }
      }

      return ImportResult(
        success: true,
        data: xmlData,
        recordCount: _countRecords(xmlData),
        format: ImportFormat.xml,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        error: 'Failed to import XML: $e',
        format: ImportFormat.xml,
      );
    }
  }

  /// Массовый импорт из нескольких файлов
  Future<List<ImportResult>> importFromMultipleFiles({
    required List<String> filePaths,
    ImportFormat? format,
    Map<String, dynamic>? options,
  }) async {
    final List<ImportResult> results = [];

    for (final String filePath in filePaths) {
      final ImportFormat detectedFormat = format ?? _detectFormat(filePath);

      ImportResult result;
      switch (detectedFormat) {
        case ImportFormat.json:
          result = await importFromJson(
            filePath: filePath,
            validateSchema: options?['validateSchema'] ?? true,
            schema: options?['schema'],
          );
        case ImportFormat.csv:
          result = await importFromCsv(
            filePath: filePath,
            delimiter: options?['delimiter'] ?? ',',
            hasHeaders: options?['hasHeaders'] ?? true,
            expectedColumns: options?['expectedColumns'],
          );
        case ImportFormat.xml:
          result = await importFromXml(
            filePath: filePath,
            rootElement: options?['rootElement'] ?? 'data',
            validateSchema: options?['validateSchema'] ?? true,
            schema: options?['schema'],
          );
        default:
          result = ImportResult(
            success: false,
            error: 'Unsupported format for file: $filePath',
            format: detectedFormat,
          );
      }
      results.add(result);
    }

    return results;
  }

  /// Валидация файла перед импортом
  Future<ValidationResult> validateFile({
    required String filePath,
    ImportFormat? format,
    Map<String, dynamic>? schema,
  }) async {
    try {
      final File file = File(filePath);
      if (!await file.exists()) {
        return ValidationResult(
          isValid: false,
          errors: ['File does not exist: $filePath'],
        );
      }

      final ImportFormat detectedFormat = format ?? _detectFormat(filePath);
      final List<String> errors = [];

      // Проверка размера файла
      final int fileSize = await file.length();
      if (fileSize > 100 * 1024 * 1024) {
        // 100MB
        errors.add('File size exceeds maximum limit (100MB)');
      }

      // Проверка формата
      switch (detectedFormat) {
        case ImportFormat.json:
          try {
            final String content = await file.readAsString();
            jsonDecode(content);
          } catch (e) {
            errors.add('Invalid JSON format: $e');
          }
        case ImportFormat.csv:
          try {
            final List<String> lines = await file.readAsLines();
            if (lines.isEmpty) {
              errors.add('CSV file is empty');
            }
          } catch (e) {
            errors.add('Invalid CSV format: $e');
          }
        case ImportFormat.xml:
          try {
            final String content = await file.readAsString();
            if (!content.contains('<?xml')) {
              errors.add('Invalid XML format: missing XML declaration');
            }
          } catch (e) {
            errors.add('Invalid XML format: $e');
          }
        default:
          errors.add('Unsupported file format');
      }

      // Валидация схемы
      if (schema != null && errors.isEmpty) {
        try {
          final ImportResult importResult = await _importForValidation(filePath, detectedFormat);
          if (importResult.success && importResult.data != null) {
            final ValidationResult schemaValidation = _validateJsonSchema(importResult.data!, schema);
            errors.addAll(schemaValidation.errors);
          }
        } catch (e) {
          errors.add('Schema validation failed: $e');
        }
      }

      return ValidationResult(
        isValid: errors.isEmpty,
        errors: errors,
      );
    } catch (e) {
      return ValidationResult(
        isValid: false,
        errors: ['Validation failed: $e'],
      );
    }
  }

  /// Вспомогательные методы

  ImportFormat _detectFormat(String filePath) {
    final String extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.json':
        return ImportFormat.json;
      case '.csv':
        return ImportFormat.csv;
      case '.xml':
        return ImportFormat.xml;
      default:
        return ImportFormat.unknown;
    }
  }

  List<String> _parseCsvLine(String line, String delimiter) {
    final List<String> result = [];
    bool inQuotes = false;
    final StringBuffer currentField = StringBuffer();

    for (int i = 0; i < line.length; i++) {
      final String char = line[i];

      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          currentField.write('"');
          i++; // Пропускаем следующий символ
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == delimiter && !inQuotes) {
        result.add(currentField.toString().trim());
        currentField.clear();
      } else {
        currentField.write(char);
      }
    }

    result.add(currentField.toString().trim());
    return result;
  }

  dynamic _parseCsvValue(String value) {
    // Попытка парсинга как число
    if (RegExp(r'^-?\d+$').hasMatch(value)) {
      return int.tryParse(value);
    }
    if (RegExp(r'^-?\d*\.\d+$').hasMatch(value)) {
      return double.tryParse(value);
    }

    // Попытка парсинга как boolean
    if (value.toLowerCase() == 'true') return true;
    if (value.toLowerCase() == 'false') return false;

    // Возвращаем как строку
    return value;
  }

  Map<String, dynamic> _parseXmlContent(String content, String rootElement) {
    // Упрощенный XML парсер для демонстрации
    // В реальном приложении следует использовать специализированную библиотеку
    final Map<String, dynamic> result = {};

    // Удаляем XML декларацию и комментарии
    final String cleanContent =
        content.replaceAll(RegExp(r'<\?xml[^>]*\?>'), '').replaceAll(RegExp('<!--.*?-->', multiLine: true), '').trim();

    // Извлекаем содержимое корневого элемента
    final RegExp rootRegex = RegExp('<$rootElement>(.*?)</$rootElement>', multiLine: true);
    final Match? rootMatch = rootRegex.firstMatch(cleanContent);

    if (rootMatch != null) {
      final String rootContent = rootMatch.group(1) ?? '';
      result[rootElement] = _parseXmlElement(rootContent);
    }

    return result;
  }

  dynamic _parseXmlElement(String content) {
    final Map<String, dynamic> result = {};
    final RegExp elementRegex = RegExp(r'<(\w+)>(.*?)</\1>', multiLine: true);

    for (final Match match in elementRegex.allMatches(content)) {
      final String tagName = match.group(1)!;
      final String tagContent = match.group(2)!;

      if (tagContent.contains('<')) {
        result[tagName] = _parseXmlElement(tagContent);
      } else {
        result[tagName] = tagContent.trim();
      }
    }

    return result.isNotEmpty ? result : content.trim();
  }

  ValidationResult _validateJsonSchema(Map<String, dynamic> data, Map<String, dynamic> schema) {
    final List<String> errors = [];

    // Простая валидация схемы
    if (schema.containsKey('required')) {
      final List<String> requiredFields = List<String>.from(schema['required']);
      for (final String field in requiredFields) {
        if (!data.containsKey(field)) {
          errors.add('Required field missing: $field');
        }
      }
    }

    if (schema.containsKey('properties')) {
      final Map<String, dynamic> properties = schema['properties'];
      for (final MapEntry<String, dynamic> entry in data.entries) {
        if (properties.containsKey(entry.key)) {
          final Map<String, dynamic> fieldSchema = properties[entry.key];
          final String? type = fieldSchema['type'];

          if (type != null) {
            switch (type) {
              case 'string':
                if (entry.value is! String) {
                  errors.add('Field ${entry.key} must be a string');
                }
              case 'number':
                if (entry.value is! num) {
                  errors.add('Field ${entry.key} must be a number');
                }
              case 'boolean':
                if (entry.value is! bool) {
                  errors.add('Field ${entry.key} must be a boolean');
                }
            }
          }
        }
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  int _countRecords(dynamic data) {
    if (data is List) {
      return data.length;
    } else if (data is Map) {
      return data.length;
    }
    return 1;
  }

  Future<ImportResult> _importForValidation(String filePath, ImportFormat format) async {
    switch (format) {
      case ImportFormat.json:
        return await importFromJson(filePath: filePath, validateSchema: false);
      case ImportFormat.csv:
        return await importFromCsv(filePath: filePath, validateData: false);
      case ImportFormat.xml:
        return await importFromXml(filePath: filePath, validateSchema: false);
      default:
        return ImportResult(
          success: false,
          error: 'Unsupported format',
          format: format,
        );
    }
  }
}

/// Форматы импорта
enum ImportFormat {
  json,
  csv,
  xml,
  unknown,
}

/// Результат импорта
class ImportResult extends Equatable {
  final bool success;
  final Map<String, dynamic>? data;
  final Map<String, dynamic>? metadata;
  final int? recordCount;
  final ImportFormat format;
  final String? error;

  const ImportResult({
    required this.success,
    this.data,
    this.metadata,
    this.recordCount,
    required this.format,
    this.error,
  });

  @override
  List<Object?> get props => [success, data, metadata, recordCount, format, error];
}

/// Результат валидации
class ValidationResult extends Equatable {
  final bool isValid;
  final List<String> errors;

  const ValidationResult({
    required this.isValid,
    required this.errors,
  });

  @override
  List<Object?> get props => [isValid, errors];
}
