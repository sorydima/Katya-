import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// Перечисление типов профилирования
enum ProfilingType {
  function,
  database,
  api,
  memory,
  cpu,
  network,
  custom,
}

/// Перечисление уровней детализации профилирования
enum ProfilingLevel {
  basic,
  detailed,
  comprehensive,
}

/// Модель точки профилирования
class ProfilingPoint extends Equatable {
  final String id;
  final String name;
  final ProfilingType type;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? duration;
  final Map<String, dynamic>? metadata;
  final List<ProfilingPoint>? children;
  final String? parentId;

  const ProfilingPoint({
    required this.id,
    required this.name,
    required this.type,
    required this.startTime,
    this.endTime,
    this.duration,
    this.metadata,
    this.children,
    this.parentId,
  });

  ProfilingPoint copyWith({
    String? id,
    String? name,
    ProfilingType? type,
    DateTime? startTime,
    DateTime? endTime,
    Duration? duration,
    Map<String, dynamic>? metadata,
    List<ProfilingPoint>? children,
    String? parentId,
  }) {
    return ProfilingPoint(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      metadata: metadata ?? this.metadata,
      children: children ?? this.children,
      parentId: parentId ?? this.parentId,
    );
  }

  @override
  List<Object?> get props => [id, name, type, startTime, endTime, duration, metadata, children, parentId];
}

/// Модель отчета профилирования
class ProfilingReport extends Equatable {
  final String id;
  final String name;
  final DateTime startTime;
  final DateTime endTime;
  final Duration totalDuration;
  final List<ProfilingPoint> rootPoints;
  final Map<String, dynamic> summary;
  final ProfilingLevel level;

  const ProfilingReport({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.totalDuration,
    required this.rootPoints,
    required this.summary,
    required this.level,
  });

  @override
  List<Object?> get props => [id, name, startTime, endTime, totalDuration, rootPoints, summary, level];
}

/// Модель конфигурации профилирования
class ProfilingConfig extends Equatable {
  final ProfilingLevel level;
  final bool enableMemoryProfiling;
  final bool enableCpuProfiling;
  final bool enableNetworkProfiling;
  final Duration maxDuration;
  final int maxDepth;
  final bool autoStart;
  final bool autoStop;

  const ProfilingConfig({
    this.level = ProfilingLevel.basic,
    this.enableMemoryProfiling = true,
    this.enableCpuProfiling = true,
    this.enableNetworkProfiling = true,
    this.maxDuration = const Duration(minutes: 5),
    this.maxDepth = 10,
    this.autoStart = false,
    this.autoStop = true,
  });

  @override
  List<Object?> get props => [
        level,
        enableMemoryProfiling,
        enableCpuProfiling,
        enableNetworkProfiling,
        maxDuration,
        maxDepth,
        autoStart,
        autoStop
      ];
}

/// Сервис для профилирования производительности
class PerformanceProfilerService {
  static final PerformanceProfilerService _instance = PerformanceProfilerService._internal();

  final Map<String, ProfilingPoint> _activePoints = {};
  final List<ProfilingReport> _reports = [];
  final Uuid _uuid = const Uuid();
  ProfilingConfig _config = const ProfilingConfig();
  bool _isProfiling = false;
  DateTime? _profilingStartTime;

  factory PerformanceProfilerService() => _instance;

  PerformanceProfilerService._internal();

  /// Начало профилирования
  void startProfiling({String? name, ProfilingConfig? config}) {
    if (_isProfiling) {
      print('Profiling is already active');
      return;
    }

    if (config != null) {
      _config = config;
    }

    _isProfiling = true;
    _profilingStartTime = DateTime.now();
    _activePoints.clear();

    print('Profiling started: ${name ?? 'Default'}');
  }

  /// Остановка профилирования
  ProfilingReport stopProfiling({String? name}) {
    if (!_isProfiling) {
      throw StateError('Profiling is not active');
    }

    final endTime = DateTime.now();
    final totalDuration = _profilingStartTime != null ? endTime.difference(_profilingStartTime!) : Duration.zero;

    // Завершаем все активные точки
    for (final point in _activePoints.values) {
      if (point.endTime == null) {
        endPoint(point.id);
      }
    }

    // Создаем отчет
    final report = ProfilingReport(
      id: _uuid.v4(),
      name: name ?? 'Profiling Report',
      startTime: _profilingStartTime ?? endTime,
      endTime: endTime,
      totalDuration: totalDuration,
      rootPoints: _getRootPoints(),
      summary: _generateSummary(),
      level: _config.level,
    );

    _reports.add(report);
    _isProfiling = false;
    _profilingStartTime = null;

    print('Profiling stopped. Report ID: ${report.id}');
    return report;
  }

  /// Начало точки профилирования
  String startPoint({
    required String name,
    required ProfilingType type,
    Map<String, dynamic>? metadata,
    String? parentId,
  }) {
    if (!_isProfiling) {
      throw StateError('Profiling is not active');
    }

    final pointId = _uuid.v4();
    final point = ProfilingPoint(
      id: pointId,
      name: name,
      type: type,
      startTime: DateTime.now(),
      metadata: metadata,
      parentId: parentId,
    );

    _activePoints[pointId] = point;

    // Проверяем максимальную глубину
    if (_getPointDepth(pointId) > _config.maxDepth) {
      print('Warning: Profiling point depth exceeded maximum depth of ${_config.maxDepth}');
    }

    return pointId;
  }

  /// Завершение точки профилирования
  void endPoint(String pointId, {Map<String, dynamic>? additionalMetadata}) {
    final point = _activePoints[pointId];
    if (point == null) {
      print('Warning: Profiling point $pointId not found');
      return;
    }

    final endTime = DateTime.now();
    final duration = endTime.difference(point.startTime);

    final updatedPoint = point.copyWith(
      endTime: endTime,
      duration: duration,
      metadata: {
        ...?point.metadata,
        ...?additionalMetadata,
      },
    );

    _activePoints[pointId] = updatedPoint;

    // Если это корневая точка, завершаем её
    if (point.parentId == null) {
      _finalizePoint(pointId);
    }
  }

  /// Финализация точки профилирования
  void _finalizePoint(String pointId) {
    final point = _activePoints[pointId];
    if (point == null) return;

    // Собираем дочерние точки
    final children = _activePoints.values.where((p) => p.parentId == pointId).toList();

    final finalizedPoint = point.copyWith(children: children);
    _activePoints[pointId] = finalizedPoint;

    // Удаляем дочерние точки из активных
    for (final child in children) {
      _activePoints.remove(child.id);
    }
  }

  /// Получение корневых точек
  List<ProfilingPoint> _getRootPoints() {
    return _activePoints.values.where((point) => point.parentId == null).toList();
  }

  /// Получение глубины точки
  int _getPointDepth(String pointId) {
    int depth = 0;
    String? currentId = pointId;

    while (currentId != null) {
      final point = _activePoints[currentId];
      if (point == null) break;

      currentId = point.parentId;
      depth++;
    }

    return depth;
  }

  /// Генерация сводки профилирования
  Map<String, dynamic> _generateSummary() {
    final allPoints = _activePoints.values.toList();
    final completedPoints = allPoints.where((p) => p.endTime != null).toList();

    if (completedPoints.isEmpty) {
      return {
        'totalPoints': allPoints.length,
        'completedPoints': 0,
        'activePoints': allPoints.length,
        'averageDuration': 0,
        'maxDuration': 0,
        'minDuration': 0,
      };
    }

    final durations = completedPoints.map((p) => p.duration?.inMicroseconds ?? 0).toList()..sort();

    final totalDuration = durations.reduce((a, b) => a + b);
    final averageDuration = totalDuration / durations.length;
    final maxDuration = durations.last;
    final minDuration = durations.first;

    // Группировка по типам
    final pointsByType = <ProfilingType, List<ProfilingPoint>>{};
    for (final point in completedPoints) {
      pointsByType[point.type] = (pointsByType[point.type] ?? [])..add(point);
    }

    // Группировка по именам
    final pointsByName = <String, List<ProfilingPoint>>{};
    for (final point in completedPoints) {
      pointsByName[point.name] = (pointsByName[point.name] ?? [])..add(point);
    }

    return {
      'totalPoints': allPoints.length,
      'completedPoints': completedPoints.length,
      'activePoints': allPoints.length - completedPoints.length,
      'averageDuration': averageDuration,
      'maxDuration': maxDuration,
      'minDuration': minDuration,
      'pointsByType': pointsByType.map((type, points) => MapEntry(
            type.name,
            {
              'count': points.length,
              'totalDuration': points.map((p) => p.duration?.inMicroseconds ?? 0).reduce((a, b) => a + b),
              'averageDuration':
                  points.map((p) => p.duration?.inMicroseconds ?? 0).reduce((a, b) => a + b) / points.length,
            },
          )),
      'pointsByName': pointsByName.map((name, points) => MapEntry(
            name,
            {
              'count': points.length,
              'totalDuration': points.map((p) => p.duration?.inMicroseconds ?? 0).reduce((a, b) => a + b),
              'averageDuration':
                  points.map((p) => p.duration?.inMicroseconds ?? 0).reduce((a, b) => a + b) / points.length,
            },
          )),
    };
  }

  /// Профилирование функции
  Future<T> profileFunction<T>(
    String name,
    Future<T> Function() function, {
    Map<String, dynamic>? metadata,
    String? parentId,
  }) async {
    final pointId = startPoint(
      name: name,
      type: ProfilingType.function,
      metadata: metadata,
      parentId: parentId,
    );

    try {
      final result = await function();
      endPoint(pointId);
      return result;
    } catch (e) {
      endPoint(pointId, additionalMetadata: {'error': e.toString()});
      rethrow;
    }
  }

  /// Профилирование синхронной функции
  T profileSyncFunction<T>(
    String name,
    T Function() function, {
    Map<String, dynamic>? metadata,
    String? parentId,
  }) {
    final pointId = startPoint(
      name: name,
      type: ProfilingType.function,
      metadata: metadata,
      parentId: parentId,
    );

    try {
      final result = function();
      endPoint(pointId);
      return result;
    } catch (e) {
      endPoint(pointId, additionalMetadata: {'error': e.toString()});
      rethrow;
    }
  }

  /// Профилирование API запроса
  Future<T> profileApiRequest<T>(
    String endpoint,
    Future<T> Function() request, {
    Map<String, dynamic>? metadata,
    String? parentId,
  }) async {
    final pointId = startPoint(
      name: 'API: $endpoint',
      type: ProfilingType.api,
      metadata: {
        'endpoint': endpoint,
        ...?metadata,
      },
      parentId: parentId,
    );

    try {
      final result = await request();
      endPoint(pointId);
      return result;
    } catch (e) {
      endPoint(pointId, additionalMetadata: {'error': e.toString()});
      rethrow;
    }
  }

  /// Профилирование запроса к базе данных
  Future<T> profileDatabaseQuery<T>(
    String query,
    Future<T> Function() queryFunction, {
    Map<String, dynamic>? metadata,
    String? parentId,
  }) async {
    final pointId = startPoint(
      name: 'DB Query',
      type: ProfilingType.database,
      metadata: {
        'query': query,
        ...?metadata,
      },
      parentId: parentId,
    );

    try {
      final result = await queryFunction();
      endPoint(pointId);
      return result;
    } catch (e) {
      endPoint(pointId, additionalMetadata: {'error': e.toString()});
      rethrow;
    }
  }

  /// Получение активных точек профилирования
  List<ProfilingPoint> getActivePoints() {
    return _activePoints.values.toList();
  }

  /// Получение всех отчетов
  List<ProfilingReport> getAllReports() {
    return List<ProfilingReport>.from(_reports);
  }

  /// Получение отчета по ID
  ProfilingReport? getReportById(String id) {
    try {
      return _reports.firstWhere((report) => report.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Получение последнего отчета
  ProfilingReport? getLastReport() {
    if (_reports.isEmpty) return null;
    return _reports.last;
  }

  /// Очистка всех отчетов
  void clearReports() {
    _reports.clear();
  }

  /// Очистка старых отчетов
  void clearOldReports({Duration? olderThan}) {
    final cutoff = olderThan ?? const Duration(days: 7);
    final cutoffTime = DateTime.now().subtract(cutoff);

    _reports.removeWhere((report) => report.endTime.isBefore(cutoffTime));
  }

  /// Проверка активности профилирования
  bool get isProfiling => _isProfiling;

  /// Получение конфигурации
  ProfilingConfig get config => _config;

  /// Обновление конфигурации
  void updateConfig(ProfilingConfig newConfig) {
    _config = newConfig;
  }

  /// Экспорт отчета в JSON
  Map<String, dynamic> exportReportToJson(String reportId) {
    final report = getReportById(reportId);
    if (report == null) {
      throw ArgumentError('Report with ID $reportId not found');
    }

    return {
      'id': report.id,
      'name': report.name,
      'startTime': report.startTime.toIso8601String(),
      'endTime': report.endTime.toIso8601String(),
      'totalDuration': report.totalDuration.inMicroseconds,
      'level': report.level.name,
      'summary': report.summary,
      'rootPoints': _exportPointsToJson(report.rootPoints),
    };
  }

  /// Экспорт точек в JSON
  List<Map<String, dynamic>> _exportPointsToJson(List<ProfilingPoint> points) {
    return points
        .map((point) => {
              'id': point.id,
              'name': point.name,
              'type': point.type.name,
              'startTime': point.startTime.toIso8601String(),
              'endTime': point.endTime?.toIso8601String(),
              'duration': point.duration?.inMicroseconds,
              'metadata': point.metadata,
              'parentId': point.parentId,
              'children': point.children != null ? _exportPointsToJson(point.children!) : null,
            })
        .toList();
  }

  /// Остановка сервиса
  void dispose() {
    if (_isProfiling) {
      stopProfiling();
    }
    _activePoints.clear();
    _reports.clear();
  }
}
