import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:path/path.dart' as path;

/// Сервис для экспорта данных в различных форматах
class DataExportService {
  static final DataExportService _instance = DataExportService._internal();

  factory DataExportService() => _instance;

  DataExportService._internal();

  /// Экспорт данных в JSON формат
  Future<ExportResult> exportToJson({
    required Map<String, dynamic> data,
    required String fileName,
    String? outputPath,
    bool prettyPrint = true,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final Map<String, dynamic> exportData = {
        'metadata': {
          'exportDate': DateTime.now().toIso8601String(),
          'version': '1.0',
          'format': 'json',
          if (metadata != null) ...metadata,
        },
        'data': data,
      };

      final String jsonString =
          prettyPrint ? const JsonEncoder.withIndent('  ').convert(exportData) : jsonEncode(exportData);

      final String filePath = _getOutputPath(fileName, 'json', outputPath);
      final File file = File(filePath);
      await file.writeAsString(jsonString);

      return ExportResult(
        success: true,
        filePath: filePath,
        fileSize: await file.length(),
        recordCount: _countRecords(data),
        format: ExportFormat.json,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        error: e.toString(),
        format: ExportFormat.json,
      );
    }
  }

  /// Экспорт данных в CSV формат
  Future<ExportResult> exportToCsv({
    required List<Map<String, dynamic>> data,
    required String fileName,
    String? outputPath,
    String delimiter = ',',
    bool includeHeaders = true,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      if (data.isEmpty) {
        return const ExportResult(
          success: false,
          error: 'No data to export',
          format: ExportFormat.csv,
        );
      }

      final List<String> headers = data.first.keys.toList();
      final List<String> csvLines = [];

      // Добавляем метаданные как комментарии
      if (metadata != null) {
        csvLines.add('# Export metadata:');
        metadata.forEach((key, value) {
          csvLines.add('# $key: $value');
        });
        csvLines.add('# Export date: ${DateTime.now().toIso8601String()}');
        csvLines.add('');
      }

      // Добавляем заголовки
      if (includeHeaders) {
        csvLines.add(headers.map((h) => _escapeCsvField(h)).join(delimiter));
      }

      // Добавляем данные
      for (final Map<String, dynamic> row in data) {
        final List<String> csvRow = headers.map((header) {
          final dynamic value = row[header];
          return _escapeCsvField(value?.toString() ?? '');
        }).toList();
        csvLines.add(csvRow.join(delimiter));
      }

      final String csvContent = csvLines.join('\n');
      final String filePath = _getOutputPath(fileName, 'csv', outputPath);
      final File file = File(filePath);
      await file.writeAsString(csvContent);

      return ExportResult(
        success: true,
        filePath: filePath,
        fileSize: await file.length(),
        recordCount: data.length,
        format: ExportFormat.csv,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        error: e.toString(),
        format: ExportFormat.csv,
      );
    }
  }

  /// Экспорт данных в XML формат
  Future<ExportResult> exportToXml({
    required Map<String, dynamic> data,
    required String fileName,
    String? outputPath,
    String rootElement = 'data',
    bool prettyPrint = true,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final StringBuffer xmlBuffer = StringBuffer();
      xmlBuffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');

      if (metadata != null) {
        xmlBuffer.writeln('<!-- Export metadata -->');
        metadata.forEach((key, value) {
          xmlBuffer.writeln('<!-- $key: $value -->');
        });
        xmlBuffer.writeln('<!-- Export date: ${DateTime.now().toIso8601String()} -->');
      }

      xmlBuffer.writeln('<$rootElement>');
      _buildXmlElement(xmlBuffer, data, prettyPrint ? 1 : 0);
      xmlBuffer.writeln('</$rootElement>');

      final String xmlContent = xmlBuffer.toString();
      final String filePath = _getOutputPath(fileName, 'xml', outputPath);
      final File file = File(filePath);
      await file.writeAsString(xmlContent);

      return ExportResult(
        success: true,
        filePath: filePath,
        fileSize: await file.length(),
        recordCount: _countRecords(data),
        format: ExportFormat.xml,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        error: e.toString(),
        format: ExportFormat.xml,
      );
    }
  }

  /// Массовый экспорт данных в нескольких форматах
  Future<List<ExportResult>> exportToMultipleFormats({
    required Map<String, dynamic> data,
    required String baseFileName,
    String? outputPath,
    List<ExportFormat> formats = const [ExportFormat.json, ExportFormat.csv, ExportFormat.xml],
    Map<String, dynamic>? metadata,
  }) async {
    final List<ExportResult> results = [];

    for (final ExportFormat format in formats) {
      ExportResult result;
      switch (format) {
        case ExportFormat.json:
          result = await exportToJson(
            data: data,
            fileName: baseFileName,
            outputPath: outputPath,
            metadata: metadata,
          );
        case ExportFormat.csv:
          // Для CSV конвертируем данные в список карт
          final List<Map<String, dynamic>> csvData = _convertToCsvFormat(data);
          result = await exportToCsv(
            data: csvData,
            fileName: baseFileName,
            outputPath: outputPath,
            metadata: metadata,
          );
        case ExportFormat.xml:
          result = await exportToXml(
            data: data,
            fileName: baseFileName,
            outputPath: outputPath,
            metadata: metadata,
          );
        case ExportFormat.unknown:
          result = ExportResult(
            success: false,
            error: 'Unknown export format',
            format: format,
          );
      }
      results.add(result);
    }

    return results;
  }

  /// Получение статистики экспорта
  Future<ExportStatistics> getExportStatistics(String filePath) async {
    try {
      final File file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist: $filePath');
      }

      final int fileSize = await file.length();
      final DateTime lastModified = await file.lastModified();
      final String extension = path.extension(filePath).toLowerCase();

      ExportFormat format;
      switch (extension) {
        case '.json':
          format = ExportFormat.json;
        case '.csv':
          format = ExportFormat.csv;
        case '.xml':
          format = ExportFormat.xml;
        default:
          format = ExportFormat.unknown;
      }

      return ExportStatistics(
        filePath: filePath,
        fileSize: fileSize,
        lastModified: lastModified,
        format: format,
        recordCount: await _estimateRecordCount(file, format),
      );
    } catch (e) {
      throw Exception('Failed to get export statistics: $e');
    }
  }

  /// Вспомогательные методы

  String _getOutputPath(String fileName, String extension, String? outputPath) {
    final String basePath = outputPath ?? Directory.current.path;
    final String fullFileName = fileName.endsWith('.$extension') ? fileName : '$fileName.$extension';
    return path.join(basePath, fullFileName);
  }

  String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  void _buildXmlElement(StringBuffer buffer, dynamic data, int indent) {
    final String indentStr = '  ' * indent;

    if (data is Map<String, dynamic>) {
      for (final MapEntry<String, dynamic> entry in data.entries) {
        final String key = _sanitizeXmlTag(entry.key);
        buffer.write('$indentStr<$key>');

        if (entry.value is Map || entry.value is List) {
          buffer.writeln();
          _buildXmlElement(buffer, entry.value, indent + 1);
          buffer.write(indentStr);
        } else {
          buffer.write(_escapeXmlValue(entry.value?.toString() ?? ''));
        }

        buffer.writeln('</$key>');
      }
    } else if (data is List) {
      for (int i = 0; i < data.length; i++) {
        final String itemTag = 'item_$i';
        buffer.write('$indentStr<$itemTag>');

        if (data[i] is Map || data[i] is List) {
          buffer.writeln();
          _buildXmlElement(buffer, data[i], indent + 1);
          buffer.write(indentStr);
        } else {
          buffer.write(_escapeXmlValue(data[i]?.toString() ?? ''));
        }

        buffer.writeln('</$itemTag>');
      }
    } else {
      buffer.write(_escapeXmlValue(data?.toString() ?? ''));
    }
  }

  String _sanitizeXmlTag(String tag) {
    return tag.replaceAll(RegExp('[^a-zA-Z0-9_-]'), '_');
  }

  String _escapeXmlValue(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  int _countRecords(dynamic data) {
    if (data is List) {
      return data.length;
    } else if (data is Map) {
      return data.length;
    }
    return 1;
  }

  List<Map<String, dynamic>> _convertToCsvFormat(Map<String, dynamic> data) {
    // Простая конвертация для демонстрации
    // В реальном приложении может потребоваться более сложная логика
    final List<Map<String, dynamic>> result = [];

    if (data.isNotEmpty) {
      final Map<String, dynamic> firstItem =
          data.values.first is Map ? data.values.first as Map<String, dynamic> : {'value': data.values.first};
      result.add(firstItem);
    }

    return result;
  }

  Future<int> _estimateRecordCount(File file, ExportFormat format) async {
    try {
      final String content = await file.readAsString();
      switch (format) {
        case ExportFormat.json:
          final Map<String, dynamic> jsonData = jsonDecode(content);
          return _countRecords(jsonData['data']);
        case ExportFormat.csv:
          return content.split('\n').where((line) => line.trim().isNotEmpty && !line.startsWith('#')).length - 1;
        case ExportFormat.xml:
          return content.split('<').length ~/ 2; // Примерная оценка
        default:
          return 0;
      }
    } catch (e) {
      return 0;
    }
  }
}

/// Форматы экспорта
enum ExportFormat {
  json,
  csv,
  xml,
  unknown,
}

/// Результат экспорта
class ExportResult extends Equatable {
  final bool success;
  final String? filePath;
  final int? fileSize;
  final int? recordCount;
  final ExportFormat format;
  final String? error;

  const ExportResult({
    required this.success,
    this.filePath,
    this.fileSize,
    this.recordCount,
    required this.format,
    this.error,
  });

  @override
  List<Object?> get props => [success, filePath, fileSize, recordCount, format, error];
}

/// Статистика экспорта
class ExportStatistics extends Equatable {
  final String filePath;
  final int fileSize;
  final DateTime lastModified;
  final ExportFormat format;
  final int recordCount;

  const ExportStatistics({
    required this.filePath,
    required this.fileSize,
    required this.lastModified,
    required this.format,
    required this.recordCount,
  });

  @override
  List<Object?> get props => [filePath, fileSize, lastModified, format, recordCount];
}
