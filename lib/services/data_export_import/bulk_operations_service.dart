import 'dart:async';

import 'package:equatable/equatable.dart';

import '../data_export/data_export_service.dart';
import '../data_import/data_import_service.dart';

/// Сервис для массовых операций с данными
class BulkOperationsService {
  static final BulkOperationsService _instance = BulkOperationsService._internal();

  factory BulkOperationsService() => _instance;

  BulkOperationsService._internal();

  final DataExportService _exportService = DataExportService();
  final DataImportService _importService = DataImportService();

  /// Массовый экспорт данных с фильтрацией и группировкой
  Future<BulkExportResult> bulkExport({
    required Map<String, dynamic> dataSource,
    required String baseFileName,
    String? outputPath,
    List<ExportFormat> formats = const [ExportFormat.json, ExportFormat.csv],
    Map<String, dynamic>? filters,
    List<String>? groupBy,
    int? batchSize,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final List<BulkExportItem> items = [];
      final Map<String, dynamic> processedData = _applyFilters(dataSource, filters);

      if (groupBy != null && groupBy.isNotEmpty) {
        // Группировка данных
        final Map<String, Map<String, dynamic>> groupedData = _groupData(processedData, groupBy);

        for (final MapEntry<String, Map<String, dynamic>> group in groupedData.entries) {
          final String groupFileName = '${baseFileName}_${_sanitizeFileName(group.key)}';
          final List<ExportResult> groupResults = await _exportService.exportToMultipleFormats(
            data: group.value,
            baseFileName: groupFileName,
            outputPath: outputPath,
            formats: formats,
            metadata: {
              ...?metadata,
              'group': group.key,
              'groupBy': groupBy,
            },
          );

          items.add(BulkExportItem(
            groupName: group.key,
            fileName: groupFileName,
            results: groupResults,
          ));
        }
      } else {
        // Обычный экспорт без группировки
        final List<ExportResult> results = await _exportService.exportToMultipleFormats(
          data: processedData,
          baseFileName: baseFileName,
          outputPath: outputPath,
          formats: formats,
          metadata: metadata,
        );

        items.add(BulkExportItem(
          groupName: 'all',
          fileName: baseFileName,
          results: results,
        ));
      }

      return BulkExportResult(
        success: true,
        items: items,
        totalRecords: _countTotalRecords(processedData),
        totalFiles: items.fold(0, (sum, item) => sum + item.results.length),
      );
    } catch (e) {
      return BulkExportResult(
        success: false,
        error: e.toString(),
        items: const [],
      );
    }
  }

  /// Массовый импорт данных с валидацией и обработкой ошибок
  Future<BulkImportResult> bulkImport({
    required List<String> filePaths,
    ImportFormat? format,
    Map<String, dynamic>? options,
    bool stopOnError = false,
    bool validateBeforeImport = true,
    Map<String, dynamic>? schema,
  }) async {
    try {
      final List<BulkImportItem> items = [];
      final List<String> errors = [];
      int totalRecords = 0;

      for (final String filePath in filePaths) {
        try {
          // Валидация файла перед импортом
          if (validateBeforeImport) {
            final ValidationResult validation = await _importService.validateFile(
              filePath: filePath,
              format: format,
              schema: schema,
            );

            if (!validation.isValid) {
              final String error = 'Validation failed for $filePath: ${validation.errors.join(', ')}';
              errors.add(error);
              if (stopOnError) {
                break;
              }
              continue;
            }
          }

          // Импорт файла
          final ImportResult importResult = await _importService.importFromMultipleFiles(
            filePaths: [filePath],
            format: format,
            options: options,
          ).then((results) => results.first);

          if (importResult.success) {
            totalRecords += importResult.recordCount ?? 0;
            items.add(BulkImportItem(
              filePath: filePath,
              success: true,
              recordCount: importResult.recordCount ?? 0,
              data: importResult.data,
              metadata: importResult.metadata,
            ));
          } else {
            final String error = 'Import failed for $filePath: ${importResult.error}';
            errors.add(error);
            if (stopOnError) {
              break;
            }
          }
        } catch (e) {
          final String error = 'Error processing $filePath: $e';
          errors.add(error);
          if (stopOnError) {
            break;
          }
        }
      }

      return BulkImportResult(
        success: errors.isEmpty,
        items: items,
        errors: errors,
        totalRecords: totalRecords,
        totalFiles: filePaths.length,
      );
    } catch (e) {
      return BulkImportResult(
        success: false,
        error: e.toString(),
        items: const [],
        errors: [e.toString()],
      );
    }
  }

  /// Синхронизация данных между источниками
  Future<DataSyncResult> syncData({
    required Map<String, dynamic> sourceData,
    required Map<String, dynamic> targetData,
    required String syncKey,
    SyncMode mode = SyncMode.merge,
    Map<String, dynamic>? conflictResolution,
  }) async {
    try {
      final Map<String, dynamic> syncResult = {};
      final List<String> conflicts = [];
      final List<String> operations = [];

      switch (mode) {
        case SyncMode.merge:
          syncResult.addAll(targetData);
          for (final MapEntry<String, dynamic> entry in sourceData.entries) {
            if (syncResult.containsKey(entry.key)) {
              final dynamic sourceValue = entry.value;
              final dynamic targetValue = syncResult[entry.key];

              if (_isEqual(sourceValue, targetValue)) {
                operations.add('No change for key: ${entry.key}');
              } else {
                conflicts.add('Conflict for key: ${entry.key}');
                if (conflictResolution?['strategy'] == 'source') {
                  syncResult[entry.key] = sourceValue;
                  operations.add('Updated key: ${entry.key} (source wins)');
                } else if (conflictResolution?['strategy'] == 'target') {
                  operations.add('Kept key: ${entry.key} (target wins)');
                } else {
                  // По умолчанию source wins
                  syncResult[entry.key] = sourceValue;
                  operations.add('Updated key: ${entry.key} (source wins)');
                }
              }
            } else {
              syncResult[entry.key] = entry.value;
              operations.add('Added key: ${entry.key}');
            }
          }

        case SyncMode.replace:
          syncResult.addAll(sourceData);
          operations.add('Replaced all data with source');

        case SyncMode.append:
          syncResult.addAll(targetData);
          for (final MapEntry<String, dynamic> entry in sourceData.entries) {
            if (!syncResult.containsKey(entry.key)) {
              syncResult[entry.key] = entry.value;
              operations.add('Added key: ${entry.key}');
            } else {
              conflicts.add('Key already exists: ${entry.key}');
            }
          }
      }

      return DataSyncResult(
        success: true,
        syncedData: syncResult,
        conflicts: conflicts,
        operations: operations,
        mode: mode,
      );
    } catch (e) {
      return DataSyncResult(
        success: false,
        error: e.toString(),
        syncedData: const {},
        conflicts: const [],
        operations: const [],
        mode: mode,
      );
    }
  }

  /// Миграция данных между форматами
  Future<DataMigrationResult> migrateData({
    required String sourceFilePath,
    required ImportFormat sourceFormat,
    required ExportFormat targetFormat,
    String? targetFilePath,
    Map<String, dynamic>? transformation,
    Map<String, dynamic>? options,
  }) async {
    try {
      // Импорт исходных данных
      final ImportResult importResult = await _importService.importFromMultipleFiles(
        filePaths: [sourceFilePath],
        format: sourceFormat,
        options: options,
      ).then((results) => results.first);

      if (!importResult.success) {
        return DataMigrationResult(
          success: false,
          error: 'Import failed: ${importResult.error}',
          sourceFormat: sourceFormat,
          targetFormat: targetFormat,
        );
      }

      // Применение трансформации
      Map<String, dynamic> transformedData = importResult.data ?? {};
      if (transformation != null) {
        transformedData = _applyTransformation(transformedData, transformation);
      }

      // Экспорт в целевой формат
      final String targetFileName = targetFilePath ?? sourceFilePath.replaceAll(RegExp(r'\.\w+$'), '');

      ExportResult exportResult;
      switch (targetFormat) {
        case ExportFormat.json:
          exportResult = await _exportService.exportToJson(
            data: transformedData,
            fileName: targetFileName,
            metadata: {
              'migratedFrom': sourceFormat.toString(),
              'migrationDate': DateTime.now().toIso8601String(),
            },
          );
        case ExportFormat.csv:
          final List<Map<String, dynamic>> csvData = _convertToCsvFormat(transformedData);
          exportResult = await _exportService.exportToCsv(
            data: csvData,
            fileName: targetFileName,
            metadata: {
              'migratedFrom': sourceFormat.toString(),
              'migrationDate': DateTime.now().toIso8601String(),
            },
          );
        case ExportFormat.xml:
          exportResult = await _exportService.exportToXml(
            data: transformedData,
            fileName: targetFileName,
            metadata: {
              'migratedFrom': sourceFormat.toString(),
              'migrationDate': DateTime.now().toIso8601String(),
            },
          );
        default:
          return DataMigrationResult(
            success: false,
            error: 'Unsupported target format: $targetFormat',
            sourceFormat: sourceFormat,
            targetFormat: targetFormat,
          );
      }

      return DataMigrationResult(
        success: exportResult.success,
        sourceFormat: sourceFormat,
        targetFormat: targetFormat,
        sourceFilePath: sourceFilePath,
        targetFilePath: exportResult.filePath,
        recordCount: exportResult.recordCount,
        error: exportResult.error,
      );
    } catch (e) {
      return DataMigrationResult(
        success: false,
        error: 'Migration failed: $e',
        sourceFormat: sourceFormat,
        targetFormat: targetFormat,
      );
    }
  }

  /// Вспомогательные методы

  Map<String, dynamic> _applyFilters(Map<String, dynamic> data, Map<String, dynamic>? filters) {
    if (filters == null || filters.isEmpty) {
      return data;
    }

    final Map<String, dynamic> filteredData = {};

    for (final MapEntry<String, dynamic> entry in data.entries) {
      bool include = true;

      for (final MapEntry<String, dynamic> filter in filters.entries) {
        if (entry.key == filter.key) {
          if (filter.value is Map && filter.value.containsKey('operator')) {
            final String operator = filter.value['operator'];
            final dynamic filterValue = filter.value['value'];

            switch (operator) {
              case 'equals':
                include = entry.value == filterValue;
              case 'contains':
                include = entry.value.toString().contains(filterValue.toString());
              case 'startsWith':
                include = entry.value.toString().startsWith(filterValue.toString());
              case 'endsWith':
                include = entry.value.toString().endsWith(filterValue.toString());
              case 'greaterThan':
                if (entry.value is num && filterValue is num) {
                  include = entry.value > filterValue;
                }
              case 'lessThan':
                if (entry.value is num && filterValue is num) {
                  include = entry.value < filterValue;
                }
            }
          } else {
            include = entry.value == filter.value;
          }

          if (!include) break;
        }
      }

      if (include) {
        filteredData[entry.key] = entry.value;
      }
    }

    return filteredData;
  }

  Map<String, Map<String, dynamic>> _groupData(Map<String, dynamic> data, List<String> groupBy) {
    final Map<String, Map<String, dynamic>> groupedData = {};

    for (final MapEntry<String, dynamic> entry in data.entries) {
      String groupKey = '';
      for (final String field in groupBy) {
        if (entry.value is Map && (entry.value as Map).containsKey(field)) {
          groupKey += '${(entry.value as Map)[field]}_';
        } else {
          groupKey += 'unknown_';
        }
      }
      groupKey = groupKey.replaceAll(RegExp(r'_$'), '');

      if (!groupedData.containsKey(groupKey)) {
        groupedData[groupKey] = {};
      }
      groupedData[groupKey]![entry.key] = entry.value;
    }

    return groupedData;
  }

  String _sanitizeFileName(String fileName) {
    return fileName.replaceAll(RegExp('[^a-zA-Z0-9_-]'), '_');
  }

  int _countTotalRecords(Map<String, dynamic> data) {
    int count = 0;
    for (final dynamic value in data.values) {
      if (value is List) {
        count += value.length;
      } else if (value is Map) {
        count += _countTotalRecords(value);
      } else {
        count += 1;
      }
    }
    return count;
  }

  bool _isEqual(dynamic a, dynamic b) {
    if (a == b) return true;
    if (a is Map && b is Map) {
      if (a.length != b.length) return false;
      for (final MapEntry entry in a.entries) {
        if (!b.containsKey(entry.key) || !_isEqual(entry.value, b[entry.key])) {
          return false;
        }
      }
      return true;
    }
    if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (int i = 0; i < a.length; i++) {
        if (!_isEqual(a[i], b[i])) return false;
      }
      return true;
    }
    return false;
  }

  Map<String, dynamic> _applyTransformation(Map<String, dynamic> data, Map<String, dynamic> transformation) {
    final Map<String, dynamic> transformedData = Map.from(data);

    for (final MapEntry<String, dynamic> rule in transformation.entries) {
      final String operation = rule.key;
      final dynamic config = rule.value;

      switch (operation) {
        case 'rename':
          if (config is Map) {
            for (final MapEntry<String, String> rename in config.entries) {
              if (transformedData.containsKey(rename.key)) {
                transformedData[rename.value] = transformedData.remove(rename.key);
              }
            }
          }
        case 'remove':
          if (config is List) {
            for (final String key in config) {
              transformedData.remove(key);
            }
          }
        case 'add':
          if (config is Map) {
            transformedData.addAll(config);
          }
        case 'transform':
          if (config is Map) {
            for (final MapEntry<String, dynamic> transform in config.entries) {
              if (transformedData.containsKey(transform.key)) {
                final String transformType = transform.value['type'] ?? 'string';
                final dynamic value = transformedData[transform.key];

                switch (transformType) {
                  case 'uppercase':
                    transformedData[transform.key] = value.toString().toUpperCase();
                  case 'lowercase':
                    transformedData[transform.key] = value.toString().toLowerCase();
                  case 'number':
                    transformedData[transform.key] = num.tryParse(value.toString());
                  case 'date':
                    transformedData[transform.key] = DateTime.tryParse(value.toString())?.toIso8601String();
                }
              }
            }
          }
      }
    }

    return transformedData;
  }

  List<Map<String, dynamic>> _convertToCsvFormat(Map<String, dynamic> data) {
    final List<Map<String, dynamic>> result = [];

    if (data.isNotEmpty) {
      final Map<String, dynamic> firstItem =
          data.values.first is Map ? data.values.first as Map<String, dynamic> : {'value': data.values.first};
      result.add(firstItem);
    }

    return result;
  }
}

/// Режимы синхронизации
enum SyncMode {
  merge,
  replace,
  append,
}

/// Результат массового экспорта
class BulkExportResult extends Equatable {
  final bool success;
  final List<BulkExportItem> items;
  final int? totalRecords;
  final int? totalFiles;
  final String? error;

  const BulkExportResult({
    required this.success,
    required this.items,
    this.totalRecords,
    this.totalFiles,
    this.error,
  });

  @override
  List<Object?> get props => [success, items, totalRecords, totalFiles, error];
}

/// Элемент массового экспорта
class BulkExportItem extends Equatable {
  final String groupName;
  final String fileName;
  final List<ExportResult> results;

  const BulkExportItem({
    required this.groupName,
    required this.fileName,
    required this.results,
  });

  @override
  List<Object?> get props => [groupName, fileName, results];
}

/// Результат массового импорта
class BulkImportResult extends Equatable {
  final bool success;
  final List<BulkImportItem> items;
  final List<String> errors;
  final int? totalRecords;
  final int? totalFiles;
  final String? error;

  const BulkImportResult({
    required this.success,
    required this.items,
    required this.errors,
    this.totalRecords,
    this.totalFiles,
    this.error,
  });

  @override
  List<Object?> get props => [success, items, errors, totalRecords, totalFiles, error];
}

/// Элемент массового импорта
class BulkImportItem extends Equatable {
  final String filePath;
  final bool success;
  final int recordCount;
  final Map<String, dynamic>? data;
  final Map<String, dynamic>? metadata;

  const BulkImportItem({
    required this.filePath,
    required this.success,
    required this.recordCount,
    this.data,
    this.metadata,
  });

  @override
  List<Object?> get props => [filePath, success, recordCount, data, metadata];
}

/// Результат синхронизации данных
class DataSyncResult extends Equatable {
  final bool success;
  final Map<String, dynamic> syncedData;
  final List<String> conflicts;
  final List<String> operations;
  final SyncMode mode;
  final String? error;

  const DataSyncResult({
    required this.success,
    required this.syncedData,
    required this.conflicts,
    required this.operations,
    required this.mode,
    this.error,
  });

  @override
  List<Object?> get props => [success, syncedData, conflicts, operations, mode, error];
}

/// Результат миграции данных
class DataMigrationResult extends Equatable {
  final bool success;
  final ImportFormat sourceFormat;
  final ExportFormat targetFormat;
  final String? sourceFilePath;
  final String? targetFilePath;
  final int? recordCount;
  final String? error;

  const DataMigrationResult({
    required this.success,
    required this.sourceFormat,
    required this.targetFormat,
    this.sourceFilePath,
    this.targetFilePath,
    this.recordCount,
    this.error,
  });

  @override
  List<Object?> get props => [success, sourceFormat, targetFormat, sourceFilePath, targetFilePath, recordCount, error];
}
