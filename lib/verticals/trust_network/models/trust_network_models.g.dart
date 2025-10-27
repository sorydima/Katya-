// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trust_network_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrustScore _$TrustScoreFromJson(Map<String, dynamic> json) => TrustScore(
      userId: json['userId'] as String,
      score: (json['score'] as num).toDouble(),
      level: $enumDecode(_$TrustLevelEnumMap, json['level']),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      factors: (json['factors'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const {},
      history: (json['history'] as List<dynamic>?)
              ?.map((e) => TrustEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TrustScoreToJson(TrustScore instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'score': instance.score,
      'level': _$TrustLevelEnumMap[instance.level]!,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'factors': instance.factors,
      'history': instance.history,
    };

const _$TrustLevelEnumMap = {
  TrustLevel.unverified: 'unverified',
  TrustLevel.low: 'low',
  TrustLevel.medium: 'medium',
  TrustLevel.high: 'high',
  TrustLevel.excellent: 'excellent',
};

TrustEvent _$TrustEventFromJson(Map<String, dynamic> json) => TrustEvent(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: $enumDecode(_$TrustEventTypeEnumMap, json['type']),
      scoreChange: (json['scoreChange'] as num).toDouble(),
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$TrustEventToJson(TrustEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': _$TrustEventTypeEnumMap[instance.type]!,
      'scoreChange': instance.scoreChange,
      'description': instance.description,
      'timestamp': instance.timestamp.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$TrustEventTypeEnumMap = {
  TrustEventType.messageSent: 'messageSent',
  TrustEventType.messageReceived: 'messageReceived',
  TrustEventType.fileShared: 'fileShared',
  TrustEventType.contactAdded: 'contactAdded',
  TrustEventType.positiveFeedback: 'positiveFeedback',
  TrustEventType.negativeFeedback: 'negativeFeedback',
  TrustEventType.accountVerified: 'accountVerified',
  TrustEventType.securityViolation: 'securityViolation',
  TrustEventType.suspiciousActivity: 'suspiciousActivity',
  TrustEventType.profileCompleted: 'profileCompleted',
  TrustEventType.consistentUsage: 'consistentUsage',
  TrustEventType.longTermUser: 'longTermUser',
  TrustEventType.communityContribution: 'communityContribution',
  TrustEventType.moderationAction: 'moderationAction',
  TrustEventType.accountRecovery: 'accountRecovery',
  TrustEventType.deviceChange: 'deviceChange',
  TrustEventType.locationChange: 'locationChange',
  TrustEventType.timePatternChange: 'timePatternChange',
};

TrustNetwork _$TrustNetworkFromJson(Map<String, dynamic> json) => TrustNetwork(
      userId: json['userId'] as String,
      connections: (json['connections'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
                k, TrustConnection.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
      score: TrustScore.fromJson(json['score'] as Map<String, dynamic>),
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((e) =>
                  TrustRecommendation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      settings: json['settings'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$TrustNetworkToJson(TrustNetwork instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'connections': instance.connections,
      'score': instance.score,
      'recommendations': instance.recommendations,
      'settings': instance.settings,
    };

TrustConnection _$TrustConnectionFromJson(Map<String, dynamic> json) =>
    TrustConnection(
      connectedUserId: json['connectedUserId'] as String,
      trustScore: (json['trustScore'] as num).toDouble(),
      type: $enumDecode(_$TrustConnectionTypeEnumMap, json['type']),
      establishedAt: DateTime.parse(json['establishedAt'] as String),
      lastInteraction: DateTime.parse(json['lastInteraction'] as String),
      interactionCount: (json['interactionCount'] as num?)?.toInt() ?? 0,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$TrustConnectionToJson(TrustConnection instance) =>
    <String, dynamic>{
      'connectedUserId': instance.connectedUserId,
      'trustScore': instance.trustScore,
      'type': _$TrustConnectionTypeEnumMap[instance.type]!,
      'establishedAt': instance.establishedAt.toIso8601String(),
      'lastInteraction': instance.lastInteraction.toIso8601String(),
      'interactionCount': instance.interactionCount,
      'metadata': instance.metadata,
    };

const _$TrustConnectionTypeEnumMap = {
  TrustConnectionType.direct: 'direct',
  TrustConnectionType.indirect: 'indirect',
  TrustConnectionType.institutional: 'institutional',
  TrustConnectionType.algorithmic: 'algorithmic',
  TrustConnectionType.manual: 'manual',
};

TrustRecommendation _$TrustRecommendationFromJson(Map<String, dynamic> json) =>
    TrustRecommendation(
      id: json['id'] as String,
      userId: json['userId'] as String,
      recommendedUserId: json['recommendedUserId'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      reason: json['reason'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      type: $enumDecode(_$TrustRecommendationTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$TrustRecommendationToJson(
        TrustRecommendation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'recommendedUserId': instance.recommendedUserId,
      'confidence': instance.confidence,
      'reason': instance.reason,
      'createdAt': instance.createdAt.toIso8601String(),
      'type': _$TrustRecommendationTypeEnumMap[instance.type]!,
    };

const _$TrustRecommendationTypeEnumMap = {
  TrustRecommendationType.mutualConnections: 'mutualConnections',
  TrustRecommendationType.sharedInterests: 'sharedInterests',
  TrustRecommendationType.locationBased: 'locationBased',
  TrustRecommendationType.activityBased: 'activityBased',
  TrustRecommendationType.institutional: 'institutional',
  TrustRecommendationType.algorithmic: 'algorithmic',
  TrustRecommendationType.manual: 'manual',
};

TrustVerification _$TrustVerificationFromJson(Map<String, dynamic> json) =>
    TrustVerification(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: $enumDecode(_$VerificationTypeEnumMap, json['type']),
      status: $enumDecode(_$VerificationStatusEnumMap, json['status']),
      verifierId: json['verifierId'] as String?,
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      verifiedAt: json['verifiedAt'] == null
          ? null
          : DateTime.parse(json['verifiedAt'] as String),
      verificationData: json['verificationData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$TrustVerificationToJson(TrustVerification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': _$VerificationTypeEnumMap[instance.type]!,
      'status': _$VerificationStatusEnumMap[instance.status]!,
      'verifierId': instance.verifierId,
      'requestedAt': instance.requestedAt.toIso8601String(),
      'verifiedAt': instance.verifiedAt?.toIso8601String(),
      'verificationData': instance.verificationData,
    };

const _$VerificationTypeEnumMap = {
  VerificationType.email: 'email',
  VerificationType.phone: 'phone',
  VerificationType.governmentId: 'governmentId',
  VerificationType.institutional: 'institutional',
  VerificationType.biometric: 'biometric',
  VerificationType.deviceFingerprint: 'deviceFingerprint',
  VerificationType.socialMedia: 'socialMedia',
  VerificationType.financial: 'financial',
  VerificationType.educational: 'educational',
  VerificationType.professional: 'professional',
};

const _$VerificationStatusEnumMap = {
  VerificationStatus.pending: 'pending',
  VerificationStatus.inProgress: 'inProgress',
  VerificationStatus.verified: 'verified',
  VerificationStatus.rejected: 'rejected',
  VerificationStatus.expired: 'expired',
  VerificationStatus.revoked: 'revoked',
};

TrustPolicy _$TrustPolicyFromJson(Map<String, dynamic> json) => TrustPolicy(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$TrustPolicyTypeEnumMap, json['type']),
      rules: json['rules'] as Map<String, dynamic>,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TrustPolicyToJson(TrustPolicy instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': _$TrustPolicyTypeEnumMap[instance.type]!,
      'rules': instance.rules,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$TrustPolicyTypeEnumMap = {
  TrustPolicyType.global: 'global',
  TrustPolicyType.regional: 'regional',
  TrustPolicyType.organizational: 'organizational',
  TrustPolicyType.userDefined: 'userDefined',
  TrustPolicyType.adaptive: 'adaptive',
};

ReputationScore _$ReputationScoreFromJson(Map<String, dynamic> json) =>
    ReputationScore(
      userId: json['userId'] as String,
      overallScore: (json['overallScore'] as num).toDouble(),
      categoryScores: (json['categoryScores'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const {},
      events: (json['events'] as List<dynamic>?)
              ?.map((e) => ReputationEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$ReputationScoreToJson(ReputationScore instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'overallScore': instance.overallScore,
      'categoryScores': instance.categoryScores,
      'events': instance.events,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

ReputationEvent _$ReputationEventFromJson(Map<String, dynamic> json) =>
    ReputationEvent(
      id: json['id'] as String,
      userId: json['userId'] as String,
      category: json['category'] as String,
      scoreChange: (json['scoreChange'] as num).toDouble(),
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      source: json['source'] as String?,
    );

Map<String, dynamic> _$ReputationEventToJson(ReputationEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'category': instance.category,
      'scoreChange': instance.scoreChange,
      'description': instance.description,
      'timestamp': instance.timestamp.toIso8601String(),
      'source': instance.source,
    };

TrustAnalytics _$TrustAnalyticsFromJson(Map<String, dynamic> json) =>
    TrustAnalytics(
      userId: json['userId'] as String,
      metrics: (json['metrics'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const {},
      insights: (json['insights'] as List<dynamic>?)
              ?.map((e) => TrustInsight.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );

Map<String, dynamic> _$TrustAnalyticsToJson(TrustAnalytics instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'metrics': instance.metrics,
      'insights': instance.insights,
      'generatedAt': instance.generatedAt.toIso8601String(),
    };

TrustInsight _$TrustInsightFromJson(Map<String, dynamic> json) => TrustInsight(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$TrustInsightTypeEnumMap, json['type']),
      confidence: (json['confidence'] as num).toDouble(),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$TrustInsightToJson(TrustInsight instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'type': _$TrustInsightTypeEnumMap[instance.type]!,
      'confidence': instance.confidence,
      'generatedAt': instance.generatedAt.toIso8601String(),
      'data': instance.data,
    };

const _$TrustInsightTypeEnumMap = {
  TrustInsightType.risk: 'risk',
  TrustInsightType.opportunity: 'opportunity',
  TrustInsightType.trend: 'trend',
  TrustInsightType.anomaly: 'anomaly',
  TrustInsightType.recommendation: 'recommendation',
  TrustInsightType.warning: 'warning',
  TrustInsightType.positive: 'positive',
  TrustInsightType.negative: 'negative',
};

TrustCommunity _$TrustCommunityFromJson(Map<String, dynamic> json) =>
    TrustCommunity(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      members: (json['members'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      moderatorId: json['moderatorId'] as String,
      type: $enumDecode(_$TrustCommunityTypeEnumMap, json['type']),
      averageScores: (json['averageScores'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const {},
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$TrustCommunityToJson(TrustCommunity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'members': instance.members,
      'moderatorId': instance.moderatorId,
      'type': _$TrustCommunityTypeEnumMap[instance.type]!,
      'averageScores': instance.averageScores,
      'isActive': instance.isActive,
    };

const _$TrustCommunityTypeEnumMap = {
  TrustCommunityType.interestBased: 'interestBased',
  TrustCommunityType.locationBased: 'locationBased',
  TrustCommunityType.professional: 'professional',
  TrustCommunityType.educational: 'educational',
  TrustCommunityType.social: 'social',
  TrustCommunityType.support: 'support',
  TrustCommunityType.moderation: 'moderation',
  TrustCommunityType.verification: 'verification',
};

TrustBadge _$TrustBadgeFromJson(Map<String, dynamic> json) => TrustBadge(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconUrl: json['iconUrl'] as String,
      category: json['category'] as String,
      requirements: json['requirements'] as Map<String, dynamic>,
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$TrustBadgeToJson(TrustBadge instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'iconUrl': instance.iconUrl,
      'category': instance.category,
      'requirements': instance.requirements,
      'expiresAt': instance.expiresAt?.toIso8601String(),
    };

UserBadge _$UserBadgeFromJson(Map<String, dynamic> json) => UserBadge(
      userId: json['userId'] as String,
      badgeId: json['badgeId'] as String,
      earnedAt: DateTime.parse(json['earnedAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$UserBadgeToJson(UserBadge instance) => <String, dynamic>{
      'userId': instance.userId,
      'badgeId': instance.badgeId,
      'earnedAt': instance.earnedAt.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'metadata': instance.metadata,
    };

TrustReport _$TrustReportFromJson(Map<String, dynamic> json) => TrustReport(
      id: json['id'] as String,
      userId: json['userId'] as String,
      reportDate: DateTime.parse(json['reportDate'] as String),
      currentScore:
          TrustScore.fromJson(json['currentScore'] as Map<String, dynamic>),
      scoreHistory: (json['scoreHistory'] as List<dynamic>?)
              ?.map((e) => TrustScore.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      insights: (json['insights'] as List<dynamic>?)
              ?.map((e) => TrustInsight.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      recommendations:
          json['recommendations'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$TrustReportToJson(TrustReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'reportDate': instance.reportDate.toIso8601String(),
      'currentScore': instance.currentScore,
      'scoreHistory': instance.scoreHistory,
      'insights': instance.insights,
      'recommendations': instance.recommendations,
    };

TrustConfiguration _$TrustConfigurationFromJson(Map<String, dynamic> json) =>
    TrustConfiguration(
      id: json['id'] as String,
      weights: (json['weights'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const {},
      policies: (json['policies'] as Map<String, dynamic>?)?.map(
            (k, e) =>
                MapEntry(k, TrustPolicy.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
      thresholds: json['thresholds'] as Map<String, dynamic>? ?? const {},
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$TrustConfigurationToJson(TrustConfiguration instance) =>
    <String, dynamic>{
      'id': instance.id,
      'weights': instance.weights,
      'policies': instance.policies,
      'thresholds': instance.thresholds,
      'isActive': instance.isActive,
    };
