import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';

/// Менеджер переводов для управления файлами переводов
class TranslationManager {
  static final TranslationManager _instance = TranslationManager._internal();

  // Путь к директории с переводами
  static const String _translationsPath = 'assets/translations';

  // Кэш метаданных файлов
  final Map<String, TranslationFileMetadata> _fileMetadata = {};

  // Поток для уведомлений об изменениях в файлах
  final StreamController<TranslationFileChange> _fileChangeController = StreamController.broadcast();
  Stream<TranslationFileChange> get fileChangeStream => _fileChangeController.stream;

  factory TranslationManager() => _instance;
  TranslationManager._internal();

  /// Инициализация менеджера
  Future<void> initialize() async {
    await _scanTranslationFiles();
    _setupFileWatcher();
    print('TranslationManager initialized');
  }

  /// Сканирование файлов переводов
  Future<void> _scanTranslationFiles() async {
    try {
      final directory = Directory(_translationsPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
        print('Created translations directory: $_translationsPath');
        return;
      }

      final files = await directory.list().where((entity) => entity is File).cast<File>().toList();

      for (final file in files) {
        if (file.path.endsWith('.json')) {
          await _loadFileMetadata(file);
        }
      }

      print('Scanned ${files.length} translation files');
    } catch (e) {
      print('Error scanning translation files: $e');
    }
  }

  /// Загрузка метаданных файла
  Future<void> _loadFileMetadata(File file) async {
    try {
      final content = await file.readAsString();
      final jsonData = jsonDecode(content) as Map<String, dynamic>;

      final languageCode = _extractLanguageCode(file.path);
      final metadata = TranslationFileMetadata(
        languageCode: languageCode,
        filePath: file.path,
        lastModified: await file.lastModified(),
        size: await file.length(),
        keyCount: jsonData.length,
        checksum: content.hashCode.toString(),
      );

      _fileMetadata[languageCode] = metadata;
    } catch (e) {
      print('Error loading metadata for ${file.path}: $e');
    }
  }

  /// Извлечение кода языка из пути файла
  String _extractLanguageCode(String filePath) {
    final fileName = filePath.split('/').last;
    return fileName.replaceAll('.json', '');
  }

  /// Настройка наблюдателя за файлами
  void _setupFileWatcher() {
    try {
      final directory = Directory(_translationsPath);
      directory.watch(events: FileSystemEvent.all).listen((event) {
        if (event is FileSystemModifyEvent && event.path.endsWith('.json')) {
          _handleFileChange(event);
        }
      });
    } catch (e) {
      print('Error setting up file watcher: $e');
    }
  }

  /// Обработка изменения файла
  Future<void> _handleFileChange(FileSystemModifyEvent event) async {
    try {
      final file = File(event.path);
      final languageCode = _extractLanguageCode(event.path);

      await _loadFileMetadata(file);

      _fileChangeController.add(TranslationFileChange(
        languageCode: languageCode,
        filePath: event.path,
        changeType: FileChangeType.modified,
        timestamp: DateTime.now(),
      ));

      print('Translation file changed: $languageCode');
    } catch (e) {
      print('Error handling file change: $e');
    }
  }

  /// Создание нового файла перевода
  Future<void> createTranslationFile(String languageCode, Map<String, String> translations) async {
    try {
      final filePath = '$_translationsPath/$languageCode.json';
      final file = File(filePath);

      // Проверяем, существует ли файл
      if (await file.exists()) {
        throw ArgumentError('Translation file for $languageCode already exists');
      }

      // Создаем файл с переводами
      final jsonContent = jsonEncode(translations);
      await file.writeAsString(jsonContent);

      await _loadFileMetadata(file);

      _fileChangeController.add(TranslationFileChange(
        languageCode: languageCode,
        filePath: filePath,
        changeType: FileChangeType.created,
        timestamp: DateTime.now(),
      ));

      print('Created translation file: $languageCode');
    } catch (e) {
      print('Error creating translation file: $e');
      rethrow;
    }
  }

  /// Обновление файла перевода
  Future<void> updateTranslationFile(String languageCode, Map<String, String> translations) async {
    try {
      final filePath = '$_translationsPath/$languageCode.json';
      final file = File(filePath);

      // Создаем резервную копию
      if (await file.exists()) {
        final backupPath = '$filePath.backup';
        await file.copy(backupPath);
      }

      // Записываем новые переводы
      final jsonContent = jsonEncode(translations);
      await file.writeAsString(jsonContent);

      await _loadFileMetadata(file);

      _fileChangeController.add(TranslationFileChange(
        languageCode: languageCode,
        filePath: filePath,
        changeType: FileChangeType.modified,
        timestamp: DateTime.now(),
      ));

      print('Updated translation file: $languageCode');
    } catch (e) {
      print('Error updating translation file: $e');
      rethrow;
    }
  }

  /// Удаление файла перевода
  Future<void> deleteTranslationFile(String languageCode) async {
    try {
      final filePath = '$_translationsPath/$languageCode.json';
      final file = File(filePath);

      if (await file.exists()) {
        await file.delete();
        _fileMetadata.remove(languageCode);

        _fileChangeController.add(TranslationFileChange(
          languageCode: languageCode,
          filePath: filePath,
          changeType: FileChangeType.deleted,
          timestamp: DateTime.now(),
        ));

        print('Deleted translation file: $languageCode');
      }
    } catch (e) {
      print('Error deleting translation file: $e');
      rethrow;
    }
  }

  /// Получение метаданных файла
  TranslationFileMetadata? getFileMetadata(String languageCode) {
    return _fileMetadata[languageCode];
  }

  /// Получение всех метаданных файлов
  List<TranslationFileMetadata> getAllFileMetadata() {
    return _fileMetadata.values.toList();
  }

  /// Валидация файла перевода
  Future<TranslationValidationResult> validateTranslationFile(String languageCode) async {
    try {
      final filePath = '$_translationsPath/$languageCode.json';
      final file = File(filePath);

      if (!await file.exists()) {
        return TranslationValidationResult(
          languageCode: languageCode,
          isValid: false,
          errors: const ['Translation file does not exist'],
          warnings: const [],
        );
      }

      final content = await file.readAsString();
      final Map<String, dynamic> jsonData;

      try {
        jsonData = jsonDecode(content);
      } catch (e) {
        return TranslationValidationResult(
          languageCode: languageCode,
          isValid: false,
          errors: ['Invalid JSON format: $e'],
          warnings: const [],
        );
      }

      final errors = <String>[];
      final warnings = <String>[];

      // Проверяем, что все значения являются строками
      jsonData.forEach((key, value) {
        if (value is! String) {
          errors.add('Key "$key" has non-string value: ${value.runtimeType}');
        } else if (value.isEmpty) {
          warnings.add('Key "$key" has empty translation');
        }
      });

      // Проверяем наличие базовых ключей (если есть английский файл)
      if (languageCode != 'en') {
        final baseFile = File('$_translationsPath/en.json');
        if (await baseFile.exists()) {
          final baseContent = await baseFile.readAsString();
          final baseData = jsonDecode(baseContent) as Map<String, dynamic>;

          for (final key in baseData.keys) {
            if (!jsonData.containsKey(key)) {
              warnings.add('Missing translation for key: $key');
            }
          }
        }
      }

      return TranslationValidationResult(
        languageCode: languageCode,
        isValid: errors.isEmpty,
        errors: errors,
        warnings: warnings,
      );
    } catch (e) {
      return TranslationValidationResult(
        languageCode: languageCode,
        isValid: false,
        errors: ['Validation error: $e'],
        warnings: const [],
      );
    }
  }

  /// Валидация всех файлов переводов
  Future<List<TranslationValidationResult>> validateAllTranslationFiles() async {
    final results = <TranslationValidationResult>[];

    for (final languageCode in _fileMetadata.keys) {
      final result = await validateTranslationFile(languageCode);
      results.add(result);
    }

    return results;
  }

  /// Синхронизация переводов с базовым языком
  Future<void> synchronizeWithBaseLanguage(String baseLanguageCode) async {
    try {
      final baseFile = File('$_translationsPath/$baseLanguageCode.json');
      if (!await baseFile.exists()) {
        throw ArgumentError('Base language file not found: $baseLanguageCode');
      }

      final baseContent = await baseFile.readAsString();
      final baseData = jsonDecode(baseContent) as Map<String, dynamic>;

      // Обновляем все остальные языки
      for (final entry in _fileMetadata.entries) {
        final languageCode = entry.key;
        if (languageCode == baseLanguageCode) continue;

        final file = File('$_translationsPath/$languageCode.json');
        Map<String, dynamic> existingData = {};

        if (await file.exists()) {
          final content = await file.readAsString();
          existingData = jsonDecode(content) as Map<String, dynamic>;
        }

        // Добавляем недостающие ключи
        final updatedData = <String, String>{};
        baseData.forEach((key, value) {
          updatedData[key] = existingData[key] ?? value.toString();
        });

        await updateTranslationFile(languageCode, updatedData);
      }

      print('Synchronized all translation files with base language: $baseLanguageCode');
    } catch (e) {
      print('Error synchronizing translation files: $e');
      rethrow;
    }
  }

  /// Экспорт переводов в различные форматы
  Future<void> exportTranslations(String languageCode, TranslationExportFormat format, String outputPath) async {
    try {
      final file = File('$_translationsPath/$languageCode.json');
      if (!await file.exists()) {
        throw ArgumentError('Translation file not found: $languageCode');
      }

      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      String exportContent;
      String extension;

      switch (format) {
        case TranslationExportFormat.json:
          exportContent = jsonEncode(data);
          extension = 'json';
        case TranslationExportFormat.csv:
          exportContent = _convertToCSV(data);
          extension = 'csv';
        case TranslationExportFormat.xlsx:
          // Для Excel нужна дополнительная библиотека
          throw UnimplementedError('Excel export not implemented');
        case TranslationExportFormat.properties:
          exportContent = _convertToProperties(data);
          extension = 'properties';
      }

      final outputFile = File('$outputPath/$languageCode.$extension');
      await outputFile.writeAsString(exportContent);

      print('Exported translations for $languageCode to $outputPath');
    } catch (e) {
      print('Error exporting translations: $e');
      rethrow;
    }
  }

  /// Импорт переводов из различных форматов
  Future<void> importTranslations(String languageCode, TranslationExportFormat format, String inputPath) async {
    try {
      final file = File(inputPath);
      if (!await file.exists()) {
        throw ArgumentError('Import file not found: $inputPath');
      }

      final content = await file.readAsString();
      Map<String, String> translations;

      switch (format) {
        case TranslationExportFormat.json:
          final data = jsonDecode(content) as Map<String, dynamic>;
          translations = data.map((key, value) => MapEntry(key, value.toString()));
        case TranslationExportFormat.csv:
          translations = _parseFromCSV(content);
        case TranslationExportFormat.xlsx:
          throw UnimplementedError('Excel import not implemented');
        case TranslationExportFormat.properties:
          translations = _parseFromProperties(content);
      }

      await updateTranslationFile(languageCode, translations);
      print('Imported translations for $languageCode from $inputPath');
    } catch (e) {
      print('Error importing translations: $e');
      rethrow;
    }
  }

  /// Конвертация в CSV
  String _convertToCSV(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    buffer.writeln('Key,Translation');

    data.forEach((key, value) {
      buffer.writeln('"$key","$value"');
    });

    return buffer.toString();
  }

  /// Парсинг из CSV
  Map<String, String> _parseFromCSV(String content) {
    final lines = content.split('\n');
    final translations = <String, String>{};

    // Пропускаем заголовок
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final parts = line.split(',');
      if (parts.length >= 2) {
        final key = parts[0].replaceAll('"', '');
        final translation = parts[1].replaceAll('"', '');
        translations[key] = translation;
      }
    }

    return translations;
  }

  /// Конвертация в Properties
  String _convertToProperties(Map<String, dynamic> data) {
    final buffer = StringBuffer();

    data.forEach((key, value) {
      buffer.writeln('$key=$value');
    });

    return buffer.toString();
  }

  /// Парсинг из Properties
  Map<String, String> _parseFromProperties(String content) {
    final lines = content.split('\n');
    final translations = <String, String>{};

    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty || trimmedLine.startsWith('#')) continue;

      final equalIndex = trimmedLine.indexOf('=');
      if (equalIndex > 0) {
        final key = trimmedLine.substring(0, equalIndex);
        final value = trimmedLine.substring(equalIndex + 1);
        translations[key] = value;
      }
    }

    return translations;
  }

  /// Освобождение ресурсов
  Future<void> dispose() async {
    await _fileChangeController.close();
    _fileMetadata.clear();
  }
}

/// Метаданные файла перевода
class TranslationFileMetadata extends Equatable {
  final String languageCode;
  final String filePath;
  final DateTime lastModified;
  final int size;
  final int keyCount;
  final String checksum;

  const TranslationFileMetadata({
    required this.languageCode,
    required this.filePath,
    required this.lastModified,
    required this.size,
    required this.keyCount,
    required this.checksum,
  });

  @override
  List<Object?> get props => [languageCode, filePath, lastModified, size, keyCount, checksum];
}

/// Изменение файла перевода
class TranslationFileChange extends Equatable {
  final String languageCode;
  final String filePath;
  final FileChangeType changeType;
  final DateTime timestamp;

  const TranslationFileChange({
    required this.languageCode,
    required this.filePath,
    required this.changeType,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [languageCode, filePath, changeType, timestamp];
}

/// Тип изменения файла
enum FileChangeType { created, modified, deleted }

/// Результат валидации перевода
class TranslationValidationResult extends Equatable {
  final String languageCode;
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const TranslationValidationResult({
    required this.languageCode,
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  @override
  List<Object?> get props => [languageCode, isValid, errors, warnings];
}

/// Формат экспорта/импорта
enum TranslationExportFormat { json, csv, xlsx, properties }
