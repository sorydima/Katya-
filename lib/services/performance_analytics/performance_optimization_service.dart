import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// Перечисление типов оптимизации
enum OptimizationType {
  cpu,
  memory,
  disk,
  network,
  database,
  api,
  cache,
  algorithm,
  architecture,
  configuration,
}

/// Перечисление приоритетов оптимизации
enum OptimizationPriority {
  low,
  medium,
  high,
  critical,
}

/// Перечисление статусов рекомендации
enum RecommendationStatus {
  pending,
  inProgress,
  completed,
  rejected,
  failed,
}

/// Модель рекомендации по оптимизации
class OptimizationRecommendation extends Equatable {
  final String id;
  final String title;
  final String description;
  final OptimizationType type;
  final OptimizationPriority priority;
  final RecommendationStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final Map<String, dynamic>? metadata;
  final List<String>? steps;
  final double? expectedImprovement;
  final String? category;

  const OptimizationRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    this.status = RecommendationStatus.pending,
    required this.createdAt,
    this.completedAt,
    this.metadata,
    this.steps,
    this.expectedImprovement,
    this.category,
  });

  OptimizationRecommendation copyWith({
    String? id,
    String? title,
    String? description,
    OptimizationType? type,
    OptimizationPriority? priority,
    RecommendationStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    Map<String, dynamic>? metadata,
    List<String>? steps,
    double? expectedImprovement,
    String? category,
  }) {
    return OptimizationRecommendation(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      metadata: metadata ?? this.metadata,
      steps: steps ?? this.steps,
      expectedImprovement: expectedImprovement ?? this.expectedImprovement,
      category: category ?? this.category,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        priority,
        status,
        createdAt,
        completedAt,
        metadata,
        steps,
        expectedImprovement,
        category
      ];
}

/// Модель анализа производительности
class PerformanceAnalysis extends Equatable {
  final String id;
  final DateTime timestamp;
  final Map<String, dynamic> metrics;
  final List<OptimizationRecommendation> recommendations;
  final Map<String, dynamic> summary;
  final String? notes;

  const PerformanceAnalysis({
    required this.id,
    required this.timestamp,
    required this.metrics,
    required this.recommendations,
    required this.summary,
    this.notes,
  });

  @override
  List<Object?> get props => [id, timestamp, metrics, recommendations, summary, notes];
}

/// Модель конфигурации оптимизации
class OptimizationConfig extends Equatable {
  final bool enableAutoOptimization;
  final Duration analysisInterval;
  final Map<OptimizationType, bool> enabledTypes;
  final Map<OptimizationPriority, bool> enabledPriorities;
  final double performanceThreshold;
  final int maxRecommendations;

  const OptimizationConfig({
    this.enableAutoOptimization = false,
    this.analysisInterval = const Duration(hours: 1),
    this.enabledTypes = const {},
    this.enabledPriorities = const {},
    this.performanceThreshold = 0.8,
    this.maxRecommendations = 50,
  });

  @override
  List<Object?> get props => [
        enableAutoOptimization,
        analysisInterval,
        enabledTypes,
        enabledPriorities,
        performanceThreshold,
        maxRecommendations
      ];
}

/// Сервис для анализа производительности и генерации рекомендаций по оптимизации
class PerformanceOptimizationService {
  static final PerformanceOptimizationService _instance = PerformanceOptimizationService._internal();

  final List<OptimizationRecommendation> _recommendations = [];
  final List<PerformanceAnalysis> _analyses = [];
  final Uuid _uuid = const Uuid();
  final Random _random = Random();
  OptimizationConfig _config = const OptimizationConfig();
  Timer? _analysisTimer;

  factory PerformanceOptimizationService() => _instance;

  PerformanceOptimizationService._internal() {
    _initializeDefaultConfig();
    if (_config.enableAutoOptimization) {
      _startAutoAnalysis();
    }
  }

  /// Инициализация конфигурации по умолчанию
  void _initializeDefaultConfig() {
    _config = const OptimizationConfig(
      enableAutoOptimization: true,
      analysisInterval: Duration(hours: 1),
      enabledTypes: {
        OptimizationType.cpu: true,
        OptimizationType.memory: true,
        OptimizationType.disk: true,
        OptimizationType.network: true,
        OptimizationType.database: true,
        OptimizationType.api: true,
        OptimizationType.cache: true,
        OptimizationType.algorithm: true,
        OptimizationType.architecture: false,
        OptimizationType.configuration: true,
      },
      enabledPriorities: {
        OptimizationPriority.low: true,
        OptimizationPriority.medium: true,
        OptimizationPriority.high: true,
        OptimizationPriority.critical: true,
      },
      performanceThreshold: 0.8,
      maxRecommendations: 50,
    );
  }

  /// Запуск автоматического анализа
  void _startAutoAnalysis() {
    _analysisTimer = Timer.periodic(_config.analysisInterval, (_) {
      performAnalysis();
    });
  }

  /// Остановка автоматического анализа
  void _stopAutoAnalysis() {
    _analysisTimer?.cancel();
    _analysisTimer = null;
  }

  /// Выполнение анализа производительности
  Future<PerformanceAnalysis> performAnalysis({Map<String, dynamic>? customMetrics}) async {
    final timestamp = DateTime.now();
    final metrics = await _collectMetrics(customMetrics);
    final recommendations = await _generateRecommendations(metrics);
    final summary = _generateSummary(metrics, recommendations);

    final analysis = PerformanceAnalysis(
      id: _uuid.v4(),
      timestamp: timestamp,
      metrics: metrics,
      recommendations: recommendations,
      summary: summary,
    );

    _analyses.add(analysis);
    _recommendations.addAll(recommendations);

    // Ограничиваем количество рекомендаций
    if (_recommendations.length > _config.maxRecommendations) {
      _recommendations.sort((a, b) => b.priority.index.compareTo(a.priority.index));
      _recommendations.removeRange(_config.maxRecommendations, _recommendations.length);
    }

    print('Performance analysis completed. Generated ${recommendations.length} recommendations.');
    return analysis;
  }

  /// Сбор метрик для анализа
  Future<Map<String, dynamic>> _collectMetrics(Map<String, dynamic>? customMetrics) async {
    final metrics = <String, dynamic>{
      'cpu': {
        'usage': 20 + _random.nextDouble() * 60, // 20-80%
        'load': 1.0 + _random.nextDouble() * 2.0, // 1.0-3.0
        'cores': Platform.numberOfProcessors,
      },
      'memory': {
        'usage': 0.3 + _random.nextDouble() * 0.4, // 30-70%
        'total': 8 * 1024 * 1024 * 1024, // 8GB
        'available': 2 * 1024 * 1024 * 1024, // 2GB
      },
      'disk': {
        'usage': 0.1 + _random.nextDouble() * 0.3, // 10-40%
        'readSpeed': 100 + _random.nextDouble() * 200, // 100-300 MB/s
        'writeSpeed': 50 + _random.nextDouble() * 150, // 50-200 MB/s
      },
      'network': {
        'throughput': 10 + _random.nextDouble() * 90, // 10-100 MB/s
        'latency': 1 + _random.nextDouble() * 49, // 1-50 ms
        'packetLoss': _random.nextDouble() * 0.01, // 0-1%
      },
      'database': {
        'queryTime': 10 + _random.nextDouble() * 100, // 10-110 ms
        'connectionPool': 0.5 + _random.nextDouble() * 0.4, // 50-90%
        'cacheHitRate': 70 + _random.nextDouble() * 25, // 70-95%
      },
      'api': {
        'responseTime': 50 + _random.nextDouble() * 200, // 50-250 ms
        'throughput': 100 + _random.nextDouble() * 900, // 100-1000 req/s
        'errorRate': _random.nextDouble() * 0.05, // 0-5%
      },
      'cache': {
        'hitRate': 70 + _random.nextDouble() * 25, // 70-95%
        'size': 0.1 + _random.nextDouble() * 0.3, // 10-40%
        'evictionRate': _random.nextDouble() * 0.1, // 0-10%
      },
    };

    if (customMetrics != null) {
      metrics.addAll(customMetrics);
    }

    return metrics;
  }

  /// Генерация рекомендаций по оптимизации
  Future<List<OptimizationRecommendation>> _generateRecommendations(Map<String, dynamic> metrics) async {
    final recommendations = <OptimizationRecommendation>[];

    // Анализ CPU
    final cpuUsage = metrics['cpu']['usage'] as double;
    if (cpuUsage > 80) {
      recommendations.add(_createCpuOptimizationRecommendation(cpuUsage));
    }

    // Анализ памяти
    final memoryUsage = metrics['memory']['usage'] as double;
    if (memoryUsage > 0.8) {
      recommendations.add(_createMemoryOptimizationRecommendation(memoryUsage));
    }

    // Анализ диска
    final diskUsage = metrics['disk']['usage'] as double;
    if (diskUsage > 0.7) {
      recommendations.add(_createDiskOptimizationRecommendation(diskUsage));
    }

    // Анализ сети
    final networkLatency = metrics['network']['latency'] as double;
    if (networkLatency > 30) {
      recommendations.add(_createNetworkOptimizationRecommendation(networkLatency));
    }

    // Анализ базы данных
    final dbQueryTime = metrics['database']['queryTime'] as double;
    if (dbQueryTime > 100) {
      recommendations.add(_createDatabaseOptimizationRecommendation(dbQueryTime));
    }

    // Анализ API
    final apiResponseTime = metrics['api']['responseTime'] as double;
    if (apiResponseTime > 200) {
      recommendations.add(_createApiOptimizationRecommendation(apiResponseTime));
    }

    // Анализ кэша
    final cacheHitRate = metrics['cache']['hitRate'] as double;
    if (cacheHitRate < 80) {
      recommendations.add(_createCacheOptimizationRecommendation(cacheHitRate));
    }

    return recommendations;
  }

  /// Создание рекомендации по оптимизации CPU
  OptimizationRecommendation _createCpuOptimizationRecommendation(double cpuUsage) {
    final priority = cpuUsage > 95
        ? OptimizationPriority.critical
        : cpuUsage > 85
            ? OptimizationPriority.high
            : OptimizationPriority.medium;

    return OptimizationRecommendation(
      id: _uuid.v4(),
      title: 'High CPU Usage Detected',
      description: 'CPU usage is at ${(cpuUsage * 100).toStringAsFixed(1)}%, which may impact system performance.',
      type: OptimizationType.cpu,
      priority: priority,
      createdAt: DateTime.now(),
      expectedImprovement: 0.2,
      category: 'Performance',
      steps: const [
        'Identify CPU-intensive processes',
        'Optimize algorithms and data structures',
        'Implement caching strategies',
        'Consider horizontal scaling',
        'Profile and optimize hot code paths',
      ],
      metadata: {
        'currentUsage': cpuUsage,
        'threshold': 0.8,
        'impact': 'High',
      },
    );
  }

  /// Создание рекомендации по оптимизации памяти
  OptimizationRecommendation _createMemoryOptimizationRecommendation(double memoryUsage) {
    final priority = memoryUsage > 0.95
        ? OptimizationPriority.critical
        : memoryUsage > 0.85
            ? OptimizationPriority.high
            : OptimizationPriority.medium;

    return OptimizationRecommendation(
      id: _uuid.v4(),
      title: 'High Memory Usage Detected',
      description: 'Memory usage is at ${(memoryUsage * 100).toStringAsFixed(1)}%, which may cause performance issues.',
      type: OptimizationType.memory,
      priority: priority,
      createdAt: DateTime.now(),
      expectedImprovement: 0.15,
      category: 'Memory Management',
      steps: const [
        'Analyze memory leaks',
        'Implement object pooling',
        'Optimize data structures',
        'Use lazy loading where appropriate',
        'Consider memory-mapped files',
      ],
      metadata: {
        'currentUsage': memoryUsage,
        'threshold': 0.8,
        'impact': 'High',
      },
    );
  }

  /// Создание рекомендации по оптимизации диска
  OptimizationRecommendation _createDiskOptimizationRecommendation(double diskUsage) {
    return OptimizationRecommendation(
      id: _uuid.v4(),
      title: 'High Disk Usage Detected',
      description: 'Disk usage is at ${(diskUsage * 100).toStringAsFixed(1)}%, which may affect I/O performance.',
      type: OptimizationType.disk,
      priority: OptimizationPriority.medium,
      createdAt: DateTime.now(),
      expectedImprovement: 0.1,
      category: 'Storage',
      steps: const [
        'Clean up temporary files',
        'Implement data compression',
        'Archive old data',
        'Optimize database indexes',
        'Consider SSD upgrade',
      ],
      metadata: {
        'currentUsage': diskUsage,
        'threshold': 0.7,
        'impact': 'Medium',
      },
    );
  }

  /// Создание рекомендации по оптимизации сети
  OptimizationRecommendation _createNetworkOptimizationRecommendation(double latency) {
    return OptimizationRecommendation(
      id: _uuid.v4(),
      title: 'High Network Latency Detected',
      description: 'Network latency is ${latency.toStringAsFixed(1)}ms, which may impact user experience.',
      type: OptimizationType.network,
      priority: OptimizationPriority.medium,
      createdAt: DateTime.now(),
      expectedImprovement: 0.3,
      category: 'Network',
      steps: const [
        'Optimize network configuration',
        'Implement connection pooling',
        'Use CDN for static content',
        'Compress data transfers',
        'Consider geographic distribution',
      ],
      metadata: {
        'currentLatency': latency,
        'threshold': 30.0,
        'impact': 'Medium',
      },
    );
  }

  /// Создание рекомендации по оптимизации базы данных
  OptimizationRecommendation _createDatabaseOptimizationRecommendation(double queryTime) {
    return OptimizationRecommendation(
      id: _uuid.v4(),
      title: 'Slow Database Queries Detected',
      description: 'Average query time is ${queryTime.toStringAsFixed(1)}ms, which may impact application performance.',
      type: OptimizationType.database,
      priority: OptimizationPriority.high,
      createdAt: DateTime.now(),
      expectedImprovement: 0.4,
      category: 'Database',
      steps: const [
        'Analyze slow query log',
        'Add missing indexes',
        'Optimize query structure',
        'Implement query caching',
        'Consider read replicas',
      ],
      metadata: {
        'currentQueryTime': queryTime,
        'threshold': 100.0,
        'impact': 'High',
      },
    );
  }

  /// Создание рекомендации по оптимизации API
  OptimizationRecommendation _createApiOptimizationRecommendation(double responseTime) {
    return OptimizationRecommendation(
      id: _uuid.v4(),
      title: 'Slow API Response Times Detected',
      description:
          'Average API response time is ${responseTime.toStringAsFixed(1)}ms, which may impact user experience.',
      type: OptimizationType.api,
      priority: OptimizationPriority.high,
      createdAt: DateTime.now(),
      expectedImprovement: 0.5,
      category: 'API Performance',
      steps: const [
        'Profile API endpoints',
        'Implement response caching',
        'Optimize database queries',
        'Use async processing',
        'Implement rate limiting',
      ],
      metadata: {
        'currentResponseTime': responseTime,
        'threshold': 200.0,
        'impact': 'High',
      },
    );
  }

  /// Создание рекомендации по оптимизации кэша
  OptimizationRecommendation _createCacheOptimizationRecommendation(double hitRate) {
    return OptimizationRecommendation(
      id: _uuid.v4(),
      title: 'Low Cache Hit Rate Detected',
      description: 'Cache hit rate is ${hitRate.toStringAsFixed(1)}%, which may indicate inefficient caching.',
      type: OptimizationType.cache,
      priority: OptimizationPriority.medium,
      createdAt: DateTime.now(),
      expectedImprovement: 0.2,
      category: 'Caching',
      steps: const [
        'Analyze cache patterns',
        'Optimize cache keys',
        'Implement cache warming',
        'Adjust cache TTL',
        'Consider cache partitioning',
      ],
      metadata: {
        'currentHitRate': hitRate,
        'threshold': 80.0,
        'impact': 'Medium',
      },
    );
  }

  /// Генерация сводки анализа
  Map<String, dynamic> _generateSummary(
      Map<String, dynamic> metrics, List<OptimizationRecommendation> recommendations) {
    final criticalCount = recommendations.where((r) => r.priority == OptimizationPriority.critical).length;
    final highCount = recommendations.where((r) => r.priority == OptimizationPriority.high).length;
    final mediumCount = recommendations.where((r) => r.priority == OptimizationPriority.medium).length;
    final lowCount = recommendations.where((r) => r.priority == OptimizationPriority.low).length;

    return {
      'totalRecommendations': recommendations.length,
      'criticalRecommendations': criticalCount,
      'highRecommendations': highCount,
      'mediumRecommendations': mediumCount,
      'lowRecommendations': lowCount,
      'performanceScore': _calculatePerformanceScore(metrics),
      'topIssues': _getTopIssues(metrics),
      'estimatedImprovement': _calculateEstimatedImprovement(recommendations),
    };
  }

  /// Расчет оценки производительности
  double _calculatePerformanceScore(Map<String, dynamic> metrics) {
    double score = 100.0;

    // CPU penalty
    final cpuUsage = metrics['cpu']['usage'] as double;
    if (cpuUsage > 80) score -= (cpuUsage - 80) * 2;

    // Memory penalty
    final memoryUsage = metrics['memory']['usage'] as double;
    if (memoryUsage > 0.8) score -= (memoryUsage - 0.8) * 100;

    // Disk penalty
    final diskUsage = metrics['disk']['usage'] as double;
    if (diskUsage > 0.7) score -= (diskUsage - 0.7) * 50;

    // Network penalty
    final networkLatency = metrics['network']['latency'] as double;
    if (networkLatency > 30) score -= (networkLatency - 30) * 0.5;

    // Database penalty
    final dbQueryTime = metrics['database']['queryTime'] as double;
    if (dbQueryTime > 100) score -= (dbQueryTime - 100) * 0.2;

    // API penalty
    final apiResponseTime = metrics['api']['responseTime'] as double;
    if (apiResponseTime > 200) score -= (apiResponseTime - 200) * 0.1;

    // Cache penalty
    final cacheHitRate = metrics['cache']['hitRate'] as double;
    if (cacheHitRate < 80) score -= (80 - cacheHitRate) * 0.5;

    return max(0, min(100, score));
  }

  /// Получение основных проблем
  List<String> _getTopIssues(Map<String, dynamic> metrics) {
    final issues = <String>[];

    final cpuUsage = metrics['cpu']['usage'] as double;
    if (cpuUsage > 80) issues.add('High CPU usage (${(cpuUsage * 100).toStringAsFixed(1)}%)');

    final memoryUsage = metrics['memory']['usage'] as double;
    if (memoryUsage > 0.8) issues.add('High memory usage (${(memoryUsage * 100).toStringAsFixed(1)}%)');

    final diskUsage = metrics['disk']['usage'] as double;
    if (diskUsage > 0.7) issues.add('High disk usage (${(diskUsage * 100).toStringAsFixed(1)}%)');

    final networkLatency = metrics['network']['latency'] as double;
    if (networkLatency > 30) issues.add('High network latency (${networkLatency.toStringAsFixed(1)}ms)');

    final dbQueryTime = metrics['database']['queryTime'] as double;
    if (dbQueryTime > 100) issues.add('Slow database queries (${dbQueryTime.toStringAsFixed(1)}ms)');

    final apiResponseTime = metrics['api']['responseTime'] as double;
    if (apiResponseTime > 200) issues.add('Slow API responses (${apiResponseTime.toStringAsFixed(1)}ms)');

    final cacheHitRate = metrics['cache']['hitRate'] as double;
    if (cacheHitRate < 80) issues.add('Low cache hit rate (${cacheHitRate.toStringAsFixed(1)}%)');

    return issues.take(5).toList();
  }

  /// Расчет ожидаемого улучшения
  double _calculateEstimatedImprovement(List<OptimizationRecommendation> recommendations) {
    if (recommendations.isEmpty) return 0.0;

    final totalImprovement = recommendations.map((r) => r.expectedImprovement ?? 0.0).reduce((a, b) => a + b);

    return min(1.0, totalImprovement / recommendations.length);
  }

  /// Получение всех рекомендаций
  List<OptimizationRecommendation> getAllRecommendations() {
    return List<OptimizationRecommendation>.from(_recommendations);
  }

  /// Получение рекомендаций по типу
  List<OptimizationRecommendation> getRecommendationsByType(OptimizationType type) {
    return _recommendations.where((r) => r.type == type).toList();
  }

  /// Получение рекомендаций по приоритету
  List<OptimizationRecommendation> getRecommendationsByPriority(OptimizationPriority priority) {
    return _recommendations.where((r) => r.priority == priority).toList();
  }

  /// Получение рекомендаций по статусу
  List<OptimizationRecommendation> getRecommendationsByStatus(RecommendationStatus status) {
    return _recommendations.where((r) => r.status == status).toList();
  }

  /// Обновление статуса рекомендации
  void updateRecommendationStatus(String id, RecommendationStatus status) {
    final index = _recommendations.indexWhere((r) => r.id == id);
    if (index != -1) {
      final recommendation = _recommendations[index];
      _recommendations[index] = recommendation.copyWith(
        status: status,
        completedAt: status == RecommendationStatus.completed ? DateTime.now() : null,
      );
    }
  }

  /// Получение всех анализов
  List<PerformanceAnalysis> getAllAnalyses() {
    return List<PerformanceAnalysis>.from(_analyses);
  }

  /// Получение последнего анализа
  PerformanceAnalysis? getLastAnalysis() {
    if (_analyses.isEmpty) return null;
    return _analyses.last;
  }

  /// Получение конфигурации
  OptimizationConfig get config => _config;

  /// Обновление конфигурации
  void updateConfig(OptimizationConfig newConfig) {
    _config = newConfig;

    if (_config.enableAutoOptimization) {
      _startAutoAnalysis();
    } else {
      _stopAutoAnalysis();
    }
  }

  /// Очистка старых данных
  void cleanupOldData({Duration? olderThan}) {
    final cutoff = olderThan ?? const Duration(days: 30);
    final cutoffTime = DateTime.now().subtract(cutoff);

    _analyses.removeWhere((analysis) => analysis.timestamp.isBefore(cutoffTime));
    _recommendations.removeWhere((rec) => rec.createdAt.isBefore(cutoffTime));
  }

  /// Остановка сервиса
  void dispose() {
    _stopAutoAnalysis();
    _recommendations.clear();
    _analyses.clear();
  }
}
