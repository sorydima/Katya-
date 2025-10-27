import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';

/// Сервис для профилирования производительности кода
class PerformanceProfilerService {
  static final PerformanceProfilerService _instance = PerformanceProfilerService._internal();

  factory PerformanceProfilerService() => _instance;

  PerformanceProfilerService._internal();

  final Map<String, CodeProfile> _profiles = {};
  final Map<String, List<ExecutionTrace>> _traces = {};
  final Map<String, List<MemorySnapshot>> _memorySnapshots = {};
  final StreamController<ProfilerEvent> _eventController = StreamController<ProfilerEvent>.broadcast();

  bool _isProfiling = false;
  Timer? _profilingTimer;

  /// Поток событий профилировщика
  Stream<ProfilerEvent> get events => _eventController.stream;

  /// Запуск профилирования
  Future<void> startProfiling({
    Duration interval = const Duration(seconds: 1),
    bool includeMemory = true,
    bool includeCpu = true,
  }) async {
    if (_isProfiling) return;

    _isProfiling = true;
    _profilingTimer = Timer.periodic(interval, (_) => _collectProfileData(includeMemory, includeCpu));

    _emitEvent(const ProfilerEvent.profilingStarted());
    print('Performance profiling started');
  }

  /// Остановка профилирования
  Future<void> stopProfiling() async {
    _isProfiling = false;
    _profilingTimer?.cancel();
    _profilingTimer = null;

    _emitEvent(const ProfilerEvent.profilingStopped());
    print('Performance profiling stopped');
  }

  /// Профилирование функции
  Future<T> profileFunction<T>(
    String functionName,
    Future<T> Function() function, {
    bool trackMemory = true,
    bool trackCpu = true,
  }) async {
    final String profileId = '${functionName}_${DateTime.now().millisecondsSinceEpoch}';
    final Stopwatch stopwatch = Stopwatch()..start();

    MemorySnapshot? startMemory;
    if (trackMemory) {
      startMemory = await _takeMemorySnapshot();
    }

    try {
      final T result = await function();
      stopwatch.stop();

      final MemorySnapshot? endMemory = trackMemory ? await _takeMemorySnapshot() : null;

      final ExecutionTrace trace = ExecutionTrace(
        id: profileId,
        functionName: functionName,
        startTime: DateTime.now().subtract(Duration(milliseconds: stopwatch.elapsedMilliseconds)),
        endTime: DateTime.now(),
        duration: Duration(milliseconds: stopwatch.elapsedMilliseconds),
        memoryBefore: startMemory,
        memoryAfter: endMemory,
        memoryDelta: endMemory != null && startMemory != null ? endMemory.heapUsed - startMemory.heapUsed : null,
        success: true,
        error: null,
      );

      _addTrace(trace);
      _emitEvent(ProfilerEvent.functionProfiled(trace));

      return result;
    } catch (e) {
      stopwatch.stop();

      final ExecutionTrace trace = ExecutionTrace(
        id: profileId,
        functionName: functionName,
        startTime: DateTime.now().subtract(Duration(milliseconds: stopwatch.elapsedMilliseconds)),
        endTime: DateTime.now(),
        duration: Duration(milliseconds: stopwatch.elapsedMilliseconds),
        memoryBefore: startMemory,
        memoryAfter: null,
        memoryDelta: null,
        success: false,
        error: e.toString(),
      );

      _addTrace(trace);
      _emitEvent(ProfilerEvent.functionProfiled(trace));

      rethrow;
    }
  }

  /// Профилирование блока кода
  Future<T> profileBlock<T>(
    String blockName,
    Future<T> Function() block, {
    bool trackMemory = true,
  }) async {
    return profileFunction(blockName, block, trackMemory: trackMemory);
  }

  /// Создание профиля кода
  Future<CodeProfile> createProfile({
    required String name,
    required String description,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) async {
    final String profileId = _generateProfileId();

    final CodeProfile profile = CodeProfile(
      id: profileId,
      name: name,
      description: description,
      tags: tags ?? [],
      metadata: metadata ?? {},
      createdAt: DateTime.now(),
      lastUpdated: DateTime.now(),
      isActive: true,
    );

    _profiles[profileId] = profile;
    _emitEvent(ProfilerEvent.profileCreated(profile));

    return profile;
  }

  /// Анализ производительности
  Future<PerformanceAnalysis> analyzePerformance({
    String? profileId,
    Duration? timeRange,
    List<String>? functionNames,
  }) async {
    final List<ExecutionTrace> traces = _getTracesForAnalysis(profileId, timeRange, functionNames);

    if (traces.isEmpty) {
      return const PerformanceAnalysis(
        totalExecutions: 0,
        averageExecutionTime: Duration.zero,
        minExecutionTime: Duration.zero,
        maxExecutionTime: Duration.zero,
        totalMemoryUsage: 0,
        averageMemoryUsage: 0,
        slowestFunctions: [],
        memoryIntensiveFunctions: [],
        errorRate: 0,
        recommendations: [],
      );
    }

    // Анализ времени выполнения
    final List<Duration> executionTimes = traces.map((t) => t.duration).toList();
    final Duration averageExecutionTime = Duration(
      milliseconds: executionTimes.map((d) => d.inMilliseconds).reduce((a, b) => a + b) ~/ executionTimes.length,
    );
    final Duration minExecutionTime = executionTimes.reduce((a, b) => a < b ? a : b);
    final Duration maxExecutionTime = executionTimes.reduce((a, b) => a > b ? a : b);

    // Анализ использования памяти
    final List<int> memoryUsages = traces.where((t) => t.memoryDelta != null).map((t) => t.memoryDelta!).toList();
    final int totalMemoryUsage = memoryUsages.fold(0, (a, b) => a + b);
    final double averageMemoryUsage = memoryUsages.isNotEmpty ? totalMemoryUsage / memoryUsages.length : 0;

    // Самые медленные функции
    final List<FunctionPerformance> slowestFunctions = _getSlowestFunctions(traces);

    // Функции с наибольшим использованием памяти
    final List<FunctionPerformance> memoryIntensiveFunctions = _getMemoryIntensiveFunctions(traces);

    // Анализ ошибок
    final int errorCount = traces.where((t) => !t.success).length;
    final double errorRate = traces.isNotEmpty ? (errorCount / traces.length) * 100 : 0;

    // Генерация рекомендаций
    final List<String> recommendations = _generateRecommendations(
      averageExecutionTime,
      averageMemoryUsage,
      errorRate,
      slowestFunctions,
    );

    return PerformanceAnalysis(
      totalExecutions: traces.length,
      averageExecutionTime: averageExecutionTime,
      minExecutionTime: minExecutionTime,
      maxExecutionTime: maxExecutionTime,
      totalMemoryUsage: totalMemoryUsage,
      averageMemoryUsage: averageMemoryUsage,
      slowestFunctions: slowestFunctions,
      memoryIntensiveFunctions: memoryIntensiveFunctions,
      errorRate: errorRate,
      recommendations: recommendations,
    );
  }

  /// Получение статистики профилирования
  ProfilingStatistics getStatistics() {
    final int totalProfiles = _profiles.length;
    final int totalTraces = _traces.values.fold(0, (sum, traces) => sum + traces.length);
    final int activeProfiles = _profiles.values.where((p) => p.isActive).length;

    return ProfilingStatistics(
      totalProfiles: totalProfiles,
      totalTraces: totalTraces,
      activeProfiles: activeProfiles,
      isProfiling: _isProfiling,
      lastUpdate: DateTime.now(),
    );
  }

  /// Получение профилей
  List<CodeProfile> getProfiles() => _profiles.values.toList();

  /// Получение трейсов
  Map<String, List<ExecutionTrace>> getTraces() => Map.unmodifiable(_traces);

  /// Получение снимков памяти
  Map<String, List<MemorySnapshot>> getMemorySnapshots() => Map.unmodifiable(_memorySnapshots);

  /// Экспорт данных профилирования
  Future<Map<String, dynamic>> exportData({
    String? profileId,
    Duration? timeRange,
  }) async {
    final Map<String, dynamic> exportData = {
      'exportedAt': DateTime.now().toIso8601String(),
      'profiles': _profiles.values.map((p) => _profileToMap(p)).toList(),
      'traces': _getTracesForExport(profileId, timeRange).map((t) => _traceToMap(t)).toList(),
      'memorySnapshots':
          _getMemorySnapshotsForExport(profileId, timeRange).map((s) => _memorySnapshotToMap(s)).toList(),
    };

    return exportData;
  }

  /// Вспомогательные методы

  Future<void> _collectProfileData(bool includeMemory, bool includeCpu) async {
    try {
      if (includeMemory) {
        final MemorySnapshot snapshot = await _takeMemorySnapshot();
        _addMemorySnapshot(snapshot);
      }

      if (includeCpu) {
        // TODO: Implement CPU profiling
      }

      _emitEvent(const ProfilerEvent.dataCollected());
    } catch (e) {
      _emitEvent(ProfilerEvent.collectionError(e.toString()));
    }
  }

  Future<MemorySnapshot> _takeMemorySnapshot() async {
    // Упрощенная реализация - в реальном приложении используйте системные API
    final ProcessResult result = await Process.run('ps', ['-o', 'rss,vsz', '-p', '${ProcessInfo.currentRss}']);

    int heapUsed = 0;
    int heapTotal = 0;

    if (result.exitCode == 0) {
      final List<String> lines = result.stdout.toString().split('\n');
      if (lines.length > 1) {
        final List<String> values = lines[1].trim().split(RegExp(r'\s+'));
        if (values.length >= 2) {
          heapUsed = int.tryParse(values[0]) ?? 0;
          heapTotal = int.tryParse(values[1]) ?? 0;
        }
      }
    }

    return MemorySnapshot(
      timestamp: DateTime.now(),
      heapUsed: heapUsed,
      heapTotal: heapTotal,
      externalMemory: 0, // TODO: Implement external memory tracking
    );
  }

  void _addTrace(ExecutionTrace trace) {
    final String key = trace.functionName;
    _traces[key] ??= [];
    _traces[key]!.add(trace);

    // Ограничение размера (последние 1000 трейсов на функцию)
    if (_traces[key]!.length > 1000) {
      _traces[key]!.removeAt(0);
    }
  }

  void _addMemorySnapshot(MemorySnapshot snapshot) {
    const String key = 'system';
    _memorySnapshots[key] ??= [];
    _memorySnapshots[key]!.add(snapshot);

    // Ограничение размера (последние 1000 снимков)
    if (_memorySnapshots[key]!.length > 1000) {
      _memorySnapshots[key]!.removeAt(0);
    }
  }

  List<ExecutionTrace> _getTracesForAnalysis(String? profileId, Duration? timeRange, List<String>? functionNames) {
    List<ExecutionTrace> traces = [];

    if (functionNames != null) {
      for (final String functionName in functionNames) {
        traces.addAll(_traces[functionName] ?? []);
      }
    } else {
      traces = _traces.values.expand((list) => list).toList();
    }

    if (timeRange != null) {
      final DateTime cutoff = DateTime.now().subtract(timeRange);
      traces = traces.where((t) => t.startTime.isAfter(cutoff)).toList();
    }

    return traces;
  }

  List<FunctionPerformance> _getSlowestFunctions(List<ExecutionTrace> traces) {
    final Map<String, List<Duration>> functionTimes = {};

    for (final ExecutionTrace trace in traces) {
      functionTimes[trace.functionName] ??= [];
      functionTimes[trace.functionName]!.add(trace.duration);
    }

    final List<FunctionPerformance> performances = [];

    for (final MapEntry<String, List<Duration>> entry in functionTimes.entries) {
      final List<Duration> times = entry.value;
      final Duration averageTime = Duration(
        milliseconds: times.map((d) => d.inMilliseconds).reduce((a, b) => a + b) ~/ times.length,
      );

      performances.add(FunctionPerformance(
        functionName: entry.key,
        executionCount: times.length,
        averageTime: averageTime,
        totalTime: Duration(milliseconds: times.map((d) => d.inMilliseconds).reduce((a, b) => a + b)),
        minTime: times.reduce((a, b) => a < b ? a : b),
        maxTime: times.reduce((a, b) => a > b ? a : b),
      ));
    }

    performances.sort((a, b) => b.averageTime.compareTo(a.averageTime));
    return performances.take(10).toList();
  }

  List<FunctionPerformance> _getMemoryIntensiveFunctions(List<ExecutionTrace> traces) {
    final Map<String, List<int>> functionMemory = {};

    for (final ExecutionTrace trace in traces.where((t) => t.memoryDelta != null)) {
      functionMemory[trace.functionName] ??= [];
      functionMemory[trace.functionName]!.add(trace.memoryDelta!);
    }

    final List<FunctionPerformance> performances = [];

    for (final MapEntry<String, List<int>> entry in functionMemory.entries) {
      final List<int> memoryUsages = entry.value;
      final double averageMemory = memoryUsages.reduce((a, b) => a + b) / memoryUsages.length;

      performances.add(FunctionPerformance(
        functionName: entry.key,
        executionCount: memoryUsages.length,
        averageTime: Duration.zero, // Not relevant for memory analysis
        totalTime: Duration.zero,
        minTime: Duration.zero,
        maxTime: Duration.zero,
        averageMemoryUsage: averageMemory,
        totalMemoryUsage: memoryUsages.reduce((a, b) => a + b),
      ));
    }

    performances.sort((a, b) => (b.averageMemoryUsage ?? 0).compareTo(a.averageMemoryUsage ?? 0));
    return performances.take(10).toList();
  }

  List<String> _generateRecommendations(
    Duration averageExecutionTime,
    double averageMemoryUsage,
    double errorRate,
    List<FunctionPerformance> slowestFunctions,
  ) {
    final List<String> recommendations = [];

    if (averageExecutionTime.inMilliseconds > 1000) {
      recommendations.add('Consider optimizing slow functions - average execution time is high');
    }

    if (averageMemoryUsage > 1000000) {
      // 1MB
      recommendations.add('Memory usage is high - consider memory optimization');
    }

    if (errorRate > 5) {
      recommendations.add('Error rate is high - investigate and fix issues');
    }

    if (slowestFunctions.isNotEmpty) {
      final String slowestFunction = slowestFunctions.first.functionName;
      recommendations.add('Function "$slowestFunction" is the slowest - consider optimization');
    }

    return recommendations;
  }

  List<ExecutionTrace> _getTracesForExport(String? profileId, Duration? timeRange) {
    return _getTracesForAnalysis(profileId, timeRange, null);
  }

  List<MemorySnapshot> _getMemorySnapshotsForExport(String? profileId, Duration? timeRange) {
    List<MemorySnapshot> snapshots = _memorySnapshots.values.expand((list) => list).toList();

    if (timeRange != null) {
      final DateTime cutoff = DateTime.now().subtract(timeRange);
      snapshots = snapshots.where((s) => s.timestamp.isAfter(cutoff)).toList();
    }

    return snapshots;
  }

  String _generateProfileId() {
    return 'profile_${DateTime.now().millisecondsSinceEpoch}_${_profiles.length}';
  }

  Map<String, dynamic> _profileToMap(CodeProfile profile) {
    return {
      'id': profile.id,
      'name': profile.name,
      'description': profile.description,
      'tags': profile.tags,
      'metadata': profile.metadata,
      'createdAt': profile.createdAt.toIso8601String(),
      'lastUpdated': profile.lastUpdated.toIso8601String(),
      'isActive': profile.isActive,
    };
  }

  Map<String, dynamic> _traceToMap(ExecutionTrace trace) {
    return {
      'id': trace.id,
      'functionName': trace.functionName,
      'startTime': trace.startTime.toIso8601String(),
      'endTime': trace.endTime.toIso8601String(),
      'duration': trace.duration.inMilliseconds,
      'memoryBefore': trace.memoryBefore != null ? _memorySnapshotToMap(trace.memoryBefore!) : null,
      'memoryAfter': trace.memoryAfter != null ? _memorySnapshotToMap(trace.memoryAfter!) : null,
      'memoryDelta': trace.memoryDelta,
      'success': trace.success,
      'error': trace.error,
    };
  }

  Map<String, dynamic> _memorySnapshotToMap(MemorySnapshot snapshot) {
    return {
      'timestamp': snapshot.timestamp.toIso8601String(),
      'heapUsed': snapshot.heapUsed,
      'heapTotal': snapshot.heapTotal,
      'externalMemory': snapshot.externalMemory,
    };
  }

  void _emitEvent(ProfilerEvent event) {
    _eventController.add(event);
  }

  void dispose() {
    stopProfiling();
    _eventController.close();
  }
}

/// Профиль кода
class CodeProfile extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<String> tags;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final bool isActive;

  const CodeProfile({
    required this.id,
    required this.name,
    required this.description,
    required this.tags,
    required this.metadata,
    required this.createdAt,
    required this.lastUpdated,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, name, description, tags, metadata, createdAt, lastUpdated, isActive];
}

/// Трейс выполнения
class ExecutionTrace extends Equatable {
  final String id;
  final String functionName;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final MemorySnapshot? memoryBefore;
  final MemorySnapshot? memoryAfter;
  final int? memoryDelta;
  final bool success;
  final String? error;

  const ExecutionTrace({
    required this.id,
    required this.functionName,
    required this.startTime,
    required this.endTime,
    required this.duration,
    this.memoryBefore,
    this.memoryAfter,
    this.memoryDelta,
    required this.success,
    this.error,
  });

  @override
  List<Object?> get props => [
        id,
        functionName,
        startTime,
        endTime,
        duration,
        memoryBefore,
        memoryAfter,
        memoryDelta,
        success,
        error,
      ];
}

/// Снимок памяти
class MemorySnapshot extends Equatable {
  final DateTime timestamp;
  final int heapUsed;
  final int heapTotal;
  final int externalMemory;

  const MemorySnapshot({
    required this.timestamp,
    required this.heapUsed,
    required this.heapTotal,
    required this.externalMemory,
  });

  @override
  List<Object?> get props => [timestamp, heapUsed, heapTotal, externalMemory];
}

/// Производительность функции
class FunctionPerformance extends Equatable {
  final String functionName;
  final int executionCount;
  final Duration averageTime;
  final Duration totalTime;
  final Duration minTime;
  final Duration maxTime;
  final double? averageMemoryUsage;
  final int? totalMemoryUsage;

  const FunctionPerformance({
    required this.functionName,
    required this.executionCount,
    required this.averageTime,
    required this.totalTime,
    required this.minTime,
    required this.maxTime,
    this.averageMemoryUsage,
    this.totalMemoryUsage,
  });

  @override
  List<Object?> get props => [
        functionName,
        executionCount,
        averageTime,
        totalTime,
        minTime,
        maxTime,
        averageMemoryUsage,
        totalMemoryUsage,
      ];
}

/// Анализ производительности
class PerformanceAnalysis extends Equatable {
  final int totalExecutions;
  final Duration averageExecutionTime;
  final Duration minExecutionTime;
  final Duration maxExecutionTime;
  final int totalMemoryUsage;
  final double averageMemoryUsage;
  final List<FunctionPerformance> slowestFunctions;
  final List<FunctionPerformance> memoryIntensiveFunctions;
  final double errorRate;
  final List<String> recommendations;

  const PerformanceAnalysis({
    required this.totalExecutions,
    required this.averageExecutionTime,
    required this.minExecutionTime,
    required this.maxExecutionTime,
    required this.totalMemoryUsage,
    required this.averageMemoryUsage,
    required this.slowestFunctions,
    required this.memoryIntensiveFunctions,
    required this.errorRate,
    required this.recommendations,
  });

  @override
  List<Object?> get props => [
        totalExecutions,
        averageExecutionTime,
        minExecutionTime,
        maxExecutionTime,
        totalMemoryUsage,
        averageMemoryUsage,
        slowestFunctions,
        memoryIntensiveFunctions,
        errorRate,
        recommendations,
      ];
}

/// Статистика профилирования
class ProfilingStatistics extends Equatable {
  final int totalProfiles;
  final int totalTraces;
  final int activeProfiles;
  final bool isProfiling;
  final DateTime lastUpdate;

  const ProfilingStatistics({
    required this.totalProfiles,
    required this.totalTraces,
    required this.activeProfiles,
    required this.isProfiling,
    required this.lastUpdate,
  });

  @override
  List<Object?> get props => [totalProfiles, totalTraces, activeProfiles, isProfiling, lastUpdate];
}

/// События профилировщика
abstract class ProfilerEvent extends Equatable {
  const ProfilerEvent();

  const factory ProfilerEvent.profilingStarted() = ProfilerStartedEvent;
  const factory ProfilerEvent.profilingStopped() = ProfilerStoppedEvent;
  const factory ProfilerEvent.functionProfiled(ExecutionTrace trace) = FunctionProfiledEvent;
  const factory ProfilerEvent.profileCreated(CodeProfile profile) = ProfileCreatedEvent;
  const factory ProfilerEvent.dataCollected() = DataCollectedEvent;
  const factory ProfilerEvent.collectionError(String error) = CollectionErrorEvent;
}

class ProfilerStartedEvent extends ProfilerEvent {
  const ProfilerStartedEvent();

  @override
  List<Object?> get props => [];
}

class ProfilerStoppedEvent extends ProfilerEvent {
  const ProfilerStoppedEvent();

  @override
  List<Object?> get props => [];
}

class FunctionProfiledEvent extends ProfilerEvent {
  final ExecutionTrace trace;

  const FunctionProfiledEvent(this.trace);

  @override
  List<Object?> get props => [trace];
}

class ProfileCreatedEvent extends ProfilerEvent {
  final CodeProfile profile;

  const ProfileCreatedEvent(this.profile);

  @override
  List<Object?> get props => [profile];
}

class DataCollectedEvent extends ProfilerEvent {
  const DataCollectedEvent();

  @override
  List<Object?> get props => [];
}

class CollectionErrorEvent extends ProfilerEvent {
  final String error;

  const CollectionErrorEvent(this.error);

  @override
  List<Object?> get props => [error];
}
