import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'trust_network_models.g.dart';

@JsonSerializable()
class TrustScore extends Equatable {
  final String userId;
  final double score;
  final TrustLevel level;
  final DateTime lastUpdated;
  final Map<String, double> factors;
  final List<TrustEvent> history;

  const TrustScore({
    required this.userId,
    required this.score,
    required this.level,
    required this.lastUpdated,
    this.factors = const {},
    this.history = const [],
  });

  TrustScore copyWith({
    String? userId,
    double? score,
    TrustLevel? level,
    DateTime? lastUpdated,
    Map<String, double>? factors,
    List<TrustEvent>? history,
  }) {
    return TrustScore(
      userId: userId ?? this.userId,
      score: score ?? this.score,
      level: level ?? this.level,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      factors: factors ?? this.factors,
      history: history ?? this.history,
    );
  }

  factory TrustScore.fromJson(Map<String, dynamic> json) => _$TrustScoreFromJson(json);
  Map<String, dynamic> toJson() => _$TrustScoreToJson(this);

  @override
  List<Object?> get props => [userId, score, level, lastUpdated, factors, history];
}

enum TrustLevel {
  unverified(0.0, 0.1),
  low(0.1, 0.3),
  medium(0.3, 0.6),
  high(0.6, 0.8),
  excellent(0.8, 1.0);

  const TrustLevel(this.minScore, this.maxScore);
  final double minScore;
  final double maxScore;

  static TrustLevel fromScore(double score) {
    for (final level in TrustLevel.values) {
      if (score >= level.minScore && score < level.maxScore) {
        return level;
      }
    }
    return TrustLevel.unverified;
  }
}

@JsonSerializable()
class TrustEvent extends Equatable {
  final String id;
  final String userId;
  final TrustEventType type;
  final double scoreChange;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const TrustEvent({
    required this.id,
    required this.userId,
    required this.type,
    required this.scoreChange,
    required this.description,
    required this.timestamp,
    this.metadata,
  });

  factory TrustEvent.fromJson(Map<String, dynamic> json) => _$TrustEventFromJson(json);
  Map<String, dynamic> toJson() => _$TrustEventToJson(this);

  @override
  List<Object?> get props => [id, userId, type, scoreChange, description, timestamp, metadata];
}

enum TrustEventType {
  messageSent,
  messageReceived,
  fileShared,
  contactAdded,
  positiveFeedback,
  negativeFeedback,
  accountVerified,
  securityViolation,
  suspiciousActivity,
  profileCompleted,
  consistentUsage,
  longTermUser,
  communityContribution,
  moderationAction,
  accountRecovery,
  deviceChange,
  locationChange,
  timePatternChange,
}

@JsonSerializable()
class TrustNetwork extends Equatable {
  final String userId;
  final Map<String, TrustConnection> connections;
  final TrustScore score;
  final List<TrustRecommendation> recommendations;
  final Map<String, dynamic> settings;

  const TrustNetwork({
    required this.userId,
    this.connections = const {},
    required this.score,
    this.recommendations = const [],
    this.settings = const {},
  });

  TrustNetwork copyWith({
    String? userId,
    Map<String, TrustConnection>? connections,
    TrustScore? score,
    List<TrustRecommendation>? recommendations,
    Map<String, dynamic>? settings,
  }) {
    return TrustNetwork(
      userId: userId ?? this.userId,
      connections: connections ?? this.connections,
      score: score ?? this.score,
      recommendations: recommendations ?? this.recommendations,
      settings: settings ?? this.settings,
    );
  }

  factory TrustNetwork.fromJson(Map<String, dynamic> json) => _$TrustNetworkFromJson(json);
  Map<String, dynamic> toJson() => _$TrustNetworkToJson(this);

  @override
  List<Object?> get props => [userId, connections, score, recommendations, settings];
}

@JsonSerializable()
class TrustConnection extends Equatable {
  final String connectedUserId;
  final double trustScore;
  final TrustConnectionType type;
  final DateTime establishedAt;
  final DateTime lastInteraction;
  final int interactionCount;
  final Map<String, dynamic>? metadata;

  const TrustConnection({
    required this.connectedUserId,
    required this.trustScore,
    required this.type,
    required this.establishedAt,
    required this.lastInteraction,
    this.interactionCount = 0,
    this.metadata,
  });

  factory TrustConnection.fromJson(Map<String, dynamic> json) => _$TrustConnectionFromJson(json);
  Map<String, dynamic> toJson() => _$TrustConnectionToJson(this);

  @override
  List<Object?> get props => [
        connectedUserId,
        trustScore,
        type,
        establishedAt,
        lastInteraction,
        interactionCount,
        metadata,
      ];
}

enum TrustConnectionType {
  direct,        // Direct connection (mutual friends, contacts)
  indirect,      // Indirect connection (friend of friend)
  institutional, // Institutional connection (verified organization)
  algorithmic,   // Algorithmically determined connection
  manual,        // Manually established connection
}

@JsonSerializable()
class TrustRecommendation extends Equatable {
  final String id;
  final String userId;
  final String recommendedUserId;
  final double confidence;
  final String reason;
  final DateTime createdAt;
  final TrustRecommendationType type;

  const TrustRecommendation({
    required this.id,
    required this.userId,
    required this.recommendedUserId,
    required this.confidence,
    required this.reason,
    required this.createdAt,
    required this.type,
  });

  factory TrustRecommendation.fromJson(Map<String, dynamic> json) => _$TrustRecommendationFromJson(json);
  Map<String, dynamic> toJson() => _$TrustRecommendationToJson(this);

  @override
  List<Object?> get props => [id, userId, recommendedUserId, confidence, reason, createdAt, type];
}

enum TrustRecommendationType {
  mutualConnections,
  sharedInterests,
  locationBased,
  activityBased,
  institutional,
  algorithmic,
  manual,
}

@JsonSerializable()
class TrustVerification extends Equatable {
  final String id;
  final String userId;
  final VerificationType type;
  final VerificationStatus status;
  final String? verifierId;
  final DateTime requestedAt;
  final DateTime? verifiedAt;
  final Map<String, dynamic>? verificationData;

  const TrustVerification({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    this.verifierId,
    required this.requestedAt,
    this.verifiedAt,
    this.verificationData,
  });

  factory TrustVerification.fromJson(Map<String, dynamic> json) => _$TrustVerificationFromJson(json);
  Map<String, dynamic> toJson() => _$TrustVerificationToJson(this);

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        status,
        verifierId,
        requestedAt,
        verifiedAt,
        verificationData,
      ];
}

enum VerificationType {
  email,
  phone,
  governmentId,
  institutional,
  biometric,
  deviceFingerprint,
  socialMedia,
  financial,
  educational,
  professional,
}

enum VerificationStatus {
  pending,
  inProgress,
  verified,
  rejected,
  expired,
  revoked,
}

@JsonSerializable()
class TrustPolicy extends Equatable {
  final String id;
  final String name;
  final String description;
  final TrustPolicyType type;
  final Map<String, dynamic> rules;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TrustPolicy({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.rules,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory TrustPolicy.fromJson(Map<String, dynamic> json) => _$TrustPolicyFromJson(json);
  Map<String, dynamic> toJson() => _$TrustPolicyToJson(this);

  @override
  List<Object?> get props => [id, name, description, type, rules, isActive, createdAt, updatedAt];
}

enum TrustPolicyType {
  global,        // Global trust policies
  regional,      // Regional policies (country-specific)
  organizational, // Organization-specific policies
  userDefined,   // User-defined policies
  adaptive,      // Adaptive policies based on behavior
}

@JsonSerializable()
class ReputationScore extends Equatable {
  final String userId;
  final double overallScore;
  final Map<String, double> categoryScores;
  final List<ReputationEvent> events;
  final DateTime lastUpdated;

  const ReputationScore({
    required this.userId,
    required this.overallScore,
    this.categoryScores = const {},
    this.events = const [],
    required this.lastUpdated,
  });

  factory ReputationScore.fromJson(Map<String, dynamic> json) => _$ReputationScoreFromJson(json);
  Map<String, dynamic> toJson() => _$ReputationScoreToJson(this);

  @override
  List<Object?> get props => [userId, overallScore, categoryScores, events, lastUpdated];
}

@JsonSerializable()
class ReputationEvent extends Equatable {
  final String id;
  final String userId;
  final String category;
  final double scoreChange;
  final String description;
  final DateTime timestamp;
  final String? source;

  const ReputationEvent({
    required this.id,
    required this.userId,
    required this.category,
    required this.scoreChange,
    required this.description,
    required this.timestamp,
    this.source,
  });

  factory ReputationEvent.fromJson(Map<String, dynamic> json) => _$ReputationEventFromJson(json);
  Map<String, dynamic> toJson() => _$ReputationEventToJson(this);

  @override
  List<Object?> get props => [id, userId, category, scoreChange, description, timestamp, source];
}

@JsonSerializable()
class TrustAnalytics extends Equatable {
  final String userId;
  final Map<String, double> metrics;
  final List<TrustInsight> insights;
  final DateTime generatedAt;

  const TrustAnalytics({
    required this.userId,
    this.metrics = const {},
    this.insights = const [],
    required this.generatedAt,
  });

  factory TrustAnalytics.fromJson(Map<String, dynamic> json) => _$TrustAnalyticsFromJson(json);
  Map<String, dynamic> toJson() => _$TrustAnalyticsToJson(this);

  @override
  List<Object?> get props => [userId, metrics, insights, generatedAt];
}

@JsonSerializable()
class TrustInsight extends Equatable {
  final String id;
  final String title;
  final String description;
  final TrustInsightType type;
  final double confidence;
  final DateTime generatedAt;
  final Map<String, dynamic>? data;

  const TrustInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.confidence,
    required this.generatedAt,
    this.data,
  });

  factory TrustInsight.fromJson(Map<String, dynamic> json) => _$TrustInsightFromJson(json);
  Map<String, dynamic> toJson() => _$TrustInsightToJson(this);

  @override
  List<Object?> get props => [id, title, description, type, confidence, generatedAt, data];
}

enum TrustInsightType {
  risk,
  opportunity,
  trend,
  anomaly,
  recommendation,
  warning,
  positive,
  negative,
}

@JsonSerializable()
class TrustCommunity extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<String> members;
  final String moderatorId;
  final TrustCommunityType type;
  final Map<String, double> averageScores;
  final bool isActive;

  const TrustCommunity({
    required this.id,
    required this.name,
    required this.description,
    this.members = const [],
    required this.moderatorId,
    required this.type,
    this.averageScores = const {},
    this.isActive = true,
  });

  factory TrustCommunity.fromJson(Map<String, dynamic> json) => _$TrustCommunityFromJson(json);
  Map<String, dynamic> toJson() => _$TrustCommunityToJson(this);

  @override
  List<Object?> get props => [id, name, description, members, moderatorId, type, averageScores, isActive];
}

enum TrustCommunityType {
  interestBased,
  locationBased,
  professional,
  educational,
  social,
  support,
  moderation,
  verification,
}

@JsonSerializable()
class TrustBadge extends Equatable {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final String category;
  final Map<String, dynamic> requirements;
  final DateTime? expiresAt;

  const TrustBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.category,
    required this.requirements,
    this.expiresAt,
  });

  factory TrustBadge.fromJson(Map<String, dynamic> json) => _$TrustBadgeFromJson(json);
  Map<String, dynamic> toJson() => _$TrustBadgeToJson(this);

  @override
  List<Object?> get props => [id, name, description, iconUrl, category, requirements, expiresAt];
}

@JsonSerializable()
class UserBadge extends Equatable {
  final String userId;
  final String badgeId;
  final DateTime earnedAt;
  final DateTime? expiresAt;
  final Map<String, dynamic>? metadata;

  const UserBadge({
    required this.userId,
    required this.badgeId,
    required this.earnedAt,
    this.expiresAt,
    this.metadata,
  });

  factory UserBadge.fromJson(Map<String, dynamic> json) => _$UserBadgeFromJson(json);
  Map<String, dynamic> toJson() => _$UserBadgeToJson(this);

  @override
  List<Object?> get props => [userId, badgeId, earnedAt, expiresAt, metadata];
}

@JsonSerializable()
class TrustReport extends Equatable {
  final String id;
  final String userId;
  final DateTime reportDate;
  final TrustScore currentScore;
  final List<TrustScore> scoreHistory;
  final List<TrustInsight> insights;
  final Map<String, dynamic> recommendations;

  const TrustReport({
    required this.id,
    required this.userId,
    required this.reportDate,
    required this.currentScore,
    this.scoreHistory = const [],
    this.insights = const [],
    this.recommendations = const {},
  });

  factory TrustReport.fromJson(Map<String, dynamic> json) => _$TrustReportFromJson(json);
  Map<String, dynamic> toJson() => _$TrustReportToJson(this);

  @override
  List<Object?> get props => [id, userId, reportDate, currentScore, scoreHistory, insights, recommendations];
}

@JsonSerializable()
class TrustConfiguration extends Equatable {
  final String id;
  final Map<String, double> weights;
  final Map<String, TrustPolicy> policies;
  final Map<String, dynamic> thresholds;
  final bool isActive;

  const TrustConfiguration({
    required this.id,
    this.weights = const {},
    this.policies = const {},
    this.thresholds = const {},
    this.isActive = true,
  });

  factory TrustConfiguration.fromJson(Map<String, dynamic> json) => _$TrustConfigurationFromJson(json);
  Map<String, dynamic> toJson() => _$TrustConfigurationToJson(this);

  @override
  List<Object?> get props => [id, weights, policies, thresholds, isActive];
}
