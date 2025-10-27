import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';

/// Сервис для детальной аналитики производительности
class PerformanceAnalyticsService {
  static final PerformanceAnalyticsService _instance = PerformanceAnalyticsService._internal();

  factory PerformanceAnalyticsService() => _instance;

  PerformanceAnalyticsService._internal() {
    _initializeMetrics();
  }

  final Map<String, PerformanceMetric> _metrics = {};
  final Map<String, List<PerformanceDataPoint>> _timeSeriesData = {};
  final Map<String, PerformanceProfile> _profiles = {};
  final List<PerformanceAlert> _alerts = [];
  final StreamController<PerformanceEvent> _eventController = StreamController<PerformanceEvent>.broadcast();

  Timer? _collectionTimer;
  Timer? _analysisTimer;
  bool _isCollecting = false;

  /// Поток событий производительности
  Stream<PerformanceEvent> get events => _eventController.stream;

  /// Инициализация метрик
  void _initializeMetrics() {
    // Системные метрики
    _registerMetric('cpu_usage', 'CPU Usage', '%', MetricType.gauge, 0, 100);
    _registerMetric('memory_usage', 'Memory Usage', '%', MetricType.gauge, 0, 100);
    _registerMetric('disk_usage', 'Disk Usage', '%', MetricType.gauge, 0, 100);
    _registerMetric('network_io', 'Network I/O', 'bytes/s', MetricType.counter, 0, double.infinity);
    _registerMetric('disk_io', 'Disk I/O', 'bytes/s', MetricType.counter, 0, double.infinity);

    // Метрики приложения
    _registerMetric('request_count', 'Request Count', 'requests/s', MetricType.counter, 0, double.infinity);
    _registerMetric('response_time', 'Response Time', 'ms', MetricType.histogram, 0, 10000);
    _registerMetric('error_rate', 'Error Rate', '%', MetricType.gauge, 0, 100);
    _registerMetric('active_connections', 'Active Connections', 'connections', MetricType.gauge, 0, 10000);
    _registerMetric('queue_length', 'Queue Length', 'items', MetricType.gauge, 0, 10000);

    // Метрики базы данных
    _registerMetric('db_connections', 'Database Connections', 'connections', MetricType.gauge, 0, 100);
    _registerMetric('db_query_time', 'Database Query Time', 'ms', MetricType.histogram, 0, 5000);
    _registerMetric(
        'db_transaction_rate', 'Transaction Rate', 'transactions/s', MetricType.counter, 0, double.infinity);
    _registerMetric('db_cache_hit_rate', 'Cache Hit Rate', '%', MetricType.gauge, 0, 100);

    // Метрики кэша
    _registerMetric('cache_hit_rate', 'Cache Hit Rate', '%', MetricType.gauge, 0, 100);
    _registerMetric('cache_memory_usage', 'Cache Memory Usage', 'MB', MetricType.gauge, 0, 1000);
    _registerMetric(
        'cache_eviction_rate', 'Cache Eviction Rate', 'evictions/s', MetricType.counter, 0, double.infinity);

    // Метрики безопасности
    _registerMetric('security_events', 'Security Events', 'events/s', MetricType.counter, 0, double.infinity);
    _registerMetric('failed_logins', 'Failed Logins', 'attempts/s', MetricType.counter, 0, double.infinity);
    _registerMetric('blocked_requests', 'Blocked Requests', 'requests/s', MetricType.counter, 0, double.infinity);
  }

  /// Регистрация метрики
  void _registerMetric(String id, String name, String unit, MetricType type, double min, double max) {
    _metrics[id] = PerformanceMetric(
      id: id,
      name: name,
      unit: unit,
      type: type,
      minValue: min,
      maxValue: max,
      currentValue: 0,
      lastUpdated: DateTime.now(),
    );
    _timeSeriesData[id] = [];
  }

  /// Запуск сбора метрик
  Future<void> startCollection({Duration interval = const Duration(seconds: 5)}) async {
    if (_isCollecting) return;

    _isCollecting = true;
    _collectionTimer = Timer.periodic(interval, (_) => _collectMetrics());
    _analysisTimer = Timer.periodic(const Duration(minutes: 1), (_) => _analyzeMetrics());

    _emitEvent(const PerformanceEvent.collectionStarted());
    print('Performance analytics collection started');
  }

  /// Остановка сбора метрик
  Future<void> stopCollection() async {
    _isCollecting = false;
    _collectionTimer?.cancel();
    _analysisTimer?.cancel();
    _collectionTimer = null;
    _analysisTimer = null;

    _emitEvent(const PerformanceEvent.collectionStopped());
    print('Performance analytics collection stopped');
  }

  /// Сбор метрик
  Future<void> _collectMetrics() async {
    try {
      // Сбор системных метрик
      await _collectSystemMetrics();

      // Сбор метрик приложения
      await _collectApplicationMetrics();

      // Сбор метрик базы данных
      await _collectDatabaseMetrics();

      // Сбор метрик кэша
      await _collectCacheMetrics();

      // Сбор метрик безопасности
      await _collectSecurityMetrics();

      _emitEvent(PerformanceEvent.metricsCollected(_metrics.values.toList()));
    } catch (e) {
      _emitEvent(PerformanceEvent.collectionError(e.toString()));
    }
  }

  /// Сбор системных метрик
  Future<void> _collectSystemMetrics() async {
    // CPU Usage (упрощенная реализация)
    final double cpuUsage = await _getCpuUsage();
    _updateMetric('cpu_usage', cpuUsage);

    // Memory Usage
    final double memoryUsage = await _getMemoryUsage();
    _updateMetric('memory_usage', memoryUsage);

    // Disk Usage
    final double diskUsage = await _getDiskUsage();
    _updateMetric('disk_usage', diskUsage);

    // Network I/O
    final double networkIo = await _getNetworkIo();
    _updateMetric('network_io', networkIo);

    // Disk I/O
    final double diskIo = await _getDiskIo();
    _updateMetric('disk_io', diskIo);
  }

  /// Сбор метрик приложения
  Future<void> _collectApplicationMetrics() async {
    // Request Count (симуляция)
    final double requestCount = _generateRandomValue(100, 1000);
    _updateMetric('request_count', requestCount);

    // Response Time
    final double responseTime = _generateRandomValue(50, 500);
    _updateMetric('response_time', responseTime);

    // Error Rate
    final double errorRate = _generateRandomValue(0, 5);
    _updateMetric('error_rate', errorRate);

    // Active Connections
    final double activeConnections = _generateRandomValue(10, 100);
    _updateMetric('active_connections', activeConnections);

    // Queue Length
    final double queueLength = _generateRandomValue(0, 50);
    _updateMetric('queue_length', queueLength);
  }

  /// Сбор метрик базы данных
  Future<void> _collectDatabaseMetrics() async {
    // Database Connections
    final double dbConnections = _generateRandomValue(5, 20);
    _updateMetric('db_connections', dbConnections);

    // Database Query Time
    final double dbQueryTime = _generateRandomValue(10, 200);
    _updateMetric('db_query_time', dbQueryTime);

    // Transaction Rate
    final double transactionRate = _generateRandomValue(50, 500);
    _updateMetric('db_transaction_rate', transactionRate);

    // Cache Hit Rate
    final double cacheHitRate = _generateRandomValue(80, 99);
    _updateMetric('db_cache_hit_rate', cacheHitRate);
  }

  /// Сбор метрик кэша
  Future<void> _collectCacheMetrics() async {
    // Cache Hit Rate
    final double cacheHitRate = _generateRandomValue(85, 98);
    _updateMetric('cache_hit_rate', cacheHitRate);

    // Cache Memory Usage
    final double cacheMemoryUsage = _generateRandomValue(100, 800);
    _updateMetric('cache_memory_usage', cacheMemoryUsage);

    // Cache Eviction Rate
    final double evictionRate = _generateRandomValue(0, 10);
    _updateMetric('cache_eviction_rate', evictionRate);
  }

  /// Сбор метрик безопасности
  Future<void> _collectSecurityMetrics() async {
    // Security Events
    final double securityEvents = _generateRandomValue(0, 5);
    _updateMetric('security_events', securityEvents);

    // Failed Logins
    final double failedLogins = _generateRandomValue(0, 3);
    _updateMetric('failed_logins', failedLogins);

    // Blocked Requests
    final double blockedRequests = _generateRandomValue(0, 10);
    _updateMetric('blocked_requests', blockedRequests);
  }

  /// Обновление метрики
  void _updateMetric(String metricId, double value) {
    final PerformanceMetric? metric = _metrics[metricId];
    if (metric == null) return;

    final DateTime now = DateTime.now();
    final PerformanceMetric updatedMetric = PerformanceMetric(
      id: metric.id,
      name: metric.name,
      unit: metric.unit,
      type: metric.type,
      minValue: metric.minValue,
      maxValue: metric.maxValue,
      currentValue: value,
      lastUpdated: now,
    );

    _metrics[metricId] = updatedMetric;

    // Добавление точки данных в временной ряд
    final PerformanceDataPoint dataPoint = PerformanceDataPoint(
      timestamp: now,
      value: value,
      metricId: metricId,
    );

    _timeSeriesData[metricId]?.add(dataPoint);

    // Ограничение размера временного ряда (последние 1000 точек)
    if (_timeSeriesData[metricId]!.length > 1000) {
      _timeSeriesData[metricId]!.removeAt(0);
    }
  }

  /// Анализ метрик
  Future<void> _analyzeMetrics() async {
    try {
      // Анализ трендов
      final Map<String, PerformanceTrend> trends = _analyzeTrends();

      // Анализ аномалий
      final List<PerformanceAnomaly> anomalies = _detectAnomalies();

      // Генерация профилей производительности
      final List<PerformanceProfile> profiles = _generateProfiles();

      // Проверка пороговых значений
      final List<PerformanceAlert> newAlerts = _checkThresholds();

      _emitEvent(PerformanceEvent.analysisCompleted(
        trends: trends,
        anomalies: anomalies,
        profiles: profiles,
        alerts: newAlerts,
      ));
    } catch (e) {
      _emitEvent(PerformanceEvent.analysisError(e.toString()));
    }
  }

  /// Анализ трендов
  Map<String, PerformanceTrend> _analyzeTrends() {
    final Map<String, PerformanceTrend> trends = {};

    for (final String metricId in _timeSeriesData.keys) {
      final List<PerformanceDataPoint> dataPoints = _timeSeriesData[metricId]!;
      if (dataPoints.length < 10) continue;

      // Простой анализ тренда (линейная регрессия)
      final PerformanceTrend trend = _calculateTrend(dataPoints);
      trends[metricId] = trend;
    }

    return trends;
  }

  /// Расчет тренда
  PerformanceTrend _calculateTrend(List<PerformanceDataPoint> dataPoints) {
    if (dataPoints.length < 2) {
      return PerformanceTrend(
        metricId: dataPoints.isNotEmpty ? dataPoints.first.metricId : '',
        direction: TrendDirection.stable,
        slope: 0,
        confidence: 0,
        changePercent: 0,
      );
    }

    final int n = dataPoints.length;
    double sumX = 0;
    double sumY = 0;
    double sumXY = 0;
    double sumXX = 0;

    for (int i = 0; i < n; i++) {
      final double x = i.toDouble();
      final double y = dataPoints[i].value;
      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumXX += x * x;
    }

    final double slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
    final double intercept = (sumY - slope * sumX) / n;

    // Определение направления тренда
    TrendDirection direction;
    if (slope > 0.1) {
      direction = TrendDirection.increasing;
    } else if (slope < -0.1) {
      direction = TrendDirection.decreasing;
    } else {
      direction = TrendDirection.stable;
    }

    // Расчет процента изменения
    final double firstValue = dataPoints.first.value;
    final double lastValue = dataPoints.last.value;
    final double changePercent = firstValue != 0 ? ((lastValue - firstValue) / firstValue) * 100 : 0;

    // Упрощенная оценка уверенности
    final double confidence = min(1.0, dataPoints.length / 100.0);

    return PerformanceTrend(
      metricId: dataPoints.first.metricId,
      direction: direction,
      slope: slope,
      confidence: confidence,
      changePercent: changePercent,
    );
  }

  /// Обнаружение аномалий
  List<PerformanceAnomaly> _detectAnomalies() {
    final List<PerformanceAnomaly> anomalies = [];

    for (final String metricId in _timeSeriesData.keys) {
      final List<PerformanceDataPoint> dataPoints = _timeSeriesData[metricId]!;
      if (dataPoints.length < 20) continue;

      // Простое обнаружение аномалий на основе стандартного отклонения
      final List<PerformanceAnomaly> metricAnomalies = _detectMetricAnomalies(metricId, dataPoints);
      anomalies.addAll(metricAnomalies);
    }

    return anomalies;
  }

  /// Обнаружение аномалий для метрики
  List<PerformanceAnomaly> _detectMetricAnomalies(String metricId, List<PerformanceDataPoint> dataPoints) {
    final List<PerformanceAnomaly> anomalies = [];

    // Расчет среднего и стандартного отклонения
    final double mean = dataPoints.map((p) => p.value).reduce((a, b) => a + b) / dataPoints.length;
    final double variance = dataPoints.map((p) => pow(p.value - mean, 2)).reduce((a, b) => a + b) / dataPoints.length;
    final double stdDev = sqrt(variance);

    // Обнаружение выбросов (значения за пределами 2 стандартных отклонений)
    for (final PerformanceDataPoint point in dataPoints) {
      if ((point.value - mean).abs() > 2 * stdDev) {
        anomalies.add(PerformanceAnomaly(
          metricId: metricId,
          timestamp: point.timestamp,
          value: point.value,
          expectedValue: mean,
          deviation: (point.value - mean).abs(),
          severity: (point.value - mean).abs() > 3 * stdDev ? AnomalySeverity.high : AnomalySeverity.medium,
        ));
      }
    }

    return anomalies;
  }

  /// Генерация профилей производительности
  List<PerformanceProfile> _generateProfiles() {
    final List<PerformanceProfile> profiles = [];

    // Профиль системы
    final PerformanceProfile systemProfile = _generateSystemProfile();
    profiles.add(systemProfile);

    // Профиль приложения
    final PerformanceProfile appProfile = _generateApplicationProfile();
    profiles.add(appProfile);

    // Профиль базы данных
    final PerformanceProfile dbProfile = _generateDatabaseProfile();
    profiles.add(dbProfile);

    return profiles;
  }

  /// Генерация системного профиля
  PerformanceProfile _generateSystemProfile() {
    final double cpuUsage = _metrics['cpu_usage']?.currentValue ?? 0;
    final double memoryUsage = _metrics['memory_usage']?.currentValue ?? 0;
    final double diskUsage = _metrics['disk_usage']?.currentValue ?? 0;

    PerformanceHealth health;
    if (cpuUsage > 80 || memoryUsage > 85 || diskUsage > 90) {
      health = PerformanceHealth.critical;
    } else if (cpuUsage > 60 || memoryUsage > 70 || diskUsage > 80) {
      health = PerformanceHealth.warning;
    } else {
      health = PerformanceHealth.good;
    }

    return PerformanceProfile(
      id: 'system',
      name: 'System Performance',
      health: health,
      score: _calculateSystemScore(cpuUsage, memoryUsage, diskUsage),
      metrics: const ['cpu_usage', 'memory_usage', 'disk_usage'],
      recommendations: _generateSystemRecommendations(cpuUsage, memoryUsage, diskUsage),
      lastUpdated: DateTime.now(),
    );
  }

  /// Генерация профиля приложения
  PerformanceProfile _generateApplicationProfile() {
    final double responseTime = _metrics['response_time']?.currentValue ?? 0;
    final double errorRate = _metrics['error_rate']?.currentValue ?? 0;
    final double requestCount = _metrics['request_count']?.currentValue ?? 0;

    PerformanceHealth health;
    if (responseTime > 1000 || errorRate > 5) {
      health = PerformanceHealth.critical;
    } else if (responseTime > 500 || errorRate > 2) {
      health = PerformanceHealth.warning;
    } else {
      health = PerformanceHealth.good;
    }

    return PerformanceProfile(
      id: 'application',
      name: 'Application Performance',
      health: health,
      score: _calculateApplicationScore(responseTime, errorRate, requestCount),
      metrics: const ['response_time', 'error_rate', 'request_count'],
      recommendations: _generateApplicationRecommendations(responseTime, errorRate, errorRate),
      lastUpdated: DateTime.now(),
    );
  }

  /// Генерация профиля базы данных
  PerformanceProfile _generateDatabaseProfile() {
    final double queryTime = _metrics['db_query_time']?.currentValue ?? 0;
    final double cacheHitRate = _metrics['db_cache_hit_rate']?.currentValue ?? 0;
    final double connections = _metrics['db_connections']?.currentValue ?? 0;

    PerformanceHealth health;
    if (queryTime > 1000 || cacheHitRate < 70) {
      health = PerformanceHealth.critical;
    } else if (queryTime > 500 || cacheHitRate < 85) {
      health = PerformanceHealth.warning;
    } else {
      health = PerformanceHealth.good;
    }

    return PerformanceProfile(
      id: 'database',
      name: 'Database Performance',
      health: health,
      score: _calculateDatabaseScore(queryTime, cacheHitRate, connections),
      metrics: const ['db_query_time', 'db_cache_hit_rate', 'db_connections'],
      recommendations: _generateDatabaseRecommendations(queryTime, cacheHitRate, connections),
      lastUpdated: DateTime.now(),
    );
  }

  /// Проверка пороговых значений
  List<PerformanceAlert> _checkThresholds() {
    final List<PerformanceAlert> alerts = [];

    for (final PerformanceMetric metric in _metrics.values) {
      final List<PerformanceAlert> metricAlerts = _checkMetricThresholds(metric);
      alerts.addAll(metricAlerts);
    }

    return alerts;
  }

  /// Проверка пороговых значений для метрики
  List<PerformanceAlert> _checkMetricThresholds(PerformanceMetric metric) {
    final List<PerformanceAlert> alerts = [];

    // Критические пороги
    if (metric.currentValue > metric.maxValue * 0.9) {
      alerts.add(PerformanceAlert(
        id: '${metric.id}_critical',
        metricId: metric.id,
        severity: AlertSeverity.critical,
        message: '${metric.name} is critically high: ${metric.currentValue.toStringAsFixed(2)} ${metric.unit}',
        timestamp: DateTime.now(),
        value: metric.currentValue,
        threshold: metric.maxValue * 0.9,
      ));
    }

    // Предупреждения
    if (metric.currentValue > metric.maxValue * 0.7) {
      alerts.add(PerformanceAlert(
        id: '${metric.id}_warning',
        metricId: metric.id,
        severity: AlertSeverity.warning,
        message: '${metric.name} is high: ${metric.currentValue.toStringAsFixed(2)} ${metric.unit}',
        timestamp: DateTime.now(),
        value: metric.currentValue,
        threshold: metric.maxValue * 0.7,
      ));
    }

    return alerts;
  }

  /// Получение метрик
  Map<String, PerformanceMetric> getMetrics() => Map.unmodifiable(_metrics);

  /// Получение временных рядов
  Map<String, List<PerformanceDataPoint>> getTimeSeriesData() => Map.unmodifiable(_timeSeriesData);

  /// Получение профилей
  List<PerformanceProfile> getProfiles() => _profiles.values.toList();

  /// Получение алертов
  List<PerformanceAlert> getAlerts() => List.unmodifiable(_alerts);

  /// Получение статистики производительности
  PerformanceStatistics getStatistics() {
    final int totalMetrics = _metrics.length;
    final int activeAlerts = _alerts.where((a) => a.severity == AlertSeverity.critical).length;
    final double averageScore = _profiles.values.isNotEmpty
        ? _profiles.values.map((p) => p.score).reduce((a, b) => a + b) / _profiles.values.length
        : 0;

    return PerformanceStatistics(
      totalMetrics: totalMetrics,
      activeAlerts: activeAlerts,
      averageScore: averageScore,
      collectionActive: _isCollecting,
      lastUpdate: DateTime.now(),
    );
  }

  /// Вспомогательные методы для сбора системных метрик

  Future<double> _getCpuUsage() async {
    // Упрощенная реализация - в реальном приложении используйте системные API
    return _generateRandomValue(10, 80);
  }

  Future<double> _getMemoryUsage() async {
    // Упрощенная реализация
    return _generateRandomValue(30, 70);
  }

  Future<double> _getDiskUsage() async {
    // Упрощенная реализация
    return _generateRandomValue(20, 60);
  }

  Future<double> _getNetworkIo() async {
    // Упрощенная реализация
    return _generateRandomValue(1000, 10000);
  }

  Future<double> _getDiskIo() async {
    // Упрощенная реализация
    return _generateRandomValue(500, 5000);
  }

  double _generateRandomValue(double min, double max) {
    final Random random = Random();
    return min + random.nextDouble() * (max - min);
  }

  // Методы расчета оценок и рекомендаций

  double _calculateSystemScore(double cpu, double memory, double disk) {
    return 100 - (cpu * 0.4 + memory * 0.4 + disk * 0.2);
  }

  double _calculateApplicationScore(double responseTime, double errorRate, double requestCount) {
    final double responseScore = max(0, 100 - responseTime / 10);
    final double errorScore = max(0, 100 - errorRate * 20);
    return (responseScore + errorScore) / 2;
  }

  double _calculateDatabaseScore(double queryTime, double cacheHitRate, double connections) {
    final double queryScore = max(0, 100 - queryTime / 50);
    final double cacheScore = cacheHitRate;
    return (queryScore + cacheScore) / 2;
  }

  List<String> _generateSystemRecommendations(double cpu, double memory, double disk) {
    final List<String> recommendations = [];
    if (cpu > 70) recommendations.add('Consider CPU optimization or scaling');
    if (memory > 80) recommendations.add('Increase memory allocation or optimize memory usage');
    if (disk > 85) recommendations.add('Clean up disk space or expand storage');
    return recommendations;
  }

  List<String> _generateApplicationRecommendations(double responseTime, double errorRate, double requestCount) {
    final List<String> recommendations = [];
    if (responseTime > 500) recommendations.add('Optimize application performance');
    if (errorRate > 2) recommendations.add('Investigate and fix application errors');
    return recommendations;
  }

  List<String> _generateDatabaseRecommendations(double queryTime, double cacheHitRate, double connections) {
    final List<String> recommendations = [];
    if (queryTime > 500) recommendations.add('Optimize database queries');
    if (cacheHitRate < 85) recommendations.add('Improve database caching strategy');
    if (connections > 15) recommendations.add('Consider connection pooling optimization');
    return recommendations;
  }

  void _emitEvent(PerformanceEvent event) {
    _eventController.add(event);
  }

  void dispose() {
    stopCollection();
    _eventController.close();
  }
}

/// Типы метрик
enum MetricType {
  gauge,
  counter,
  histogram,
}

/// Направление тренда
enum TrendDirection {
  increasing,
  decreasing,
  stable,
}

/// Уровень серьезности аномалии
enum AnomalySeverity {
  low,
  medium,
  high,
  critical,
}

/// Уровень серьезности алерта
enum AlertSeverity {
  info,
  warning,
  critical,
}

/// Здоровье производительности
enum PerformanceHealth {
  good,
  warning,
  critical,
}

/// Метрика производительности
class PerformanceMetric extends Equatable {
  final String id;
  final String name;
  final String unit;
  final MetricType type;
  final double minValue;
  final double maxValue;
  final double currentValue;
  final DateTime lastUpdated;

  const PerformanceMetric({
    required this.id,
    required this.name,
    required this.unit,
    required this.type,
    required this.minValue,
    required this.maxValue,
    required this.currentValue,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [id, name, unit, type, minValue, maxValue, currentValue, lastUpdated];
}

/// Точка данных временного ряда
class PerformanceDataPoint extends Equatable {
  final DateTime timestamp;
  final double value;
  final String metricId;

  const PerformanceDataPoint({
    required this.timestamp,
    required this.value,
    required this.metricId,
  });

  @override
  List<Object?> get props => [timestamp, value, metricId];
}

/// Тренд производительности
class PerformanceTrend extends Equatable {
  final String metricId;
  final TrendDirection direction;
  final double slope;
  final double confidence;
  final double changePercent;

  const PerformanceTrend({
    required this.metricId,
    required this.direction,
    required this.slope,
    required this.confidence,
    required this.changePercent,
  });

  @override
  List<Object?> get props => [metricId, direction, slope, confidence, changePercent];
}

/// Аномалия производительности
class PerformanceAnomaly extends Equatable {
  final String metricId;
  final DateTime timestamp;
  final double value;
  final double expectedValue;
  final double deviation;
  final AnomalySeverity severity;

  const PerformanceAnomaly({
    required this.metricId,
    required this.timestamp,
    required this.value,
    required this.expectedValue,
    required this.deviation,
    required this.severity,
  });

  @override
  List<Object?> get props => [metricId, timestamp, value, expectedValue, deviation, severity];
}

/// Профиль производительности
class PerformanceProfile extends Equatable {
  final String id;
  final String name;
  final PerformanceHealth health;
  final double score;
  final List<String> metrics;
  final List<String> recommendations;
  final DateTime lastUpdated;

  const PerformanceProfile({
    required this.id,
    required this.name,
    required this.health,
    required this.score,
    required this.metrics,
    required this.recommendations,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [id, name, health, score, metrics, recommendations, lastUpdated];
}

/// Алерт производительности
class PerformanceAlert extends Equatable {
  final String id;
  final String metricId;
  final AlertSeverity severity;
  final String message;
  final DateTime timestamp;
  final double value;
  final double threshold;

  const PerformanceAlert({
    required this.id,
    required this.metricId,
    required this.severity,
    required this.message,
    required this.timestamp,
    required this.value,
    required this.threshold,
  });

  @override
  List<Object?> get props => [id, metricId, severity, message, timestamp, value, threshold];
}

/// Статистика производительности
class PerformanceStatistics extends Equatable {
  final int totalMetrics;
  final int activeAlerts;
  final double averageScore;
  final bool collectionActive;
  final DateTime lastUpdate;

  const PerformanceStatistics({
    required this.totalMetrics,
    required this.activeAlerts,
    required this.averageScore,
    required this.collectionActive,
    required this.lastUpdate,
  });

  @override
  List<Object?> get props => [totalMetrics, activeAlerts, averageScore, collectionActive, lastUpdate];
}

/// События производительности
abstract class PerformanceEvent extends Equatable {
  const PerformanceEvent();

  const factory PerformanceEvent.collectionStarted() = PerformanceCollectionStartedEvent;
  const factory PerformanceEvent.collectionStopped() = PerformanceCollectionStoppedEvent;
  const factory PerformanceEvent.metricsCollected(List<PerformanceMetric> metrics) = PerformanceMetricsCollectedEvent;
  const factory PerformanceEvent.analysisCompleted({
    required Map<String, PerformanceTrend> trends,
    required List<PerformanceAnomaly> anomalies,
    required List<PerformanceProfile> profiles,
    required List<PerformanceAlert> alerts,
  }) = PerformanceAnalysisCompletedEvent;
  const factory PerformanceEvent.collectionError(String error) = PerformanceCollectionErrorEvent;
  const factory PerformanceEvent.analysisError(String error) = PerformanceAnalysisErrorEvent;
}

class PerformanceCollectionStartedEvent extends PerformanceEvent {
  const PerformanceCollectionStartedEvent();

  @override
  List<Object?> get props => [];
}

class PerformanceCollectionStoppedEvent extends PerformanceEvent {
  const PerformanceCollectionStoppedEvent();

  @override
  List<Object?> get props => [];
}

class PerformanceMetricsCollectedEvent extends PerformanceEvent {
  final List<PerformanceMetric> metrics;

  const PerformanceMetricsCollectedEvent(this.metrics);

  @override
  List<Object?> get props => [metrics];
}

class PerformanceAnalysisCompletedEvent extends PerformanceEvent {
  final Map<String, PerformanceTrend> trends;
  final List<PerformanceAnomaly> anomalies;
  final List<PerformanceProfile> profiles;
  final List<PerformanceAlert> alerts;

  const PerformanceAnalysisCompletedEvent({
    required this.trends,
    required this.anomalies,
    required this.profiles,
    required this.alerts,
  });

  @override
  List<Object?> get props => [trends, anomalies, profiles, alerts];
}

class PerformanceCollectionErrorEvent extends PerformanceEvent {
  final String error;

  const PerformanceCollectionErrorEvent(this.error);

  @override
  List<Object?> get props => [error];
}

class PerformanceAnalysisErrorEvent extends PerformanceEvent {
  final String error;

  const PerformanceAnalysisErrorEvent(this.error);

  @override
  List<Object?> get props => [error];
}
