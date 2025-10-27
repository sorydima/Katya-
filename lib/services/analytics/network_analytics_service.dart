import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';

import 'models/analytics_task.dart';

/// Сервис для продвинутой аналитики и мониторинга сети доверия
class NetworkAnalyticsService {
  static final NetworkAnalyticsService _instance = NetworkAnalyticsService._internal();

  // Метрики и данные
  final Map<String, NetworkMetric> _metrics = {};
  final Map<String, NetworkEvent> _events = {};
  final Map<String, NetworkAlert> _alerts = {};

  // Аналитика и отчеты
  final Map<String, NetworkReport> _reports = {};
  final Map<String, NetworkInsight> _insights = {};
  final Map<String, NetworkPrediction> _predictions = {};

  // Конфигурация
  static const int _metricsRetentionDays = 90;
  static const int _eventsRetentionDays = 30;
  static const int _maxMetricsPerType = 10000;
  static const Duration _reportGenerationInterval = Duration(hours: 6);

  factory NetworkAnalyticsService() => _instance;
  NetworkAnalyticsService._internal();

  /// Инициализация сервиса
  Future<void> initialize() async {
    await _initializeMetrics();
    _setupDataCollection();
    _setupAnalyticsProcessing();
    _setupAlertMonitoring();
  }

  /// Сбор метрики сети
  Future<void> collectMetric({
    required String metricId,
    required MetricType type,
    required double value,
    required String source,
    Map<String, dynamic>? tags,
    DateTime? timestamp,
  }) async {
    final metric = NetworkMetric(
      metricId: metricId,
      type: type,
      value: value,
      source: source,
      tags: tags ?? {},
      timestamp: timestamp ?? DateTime.now(),
      metadata: const {},
    );

    // Добавляем метрику
    _addMetric(metric);

    // Проверяем алерты
    await _checkMetricAlerts(metric);

    // Обновляем агрегированные метрики
    await _updateAggregatedMetrics(metric);
  }

  /// Регистрация события сети
  Future<void> recordEvent({
    required String eventId,
    required EventType type,
    required String source,
    required Map<String, dynamic> data,
    DateTime? timestamp,
  }) async {
    final event = NetworkEvent(
      eventId: eventId,
      type: type,
      source: source,
      data: data,
      timestamp: timestamp ?? DateTime.now(),
      severity: _determineEventSeverity(type, data),
    );

    _events[eventId] = event;

    // Проверяем алерты на события
    await _checkEventAlerts(event);

    // Генерируем инсайты
    await _generateEventInsights(event);
  }

  /// Получение метрик сети
  Future<List<NetworkMetric>> getMetrics({
    MetricType? type,
    String? source,
    DateTime? from,
    DateTime? to,
    int? limit,
  }) async {
    var metrics = _metrics.values.toList();

    if (type != null) {
      metrics = metrics.where((m) => m.type == type).toList();
    }

    if (source != null) {
      metrics = metrics.where((m) => m.source == source).toList();
    }

    if (from != null) {
      metrics = metrics.where((m) => m.timestamp.isAfter(from)).toList();
    }

    if (to != null) {
      metrics = metrics.where((m) => m.timestamp.isBefore(to)).toList();
    }

    // Сортировка по времени (новые сначала)
    metrics.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return limit != null ? metrics.take(limit).toList() : metrics;
  }

  /// Получение событий сети
  Future<List<NetworkEvent>> getEvents({
    EventType? type,
    String? source,
    EventSeverity? severity,
    DateTime? from,
    DateTime? to,
    int? limit,
  }) async {
    var events = _events.values.toList();

    if (type != null) {
      events = events.where((e) => e.type == type).toList();
    }

    if (source != null) {
      events = events.where((e) => e.source == source).toList();
    }

    if (severity != null) {
      events = events.where((e) => e.severity == severity).toList();
    }

    if (from != null) {
      events = events.where((e) => e.timestamp.isAfter(from)).toList();
    }

    if (to != null) {
      events = events.where((e) => e.timestamp.isBefore(to)).toList();
    }

    // Сортировка по времени (новые сначала)
    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return limit != null ? events.take(limit).toList() : events;
  }

  /// Создание алерта
  Future<NetworkAlert> createAlert({
    required String alertId,
    required String name,
    required AlertType type,
    required String condition,
    required AlertSeverity severity,
    Map<String, dynamic>? parameters,
  }) async {
    final alert = NetworkAlert(
      alertId: alertId,
      name: name,
      type: type,
      condition: condition,
      severity: severity,
      parameters: parameters ?? {},
      status: AlertStatus.active,
      createdAt: DateTime.now(),
      lastTriggered: null,
      triggerCount: 0,
    );

    _alerts[alertId] = alert;
    return alert;
  }

  /// Получение активных алертов
  Future<List<NetworkAlert>> getActiveAlerts() async {
    return _alerts.values.where((a) => a.status == AlertStatus.active).toList();
  }

  /// Генерация отчета о сети
  Future<NetworkReport> generateNetworkReport({
    required String reportId,
    required ReportType type,
    required DateTime from,
    required DateTime to,
    Map<String, dynamic>? filters,
  }) async {
    final report = NetworkReport(
      reportId: reportId,
      type: type,
      from: from,
      to: to,
      filters: filters ?? {},
      status: ReportStatus.generating,
      createdAt: DateTime.now(),
    );

    try {
      // Генерируем содержимое отчета
      await _generateReportContent(report);

      report.status = ReportStatus.completed;
      report.completedAt = DateTime.now();
    } catch (e) {
      report.status = ReportStatus.failed;
      report.errorMessage = e.toString();
    }

    _reports[reportId] = report;
    return report;
  }

  /// Получение инсайтов сети
  Future<List<NetworkInsight>> getNetworkInsights({
    InsightType? type,
    String? source,
    int? limit,
  }) async {
    var insights = _insights.values.toList();

    if (type != null) {
      insights = insights.where((i) => i.type == type).toList();
    }

    if (source != null) {
      insights = insights.where((i) => i.source == source).toList();
    }

    // Сортировка по важности и времени
    insights.sort((a, b) {
      final importanceComparison = b.importance.index.compareTo(a.importance.index);
      if (importanceComparison != 0) return importanceComparison;
      return b.generatedAt.compareTo(a.generatedAt);
    });

    return limit != null ? insights.take(limit).toList() : insights;
  }

  /// Получение прогнозов
  Future<List<NetworkPrediction>> getPredictions({
    PredictionType? type,
    String? metricId,
    int? limit,
  }) async {
    var predictions = _predictions.values.toList();

    if (type != null) {
      predictions = predictions.where((p) => p.type == type).toList();
    }

    if (metricId != null) {
      predictions = predictions.where((p) => p.metricId == metricId).toList();
    }

    // Сортировка по времени прогноза
    predictions.sort((a, b) => a.predictedAt.compareTo(b.predictedAt));

    return limit != null ? predictions.take(limit).toList() : predictions;
  }

  /// Анализ производительности сети
  Future<NetworkPerformanceAnalysis> analyzePerformance({
    required DateTime from,
    required DateTime to,
    String? source,
  }) async {
    final metrics = await getMetrics(from: from, to: to, source: source);
    final events = await getEvents(from: from, to: to, source: source);

    return NetworkPerformanceAnalysis(
      period: PerformancePeriod(from: from, to: to),
      totalMetrics: metrics.length,
      totalEvents: events.length,
      averageResponseTime: _calculateAverageResponseTime(metrics),
      uptime: _calculateUptime(events),
      errorRate: _calculateErrorRate(events),
      throughput: _calculateThroughput(metrics),
      latency: _calculateLatency(metrics),
      availability: _calculateAvailability(events),
      performanceScore: _calculatePerformanceScore(metrics, events),
      bottlenecks: _identifyBottlenecks(metrics, events),
      recommendations: _generatePerformanceRecommendations(metrics, events),
      analyzedAt: DateTime.now(),
    );
  }

  /// Анализ безопасности сети
  Future<NetworkSecurityAnalysis> analyzeSecurity({
    required DateTime from,
    required DateTime to,
  }) async {
    final securityEvents = await getEvents(
      type: EventType.security,
      from: from,
      to: to,
    );

    return NetworkSecurityAnalysis(
      period: PerformancePeriod(from: from, to: to),
      totalSecurityEvents: securityEvents.length,
      threatLevel: _assessThreatLevel(securityEvents),
      attackTypes: _categorizeAttackTypes(securityEvents),
      affectedSources: _identifyAffectedSources(securityEvents),
      mitigationActions: _recommendMitigationActions(securityEvents),
      securityScore: _calculateSecurityScore(securityEvents),
      vulnerabilities: _identifyVulnerabilities(securityEvents),
      recommendations: _generateSecurityRecommendations(securityEvents),
      analyzedAt: DateTime.now(),
    );
  }

  /// Инициализация метрик
  Future<void> _initializeMetrics() async {
    // Создаем базовые метрики
    final basicMetrics = [
      MetricType.networkLatency,
      MetricType.networkThroughput,
      MetricType.activeConnections,
      MetricType.memoryUsage,
      MetricType.cpuUsage,
      MetricType.diskUsage,
      MetricType.errorRate,
      MetricType.responseTime,
    ];

    for (final metricType in basicMetrics) {
      await collectMetric(
        metricId: '${metricType.name}_baseline',
        type: metricType,
        value: _getBaselineValue(metricType),
        source: 'system',
      );
    }
  }

  /// Настройка сбора данных
  void _setupDataCollection() {
    Timer.periodic(const Duration(minutes: 1), (timer) async {
      await _collectSystemMetrics();
    });

    Timer.periodic(const Duration(seconds: 30), (timer) async {
      await _collectNetworkEvents();
    });
  }

  /// Настройка обработки аналитики
  void _setupAnalyticsProcessing() {
    Timer.periodic(const Duration(hours: 1), (timer) async {
      await _processAnalytics();
    });

    Timer.periodic(_reportGenerationInterval, (timer) async {
      await _generatePeriodicReports();
    });
  }

  /// Настройка мониторинга алертов
  void _setupAlertMonitoring() {
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      await _monitorAlerts();
    });
  }

  /// Сбор системных метрик
  Future<void> _collectSystemMetrics() async {
    // В реальной реализации здесь будет сбор реальных системных метрик
    // Для демонстрации генерируем тестовые данные

    await collectMetric(
      metricId: 'cpu_usage_${DateTime.now().millisecondsSinceEpoch}',
      type: MetricType.cpuUsage,
      value: 20.0 + Random().nextDouble() * 60.0,
      source: 'system',
    );

    await collectMetric(
      metricId: 'memory_usage_${DateTime.now().millisecondsSinceEpoch}',
      type: MetricType.memoryUsage,
      value: 40.0 + Random().nextDouble() * 40.0,
      source: 'system',
    );

    await collectMetric(
      metricId: 'network_latency_${DateTime.now().millisecondsSinceEpoch}',
      type: MetricType.networkLatency,
      value: 50.0 + Random().nextDouble() * 100.0,
      source: 'network',
    );
  }

  /// Сбор сетевых событий
  Future<void> _collectNetworkEvents() async {
    // В реальной реализации здесь будет сбор реальных сетевых событий
    // Для демонстрации генерируем тестовые события

    if (Random().nextDouble() < 0.1) {
      // 10% вероятность события
      await recordEvent(
        eventId: 'event_${DateTime.now().millisecondsSinceEpoch}',
        type: EventType.connection,
        source: 'network',
        data: {
          'connectionId': 'conn_${Random().nextInt(1000)}',
          'status': Random().nextBool() ? 'established' : 'closed',
        },
      );
    }
  }

  /// Обработка аналитики
  Future<void> _processAnalytics() async {
    await _generateInsights();
    await _updatePredictions();
    await _cleanupOldData();
  }

  /// Генерация инсайтов
  Future<void> _generateInsights() async {
    // Анализ трендов
    await _analyzeTrends();

    // Анализ аномалий
    await _detectAnomalies();

    // Анализ паттернов
    await _analyzePatterns();
  }

  /// Обновление прогнозов
  Future<void> _updatePredictions() async {
    final metrics = _metrics.values.toList();
    final metricTypes = metrics.map((m) => m.type).toSet();

    for (final metricType in metricTypes) {
      final typeMetrics = metrics.where((m) => m.type == metricType).toList();
      if (typeMetrics.length >= 10) {
        // Минимум данных для прогноза
        await _generatePrediction(metricType, typeMetrics);
      }
    }
  }

  /// Генерация прогноза
  Future<void> _generatePrediction(MetricType metricType, List<NetworkMetric> metrics) async {
    // Простой линейный прогноз
    final sortedMetrics = metrics..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (sortedMetrics.length < 2) return;

    final recentValues = sortedMetrics.length > 10
        ? sortedMetrics.sublist(sortedMetrics.length - 10).map((m) => m.value).toList()
        : sortedMetrics.map((m) => m.value).toList();
    final trend = _calculateTrend(recentValues);

    final prediction = NetworkPrediction(
      predictionId: 'pred_${metricType.name}_${DateTime.now().millisecondsSinceEpoch}',
      metricId: metricType.name,
      type: PredictionType.trend,
      currentValue: recentValues.last,
      predictedValue: recentValues.last + trend * 24, // Прогноз на 24 часа
      confidence: _calculatePredictionConfidence(recentValues),
      predictedAt: DateTime.now().add(const Duration(hours: 24)),
      generatedAt: DateTime.now(),
    );

    _predictions[prediction.predictionId] = prediction;
  }

  /// Генерация периодических отчетов
  Future<void> _generatePeriodicReports() async {
    final now = DateTime.now();
    final from = now.subtract(_reportGenerationInterval);

    await generateNetworkReport(
      reportId: 'periodic_${now.millisecondsSinceEpoch}',
      type: ReportType.performance,
      from: from,
      to: now,
    );
  }

  /// Мониторинг алертов
  Future<void> _monitorAlerts() async {
    for (final alert in _alerts.values.where((a) => a.status == AlertStatus.active)) {
      await _evaluateAlert(alert);
    }
  }

  /// Добавление метрики
  void _addMetric(NetworkMetric metric) {
    _metrics[metric.metricId] = metric;

    // Ограничиваем количество метрик
    if (_metrics.length > _maxMetricsPerType * 10) {
      final sortedMetrics = _metrics.entries.toList()..sort((a, b) => a.value.timestamp.compareTo(b.value.timestamp));

      final toRemove = sortedMetrics.take(_metrics.length - _maxMetricsPerType * 10);
      for (final entry in toRemove) {
        _metrics.remove(entry.key);
      }
    }
  }

  /// Определение серьезности события
  EventSeverity _determineEventSeverity(EventType type, Map<String, dynamic> data) {
    switch (type) {
      case EventType.error:
        return EventSeverity.high;
      case EventType.security:
        return EventSeverity.critical;
      case EventType.connection:
        return EventSeverity.medium;
      case EventType.performance:
        return EventSeverity.low;
      default:
        return EventSeverity.low;
    }
  }

  /// Проверка алертов на метрики
  Future<void> _checkMetricAlerts(NetworkMetric metric) async {
    for (final alert in _alerts.values.where((a) => a.type == AlertType.metric)) {
      if (await _evaluateMetricAlert(alert, metric)) {
        await _triggerAlert(alert, metric);
      }
    }
  }

  /// Проверка алертов на события
  Future<void> _checkEventAlerts(NetworkEvent event) async {
    for (final alert in _alerts.values.where((a) => a.type == AlertType.event)) {
      if (await _evaluateEventAlert(alert, event)) {
        await _triggerAlert(alert, event);
      }
    }
  }

  /// Обновление агрегированных метрик
  Future<void> _updateAggregatedMetrics(NetworkMetric metric) async {
    // В реальной реализации здесь будет обновление агрегированных метрик
  }

  /// Генерация инсайтов на основе событий
  Future<void> _generateEventInsights(NetworkEvent event) async {
    // Анализ частоты событий
    final similarEvents = _events.values
        .where((e) => e.type == event.type && e.source == event.source)
        .where((e) => e.timestamp.isAfter(DateTime.now().subtract(const Duration(hours: 24))))
        .length;

    if (similarEvents > 10) {
      final insight = NetworkInsight(
        insightId: 'insight_${event.eventId}',
        type: InsightType.frequency,
        title: 'High Event Frequency Detected',
        description: 'Unusual high frequency of ${event.type.name} events from ${event.source}',
        importance: ImportanceLevel.medium,
        source: event.source,
        data: {'eventCount': similarEvents, 'eventType': event.type.name},
        generatedAt: DateTime.now(),
      );

      _insights[insight.insightId] = insight;
    }
  }

  /// Очистка старых данных
  Future<void> _cleanupOldData() async {
    final cutoffDate = DateTime.now().subtract(const Duration(days: _metricsRetentionDays));

    // Очистка старых метрик
    _metrics.removeWhere((key, metric) => metric.timestamp.isBefore(cutoffDate));

    // Очистка старых событий
    final eventCutoffDate = DateTime.now().subtract(const Duration(days: _eventsRetentionDays));
    _events.removeWhere((key, event) => event.timestamp.isBefore(eventCutoffDate));
  }

  /// Анализ трендов
  Future<void> _analyzeTrends() async {
    // В реальной реализации здесь будет анализ трендов
  }

  /// Обнаружение аномалий
  Future<void> _detectAnomalies() async {
    // В реальной реализации здесь будет обнаружение аномалий
  }

  /// Анализ паттернов
  Future<void> _analyzePatterns() async {
    // В реальной реализации здесь будет анализ паттернов
  }

  /// Оценка алерта
  Future<void> _evaluateAlert(NetworkAlert alert) async {
    // В реальной реализации здесь будет оценка условий алерта
  }

  /// Получение базового значения
  double _getBaselineValue(MetricType type) {
    switch (type) {
      case MetricType.cpuUsage:
        return 25.0;
      case MetricType.memoryUsage:
        return 50.0;
      case MetricType.networkLatency:
        return 100.0;
      case MetricType.networkThroughput:
        return 1000.0;
      case MetricType.activeConnections:
        return 100.0;
      case MetricType.diskUsage:
        return 60.0;
      case MetricType.errorRate:
        return 0.01;
      case MetricType.responseTime:
        return 200.0;
    }
  }

  /// Расчет тренда
  double _calculateTrend(List<double> values) {
    if (values.length < 2) return 0.0;

    double sum = 0.0;
    for (int i = 1; i < values.length; i++) {
      sum += values[i] - values[i - 1];
    }

    return sum / (values.length - 1);
  }

  /// Расчет уверенности прогноза
  double _calculatePredictionConfidence(List<double> values) {
    if (values.length < 3) return 0.0;

    // Простая оценка на основе стабильности данных
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) / values.length;
    final stability = 1.0 / (1.0 + variance);

    return min(1.0, stability);
  }

  /// Оценка алерта на метрику
  Future<bool> _evaluateMetricAlert(NetworkAlert alert, NetworkMetric metric) async {
    // Простая реализация для демонстрации
    return false;
  }

  /// Оценка алерта на событие
  Future<bool> _evaluateEventAlert(NetworkAlert alert, NetworkEvent event) async {
    // Простая реализация для демонстрации
    return false;
  }

  /// Срабатывание алерта
  Future<void> _triggerAlert(NetworkAlert alert, dynamic data) async {
    alert.triggerCount++;
    alert.lastTriggered = DateTime.now();
  }

  /// Генерация содержимого отчета
  Future<void> _generateReportContent(NetworkReport report) async {
    // В реальной реализации здесь будет генерация содержимого отчета
    await Future.delayed(const Duration(seconds: 2)); // Имитация генерации
  }

  /// Расчет средней времени ответа
  Duration _calculateAverageResponseTime(List<NetworkMetric> metrics) {
    final responseTimeMetrics = metrics.where((m) => m.type == MetricType.responseTime);
    if (responseTimeMetrics.isEmpty) return Duration.zero;

    final average = responseTimeMetrics.map((m) => m.value).reduce((a, b) => a + b) / responseTimeMetrics.length;
    return Duration(milliseconds: average.round());
  }

  /// Расчет времени работы
  double _calculateUptime(List<NetworkEvent> events) {
    // Простая реализация для демонстрации
    return 0.99; // 99% uptime
  }

  /// Расчет частоты ошибок
  double _calculateErrorRate(List<NetworkEvent> events) {
    final errorEvents = events.where((e) => e.type == EventType.error).length;
    return events.isEmpty ? 0.0 : errorEvents / events.length;
  }

  /// Расчет пропускной способности
  double _calculateThroughput(List<NetworkMetric> metrics) {
    final throughputMetrics = metrics.where((m) => m.type == MetricType.networkThroughput);
    if (throughputMetrics.isEmpty) return 0.0;

    return throughputMetrics.map((m) => m.value).reduce((a, b) => a + b) / throughputMetrics.length;
  }

  /// Расчет задержки
  Duration _calculateLatency(List<NetworkMetric> metrics) {
    final latencyMetrics = metrics.where((m) => m.type == MetricType.networkLatency);
    if (latencyMetrics.isEmpty) return Duration.zero;

    final average = latencyMetrics.map((m) => m.value).reduce((a, b) => a + b) / latencyMetrics.length;
    return Duration(milliseconds: average.round());
  }

  /// Расчет доступности
  double _calculateAvailability(List<NetworkEvent> events) {
    // Простая реализация для демонстрации
    return 0.995; // 99.5% availability
  }

  /// Расчет скора производительности
  double _calculatePerformanceScore(List<NetworkMetric> metrics, List<NetworkEvent> events) {
    final errorRate = _calculateErrorRate(events);
    final uptime = _calculateUptime(events);

    return (uptime * (1.0 - errorRate)) * 100;
  }

  /// Идентификация узких мест
  List<String> _identifyBottlenecks(List<NetworkMetric> metrics, List<NetworkEvent> events) {
    final bottlenecks = <String>[];

    // Простая логика для демонстрации
    final highCpuMetrics = metrics.where((m) => m.type == MetricType.cpuUsage && m.value > 80.0);
    if (highCpuMetrics.isNotEmpty) {
      bottlenecks.add('High CPU usage detected');
    }

    final highMemoryMetrics = metrics.where((m) => m.type == MetricType.memoryUsage && m.value > 90.0);
    if (highMemoryMetrics.isNotEmpty) {
      bottlenecks.add('High memory usage detected');
    }

    return bottlenecks;
  }

  /// Генерация рекомендаций по производительности
  List<String> _generatePerformanceRecommendations(List<NetworkMetric> metrics, List<NetworkEvent> events) {
    final recommendations = <String>[];

    final errorRate = _calculateErrorRate(events);
    if (errorRate > 0.05) {
      recommendations.add('High error rate detected - investigate error sources');
    }

    final highLatencyMetrics = metrics.where((m) => m.type == MetricType.networkLatency && m.value > 500.0);
    if (highLatencyMetrics.isNotEmpty) {
      recommendations.add('High network latency - consider network optimization');
    }

    return recommendations;
  }

  /// Оценка уровня угроз
  ThreatLevel _assessThreatLevel(List<NetworkEvent> securityEvents) {
    if (securityEvents.isEmpty) return ThreatLevel.low;

    final criticalEvents = securityEvents.where((e) => e.severity == EventSeverity.critical).length;
    final highEvents = securityEvents.where((e) => e.severity == EventSeverity.high).length;

    if (criticalEvents > 0) return ThreatLevel.critical;
    if (highEvents > 5) return ThreatLevel.high;
    if (highEvents > 0) return ThreatLevel.medium;
    return ThreatLevel.low;
  }

  /// Категоризация типов атак
  Map<String, int> _categorizeAttackTypes(List<NetworkEvent> securityEvents) {
    final attackTypes = <String, int>{};

    for (final event in securityEvents) {
      final attackType = event.data['attackType'] as String? ?? 'unknown';
      attackTypes[attackType] = (attackTypes[attackType] ?? 0) + 1;
    }

    return attackTypes;
  }

  /// Идентификация затронутых источников
  List<String> _identifyAffectedSources(List<NetworkEvent> securityEvents) {
    return securityEvents.map((e) => e.source).toSet().toList();
  }

  /// Рекомендации по смягчению
  List<String> _recommendMitigationActions(List<NetworkEvent> securityEvents) {
    final recommendations = <String>[];

    if (securityEvents.isNotEmpty) {
      recommendations.add('Review security logs and implement additional monitoring');
      recommendations.add('Consider updating security policies');
      recommendations.add('Perform security assessment of affected systems');
    }

    return recommendations;
  }

  /// Расчет скора безопасности
  double _calculateSecurityScore(List<NetworkEvent> securityEvents) {
    if (securityEvents.isEmpty) return 100.0;

    double score = 100.0;
    for (final event in securityEvents) {
      switch (event.severity) {
        case EventSeverity.critical:
          score -= 20.0;
        case EventSeverity.high:
          score -= 10.0;
        case EventSeverity.medium:
          score -= 5.0;
        case EventSeverity.low:
          score -= 1.0;
      }
    }

    return max(0.0, score);
  }

  /// Идентификация уязвимостей
  List<String> _identifyVulnerabilities(List<NetworkEvent> securityEvents) {
    final vulnerabilities = <String>[];

    for (final event in securityEvents) {
      final vulnerability = event.data['vulnerability'] as String?;
      if (vulnerability != null && !vulnerabilities.contains(vulnerability)) {
        vulnerabilities.add(vulnerability);
      }
    }

    return vulnerabilities;
  }

  /// Генерация рекомендаций по безопасности
  List<String> _generateSecurityRecommendations(List<NetworkEvent> securityEvents) {
    final recommendations = <String>[];

    if (securityEvents.isNotEmpty) {
      recommendations.add('Implement additional security monitoring');
      recommendations.add('Review and update access controls');
      recommendations.add('Perform regular security audits');
      recommendations.add('Update security patches and software');
    }

    return recommendations;
  }

  /// Получение системных метрик
  Map<String, dynamic> getSystemMetrics() {
    return {
      'totalMetrics': _metrics.length,
      'totalEvents': _events.length,
      'totalAlerts': _alerts.length,
      'totalReports': _reports.length,
      'totalInsights': _insights.length,
      'totalPredictions': _predictions.length,
    };
  }

  /// Получение сетевых метрик
  List<NetworkMetric> getNetworkMetrics() {
    return _metrics.values.toList();
  }

  /// Получение задач аналитики
  List<AnalyticsTask> getAnalyticsTasks() {
    // Возвращаем пустой список, так как у нас нет задач аналитики
    return [];
  }

  /// Освобождение ресурсов
  void dispose() {
    _metrics.clear();
    _events.clear();
    _alerts.clear();
    _reports.clear();
    _insights.clear();
    _predictions.clear();
  }
}

/// Метрика сети
class NetworkMetric extends Equatable {
  final String metricId;
  final MetricType type;
  final double value;
  final String source;
  final Map<String, dynamic> tags;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const NetworkMetric({
    required this.metricId,
    required this.type,
    required this.value,
    required this.source,
    required this.tags,
    required this.timestamp,
    required this.metadata,
  });

  @override
  List<Object?> get props => [metricId, type, value, source, tags, timestamp, metadata];
}

/// Типы метрик
enum MetricType {
  cpuUsage,
  memoryUsage,
  networkLatency,
  networkThroughput,
  activeConnections,
  diskUsage,
  errorRate,
  responseTime,
}

/// Событие сети
class NetworkEvent extends Equatable {
  final String eventId;
  final EventType type;
  final String source;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final EventSeverity severity;

  const NetworkEvent({
    required this.eventId,
    required this.type,
    required this.source,
    required this.data,
    required this.timestamp,
    required this.severity,
  });

  @override
  List<Object?> get props => [eventId, type, source, data, timestamp, severity];
}

/// Типы событий
enum EventType {
  connection,
  error,
  security,
  performance,
  system,
}

/// Серьезность событий
enum EventSeverity {
  low,
  medium,
  high,
  critical,
}

/// Алерт сети
class NetworkAlert extends Equatable {
  final String alertId;
  final String name;
  final AlertType type;
  final String condition;
  final AlertSeverity severity;
  final Map<String, dynamic> parameters;
  final AlertStatus status;
  final DateTime createdAt;
  DateTime? lastTriggered;
  int triggerCount;

  NetworkAlert({
    required this.alertId,
    required this.name,
    required this.type,
    required this.condition,
    required this.severity,
    required this.parameters,
    required this.status,
    required this.createdAt,
    this.lastTriggered,
    required this.triggerCount,
  });

  @override
  List<Object?> get props =>
      [alertId, name, type, condition, severity, parameters, status, createdAt, lastTriggered, triggerCount];
}

/// Типы алертов
enum AlertType {
  metric,
  event,
  threshold,
  anomaly,
}

/// Серьезность алертов
enum AlertSeverity {
  low,
  medium,
  high,
  critical,
}

/// Статусы алертов
enum AlertStatus {
  active,
  paused,
  resolved,
  disabled,
}

/// Отчет о сети
class NetworkReport extends Equatable {
  final String reportId;
  final ReportType type;
  final DateTime from;
  final DateTime to;
  final Map<String, dynamic> filters;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? errorMessage;

  const NetworkReport({
    required this.reportId,
    required this.type,
    required this.from,
    required this.to,
    required this.filters,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [reportId, type, from, to, filters, status, createdAt, completedAt, errorMessage];
}

/// Типы отчетов
enum ReportType {
  performance,
  security,
  usage,
  capacity,
}

/// Статусы отчетов
enum ReportStatus {
  generating,
  completed,
  failed,
}

/// Инсайт сети
class NetworkInsight extends Equatable {
  final String insightId;
  final InsightType type;
  final String title;
  final String description;
  final ImportanceLevel importance;
  final String source;
  final Map<String, dynamic> data;
  final DateTime generatedAt;

  const NetworkInsight({
    required this.insightId,
    required this.type,
    required this.title,
    required this.description,
    required this.importance,
    required this.source,
    required this.data,
    required this.generatedAt,
  });

  @override
  List<Object?> get props => [insightId, type, title, description, importance, source, data, generatedAt];
}

/// Типы инсайтов
enum InsightType {
  trend,
  anomaly,
  pattern,
  frequency,
  correlation,
}

/// Уровни важности
enum ImportanceLevel {
  low,
  medium,
  high,
  critical,
}

/// Прогноз сети
class NetworkPrediction extends Equatable {
  final String predictionId;
  final String metricId;
  final PredictionType type;
  final double currentValue;
  final double predictedValue;
  final double confidence;
  final DateTime predictedAt;
  final DateTime generatedAt;

  const NetworkPrediction({
    required this.predictionId,
    required this.metricId,
    required this.type,
    required this.currentValue,
    required this.predictedValue,
    required this.confidence,
    required this.predictedAt,
    required this.generatedAt,
  });

  @override
  List<Object?> get props =>
      [predictionId, metricId, type, currentValue, predictedValue, confidence, predictedAt, generatedAt];
}

/// Типы прогнозов
enum PredictionType {
  trend,
  anomaly,
  capacity,
  failure,
}

/// Анализ производительности сети
class NetworkPerformanceAnalysis extends Equatable {
  final PerformancePeriod period;
  final int totalMetrics;
  final int totalEvents;
  final Duration averageResponseTime;
  final double uptime;
  final double errorRate;
  final double throughput;
  final Duration latency;
  final double availability;
  final double performanceScore;
  final List<String> bottlenecks;
  final List<String> recommendations;
  final DateTime analyzedAt;

  const NetworkPerformanceAnalysis({
    required this.period,
    required this.totalMetrics,
    required this.totalEvents,
    required this.averageResponseTime,
    required this.uptime,
    required this.errorRate,
    required this.throughput,
    required this.latency,
    required this.availability,
    required this.performanceScore,
    required this.bottlenecks,
    required this.recommendations,
    required this.analyzedAt,
  });

  @override
  List<Object?> get props => [
        period,
        totalMetrics,
        totalEvents,
        averageResponseTime,
        uptime,
        errorRate,
        throughput,
        latency,
        availability,
        performanceScore,
        bottlenecks,
        recommendations,
        analyzedAt
      ];
}

/// Период производительности
class PerformancePeriod extends Equatable {
  final DateTime from;
  final DateTime to;

  const PerformancePeriod({required this.from, required this.to});

  @override
  List<Object?> get props => [from, to];
}

/// Анализ безопасности сети
class NetworkSecurityAnalysis extends Equatable {
  final PerformancePeriod period;
  final int totalSecurityEvents;
  final ThreatLevel threatLevel;
  final Map<String, int> attackTypes;
  final List<String> affectedSources;
  final List<String> mitigationActions;
  final double securityScore;
  final List<String> vulnerabilities;
  final List<String> recommendations;
  final DateTime analyzedAt;

  const NetworkSecurityAnalysis({
    required this.period,
    required this.totalSecurityEvents,
    required this.threatLevel,
    required this.attackTypes,
    required this.affectedSources,
    required this.mitigationActions,
    required this.securityScore,
    required this.vulnerabilities,
    required this.recommendations,
    required this.analyzedAt,
  });

  @override
  List<Object?> get props => [
        period,
        totalSecurityEvents,
        threatLevel,
        attackTypes,
        affectedSources,
        mitigationActions,
        securityScore,
        vulnerabilities,
        recommendations,
        analyzedAt
      ];
}

/// Уровни угроз
enum ThreatLevel {
  low,
  medium,
  high,
  critical,
}
