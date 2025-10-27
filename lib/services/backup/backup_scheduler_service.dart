import 'dart:async';
import 'package:equatable/equatable.dart';
import 'backup_service.dart';

/// Сервис для планирования автоматических резервных копий
class BackupSchedulerService {
  static final BackupSchedulerService _instance = BackupSchedulerService._internal();

  factory BackupSchedulerService() => _instance;

  BackupSchedulerService._internal();

  final BackupService _backupService = BackupService();
  final Map<String, BackupSchedule> _schedules = {};
  final Map<String, Timer> _timers = {};
  final StreamController<BackupScheduleEvent> _eventController = StreamController<BackupScheduleEvent>.broadcast();

  /// Поток событий планировщика
  Stream<BackupScheduleEvent> get events => _eventController.stream;

  /// Создание расписания резервного копирования
  Future<BackupSchedule> createSchedule({
    required String name,
    required BackupScheduleType type,
    required Map<String, dynamic> scheduleConfig,
    required Map<String, dynamic> backupConfig,
    bool enabled = true,
    String? description,
    int maxRetentionDays = 30,
    int maxBackups = 10,
  }) async {
    final String scheduleId = _generateScheduleId();

    final BackupSchedule schedule = BackupSchedule(
      id: scheduleId,
      name: name,
      description: description,
      type: type,
      scheduleConfig: scheduleConfig,
      backupConfig: backupConfig,
      enabled: enabled,
      maxRetentionDays: maxRetentionDays,
      maxBackups: maxBackups,
      createdAt: DateTime.now(),
      lastRun: null,
      nextRun: _calculateNextRun(type, scheduleConfig),
    );

    _schedules[scheduleId] = schedule;

    if (enabled) {
      await _startSchedule(schedule);
    }

    _emitEvent(BackupScheduleEvent.created(schedule));
    return schedule;
  }

  /// Обновление расписания
  Future<BackupSchedule> updateSchedule({
    required String scheduleId,
    String? name,
    String? description,
    BackupScheduleType? type,
    Map<String, dynamic>? scheduleConfig,
    Map<String, dynamic>? backupConfig,
    bool? enabled,
    int? maxRetentionDays,
    int? maxBackups,
  }) async {
    final BackupSchedule? existingSchedule = _schedules[scheduleId];
    if (existingSchedule == null) {
      throw Exception('Schedule not found: $scheduleId');
    }

    // Остановка существующего таймера
    await _stopSchedule(scheduleId);

    final BackupSchedule updatedSchedule = BackupSchedule(
      id: scheduleId,
      name: name ?? existingSchedule.name,
      description: description ?? existingSchedule.description,
      type: type ?? existingSchedule.type,
      scheduleConfig: scheduleConfig ?? existingSchedule.scheduleConfig,
      backupConfig: backupConfig ?? existingSchedule.backupConfig,
      enabled: enabled ?? existingSchedule.enabled,
      maxRetentionDays: maxRetentionDays ?? existingSchedule.maxRetentionDays,
      maxBackups: maxBackups ?? existingSchedule.maxBackups,
      createdAt: existingSchedule.createdAt,
      lastRun: existingSchedule.lastRun,
      nextRun: _calculateNextRun(type ?? existingSchedule.type, scheduleConfig ?? existingSchedule.scheduleConfig),
    );

    _schedules[scheduleId] = updatedSchedule;

    if (updatedSchedule.enabled) {
      await _startSchedule(updatedSchedule);
    }

    _emitEvent(BackupScheduleEvent.updated(updatedSchedule));
    return updatedSchedule;
  }

  /// Удаление расписания
  Future<bool> deleteSchedule(String scheduleId) async {
    final BackupSchedule? schedule = _schedules[scheduleId];
    if (schedule == null) {
      return false;
    }

    await _stopSchedule(scheduleId);
    _schedules.remove(scheduleId);

    _emitEvent(BackupScheduleEvent.deleted(schedule));
    return true;
  }

  /// Получение списка расписаний
  List<BackupSchedule> getSchedules() {
    return _schedules.values.toList();
  }

  /// Получение расписания по ID
  BackupSchedule? getSchedule(String scheduleId) {
    return _schedules[scheduleId];
  }

  /// Включение/выключение расписания
  Future<void> toggleSchedule(String scheduleId, bool enabled) async {
    final BackupSchedule? schedule = _schedules[scheduleId];
    if (schedule == null) {
      throw Exception('Schedule not found: $scheduleId');
    }

    if (enabled) {
      await _startSchedule(schedule);
    } else {
      await _stopSchedule(scheduleId);
    }

    final BackupSchedule updatedSchedule = BackupSchedule(
      id: schedule.id,
      name: schedule.name,
      description: schedule.description,
      type: schedule.type,
      scheduleConfig: schedule.scheduleConfig,
      backupConfig: schedule.backupConfig,
      enabled: enabled,
      maxRetentionDays: schedule.maxRetentionDays,
      maxBackups: schedule.maxBackups,
      createdAt: schedule.createdAt,
      lastRun: schedule.lastRun,
      nextRun: enabled ? _calculateNextRun(schedule.type, schedule.scheduleConfig) : null,
    );

    _schedules[scheduleId] = updatedSchedule;
    _emitEvent(BackupScheduleEvent.updated(updatedSchedule));
  }

  /// Запуск резервного копирования по расписанию
  Future<void> runScheduledBackup(String scheduleId) async {
    final BackupSchedule? schedule = _schedules[scheduleId];
    if (schedule == null || !schedule.enabled) {
      return;
    }

    try {
      _emitEvent(BackupScheduleEvent.started(schedule));

      // Определение типа резервного копирования
      final BackupType backupType = _determineBackupType(schedule);

      BackupResult result;
      if (backupType == BackupType.full) {
        result = await _backupService.createFullBackup(
          backupName: '${schedule.name}_${DateTime.now().millisecondsSinceEpoch}',
          description: 'Scheduled backup: ${schedule.name}',
          includePaths: (schedule.backupConfig['includePaths'] as List<dynamic>?)?.cast<String>(),
          excludePaths: (schedule.backupConfig['excludePaths'] as List<dynamic>?)?.cast<String>(),
          compress: schedule.backupConfig['compress'] as bool? ?? true,
          encrypt: schedule.backupConfig['encrypt'] as bool? ?? false,
          encryptionKey: schedule.backupConfig['encryptionKey'] as String?,
          storageType: BackupStorageType.values.firstWhere(
            (type) => type.toString() == schedule.backupConfig['storageType'],
            orElse: () => BackupStorageType.local,
          ),
          storageConfig: schedule.backupConfig['storageConfig'],
        );
      } else {
        // Поиск последней полной резервной копии для инкрементального
        final String? baseBackupId = await _findLastFullBackupId();
        if (baseBackupId == null) {
          throw Exception('No full backup found for incremental backup');
        }

        result = await _backupService.createIncrementalBackup(
          backupName: '${schedule.name}_incremental_${DateTime.now().millisecondsSinceEpoch}',
          baseBackupId: baseBackupId,
          description: 'Scheduled incremental backup: ${schedule.name}',
          includePaths: (schedule.backupConfig['includePaths'] as List<dynamic>?)?.cast<String>(),
          excludePaths: (schedule.backupConfig['excludePaths'] as List<dynamic>?)?.cast<String>(),
          compress: schedule.backupConfig['compress'] as bool? ?? true,
          encrypt: schedule.backupConfig['encrypt'] as bool? ?? false,
          encryptionKey: schedule.backupConfig['encryptionKey'] as String?,
          storageType: BackupStorageType.values.firstWhere(
            (type) => type.toString() == schedule.backupConfig['storageType'],
            orElse: () => BackupStorageType.local,
          ),
          storageConfig: schedule.backupConfig['storageConfig'],
        );
      }

      // Обновление расписания
      final BackupSchedule updatedSchedule = BackupSchedule(
        id: schedule.id,
        name: schedule.name,
        description: schedule.description,
        type: schedule.type,
        scheduleConfig: schedule.scheduleConfig,
        backupConfig: schedule.backupConfig,
        enabled: schedule.enabled,
        maxRetentionDays: schedule.maxRetentionDays,
        maxBackups: schedule.maxBackups,
        createdAt: schedule.createdAt,
        lastRun: DateTime.now(),
        nextRun: _calculateNextRun(schedule.type, schedule.scheduleConfig),
      );

      _schedules[scheduleId] = updatedSchedule;

      // Очистка старых резервных копий
      await _cleanupOldBackups(schedule);

      _emitEvent(BackupScheduleEvent.completed(updatedSchedule, result));
    } catch (e) {
      _emitEvent(BackupScheduleEvent.failed(schedule, e.toString()));
    }
  }

  /// Получение статистики расписаний
  BackupScheduleStatistics getScheduleStatistics() {
    final List<BackupSchedule> schedules = _schedules.values.toList();

    final int enabledSchedules = schedules.where((s) => s.enabled).length;
    final int disabledSchedules = schedules.length - enabledSchedules;
    DateTime? nextRun;

    for (final BackupSchedule schedule in schedules) {
      if (schedule.enabled && schedule.nextRun != null) {
        if (nextRun == null || schedule.nextRun!.isBefore(nextRun)) {
          nextRun = schedule.nextRun;
        }
      }
    }

    return BackupScheduleStatistics(
      totalSchedules: schedules.length,
      enabledSchedules: enabledSchedules,
      disabledSchedules: disabledSchedules,
      nextRun: nextRun,
    );
  }

  /// Вспомогательные методы

  String _generateScheduleId() {
    return 'schedule_${DateTime.now().millisecondsSinceEpoch}_${_schedules.length}';
  }

  DateTime? _calculateNextRun(BackupScheduleType type, Map<String, dynamic> config) {
    final DateTime now = DateTime.now();

    switch (type) {
      case BackupScheduleType.daily:
        final int hour = config['hour'] ?? 2;
        final int minute = config['minute'] ?? 0;

        DateTime nextRun = DateTime(now.year, now.month, now.day, hour, minute);
        if (nextRun.isBefore(now)) {
          nextRun = nextRun.add(const Duration(days: 1));
        }
        return nextRun;

      case BackupScheduleType.weekly:
        final int dayOfWeek = config['dayOfWeek'] ?? 1; // Monday
        final int hour = config['hour'] ?? 2;
        final int minute = config['minute'] ?? 0;

        DateTime nextRun = DateTime(now.year, now.month, now.day, hour, minute);
        int daysUntilTarget = (dayOfWeek - now.weekday) % 7;
        if (daysUntilTarget == 0 && nextRun.isBefore(now)) {
          daysUntilTarget = 7;
        }
        nextRun = nextRun.add(Duration(days: daysUntilTarget));
        return nextRun;

      case BackupScheduleType.monthly:
        final int dayOfMonth = config['dayOfMonth'] ?? 1;
        final int hour = config['hour'] ?? 2;
        final int minute = config['minute'] ?? 0;

        DateTime nextRun = DateTime(now.year, now.month, dayOfMonth, hour, minute);
        if (nextRun.isBefore(now)) {
          nextRun = DateTime(now.year, now.month + 1, dayOfMonth, hour, minute);
        }
        return nextRun;

      case BackupScheduleType.custom:
        final String? cronExpression = config['cronExpression'];
        if (cronExpression != null) {
          // TODO: Implement cron expression parsing
          return null;
        }
        return null;
    }
  }

  Future<void> _startSchedule(BackupSchedule schedule) async {
    if (schedule.nextRun == null) {
      return;
    }

    final Duration delay = schedule.nextRun!.difference(DateTime.now());
    if (delay.isNegative) {
      return;
    }

    final Timer timer = Timer(delay, () async {
      await runScheduledBackup(schedule.id);

      // Планирование следующего запуска
      if (_schedules.containsKey(schedule.id) && _schedules[schedule.id]!.enabled) {
        await _startSchedule(_schedules[schedule.id]!);
      }
    });

    _timers[schedule.id] = timer;
  }

  Future<void> _stopSchedule(String scheduleId) async {
    final Timer? timer = _timers[scheduleId];
    if (timer != null) {
      timer.cancel();
      _timers.remove(scheduleId);
    }
  }

  BackupType _determineBackupType(BackupSchedule schedule) {
    // Логика определения типа резервного копирования
    final String? backupType = schedule.backupConfig['backupType'];
    if (backupType == 'incremental') {
      return BackupType.incremental;
    }
    return BackupType.full;
  }

  Future<String?> _findLastFullBackupId() async {
    // Поиск последней полной резервной копии
    // TODO: Implement actual search logic
    return null;
  }

  Future<void> _cleanupOldBackups(BackupSchedule schedule) async {
    try {
      final List<BackupInfo> backups = await _backupService.listBackups();

      // Сортировка по дате создания
      backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Удаление старых резервных копий
      final DateTime cutoffDate = DateTime.now().subtract(Duration(days: schedule.maxRetentionDays));
      final List<BackupInfo> backupsToDelete =
          backups.where((backup) => backup.createdAt.isBefore(cutoffDate)).toList();

      // Ограничение количества резервных копий
      if (backups.length > schedule.maxBackups) {
        final List<BackupInfo> excessBackups = backups.skip(schedule.maxBackups).toList();
        backupsToDelete.addAll(excessBackups);
      }

      for (final BackupInfo backup in backupsToDelete) {
        await _backupService.deleteBackup(backup.path);
      }
    } catch (e) {
      // Логирование ошибки очистки
      print('Error cleaning up old backups: $e');
    }
  }

  void _emitEvent(BackupScheduleEvent event) {
    _eventController.add(event);
  }

  void dispose() {
    for (final Timer timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _eventController.close();
  }
}

/// Типы расписаний резервного копирования
enum BackupScheduleType {
  daily,
  weekly,
  monthly,
  custom,
}

/// Расписание резервного копирования
class BackupSchedule extends Equatable {
  final String id;
  final String name;
  final String? description;
  final BackupScheduleType type;
  final Map<String, dynamic> scheduleConfig;
  final Map<String, dynamic> backupConfig;
  final bool enabled;
  final int maxRetentionDays;
  final int maxBackups;
  final DateTime createdAt;
  final DateTime? lastRun;
  final DateTime? nextRun;

  const BackupSchedule({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.scheduleConfig,
    required this.backupConfig,
    required this.enabled,
    required this.maxRetentionDays,
    required this.maxBackups,
    required this.createdAt,
    this.lastRun,
    this.nextRun,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        scheduleConfig,
        backupConfig,
        enabled,
        maxRetentionDays,
        maxBackups,
        createdAt,
        lastRun,
        nextRun,
      ];
}

/// Статистика расписаний
class BackupScheduleStatistics extends Equatable {
  final int totalSchedules;
  final int enabledSchedules;
  final int disabledSchedules;
  final DateTime? nextRun;

  const BackupScheduleStatistics({
    required this.totalSchedules,
    required this.enabledSchedules,
    required this.disabledSchedules,
    this.nextRun,
  });

  @override
  List<Object?> get props => [totalSchedules, enabledSchedules, disabledSchedules, nextRun];
}

/// События планировщика резервного копирования
abstract class BackupScheduleEvent extends Equatable {
  const BackupScheduleEvent();

  const factory BackupScheduleEvent.created(BackupSchedule schedule) = BackupScheduleCreatedEvent;
  const factory BackupScheduleEvent.updated(BackupSchedule schedule) = BackupScheduleUpdatedEvent;
  const factory BackupScheduleEvent.deleted(BackupSchedule schedule) = BackupScheduleDeletedEvent;
  const factory BackupScheduleEvent.started(BackupSchedule schedule) = BackupScheduleStartedEvent;
  const factory BackupScheduleEvent.completed(BackupSchedule schedule, BackupResult result) =
      BackupScheduleCompletedEvent;
  const factory BackupScheduleEvent.failed(BackupSchedule schedule, String error) = BackupScheduleFailedEvent;
}

class BackupScheduleCreatedEvent extends BackupScheduleEvent {
  final BackupSchedule schedule;

  const BackupScheduleCreatedEvent(this.schedule);

  @override
  List<Object?> get props => [schedule];
}

class BackupScheduleUpdatedEvent extends BackupScheduleEvent {
  final BackupSchedule schedule;

  const BackupScheduleUpdatedEvent(this.schedule);

  @override
  List<Object?> get props => [schedule];
}

class BackupScheduleDeletedEvent extends BackupScheduleEvent {
  final BackupSchedule schedule;

  const BackupScheduleDeletedEvent(this.schedule);

  @override
  List<Object?> get props => [schedule];
}

class BackupScheduleStartedEvent extends BackupScheduleEvent {
  final BackupSchedule schedule;

  const BackupScheduleStartedEvent(this.schedule);

  @override
  List<Object?> get props => [schedule];
}

class BackupScheduleCompletedEvent extends BackupScheduleEvent {
  final BackupSchedule schedule;
  final BackupResult result;

  const BackupScheduleCompletedEvent(this.schedule, this.result);

  @override
  List<Object?> get props => [schedule, result];
}

class BackupScheduleFailedEvent extends BackupScheduleEvent {
  final BackupSchedule schedule;
  final String error;

  const BackupScheduleFailedEvent(this.schedule, this.error);

  @override
  List<Object?> get props => [schedule, error];
}
