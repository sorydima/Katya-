// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalyticsData _$AnalyticsDataFromJson(Map<String, dynamic> json) =>
    AnalyticsData(
      id: json['id'] as String,
      userId: json['userId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      version: json['version'] as String,
      userAnalytics:
          UserAnalytics.fromJson(json['userAnalytics'] as Map<String, dynamic>),
      sessions: (json['sessions'] as List<dynamic>?)
              ?.map((e) => SessionAnalytics.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => FeatureAnalytics.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      performance: (json['performance'] as List<dynamic>?)
              ?.map((e) =>
                  PerformanceAnalytics.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      errors: (json['errors'] as List<dynamic>?)
              ?.map((e) => ErrorAnalytics.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      network: (json['network'] as List<dynamic>?)
              ?.map((e) => NetworkAnalytics.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$AnalyticsDataToJson(AnalyticsData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'timestamp': instance.timestamp.toIso8601String(),
      'version': instance.version,
      'userAnalytics': instance.userAnalytics,
      'sessions': instance.sessions,
      'features': instance.features,
      'performance': instance.performance,
      'errors': instance.errors,
      'network': instance.network,
    };

UserAnalytics _$UserAnalyticsFromJson(Map<String, dynamic> json) =>
    UserAnalytics(
      userId: json['userId'] as String,
      firstSeen: DateTime.parse(json['firstSeen'] as String),
      lastSeen: DateTime.parse(json['lastSeen'] as String),
      platform: json['platform'] as String,
      appVersion: json['appVersion'] as String,
      locale: json['locale'] as String,
      totalSessions: (json['totalSessions'] as num?)?.toInt() ?? 0,
      totalTimeSpent: json['totalTimeSpent'] == null
          ? Duration.zero
          : Duration(microseconds: (json['totalTimeSpent'] as num).toInt()),
      messagesSent: (json['messagesSent'] as num?)?.toInt() ?? 0,
      messagesReceived: (json['messagesReceived'] as num?)?.toInt() ?? 0,
      roomsJoined: (json['roomsJoined'] as num?)?.toInt() ?? 0,
      roomsCreated: (json['roomsCreated'] as num?)?.toInt() ?? 0,
      preferences: json['preferences'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$UserAnalyticsToJson(UserAnalytics instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'firstSeen': instance.firstSeen.toIso8601String(),
      'lastSeen': instance.lastSeen.toIso8601String(),
      'platform': instance.platform,
      'appVersion': instance.appVersion,
      'locale': instance.locale,
      'totalSessions': instance.totalSessions,
      'totalTimeSpent': instance.totalTimeSpent.inMicroseconds,
      'messagesSent': instance.messagesSent,
      'messagesReceived': instance.messagesReceived,
      'roomsJoined': instance.roomsJoined,
      'roomsCreated': instance.roomsCreated,
      'preferences': instance.preferences,
    };

SessionAnalytics _$SessionAnalyticsFromJson(Map<String, dynamic> json) =>
    SessionAnalytics(
      sessionId: json['sessionId'] as String,
      userId: json['userId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      duration: json['duration'] == null
          ? null
          : Duration(microseconds: (json['duration'] as num).toInt()),
      platform: json['platform'] as String,
      appVersion: json['appVersion'] as String,
      featuresUsed: (json['featuresUsed'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      roomsVisited: (json['roomsVisited'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      messagesSent: (json['messagesSent'] as num?)?.toInt() ?? 0,
      messagesReceived: (json['messagesReceived'] as num?)?.toInt() ?? 0,
      errors: (json['errors'] as List<dynamic>?)
              ?.map((e) => ErrorEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$SessionAnalyticsToJson(SessionAnalytics instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'userId': instance.userId,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'duration': instance.duration?.inMicroseconds,
      'platform': instance.platform,
      'appVersion': instance.appVersion,
      'featuresUsed': instance.featuresUsed,
      'roomsVisited': instance.roomsVisited,
      'messagesSent': instance.messagesSent,
      'messagesReceived': instance.messagesReceived,
      'errors': instance.errors,
    };

FeatureAnalytics _$FeatureAnalyticsFromJson(Map<String, dynamic> json) =>
    FeatureAnalytics(
      featureName: json['featureName'] as String,
      userId: json['userId'] as String,
      usageCount: (json['usageCount'] as num?)?.toInt() ?? 0,
      totalTimeSpent: json['totalTimeSpent'] == null
          ? Duration.zero
          : Duration(microseconds: (json['totalTimeSpent'] as num).toInt()),
      firstUsed: DateTime.parse(json['firstUsed'] as String),
      lastUsed: DateTime.parse(json['lastUsed'] as String),
      featureData: json['featureData'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$FeatureAnalyticsToJson(FeatureAnalytics instance) =>
    <String, dynamic>{
      'featureName': instance.featureName,
      'userId': instance.userId,
      'usageCount': instance.usageCount,
      'totalTimeSpent': instance.totalTimeSpent.inMicroseconds,
      'firstUsed': instance.firstUsed.toIso8601String(),
      'lastUsed': instance.lastUsed.toIso8601String(),
      'featureData': instance.featureData,
    };

PerformanceAnalytics _$PerformanceAnalyticsFromJson(
        Map<String, dynamic> json) =>
    PerformanceAnalytics(
      metricName: json['metricName'] as String,
      userId: json['userId'] as String,
      value: (json['value'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      platform: json['platform'] as String,
      appVersion: json['appVersion'] as String,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$PerformanceAnalyticsToJson(
        PerformanceAnalytics instance) =>
    <String, dynamic>{
      'metricName': instance.metricName,
      'userId': instance.userId,
      'value': instance.value,
      'timestamp': instance.timestamp.toIso8601String(),
      'platform': instance.platform,
      'appVersion': instance.appVersion,
      'metadata': instance.metadata,
    };

ErrorAnalytics _$ErrorAnalyticsFromJson(Map<String, dynamic> json) =>
    ErrorAnalytics(
      errorId: json['errorId'] as String,
      userId: json['userId'] as String,
      errorType: json['errorType'] as String,
      errorMessage: json['errorMessage'] as String,
      stackTrace: json['stackTrace'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      platform: json['platform'] as String,
      appVersion: json['appVersion'] as String,
      roomId: json['roomId'] as String?,
      featureName: json['featureName'] as String?,
      context: json['context'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$ErrorAnalyticsToJson(ErrorAnalytics instance) =>
    <String, dynamic>{
      'errorId': instance.errorId,
      'userId': instance.userId,
      'errorType': instance.errorType,
      'errorMessage': instance.errorMessage,
      'stackTrace': instance.stackTrace,
      'timestamp': instance.timestamp.toIso8601String(),
      'platform': instance.platform,
      'appVersion': instance.appVersion,
      'roomId': instance.roomId,
      'featureName': instance.featureName,
      'context': instance.context,
    };

NetworkAnalytics _$NetworkAnalyticsFromJson(Map<String, dynamic> json) =>
    NetworkAnalytics(
      requestId: json['requestId'] as String,
      userId: json['userId'] as String,
      endpoint: json['endpoint'] as String,
      method: json['method'] as String,
      statusCode: (json['statusCode'] as num).toInt(),
      responseSize: (json['responseSize'] as num?)?.toInt() ?? 0,
      duration: Duration(microseconds: (json['duration'] as num).toInt()),
      timestamp: DateTime.parse(json['timestamp'] as String),
      platform: json['platform'] as String,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$NetworkAnalyticsToJson(NetworkAnalytics instance) =>
    <String, dynamic>{
      'requestId': instance.requestId,
      'userId': instance.userId,
      'endpoint': instance.endpoint,
      'method': instance.method,
      'statusCode': instance.statusCode,
      'responseSize': instance.responseSize,
      'duration': instance.duration.inMicroseconds,
      'timestamp': instance.timestamp.toIso8601String(),
      'platform': instance.platform,
      'metadata': instance.metadata,
    };

ErrorEvent _$ErrorEventFromJson(Map<String, dynamic> json) => ErrorEvent(
      type: json['type'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      data: json['data'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$ErrorEventToJson(ErrorEvent instance) =>
    <String, dynamic>{
      'type': instance.type,
      'message': instance.message,
      'timestamp': instance.timestamp.toIso8601String(),
      'data': instance.data,
    };

AnalyticsReport _$AnalyticsReportFromJson(Map<String, dynamic> json) =>
    AnalyticsReport(
      reportId: json['reportId'] as String,
      userId: json['userId'] as String,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      userSummary:
          UserAnalytics.fromJson(json['userSummary'] as Map<String, dynamic>),
      featureReports: (json['featureReports'] as List<dynamic>?)
              ?.map(
                  (e) => FeatureUsageReport.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      performanceReports: (json['performanceReports'] as List<dynamic>?)
              ?.map(
                  (e) => PerformanceReport.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      errorReports: (json['errorReports'] as List<dynamic>?)
              ?.map((e) => ErrorReport.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      networkReport:
          NetworkReport.fromJson(json['networkReport'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AnalyticsReportToJson(AnalyticsReport instance) =>
    <String, dynamic>{
      'reportId': instance.reportId,
      'userId': instance.userId,
      'generatedAt': instance.generatedAt.toIso8601String(),
      'periodStart': instance.periodStart.toIso8601String(),
      'periodEnd': instance.periodEnd.toIso8601String(),
      'userSummary': instance.userSummary,
      'featureReports': instance.featureReports,
      'performanceReports': instance.performanceReports,
      'errorReports': instance.errorReports,
      'networkReport': instance.networkReport,
    };

FeatureUsageReport _$FeatureUsageReportFromJson(Map<String, dynamic> json) =>
    FeatureUsageReport(
      featureName: json['featureName'] as String,
      usageCount: (json['usageCount'] as num?)?.toInt() ?? 0,
      totalTime: json['totalTime'] == null
          ? Duration.zero
          : Duration(microseconds: (json['totalTime'] as num).toInt()),
      averageTime: (json['averageTime'] as num?)?.toDouble() ?? 0.0,
      uniqueUsers: (json['uniqueUsers'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$FeatureUsageReportToJson(FeatureUsageReport instance) =>
    <String, dynamic>{
      'featureName': instance.featureName,
      'usageCount': instance.usageCount,
      'totalTime': instance.totalTime.inMicroseconds,
      'averageTime': instance.averageTime,
      'uniqueUsers': instance.uniqueUsers,
    };

PerformanceReport _$PerformanceReportFromJson(Map<String, dynamic> json) =>
    PerformanceReport(
      metricName: json['metricName'] as String,
      averageValue: (json['averageValue'] as num?)?.toDouble() ?? 0.0,
      minValue: (json['minValue'] as num?)?.toDouble() ?? 0.0,
      maxValue: (json['maxValue'] as num?)?.toDouble() ?? 0.0,
      p50Value: (json['p50Value'] as num?)?.toDouble() ?? 0.0,
      p95Value: (json['p95Value'] as num?)?.toDouble() ?? 0.0,
      p99Value: (json['p99Value'] as num?)?.toDouble() ?? 0.0,
      sampleCount: (json['sampleCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$PerformanceReportToJson(PerformanceReport instance) =>
    <String, dynamic>{
      'metricName': instance.metricName,
      'averageValue': instance.averageValue,
      'minValue': instance.minValue,
      'maxValue': instance.maxValue,
      'p50Value': instance.p50Value,
      'p95Value': instance.p95Value,
      'p99Value': instance.p99Value,
      'sampleCount': instance.sampleCount,
    };

ErrorReport _$ErrorReportFromJson(Map<String, dynamic> json) => ErrorReport(
      errorType: json['errorType'] as String,
      occurrenceCount: (json['occurrenceCount'] as num?)?.toInt() ?? 0,
      affectedUsers: (json['affectedUsers'] as num?)?.toInt() ?? 0,
      firstOccurrence: DateTime.parse(json['firstOccurrence'] as String),
      lastOccurrence: DateTime.parse(json['lastOccurrence'] as String),
      commonMessages: (json['commonMessages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ErrorReportToJson(ErrorReport instance) =>
    <String, dynamic>{
      'errorType': instance.errorType,
      'occurrenceCount': instance.occurrenceCount,
      'affectedUsers': instance.affectedUsers,
      'firstOccurrence': instance.firstOccurrence.toIso8601String(),
      'lastOccurrence': instance.lastOccurrence.toIso8601String(),
      'commonMessages': instance.commonMessages,
    };

NetworkReport _$NetworkReportFromJson(Map<String, dynamic> json) =>
    NetworkReport(
      totalRequests: (json['totalRequests'] as num?)?.toInt() ?? 0,
      averageResponseTime:
          (json['averageResponseTime'] as num?)?.toDouble() ?? 0.0,
      successCount: (json['successCount'] as num?)?.toInt() ?? 0,
      errorCount: (json['errorCount'] as num?)?.toInt() ?? 0,
      successRate: (json['successRate'] as num?)?.toDouble() ?? 0.0,
      statusCodeDistribution:
          (json['statusCodeDistribution'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, (e as num).toInt()),
              ) ??
              const {},
      averageResponseTimeByEndpoint:
          (json['averageResponseTimeByEndpoint'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, (e as num).toDouble()),
              ) ??
              const {},
    );

Map<String, dynamic> _$NetworkReportToJson(NetworkReport instance) =>
    <String, dynamic>{
      'totalRequests': instance.totalRequests,
      'averageResponseTime': instance.averageResponseTime,
      'successCount': instance.successCount,
      'errorCount': instance.errorCount,
      'successRate': instance.successRate,
      'statusCodeDistribution': instance.statusCodeDistribution,
      'averageResponseTimeByEndpoint': instance.averageResponseTimeByEndpoint,
    };

AnalyticsConfig _$AnalyticsConfigFromJson(Map<String, dynamic> json) =>
    AnalyticsConfig(
      enabled: json['enabled'] as bool? ?? true,
      trackUserAnalytics: json['trackUserAnalytics'] as bool? ?? true,
      trackFeatureUsage: json['trackFeatureUsage'] as bool? ?? true,
      trackPerformance: json['trackPerformance'] as bool? ?? true,
      trackErrors: json['trackErrors'] as bool? ?? true,
      trackNetwork: json['trackNetwork'] as bool? ?? true,
      dataRetentionPeriod: json['dataRetentionPeriod'] == null
          ? const Duration(days: 90)
          : Duration(
              microseconds: (json['dataRetentionPeriod'] as num).toInt()),
      maxEventsPerSession:
          (json['maxEventsPerSession'] as num?)?.toInt() ?? 1000,
      anonymizeUserData: json['anonymizeUserData'] as bool? ?? false,
      allowedPlatforms: (json['allowedPlatforms'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ['ios', 'android', 'web', 'desktop'],
    );

Map<String, dynamic> _$AnalyticsConfigToJson(AnalyticsConfig instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'trackUserAnalytics': instance.trackUserAnalytics,
      'trackFeatureUsage': instance.trackFeatureUsage,
      'trackPerformance': instance.trackPerformance,
      'trackErrors': instance.trackErrors,
      'trackNetwork': instance.trackNetwork,
      'dataRetentionPeriod': instance.dataRetentionPeriod.inMicroseconds,
      'maxEventsPerSession': instance.maxEventsPerSession,
      'anonymizeUserData': instance.anonymizeUserData,
      'allowedPlatforms': instance.allowedPlatforms,
    };

AnalyticsEvent _$AnalyticsEventFromJson(Map<String, dynamic> json) =>
    AnalyticsEvent(
      eventId: json['eventId'] as String,
      userId: json['userId'] as String,
      eventType: json['eventType'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      data: json['data'] as Map<String, dynamic>? ?? const {},
      platform: json['platform'] as String,
      appVersion: json['appVersion'] as String,
    );

Map<String, dynamic> _$AnalyticsEventToJson(AnalyticsEvent instance) =>
    <String, dynamic>{
      'eventId': instance.eventId,
      'userId': instance.userId,
      'eventType': instance.eventType,
      'timestamp': instance.timestamp.toIso8601String(),
      'data': instance.data,
      'platform': instance.platform,
      'appVersion': instance.appVersion,
    };

AnalyticsInsight _$AnalyticsInsightFromJson(Map<String, dynamic> json) =>
    AnalyticsInsight(
      insightId: json['insightId'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      data: json['data'] as Map<String, dynamic>? ?? const {},
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      confidence: json['confidence'] as String? ?? 'medium',
    );

Map<String, dynamic> _$AnalyticsInsightToJson(AnalyticsInsight instance) =>
    <String, dynamic>{
      'insightId': instance.insightId,
      'type': instance.type,
      'title': instance.title,
      'description': instance.description,
      'data': instance.data,
      'generatedAt': instance.generatedAt.toIso8601String(),
      'confidence': instance.confidence,
    };

AnalyticsQuery _$AnalyticsQueryFromJson(Map<String, dynamic> json) =>
    AnalyticsQuery(
      queryId: json['queryId'] as String,
      userId: json['userId'] as String,
      type: $enumDecode(_$AnalyticsQueryTypeEnumMap, json['type']),
      parameters: json['parameters'] as Map<String, dynamic>? ?? const {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: $enumDecodeNullable(_$QueryStatusEnumMap, json['status']) ??
          QueryStatus.pending,
    );

Map<String, dynamic> _$AnalyticsQueryToJson(AnalyticsQuery instance) =>
    <String, dynamic>{
      'queryId': instance.queryId,
      'userId': instance.userId,
      'type': _$AnalyticsQueryTypeEnumMap[instance.type]!,
      'parameters': instance.parameters,
      'createdAt': instance.createdAt.toIso8601String(),
      'status': _$QueryStatusEnumMap[instance.status]!,
    };

const _$AnalyticsQueryTypeEnumMap = {
  AnalyticsQueryType.userActivity: 'userActivity',
  AnalyticsQueryType.featureUsage: 'featureUsage',
  AnalyticsQueryType.performanceMetrics: 'performanceMetrics',
  AnalyticsQueryType.errorAnalysis: 'errorAnalysis',
  AnalyticsQueryType.networkAnalysis: 'networkAnalysis',
  AnalyticsQueryType.customReport: 'customReport',
};

const _$QueryStatusEnumMap = {
  QueryStatus.pending: 'pending',
  QueryStatus.running: 'running',
  QueryStatus.completed: 'completed',
  QueryStatus.failed: 'failed',
  QueryStatus.cancelled: 'cancelled',
};

AnalyticsQueryResult _$AnalyticsQueryResultFromJson(
        Map<String, dynamic> json) =>
    AnalyticsQueryResult(
      queryId: json['queryId'] as String,
      success: json['success'] as bool,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => AnalyticsData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      report: json['report'] == null
          ? null
          : AnalyticsReport.fromJson(json['report'] as Map<String, dynamic>),
      errors:
          (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
      completedAt: DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$AnalyticsQueryResultToJson(
        AnalyticsQueryResult instance) =>
    <String, dynamic>{
      'queryId': instance.queryId,
      'success': instance.success,
      'data': instance.data,
      'report': instance.report,
      'errors': instance.errors,
      'completedAt': instance.completedAt.toIso8601String(),
    };
