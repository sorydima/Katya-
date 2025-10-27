import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';

/// Сервис для управления репутацией и рекомендациями в сети доверия
class ReputationService {
  static final ReputationService _instance = ReputationService._internal();

  // Кэш репутационных данных
  final Map<String, ReputationScore> _reputationCache = {};
  final Map<String, List<ReputationRecommendation>> _recommendationCache = {};

  // Метрики взаимодействия
  final Map<String, Map<String, InteractionMetrics>> _interactionMetrics = {};

  // Конфигурация
  static const double _baseReputationScore = 0.5;
  static const double _maxReputationScore = 1.0;
  static const double _minReputationScore = 0.0;
  static const int _interactionHistoryDays = 30;
  static const double _recommendationThreshold = 0.7;
  static const int _maxRecommendations = 10;

  factory ReputationService() => _instance;
  ReputationService._internal();

  /// Инициализация сервиса
  Future<void> initialize() async {
    await _loadReputationData();
    _setupPeriodicReputationUpdate();
  }

  /// Получение репутационного скора для идентичности
  Future<ReputationScore> getReputationScore(String identityId) async {
    if (_reputationCache.containsKey(identityId)) {
      return _reputationCache[identityId]!;
    }

    final score = await _calculateReputationScore(identityId);
    _reputationCache[identityId] = score;
    return score;
  }

  /// Получение рекомендаций для идентичности
  Future<List<ReputationRecommendation>> getRecommendations(String identityId) async {
    if (_recommendationCache.containsKey(identityId)) {
      return _recommendationCache[identityId]!;
    }

    final recommendations = await _generateRecommendations(identityId);
    _recommendationCache[identityId] = recommendations;
    return recommendations;
  }

  /// Обновление репутации на основе взаимодействия
  Future<void> updateReputationFromInteraction({
    required String identityId,
    required String targetIdentityId,
    required InteractionType interactionType,
    required double qualityScore,
    Map<String, dynamic>? metadata,
  }) async {
    // Обновляем метрики взаимодействия
    _updateInteractionMetrics(identityId, targetIdentityId, interactionType, qualityScore);

    // Пересчитываем репутационные скора
    await _recalculateReputationScores([identityId, targetIdentityId]);

    // Обновляем кэш рекомендаций
    _recommendationCache.remove(identityId);
    _recommendationCache.remove(targetIdentityId);
  }

  /// Получение топ узлов по репутации
  Future<List<ReputationRanking>> getTopReputationNodes({
    int limit = 50,
    String? protocol,
    ReputationLevel? minLevel,
  }) async {
    final rankings = <ReputationRanking>[];

    for (final entry in _reputationCache.entries) {
      final score = entry.value;

      // Фильтрация по протоколу
      if (protocol != null && score.protocol != protocol) continue;

      // Фильтрация по уровню репутации
      if (minLevel != null && score.level.index < minLevel.index) continue;

      rankings.add(ReputationRanking(
        identityId: entry.key,
        score: score,
        rank: rankings.length + 1,
      ));
    }

    // Сортировка по репутационному скору
    rankings.sort((a, b) => b.score.overallScore.compareTo(a.score.overallScore));

    return rankings.take(limit).toList();
  }

  /// Анализ репутационных трендов
  Future<ReputationTrendAnalysis> analyzeReputationTrends({
    required String identityId,
    required int days,
  }) async {
    final trendData = <DateTime, double>{};
    final currentScore = await getReputationScore(identityId);

    // Анализ исторических данных (заглушка для демонстрации)
    for (int i = days; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final historicalScore = _generateHistoricalScore(currentScore.overallScore, i);
      trendData[date] = historicalScore;
    }

    return ReputationTrendAnalysis(
      identityId: identityId,
      trendData: trendData,
      trendDirection: _calculateTrendDirection(trendData),
      volatility: _calculateVolatility(trendData),
      confidence: _calculateTrendConfidence(trendData),
    );
  }

  /// Получение репутационных инсайтов
  Future<ReputationInsights> getReputationInsights(String identityId) async {
    final score = await getReputationScore(identityId);
    final interactions = _interactionMetrics[identityId] ?? {};

    return ReputationInsights(
      identityId: identityId,
      score: score,
      totalInteractions: _calculateTotalInteractions(interactions),
      uniquePartners: interactions.length,
      averageQuality: _calculateAverageQuality(interactions),
      topInteractionTypes: _getTopInteractionTypes(interactions),
      reputationFactors: _analyzeReputationFactors(score, interactions),
      recommendations: _generateInsightRecommendations(score, interactions),
    );
  }

  /// Загрузка репутационных данных
  Future<void> _loadReputationData() async {
    // Загрузка из локального хранилища
    // В реальной реализации здесь будет загрузка из базы данных
  }

  /// Настройка периодического обновления репутации
  void _setupPeriodicReputationUpdate() {
    Timer.periodic(const Duration(hours: 6), (timer) async {
      await _performPeriodicReputationUpdate();
    });
  }

  /// Периодическое обновление репутации
  Future<void> _performPeriodicReputationUpdate() async {
    final identitiesToUpdate = <String>[];

    // Определяем идентичности для обновления
    for (final entry in _reputationCache.entries) {
      if (_needsReputationUpdate(entry.key)) {
        identitiesToUpdate.add(entry.key);
      }
    }

    // Пересчитываем репутационные скора
    await _recalculateReputationScores(identitiesToUpdate);

    // Очищаем кэш рекомендаций
    _recommendationCache.clear();
  }

  /// Расчет репутационного скора
  Future<ReputationScore> _calculateReputationScore(String identityId) async {
    final interactions = _interactionMetrics[identityId] ?? {};

    // Базовый скор
    double overallScore = _baseReputationScore;

    // Факторы репутации
    final factors = <String, double>{
      'interaction_quality': _calculateInteractionQualityFactor(interactions),
      'consistency': _calculateConsistencyFactor(interactions),
      'diversity': _calculateDiversityFactor(interactions),
      'recency': _calculateRecencyFactor(interactions),
      'volume': _calculateVolumeFactor(interactions),
    };

    // Взвешенная сумма факторов
    final weights = <String, double>{
      'interaction_quality': 0.3,
      'consistency': 0.2,
      'diversity': 0.15,
      'recency': 0.15,
      'volume': 0.2,
    };

    for (final entry in factors.entries) {
      overallScore += entry.value * weights[entry.key]!;
    }

    // Нормализация
    overallScore = max(_minReputationScore, min(_maxReputationScore, overallScore));

    return ReputationScore(
      identityId: identityId,
      overallScore: overallScore,
      factors: factors,
      level: _determineReputationLevel(overallScore),
      lastUpdated: DateTime.now(),
      protocol: _extractProtocolFromIdentity(identityId),
    );
  }

  /// Генерация рекомендаций
  Future<List<ReputationRecommendation>> _generateRecommendations(String identityId) async {
    final recommendations = <ReputationRecommendation>[];
    final currentScore = await getReputationScore(identityId);

    // Рекомендации на основе репутационных факторов
    for (final entry in currentScore.factors.entries) {
      if (entry.value < _recommendationThreshold) {
        recommendations.add(ReputationRecommendation(
          type: RecommendationType.improveFactor,
          factor: entry.key,
          currentValue: entry.value,
          targetValue: _recommendationThreshold,
          priority: _calculateRecommendationPriority(entry.key, entry.value),
          description: _generateRecommendationDescription(entry.key, entry.value),
        ));
      }
    }

    // Рекомендации на основе взаимодействий
    final interactionRecommendations = _generateInteractionRecommendations(identityId);
    recommendations.addAll(interactionRecommendations);

    // Сортировка по приоритету
    recommendations.sort((a, b) => b.priority.compareTo(a.priority));

    return recommendations.take(_maxRecommendations).toList();
  }

  /// Обновление метрик взаимодействия
  void _updateInteractionMetrics(
    String identityId,
    String targetIdentityId,
    InteractionType interactionType,
    double qualityScore,
  ) {
    if (!_interactionMetrics.containsKey(identityId)) {
      _interactionMetrics[identityId] = {};
    }

    if (!_interactionMetrics[identityId]!.containsKey(targetIdentityId)) {
      _interactionMetrics[identityId]![targetIdentityId] = InteractionMetrics(
        targetIdentityId: targetIdentityId,
        interactionType: interactionType,
        totalInteractions: 0,
        averageQuality: 0.0,
        lastInteraction: DateTime.now(),
        qualityHistory: const [],
      );
    }

    final metrics = _interactionMetrics[identityId]![targetIdentityId]!;
    metrics.qualityHistory.add(qualityScore);
    final newAverageQuality = metrics.qualityHistory.reduce((a, b) => a + b) / metrics.qualityHistory.length;

    // Создаем новый объект с обновленными значениями
    _interactionMetrics[identityId]![targetIdentityId] = InteractionMetrics(
      targetIdentityId: metrics.targetIdentityId,
      interactionType: metrics.interactionType,
      totalInteractions: metrics.totalInteractions + 1,
      averageQuality: newAverageQuality,
      lastInteraction: DateTime.now(),
      qualityHistory: metrics.qualityHistory,
    );
  }

  /// Пересчет репутационных скоров
  Future<void> _recalculateReputationScores(List<String> identityIds) async {
    for (final identityId in identityIds) {
      final newScore = await _calculateReputationScore(identityId);
      _reputationCache[identityId] = newScore;
    }
  }

  /// Проверка необходимости обновления репутации
  bool _needsReputationUpdate(String identityId) {
    final lastUpdate = _reputationCache[identityId]?.lastUpdated;
    if (lastUpdate == null) return true;

    final hoursSinceUpdate = DateTime.now().difference(lastUpdate).inHours;
    return hoursSinceUpdate >= 6;
  }

  /// Расчет факторов репутации
  double _calculateInteractionQualityFactor(Map<String, InteractionMetrics> interactions) {
    if (interactions.isEmpty) return 0.0;

    double totalQuality = 0.0;
    int totalInteractions = 0;

    for (final metrics in interactions.values) {
      totalQuality += metrics.averageQuality * metrics.totalInteractions;
      totalInteractions += metrics.totalInteractions;
    }

    return totalInteractions > 0 ? totalQuality / totalInteractions : 0.0;
  }

  double _calculateConsistencyFactor(Map<String, InteractionMetrics> interactions) {
    if (interactions.length < 2) return 0.0;

    final qualityScores = interactions.values.map((m) => m.averageQuality).toList();
    final mean = qualityScores.reduce((a, b) => a + b) / qualityScores.length;

    double variance = 0.0;
    for (final score in qualityScores) {
      variance += pow(score - mean, 2);
    }
    variance /= qualityScores.length;

    // Обратная зависимость от дисперсии (чем меньше дисперсия, тем выше консистентность)
    return max(0.0, 1.0 - variance);
  }

  double _calculateDiversityFactor(Map<String, InteractionMetrics> interactions) {
    final uniqueTypes = interactions.values.map((m) => m.interactionType).toSet().length;
    return min(1.0, uniqueTypes / 5.0); // Нормализация к максимальному количеству типов
  }

  double _calculateRecencyFactor(Map<String, InteractionMetrics> interactions) {
    if (interactions.isEmpty) return 0.0;

    final now = DateTime.now();
    double recencyScore = 0.0;

    for (final metrics in interactions.values) {
      final daysSinceLastInteraction = now.difference(metrics.lastInteraction).inDays;
      final recency = max(0.0, 1.0 - (daysSinceLastInteraction / _interactionHistoryDays));
      recencyScore += recency;
    }

    return recencyScore / interactions.length;
  }

  double _calculateVolumeFactor(Map<String, InteractionMetrics> interactions) {
    final totalInteractions = interactions.values.fold(0, (sum, m) => sum + m.totalInteractions);
    return min(1.0, totalInteractions / 100.0); // Нормализация к 100 взаимодействиям
  }

  /// Определение уровня репутации
  ReputationLevel _determineReputationLevel(double score) {
    if (score >= 0.9) return ReputationLevel.excellent;
    if (score >= 0.8) return ReputationLevel.veryGood;
    if (score >= 0.7) return ReputationLevel.good;
    if (score >= 0.6) return ReputationLevel.fair;
    if (score >= 0.4) return ReputationLevel.poor;
    return ReputationLevel.veryPoor;
  }

  /// Извлечение протокола из идентичности
  String _extractProtocolFromIdentity(String identityId) {
    // Простая логика извлечения протокола
    if (identityId.contains('@')) return 'email';
    if (identityId.contains('+')) return 'phone';
    if (identityId.startsWith('@')) return 'matrix';
    return 'unknown';
  }

  /// Генерация исторического скора
  double _generateHistoricalScore(double currentScore, int daysAgo) {
    // Простая модель для демонстрации
    final variation = sin(daysAgo * 0.1) * 0.1;
    return max(0.0, min(1.0, currentScore + variation));
  }

  /// Расчет направления тренда
  TrendDirection _calculateTrendDirection(Map<DateTime, double> trendData) {
    if (trendData.length < 2) return TrendDirection.stable;

    final values = trendData.values.toList();
    final firstHalf = values.take(values.length ~/ 2).reduce((a, b) => a + b) / (values.length ~/ 2);
    final secondHalf = values.skip(values.length ~/ 2).reduce((a, b) => a + b) / (values.length - values.length ~/ 2);

    final difference = secondHalf - firstHalf;
    if (difference > 0.05) return TrendDirection.increasing;
    if (difference < -0.05) return TrendDirection.decreasing;
    return TrendDirection.stable;
  }

  /// Расчет волатильности
  double _calculateVolatility(Map<DateTime, double> trendData) {
    if (trendData.length < 2) return 0.0;

    final values = trendData.values.toList();
    final mean = values.reduce((a, b) => a + b) / values.length;

    double variance = 0.0;
    for (final value in values) {
      variance += pow(value - mean, 2);
    }
    variance /= values.length;

    return sqrt(variance);
  }

  /// Расчет уверенности в тренде
  double _calculateTrendConfidence(Map<DateTime, double> trendData) {
    // Простая модель уверенности на основе количества данных
    return min(1.0, trendData.length / 30.0);
  }

  /// Расчет общих взаимодействий
  int _calculateTotalInteractions(Map<String, InteractionMetrics> interactions) {
    return interactions.values.fold(0, (sum, m) => sum + m.totalInteractions);
  }

  /// Расчет средней качества
  double _calculateAverageQuality(Map<String, InteractionMetrics> interactions) {
    if (interactions.isEmpty) return 0.0;

    double totalQuality = 0.0;
    int totalInteractions = 0;

    for (final metrics in interactions.values) {
      totalQuality += metrics.averageQuality * metrics.totalInteractions;
      totalInteractions += metrics.totalInteractions;
    }

    return totalInteractions > 0 ? totalQuality / totalInteractions : 0.0;
  }

  /// Получение топ типов взаимодействий
  List<String> _getTopInteractionTypes(Map<String, InteractionMetrics> interactions) {
    final typeCounts = <String, int>{};

    for (final metrics in interactions.values) {
      typeCounts[metrics.interactionType.toString()] =
          (typeCounts[metrics.interactionType.toString()] ?? 0) + metrics.totalInteractions;
    }

    final sortedTypes = typeCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return sortedTypes.take(3).map((e) => e.key).toList();
  }

  /// Анализ факторов репутации
  List<String> _analyzeReputationFactors(ReputationScore score, Map<String, InteractionMetrics> interactions) {
    final factors = <String>[];

    for (final entry in score.factors.entries) {
      if (entry.value < 0.5) {
        factors.add('Low ${entry.key.replaceAll('_', ' ')}');
      } else if (entry.value > 0.8) {
        factors.add('High ${entry.key.replaceAll('_', ' ')}');
      }
    }

    return factors;
  }

  /// Генерация рекомендаций по инсайтам
  List<String> _generateInsightRecommendations(ReputationScore score, Map<String, InteractionMetrics> interactions) {
    final recommendations = <String>[];

    if (score.overallScore < 0.6) {
      recommendations.add('Focus on improving interaction quality');
    }

    if (interactions.length < 5) {
      recommendations.add('Increase network diversity');
    }

    if (score.factors['recency'] != null && score.factors['recency']! < 0.5) {
      recommendations.add('Maintain more recent interactions');
    }

    return recommendations;
  }

  /// Генерация рекомендаций по взаимодействиям
  List<ReputationRecommendation> _generateInteractionRecommendations(String identityId) {
    final recommendations = <ReputationRecommendation>[];
    final interactions = _interactionMetrics[identityId] ?? {};

    if (interactions.length < 3) {
      recommendations.add(ReputationRecommendation(
        type: RecommendationType.increaseDiversity,
        factor: 'network_diversity',
        currentValue: interactions.length / 10.0,
        targetValue: 0.7,
        priority: 8,
        description: 'Increase network diversity by connecting with more identities',
      ));
    }

    return recommendations;
  }

  /// Расчет приоритета рекомендации
  int _calculateRecommendationPriority(String factor, double currentValue) {
    const targetValue = _recommendationThreshold;
    final gap = targetValue - currentValue;

    if (gap > 0.3) return 10;
    if (gap > 0.2) return 8;
    if (gap > 0.1) return 6;
    return 4;
  }

  /// Генерация описания рекомендации
  String _generateRecommendationDescription(String factor, double currentValue) {
    const targetValue = _recommendationThreshold;
    final gap = targetValue - currentValue;

    switch (factor) {
      case 'interaction_quality':
        return 'Improve interaction quality by ${(gap * 100).toStringAsFixed(1)}%';
      case 'consistency':
        return 'Maintain more consistent interaction patterns';
      case 'diversity':
        return 'Increase interaction diversity across different types';
      case 'recency':
        return 'Engage in more recent interactions';
      case 'volume':
        return 'Increase overall interaction volume';
      default:
        return 'Improve ${factor.replaceAll('_', ' ')}';
    }
  }

  /// Освобождение ресурсов
  void dispose() {
    _reputationCache.clear();
    _recommendationCache.clear();
    _interactionMetrics.clear();
  }
}

/// Модель репутационного скора
class ReputationScore extends Equatable {
  final String identityId;
  final double overallScore;
  final Map<String, double> factors;
  final ReputationLevel level;
  final DateTime lastUpdated;
  final String protocol;

  const ReputationScore({
    required this.identityId,
    required this.overallScore,
    required this.factors,
    required this.level,
    required this.lastUpdated,
    required this.protocol,
  });

  @override
  List<Object?> get props => [identityId, overallScore, factors, level, lastUpdated, protocol];
}

/// Уровни репутации
enum ReputationLevel {
  veryPoor,
  poor,
  fair,
  good,
  veryGood,
  excellent,
}

/// Типы взаимодействий
enum InteractionType {
  message,
  verification,
  recommendation,
  collaboration,
  dispute,
}

/// Метрики взаимодействия
class InteractionMetrics extends Equatable {
  final String targetIdentityId;
  final InteractionType interactionType;
  final int totalInteractions;
  final double averageQuality;
  final DateTime lastInteraction;
  final List<double> qualityHistory;

  const InteractionMetrics({
    required this.targetIdentityId,
    required this.interactionType,
    required this.totalInteractions,
    required this.averageQuality,
    required this.lastInteraction,
    required this.qualityHistory,
  });

  @override
  List<Object?> get props => [
        targetIdentityId,
        interactionType,
        totalInteractions,
        averageQuality,
        lastInteraction,
        qualityHistory,
      ];
}

/// Рекомендация по репутации
class ReputationRecommendation extends Equatable {
  final RecommendationType type;
  final String factor;
  final double currentValue;
  final double targetValue;
  final int priority;
  final String description;

  const ReputationRecommendation({
    required this.type,
    required this.factor,
    required this.currentValue,
    required this.targetValue,
    required this.priority,
    required this.description,
  });

  @override
  List<Object?> get props => [type, factor, currentValue, targetValue, priority, description];
}

/// Типы рекомендаций
enum RecommendationType {
  improveFactor,
  increaseDiversity,
  maintainConsistency,
  increaseVolume,
  improveQuality,
}

/// Ранжирование по репутации
class ReputationRanking extends Equatable {
  final String identityId;
  final ReputationScore score;
  final int rank;

  const ReputationRanking({
    required this.identityId,
    required this.score,
    required this.rank,
  });

  @override
  List<Object?> get props => [identityId, score, rank];
}

/// Анализ трендов репутации
class ReputationTrendAnalysis extends Equatable {
  final String identityId;
  final Map<DateTime, double> trendData;
  final TrendDirection trendDirection;
  final double volatility;
  final double confidence;

  const ReputationTrendAnalysis({
    required this.identityId,
    required this.trendData,
    required this.trendDirection,
    required this.volatility,
    required this.confidence,
  });

  @override
  List<Object?> get props => [identityId, trendData, trendDirection, volatility, confidence];
}

/// Направления трендов
enum TrendDirection {
  increasing,
  decreasing,
  stable,
}

/// Инсайты по репутации
class ReputationInsights extends Equatable {
  final String identityId;
  final ReputationScore score;
  final int totalInteractions;
  final int uniquePartners;
  final double averageQuality;
  final List<String> topInteractionTypes;
  final List<String> reputationFactors;
  final List<String> recommendations;

  const ReputationInsights({
    required this.identityId,
    required this.score,
    required this.totalInteractions,
    required this.uniquePartners,
    required this.averageQuality,
    required this.topInteractionTypes,
    required this.reputationFactors,
    required this.recommendations,
  });

  @override
  List<Object?> get props => [
        identityId,
        score,
        totalInteractions,
        uniquePartners,
        averageQuality,
        topInteractionTypes,
        reputationFactors,
        recommendations,
      ];
}
