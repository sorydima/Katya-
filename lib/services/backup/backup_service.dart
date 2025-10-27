import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:path/path.dart' as path;

/// Сервис для резервного копирования данных
class BackupService {
  static final BackupService _instance = BackupService._internal();

  factory BackupService() => _instance;

  BackupService._internal();

  final Map<String, BackupTask> _activeTasks = {};
  final List<BackupTask> _completedTasks = [];
  final StreamController<BackupEvent> _eventController = StreamController<BackupEvent>.broadcast();

  /// Поток событий резервного копирования
  Stream<BackupEvent> get events => _eventController.stream;

  /// Создание полного резервного копирования
  Future<BackupResult> createFullBackup({
    required String backupName,
    String? description,
    List<String>? includePaths,
    List<String>? excludePaths,
    bool compress = true,
    bool encrypt = false,
    String? encryptionKey,
    BackupStorageType storageType = BackupStorageType.local,
    Map<String, dynamic>? storageConfig,
  }) async {
    final String taskId = _generateTaskId();
    final BackupTask task = BackupTask(
      id: taskId,
      name: backupName,
      description: description,
      type: BackupType.full,
      status: BackupStatus.running,
      createdAt: DateTime.now(),
      includePaths: includePaths ?? _getDefaultIncludePaths(),
      excludePaths: excludePaths ?? _getDefaultExcludePaths(),
      compress: compress,
      encrypt: encrypt,
      encryptionKey: encryptionKey,
      storageType: storageType,
      storageConfig: storageConfig,
    );

    _activeTasks[taskId] = task;
    _emitEvent(BackupEvent.started(task));

    try {
      // Создание временной директории для резервной копии
      final Directory tempDir = await _createTempDirectory(taskId);

      // Копирование файлов
      await _copyFiles(task, tempDir);

      // Создание метаданных
      await _createBackupMetadata(task, tempDir);

      // Сжатие архива
      String? archivePath;
      if (compress) {
        archivePath = await _compressBackup(task, tempDir);
      }

      // Шифрование
      if (encrypt && encryptionKey != null) {
        archivePath = await _encryptBackup(task, archivePath ?? tempDir.path, encryptionKey);
      }

      // Загрузка в хранилище
      final String finalPath = await _uploadToStorage(task, archivePath ?? tempDir.path, storageType, storageConfig);

      // Очистка временных файлов
      await _cleanupTempFiles(tempDir);

      final BackupResult result = BackupResult(
        success: true,
        taskId: taskId,
        backupPath: finalPath,
        size: await _calculateBackupSize(finalPath),
        createdAt: DateTime.now(),
        metadata: await _getBackupMetadata(finalPath),
      );

      _completeTask(task, result);
      return result;
    } catch (e) {
      final BackupResult result = BackupResult(
        success: false,
        taskId: taskId,
        error: e.toString(),
        createdAt: DateTime.now(),
      );

      _completeTask(task, result);
      return result;
    }
  }

  /// Создание инкрементального резервного копирования
  Future<BackupResult> createIncrementalBackup({
    required String backupName,
    required String baseBackupId,
    String? description,
    List<String>? includePaths,
    List<String>? excludePaths,
    bool compress = true,
    bool encrypt = false,
    String? encryptionKey,
    BackupStorageType storageType = BackupStorageType.local,
    Map<String, dynamic>? storageConfig,
  }) async {
    final String taskId = _generateTaskId();
    final BackupTask baseTask = _completedTasks.firstWhere(
      (task) => task.id == baseBackupId,
      orElse: () => throw Exception('Base backup not found: $baseBackupId'),
    );

    final BackupTask task = BackupTask(
      id: taskId,
      name: backupName,
      description: description,
      type: BackupType.incremental,
      status: BackupStatus.running,
      createdAt: DateTime.now(),
      baseBackupId: baseBackupId,
      includePaths: includePaths ?? baseTask.includePaths,
      excludePaths: excludePaths ?? baseTask.excludePaths,
      compress: compress,
      encrypt: encrypt,
      encryptionKey: encryptionKey,
      storageType: storageType,
      storageConfig: storageConfig,
    );

    _activeTasks[taskId] = task;
    _emitEvent(BackupEvent.started(task));

    try {
      // Создание временной директории
      final Directory tempDir = await _createTempDirectory(taskId);

      // Определение измененных файлов
      final List<String> changedFiles = await _findChangedFiles(baseTask, task);

      // Копирование только измененных файлов
      await _copyChangedFiles(task, changedFiles, tempDir);

      // Создание метаданных
      await _createBackupMetadata(task, tempDir);

      // Сжатие и шифрование
      String? archivePath;
      if (compress) {
        archivePath = await _compressBackup(task, tempDir);
      }

      if (encrypt && encryptionKey != null) {
        archivePath = await _encryptBackup(task, archivePath ?? tempDir.path, encryptionKey);
      }

      // Загрузка в хранилище
      final String finalPath = await _uploadToStorage(task, archivePath ?? tempDir.path, storageType, storageConfig);

      // Очистка
      await _cleanupTempFiles(tempDir);

      final BackupResult result = BackupResult(
        success: true,
        taskId: taskId,
        backupPath: finalPath,
        size: await _calculateBackupSize(finalPath),
        createdAt: DateTime.now(),
        metadata: await _getBackupMetadata(finalPath),
        changedFilesCount: changedFiles.length,
      );

      _completeTask(task, result);
      return result;
    } catch (e) {
      final BackupResult result = BackupResult(
        success: false,
        taskId: taskId,
        error: e.toString(),
        createdAt: DateTime.now(),
      );

      _completeTask(task, result);
      return result;
    }
  }

  /// Восстановление из резервной копии
  Future<RestoreResult> restoreFromBackup({
    required String backupPath,
    String? targetPath,
    bool verifyIntegrity = true,
    bool overwriteExisting = false,
    List<String>? includeFiles,
    List<String>? excludeFiles,
  }) async {
    final String taskId = _generateTaskId();
    final RestoreTask task = RestoreTask(
      id: taskId,
      backupPath: backupPath,
      targetPath: targetPath ?? Directory.current.path,
      status: RestoreStatus.running,
      createdAt: DateTime.now(),
      verifyIntegrity: verifyIntegrity,
      overwriteExisting: overwriteExisting,
      includeFiles: includeFiles,
      excludeFiles: excludeFiles,
    );

    _emitEvent(BackupEvent.restoreStarted(task));

    try {
      // Проверка целостности
      if (verifyIntegrity) {
        await _verifyBackupIntegrity(backupPath);
      }

      // Расшифровка (если необходимо)
      String workingPath = await _decryptBackupIfNeeded(backupPath);

      // Распаковка (если необходимо)
      workingPath = await _extractBackupIfNeeded(workingPath);

      // Восстановление файлов
      await _restoreFiles(task, workingPath);

      // Очистка временных файлов
      if (workingPath != backupPath) {
        await Directory(workingPath).delete(recursive: true);
      }

      final RestoreResult result = RestoreResult(
        success: true,
        taskId: taskId,
        restoredFilesCount: await _countRestoredFiles(task.targetPath),
        createdAt: DateTime.now(),
      );

      _emitEvent(BackupEvent.restoreCompleted(task, result));
      return result;
    } catch (e) {
      final RestoreResult result = RestoreResult(
        success: false,
        taskId: taskId,
        error: e.toString(),
        createdAt: DateTime.now(),
      );

      _emitEvent(BackupEvent.restoreFailed(task, result));
      return result;
    }
  }

  /// Получение списка доступных резервных копий
  Future<List<BackupInfo>> listBackups({
    BackupStorageType? storageType,
    String? storagePath,
  }) async {
    try {
      final List<BackupInfo> backups = [];

      if (storageType == null || storageType == BackupStorageType.local) {
        final String backupDir = storagePath ?? _getDefaultBackupDirectory();
        final Directory dir = Directory(backupDir);

        if (await dir.exists()) {
          await for (final FileSystemEntity entity in dir.list()) {
            if (entity is File && _isBackupFile(entity.path)) {
              final BackupInfo info = await _getBackupInfo(entity.path);
              backups.add(info);
            }
          }
        }
      }

      // Сортировка по дате создания (новые сначала)
      backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return backups;
    } catch (e) {
      throw Exception('Failed to list backups: $e');
    }
  }

  /// Удаление резервной копии
  Future<bool> deleteBackup(String backupPath) async {
    try {
      final File backupFile = File(backupPath);
      if (await backupFile.exists()) {
        await backupFile.delete();
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to delete backup: $e');
    }
  }

  /// Получение статистики резервного копирования
  Future<BackupStatistics> getBackupStatistics() async {
    final List<BackupInfo> backups = await listBackups();

    int totalSize = 0;
    int fullBackups = 0;
    int incrementalBackups = 0;
    DateTime? lastBackup;

    for (final BackupInfo backup in backups) {
      totalSize += backup.size;
      if (backup.type == BackupType.full) {
        fullBackups++;
      } else {
        incrementalBackups++;
      }

      if (lastBackup == null || backup.createdAt.isAfter(lastBackup)) {
        lastBackup = backup.createdAt;
      }
    }

    return BackupStatistics(
      totalBackups: backups.length,
      totalSize: totalSize,
      fullBackups: fullBackups,
      incrementalBackups: incrementalBackups,
      lastBackup: lastBackup,
      averageSize: backups.isNotEmpty ? totalSize / backups.length : 0,
    );
  }

  /// Вспомогательные методы

  String _generateTaskId() {
    return 'backup_${DateTime.now().millisecondsSinceEpoch}_${_activeTasks.length}';
  }

  List<String> _getDefaultIncludePaths() {
    return [
      'lib/',
      'assets/',
      'config/',
      'pubspec.yaml',
      'pubspec.lock',
    ];
  }

  List<String> _getDefaultExcludePaths() {
    return [
      'build/',
      '.dart_tool/',
      'node_modules/',
      '.git/',
      '*.log',
      '*.tmp',
    ];
  }

  String _getDefaultBackupDirectory() {
    return path.join(Directory.current.path, 'backups');
  }

  Future<Directory> _createTempDirectory(String taskId) async {
    final String tempPath = path.join(Directory.systemTemp.path, 'katya_backup_$taskId');
    final Directory tempDir = Directory(tempPath);
    await tempDir.create(recursive: true);
    return tempDir;
  }

  Future<void> _copyFiles(BackupTask task, Directory tempDir) async {
    for (final String includePath in task.includePaths) {
      final String sourcePath =
          path.isAbsolute(includePath) ? includePath : path.join(Directory.current.path, includePath);

      final FileSystemEntityType sourceType = FileSystemEntity.typeSync(sourcePath);

      if (sourceType == FileSystemEntityType.file) {
        await _copyFile(File(sourcePath), tempDir);
      } else if (sourceType == FileSystemEntityType.directory) {
        await _copyDirectory(Directory(sourcePath), tempDir);
      }
    }
  }

  Future<void> _copyFile(File sourceFile, Directory targetDir) async {
    final String relativePath = path.relative(sourceFile.path, from: Directory.current.path);
    final File targetFile = File(path.join(targetDir.path, relativePath));

    await targetFile.parent.create(recursive: true);
    await sourceFile.copy(targetFile.path);
  }

  Future<void> _copyDirectory(Directory sourceDir, Directory targetDir) async {
    final String relativePath = path.relative(sourceDir.path, from: Directory.current.path);
    final Directory targetDirPath = Directory(path.join(targetDir.path, relativePath));

    await targetDirPath.create(recursive: true);

    await for (final FileSystemEntity entity in sourceDir.list(recursive: true)) {
      if (entity is File && !_shouldExcludeFile(entity.path)) {
        final String relativeEntityPath = path.relative(entity.path, from: sourceDir.path);
        final File targetFile = File(path.join(targetDirPath.path, relativeEntityPath));

        await targetFile.parent.create(recursive: true);
        await entity.copy(targetFile.path);
      }
    }
  }

  bool _shouldExcludeFile(String filePath) {
    final List<String> excludePatterns = [
      'build/',
      '.dart_tool/',
      'node_modules/',
      '.git/',
      '.DS_Store',
      'Thumbs.db',
    ];

    for (final String pattern in excludePatterns) {
      if (filePath.contains(pattern)) {
        return true;
      }
    }

    return false;
  }

  Future<void> _createBackupMetadata(BackupTask task, Directory tempDir) async {
    final Map<String, dynamic> metadata = {
      'id': task.id,
      'name': task.name,
      'description': task.description,
      'type': task.type.toString(),
      'createdAt': task.createdAt.toIso8601String(),
      'baseBackupId': task.baseBackupId,
      'includePaths': task.includePaths,
      'excludePaths': task.excludePaths,
      'compress': task.compress,
      'encrypt': task.encrypt,
      'storageType': task.storageType.toString(),
      'version': '1.0',
    };

    final File metadataFile = File(path.join(tempDir.path, 'backup_metadata.json'));
    await metadataFile.writeAsString(jsonEncode(metadata));
  }

  Future<String> _compressBackup(BackupTask task, Directory tempDir) async {
    // Здесь должна быть реализация сжатия (например, с использованием tar/zip)
    // Для демонстрации просто копируем директорию
    final String archivePath = '${tempDir.path}.tar.gz';
    // TODO: Implement actual compression
    return archivePath;
  }

  Future<String> _encryptBackup(BackupTask task, String sourcePath, String encryptionKey) async {
    // Здесь должна быть реализация шифрования
    // Для демонстрации просто возвращаем исходный путь
    // TODO: Implement actual encryption
    return sourcePath;
  }

  Future<String> _uploadToStorage(
    BackupTask task,
    String sourcePath,
    BackupStorageType storageType,
    Map<String, dynamic>? storageConfig,
  ) async {
    switch (storageType) {
      case BackupStorageType.local:
        final String backupDir = _getDefaultBackupDirectory();
        await Directory(backupDir).create(recursive: true);

        final String fileName = '${task.name}_${task.createdAt.millisecondsSinceEpoch}';
        final String targetPath = path.join(backupDir, fileName);

        if (FileSystemEntity.typeSync(sourcePath) == FileSystemEntityType.file) {
          await File(sourcePath).copy(targetPath);
        } else {
          // Копирование директории
          await _copyDirectory(Directory(sourcePath), Directory(targetPath));
        }

        return targetPath;

      case BackupStorageType.cloud:
        // TODO: Implement cloud storage upload
        throw UnimplementedError('Cloud storage not implemented yet');

      case BackupStorageType.remote:
        // TODO: Implement remote storage upload
        throw UnimplementedError('Remote storage not implemented yet');
    }
  }

  Future<void> _cleanupTempFiles(Directory tempDir) async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  }

  Future<int> _calculateBackupSize(String backupPath) async {
    final FileSystemEntityType entityType = FileSystemEntity.typeSync(backupPath);
    if (entityType == FileSystemEntityType.file) {
      return await File(backupPath).length();
    } else if (entityType == FileSystemEntityType.directory) {
      int totalSize = 0;
      await for (final FileSystemEntity file in Directory(backupPath).list(recursive: true)) {
        if (file is File) {
          totalSize += await file.length();
        }
      }
      return totalSize;
    }
    return 0;
  }

  Future<Map<String, dynamic>?> _getBackupMetadata(String backupPath) async {
    try {
      final String metadataPath = path.join(backupPath, 'backup_metadata.json');
      final File metadataFile = File(metadataPath);

      if (await metadataFile.exists()) {
        final String content = await metadataFile.readAsString();
        return jsonDecode(content) as Map<String, dynamic>;
      }
    } catch (e) {
      // Игнорируем ошибки чтения метаданных
    }
    return null;
  }

  Future<List<String>> _findChangedFiles(BackupTask baseTask, BackupTask currentTask) async {
    // Простая реализация поиска измененных файлов
    // В реальном приложении здесь должна быть более сложная логика
    final List<String> changedFiles = [];

    for (final String includePath in currentTask.includePaths) {
      final String sourcePath =
          path.isAbsolute(includePath) ? includePath : path.join(Directory.current.path, includePath);

      final FileSystemEntityType sourceType = FileSystemEntity.typeSync(sourcePath);
      if (sourceType == FileSystemEntityType.file) {
        changedFiles.add(sourcePath);
      } else if (sourceType == FileSystemEntityType.directory) {
        await for (final FileSystemEntity entity in Directory(sourcePath).list(recursive: true)) {
          if (entity is File && !_shouldExcludeFile(entity.path)) {
            changedFiles.add(entity.path);
          }
        }
      }
    }

    return changedFiles;
  }

  Future<void> _copyChangedFiles(BackupTask task, List<String> changedFiles, Directory tempDir) async {
    for (final String filePath in changedFiles) {
      final File sourceFile = File(filePath);
      if (await sourceFile.exists()) {
        await _copyFile(sourceFile, tempDir);
      }
    }
  }

  Future<void> _verifyBackupIntegrity(String backupPath) async {
    // Проверка целостности резервной копии
    // TODO: Implement integrity verification
  }

  Future<String> _decryptBackupIfNeeded(String backupPath) async {
    // Расшифровка резервной копии если необходимо
    // TODO: Implement decryption
    return backupPath;
  }

  Future<String> _extractBackupIfNeeded(String backupPath) async {
    // Распаковка резервной копии если необходимо
    // TODO: Implement extraction
    return backupPath;
  }

  Future<void> _restoreFiles(RestoreTask task, String sourcePath) async {
    final FileSystemEntityType sourceType = FileSystemEntity.typeSync(sourcePath);

    if (sourceType == FileSystemEntityType.file) {
      // Восстановление из архива
      // TODO: Implement archive extraction
    } else if (sourceType == FileSystemEntityType.directory) {
      // Копирование файлов
      await _copyDirectory(Directory(sourcePath), Directory(task.targetPath));
    }
  }

  Future<int> _countRestoredFiles(String targetPath) async {
    int count = 0;
    await for (final FileSystemEntity entity in Directory(targetPath).list(recursive: true)) {
      if (entity is File) {
        count++;
      }
    }
    return count;
  }

  bool _isBackupFile(String filePath) {
    return filePath.endsWith('.tar.gz') || filePath.endsWith('.zip') || filePath.endsWith('.backup');
  }

  Future<BackupInfo?> _getBackupInfo(String backupPath) async {
    try {
      final Map<String, dynamic>? metadata = await _getBackupMetadata(backupPath);
      final int size = await _calculateBackupSize(backupPath);

      if (metadata != null) {
        return BackupInfo(
          id: metadata['id'] as String? ?? '',
          name: metadata['name'] as String? ?? '',
          description: metadata['description'] as String?,
          type: BackupType.values.firstWhere(
            (type) => type.toString() == metadata['type'] as String?,
            orElse: () => BackupType.full,
          ),
          path: backupPath,
          size: size,
          createdAt: DateTime.parse(metadata['createdAt'] as String),
          metadata: metadata,
        );
      }
    } catch (e) {
      // Игнорируем ошибки
    }
    return null;
  }

  void _completeTask(BackupTask task, BackupResult result) {
    final BackupTask completedTask = BackupTask(
      id: task.id,
      name: task.name,
      description: task.description,
      type: task.type,
      status: result.success ? BackupStatus.completed : BackupStatus.failed,
      createdAt: task.createdAt,
      completedAt: DateTime.now(),
      baseBackupId: task.baseBackupId,
      includePaths: task.includePaths,
      excludePaths: task.excludePaths,
      compress: task.compress,
      encrypt: task.encrypt,
      encryptionKey: task.encryptionKey,
      storageType: task.storageType,
      storageConfig: task.storageConfig,
      result: result,
    );

    _activeTasks.remove(task.id);
    _completedTasks.add(completedTask);

    _emitEvent(BackupEvent.completed(completedTask, result));
  }

  void _emitEvent(BackupEvent event) {
    _eventController.add(event);
  }

  void dispose() {
    _eventController.close();
  }
}

/// Типы резервного копирования
enum BackupType {
  full,
  incremental,
}

/// Статусы резервного копирования
enum BackupStatus {
  pending,
  running,
  completed,
  failed,
  cancelled,
}

/// Типы хранилища
enum BackupStorageType {
  local,
  cloud,
  remote,
}

/// Статусы восстановления
enum RestoreStatus {
  pending,
  running,
  completed,
  failed,
  cancelled,
}

/// Задача резервного копирования
class BackupTask extends Equatable {
  final String id;
  final String name;
  final String? description;
  final BackupType type;
  final BackupStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? baseBackupId;
  final List<String> includePaths;
  final List<String> excludePaths;
  final bool compress;
  final bool encrypt;
  final String? encryptionKey;
  final BackupStorageType storageType;
  final Map<String, dynamic>? storageConfig;
  final BackupResult? result;

  const BackupTask({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.baseBackupId,
    required this.includePaths,
    required this.excludePaths,
    required this.compress,
    required this.encrypt,
    this.encryptionKey,
    required this.storageType,
    this.storageConfig,
    this.result,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        status,
        createdAt,
        completedAt,
        baseBackupId,
        includePaths,
        excludePaths,
        compress,
        encrypt,
        encryptionKey,
        storageType,
        storageConfig,
        result,
      ];
}

/// Задача восстановления
class RestoreTask extends Equatable {
  final String id;
  final String backupPath;
  final String targetPath;
  final RestoreStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool verifyIntegrity;
  final bool overwriteExisting;
  final List<String>? includeFiles;
  final List<String>? excludeFiles;
  final RestoreResult? result;

  const RestoreTask({
    required this.id,
    required this.backupPath,
    required this.targetPath,
    required this.status,
    required this.createdAt,
    this.completedAt,
    required this.verifyIntegrity,
    required this.overwriteExisting,
    this.includeFiles,
    this.excludeFiles,
    this.result,
  });

  @override
  List<Object?> get props => [
        id,
        backupPath,
        targetPath,
        status,
        createdAt,
        completedAt,
        verifyIntegrity,
        overwriteExisting,
        includeFiles,
        excludeFiles,
        result,
      ];
}

/// Результат резервного копирования
class BackupResult extends Equatable {
  final bool success;
  final String taskId;
  final String? backupPath;
  final int? size;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;
  final int? changedFilesCount;
  final String? error;

  const BackupResult({
    required this.success,
    required this.taskId,
    this.backupPath,
    this.size,
    required this.createdAt,
    this.metadata,
    this.changedFilesCount,
    this.error,
  });

  @override
  List<Object?> get props => [
        success,
        taskId,
        backupPath,
        size,
        createdAt,
        metadata,
        changedFilesCount,
        error,
      ];
}

/// Результат восстановления
class RestoreResult extends Equatable {
  final bool success;
  final String taskId;
  final int? restoredFilesCount;
  final DateTime createdAt;
  final String? error;

  const RestoreResult({
    required this.success,
    required this.taskId,
    this.restoredFilesCount,
    required this.createdAt,
    this.error,
  });

  @override
  List<Object?> get props => [success, taskId, restoredFilesCount, createdAt, error];
}

/// Информация о резервной копии
class BackupInfo extends Equatable {
  final String id;
  final String name;
  final String? description;
  final BackupType type;
  final String path;
  final int size;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const BackupInfo({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.path,
    required this.size,
    required this.createdAt,
    this.metadata,
  });

  @override
  List<Object?> get props => [id, name, description, type, path, size, createdAt, metadata];
}

/// Статистика резервного копирования
class BackupStatistics extends Equatable {
  final int totalBackups;
  final int totalSize;
  final int fullBackups;
  final int incrementalBackups;
  final DateTime? lastBackup;
  final double averageSize;

  const BackupStatistics({
    required this.totalBackups,
    required this.totalSize,
    required this.fullBackups,
    required this.incrementalBackups,
    this.lastBackup,
    required this.averageSize,
  });

  @override
  List<Object?> get props => [totalBackups, totalSize, fullBackups, incrementalBackups, lastBackup, averageSize];
}

/// События резервного копирования
abstract class BackupEvent extends Equatable {
  const BackupEvent();

  const factory BackupEvent.started(BackupTask task) = BackupStartedEvent;
  const factory BackupEvent.completed(BackupTask task, BackupResult result) = BackupCompletedEvent;
  const factory BackupEvent.restoreStarted(RestoreTask task) = RestoreStartedEvent;
  const factory BackupEvent.restoreCompleted(RestoreTask task, RestoreResult result) = RestoreCompletedEvent;
  const factory BackupEvent.restoreFailed(RestoreTask task, RestoreResult result) = RestoreFailedEvent;
}

class BackupStartedEvent extends BackupEvent {
  final BackupTask task;

  const BackupStartedEvent(this.task);

  @override
  List<Object?> get props => [task];
}

class BackupCompletedEvent extends BackupEvent {
  final BackupTask task;
  final BackupResult result;

  const BackupCompletedEvent(this.task, this.result);

  @override
  List<Object?> get props => [task, result];
}

class RestoreStartedEvent extends BackupEvent {
  final RestoreTask task;

  const RestoreStartedEvent(this.task);

  @override
  List<Object?> get props => [task];
}

class RestoreCompletedEvent extends BackupEvent {
  final RestoreTask task;
  final RestoreResult result;

  const RestoreCompletedEvent(this.task, this.result);

  @override
  List<Object?> get props => [task, result];
}

class RestoreFailedEvent extends BackupEvent {
  final RestoreTask task;
  final RestoreResult result;

  const RestoreFailedEvent(this.task, this.result);

  @override
  List<Object?> get props => [task, result];
}
