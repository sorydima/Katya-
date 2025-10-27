import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// Перечисление типов метрик производительности
enum MetricType {
  cpu,
  memory,
  disk,
  network,
  database,
  api,
  cache,
  custom,
}

/// Перечисление единиц измерения метрик
enum MetricUnit {
  percentage,
  bytes,
  milliseconds,
  count,
  requestsPerSecond,
  custom,
}

/// Модель метрики производительности
class PerformanceMetric extends Equatable {
  final String id;
  final String name;
  final MetricType type;
  final double value;
  final MetricUnit unit;
  final DateTime timestamp;
  final Map<String, dynamic>? tags;
  final String? description;

  const PerformanceMetric({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    required this.unit,
    required this.timestamp,
    this.tags,
    this.description,
  });

  @override
  List<Object?> get props => [id, name, type, value, unit, timestamp, tags, description];
}

/// Модель агрегированной метрики
class AggregatedMetric extends Equatable {
  final String name;
  final MetricType type;
  final double min;
  final double max;
  final double average;
  final double median;
  final double p95;
  final double p99;
  final int count;
  final DateTime startTime;
  final DateTime endTime;
  final MetricUnit unit;

  const AggregatedMetric({
    required this.name,
    required this.type,
    required this.min,
    required this.max,
    required this.average,
    required this.median,
    required this.p95,
    required this.p99,
    required this.count,
    required this.startTime,
    required this.endTime,
    required this.unit,
  });

  @override
  List<Object?> get props => [name, type, min, max, average, median, p95, p99, count, startTime, endTime, unit];
}

/// Модель конфигурации метрики
class MetricConfig extends Equatable {
  final String name;
  final MetricType type;
  final MetricUnit unit;
  final Duration collectionInterval;
  final Duration retentionPeriod;
  final bool enabled;
  final Map<String, dynamic>? tags;
  final String? description;

  const MetricConfig({
    required this.name,
    required this.type,
    required this.unit,
    required this.collectionInterval,
    required this.retentionPeriod,
    this.enabled = true,
    this.tags,
    this.description,
  });

  @override
  List<Object?> get props => [name, type, unit, collectionInterval, retentionPeriod, enabled, tags, description];
}

/// Сервис для сбора и управления метриками производительности
class PerformanceMetricsService {
  static final PerformanceMetricsService _instance = PerformanceMetricsService._internal();

  final List<PerformanceMetric> _metrics = [];
  final Map<String, MetricConfig> _configs = {};
  final Map<String, Timer> _timers = {};
  final Uuid _uuid = const Uuid();
  final Random _random = Random();

  factory PerformanceMetricsService() => _instance;

  PerformanceMetricsService._internal() {
    _initializeDefaultMetrics();
  }

  /// Инициализация сервиса с настройками по умолчанию
  void _initializeDefaultMetrics() {
    _configs['cpu_usage'] = const MetricConfig(
      name: 'CPU Usage',
      type: MetricType.cpu,
      unit: MetricUnit.percentage,
      collectionInterval: Duration(seconds: 5),
      retentionPeriod: Duration(hours: 24),
      description: 'CPU usage percentage',
    );

    _configs['memory_usage'] = const MetricConfig(
      name: 'Memory Usage',
      type: MetricType.memory,
      unit: MetricUnit.bytes,
      collectionInterval: Duration(seconds: 5),
      retentionPeriod: Duration(hours: 24),
      description: 'Memory usage in bytes',
    );

    _configs['disk_usage'] = const MetricConfig(
      name: 'Disk Usage',
      type: MetricType.disk,
      unit: MetricUnit.bytes,
      collectionInterval: Duration(minutes: 1),
      retentionPeriod: Duration(days: 7),
      description: 'Disk usage in bytes',
    );

    _configs['network_throughput'] = const MetricConfig(
      name: 'Network Throughput',
      type: MetricType.network,
      unit: MetricUnit.bytes,
      collectionInterval: Duration(seconds: 10),
      retentionPeriod: Duration(hours: 12),
      description: 'Network throughput in bytes per second',
    );

    _configs['api_response_time'] = const MetricConfig(
      name: 'API Response Time',
      type: MetricType.api,
      unit: MetricUnit.milliseconds,
      collectionInterval: Duration(seconds: 1),
      retentionPeriod: Duration(hours: 6),
      description: 'API response time in milliseconds',
    );

    _configs['database_query_time'] = const MetricConfig(
      name: 'Database Query Time',
      type: MetricType.database,
      unit: MetricUnit.milliseconds,
      collectionInterval: Duration(seconds: 1),
      retentionPeriod: Duration(hours: 6),
      description: 'Database query execution time in milliseconds',
    );

    _configs['cache_hit_rate'] = const MetricConfig(
      name: 'Cache Hit Rate',
      type: MetricType.cache,
      unit: MetricUnit.percentage,
      collectionInterval: Duration(seconds: 30),
      retentionPeriod: Duration(hours: 12),
      description: 'Cache hit rate percentage',
    );

    _startMetricCollection();
  }

  /// Запуск сбора метрик
  void _startMetricCollection() {
    for (final config in _configs.values) {
      if (config.enabled) {
        _startCollectingMetric(config);
      }
    }
  }

  /// Запуск сбора конкретной метрики
  void _startCollectingMetric(MetricConfig config) {
    _timers[config.name] = Timer.periodic(config.collectionInterval, (_) {
      _collectMetric(config);
    });
  }

  /// Сбор метрики
  void _collectMetric(MetricConfig config) {
    try {
      final double value = _getMetricValue(config);
      final metric = PerformanceMetric(
        id: _uuid.v4(),
        name: config.name,
        type: config.type,
        value: value,
        unit: config.unit,
        timestamp: DateTime.now(),
        tags: config.tags,
        description: config.description,
      );

      _metrics.add(metric);
      _cleanupOldMetrics();
    } catch (e) {
      print('Error collecting metric ${config.name}: $e');
    }
  }

  /// Получение значения метрики (симуляция)
  double _getMetricValue(MetricConfig config) {
    switch (config.type) {
      case MetricType.cpu:
        return _getCpuUsage();
      case MetricType.memory:
        return _getMemoryUsage();
      case MetricType.disk:
        return _getDiskUsage();
      case MetricType.network:
        return _getNetworkThroughput();
      case MetricType.api:
        return _getApiResponseTime();
      case MetricType.database:
        return _getDatabaseQueryTime();
      case MetricType.cache:
        return _getCacheHitRate();
      case MetricType.custom:
        return _random.nextDouble() * 100;
    }
  }

  /// Получение использования CPU (симуляция)
  double _getCpuUsage() {
    // В реальном приложении здесь будет системный вызов
    return 20 + _random.nextDouble() * 60; // 20-80%
  }

  /// Получение использования памяти (симуляция)
  double _getMemoryUsage() {
    // В реальном приложении здесь будет системный вызов
    return 1024 * 1024 * 1024 * (0.3 + _random.nextDouble() * 0.4); // 0.3-0.7 GB
  }

  /// Получение использования диска (симуляция)
  double _getDiskUsage() {
    // В реальном приложении здесь будет системный вызов
    return 1024 * 1024 * 1024 * 1024 * (0.1 + _random.nextDouble() * 0.3); // 0.1-0.4 TB
  }

  /// Получение пропускной способности сети (симуляция)
  double _getNetworkThroughput() {
    // В реальном приложении здесь будет системный вызов
    return 1024 * 1024 * (0.1 + _random.nextDouble() * 0.9); // 0.1-1 MB/s
  }

  /// Получение времени ответа API (симуляция)
  double _getApiResponseTime() {
    // В реальном приложении здесь будет измерение реальных запросов
    return 50 + _random.nextDouble() * 200; // 50-250 ms
  }

  /// Получение времени выполнения запроса к БД (симуляция)
  double _getDatabaseQueryTime() {
    // В реальном приложении здесь будет измерение реальных запросов
    return 10 + _random.nextDouble() * 100; // 10-110 ms
  }

  /// Получение процента попаданий в кэш (симуляция)
  double _getCacheHitRate() {
    // В реальном приложении здесь будет реальная статистика кэша
    return 70 + _random.nextDouble() * 25; // 70-95%
  }

  /// Очистка старых метрик
  void _cleanupOldMetrics() {
    final now = DateTime.now();
    _metrics.removeWhere((metric) {
      final config = _configs[metric.name];
      if (config == null) return true;

      final age = now.difference(metric.timestamp);
      return age > config.retentionPeriod;
    });
  }

  /// Добавление пользовательской метрики
  void addCustomMetric({
    required String name,
    required double value,
    required MetricUnit unit,
    Map<String, dynamic>? tags,
    String? description,
  }) {
    final metric = PerformanceMetric(
      id: _uuid.v4(),
      name: name,
      type: MetricType.custom,
      value: value,
      unit: unit,
      timestamp: DateTime.now(),
      tags: tags,
      description: description,
    );

    _metrics.add(metric);
  }

  /// Получение метрик по имени
  List<PerformanceMetric> getMetricsByName(String name) {
    return _metrics.where((metric) => metric.name == name).toList();
  }

  /// Получение метрик по типу
  List<PerformanceMetric> getMetricsByType(MetricType type) {
    return _metrics.where((metric) => metric.type == type).toList();
  }

  /// Получение метрик за период
  List<PerformanceMetric> getMetricsInRange({
    required DateTime startTime,
    required DateTime endTime,
    String? name,
    MetricType? type,
  }) {
    return _metrics.where((metric) {
      if (metric.timestamp.isBefore(startTime) || metric.timestamp.isAfter(endTime)) {
        return false;
      }
      if (name != null && metric.name != name) {
        return false;
      }
      if (type != null && metric.type != type) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Получение агрегированных метрик
  List<AggregatedMetric> getAggregatedMetrics({
    required String name,
    required Duration interval,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    final now = DateTime.now();
    final start = startTime ?? now.subtract(const Duration(hours: 1));
    final end = endTime ?? now;

    final metrics = getMetricsInRange(startTime: start, endTime: end, name: name);
    if (metrics.isEmpty) return [];

    final List<AggregatedMetric> aggregated = [];
    final sortedMetrics = List<PerformanceMetric>.from(metrics)..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    DateTime currentStart = start;
    while (currentStart.isBefore(end)) {
      final currentEnd = currentStart.add(interval);
      final intervalMetrics = sortedMetrics.where((metric) {
        return metric.timestamp.isAfter(currentStart) && metric.timestamp.isBefore(currentEnd);
      }).toList();

      if (intervalMetrics.isNotEmpty) {
        final values = intervalMetrics.map((m) => m.value).toList()..sort();
        final count = values.length;
        final min = values.first;
        final max = values.last;
        final average = values.reduce((a, b) => a + b) / count;
        final median = count % 2 == 0 ? (values[count ~/ 2 - 1] + values[count ~/ 2]) / 2 : values[count ~/ 2];
        final p95Index = (count * 0.95).floor();
        final p99Index = (count * 0.99).floor();
        final p95 = values[p95Index < count ? p95Index : count - 1];
        final p99 = values[p99Index < count ? p99Index : count - 1];

        aggregated.add(AggregatedMetric(
          name: name,
          type: intervalMetrics.first.type,
          min: min,
          max: max,
          average: average,
          median: median,
          p95: p95,
          p99: p99,
          count: count,
          startTime: currentStart,
          endTime: currentEnd,
          unit: intervalMetrics.first.unit,
        ));
      }

      currentStart = currentEnd;
    }

    return aggregated;
  }

  /// Получение всех доступных метрик
  List<PerformanceMetric> getAllMetrics() {
    return List<PerformanceMetric>.from(_metrics);
  }

  /// Получение конфигураций метрик
  Map<String, MetricConfig> getMetricConfigs() {
    return Map<String, MetricConfig>.from(_configs);
  }

  /// Обновление конфигурации метрики
  void updateMetricConfig(String name, MetricConfig config) {
    _configs[name] = config;

    // Перезапуск сбора метрики, если она была изменена
    _timers[name]?.cancel();
    if (config.enabled) {
      _startCollectingMetric(config);
    }
  }

  /// Включение/выключение сбора метрики
  void toggleMetricCollection(String name, bool enabled) {
    final config = _configs[name];
    if (config == null) return;

    final updatedConfig = MetricConfig(
      name: config.name,
      type: config.type,
      unit: config.unit,
      collectionInterval: config.collectionInterval,
      retentionPeriod: config.retentionPeriod,
      enabled: enabled,
      tags: config.tags,
      description: config.description,
    );

    updateMetricConfig(name, updatedConfig);
  }

  /// Очистка всех метрик
  void clearAllMetrics() {
    _metrics.clear();
  }

  /// Очистка метрик по имени
  void clearMetricsByName(String name) {
    _metrics.removeWhere((metric) => metric.name == name);
  }

  /// Получение статистики по метрикам
  Map<String, dynamic> getMetricsStatistics() {
    final totalMetrics = _metrics.length;
    final metricsByType = <MetricType, int>{};
    final metricsByName = <String, int>{};

    for (final metric in _metrics) {
      metricsByType[metric.type] = (metricsByType[metric.type] ?? 0) + 1;
      metricsByName[metric.name] = (metricsByName[metric.name] ?? 0) + 1;
    }

    return {
      'totalMetrics': totalMetrics,
      'metricsByType': metricsByType,
      'metricsByName': metricsByName,
      'oldestMetric':
          _metrics.isNotEmpty ? _metrics.map((m) => m.timestamp).reduce((a, b) => a.isBefore(b) ? a : b) : null,
      'newestMetric':
          _metrics.isNotEmpty ? _metrics.map((m) => m.timestamp).reduce((a, b) => a.isAfter(b) ? a : b) : null,
    };
  }

  /// Остановка сервиса
  void dispose() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _metrics.clear();
    _configs.clear();
  }
}
