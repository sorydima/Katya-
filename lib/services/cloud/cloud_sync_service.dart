import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';

/// Сервис для синхронизации с облачными сервисами
class CloudSyncService {
  static final CloudSyncService _instance = CloudSyncService._internal();

  // Облачные провайдеры
  final Map<String, CloudProvider> _cloudProviders = {};
  final Map<String, CloudSyncTask> _syncTasks = {};
  final Map<String, CloudBackup> _backups = {};
  final Map<String, SyncConflict> _conflicts = {};

  // Конфигурация
  static const Duration _syncInterval = Duration(minutes: 15);
  static const Duration _backupInterval = Duration(hours: 6);
  static const int _maxRetryAttempts = 3;
  static const Duration _conflictResolutionTimeout = Duration(minutes: 30);

  factory CloudSyncService() => _instance;
  CloudSyncService._internal();

  /// Инициализация сервиса
  Future<void> initialize() async {
    await _loadCloudProviders();
    _setupPeriodicSync();
    _setupPeriodicBackup();
    _setupConflictResolution();
  }

  /// Регистрация облачного провайдера
  Future<CloudProviderResult> registerCloudProvider({
    required String providerId,
    required CloudProviderType type,
    required String name,
    required Map<String, String> credentials,
    Map<String, dynamic>? configuration,
  }) async {
    try {
      final provider = CloudProvider(
        providerId: providerId,
        type: type,
        name: name,
        credentials: credentials,
        configuration: configuration ?? {},
        isActive: true,
        registeredAt: DateTime.now(),
        lastSync: null,
        totalSyncs: 0,
        successfulSyncs: 0,
        failedSyncs: 0,
      );

      _cloudProviders[providerId] = provider;

      // Тестируем подключение
      final testResult = await _testCloudConnection(provider);
      if (!testResult.success) {
        provider.isActive = false;
        return CloudProviderResult(
          providerId: providerId,
          success: false,
          errorMessage: testResult.errorMessage,
        );
      }

      return CloudProviderResult(
        providerId: providerId,
        success: true,
      );
    } catch (e) {
      return CloudProviderResult(
        providerId: providerId,
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Создание задачи синхронизации
  Future<SyncTaskResult> createSyncTask({
    required String taskId,
    required String providerId,
    required String localPath,
    required String remotePath,
    required SyncDirection direction,
    SyncMode mode = SyncMode.bidirectional,
    Map<String, dynamic>? filters,
    bool autoSync = true,
  }) async {
    final provider = _cloudProviders[providerId];
    if (provider == null) {
      return SyncTaskResult(
        taskId: taskId,
        success: false,
        errorMessage: 'Cloud provider not found: $providerId',
      );
    }

    try {
      final task = CloudSyncTask(
        taskId: taskId,
        providerId: providerId,
        localPath: localPath,
        remotePath: remotePath,
        direction: direction,
        mode: mode,
        filters: filters ?? {},
        autoSync: autoSync,
        isActive: true,
        createdAt: DateTime.now(),
        lastSync: null,
        nextSync: autoSync ? DateTime.now().add(_syncInterval) : null,
        syncCount: 0,
        successCount: 0,
        failCount: 0,
      );

      _syncTasks[taskId] = task;

      return SyncTaskResult(
        taskId: taskId,
        success: true,
      );
    } catch (e) {
      return SyncTaskResult(
        taskId: taskId,
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Выполнение синхронизации
  Future<SyncExecutionResult> executeSync({
    required String taskId,
    bool force = false,
  }) async {
    final task = _syncTasks[taskId];
    if (task == null) {
      return SyncExecutionResult(
        taskId: taskId,
        success: false,
        errorMessage: 'Sync task not found: $taskId',
      );
    }

    final provider = _cloudProviders[task.providerId];
    if (provider == null || !provider.isActive) {
      return SyncExecutionResult(
        taskId: taskId,
        success: false,
        errorMessage: 'Cloud provider is not available',
      );
    }

    try {
      // Проверяем, нужна ли синхронизация
      if (!force && task.lastSync != null) {
        final timeSinceLastSync = DateTime.now().difference(task.lastSync!);
        if (timeSinceLastSync < _syncInterval) {
          return SyncExecutionResult(
            taskId: taskId,
            success: true,
            message: 'Sync not needed yet',
          );
        }
      }

      // Выполняем синхронизацию
      final syncResult = await _performSync(task, provider);

      // Обновляем статистику
      task.syncCount++;
      task.lastSync = DateTime.now();
      task.nextSync = task.autoSync ? DateTime.now().add(_syncInterval) : null;

      if (syncResult.success) {
        task.successCount++;
        provider.successfulSyncs++;
      } else {
        task.failCount++;
        provider.failedSyncs++;
      }

      provider.totalSyncs++;
      provider.lastSync = DateTime.now();

      return SyncExecutionResult(
        taskId: taskId,
        success: syncResult.success,
        filesSynced: syncResult.filesSynced,
        conflictsResolved: syncResult.conflictsResolved,
        errorMessage: syncResult.errorMessage,
      );
    } catch (e) {
      task.failCount++;
      provider.failedSyncs++;
      return SyncExecutionResult(
        taskId: taskId,
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Создание резервной копии
  Future<BackupResult> createBackup({
    required String backupId,
    required String providerId,
    required String name,
    required List<String> paths,
    BackupType type = BackupType.full,
    Map<String, dynamic>? options,
  }) async {
    final provider = _cloudProviders[providerId];
    if (provider == null) {
      return BackupResult(
        backupId: backupId,
        success: false,
        errorMessage: 'Cloud provider not found: $providerId',
      );
    }

    try {
      final backup = CloudBackup(
        backupId: backupId,
        providerId: providerId,
        name: name,
        paths: paths,
        type: type,
        options: options ?? {},
        status: BackupStatus.inProgress,
        createdAt: DateTime.now(),
        completedAt: null,
        size: 0,
        fileCount: 0,
        remotePath: '',
      );

      _backups[backupId] = backup;

      // Выполняем резервное копирование
      final backupResult = await _performBackup(backup, provider);

      if (backupResult.success) {
        backup.status = BackupStatus.completed;
        backup.completedAt = DateTime.now();
        backup.size = backupResult.size;
        backup.fileCount = backupResult.fileCount;
        backup.remotePath = backupResult.remotePath;
      } else {
        backup.status = BackupStatus.failed;
      }

      return BackupResult(
        backupId: backupId,
        success: backupResult.success,
        size: backup.size,
        fileCount: backup.fileCount,
        errorMessage: backupResult.errorMessage,
      );
    } catch (e) {
      return BackupResult(
        backupId: backupId,
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Восстановление из резервной копии
  Future<RestoreResult> restoreBackup({
    required String backupId,
    required String targetPath,
    bool overwrite = false,
  }) async {
    final backup = _backups[backupId];
    if (backup == null) {
      return RestoreResult(
        backupId: backupId,
        success: false,
        errorMessage: 'Backup not found: $backupId',
      );
    }

    final provider = _cloudProviders[backup.providerId];
    if (provider == null || !provider.isActive) {
      return RestoreResult(
        backupId: backupId,
        success: false,
        errorMessage: 'Cloud provider is not available',
      );
    }

    try {
      final restoreResult = await _performRestore(backup, provider, targetPath, overwrite);

      return RestoreResult(
        backupId: backupId,
        success: restoreResult.success,
        filesRestored: restoreResult.filesRestored,
        errorMessage: restoreResult.errorMessage,
      );
    } catch (e) {
      return RestoreResult(
        backupId: backupId,
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Разрешение конфликтов синхронизации
  Future<ConflictResolutionResult> resolveConflict({
    required String conflictId,
    required ConflictResolutionStrategy strategy,
    Map<String, dynamic>? customResolution,
  }) async {
    final conflict = _conflicts[conflictId];
    if (conflict == null) {
      return ConflictResolutionResult(
        conflictId: conflictId,
        success: false,
        errorMessage: 'Conflict not found: $conflictId',
      );
    }

    try {
      final resolution = await _applyConflictResolution(conflict, strategy, customResolution);

      if (resolution.success) {
        _conflicts.remove(conflictId);
      }

      return ConflictResolutionResult(
        conflictId: conflictId,
        success: resolution.success,
        resolution: resolution.resolution,
        errorMessage: resolution.errorMessage,
      );
    } catch (e) {
      return ConflictResolutionResult(
        conflictId: conflictId,
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Получение списка облачных провайдеров
  List<CloudProvider> getCloudProviders() {
    return _cloudProviders.values.toList();
  }

  /// Получение задач синхронизации
  List<CloudSyncTask> getSyncTasks({String? providerId}) {
    final tasks = _syncTasks.values.toList();
    if (providerId != null) {
      return tasks.where((task) => task.providerId == providerId).toList();
    }
    return tasks;
  }

  /// Получение резервных копий
  List<CloudBackup> getBackups({String? providerId}) {
    final backups = _backups.values.toList();
    if (providerId != null) {
      return backups.where((backup) => backup.providerId == providerId).toList();
    }
    return backups;
  }

  /// Получение конфликтов
  List<SyncConflict> getConflicts({String? taskId}) {
    final conflicts = _conflicts.values.toList();
    if (taskId != null) {
      return conflicts.where((conflict) => conflict.taskId == taskId).toList();
    }
    return conflicts;
  }

  /// Получение статистики синхронизации
  Future<SyncStatistics> getSyncStatistics() async {
    final totalTasks = _syncTasks.length;
    final activeTasks = _syncTasks.values.where((task) => task.isActive).length;
    final totalSyncs = _syncTasks.values.fold(0, (sum, task) => sum + task.syncCount);
    final successfulSyncs = _syncTasks.values.fold(0, (sum, task) => sum + task.successCount);
    final failedSyncs = _syncTasks.values.fold(0, (sum, task) => sum + task.failCount);

    final totalBackups = _backups.length;
    final completedBackups = _backups.values.where((backup) => backup.status == BackupStatus.completed).length;
    final totalSize = _backups.values.fold(0, (sum, backup) => sum + backup.size);

    final activeConflicts = _conflicts.length;

    return SyncStatistics(
      totalTasks: totalTasks,
      activeTasks: activeTasks,
      totalSyncs: totalSyncs,
      successfulSyncs: successfulSyncs,
      failedSyncs: failedSyncs,
      successRate: totalSyncs > 0 ? successfulSyncs / totalSyncs : 0.0,
      totalBackups: totalBackups,
      completedBackups: completedBackups,
      totalBackupSize: totalSize,
      activeConflicts: activeConflicts,
    );
  }

  /// Загрузка облачных провайдеров
  Future<void> _loadCloudProviders() async {
    // В реальной реализации здесь будет загрузка из конфигурации
    // Для демонстрации создаем несколько тестовых провайдеров
    await _createDefaultProviders();
  }

  /// Создание провайдеров по умолчанию
  Future<void> _createDefaultProviders() async {
    // Google Drive
    await registerCloudProvider(
      providerId: 'google_drive',
      type: CloudProviderType.googleDrive,
      name: 'Google Drive',
      credentials: {
        'client_id': 'your_google_client_id',
        'client_secret': 'your_google_client_secret',
        'refresh_token': 'your_refresh_token',
      },
      configuration: {
        'max_file_size': 100 * 1024 * 1024, // 100MB
        'allowed_extensions': ['.txt', '.pdf', '.doc', '.docx'],
      },
    );

    // Dropbox
    await registerCloudProvider(
      providerId: 'dropbox',
      type: CloudProviderType.dropbox,
      name: 'Dropbox',
      credentials: {
        'access_token': 'your_dropbox_access_token',
      },
      configuration: {
        'max_file_size': 150 * 1024 * 1024, // 150MB
        'allowed_extensions': ['.txt', '.pdf', '.doc', '.docx', '.xls', '.xlsx'],
      },
    );

    // OneDrive
    await registerCloudProvider(
      providerId: 'onedrive',
      type: CloudProviderType.oneDrive,
      name: 'Microsoft OneDrive',
      credentials: {
        'client_id': 'your_onedrive_client_id',
        'client_secret': 'your_onedrive_client_secret',
        'refresh_token': 'your_onedrive_refresh_token',
      },
      configuration: {
        'max_file_size': 200 * 1024 * 1024, // 200MB
        'allowed_extensions': ['.txt', '.pdf', '.doc', '.docx', '.ppt', '.pptx'],
      },
    );
  }

  /// Настройка периодической синхронизации
  void _setupPeriodicSync() {
    Timer.periodic(_syncInterval, (timer) async {
      await _performPeriodicSync();
    });
  }

  /// Настройка периодического резервного копирования
  void _setupPeriodicBackup() {
    Timer.periodic(_backupInterval, (timer) async {
      await _performPeriodicBackup();
    });
  }

  /// Настройка разрешения конфликтов
  void _setupConflictResolution() {
    Timer.periodic(const Duration(minutes: 5), (timer) async {
      await _processConflictResolution();
    });
  }

  /// Тестирование подключения к облаку
  Future<ConnectionTestResult> _testCloudConnection(CloudProvider provider) async {
    // Имитация тестирования подключения
    await Future.delayed(const Duration(seconds: 1));

    // Имитация 90% успешных подключений
    final success = Random().nextDouble() > 0.1;

    return ConnectionTestResult(
      success: success,
      errorMessage: success ? null : 'Connection failed: Authentication error',
    );
  }

  /// Выполнение синхронизации
  Future<SyncOperationResult> _performSync(CloudSyncTask task, CloudProvider provider) async {
    // Имитация времени синхронизации
    await Future.delayed(const Duration(seconds: 2));

    final filesSynced = Random().nextInt(50) + 1;
    final conflictsDetected = Random().nextInt(5);

    // Создаем конфликты, если они обнаружены
    for (int i = 0; i < conflictsDetected; i++) {
      final conflictId = 'conflict_${task.taskId}_${DateTime.now().millisecondsSinceEpoch}_$i';
      final conflict = SyncConflict(
        conflictId: conflictId,
        taskId: task.taskId,
        filePath: '${task.localPath}/conflict_file_$i.txt',
        localVersion: ConflictVersion(
          path: '${task.localPath}/conflict_file_$i.txt',
          lastModified: DateTime.now().subtract(const Duration(hours: 1)),
          size: Random().nextInt(10000) + 1000,
          hash: 'local_hash_$i',
        ),
        remoteVersion: ConflictVersion(
          path: '${task.remotePath}/conflict_file_$i.txt',
          lastModified: DateTime.now().subtract(const Duration(minutes: 30)),
          size: Random().nextInt(10000) + 1000,
          hash: 'remote_hash_$i',
        ),
        detectedAt: DateTime.now(),
        status: ConflictStatus.pending,
      );

      _conflicts[conflictId] = conflict;
    }

    // Имитация 95% успешных синхронизаций
    final success = Random().nextDouble() > 0.05;

    return SyncOperationResult(
      success: success,
      filesSynced: filesSynced,
      conflictsResolved: 0, // Конфликты обрабатываются отдельно
      errorMessage: success ? null : 'Sync failed: Network timeout',
    );
  }

  /// Выполнение резервного копирования
  Future<BackupOperationResult> _performBackup(CloudBackup backup, CloudProvider provider) async {
    // Имитация времени резервного копирования
    await Future.delayed(const Duration(seconds: 5));

    final fileCount = Random().nextInt(100) + 10;
    final size = Random().nextInt(100 * 1024 * 1024) + 1024 * 1024; // 1MB to 100MB

    // Имитация 98% успешных резервных копий
    final success = Random().nextDouble() > 0.02;

    return BackupOperationResult(
      success: success,
      size: success ? size : 0,
      fileCount: success ? fileCount : 0,
      remotePath: success ? '/backups/${backup.backupId}' : '',
      errorMessage: success ? null : 'Backup failed: Insufficient storage space',
    );
  }

  /// Выполнение восстановления
  Future<RestoreOperationResult> _performRestore(
      CloudBackup backup, CloudProvider provider, String targetPath, bool overwrite) async {
    // Имитация времени восстановления
    await Future.delayed(const Duration(seconds: 3));

    final filesRestored = Random().nextInt(50) + 1;

    // Имитация 99% успешных восстановлений
    final success = Random().nextDouble() > 0.01;

    return RestoreOperationResult(
      success: success,
      filesRestored: success ? filesRestored : 0,
      errorMessage: success ? null : 'Restore failed: Target path not accessible',
    );
  }

  /// Применение разрешения конфликта
  Future<ConflictResolutionOperationResult> _applyConflictResolution(
      SyncConflict conflict, ConflictResolutionStrategy strategy, Map<String, dynamic>? customResolution) async {
    // Имитация времени разрешения конфликта
    await Future.delayed(const Duration(milliseconds: 500));

    String resolution;
    switch (strategy) {
      case ConflictResolutionStrategy.useLocal:
        resolution = 'local';
      case ConflictResolutionStrategy.useRemote:
        resolution = 'remote';
      case ConflictResolutionStrategy.merge:
        resolution = 'merged';
      case ConflictResolutionStrategy.custom:
        resolution = customResolution?['resolution'] as String? ?? 'custom';
      case ConflictResolutionStrategy.skip:
        resolution = 'skipped';
    }

    // Имитация 100% успешных разрешений конфликтов
    return ConflictResolutionOperationResult(
      success: true,
      resolution: resolution,
      errorMessage: null,
    );
  }

  /// Выполнение периодической синхронизации
  Future<void> _performPeriodicSync() async {
    final autoSyncTasks = _syncTasks.values.where((task) => task.autoSync && task.isActive).toList();

    for (final task in autoSyncTasks) {
      if (task.nextSync != null && DateTime.now().isAfter(task.nextSync!)) {
        await executeSync(taskId: task.taskId);
      }
    }
  }

  /// Выполнение периодического резервного копирования
  Future<void> _performPeriodicBackup() async {
    // В реальной реализации здесь будет автоматическое создание резервных копий
    // Для демонстрации просто логируем
  }

  /// Обработка разрешения конфликтов
  Future<void> _processConflictResolution() async {
    final pendingConflicts = _conflicts.values.where((conflict) => conflict.status == ConflictStatus.pending).toList();

    for (final conflict in pendingConflicts) {
      // Автоматическое разрешение конфликтов по умолчанию (используем локальную версию)
      await resolveConflict(
        conflictId: conflict.conflictId,
        strategy: ConflictResolutionStrategy.useLocal,
      );
    }
  }

  /// Освобождение ресурсов
  void dispose() {
    _cloudProviders.clear();
    _syncTasks.clear();
    _backups.clear();
    _conflicts.clear();
  }
}

/// Модели данных

/// Облачный провайдер
class CloudProvider extends Equatable {
  final String providerId;
  final CloudProviderType type;
  final String name;
  final Map<String, String> credentials;
  final Map<String, dynamic> configuration;
  bool isActive;
  final DateTime registeredAt;
  DateTime? lastSync;
  int totalSyncs;
  int successfulSyncs;
  int failedSyncs;

  const CloudProvider({
    required this.providerId,
    required this.type,
    required this.name,
    required this.credentials,
    required this.configuration,
    required this.isActive,
    required this.registeredAt,
    this.lastSync,
    required this.totalSyncs,
    required this.successfulSyncs,
    required this.failedSyncs,
  });

  @override
  List<Object?> get props => [
        providerId,
        type,
        name,
        credentials,
        configuration,
        isActive,
        registeredAt,
        lastSync,
        totalSyncs,
        successfulSyncs,
        failedSyncs,
      ];
}

/// Задача синхронизации с облаком
class CloudSyncTask extends Equatable {
  final String taskId;
  final String providerId;
  final String localPath;
  final String remotePath;
  final SyncDirection direction;
  final SyncMode mode;
  final Map<String, dynamic> filters;
  bool autoSync;
  bool isActive;
  final DateTime createdAt;
  DateTime? lastSync;
  DateTime? nextSync;
  int syncCount;
  int successCount;
  int failCount;

  const CloudSyncTask({
    required this.taskId,
    required this.providerId,
    required this.localPath,
    required this.remotePath,
    required this.direction,
    required this.mode,
    required this.filters,
    required this.autoSync,
    required this.isActive,
    required this.createdAt,
    this.lastSync,
    this.nextSync,
    required this.syncCount,
    required this.successCount,
    required this.failCount,
  });

  @override
  List<Object?> get props => [
        taskId,
        providerId,
        localPath,
        remotePath,
        direction,
        mode,
        filters,
        autoSync,
        isActive,
        createdAt,
        lastSync,
        nextSync,
        syncCount,
        successCount,
        failCount,
      ];
}

/// Резервная копия в облаке
class CloudBackup extends Equatable {
  final String backupId;
  final String providerId;
  final String name;
  final List<String> paths;
  final BackupType type;
  final Map<String, dynamic> options;
  BackupStatus status;
  final DateTime createdAt;
  DateTime? completedAt;
  int size;
  int fileCount;
  String remotePath;

  const CloudBackup({
    required this.backupId,
    required this.providerId,
    required this.name,
    required this.paths,
    required this.type,
    required this.options,
    required this.status,
    required this.createdAt,
    this.completedAt,
    required this.size,
    required this.fileCount,
    required this.remotePath,
  });

  @override
  List<Object?> get props => [
        backupId,
        providerId,
        name,
        paths,
        type,
        options,
        status,
        createdAt,
        completedAt,
        size,
        fileCount,
        remotePath,
      ];
}

/// Конфликт синхронизации
class SyncConflict extends Equatable {
  final String conflictId;
  final String taskId;
  final String filePath;
  final ConflictVersion localVersion;
  final ConflictVersion remoteVersion;
  final DateTime detectedAt;
  ConflictStatus status;

  const SyncConflict({
    required this.conflictId,
    required this.taskId,
    required this.filePath,
    required this.localVersion,
    required this.remoteVersion,
    required this.detectedAt,
    required this.status,
  });

  @override
  List<Object?> get props => [
        conflictId,
        taskId,
        filePath,
        localVersion,
        remoteVersion,
        detectedAt,
        status,
      ];
}

/// Версия файла в конфликте
class ConflictVersion extends Equatable {
  final String path;
  final DateTime lastModified;
  final int size;
  final String hash;

  const ConflictVersion({
    required this.path,
    required this.lastModified,
    required this.size,
    required this.hash,
  });

  @override
  List<Object?> get props => [path, lastModified, size, hash];
}

/// Статистика синхронизации
class SyncStatistics extends Equatable {
  final int totalTasks;
  final int activeTasks;
  final int totalSyncs;
  final int successfulSyncs;
  final int failedSyncs;
  final double successRate;
  final int totalBackups;
  final int completedBackups;
  final int totalBackupSize;
  final int activeConflicts;

  const SyncStatistics({
    required this.totalTasks,
    required this.activeTasks,
    required this.totalSyncs,
    required this.successfulSyncs,
    required this.failedSyncs,
    required this.successRate,
    required this.totalBackups,
    required this.completedBackups,
    required this.totalBackupSize,
    required this.activeConflicts,
  });

  @override
  List<Object?> get props => [
        totalTasks,
        activeTasks,
        totalSyncs,
        successfulSyncs,
        failedSyncs,
        successRate,
        totalBackups,
        completedBackups,
        totalBackupSize,
        activeConflicts,
      ];
}

/// Результаты операций

/// Результат регистрации облачного провайдера
class CloudProviderResult extends Equatable {
  final String providerId;
  final bool success;
  final String? errorMessage;

  const CloudProviderResult({
    required this.providerId,
    required this.success,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [providerId, success, errorMessage];
}

/// Результат создания задачи синхронизации
class SyncTaskResult extends Equatable {
  final String taskId;
  final bool success;
  final String? errorMessage;

  const SyncTaskResult({
    required this.taskId,
    required this.success,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [taskId, success, errorMessage];
}

/// Результат выполнения синхронизации
class SyncExecutionResult extends Equatable {
  final String taskId;
  final bool success;
  final int filesSynced;
  final int conflictsResolved;
  final String? errorMessage;
  final String? message;

  const SyncExecutionResult({
    required this.taskId,
    required this.success,
    required this.filesSynced,
    required this.conflictsResolved,
    this.errorMessage,
    this.message,
  });

  @override
  List<Object?> get props => [taskId, success, filesSynced, conflictsResolved, errorMessage, message];
}

/// Результат создания резервной копии
class BackupResult extends Equatable {
  final String backupId;
  final bool success;
  final int size;
  final int fileCount;
  final String? errorMessage;

  const BackupResult({
    required this.backupId,
    required this.success,
    required this.size,
    required this.fileCount,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [backupId, success, size, fileCount, errorMessage];
}

/// Результат восстановления
class RestoreResult extends Equatable {
  final String backupId;
  final bool success;
  final int filesRestored;
  final String? errorMessage;

  const RestoreResult({
    required this.backupId,
    required this.success,
    required this.filesRestored,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [backupId, success, filesRestored, errorMessage];
}

/// Результат разрешения конфликта
class ConflictResolutionResult extends Equatable {
  final String conflictId;
  final bool success;
  final String resolution;
  final String? errorMessage;

  const ConflictResolutionResult({
    required this.conflictId,
    required this.success,
    required this.resolution,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [conflictId, success, resolution, errorMessage];
}

/// Внутренние результаты операций

/// Результат тестирования подключения
class ConnectionTestResult extends Equatable {
  final bool success;
  final String? errorMessage;

  const ConnectionTestResult({
    required this.success,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [success, errorMessage];
}

/// Результат операции синхронизации
class SyncOperationResult extends Equatable {
  final bool success;
  final int filesSynced;
  final int conflictsResolved;
  final String? errorMessage;

  const SyncOperationResult({
    required this.success,
    required this.filesSynced,
    required this.conflictsResolved,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [success, filesSynced, conflictsResolved, errorMessage];
}

/// Результат операции резервного копирования
class BackupOperationResult extends Equatable {
  final bool success;
  final int size;
  final int fileCount;
  final String remotePath;
  final String? errorMessage;

  const BackupOperationResult({
    required this.success,
    required this.size,
    required this.fileCount,
    required this.remotePath,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [success, size, fileCount, remotePath, errorMessage];
}

/// Результат операции восстановления
class RestoreOperationResult extends Equatable {
  final bool success;
  final int filesRestored;
  final String? errorMessage;

  const RestoreOperationResult({
    required this.success,
    required this.filesRestored,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [success, filesRestored, errorMessage];
}

/// Результат операции разрешения конфликта
class ConflictResolutionOperationResult extends Equatable {
  final bool success;
  final String resolution;
  final String? errorMessage;

  const ConflictResolutionOperationResult({
    required this.success,
    required this.resolution,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [success, resolution, errorMessage];
}

/// Перечисления

/// Тип облачного провайдера
enum CloudProviderType { googleDrive, dropbox, oneDrive, awsS3, azureBlob }

/// Направление синхронизации
enum SyncDirection { upload, download, bidirectional }

/// Режим синхронизации
enum SyncMode { bidirectional, mirror, backup }

/// Тип резервной копии
enum BackupType { full, incremental, differential }

/// Статус резервной копии
enum BackupStatus { inProgress, completed, failed, cancelled }

/// Стратегия разрешения конфликтов
enum ConflictResolutionStrategy { useLocal, useRemote, merge, custom, skip }

/// Статус конфликта
enum ConflictStatus { pending, resolved, failed }
