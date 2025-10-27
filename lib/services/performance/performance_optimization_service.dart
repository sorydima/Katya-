import 'dart:async';

import 'package:equatable/equatable.dart';

/// Сервис для оптимизации производительности
class PerformanceOptimizationService {
  static final PerformanceOptimizationService _instance = PerformanceOptimizationService._internal();

  factory PerformanceOptimizationService() => _instance;

  PerformanceOptimizationService._internal();

  final Map<String, OptimizationRule> _rules = {};
  final Map<String, OptimizationAction> _actions = {};
  final List<OptimizationRecommendation> _recommendations = [];
  final StreamController<OptimizationEvent> _eventController = StreamController<OptimizationEvent>.broadcast();

  bool _isOptimizing = false;
  Timer? _optimizationTimer;

  /// Поток событий оптимизации
  Stream<OptimizationEvent> get events => _eventController.stream;

  /// Инициализация правил оптимизации
  Future<void> initialize() async {
    _initializeDefaultRules();
    _initializeDefaultActions();
    print('Performance optimization service initialized');
  }

  /// Инициализация правил по умолчанию
  void _initializeDefaultRules() {
    // Правила для CPU
    _addRule(OptimizationRule(
      id: 'cpu_high_usage',
      name: 'High CPU Usage',
      description: 'CPU usage is consistently above 80%',
      condition: (metrics) => metrics['cpu_usage'] > 80,
      severity: OptimizationSeverity.high,
      category: OptimizationCategory.cpu,
      actions: const ['scale_cpu', 'optimize_code'],
    ));

    // Правила для памяти
    _addRule(OptimizationRule(
      id: 'memory_high_usage',
      name: 'High Memory Usage',
      description: 'Memory usage is consistently above 85%',
      condition: (metrics) => metrics['memory_usage'] > 85,
      severity: OptimizationSeverity.high,
      category: OptimizationCategory.memory,
      actions: const ['scale_memory', 'optimize_memory'],
    ));

    // Правила для диска
    _addRule(OptimizationRule(
      id: 'disk_high_usage',
      name: 'High Disk Usage',
      description: 'Disk usage is above 90%',
      condition: (metrics) => metrics['disk_usage'] > 90,
      severity: OptimizationSeverity.critical,
      category: OptimizationCategory.storage,
      actions: const ['cleanup_disk', 'expand_storage'],
    ));

    // Правила для сети
    _addRule(OptimizationRule(
      id: 'network_high_latency',
      name: 'High Network Latency',
      description: 'Network latency is above 100ms',
      condition: (metrics) => metrics['network_latency'] > 100,
      severity: OptimizationSeverity.medium,
      category: OptimizationCategory.network,
      actions: const ['optimize_network', 'check_connectivity'],
    ));

    // Правила для базы данных
    _addRule(OptimizationRule(
      id: 'db_slow_queries',
      name: 'Slow Database Queries',
      description: 'Average query time is above 500ms',
      condition: (metrics) => metrics['db_query_time'] > 500,
      severity: OptimizationSeverity.medium,
      category: OptimizationCategory.database,
      actions: const ['optimize_queries', 'add_indexes'],
    ));

    // Правила для кэша
    _addRule(OptimizationRule(
      id: 'cache_low_hit_rate',
      name: 'Low Cache Hit Rate',
      description: 'Cache hit rate is below 80%',
      condition: (metrics) => metrics['cache_hit_rate'] < 80,
      severity: OptimizationSeverity.medium,
      category: OptimizationCategory.cache,
      actions: const ['optimize_cache', 'increase_cache_size'],
    ));

    // Правила для приложения
    _addRule(OptimizationRule(
      id: 'app_high_response_time',
      name: 'High Application Response Time',
      description: 'Average response time is above 1000ms',
      condition: (metrics) => metrics['response_time'] > 1000,
      severity: OptimizationSeverity.high,
      category: OptimizationCategory.application,
      actions: const ['optimize_code', 'scale_application'],
    ));

    _addRule(OptimizationRule(
      id: 'app_high_error_rate',
      name: 'High Application Error Rate',
      description: 'Error rate is above 5%',
      condition: (metrics) => metrics['error_rate'] > 5,
      severity: OptimizationSeverity.critical,
      category: OptimizationCategory.application,
      actions: const ['fix_errors', 'improve_error_handling'],
    ));
  }

  /// Инициализация действий по умолчанию
  void _initializeDefaultActions() {
    // Действия для CPU
    _addAction(OptimizationAction(
      id: 'scale_cpu',
      name: 'Scale CPU Resources',
      description: 'Increase CPU allocation or add more CPU cores',
      category: OptimizationCategory.cpu,
      type: OptimizationActionType.automatic,
      execute: () => _scaleCpuResources(),
    ));

    _addAction(OptimizationAction(
      id: 'optimize_code',
      name: 'Optimize Code Performance',
      description: 'Identify and optimize slow code paths',
      category: OptimizationCategory.cpu,
      type: OptimizationActionType.manual,
      execute: () => _optimizeCodePerformance(),
    ));

    // Действия для памяти
    _addAction(OptimizationAction(
      id: 'scale_memory',
      name: 'Scale Memory Resources',
      description: 'Increase memory allocation',
      category: OptimizationCategory.memory,
      type: OptimizationActionType.automatic,
      execute: () => _scaleMemoryResources(),
    ));

    _addAction(OptimizationAction(
      id: 'optimize_memory',
      name: 'Optimize Memory Usage',
      description: 'Identify and fix memory leaks',
      category: OptimizationCategory.memory,
      type: OptimizationActionType.manual,
      execute: () => _optimizeMemoryUsage(),
    ));

    // Действия для диска
    _addAction(OptimizationAction(
      id: 'cleanup_disk',
      name: 'Clean Up Disk Space',
      description: 'Remove temporary files and old logs',
      category: OptimizationCategory.storage,
      type: OptimizationActionType.automatic,
      execute: () => _cleanupDiskSpace(),
    ));

    _addAction(OptimizationAction(
      id: 'expand_storage',
      name: 'Expand Storage',
      description: 'Add more storage capacity',
      category: OptimizationCategory.storage,
      type: OptimizationActionType.manual,
      execute: () => _expandStorage(),
    ));

    // Действия для сети
    _addAction(OptimizationAction(
      id: 'optimize_network',
      name: 'Optimize Network Configuration',
      description: 'Optimize network settings and routing',
      category: OptimizationCategory.network,
      type: OptimizationActionType.manual,
      execute: () => _optimizeNetworkConfiguration(),
    ));

    _addAction(OptimizationAction(
      id: 'check_connectivity',
      name: 'Check Network Connectivity',
      description: 'Diagnose network connectivity issues',
      category: OptimizationCategory.network,
      type: OptimizationActionType.automatic,
      execute: () => _checkNetworkConnectivity(),
    ));

    // Действия для базы данных
    _addAction(OptimizationAction(
      id: 'optimize_queries',
      name: 'Optimize Database Queries',
      description: 'Analyze and optimize slow queries',
      category: OptimizationCategory.database,
      type: OptimizationActionType.manual,
      execute: () => _optimizeDatabaseQueries(),
    ));

    _addAction(OptimizationAction(
      id: 'add_indexes',
      name: 'Add Database Indexes',
      description: 'Add missing indexes to improve query performance',
      category: OptimizationCategory.database,
      type: OptimizationActionType.manual,
      execute: () => _addDatabaseIndexes(),
    ));

    // Действия для кэша
    _addAction(OptimizationAction(
      id: 'optimize_cache',
      name: 'Optimize Cache Configuration',
      description: 'Optimize cache settings and eviction policies',
      category: OptimizationCategory.cache,
      type: OptimizationActionType.manual,
      execute: () => _optimizeCacheConfiguration(),
    ));

    _addAction(OptimizationAction(
      id: 'increase_cache_size',
      name: 'Increase Cache Size',
      description: 'Increase cache memory allocation',
      category: OptimizationCategory.cache,
      type: OptimizationActionType.automatic,
      execute: () => _increaseCacheSize(),
    ));

    // Действия для приложения
    _addAction(OptimizationAction(
      id: 'scale_application',
      name: 'Scale Application',
      description: 'Scale application horizontally or vertically',
      category: OptimizationCategory.application,
      type: OptimizationActionType.automatic,
      execute: () => _scaleApplication(),
    ));

    _addAction(OptimizationAction(
      id: 'fix_errors',
      name: 'Fix Application Errors',
      description: 'Investigate and fix application errors',
      category: OptimizationCategory.application,
      type: OptimizationActionType.manual,
      execute: () => _fixApplicationErrors(),
    ));

    _addAction(OptimizationAction(
      id: 'improve_error_handling',
      name: 'Improve Error Handling',
      description: 'Enhance error handling and recovery mechanisms',
      category: OptimizationCategory.application,
      type: OptimizationActionType.manual,
      execute: () => _improveErrorHandling(),
    ));
  }

  /// Запуск автоматической оптимизации
  Future<void> startAutoOptimization({Duration interval = const Duration(minutes: 5)}) async {
    if (_isOptimizing) return;

    _isOptimizing = true;
    _optimizationTimer = Timer.periodic(interval, (_) => _performOptimization());

    _emitEvent(const OptimizationEvent.autoOptimizationStarted());
    print('Auto optimization started');
  }

  /// Остановка автоматической оптимизации
  Future<void> stopAutoOptimization() async {
    _isOptimizing = false;
    _optimizationTimer?.cancel();
    _optimizationTimer = null;

    _emitEvent(const OptimizationEvent.autoOptimizationStopped());
    print('Auto optimization stopped');
  }

  /// Анализ производительности и генерация рекомендаций
  Future<List<OptimizationRecommendation>> analyzePerformance(
    Map<String, double> metrics,
  ) async {
    final List<OptimizationRecommendation> recommendations = [];

    for (final OptimizationRule rule in _rules.values) {
      if (rule.condition(metrics)) {
        final OptimizationRecommendation recommendation = OptimizationRecommendation(
          id: '${rule.id}_${DateTime.now().millisecondsSinceEpoch}',
          ruleId: rule.id,
          title: rule.name,
          description: rule.description,
          severity: rule.severity,
          category: rule.category,
          suggestedActions: rule.actions,
          metrics: metrics,
          createdAt: DateTime.now(),
          status: OptimizationStatus.pending,
        );

        recommendations.add(recommendation);
      }
    }

    // Сортировка по серьезности
    recommendations.sort((a, b) => _getSeverityPriority(b.severity).compareTo(_getSeverityPriority(a.severity)));

    _recommendations.addAll(recommendations);
    _emitEvent(OptimizationEvent.recommendationsGenerated(recommendations));

    return recommendations;
  }

  /// Выполнение оптимизации
  Future<void> _performOptimization() async {
    try {
      // Получение текущих метрик (в реальном приложении из системы мониторинга)
      final Map<String, double> metrics = await _getCurrentMetrics();

      // Анализ и генерация рекомендаций
      final List<OptimizationRecommendation> recommendations = await analyzePerformance(metrics);

      // Выполнение автоматических действий
      for (final OptimizationRecommendation recommendation in recommendations) {
        if (recommendation.severity == OptimizationSeverity.critical ||
            recommendation.severity == OptimizationSeverity.high) {
          await _executeAutomaticActions(recommendation);
        }
      }

      _emitEvent(OptimizationEvent.optimizationCompleted(recommendations));
    } catch (e) {
      _emitEvent(OptimizationEvent.optimizationError(e.toString()));
    }
  }

  /// Выполнение автоматических действий
  Future<void> _executeAutomaticActions(OptimizationRecommendation recommendation) async {
    for (final String actionId in recommendation.suggestedActions) {
      final OptimizationAction? action = _actions[actionId];
      if (action != null && action.type == OptimizationActionType.automatic) {
        try {
          final OptimizationResult result = await action.execute();

          _emitEvent(OptimizationEvent.actionExecuted(
            actionId: actionId,
            recommendationId: recommendation.id,
            result: result,
          ));
        } catch (e) {
          _emitEvent(OptimizationEvent.actionFailed(
            actionId: actionId,
            recommendationId: recommendation.id,
            error: e.toString(),
          ));
        }
      }
    }
  }

  /// Выполнение действия оптимизации
  Future<OptimizationResult> executeAction(String actionId, {String? recommendationId}) async {
    final OptimizationAction? action = _actions[actionId];
    if (action == null) {
      throw Exception('Action not found: $actionId');
    }

    try {
      final OptimizationResult result = await action.execute();

      _emitEvent(OptimizationEvent.actionExecuted(
        actionId: actionId,
        recommendationId: recommendationId,
        result: result,
      ));

      return result;
    } catch (e) {
      _emitEvent(OptimizationEvent.actionFailed(
        actionId: actionId,
        recommendationId: recommendationId,
        error: e.toString(),
      ));
      rethrow;
    }
  }

  /// Получение рекомендаций
  List<OptimizationRecommendation> getRecommendations({
    OptimizationSeverity? severity,
    OptimizationCategory? category,
    OptimizationStatus? status,
  }) {
    List<OptimizationRecommendation> filtered = _recommendations;

    if (severity != null) {
      filtered = filtered.where((r) => r.severity == severity).toList();
    }

    if (category != null) {
      filtered = filtered.where((r) => r.category == category).toList();
    }

    if (status != null) {
      filtered = filtered.where((r) => r.status == status).toList();
    }

    return filtered;
  }

  /// Получение правил
  List<OptimizationRule> getRules() => _rules.values.toList();

  /// Получение действий
  List<OptimizationAction> getActions() => _actions.values.toList();

  /// Получение статистики оптимизации
  OptimizationStatistics getStatistics() {
    final int totalRecommendations = _recommendations.length;
    final int pendingRecommendations = _recommendations.where((r) => r.status == OptimizationStatus.pending).length;
    final int completedRecommendations = _recommendations.where((r) => r.status == OptimizationStatus.completed).length;
    final int criticalRecommendations =
        _recommendations.where((r) => r.severity == OptimizationSeverity.critical).length;

    return OptimizationStatistics(
      totalRecommendations: totalRecommendations,
      pendingRecommendations: pendingRecommendations,
      completedRecommendations: completedRecommendations,
      criticalRecommendations: criticalRecommendations,
      isAutoOptimizing: _isOptimizing,
      lastUpdate: DateTime.now(),
    );
  }

  /// Вспомогательные методы

  void _addRule(OptimizationRule rule) {
    _rules[rule.id] = rule;
  }

  void _addAction(OptimizationAction action) {
    _actions[action.id] = action;
  }

  int _getSeverityPriority(OptimizationSeverity severity) {
    switch (severity) {
      case OptimizationSeverity.low:
        return 1;
      case OptimizationSeverity.medium:
        return 2;
      case OptimizationSeverity.high:
        return 3;
      case OptimizationSeverity.critical:
        return 4;
    }
  }

  Future<Map<String, double>> _getCurrentMetrics() async {
    // В реальном приложении получать из системы мониторинга
    return {
      'cpu_usage': 75.0,
      'memory_usage': 80.0,
      'disk_usage': 85.0,
      'network_latency': 50.0,
      'db_query_time': 300.0,
      'cache_hit_rate': 85.0,
      'response_time': 800.0,
      'error_rate': 2.0,
    };
  }

  // Реализации действий оптимизации

  Future<OptimizationResult> _scaleCpuResources() async {
    // TODO: Implement actual CPU scaling
    await Future.delayed(const Duration(seconds: 1));
    return const OptimizationResult(
      success: true,
      message: 'CPU resources scaled successfully',
      metrics: {'cpu_usage': 60.0},
    );
  }

  Future<OptimizationResult> _optimizeCodePerformance() async {
    // TODO: Implement code optimization
    await Future.delayed(const Duration(seconds: 2));
    return const OptimizationResult(
      success: true,
      message: 'Code performance optimization completed',
      metrics: {'cpu_usage': 70.0},
    );
  }

  Future<OptimizationResult> _scaleMemoryResources() async {
    // TODO: Implement memory scaling
    await Future.delayed(const Duration(seconds: 1));
    return const OptimizationResult(
      success: true,
      message: 'Memory resources scaled successfully',
      metrics: {'memory_usage': 70.0},
    );
  }

  Future<OptimizationResult> _optimizeMemoryUsage() async {
    // TODO: Implement memory optimization
    await Future.delayed(const Duration(seconds: 2));
    return const OptimizationResult(
      success: true,
      message: 'Memory usage optimization completed',
      metrics: {'memory_usage': 75.0},
    );
  }

  Future<OptimizationResult> _cleanupDiskSpace() async {
    // TODO: Implement disk cleanup
    await Future.delayed(const Duration(seconds: 3));
    return const OptimizationResult(
      success: true,
      message: 'Disk cleanup completed',
      metrics: {'disk_usage': 80.0},
    );
  }

  Future<OptimizationResult> _expandStorage() async {
    // TODO: Implement storage expansion
    await Future.delayed(const Duration(seconds: 5));
    return const OptimizationResult(
      success: true,
      message: 'Storage expansion completed',
      metrics: {'disk_usage': 70.0},
    );
  }

  Future<OptimizationResult> _optimizeNetworkConfiguration() async {
    // TODO: Implement network optimization
    await Future.delayed(const Duration(seconds: 2));
    return const OptimizationResult(
      success: true,
      message: 'Network configuration optimized',
      metrics: {'network_latency': 30.0},
    );
  }

  Future<OptimizationResult> _checkNetworkConnectivity() async {
    // TODO: Implement connectivity check
    await Future.delayed(const Duration(seconds: 1));
    return const OptimizationResult(
      success: true,
      message: 'Network connectivity check completed',
      metrics: {'network_latency': 40.0},
    );
  }

  Future<OptimizationResult> _optimizeDatabaseQueries() async {
    // TODO: Implement query optimization
    await Future.delayed(const Duration(seconds: 3));
    return const OptimizationResult(
      success: true,
      message: 'Database queries optimized',
      metrics: {'db_query_time': 200.0},
    );
  }

  Future<OptimizationResult> _addDatabaseIndexes() async {
    // TODO: Implement index addition
    await Future.delayed(const Duration(seconds: 4));
    return const OptimizationResult(
      success: true,
      message: 'Database indexes added',
      metrics: {'db_query_time': 150.0},
    );
  }

  Future<OptimizationResult> _optimizeCacheConfiguration() async {
    // TODO: Implement cache optimization
    await Future.delayed(const Duration(seconds: 2));
    return const OptimizationResult(
      success: true,
      message: 'Cache configuration optimized',
      metrics: {'cache_hit_rate': 90.0},
    );
  }

  Future<OptimizationResult> _increaseCacheSize() async {
    // TODO: Implement cache size increase
    await Future.delayed(const Duration(seconds: 1));
    return const OptimizationResult(
      success: true,
      message: 'Cache size increased',
      metrics: {'cache_hit_rate': 88.0},
    );
  }

  Future<OptimizationResult> _scaleApplication() async {
    // TODO: Implement application scaling
    await Future.delayed(const Duration(seconds: 3));
    return const OptimizationResult(
      success: true,
      message: 'Application scaled successfully',
      metrics: {'response_time': 600.0},
    );
  }

  Future<OptimizationResult> _fixApplicationErrors() async {
    // TODO: Implement error fixing
    await Future.delayed(const Duration(seconds: 4));
    return const OptimizationResult(
      success: true,
      message: 'Application errors fixed',
      metrics: {'error_rate': 1.0},
    );
  }

  Future<OptimizationResult> _improveErrorHandling() async {
    // TODO: Implement error handling improvement
    await Future.delayed(const Duration(seconds: 3));
    return const OptimizationResult(
      success: true,
      message: 'Error handling improved',
      metrics: {'error_rate': 0.5},
    );
  }

  void _emitEvent(OptimizationEvent event) {
    _eventController.add(event);
  }

  void dispose() {
    stopAutoOptimization();
    _eventController.close();
  }
}

/// Серьезность оптимизации
enum OptimizationSeverity {
  low,
  medium,
  high,
  critical,
}

/// Категория оптимизации
enum OptimizationCategory {
  cpu,
  memory,
  storage,
  network,
  database,
  cache,
  application,
}

/// Тип действия оптимизации
enum OptimizationActionType {
  automatic,
  manual,
}

/// Статус оптимизации
enum OptimizationStatus {
  pending,
  inProgress,
  completed,
  failed,
  cancelled,
}

/// Правило оптимизации
class OptimizationRule extends Equatable {
  final String id;
  final String name;
  final String description;
  final bool Function(Map<String, double> metrics) condition;
  final OptimizationSeverity severity;
  final OptimizationCategory category;
  final List<String> actions;

  const OptimizationRule({
    required this.id,
    required this.name,
    required this.description,
    required this.condition,
    required this.severity,
    required this.category,
    required this.actions,
  });

  @override
  List<Object?> get props => [id, name, description, condition, severity, category, actions];
}

/// Действие оптимизации
class OptimizationAction extends Equatable {
  final String id;
  final String name;
  final String description;
  final OptimizationCategory category;
  final OptimizationActionType type;
  final Future<OptimizationResult> Function() execute;

  const OptimizationAction({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.type,
    required this.execute,
  });

  @override
  List<Object?> get props => [id, name, description, category, type, execute];
}

/// Рекомендация оптимизации
class OptimizationRecommendation extends Equatable {
  final String id;
  final String ruleId;
  final String title;
  final String description;
  final OptimizationSeverity severity;
  final OptimizationCategory category;
  final List<String> suggestedActions;
  final Map<String, double> metrics;
  final DateTime createdAt;
  final OptimizationStatus status;

  const OptimizationRecommendation({
    required this.id,
    required this.ruleId,
    required this.title,
    required this.description,
    required this.severity,
    required this.category,
    required this.suggestedActions,
    required this.metrics,
    required this.createdAt,
    required this.status,
  });

  @override
  List<Object?> get props =>
      [id, ruleId, title, description, severity, category, suggestedActions, metrics, createdAt, status];
}

/// Результат оптимизации
class OptimizationResult extends Equatable {
  final bool success;
  final String message;
  final Map<String, double>? metrics;
  final String? error;

  const OptimizationResult({
    required this.success,
    required this.message,
    this.metrics,
    this.error,
  });

  @override
  List<Object?> get props => [success, message, metrics, error];
}

/// Статистика оптимизации
class OptimizationStatistics extends Equatable {
  final int totalRecommendations;
  final int pendingRecommendations;
  final int completedRecommendations;
  final int criticalRecommendations;
  final bool isAutoOptimizing;
  final DateTime lastUpdate;

  const OptimizationStatistics({
    required this.totalRecommendations,
    required this.pendingRecommendations,
    required this.completedRecommendations,
    required this.criticalRecommendations,
    required this.isAutoOptimizing,
    required this.lastUpdate,
  });

  @override
  List<Object?> get props => [
        totalRecommendations,
        pendingRecommendations,
        completedRecommendations,
        criticalRecommendations,
        isAutoOptimizing,
        lastUpdate
      ];
}

/// События оптимизации
abstract class OptimizationEvent extends Equatable {
  const OptimizationEvent();

  const factory OptimizationEvent.autoOptimizationStarted() = AutoOptimizationStartedEvent;
  const factory OptimizationEvent.autoOptimizationStopped() = AutoOptimizationStoppedEvent;
  const factory OptimizationEvent.recommendationsGenerated(List<OptimizationRecommendation> recommendations) =
      RecommendationsGeneratedEvent;
  const factory OptimizationEvent.optimizationCompleted(List<OptimizationRecommendation> recommendations) =
      OptimizationCompletedEvent;
  const factory OptimizationEvent.optimizationError(String error) = OptimizationErrorEvent;
  const factory OptimizationEvent.actionExecuted({
    required String actionId,
    String? recommendationId,
    required OptimizationResult result,
  }) = ActionExecutedEvent;
  const factory OptimizationEvent.actionFailed({
    required String actionId,
    String? recommendationId,
    required String error,
  }) = ActionFailedEvent;
}

class AutoOptimizationStartedEvent extends OptimizationEvent {
  const AutoOptimizationStartedEvent();

  @override
  List<Object?> get props => [];
}

class AutoOptimizationStoppedEvent extends OptimizationEvent {
  const AutoOptimizationStoppedEvent();

  @override
  List<Object?> get props => [];
}

class RecommendationsGeneratedEvent extends OptimizationEvent {
  final List<OptimizationRecommendation> recommendations;

  const RecommendationsGeneratedEvent(this.recommendations);

  @override
  List<Object?> get props => [recommendations];
}

class OptimizationCompletedEvent extends OptimizationEvent {
  final List<OptimizationRecommendation> recommendations;

  const OptimizationCompletedEvent(this.recommendations);

  @override
  List<Object?> get props => [recommendations];
}

class OptimizationErrorEvent extends OptimizationEvent {
  final String error;

  const OptimizationErrorEvent(this.error);

  @override
  List<Object?> get props => [error];
}

class ActionExecutedEvent extends OptimizationEvent {
  final String actionId;
  final String? recommendationId;
  final OptimizationResult result;

  const ActionExecutedEvent({
    required this.actionId,
    this.recommendationId,
    required this.result,
  });

  @override
  List<Object?> get props => [actionId, recommendationId, result];
}

class ActionFailedEvent extends OptimizationEvent {
  final String actionId;
  final String? recommendationId;
  final String error;

  const ActionFailedEvent({
    required this.actionId,
    this.recommendationId,
    required this.error,
  });

  @override
  List<Object?> get props => [actionId, recommendationId, error];
}
