import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';
import 'package:katya/store/events/model.dart';
import 'package:katya/store/rooms/room/model.dart';
import 'package:katya/store/user/model.dart';
import 'package:katya/verticals/trust_network/models/trust_network_models.dart';

/// Trust Network Services
/// Advanced trust and reputation management system

class TrustNetworkService {
  final Box<TrustScore> _trustScoreBox;
  final Box<TrustNetwork> _trustNetworkBox;
  final Box<TrustEvent> _trustEventBox;
  final Random _random = Random.secure();
  static const double _baseTrustScore = 0.5;
  static const double _maxTrustScore = 1.0;
  static const double _minTrustScore = 0.0;

  TrustNetworkService({
    required Box<TrustScore> trustScoreBox,
    required Box<TrustNetwork> trustNetworkBox,
    required Box<TrustEvent> trustEventBox,
  })  : _trustScoreBox = trustScoreBox,
        _trustNetworkBox = trustNetworkBox,
        _trustEventBox = trustEventBox;

  /// Initialize trust network for a user
  Future<TrustNetwork> initializeUserTrust(String userId) async {
    final trustScore = TrustScore(
      userId: userId,
      score: _baseTrustScore,
      level: TrustLevel.fromScore(_baseTrustScore),
      lastUpdated: DateTime.now(),
      factors: _getDefaultTrustFactors(),
    );

    final trustNetwork = TrustNetwork(
      userId: userId,
      score: trustScore,
      connections: const {},
      recommendations: const [],
      settings: _getDefaultTrustSettings(),
    );

    await _trustScoreBox.put(userId, trustScore);
    await _trustNetworkBox.put(userId, trustNetwork);

    // Record initial trust event
    await _recordTrustEvent(
      userId: userId,
      type: TrustEventType.accountVerified,
      scoreChange: 0.0,
      description: 'Account initialized',
    );

    return trustNetwork;
  }

  /// Update trust score based on user actions
  Future<void> updateTrustScore({
    required String userId,
    required TrustEventType eventType,
    double scoreChange = 0.0,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    final currentScore = await _trustScoreBox.get(userId);
    if (currentScore == null) {
      await initializeUserTrust(userId);
      return;
    }

    // Calculate score change based on event type
    final calculatedScoreChange = scoreChange != 0.0
        ? scoreChange
        : _calculateScoreChange(eventType, metadata);

    // Apply score change with bounds checking
    final newScore = (currentScore.score + calculatedScoreChange)
        .clamp(_minTrustScore, _maxTrustScore);

    // Update factors
    final updatedFactors = Map<String, double>.from(currentScore.factors);
    _updateTrustFactors(updatedFactors, eventType, calculatedScoreChange);

    final updatedScore = currentScore.copyWith(
      score: newScore,
      level: TrustLevel.fromScore(newScore),
      lastUpdated: DateTime.now(),
      factors: updatedFactors,
    );

    await _trustScoreBox.put(userId, updatedScore);

    // Record trust event
    await _recordTrustEvent(
      userId: userId,
      type: eventType,
      scoreChange: calculatedScoreChange,
      description: description ?? _getEventDescription(eventType),
      metadata: metadata,
    );

    // Update trust network
    await _updateTrustNetwork(userId);
  }

  /// Get trust score for a user
  Future<TrustScore?> getTrustScore(String userId) async {
    return await _trustScoreBox.get(userId);
  }

  /// Get trust network for a user
  Future<TrustNetwork?> getTrustNetwork(String userId) async {
    return await _trustNetworkBox.get(userId);
  }

  /// Add trust connection between users
  Future<void> addTrustConnection({
    required String userId,
    required String connectedUserId,
    required TrustConnectionType type,
    Map<String, dynamic>? metadata,
  }) async {
    final trustNetwork = await _trustNetworkBox.get(userId);
    if (trustNetwork == null) return;

    final connection = TrustConnection(
      connectedUserId: connectedUserId,
      trustScore: _calculateConnectionTrustScore(userId, connectedUserId, type),
      type: type,
      establishedAt: DateTime.now(),
      lastInteraction: DateTime.now(),
      interactionCount: 1,
      metadata: metadata,
    );

    final updatedConnections = Map<String, TrustConnection>.from(trustNetwork.connections);
    updatedConnections[connectedUserId] = connection;

    final updatedNetwork = trustNetwork.copyWith(connections: updatedConnections);
    await _trustNetworkBox.put(userId, updatedNetwork);

    // Update trust scores based on connection
    await _updateTrustFromConnection(userId, connectedUserId, type);
  }

  /// Generate trust recommendations for a user
  Future<List<TrustRecommendation>> generateRecommendations(String userId) async {
    final trustNetwork = await _trustNetworkBox.get(userId);
    if (trustNetwork == null) return [];

    final recommendations = <TrustRecommendation>[];

    // Generate mutual connections recommendations
    recommendations.addAll(await _generateMutualConnectionRecommendations(userId));

    // Generate interest-based recommendations
    recommendations.addAll(await _generateInterestBasedRecommendations(userId));

    // Generate location-based recommendations
    recommendations.addAll(await _generateLocationBasedRecommendations(userId));

    // Sort by confidence and return top recommendations
    recommendations.sort((a, b) => b.confidence.compareTo(a.confidence));

    return recommendations.take(10).toList();
  }

  /// Verify user identity
  Future<TrustVerification> requestVerification({
    required String userId,
    required VerificationType type,
    Map<String, dynamic>? verificationData,
  }) async {
    final verification = TrustVerification(
      id: _generateId(),
      userId: userId,
      type: type,
      status: VerificationStatus.pending,
      requestedAt: DateTime.now(),
      verificationData: verificationData,
    );

    // In a real implementation, this would be stored and processed
    // For now, we'll simulate verification

    // Auto-verify certain types for demonstration
    if (type == VerificationType.email || type == VerificationType.phone) {
      // Simulate verification process
      await Future.delayed(const Duration(seconds: 2));

      // Update trust score for verification
      await updateTrustScore(
        userId: userId,
        eventType: TrustEventType.accountVerified,
        scoreChange: 0.2,
        description: '${type.name} verification completed',
        metadata: {'verificationType': type.name},
      );
    }

    return verification;
  }

  /// Generate trust report for a user
  Future<TrustReport> generateTrustReport(String userId) async {
    final trustScore = await _trustScoreBox.get(userId);
    final trustNetwork = await _trustNetworkBox.get(userId);

    if (trustScore == null || trustNetwork == null) {
      throw TrustException('Trust data not found for user: $userId');
    }

    // Get score history (simplified for this implementation)
    final scoreHistory = [trustScore];

    // Generate insights
    final insights = await _generateTrustInsights(userId, trustScore);

    // Generate recommendations
    final recommendations = _generateTrustRecommendations(userId, trustScore);

    return TrustReport(
      id: _generateId(),
      userId: userId,
      reportDate: DateTime.now(),
      currentScore: trustScore,
      scoreHistory: scoreHistory,
      insights: insights,
      recommendations: recommendations,
    );
  }

  /// Get trust analytics for a user
  Future<TrustAnalytics> getTrustAnalytics(String userId) async {
    final trustScore = await _trustScoreBox.get(userId);
    final trustNetwork = await _trustNetworkBox.get(userId);

    if (trustScore == null || trustNetwork == null) {
      throw TrustException('Trust data not found for user: $userId');
    }

    final metrics = _calculateTrustMetrics(trustScore, trustNetwork);
    final insights = await _generateTrustInsights(userId, trustScore);

    return TrustAnalytics(
      userId: userId,
      metrics: metrics,
      insights: insights,
      generatedAt: DateTime.now(),
    );
  }

  // Private helper methods

  double _calculateScoreChange(TrustEventType eventType, Map<String, dynamic>? metadata) {
    switch (eventType) {
      case TrustEventType.messageSent:
        return 0.01;
      case TrustEventType.messageReceived:
        return 0.005;
      case TrustEventType.fileShared:
        return 0.02;
      case TrustEventType.contactAdded:
        return 0.05;
      case TrustEventType.positiveFeedback:
        return 0.1;
      case TrustEventType.negativeFeedback:
        return -0.1;
      case TrustEventType.accountVerified:
        return 0.2;
      case TrustEventType.securityViolation:
        return -0.3;
      case TrustEventType.suspiciousActivity:
        return -0.2;
      case TrustEventType.profileCompleted:
        return 0.1;
      case TrustEventType.consistentUsage:
        return 0.05;
      case TrustEventType.longTermUser:
        return 0.1;
      case TrustEventType.communityContribution:
        return 0.15;
      case TrustEventType.moderationAction:
        return metadata?['positive'] == true ? 0.1 : -0.1;
      case TrustEventType.accountRecovery:
        return -0.05;
      case TrustEventType.deviceChange:
        return -0.02;
      case TrustEventType.locationChange:
        return -0.01;
      case TrustEventType.timePatternChange:
        return -0.01;
    }
  }

  Map<String, double> _getDefaultTrustFactors() {
    return {
      'communication': 0.3,
      'security': 0.25,
      'activity': 0.2,
      'connections': 0.15,
      'verification': 0.1,
    };
  }

  Map<String, dynamic> _getDefaultTrustSettings() {
    return {
      'autoUpdate': true,
      'publicScore': false,
      'allowRecommendations': true,
      'notificationThreshold': 0.7,
    };
  }

  void _updateTrustFactors(Map<String, double> factors, TrustEventType eventType, double scoreChange) {
    switch (eventType) {
      case TrustEventType.messageSent:
      case TrustEventType.messageReceived:
        factors['communication'] = (factors['communication'] ?? 0) + (scoreChange * 0.4);
        factors['activity'] = (factors['activity'] ?? 0) + (scoreChange * 0.3);
      case TrustEventType.accountVerified:
      case TrustEventType.securityViolation:
        factors['security'] = (factors['security'] ?? 0) + scoreChange;
        factors['verification'] = (factors['verification'] ?? 0) + (scoreChange * 0.8);
      case TrustEventType.contactAdded:
      case TrustEventType.positiveFeedback:
        factors['connections'] = (factors['connections'] ?? 0) + (scoreChange * 0.6);
        factors['communication'] = (factors['communication'] ?? 0) + (scoreChange * 0.2);
      case TrustEventType.suspiciousActivity:
        factors['security'] = (factors['security'] ?? 0) + scoreChange;
        factors['activity'] = (factors['activity'] ?? 0) + (scoreChange * 0.5);
      default:
        factors['activity'] = (factors['activity'] ?? 0) + (scoreChange * 0.2);
    }

    // Normalize factors to sum to 1.0
    final total = factors.values.fold(0.0, (sum, value) => sum + value);
    if (total > 0) {
      factors.updateAll((key, value) => value / total);
    }
  }

  String _getEventDescription(TrustEventType eventType) {
    switch (eventType) {
      case TrustEventType.messageSent:
        return 'Message sent';
      case TrustEventType.messageReceived:
        return 'Message received';
      case TrustEventType.fileShared:
        return 'File shared';
      case TrustEventType.contactAdded:
        return 'Contact added';
      case TrustEventType.positiveFeedback:
        return 'Positive feedback received';
      case TrustEventType.negativeFeedback:
        return 'Negative feedback received';
      case TrustEventType.accountVerified:
        return 'Account verified';
      case TrustEventType.securityViolation:
        return 'Security violation detected';
      case TrustEventType.suspiciousActivity:
        return 'Suspicious activity detected';
      case TrustEventType.profileCompleted:
        return 'Profile completed';
      case TrustEventType.consistentUsage:
        return 'Consistent usage pattern';
      case TrustEventType.longTermUser:
        return 'Long-term user status';
      case TrustEventType.communityContribution:
        return 'Community contribution';
      case TrustEventType.moderationAction:
        return 'Moderation action taken';
      case TrustEventType.accountRecovery:
        return 'Account recovery performed';
      case TrustEventType.deviceChange:
        return 'Device changed';
      case TrustEventType.locationChange:
        return 'Location changed';
      case TrustEventType.timePatternChange:
        return 'Usage pattern changed';
    }
  }

  double _calculateConnectionTrustScore(String userId, String connectedUserId, TrustConnectionType type) {
    // Base score depends on connection type
    final baseScore = switch (type) {
      TrustConnectionType.direct => 0.7,
      TrustConnectionType.institutional => 0.9,
      TrustConnectionType.indirect => 0.5,
      TrustConnectionType.algorithmic => 0.6,
      TrustConnectionType.manual => 0.8,
    };

    // Adjust based on individual trust scores
    // Implementation would check both users' trust scores

    return baseScore;
  }

  Future<void> _updateTrustFromConnection(String userId, String connectedUserId, TrustConnectionType type) async {
    // Update trust scores based on the connection
    final connectionScore = _calculateConnectionTrustScore(userId, connectedUserId, type);

    await updateTrustScore(
      userId: userId,
      eventType: TrustEventType.contactAdded,
      scoreChange: connectionScore * 0.1,
      description: 'Trust connection established',
      metadata: {'connectionType': type.name, 'connectedUser': connectedUserId},
    );
  }

  Future<List<TrustRecommendation>> _generateMutualConnectionRecommendations(String userId) async {
    // Implementation would analyze mutual connections
    return [];
  }

  Future<List<TrustRecommendation>> _generateInterestBasedRecommendations(String userId) async {
    // Implementation would analyze user interests and behavior
    return [];
  }

  Future<List<TrustRecommendation>> _generateLocationBasedRecommendations(String userId) async {
    // Implementation would analyze location-based connections
    return [];
  }

  Future<void> _recordTrustEvent({
    required String userId,
    required TrustEventType type,
    required double scoreChange,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    final event = TrustEvent(
      id: _generateId(),
      userId: userId,
      type: type,
      scoreChange: scoreChange,
      description: description,
      timestamp: DateTime.now(),
      metadata: metadata,
    );

    await _trustEventBox.put(event.id, event);
  }

  Future<void> _updateTrustNetwork(String userId) async {
    final trustNetwork = await _trustNetworkBox.get(userId);
    if (trustNetwork == null) return;

    final trustScore = await _trustScoreBox.get(userId);
    if (trustScore == null) return;

    final updatedNetwork = trustNetwork.copyWith(score: trustScore);
    await _trustNetworkBox.put(userId, updatedNetwork);
  }

  Map<String, double> _calculateTrustMetrics(TrustScore trustScore, TrustNetwork trustNetwork) {
    return {
      'overall_score': trustScore.score,
      'connection_count': trustNetwork.connections.length.toDouble(),
      'average_connection_trust': trustNetwork.connections.isNotEmpty
          ? trustNetwork.connections.values
              .map((c) => c.trustScore)
              .reduce((a, b) => a + b) / trustNetwork.connections.length
          : 0.0,
      'recommendation_count': trustNetwork.recommendations.length.toDouble(),
      'verification_count': 0.0, // Would count actual verifications
    };
  }

  Future<List<TrustInsight>> _generateTrustInsights(String userId, TrustScore trustScore) async {
    final insights = <TrustInsight>[];

    // Generate insights based on trust score and behavior
    if (trustScore.score > 0.8) {
      insights.add(TrustInsight(
        id: _generateId(),
        title: 'High Trust Score',
        description: 'Your trust score is excellent. You have established strong connections and positive interactions.',
        type: TrustInsightType.positive,
        confidence: 0.9,
        generatedAt: DateTime.now(),
        data: {'score': trustScore.score},
      ));
    }

    if (trustScore.factors['security'] ?? 0 < 0.1) {
      insights.add(TrustInsight(
        id: _generateId(),
        title: 'Security Enhancement Recommended',
        description: 'Consider enabling additional security features to improve your trust score.',
        type: TrustInsightType.recommendation,
        confidence: 0.8,
        generatedAt: DateTime.now(),
        data: {'factor': 'security', 'current': trustScore.factors['security']},
      ));
    }

    return insights;
  }

  Map<String, dynamic> _generateTrustRecommendations(String userId, TrustScore trustScore) {
    return {
      'improve_security': trustScore.factors['security'] ?? 0 < 0.2,
      'complete_profile': trustScore.factors['verification'] ?? 0 < 0.3,
      'increase_activity': trustScore.factors['activity'] ?? 0 < 0.2,
      'build_connections': (await _trustNetworkBox.get(userId))?.connections.length < 5,
    };
  }

  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = _random.nextInt(999999).toString().padLeft(6, '0');
    final hash = sha256.convert(utf8.encode(timestamp + random)).toString().substring(0, 16);
    return hash;
  }
}

/// Trust and reputation calculation service
class TrustCalculationService {
  static double calculateMessageTrustImpact(int messageCount, int timeWindowHours) {
    // Calculate trust impact based on message frequency
    final messagesPerHour = messageCount / timeWindowHours;

    if (messagesPerHour < 0.1) return 0.01;  // Very low activity
    if (messagesPerHour < 1.0) return 0.05;  // Low activity
    if (messagesPerHour < 5.0) return 0.1;   // Moderate activity
    if (messagesPerHour < 10.0) return 0.05; // High activity (slight penalty)
    return -0.1; // Very high activity (spam suspicion)
  }

  static double calculateConnectionTrustImpact(int connectionCount, double averageConnectionScore) {
    // Calculate trust impact based on connections
    final connectionBonus = (connectionCount / 10.0).clamp(0.0, 0.2);
    final qualityBonus = averageConnectionScore * 0.1;

    return connectionBonus + qualityBonus;
  }

  static double calculateVerificationTrustImpact(List<VerificationType> verifications) {
    // Calculate trust impact based on verifications
    double totalImpact = 0.0;

    for (final verification in verifications) {
      totalImpact += switch (verification) {
        VerificationType.email => 0.1,
        VerificationType.phone => 0.15,
        VerificationType.governmentId => 0.3,
        VerificationType.institutional => 0.25,
        VerificationType.biometric => 0.2,
        VerificationType.deviceFingerprint => 0.05,
        VerificationType.socialMedia => 0.1,
        VerificationType.financial => 0.2,
        VerificationType.educational => 0.15,
        VerificationType.professional => 0.2,
      };
    }

    return totalImpact.clamp(0.0, 0.5); // Cap at 0.5 to prevent over-verification
  }

  static double calculateSecurityTrustImpact(SecurityMetrics metrics) {
    // Calculate trust impact based on security metrics
    double impact = 0.0;

    if (metrics.twoFactorEnabled) impact += 0.1;
    if (metrics.encryptionEnabled) impact += 0.15;
    if (metrics.regularBackups) impact += 0.05;
    if (metrics.strongPassword) impact += 0.1;
    if (metrics.noSecurityIncidents) impact += 0.1;

    // Penalty for security incidents
    impact -= metrics.securityIncidents * 0.2;

    return impact.clamp(-0.5, 0.3);
  }

  static double calculateActivityTrustImpact(ActivityMetrics metrics) {
    // Calculate trust impact based on activity patterns
    double impact = 0.0;

    // Consistent usage bonus
    if (metrics.regularUsage) impact += 0.1;

    // Long-term user bonus
    if (metrics.accountAgeDays > 365) {
      impact += 0.1;
    } else if (metrics.accountAgeDays > 90) impact += 0.05;

    // Penalty for suspicious patterns
    if (metrics.suspiciousLoginAttempts > 0) impact -= 0.1;
    if (metrics.unusualLocationChanges > 0) impact -= 0.05;
    if (metrics.deviceChanges > 2) impact -= 0.1;

    return impact.clamp(-0.3, 0.2);
  }
}

/// Supporting models and structures

class SecurityMetrics {
  final bool twoFactorEnabled;
  final bool encryptionEnabled;
  final bool regularBackups;
  final bool strongPassword;
  final bool noSecurityIncidents;
  final int securityIncidents;

  const SecurityMetrics({
    this.twoFactorEnabled = false,
    this.encryptionEnabled = false,
    this.regularBackups = false,
    this.strongPassword = false,
    this.noSecurityIncidents = true,
    this.securityIncidents = 0,
  });
}

class ActivityMetrics {
  final bool regularUsage;
  final int accountAgeDays;
  final int suspiciousLoginAttempts;
  final int unusualLocationChanges;
  final int deviceChanges;

  const ActivityMetrics({
    this.regularUsage = false,
    this.accountAgeDays = 0,
    this.suspiciousLoginAttempts = 0,
    this.unusualLocationChanges = 0,
    this.deviceChanges = 0,
  });
}

/// Custom exception for trust-related errors
class TrustException implements Exception {
  final String message;
  final String? userId;

  TrustException(this.message, [this.userId]);

  @override
  String toString() => 'TrustException: $message${userId != null ? ' (User: $userId)' : ''}';
}
