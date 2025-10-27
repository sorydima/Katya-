import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'analytics_models.g.dart';

@JsonSerializable()
class AnalyticsData extends Equatable {
  final String id;
  final String userId;
  final DateTime timestamp;
  final String version;
  final UserAnalytics userAnalytics;
  final List<SessionAnalytics> sessions;
  final List<FeatureAnalytics> features;
  final List<PerformanceAnalytics> performance;
  final List<ErrorAnalytics> errors;
  final List<NetworkAnalytics> network;

  const AnalyticsData({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.version,
    required this.userAnalytics,
    this.sessions = const [],
    this.features = const [],
    this.performance = const [],
    this.errors = const [],
    this.network = const [],
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) => _$AnalyticsDataFromJson(json);
  Map<String, dynamic> toJson() => _$AnalyticsDataToJson(this);

  @override
  List<Object?> get props => [id, userId, timestamp, version, userAnalytics, sessions, features, performance, errors, network];
}

@JsonSerializable()
class UserAnalytics extends Equatable {
  final String userId;
  final DateTime firstSeen;
  final DateTime lastSeen;
  final String platform;
  final String appVersion;
  final String locale;
  final int totalSessions;
  final Duration totalTimeSpent;
  final int messagesSent;
  final int messagesReceived;
  final int roomsJoined;
  final int roomsCreated;
  final Map<String, dynamic> preferences;

  const UserAnalytics({
    required this.userId,
    required this.firstSeen,
    required this.lastSeen,
    required this.platform,
    required this.appVersion,
    required this.locale,
    this.totalSessions = 0,
    this.totalTimeSpent = Duration.zero,
    this.messagesSent = 0,
    this.messagesReceived = 0,
    this.roomsJoined = 0,
    this.roomsCreated = 0,
    this.preferences = const {},
  });

  factory UserAnalytics.fromJson(Map<String, dynamic> json) => _$UserAnalyticsFromJson(json);
  Map<String, dynamic> toJson() => _$UserAnalyticsToJson(this);

  @override
  List<Object?> get props => [
    userId, firstSeen, lastSeen, platform, appVersion, locale,
    totalSessions, totalTimeSpent, messagesSent, messagesReceived,
    roomsJoined, roomsCreated, preferences
  ];
}

@JsonSerializable()
class SessionAnalytics extends Equatable {
  final String sessionId;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? duration;
  final String platform;
  final String appVersion;
  final List<String> featuresUsed;
  final List<String> roomsVisited;
  final int messagesSent;
  final int messagesReceived;
  final List<ErrorEvent> errors;

  const SessionAnalytics({
    required this.sessionId,
    required this.userId,
    required this.startTime,
    this.endTime,
    this.duration,
    required this.platform,
    required this.appVersion,
    this.featuresUsed = const [],
    this.roomsVisited = const [],
    this.messagesSent = 0,
    this.messagesReceived = 0,
    this.errors = const [],
  });

  factory SessionAnalytics.fromJson(Map<String, dynamic> json) => _$SessionAnalyticsFromJson(json);
  Map<String, dynamic> toJson() => _$SessionAnalyticsToJson(this);

  @override
  List<Object?> get props => [
    sessionId, userId, startTime, endTime, duration, platform, appVersion,
    featuresUsed, roomsVisited, messagesSent, messagesReceived, errors
  ];
}

@JsonSerializable()
class FeatureAnalytics extends Equatable {
  final String featureName;
  final String userId;
  final int usageCount;
  final Duration totalTimeSpent;
  final DateTime firstUsed;
  final DateTime lastUsed;
  final Map<String, dynamic> featureData;

  const FeatureAnalytics({
    required this.featureName,
    required this.userId,
    this.usageCount = 0,
    this.totalTimeSpent = Duration.zero,
    required this.firstUsed,
    required this.lastUsed,
    this.featureData = const {},
  });

  factory FeatureAnalytics.fromJson(Map<String, dynamic> json) => _$FeatureAnalyticsFromJson(json);
  Map<String, dynamic> toJson() => _$FeatureAnalyticsToJson(this);

  @override
  List<Object?> get props => [featureName, userId, usageCount, totalTimeSpent, firstUsed, lastUsed, featureData];
}

@JsonSerializable()
class PerformanceAnalytics extends Equatable {
  final String metricName;
  final String userId;
  final double value;
  final DateTime timestamp;
  final String platform;
  final String appVersion;
  final Map<String, dynamic> metadata;

  const PerformanceAnalytics({
    required this.metricName,
    required this.userId,
    required this.value,
    required this.timestamp,
    required this.platform,
    required this.appVersion,
    this.metadata = const {},
  });

  factory PerformanceAnalytics.fromJson(Map<String, dynamic> json) => _$PerformanceAnalyticsFromJson(json);
  Map<String, dynamic> toJson() => _$PerformanceAnalyticsToJson(this);

  @override
  List<Object?> get props => [metricName, userId, value, timestamp, platform, appVersion, metadata];
}

@JsonSerializable()
class ErrorAnalytics extends Equatable {
  final String errorId;
  final String userId;
  final String errorType;
  final String errorMessage;
  final String? stackTrace;
  final DateTime timestamp;
  final String platform;
  final String appVersion;
  final String? roomId;
  final String? featureName;
  final Map<String, dynamic> context;

  const ErrorAnalytics({
    required this.errorId,
    required this.userId,
    required this.errorType,
    required this.errorMessage,
    this.stackTrace,
    required this.timestamp,
    required this.platform,
    required this.appVersion,
    this.roomId,
    this.featureName,
    this.context = const {},
  });

  factory ErrorAnalytics.fromJson(Map<String, dynamic> json) => _$ErrorAnalyticsFromJson(json);
  Map<String, dynamic> toJson() => _$ErrorAnalyticsToJson(this);

  @override
  List<Object?> get props => [
    errorId, userId, errorType, errorMessage, stackTrace, timestamp,
    platform, appVersion, roomId, featureName, context
  ];
}

@JsonSerializable()
class NetworkAnalytics extends Equatable {
  final String requestId;
  final String userId;
  final String endpoint;
  final String method;
  final int statusCode;
  final int responseSize;
  final Duration duration;
  final DateTime timestamp;
  final String platform;
  final Map<String, dynamic> metadata;

  const NetworkAnalytics({
    required this.requestId,
    required this.userId,
    required this.endpoint,
    required this.method,
    required this.statusCode,
    this.responseSize = 0,
    required this.duration,
    required this.timestamp,
    required this.platform,
    this.metadata = const {},
  });

  factory NetworkAnalytics.fromJson(Map<String, dynamic> json) => _$NetworkAnalyticsFromJson(json);
  Map<String, dynamic> toJson() => _$NetworkAnalyticsToJson(this);

  @override
  List<Object?> get props => [
    requestId, userId, endpoint, method, statusCode, responseSize,
    duration, timestamp, platform, metadata
  ];
}

@JsonSerializable()
class ErrorEvent extends Equatable {
  final String type;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  const ErrorEvent({
    required this.type,
    required this.message,
    required this.timestamp,
    this.data = const {},
  });

  factory ErrorEvent.fromJson(Map<String, dynamic> json) => _$ErrorEventFromJson(json);
  Map<String, dynamic> toJson() => _$ErrorEventToJson(this);

  @override
  List<Object?> get props => [type, message, timestamp, data];
}

@JsonSerializable()
class AnalyticsReport extends Equatable {
  final String reportId;
  final String userId;
  final DateTime generatedAt;
  final DateTime periodStart;
  final DateTime periodEnd;
  final UserAnalytics userSummary;
  final List<FeatureUsageReport> featureReports;
  final List<PerformanceReport> performanceReports;
  final List<ErrorReport> errorReports;
  final NetworkReport networkReport;

  const AnalyticsReport({
    required this.reportId,
    required this.userId,
    required this.generatedAt,
    required this.periodStart,
    required this.periodEnd,
    required this.userSummary,
    this.featureReports = const [],
    this.performanceReports = const [],
    this.errorReports = const [],
    required this.networkReport,
  });

  factory AnalyticsReport.fromJson(Map<String, dynamic> json) => _$AnalyticsReportFromJson(json);
  Map<String, dynamic> toJson() => _$AnalyticsReportToJson(this);

  @override
  List<Object?> get props => [
    reportId, userId, generatedAt, periodStart, periodEnd,
    userSummary, featureReports, performanceReports, errorReports, networkReport
  ];
}

@JsonSerializable()
class FeatureUsageReport extends Equatable {
  final String featureName;
  final int usageCount;
  final Duration totalTime;
  final double averageTime;
  final int uniqueUsers;

  const FeatureUsageReport({
    required this.featureName,
    this.usageCount = 0,
    this.totalTime = Duration.zero,
    this.averageTime = 0.0,
    this.uniqueUsers = 0,
  });

  factory FeatureUsageReport.fromJson(Map<String, dynamic> json) => _$FeatureUsageReportFromJson(json);
  Map<String, dynamic> toJson() => _$FeatureUsageReportToJson(this);

  @override
  List<Object?> get props => [featureName, usageCount, totalTime, averageTime, uniqueUsers];
}

@JsonSerializable()
class PerformanceReport extends Equatable {
  final String metricName;
  final double averageValue;
  final double minValue;
  final double maxValue;
  final double p50Value;
  final double p95Value;
  final double p99Value;
  final int sampleCount;

  const PerformanceReport({
    required this.metricName,
    this.averageValue = 0.0,
    this.minValue = 0.0,
    this.maxValue = 0.0,
    this.p50Value = 0.0,
    this.p95Value = 0.0,
    this.p99Value = 0.0,
    this.sampleCount = 0,
  });

  factory PerformanceReport.fromJson(Map<String, dynamic> json) => _$PerformanceReportFromJson(json);
  Map<String, dynamic> toJson() => _$PerformanceReportToJson(this);

  @override
  List<Object?> get props => [metricName, averageValue, minValue, maxValue, p50Value, p95Value, p99Value, sampleCount];
}

@JsonSerializable()
class ErrorReport extends Equatable {
  final String errorType;
  final int occurrenceCount;
  final int affectedUsers;
  final DateTime firstOccurrence;
  final DateTime lastOccurrence;
  final List<String> commonMessages;

  const ErrorReport({
    required this.errorType,
    this.occurrenceCount = 0,
    this.affectedUsers = 0,
    required this.firstOccurrence,
    required this.lastOccurrence,
    this.commonMessages = const [],
  });

  factory ErrorReport.fromJson(Map<String, dynamic> json) => _$ErrorReportFromJson(json);
  Map<String, dynamic> toJson() => _$ErrorReportToJson(this);

  @override
  List<Object?> get props => [errorType, occurrenceCount, affectedUsers, firstOccurrence, lastOccurrence, commonMessages];
}

@JsonSerializable()
class NetworkReport extends Equatable {
  final int totalRequests;
  final double averageResponseTime;
  final int successCount;
  final int errorCount;
  final double successRate;
  final Map<String, int> statusCodeDistribution;
  final Map<String, double> averageResponseTimeByEndpoint;

  const NetworkReport({
    this.totalRequests = 0,
    this.averageResponseTime = 0.0,
    this.successCount = 0,
    this.errorCount = 0,
    this.successRate = 0.0,
    this.statusCodeDistribution = const {},
    this.averageResponseTimeByEndpoint = const {},
  });

  factory NetworkReport.fromJson(Map<String, dynamic> json) => _$NetworkReportFromJson(json);
  Map<String, dynamic> toJson() => _$NetworkReportToJson(this);

  @override
  List<Object?> get props => [
    totalRequests, averageResponseTime, successCount, errorCount,
    successRate, statusCodeDistribution, averageResponseTimeByEndpoint
  ];
}

@JsonSerializable()
class AnalyticsConfig extends Equatable {
  final bool enabled;
  final bool trackUserAnalytics;
  final bool trackFeatureUsage;
  final bool trackPerformance;
  final bool trackErrors;
  final bool trackNetwork;
  final Duration dataRetentionPeriod;
  final int maxEventsPerSession;
  final bool anonymizeUserData;
  final List<String> allowedPlatforms;

  const AnalyticsConfig({
    this.enabled = true,
    this.trackUserAnalytics = true,
    this.trackFeatureUsage = true,
    this.trackPerformance = true,
    this.trackErrors = true,
    this.trackNetwork = true,
    this.dataRetentionPeriod = const Duration(days: 90),
    this.maxEventsPerSession = 1000,
    this.anonymizeUserData = false,
    this.allowedPlatforms = const ['ios', 'android', 'web', 'desktop'],
  });

  factory AnalyticsConfig.fromJson(Map<String, dynamic> json) => _$AnalyticsConfigFromJson(json);
  Map<String, dynamic> toJson() => _$AnalyticsConfigToJson(this);

  @override
  List<Object?> get props => [
    enabled, trackUserAnalytics, trackFeatureUsage, trackPerformance,
    trackErrors, trackNetwork, dataRetentionPeriod, maxEventsPerSession,
    anonymizeUserData, allowedPlatforms
  ];
}

@JsonSerializable()
class AnalyticsEvent extends Equatable {
  final String eventId;
  final String userId;
  final String eventType;
  final DateTime timestamp;
  final Map<String, dynamic> data;
  final String platform;
  final String appVersion;

  const AnalyticsEvent({
    required this.eventId,
    required this.userId,
    required this.eventType,
    required this.timestamp,
    this.data = const {},
    required this.platform,
    required this.appVersion,
  });

  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) => _$AnalyticsEventFromJson(json);
  Map<String, dynamic> toJson() => _$AnalyticsEventToJson(this);

  @override
  List<Object?> get props => [eventId, userId, eventType, timestamp, data, platform, appVersion];
}

@JsonSerializable()
class AnalyticsInsight extends Equatable {
  final String insightId;
  final String type;
  final String title;
  final String description;
  final Map<String, dynamic> data;
  final DateTime generatedAt;
  final String confidence;

  const AnalyticsInsight({
    required this.insightId,
    required this.type,
    required this.title,
    required this.description,
    this.data = const {},
    required this.generatedAt,
    this.confidence = 'medium',
  });

  factory AnalyticsInsight.fromJson(Map<String, dynamic> json) => _$AnalyticsInsightFromJson(json);
  Map<String, dynamic> toJson() => _$AnalyticsInsightToJson(this);

  @override
  List<Object?> get props => [insightId, type, title, description, data, generatedAt, confidence];
}

@JsonSerializable()
class AnalyticsQuery extends Equatable {
  final String queryId;
  final String userId;
  final AnalyticsQueryType type;
  final Map<String, dynamic> parameters;
  final DateTime createdAt;
  final QueryStatus status;

  const AnalyticsQuery({
    required this.queryId,
    required this.userId,
    required this.type,
    this.parameters = const {},
    required this.createdAt,
    this.status = QueryStatus.pending,
  });

  factory AnalyticsQuery.fromJson(Map<String, dynamic> json) => _$AnalyticsQueryFromJson(json);
  Map<String, dynamic> toJson() => _$AnalyticsQueryToJson(this);

  @override
  List<Object?> get props => [queryId, userId, type, parameters, createdAt, status];
}

@JsonSerializable()
class AnalyticsQueryResult extends Equatable {
  final String queryId;
  final bool success;
  final List<AnalyticsData> data;
  final AnalyticsReport? report;
  final List<String>? errors;
  final DateTime completedAt;

  const AnalyticsQueryResult({
    required this.queryId,
    required this.success,
    this.data = const [],
    this.report,
    this.errors,
    required this.completedAt,
  });

  const AnalyticsQueryResult.success({
    required this.queryId,
    this.data = const [],
    this.report,
    required this.completedAt,
  }) : success = true, errors = null;

  const AnalyticsQueryResult.failure({
    required this.queryId,
    this.errors,
    required this.completedAt,
  }) : success = false, data = const [], report = null;

  factory AnalyticsQueryResult.fromJson(Map<String, dynamic> json) => _$AnalyticsQueryResultFromJson(json);
  Map<String, dynamic> toJson() => _$AnalyticsQueryResultToJson(this);

  @override
  List<Object?> get props => [queryId, success, data, report, errors, completedAt];
}

enum AnalyticsQueryType {
  userActivity,
  featureUsage,
  performanceMetrics,
  errorAnalysis,
  networkAnalysis,
  customReport,
}

enum QueryStatus {
  pending,
  running,
  completed,
  failed,
  cancelled,
}
