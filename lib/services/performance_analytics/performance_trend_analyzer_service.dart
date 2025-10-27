import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// Перечисление типов трендов
enum TrendType {
  increasing,
  decreasing,
  stable,
  volatile,
  seasonal,
  cyclical,
  unknown,
}

/// Перечисление типов аномалий
enum AnomalyType {
  spike,
  drop,
  pattern,
  outlier,
  drift,
  unknown,
}

/// Модель тренда
class Trend extends Equatable {
  final String id;
  final String metricName;
  final TrendType type;
  final double slope;
  final double confidence;
  final DateTime startTime;
  final DateTime endTime;
  final List<double> values;
  final Map<String, dynamic>? metadata;

  const Trend({
    required this.id,
    required this.metricName,
    required this.type,
    required this.slope,
    required this.confidence,
    required this.startTime,
    required this.endTime,
    required this.values,
    this.metadata,
  });

  @override
  List<Object?> get props => [id, metricName, type, slope, confidence, startTime, endTime, values, metadata];
}

/// Модель аномалии
class Anomaly extends Equatable {
  final String id;
  final String metricName;
  final AnomalyType type;
  final double value;
  final double expectedValue;
  final double severity;
  final DateTime timestamp;
  final String? description;
  final Map<String, dynamic>? metadata;

  const Anomaly({
    required this.id,
    required this.metricName,
    required this.type,
    required this.value,
    required this.expectedValue,
    required this.severity,
    required this.timestamp,
    this.description,
    this.metadata,
  });

  @override
  List<Object?> get props => [id, metricName, type, value, expectedValue, severity, timestamp, description, metadata];
}

/// Модель прогноза
class Forecast extends Equatable {
  final String id;
  final String metricName;
  final DateTime forecastTime;
  final double predictedValue;
  final double confidence;
  final double lowerBound;
  final double upperBound;
  final String method;
  final Map<String, dynamic>? metadata;

  const Forecast({
    required this.id,
    required this.metricName,
    required this.forecastTime,
    required this.predictedValue,
    required this.confidence,
    required this.lowerBound,
    required this.upperBound,
    required this.method,
    this.metadata,
  });

  @override
  List<Object?> get props =>
      [id, metricName, forecastTime, predictedValue, confidence, lowerBound, upperBound, method, metadata];
}

/// Модель анализа трендов
class TrendAnalysis extends Equatable {
  final String id;
  final String metricName;
  final DateTime analysisTime;
  final Trend? trend;
  final List<Anomaly> anomalies;
  final List<Forecast> forecasts;
  final Map<String, dynamic> statistics;
  final String? summary;

  const TrendAnalysis({
    required this.id,
    required this.metricName,
    required this.analysisTime,
    this.trend,
    this.anomalies = const [],
    this.forecasts = const [],
    required this.statistics,
    this.summary,
  });

  @override
  List<Object?> get props => [id, metricName, analysisTime, trend, anomalies, forecasts, statistics, summary];
}

/// Модель конфигурации анализа трендов
class TrendAnalysisConfig extends Equatable {
  final Duration analysisWindow;
  final Duration forecastHorizon;
  final double anomalyThreshold;
  final double trendConfidenceThreshold;
  final int minDataPoints;
  final bool enableAnomalyDetection;
  final bool enableForecasting;
  final List<String> enabledMetrics;

  const TrendAnalysisConfig({
    this.analysisWindow = const Duration(hours: 24),
    this.forecastHorizon = const Duration(hours: 1),
    this.anomalyThreshold = 2.0,
    this.trendConfidenceThreshold = 0.7,
    this.minDataPoints = 10,
    this.enableAnomalyDetection = true,
    this.enableForecasting = true,
    this.enabledMetrics = const [],
  });

  @override
  List<Object?> get props => [
        analysisWindow,
        forecastHorizon,
        anomalyThreshold,
        trendConfidenceThreshold,
        minDataPoints,
        enableAnomalyDetection,
        enableForecasting,
        enabledMetrics
      ];
}

/// Сервис для анализа трендов и аномалий в метриках производительности
class PerformanceTrendAnalyzerService {
  static final PerformanceTrendAnalyzerService _instance = PerformanceTrendAnalyzerService._internal();

  final List<TrendAnalysis> _analyses = [];
  final Map<String, List<double>> _metricHistory = {};
  final Uuid _uuid = const Uuid();
  TrendAnalysisConfig _config = const TrendAnalysisConfig();
  Timer? _analysisTimer;

  factory PerformanceTrendAnalyzerService() => _instance;

  PerformanceTrendAnalyzerService._internal() {
    _initializeDefaultConfig();
    _startPeriodicAnalysis();
  }

  /// Инициализация конфигурации по умолчанию
  void _initializeDefaultConfig() {
    _config = const TrendAnalysisConfig(
      analysisWindow: Duration(hours: 24),
      forecastHorizon: Duration(hours: 1),
      anomalyThreshold: 2.0,
      trendConfidenceThreshold: 0.7,
      minDataPoints: 10,
      enableAnomalyDetection: true,
      enableForecasting: true,
      enabledMetrics: [
        'cpu_usage',
        'memory_usage',
        'disk_usage',
        'network_throughput',
        'api_response_time',
        'database_query_time',
        'cache_hit_rate',
      ],
    );
  }

  /// Запуск периодического анализа
  void _startPeriodicAnalysis() {
    _analysisTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      _performPeriodicAnalysis();
    });
  }

  /// Остановка периодического анализа
  void _stopPeriodicAnalysis() {
    _analysisTimer?.cancel();
    _analysisTimer = null;
  }

  /// Выполнение периодического анализа
  void _performPeriodicAnalysis() {
    for (final metricName in _config.enabledMetrics) {
      if (_metricHistory.containsKey(metricName) && _metricHistory[metricName]!.length >= _config.minDataPoints) {
        analyzeTrend(metricName);
      }
    }
  }

  /// Добавление значения метрики
  void addMetricValue(String metricName, double value) {
    _metricHistory.putIfAbsent(metricName, () => []);
    _metricHistory[metricName]!.add(value);

    // Ограничиваем историю размером окна анализа
    final maxPoints = (_config.analysisWindow.inMinutes / 5).ceil(); // Предполагаем сбор каждые 5 минут
    if (_metricHistory[metricName]!.length > maxPoints) {
      _metricHistory[metricName]!.removeAt(0);
    }
  }

  /// Анализ тренда для метрики
  TrendAnalysis analyzeTrend(String metricName) {
    final values = _metricHistory[metricName];
    if (values == null || values.length < _config.minDataPoints) {
      throw ArgumentError('Insufficient data points for trend analysis');
    }

    final analysisTime = DateTime.now();
    final trend = _detectTrend(values);
    final List<Anomaly> anomalies = _config.enableAnomalyDetection ? _detectAnomalies(metricName, values) : <Anomaly>[];
    final List<Forecast> forecasts = _config.enableForecasting ? _generateForecasts(metricName, values) : <Forecast>[];
    final statistics = _calculateStatistics(values);
    final summary = _generateSummary(trend, anomalies, forecasts, statistics);

    final analysis = TrendAnalysis(
      id: _uuid.v4(),
      metricName: metricName,
      analysisTime: analysisTime,
      trend: trend,
      anomalies: anomalies,
      forecasts: forecasts,
      statistics: statistics,
      summary: summary,
    );

    _analyses.add(analysis);
    return analysis;
  }

  /// Обнаружение тренда
  Trend? _detectTrend(List<double> values) {
    if (values.length < 2) return null;

    // Простая линейная регрессия
    final n = values.length;
    final x = List.generate(n, (i) => i.toDouble());

    final sumX = x.reduce((a, b) => a + b);
    final sumY = values.reduce((a, b) => a + b);
    final sumXY = x.asMap().entries.map((e) => e.value * values[e.key]).reduce((a, b) => a + b);
    final sumXX = x.map((xi) => xi * xi).reduce((a, b) => a + b);
    final sumYY = values.map((yi) => yi * yi).reduce((a, b) => a + b);

    final slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
    final intercept = (sumY - slope * sumX) / n;

    // Расчет коэффициента корреляции
    final correlation = (n * sumXY - sumX * sumY) / sqrt((n * sumXX - sumX * sumX) * (n * sumYY - sumY * sumY));

    final confidence = correlation.abs();

    // Определение типа тренда
    TrendType type;
    if (confidence < _config.trendConfidenceThreshold) {
      type = TrendType.stable;
    } else if (slope > 0.01) {
      type = TrendType.increasing;
    } else if (slope < -0.01) {
      type = TrendType.decreasing;
    } else {
      type = TrendType.stable;
    }

    // Проверка на волатильность
    final variance = _calculateVariance(values);
    final mean = values.reduce((a, b) => a + b) / values.length;
    final coefficientOfVariation = sqrt(variance) / mean;

    if (coefficientOfVariation > 0.3) {
      type = TrendType.volatile;
    }

    return Trend(
      id: _uuid.v4(),
      metricName: 'trend_analysis',
      type: type,
      slope: slope,
      confidence: confidence,
      startTime: DateTime.now().subtract(_config.analysisWindow),
      endTime: DateTime.now(),
      values: List<double>.from(values),
      metadata: {
        'intercept': intercept,
        'correlation': correlation,
        'variance': variance,
        'coefficientOfVariation': coefficientOfVariation,
      },
    );
  }

  /// Обнаружение аномалий
  List<Anomaly> _detectAnomalies(String metricName, List<double> values) {
    final anomalies = <Anomaly>[];
    if (values.length < 3) return anomalies;

    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = _calculateVariance(values);
    final stdDev = sqrt(variance);
    final threshold = _config.anomalyThreshold * stdDev;

    for (int i = 0; i < values.length; i++) {
      final value = values[i];
      final deviation = (value - mean).abs();

      if (deviation > threshold) {
        AnomalyType type;
        if (value > mean + threshold) {
          type = AnomalyType.spike;
        } else if (value < mean - threshold) {
          type = AnomalyType.drop;
        } else {
          type = AnomalyType.outlier;
        }

        final severity = deviation / stdDev;
        final timestamp = DateTime.now().subtract(Duration(minutes: (values.length - i - 1) * 5));

        anomalies.add(Anomaly(
          id: _uuid.v4(),
          metricName: metricName,
          type: type,
          value: value,
          expectedValue: mean,
          severity: severity,
          timestamp: timestamp,
          description: _generateAnomalyDescription(type, value, mean, severity),
          metadata: {
            'deviation': deviation,
            'threshold': threshold,
            'index': i,
          },
        ));
      }
    }

    return anomalies;
  }

  /// Генерация прогнозов
  List<Forecast> _generateForecasts(String metricName, List<double> values) {
    final forecasts = <Forecast>[];
    if (values.length < 3) return forecasts;

    // Простое экспоненциальное сглаживание
    const alpha = 0.3; // Коэффициент сглаживания
    double forecast = values.first;

    for (int i = 1; i < values.length; i++) {
      forecast = alpha * values[i] + (1 - alpha) * forecast;
    }

    // Расчет доверительного интервала
    final variance = _calculateVariance(values);
    final stdDev = sqrt(variance);
    const confidence = 0.95;
    const zScore = 1.96; // Для 95% доверительного интервала

    final margin = zScore * stdDev;
    final lowerBound = forecast - margin;
    final upperBound = forecast + margin;

    final forecastTime = DateTime.now().add(_config.forecastHorizon);

    forecasts.add(Forecast(
      id: _uuid.v4(),
      metricName: metricName,
      forecastTime: forecastTime,
      predictedValue: forecast,
      confidence: confidence,
      lowerBound: lowerBound,
      upperBound: upperBound,
      method: 'exponential_smoothing',
      metadata: {
        'alpha': alpha,
        'lastValue': values.last,
        'trend': _detectTrend(values)?.slope,
      },
    ));

    return forecasts;
  }

  /// Расчет статистики
  Map<String, dynamic> _calculateStatistics(List<double> values) {
    if (values.isEmpty) return {};

    final sorted = List<double>.from(values)..sort();
    final n = values.length;
    final sum = values.reduce((a, b) => a + b);
    final mean = sum / n;
    final variance = _calculateVariance(values);
    final stdDev = sqrt(variance);

    final median = n % 2 == 0 ? (sorted[n ~/ 2 - 1] + sorted[n ~/ 2]) / 2 : sorted[n ~/ 2];

    final q1 = sorted[(n * 0.25).floor()];
    final q3 = sorted[(n * 0.75).floor()];
    final iqr = q3 - q1;

    final min = sorted.first;
    final max = sorted.last;
    final range = max - min;

    final p95 = sorted[(n * 0.95).floor()];
    final p99 = sorted[(n * 0.99).floor()];

    return {
      'count': n,
      'mean': mean,
      'median': median,
      'stdDev': stdDev,
      'variance': variance,
      'min': min,
      'max': max,
      'range': range,
      'q1': q1,
      'q3': q3,
      'iqr': iqr,
      'p95': p95,
      'p99': p99,
      'coefficientOfVariation': stdDev / mean,
    };
  }

  /// Расчет дисперсии
  double _calculateVariance(List<double> values) {
    if (values.length < 2) return 0.0;

    final mean = values.reduce((a, b) => a + b) / values.length;
    final sumSquaredDiffs = values.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b);
    return sumSquaredDiffs / (values.length - 1);
  }

  /// Генерация описания аномалии
  String _generateAnomalyDescription(AnomalyType type, double value, double expected, double severity) {
    final deviation = ((value - expected) / expected * 100).abs();

    switch (type) {
      case AnomalyType.spike:
        return 'Unexpected spike: ${value.toStringAsFixed(2)} (expected ~${expected.toStringAsFixed(2)}, +${deviation.toStringAsFixed(1)}%)';
      case AnomalyType.drop:
        return 'Unexpected drop: ${value.toStringAsFixed(2)} (expected ~${expected.toStringAsFixed(2)}, -${deviation.toStringAsFixed(1)}%)';
      case AnomalyType.outlier:
        return 'Outlier detected: ${value.toStringAsFixed(2)} (expected ~${expected.toStringAsFixed(2)}, ${deviation.toStringAsFixed(1)}% deviation)';
      default:
        return 'Anomaly detected: ${value.toStringAsFixed(2)} (expected ~${expected.toStringAsFixed(2)})';
    }
  }

  /// Генерация сводки
  String _generateSummary(
      Trend? trend, List<Anomaly> anomalies, List<Forecast> forecasts, Map<String, dynamic> statistics) {
    final buffer = StringBuffer();

    if (trend != null) {
      buffer.writeln('Trend: ${trend.type.name} (confidence: ${(trend.confidence * 100).toStringAsFixed(1)}%)');
    }

    if (anomalies.isNotEmpty) {
      buffer.writeln('Anomalies: ${anomalies.length} detected');
      final criticalAnomalies = anomalies.where((a) => a.severity > 3.0).length;
      if (criticalAnomalies > 0) {
        buffer.writeln('Critical anomalies: $criticalAnomalies');
      }
    }

    if (forecasts.isNotEmpty) {
      final forecast = forecasts.first;
      buffer.writeln(
          'Forecast: ${forecast.predictedValue.toStringAsFixed(2)} (${(forecast.confidence * 100).toStringAsFixed(0)}% confidence)');
    }

    if (statistics.isNotEmpty) {
      final mean = statistics['mean'] as double;
      final stdDev = statistics['stdDev'] as double;
      buffer.writeln('Statistics: mean=${mean.toStringAsFixed(2)}, std=${stdDev.toStringAsFixed(2)}');
    }

    return buffer.toString().trim();
  }

  /// Получение истории метрики
  List<double> getMetricHistory(String metricName) {
    return List<double>.from(_metricHistory[metricName] ?? []);
  }

  /// Получение всех анализов
  List<TrendAnalysis> getAllAnalyses() {
    return List<TrendAnalysis>.from(_analyses);
  }

  /// Получение анализов по метрике
  List<TrendAnalysis> getAnalysesByMetric(String metricName) {
    return _analyses.where((analysis) => analysis.metricName == metricName).toList();
  }

  /// Получение последнего анализа
  TrendAnalysis? getLastAnalysis() {
    if (_analyses.isEmpty) return null;
    return _analyses.last;
  }

  /// Получение всех аномалий
  List<Anomaly> getAllAnomalies() {
    return _analyses.expand((analysis) => analysis.anomalies).toList();
  }

  /// Получение аномалий по метрике
  List<Anomaly> getAnomaliesByMetric(String metricName) {
    return _analyses
        .where((analysis) => analysis.metricName == metricName)
        .expand((analysis) => analysis.anomalies)
        .toList();
  }

  /// Получение всех прогнозов
  List<Forecast> getAllForecasts() {
    return _analyses.expand((analysis) => analysis.forecasts).toList();
  }

  /// Получение прогнозов по метрике
  List<Forecast> getForecastsByMetric(String metricName) {
    return _analyses
        .where((analysis) => analysis.metricName == metricName)
        .expand((analysis) => analysis.forecasts)
        .toList();
  }

  /// Получение конфигурации
  TrendAnalysisConfig get config => _config;

  /// Обновление конфигурации
  void updateConfig(TrendAnalysisConfig newConfig) {
    _config = newConfig;
  }

  /// Очистка старых данных
  void cleanupOldData({Duration? olderThan}) {
    final cutoff = olderThan ?? const Duration(days: 7);
    final cutoffTime = DateTime.now().subtract(cutoff);

    _analyses.removeWhere((analysis) => analysis.analysisTime.isBefore(cutoffTime));

    // Очищаем историю метрик, оставляя только последние данные
    for (final metricName in _metricHistory.keys) {
      final history = _metricHistory[metricName]!;
      final maxPoints = (_config.analysisWindow.inMinutes / 5).ceil();
      if (history.length > maxPoints) {
        _metricHistory[metricName] = history.sublist(history.length - maxPoints);
      }
    }
  }

  /// Остановка сервиса
  void dispose() {
    _stopPeriodicAnalysis();
    _analyses.clear();
    _metricHistory.clear();
  }
}
