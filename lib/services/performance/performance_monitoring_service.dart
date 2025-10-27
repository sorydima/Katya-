import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';

/// Сервис мониторинга производительности
class PerformanceMonitoringService {
  static final PerformanceMonitoringService _instance = PerformanceMonitoringService._internal();

  // Метрики и мониторинг
  final Map<String, PerformanceMetric> _metrics = {};
  final Map<String, AlertRule> _alertRules = {};
  final Map<String, PerformanceAlert> _activeAlerts = {};
  final List<PerformanceEvent> _events = [];

  // Конфигурация
  static const Duration _metricsCollectionInterval = Duration(seconds: 30);
  static const Duration _alertCheckInterval = Duration(minutes: 1);
  static const Duration _dataRetentionPeriod = Duration(days: 7);

  // Таймеры
  Timer? _metricsTimer;
  Timer? _alertTimer;
  Timer? _cleanupTimer;

  factory PerformanceMonitoringService() => _instance;
  PerformanceMonitoringService._internal();

  /// Инициализация сервиса мониторинга
  Future<void> initialize() async {
    await _loadMonitoringConfiguration();
    _setupMetricsCollection();
    _setupAlertMonitoring();
    _setupDataCleanup();
  }

  /// Регистрация метрики
  void registerMetric(String name, MetricType type, {String? description}) {
    final metric = PerformanceMetric(
      name: name,
      type: type,
      description: description,
      value: 0.0,
      unit: _getDefaultUnit(type),
      timestamp: DateTime.now(),
      tags: const {},
    );

    _metrics[name] = metric;
  }

  /// Обновление значения метрики
  void updateMetric(String name, double value, {Map<String, String>? tags}) {
    final metric = _metrics[name];
    if (metric == null) return;

    final updatedMetric = PerformanceMetric(
      name: metric.name,
      type: metric.type,
      description: metric.description,
      value: value,
      unit: metric.unit,
      timestamp: DateTime.now(),
      tags: {...metric.tags, ...?tags},
    );

    _metrics[name] = updatedMetric;
    _recordEvent(PerformanceEventType.metricUpdated, name, {'value': value});
  }

  /// Инкремент счетчика
  void incrementCounter(String name, {double increment = 1.0, Map<String, String>? tags}) {
    final metric = _metrics[name];
    if (metric == null) return;

    final newValue = metric.value + increment;
    updateMetric(name, newValue, tags: tags);
  }

  /// Измерение времени выполнения
  Future<T> measureExecutionTime<T>(
    String metricName,
    Future<T> Function() operation, {
    Map<String, String>? tags,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      final result = await operation();
      stopwatch.stop();

      updateMetric(metricName, stopwatch.elapsedMicroseconds.toDouble(), tags: {
        ...?tags,
        'status': 'success',
      });

      return result;
    } catch (e) {
      stopwatch.stop();

      updateMetric(metricName, stopwatch.elapsedMicroseconds.toDouble(), tags: {
        ...?tags,
        'status': 'error',
        'error': e.toString(),
      });

      rethrow;
    }
  }

  /// Создание правила алерта
  AlertRule createAlertRule({
    required String ruleId,
    required String name,
    required String metricName,
    required AlertCondition condition,
    required double threshold,
    required AlertSeverity severity,
    String? description,
    Duration? evaluationPeriod,
  }) {
    final rule = AlertRule(
      ruleId: ruleId,
      name: name,
      metricName: metricName,
      condition: condition,
      threshold: threshold,
      severity: severity,
      description: description,
      evaluationPeriod: evaluationPeriod ?? const Duration(minutes: 5),
      isActive: true,
      createdAt: DateTime.now(),
      lastTriggered: null,
      triggerCount: 0,
    );

    _alertRules[ruleId] = rule;
    return rule;
  }

  /// Получение метрик
  List<PerformanceMetric> getMetrics({
    String? name,
    MetricType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    var metrics = _metrics.values.toList();

    if (name != null) {
      metrics = metrics.where((m) => m.name == name).toList();
    }

    if (type != null) {
      metrics = metrics.where((m) => m.type == type).toList();
    }

    if (startDate != null) {
      metrics = metrics.where((m) => m.timestamp.isAfter(startDate)).toList();
    }

    if (endDate != null) {
      metrics = metrics.where((m) => m.timestamp.isBefore(endDate)).toList();
    }

    return metrics;
  }

  /// Получение активных алертов
  List<PerformanceAlert> getActiveAlerts({AlertSeverity? severity}) {
    var alerts = _activeAlerts.values.where((alert) => alert.isActive).toList();

    if (severity != null) {
      alerts = alerts.where((alert) => alert.severity == severity).toList();
    }

    return alerts;
  }

  /// Получение событий
  List<PerformanceEvent> getEvents({
    PerformanceEventType? type,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) {
    var events = _events.toList();

    if (type != null) {
      events = events.where((e) => e.type == type).toList();
    }

    if (startDate != null) {
      events = events.where((e) => e.timestamp.isAfter(startDate)).toList();
    }

    if (endDate != null) {
      events = events.where((e) => e.timestamp.isBefore(endDate)).toList();
    }

    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return limit != null ? events.take(limit).toList() : events;
  }

  /// Получение отчета о производительности
  PerformanceReport generateReport({
    DateTime? startDate,
    DateTime? endDate,
    String? metricName,
  }) {
    final end = endDate ?? DateTime.now();
    final start = startDate ?? end.subtract(const Duration(hours: 1));

    final relevantMetrics = _metrics.values
        .where((m) => m.timestamp.isAfter(start) && m.timestamp.isBefore(end))
        .where((m) => metricName == null || m.name == metricName)
        .toList();

    if (relevantMetrics.isEmpty) {
      return PerformanceReport(
        periodStart: start,
        periodEnd: end,
        totalMetrics: 0,
        averageValue: 0.0,
        minValue: 0.0,
        maxValue: 0.0,
        trend: PerformanceTrend.stable,
        alertsTriggered: 0,
        eventsCount: 0,
      );
    }

    final values = relevantMetrics.map((m) => m.value).toList();
    final averageValue = values.reduce((a, b) => a + b) / values.length;
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);

    final trend = _calculateTrend(relevantMetrics);
    final alertsTriggered =
        _activeAlerts.values.where((alert) => alert.timestamp.isAfter(start) && alert.timestamp.isBefore(end)).length;

    final eventsCount =
        _events.where((event) => event.timestamp.isAfter(start) && event.timestamp.isBefore(end)).length;

    return PerformanceReport(
      periodStart: start,
      periodEnd: end,
      totalMetrics: relevantMetrics.length,
      averageValue: averageValue,
      minValue: minValue,
      maxValue: maxValue,
      trend: trend,
      alertsTriggered: alertsTriggered,
      eventsCount: eventsCount,
    );
  }

  /// Получение статистики системы
  SystemStats getSystemStats() {
    final now = DateTime.now();
    final lastHour = now.subtract(const Duration(hours: 1));

    final metricsLastHour = _metrics.values.where((m) => m.timestamp.isAfter(lastHour)).length;

    final activeAlertsCount = _activeAlerts.values.where((alert) => alert.isActive).length;

    final eventsLastHour = _events.where((e) => e.timestamp.isAfter(lastHour)).length;

    return SystemStats(
      totalMetrics: _metrics.length,
      metricsLastHour: metricsLastHour,
      activeAlerts: activeAlertsCount,
      eventsLastHour: eventsLastHour,
      uptime: const Duration(hours: 24), // Имитация
      memoryUsage: Random().nextInt(1024), // Имитация
      cpuUsage: Random().nextDouble(),
      diskUsage: Random().nextDouble(),
    );
  }

  /// Экспорт метрик
  Future<ExportResult> exportMetrics({
    required ExportFormat format,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? metricNames,
  }) async {
    try {
      final metrics = getMetrics(
        startDate: startDate,
        endDate: endDate,
      );

      final filteredMetrics =
          metricNames != null ? metrics.where((m) => metricNames.contains(m.name)).toList() : metrics;

      String data;
      String mimeType;

      switch (format) {
        case ExportFormat.json:
          data = _exportToJson(filteredMetrics);
          mimeType = 'application/json';
        case ExportFormat.csv:
          data = _exportToCsv(filteredMetrics);
          mimeType = 'text/csv';
        case ExportFormat.xml:
          data = _exportToXml(filteredMetrics);
          mimeType = 'application/xml';
      }

      return ExportResult(
        success: true,
        data: data,
        format: format,
        mimeType: mimeType,
        recordCount: filteredMetrics.length,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        data: '',
        format: format,
        mimeType: '',
        recordCount: 0,
        errorMessage: e.toString(),
      );
    }
  }

  /// Получение единицы измерения по умолчанию
  String _getDefaultUnit(MetricType type) {
    switch (type) {
      case MetricType.counter:
        return 'count';
      case MetricType.gauge:
        return 'value';
      case MetricType.histogram:
        return 'ms';
      case MetricType.timer:
        return 'ms';
    }
  }

  /// Расчет тренда
  PerformanceTrend _calculateTrend(List<PerformanceMetric> metrics) {
    if (metrics.length < 2) return PerformanceTrend.stable;

    final sortedMetrics = metrics..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final firstHalf = sortedMetrics.take(sortedMetrics.length ~/ 2);
    final secondHalf = sortedMetrics.skip(sortedMetrics.length ~/ 2);

    final firstAvg = firstHalf.map((m) => m.value).reduce((a, b) => a + b) / firstHalf.length;
    final secondAvg = secondHalf.map((m) => m.value).reduce((a, b) => a + b) / secondHalf.length;

    final change = (secondAvg - firstAvg) / firstAvg;

    if (change > 0.1) return PerformanceTrend.increasing;
    if (change < -0.1) return PerformanceTrend.decreasing;
    return PerformanceTrend.stable;
  }

  /// Запись события
  void _recordEvent(PerformanceEventType type, String source, Map<String, dynamic> data) {
    final event = PerformanceEvent(
      id: _generateId(),
      type: type,
      source: source,
      data: data,
      timestamp: DateTime.now(),
    );

    _events.add(event);

    // Ограничиваем количество событий в памяти
    if (_events.length > 10000) {
      _events.removeRange(0, _events.length - 5000);
    }
  }

  /// Проверка алертов
  void _checkAlerts() {
    for (final rule in _alertRules.values) {
      if (!rule.isActive) continue;

      final metric = _metrics[rule.metricName];
      if (metric == null) continue;

      final shouldTrigger = _evaluateAlertCondition(metric.value, rule.condition, rule.threshold);

      if (shouldTrigger) {
        _triggerAlert(rule, metric.value);
      }
    }
  }

  /// Оценка условия алерта
  bool _evaluateAlertCondition(double value, AlertCondition condition, double threshold) {
    switch (condition) {
      case AlertCondition.greaterThan:
        return value > threshold;
      case AlertCondition.lessThan:
        return value < threshold;
      case AlertCondition.equals:
        return value == threshold;
      case AlertCondition.notEquals:
        return value != threshold;
      case AlertCondition.greaterThanOrEquals:
        return value >= threshold;
      case AlertCondition.lessThanOrEquals:
        return value <= threshold;
    }
  }

  /// Срабатывание алерта
  void _triggerAlert(AlertRule rule, double currentValue) {
    final alert = PerformanceAlert(
      alertId: _generateId(),
      ruleId: rule.ruleId,
      ruleName: rule.name,
      metricName: rule.metricName,
      severity: rule.severity,
      currentValue: currentValue,
      threshold: rule.threshold,
      message: 'Alert triggered: ${rule.name} - Current: $currentValue, Threshold: ${rule.threshold}',
      timestamp: DateTime.now(),
      isActive: true,
      acknowledgedAt: null,
    );

    _activeAlerts[alert.alertId] = alert;
    _recordEvent(PerformanceEventType.alertTriggered, rule.metricName, {
      'ruleId': rule.ruleId,
      'currentValue': currentValue,
      'threshold': rule.threshold,
    });

    // Обновляем правило
    rule.lastTriggered = DateTime.now();
    rule.triggerCount++;
  }

  /// Экспорт в JSON
  String _exportToJson(List<PerformanceMetric> metrics) {
    final jsonData = metrics
        .map((m) => {
              'name': m.name,
              'type': m.type.name,
              'value': m.value,
              'unit': m.unit,
              'timestamp': m.timestamp.toIso8601String(),
              'tags': m.tags,
            })
        .toList();

    return jsonData.toString();
  }

  /// Экспорт в CSV
  String _exportToCsv(List<PerformanceMetric> metrics) {
    final buffer = StringBuffer();
    buffer.writeln('name,type,value,unit,timestamp,tags');

    for (final metric in metrics) {
      buffer.writeln(
          '${metric.name},${metric.type.name},${metric.value},${metric.unit},${metric.timestamp.toIso8601String()},"${metric.tags}"');
    }

    return buffer.toString();
  }

  /// Экспорт в XML
  String _exportToXml(List<PerformanceMetric> metrics) {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln('<metrics>');

    for (final metric in metrics) {
      buffer.writeln('  <metric>');
      buffer.writeln('    <name>${metric.name}</name>');
      buffer.writeln('    <type>${metric.type.name}</type>');
      buffer.writeln('    <value>${metric.value}</value>');
      buffer.writeln('    <unit>${metric.unit}</unit>');
      buffer.writeln('    <timestamp>${metric.timestamp.toIso8601String()}</timestamp>');
      buffer.writeln('  </metric>');
    }

    buffer.writeln('</metrics>');
    return buffer.toString();
  }

  /// Настройка сбора метрик
  void _setupMetricsCollection() {
    _metricsTimer = Timer.periodic(_metricsCollectionInterval, (timer) async {
      await _collectSystemMetrics();
    });
  }

  /// Настройка мониторинга алертов
  void _setupAlertMonitoring() {
    _alertTimer = Timer.periodic(_alertCheckInterval, (timer) {
      _checkAlerts();
    });
  }

  /// Настройка очистки данных
  void _setupDataCleanup() {
    _cleanupTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      _cleanupOldData();
    });
  }

  /// Сбор системных метрик
  Future<void> _collectSystemMetrics() async {
    // Имитация сбора системных метрик
    updateMetric('system.cpu_usage', Random().nextDouble() * 100);
    updateMetric('system.memory_usage', Random().nextInt(8192).toDouble());
    updateMetric('system.disk_usage', Random().nextDouble() * 100);
    updateMetric('system.network_io', Random().nextInt(1000000).toDouble());
  }

  /// Очистка старых данных
  void _cleanupOldData() {
    final cutoffDate = DateTime.now().subtract(_dataRetentionPeriod);

    // Очищаем старые метрики
    _metrics.removeWhere((key, metric) => metric.timestamp.isBefore(cutoffDate));

    // Очищаем старые события
    _events.removeWhere((event) => event.timestamp.isBefore(cutoffDate));

    // Деактивируем старые алерты
    _activeAlerts.removeWhere((key, alert) {
      if (alert.timestamp.isBefore(cutoffDate)) {
        alert.isActive = false;
        return true;
      }
      return false;
    });
  }

  /// Загрузка конфигурации мониторинга
  Future<void> _loadMonitoringConfiguration() async {
    // Регистрируем базовые метрики
    registerMetric('system.cpu_usage', MetricType.gauge, description: 'CPU usage percentage');
    registerMetric('system.memory_usage', MetricType.gauge, description: 'Memory usage in MB');
    registerMetric('system.disk_usage', MetricType.gauge, description: 'Disk usage percentage');
    registerMetric('system.network_io', MetricType.gauge, description: 'Network I/O in bytes');

    // Создаем базовые правила алертов
    createAlertRule(
      ruleId: 'high_cpu_usage',
      name: 'High CPU Usage',
      metricName: 'system.cpu_usage',
      condition: AlertCondition.greaterThan,
      threshold: 80.0,
      severity: AlertSeverity.warning,
      description: 'CPU usage exceeds 80%',
    );

    createAlertRule(
      ruleId: 'high_memory_usage',
      name: 'High Memory Usage',
      metricName: 'system.memory_usage',
      condition: AlertCondition.greaterThan,
      threshold: 6144.0, // 6GB
      severity: AlertSeverity.critical,
      description: 'Memory usage exceeds 6GB',
    );
  }

  /// Генерация уникального ID
  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';
  }

  /// Освобождение ресурсов
  void dispose() {
    _metricsTimer?.cancel();
    _alertTimer?.cancel();
    _cleanupTimer?.cancel();
    _metrics.clear();
    _alertRules.clear();
    _activeAlerts.clear();
    _events.clear();
  }
}

/// Модели данных

/// Метрика производительности
class PerformanceMetric extends Equatable {
  final String name;
  final MetricType type;
  final String? description;
  final double value;
  final String unit;
  final DateTime timestamp;
  final Map<String, String> tags;

  const PerformanceMetric({
    required this.name,
    required this.type,
    this.description,
    required this.value,
    required this.unit,
    required this.timestamp,
    required this.tags,
  });

  @override
  List<Object?> get props => [name, type, description, value, unit, timestamp, tags];
}

/// Правило алерта
class AlertRule extends Equatable {
  final String ruleId;
  final String name;
  final String metricName;
  final AlertCondition condition;
  final double threshold;
  final AlertSeverity severity;
  final String? description;
  final Duration evaluationPeriod;
  bool isActive;
  final DateTime createdAt;
  DateTime? lastTriggered;
  int triggerCount;

  AlertRule({
    required this.ruleId,
    required this.name,
    required this.metricName,
    required this.condition,
    required this.threshold,
    required this.severity,
    this.description,
    required this.evaluationPeriod,
    required this.isActive,
    required this.createdAt,
    this.lastTriggered,
    required this.triggerCount,
  });

  @override
  List<Object?> get props => [
        ruleId,
        name,
        metricName,
        condition,
        threshold,
        severity,
        description,
        evaluationPeriod,
        isActive,
        createdAt,
        lastTriggered,
        triggerCount,
      ];
}

/// Алерт производительности
class PerformanceAlert extends Equatable {
  final String alertId;
  final String ruleId;
  final String ruleName;
  final String metricName;
  final AlertSeverity severity;
  final double currentValue;
  final double threshold;
  final String message;
  final DateTime timestamp;
  bool isActive;
  DateTime? acknowledgedAt;

  PerformanceAlert({
    required this.alertId,
    required this.ruleId,
    required this.ruleName,
    required this.metricName,
    required this.severity,
    required this.currentValue,
    required this.threshold,
    required this.message,
    required this.timestamp,
    required this.isActive,
    this.acknowledgedAt,
  });

  @override
  List<Object?> get props => [
        alertId,
        ruleId,
        ruleName,
        metricName,
        severity,
        currentValue,
        threshold,
        message,
        timestamp,
        isActive,
        acknowledgedAt,
      ];
}

/// Событие производительности
class PerformanceEvent extends Equatable {
  final String id;
  final PerformanceEventType type;
  final String source;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  const PerformanceEvent({
    required this.id,
    required this.type,
    required this.source,
    required this.data,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, type, source, data, timestamp];
}

/// Отчет о производительности
class PerformanceReport extends Equatable {
  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalMetrics;
  final double averageValue;
  final double minValue;
  final double maxValue;
  final PerformanceTrend trend;
  final int alertsTriggered;
  final int eventsCount;

  const PerformanceReport({
    required this.periodStart,
    required this.periodEnd,
    required this.totalMetrics,
    required this.averageValue,
    required this.minValue,
    required this.maxValue,
    required this.trend,
    required this.alertsTriggered,
    required this.eventsCount,
  });

  @override
  List<Object?> get props => [
        periodStart,
        periodEnd,
        totalMetrics,
        averageValue,
        minValue,
        maxValue,
        trend,
        alertsTriggered,
        eventsCount,
      ];
}

/// Статистика системы
class SystemStats extends Equatable {
  final int totalMetrics;
  final int metricsLastHour;
  final int activeAlerts;
  final int eventsLastHour;
  final Duration uptime;
  final int memoryUsage;
  final double cpuUsage;
  final double diskUsage;

  const SystemStats({
    required this.totalMetrics,
    required this.metricsLastHour,
    required this.activeAlerts,
    required this.eventsLastHour,
    required this.uptime,
    required this.memoryUsage,
    required this.cpuUsage,
    required this.diskUsage,
  });

  @override
  List<Object?> get props => [
        totalMetrics,
        metricsLastHour,
        activeAlerts,
        eventsLastHour,
        uptime,
        memoryUsage,
        cpuUsage,
        diskUsage,
      ];
}

/// Результат экспорта
class ExportResult extends Equatable {
  final bool success;
  final String data;
  final ExportFormat format;
  final String mimeType;
  final int recordCount;
  final String? errorMessage;

  const ExportResult({
    required this.success,
    required this.data,
    required this.format,
    required this.mimeType,
    required this.recordCount,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [success, data, format, mimeType, recordCount, errorMessage];
}

/// Перечисления

/// Тип метрики
enum MetricType {
  counter, // Счетчик
  gauge, // Измеритель
  histogram, // Гистограмма
  timer, // Таймер
}

/// Условие алерта
enum AlertCondition {
  greaterThan,
  lessThan,
  equals,
  notEquals,
  greaterThanOrEquals,
  lessThanOrEquals,
}

/// Серьезность алерта
enum AlertSeverity {
  info, // Информация
  warning, // Предупреждение
  critical, // Критический
  emergency, // Экстренный
}

/// Тип события
enum PerformanceEventType {
  metricUpdated,
  alertTriggered,
  alertAcknowledged,
  thresholdExceeded,
  systemError,
}

/// Тренд производительности
enum PerformanceTrend {
  increasing, // Растущий
  decreasing, // Убывающий
  stable, // Стабильный
}

/// Формат экспорта
enum ExportFormat {
  json,
  csv,
  xml,
}
