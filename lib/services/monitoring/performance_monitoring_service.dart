import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../performance/models/performance_metric.dart';

/// Сервис мониторинга производительности
class PerformanceMonitoringService extends ChangeNotifier {
  static final PerformanceMonitoringService _instance = PerformanceMonitoringService._internal();

  factory PerformanceMonitoringService() => _instance;

  PerformanceMonitoringService._internal();

  final List<PerformanceMetric> _metrics = [];
  final Random _random = Random();
  Timer? _monitoringTimer;
  bool _isMonitoring = false;

  /// Инициализация сервиса
  Future<void> initialize() async {
    print('Initializing Performance Monitoring Service...');
    await _startMonitoring();
  }

  /// Запуск мониторинга
  Future<void> _startMonitoring() async {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _monitoringTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _generateMetrics();
    });
  }

  /// Генерация метрик
  void _generateMetrics() {
    final now = DateTime.now();

    // CPU метрика
    _addMetric(PerformanceMetric(
      id: 'cpu_${now.millisecondsSinceEpoch}',
      name: 'CPU Usage',
      type: MetricType.cpu,
      value: 20 + _random.nextDouble() * 60, // 20-80%
      unit: '%',
      timestamp: now,
    ));

    // Memory метрика
    _addMetric(PerformanceMetric(
      id: 'memory_${now.millisecondsSinceEpoch}',
      name: 'Memory Usage',
      type: MetricType.memory,
      value: 40 + _random.nextDouble() * 40, // 40-80%
      unit: '%',
      timestamp: now,
    ));

    // Disk метрика
    _addMetric(PerformanceMetric(
      id: 'disk_${now.millisecondsSinceEpoch}',
      name: 'Disk Usage',
      type: MetricType.disk,
      value: 30 + _random.nextDouble() * 50, // 30-80%
      unit: '%',
      timestamp: now,
    ));

    // Network метрика
    _addMetric(PerformanceMetric(
      id: 'network_${now.millisecondsSinceEpoch}',
      name: 'Network Latency',
      type: MetricType.network,
      value: 10 + _random.nextDouble() * 90, // 10-100ms
      unit: 'ms',
      timestamp: now,
    ));

    notifyListeners();
  }

  /// Добавление метрики
  void _addMetric(PerformanceMetric metric) {
    _metrics.add(metric);

    // Ограничиваем количество метрик (храним последние 100)
    if (_metrics.length > 100) {
      _metrics.removeAt(0);
    }
  }

  /// Получение всех метрик
  List<PerformanceMetric> getAllMetrics() {
    return List.from(_metrics);
  }

  /// Получение метрик по типу
  List<PerformanceMetric> getMetricsByType(MetricType type) {
    return _metrics.where((metric) => metric.type == type).toList();
  }

  /// Получение последних метрик
  List<PerformanceMetric> getRecentMetrics({int count = 10}) {
    final sorted = List.from(_metrics);
    sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted.take(count).toList();
  }

  /// Получение среднего значения метрики
  double getAverageMetricValue(MetricType type) {
    final metrics = getMetricsByType(type);
    if (metrics.isEmpty) return 0.0;

    final sum = metrics.fold<double>(0.0, (sum, metric) => sum + metric.value);
    return sum / metrics.length;
  }

  /// Получение текущих метрик (алиас для getAllMetrics)
  List<PerformanceMetric> getCurrentMetrics() {
    return getAllMetrics();
  }

  /// Остановка мониторинга
  void stopMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    _isMonitoring = false;
  }

  /// Очистка метрик
  void clearMetrics() {
    _metrics.clear();
    notifyListeners();
  }

  /// Освобождение ресурсов
  @override
  void dispose() {
    stopMonitoring();
    super.dispose();
  }
}
