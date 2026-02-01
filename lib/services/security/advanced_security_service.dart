import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';
import 'models/security_policy.dart';
import 'models/security_rule.dart';

/// Продвинутый сервис безопасности и защиты
class AdvancedSecurityService {
  static final AdvancedSecurityService _instance = AdvancedSecurityService._internal();

  // Системы безопасности
  final Map<String, SecurityPolicy> _securityPolicies = {};
  final Map<String, ThreatDetection> _threatDetections = {};
  final Map<String, SecurityEvent> _securityEvents = {};
  final Map<String, AccessControl> _accessControls = {};

  // Криптографические ключи и сертификаты
  final Map<String, EncryptionKey> _encryptionKeys = {};
  final Map<String, DigitalCertificate> _certificates = {};
  final Map<String, SecurityToken> _securityTokens = {};

  // Конфигурация
  static const Duration _tokenExpirationTime = Duration(hours: 24);
  static const Duration _keyRotationInterval = Duration(days: 30);
  static const int _maxFailedAttempts = 5;
  static const Duration _lockoutDuration = Duration(minutes: 30);

  factory AdvancedSecurityService() => _instance;
  AdvancedSecurityService._internal();

  /// Инициализация сервиса
  Future<void> initialize() async {
    await _initializeDefaultPolicies();
    await _generateDefaultKeys();
    _setupSecurityMonitoring();
    _setupKeyRotation();
  }

  /// Создание политики безопасности
  Future<SecurityPolicyResult> createSecurityPolicy({
    required String policyId,
    required String name,
    required SecurityLevel level,
    required List<SecurityRule> rules,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final policy = SecurityPolicy(
        policyId: policyId,
        name: name,
        level: level,
        rules: rules,
        metadata: metadata ?? {},
        isActive: true,
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
        appliedCount: 0,
      );

      _securityPolicies[policyId] = policy;

      return SecurityPolicyResult(
        policyId: policyId,
        success: true,
      );
    } catch (e) {
      return SecurityPolicyResult(
        policyId: policyId,
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Применение политики безопасности
  Future<bool> applySecurityPolicy(String policyId, String targetId) async {
    final policy = _securityPolicies[policyId];
    if (policy == null || !policy.isActive) {
      return false;
    }

    try {
      // Применяем правила политики
      for (final rule in policy.rules) {
        await _applySecurityRule(rule, targetId);
      }

      policy.appliedCount++;
      policy.lastModified = DateTime.now();

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Обнаружение угроз
  Future<ThreatDetectionResult> detectThreats({
    required String sourceId,
    required ThreatType threatType,
    required Map<String, dynamic> threatData,
    ThreatSeverity severity = ThreatSeverity.medium,
  }) async {
    try {
      final detection = ThreatDetection(
        detectionId: _generateId(),
        sourceId: sourceId,
        threatType: threatType,
        severity: severity,
        threatData: threatData,
        detectedAt: DateTime.now(),
        status: ThreatStatus.detected,
        confidence: _calculateThreatConfidence(threatType, threatData),
        mitigationActions: const [],
      );

      _threatDetections[detection.detectionId] = detection;

      // Автоматическое применение мер противодействия
      await _applyThreatMitigation(detection);

      // Записываем событие безопасности
      await _recordSecurityEvent(
        eventType: SecurityEventType.threatDetected,
        sourceId: sourceId,
        details: threatData,
        severity: severity,
      );

      return ThreatDetectionResult(
        detectionId: detection.detectionId,
        success: true,
        confidence: detection.confidence,
        mitigationApplied: detection.mitigationActions.isNotEmpty,
      );
    } catch (e) {
      return ThreatDetectionResult(
        detectionId: '',
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Контроль доступа
  Future<AccessControlResult> checkAccess({
    required String userId,
    required String resourceId,
    required AccessType accessType,
    Map<String, dynamic>? context,
  }) async {
    try {
      final accessControl = _accessControls[userId];
      if (accessControl == null) {
        return AccessControlResult(
          userId: userId,
          resourceId: resourceId,
          accessType: accessType,
          granted: false,
          reason: 'No access control defined for user',
        );
      }

      // Проверяем права доступа
      final hasAccess = await _evaluateAccessRights(accessControl, resourceId, accessType, context);

      // Записываем событие доступа
      await _recordSecurityEvent(
        eventType: hasAccess ? SecurityEventType.accessGranted : SecurityEventType.accessDenied,
        sourceId: userId,
        details: {
          'resourceId': resourceId,
          'accessType': accessType.name,
          'context': context,
        },
        severity: hasAccess ? ThreatSeverity.low : ThreatSeverity.medium,
      );

      return AccessControlResult(
        userId: userId,
        resourceId: resourceId,
        accessType: accessType,
        granted: hasAccess,
        reason: hasAccess ? 'Access granted' : 'Access denied by policy',
      );
    } catch (e) {
      return AccessControlResult(
        userId: userId,
        resourceId: resourceId,
        accessType: accessType,
        granted: false,
        reason: 'Error checking access: $e',
      );
    }
  }

  /// Генерация токена безопасности
  Future<SecurityTokenResult> generateSecurityToken({
    required String userId,
    required List<String> permissions,
    Duration? expiration,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final tokenId = _generateId();
      final token = _generateTokenValue();
      final expiresAt = DateTime.now().add(expiration ?? _tokenExpirationTime);

      final securityToken = SecurityToken(
        tokenId: tokenId,
        userId: userId,
        token: token,
        permissions: permissions,
        metadata: metadata ?? {},
        createdAt: DateTime.now(),
        expiresAt: expiresAt,
        isActive: true,
        usageCount: 0,
      );

      _securityTokens[tokenId] = securityToken;

      return SecurityTokenResult(
        tokenId: tokenId,
        token: token,
        success: true,
        expiresAt: expiresAt,
      );
    } catch (e) {
      return SecurityTokenResult(
        tokenId: '',
        token: '',
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Валидация токена
  Future<TokenValidationResult> validateToken(String token) async {
    try {
      final securityToken = _securityTokens.values.firstWhere(
        (t) => t.token == token && t.isActive,
        orElse: () => throw Exception('Token not found'),
      );

      if (DateTime.now().isAfter(securityToken.expiresAt)) {
        securityToken.isActive = false;
        return const TokenValidationResult(
          valid: false,
          reason: 'Token expired',
        );
      }

      securityToken.usageCount++;

      return TokenValidationResult(
        valid: true,
        userId: securityToken.userId,
        permissions: securityToken.permissions,
        expiresAt: securityToken.expiresAt,
      );
    } catch (e) {
      return TokenValidationResult(
        valid: false,
        reason: 'Invalid token: $e',
      );
    }
  }

  /// Шифрование данных
  Future<EncryptionResult> encryptData({
    required String data,
    required String keyId,
    EncryptionAlgorithm algorithm = EncryptionAlgorithm.aes256,
  }) async {
    try {
      final key = _encryptionKeys[keyId];
      if (key == null) {
        return EncryptionResult(
          success: false,
          errorMessage: 'Encryption key not found: $keyId',
        );
      }

      final encryptedData = _performEncryption(data, key, algorithm);
      final iv = _generateInitializationVector();

      return EncryptionResult(
        success: true,
        encryptedData: encryptedData,
        keyId: keyId,
        algorithm: algorithm,
        iv: iv,
      );
    } catch (e) {
      return EncryptionResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Расшифровка данных
  Future<DecryptionResult> decryptData({
    required String encryptedData,
    required String keyId,
    required String iv,
    EncryptionAlgorithm algorithm = EncryptionAlgorithm.aes256,
  }) async {
    try {
      final key = _encryptionKeys[keyId];
      if (key == null) {
        return DecryptionResult(
          success: false,
          errorMessage: 'Decryption key not found: $keyId',
        );
      }

      final decryptedData = _performDecryption(encryptedData, key, iv, algorithm);

      return DecryptionResult(
        success: true,
        decryptedData: decryptedData,
      );
    } catch (e) {
      return DecryptionResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Цифровая подпись
  Future<DigitalSignatureResult> createDigitalSignature({
    required String data,
    required String keyId,
    SignatureAlgorithm algorithm = SignatureAlgorithm.rsaSha256,
  }) async {
    try {
      final key = _encryptionKeys[keyId];
      if (key == null) {
        return DigitalSignatureResult(
          success: false,
          errorMessage: 'Signing key not found: $keyId',
        );
      }

      final signature = _performSigning(data, key, algorithm);
      final certificate = _certificates[keyId];

      return DigitalSignatureResult(
        success: true,
        signature: signature,
        algorithm: algorithm,
        certificate: certificate,
        signedAt: DateTime.now(),
      );
    } catch (e) {
      return DigitalSignatureResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Верификация цифровой подписи
  Future<SignatureVerificationResult> verifyDigitalSignature({
    required String data,
    required String signature,
    required String keyId,
    SignatureAlgorithm algorithm = SignatureAlgorithm.rsaSha256,
  }) async {
    try {
      final key = _encryptionKeys[keyId];
      if (key == null) {
        return SignatureVerificationResult(
          valid: false,
          reason: 'Verification key not found: $keyId',
        );
      }

      final isValid = _performSignatureVerification(data, signature, key, algorithm);
      final certificate = _certificates[keyId];

      return SignatureVerificationResult(
        valid: isValid,
        certificate: certificate,
        verifiedAt: DateTime.now(),
      );
    } catch (e) {
      return SignatureVerificationResult(
        valid: false,
        reason: 'Verification error: $e',
      );
    }
  }

  /// Анализ безопасности
  Future<SecurityAnalysisResult> analyzeSecurity({
    required String targetId,
    SecurityAnalysisType analysisType = SecurityAnalysisType.comprehensive,
  }) async {
    try {
      final vulnerabilities = await _scanVulnerabilities(targetId);
      final threats = _threatDetections.values.where((t) => t.sourceId == targetId).toList();
      final events = _securityEvents.values.where((e) => e.sourceId == targetId).toList();

      final riskScore = _calculateRiskScore(vulnerabilities, threats, events);
      final recommendations = _generateSecurityRecommendations(vulnerabilities, threats);

      return SecurityAnalysisResult(
        targetId: targetId,
        analysisType: analysisType,
        riskScore: riskScore,
        vulnerabilities: vulnerabilities,
        threats: threats,
        securityEvents: events,
        recommendations: recommendations,
        analyzedAt: DateTime.now(),
      );
    } catch (e) {
      return SecurityAnalysisResult(
        targetId: targetId,
        analysisType: analysisType,
        riskScore: 0.0,
        vulnerabilities: const [],
        threats: const [],
        securityEvents: const [],
        recommendations: const [],
        errorMessage: e.toString(),
      );
    }
  }

  /// Инициализация политик по умолчанию
  Future<void> _initializeDefaultPolicies() async {
    // Политика для высокого уровня безопасности
    await createSecurityPolicy(
      policyId: 'high_security',
      name: 'High Security Policy',
      level: SecurityLevel.high,
      rules: [
        const SecurityRule(
          ruleId: 'strong_passwords',
          name: 'Strong Password Requirements',
          type: RuleType.authentication,
          conditions: {'min_length': 12, 'require_special_chars': true},
          actions: [RuleAction.require, RuleAction.block],
        ),
        const SecurityRule(
          ruleId: 'two_factor_auth',
          name: 'Two-Factor Authentication',
          type: RuleType.authentication,
          conditions: {'required': true},
          actions: [RuleAction.require],
        ),
      ],
    );

    // Политика для среднего уровня безопасности
    await createSecurityPolicy(
      policyId: 'medium_security',
      name: 'Medium Security Policy',
      level: SecurityLevel.medium,
      rules: [
        const SecurityRule(
          ruleId: 'standard_passwords',
          name: 'Standard Password Requirements',
          type: RuleType.authentication,
          conditions: {'min_length': 8, 'require_special_chars': false},
          actions: [RuleAction.require],
        ),
      ],
    );
  }

  /// Генерация ключей по умолчанию
  Future<void> _generateDefaultKeys() async {
    // Генерируем ключи шифрования
    await _generateEncryptionKey('default_encryption', EncryptionAlgorithm.aes256);
    await _generateEncryptionKey('default_signing', EncryptionAlgorithm.rsa4096);

    // Генерируем сертификаты
    await _generateDigitalCertificate('default_certificate', 'default_signing');
  }

  /// Настройка мониторинга безопасности
  void _setupSecurityMonitoring() {
    Timer.periodic(const Duration(minutes: 5), (timer) async {
      await _performSecurityScan();
    });
  }

  /// Настройка ротации ключей
  void _setupKeyRotation() {
    Timer.periodic(_keyRotationInterval, (timer) async {
      await _rotateEncryptionKeys();
    });
  }

  /// Применение правила безопасности
  Future<void> _applySecurityRule(SecurityRule rule, String targetId) async {
    // Имитация применения правила
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Расчет уверенности в угрозе
  double _calculateThreatConfidence(ThreatType threatType, Map<String, dynamic> threatData) {
    double confidence = 0.5; // Базовая уверенность

    switch (threatType) {
      case ThreatType.malware:
        confidence += 0.3;
      case ThreatType.phishing:
        confidence += 0.2;
      case ThreatType.bruteForce:
        confidence += 0.4;
      case ThreatType.dataBreach:
        confidence += 0.35;
    }

    return min(1.0, confidence);
  }

  /// Применение мер противодействия угрозам
  Future<void> _applyThreatMitigation(ThreatDetection detection) async {
    final mitigationActions = <String>[];

    switch (detection.threatType) {
      case ThreatType.malware:
        mitigationActions.addAll(['quarantine', 'scan', 'alert']);
      case ThreatType.phishing:
        mitigationActions.addAll(['block_url', 'alert', 'educate']);
      case ThreatType.bruteForce:
        mitigationActions.addAll(['lockout', 'rate_limit', 'alert']);
      case ThreatType.dataBreach:
        mitigationActions.addAll(['isolate', 'investigate', 'notify']);
    }

    detection.mitigationActions.addAll(mitigationActions);
    detection.status = ThreatStatus.mitigated;
  }

  /// Запись события безопасности
  Future<void> _recordSecurityEvent({
    required SecurityEventType eventType,
    required String sourceId,
    required Map<String, dynamic> details,
    required ThreatSeverity severity,
  }) async {
    final event = SecurityEvent(
      eventId: _generateId(),
      eventType: eventType,
      sourceId: sourceId,
      details: details,
      severity: severity,
      timestamp: DateTime.now(),
      processed: false,
    );

    _securityEvents[event.eventId] = event;
  }

  /// Оценка прав доступа
  Future<bool> _evaluateAccessRights(
    AccessControl accessControl,
    String resourceId,
    AccessType accessType,
    Map<String, dynamic>? context,
  ) async {
    // Простая логика для демонстрации
    return accessControl.permissions.contains('${accessType.name}_$resourceId');
  }

  /// Генерация ID
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(1000).toString();
  }

  /// Генерация токена
  String _generateTokenValue() {
    final bytes = List<int>.generate(32, (i) => Random().nextInt(256));
    return base64Encode(bytes);
  }

  /// Шифрование
  String _performEncryption(String data, EncryptionKey key, EncryptionAlgorithm algorithm) {
    // Имитация шифрования
    final bytes = utf8.encode(data);
    return base64Encode(bytes);
  }

  /// Генерация вектора инициализации
  String _generateInitializationVector() {
    final bytes = List<int>.generate(16, (i) => Random().nextInt(256));
    return base64Encode(bytes);
  }

  /// Расшифровка
  String _performDecryption(String encryptedData, EncryptionKey key, String iv, EncryptionAlgorithm algorithm) {
    // Имитация расшифровки
    final bytes = base64Decode(encryptedData);
    return utf8.decode(bytes);
  }

  /// Подписание
  String _performSigning(String data, EncryptionKey key, SignatureAlgorithm algorithm) {
    // Имитация подписания
    final bytes = utf8.encode(data);
    final hash = sha256.convert(bytes);
    return base64Encode(hash.bytes);
  }

  /// Верификация подписи
  bool _performSignatureVerification(String data, String signature, EncryptionKey key, SignatureAlgorithm algorithm) {
    // Имитация верификации
    final expectedSignature = _performSigning(data, key, algorithm);
    return signature == expectedSignature;
  }

  /// Сканирование уязвимостей
  Future<List<SecurityVulnerability>> _scanVulnerabilities(String targetId) async {
    // Имитация сканирования
    await Future.delayed(const Duration(seconds: 2));

    final vulnerabilities = <SecurityVulnerability>[];
    if (Random().nextDouble() > 0.7) {
      vulnerabilities.add(SecurityVulnerability(
        vulnerabilityId: _generateId(),
        targetId: targetId,
        type: VulnerabilityType.injection,
        severity: ThreatSeverity.high,
        description: 'Potential SQL injection vulnerability',
        detectedAt: DateTime.now(),
      ));
    }

    return vulnerabilities;
  }

  /// Расчет оценки риска
  double _calculateRiskScore(
    List<SecurityVulnerability> vulnerabilities,
    List<ThreatDetection> threats,
    List<SecurityEvent> events,
  ) {
    double score = 0.0;

    // Уязвимости
    for (final vulnerability in vulnerabilities) {
      score += vulnerability.severity.index * 0.3;
    }

    // Угрозы
    for (final threat in threats) {
      score += threat.severity.index * 0.2;
    }

    // События
    for (final event in events) {
      score += event.severity.index * 0.1;
    }

    return min(1.0, score / 10.0);
  }

  /// Генерация рекомендаций по безопасности
  List<String> _generateSecurityRecommendations(
    List<SecurityVulnerability> vulnerabilities,
    List<ThreatDetection> threats,
  ) {
    final recommendations = <String>[];

    if (vulnerabilities.isNotEmpty) {
      recommendations.add('Update software and apply security patches');
    }

    if (threats.isNotEmpty) {
      recommendations.add('Implement additional monitoring and detection systems');
    }

    recommendations.add('Regular security audits and penetration testing');
    recommendations.add('Employee security awareness training');

    return recommendations;
  }

  /// Сканирование безопасности
  Future<void> _performSecurityScan() async {
    // Имитация сканирования
    await Future.delayed(const Duration(seconds: 1));
  }

  /// Ротация ключей шифрования
  Future<void> _rotateEncryptionKeys() async {
    // Имитация ротации ключей
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Генерация ключа шифрования
  Future<void> _generateEncryptionKey(String keyId, EncryptionAlgorithm algorithm) async {
    final key = EncryptionKey(
      keyId: keyId,
      algorithm: algorithm,
      keyData: _generateKeyData(),
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(_keyRotationInterval),
      isActive: true,
    );

    _encryptionKeys[keyId] = key;
  }

  /// Генерация данных ключа
  String _generateKeyData() {
    final bytes = List<int>.generate(32, (i) => Random().nextInt(256));
    return base64Encode(bytes);
  }

  /// Генерация цифрового сертификата
  Future<void> _generateDigitalCertificate(String certId, String keyId) async {
    final certificate = DigitalCertificate(
      certificateId: certId,
      keyId: keyId,
      subject: 'CN=Katya Security Service',
      issuer: 'CN=Katya Certificate Authority',
      validFrom: DateTime.now(),
      validTo: DateTime.now().add(const Duration(days: 365)),
      serialNumber: _generateId(),
      publicKey: _generateKeyData(),
    );

    _certificates[certId] = certificate;
  }

  /// Получение всех политик
  List<SecurityPolicy> getAllPolicies() {
    return _securityPolicies.values.toList();
  }

  /// Получение всех правил
  List<SecurityRule> getAllRules() {
    final rules = <SecurityRule>[];
    for (final policy in _securityPolicies.values) {
      rules.addAll(policy.rules);
    }
    return rules;
  }
}

/// Политика безопасности
class SecurityPolicy extends Equatable {
  final String policyId;
  final String name;
  final SecurityLevel level;
  final List<SecurityRule> rules;
  final Map<String, dynamic> metadata;
  bool isActive;
  final DateTime createdAt;
  DateTime lastModified;
  int appliedCount;

  SecurityPolicy({
    required this.policyId,
    required this.name,
    required this.level,
    required this.rules,
    required this.metadata,
    required this.isActive,
    required this.createdAt,
    required this.lastModified,
    required this.appliedCount,
  });

  @override
  List<Object?> get props => [
        policyId,
        name,
        level,
        rules,
        metadata,
        isActive,
        createdAt,
        lastModified,
        appliedCount,
      ];
}

/// Правило безопасности
class SecurityRule extends Equatable {
  final String ruleId;
  final String name;
  final RuleType type;
  final Map<String, dynamic> conditions;
  final List<RuleAction> actions;

  const SecurityRule({
    required this.ruleId,
    required this.name,
    required this.type,
    required this.conditions,
    required this.actions,
  });

  @override
  List<Object?> get props => [ruleId, name, type, conditions, actions];
}

class ThreatDetection extends Equatable {
  final String detectionId;
  final String sourceId;
  final ThreatType threatType;
  final ThreatSeverity severity;
  final Map<String, dynamic> threatData;
  final DateTime detectedAt;
  ThreatStatus status;
  final double confidence;
  final List<String> mitigationActions;

  ThreatDetection({
    required this.detectionId,
    required this.sourceId,
    required this.threatType,
    required this.severity,
    required this.threatData,
    required this.detectedAt,
    required this.status,
    required this.confidence,
    required this.mitigationActions,
  });

  @override
  List<Object?> get props => [
        detectionId,
        sourceId,
        threatType,
        severity,
        threatData,
        detectedAt,
        status,
        confidence,
        mitigationActions,
      ];
}

/// Событие безопасности
class SecurityEvent extends Equatable {
  final String eventId;
  final SecurityEventType eventType;
  final String sourceId;
  final Map<String, dynamic> details;
  final ThreatSeverity severity;
  final DateTime timestamp;
  bool processed;

  SecurityEvent({
    required this.eventId,
    required this.eventType,
    required this.sourceId,
    required this.details,
    required this.severity,
    required this.timestamp,
    required this.processed,
  });

  @override
  List<Object?> get props => [eventId, eventType, sourceId, details, severity, timestamp, processed];
}

/// Контроль доступа
class AccessControl extends Equatable {
  final String userId;
  final List<String> permissions;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  DateTime lastModified;
  bool isActive;

  AccessControl({
    required this.userId,
    required this.permissions,
    required this.metadata,
    required this.createdAt,
    required this.lastModified,
    required this.isActive,
  });

  @override
  List<Object?> get props => [userId, permissions, metadata, createdAt, lastModified, isActive];
}

/// Токен безопасности
class SecurityToken extends Equatable {
  final String tokenId;
  final String userId;
  final String token;
  final List<String> permissions;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime expiresAt;
  bool isActive;
  int usageCount;

  SecurityToken({
    required this.tokenId,
    required this.userId,
    required this.token,
    required this.permissions,
    required this.metadata,
    required this.createdAt,
    required this.expiresAt,
    required this.isActive,
    required this.usageCount,
  });

  @override
  List<Object?> get props => [
        tokenId,
        userId,
        token,
        permissions,
        metadata,
        createdAt,
        expiresAt,
        isActive,
        usageCount,
      ];
}

/// Ключ шифрования
class EncryptionKey extends Equatable {
  final String keyId;
  final EncryptionAlgorithm algorithm;
  final String keyData;
  final DateTime createdAt;
  final DateTime expiresAt;
  bool isActive;

  EncryptionKey({
    required this.keyId,
    required this.algorithm,
    required this.keyData,
    required this.createdAt,
    required this.expiresAt,
    required this.isActive,
  });

  @override
  List<Object?> get props => [keyId, algorithm, keyData, createdAt, expiresAt, isActive];
}

/// Цифровой сертификат
class DigitalCertificate extends Equatable {
  final String certificateId;
  final String keyId;
  final String subject;
  final String issuer;
  final DateTime validFrom;
  final DateTime validTo;
  final String serialNumber;
  final String publicKey;

  const DigitalCertificate({
    required this.certificateId,
    required this.keyId,
    required this.subject,
    required this.issuer,
    required this.validFrom,
    required this.validTo,
    required this.serialNumber,
    required this.publicKey,
  });

  @override
  List<Object?> get props => [
        certificateId,
        keyId,
        subject,
        issuer,
        validFrom,
        validTo,
        serialNumber,
        publicKey,
      ];
}

/// Уязвимость безопасности
class SecurityVulnerability extends Equatable {
  final String vulnerabilityId;
  final String targetId;
  final VulnerabilityType type;
  final ThreatSeverity severity;
  final String description;
  final DateTime detectedAt;

  const SecurityVulnerability({
    required this.vulnerabilityId,
    required this.targetId,
    required this.type,
    required this.severity,
    required this.description,
    required this.detectedAt,
  });

  @override
  List<Object?> get props => [vulnerabilityId, targetId, type, severity, description, detectedAt];
}

/// Уровни безопасности
enum SecurityLevel { low, medium, high, critical }

/// Типы правил
enum RuleType { authentication, authorization, encryption, monitoring }

/// Действия правил
enum RuleAction { allow, block, require, warn, log }

/// Типы угроз
enum ThreatType { malware, phishing, bruteForce, dataBreach, ddos, insider }

/// Серьезность угроз
enum ThreatSeverity { low, medium, high, critical }

/// Статусы угроз
enum ThreatStatus { detected, analyzing, mitigated, resolved }

/// Типы событий безопасности
enum SecurityEventType {
  accessGranted,
  accessDenied,
  threatDetected,
  policyViolation,
  authenticationSuccess,
  authenticationFailure,
}

/// Типы доступа
enum AccessType { read, write, execute, admin, delete }

/// Алгоритмы шифрования
enum EncryptionAlgorithm { aes256, aes128, rsa4096, rsa2048, chacha20 }

/// Алгоритмы подписи
enum SignatureAlgorithm { rsaSha256, rsaSha512, ecdsaSha256, ed25519 }

/// Типы уязвимостей
enum VulnerabilityType { injection, xss, csrf, bufferOverflow, privilegeEscalation }

/// Типы анализа безопасности
enum SecurityAnalysisType { quick, standard, comprehensive, deep }

/// Результат политики безопасности
class SecurityPolicyResult extends Equatable {
  final String policyId;
  final bool success;
  final String? errorMessage;

  const SecurityPolicyResult({
    required this.policyId,
    required this.success,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [policyId, success, errorMessage];
}

/// Результат обнаружения угроз
class ThreatDetectionResult extends Equatable {
  final String detectionId;
  final bool success;
  final double confidence;
  final bool mitigationApplied;
  final String? errorMessage;

  const ThreatDetectionResult({
    required this.detectionId,
    required this.success,
    required this.confidence,
    required this.mitigationApplied,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [detectionId, success, confidence, mitigationApplied, errorMessage];
}

/// Результат контроля доступа
class AccessControlResult extends Equatable {
  final String userId;
  final String resourceId;
  final AccessType accessType;
  final bool granted;
  final String reason;

  const AccessControlResult({
    required this.userId,
    required this.resourceId,
    required this.accessType,
    required this.granted,
    required this.reason,
  });

  @override
  List<Object?> get props => [userId, resourceId, accessType, granted, reason];
}

/// Результат токена безопасности
class SecurityTokenResult extends Equatable {
  final String tokenId;
  final String token;
  final bool success;
  final DateTime expiresAt;
  final String? errorMessage;

  const SecurityTokenResult({
    required this.tokenId,
    required this.token,
    required this.success,
    required this.expiresAt,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [tokenId, token, success, expiresAt, errorMessage];
}

/// Результат валидации токена
class TokenValidationResult extends Equatable {
  final bool valid;
  final String? userId;
  final List<String>? permissions;
  final DateTime? expiresAt;
  final String? reason;

  const TokenValidationResult({
    required this.valid,
    this.userId,
    this.permissions,
    this.expiresAt,
    this.reason,
  });

  @override
  List<Object?> get props => [valid, userId, permissions, expiresAt, reason];
}

/// Результат шифрования
class EncryptionResult extends Equatable {
  final bool success;
  final String? encryptedData;
  final String? keyId;
  final EncryptionAlgorithm? algorithm;
  final String? iv;
  final String? errorMessage;

  const EncryptionResult({
    required this.success,
    this.encryptedData,
    this.keyId,
    this.algorithm,
    this.iv,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [success, encryptedData, keyId, algorithm, iv, errorMessage];
}

/// Результат расшифровки
class DecryptionResult extends Equatable {
  final bool success;
  final String? decryptedData;
  final String? errorMessage;

  const DecryptionResult({
    required this.success,
    this.decryptedData,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [success, decryptedData, errorMessage];
}

/// Результат цифровой подписи
class DigitalSignatureResult extends Equatable {
  final bool success;
  final String? signature;
  final SignatureAlgorithm? algorithm;
  final DigitalCertificate? certificate;
  final DateTime? signedAt;
  final String? errorMessage;

  const DigitalSignatureResult({
    required this.success,
    this.signature,
    this.algorithm,
    this.certificate,
    this.signedAt,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [success, signature, algorithm, certificate, signedAt, errorMessage];
}

/// Результат верификации подписи
class SignatureVerificationResult extends Equatable {
  final bool valid;
  final DigitalCertificate? certificate;
  final DateTime? verifiedAt;
  final String? reason;

  const SignatureVerificationResult({
    required this.valid,
    this.certificate,
    this.verifiedAt,
    this.reason,
  });

  @override
  List<Object?> get props => [valid, certificate, verifiedAt, reason];
}

/// Результат анализа безопасности
class SecurityAnalysisResult extends Equatable {
  final String targetId;
  final SecurityAnalysisType analysisType;
  final double riskScore;
  final List<SecurityVulnerability> vulnerabilities;
  final List<ThreatDetection> threats;
  final List<SecurityEvent> securityEvents;
  final List<String> recommendations;
  final DateTime analyzedAt;
  final String? errorMessage;

  const SecurityAnalysisResult({
    required this.targetId,
    required this.analysisType,
    required this.riskScore,
    required this.vulnerabilities,
    required this.threats,
    required this.securityEvents,
    required this.recommendations,
    required this.analyzedAt,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        targetId,
        analysisType,
        riskScore,
        vulnerabilities,
        threats,
        securityEvents,
        recommendations,
        analyzedAt,
        errorMessage,
      ];
}
