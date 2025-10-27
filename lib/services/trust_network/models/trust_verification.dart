import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'trust_verification.g.dart';

/// Модель результата верификации доверия
@JsonSerializable()
class TrustVerification extends Equatable {
  /// Уникальный идентификатор верификации
  final String verificationId;

  /// Идентификатор верифицируемой личности
  final String identityId;

  /// Протокол, через который была проведена верификация
  final String protocolId;

  /// Идентификатор источника верификации
  final String fromIdentityId;

  /// Идентификатор цели верификации
  final String toIdentityId;

  /// Балл доверия
  final double trustScore;

  /// Тип верификации
  final String verificationType;

  /// Результат верификации
  final bool isVerified;

  /// Время проведения верификации
  final DateTime verifiedAt;

  /// Дополнительные данные верификации
  final Map<String, dynamic> verificationData;

  /// Сообщение о результате (ошибка или успех)
  final String? message;

  /// Уровень доверия после верификации
  final double trustLevel;

  /// Подпись результата верификации
  final String? signature;

  /// Хэш данных верификации
  final String? dataHash;

  /// Статус верификации
  final VerificationResultStatus status;

  const TrustVerification({
    required this.verificationId,
    required this.identityId,
    required this.protocolId,
    required this.fromIdentityId,
    required this.toIdentityId,
    required this.trustScore,
    required this.verificationType,
    required this.isVerified,
    required this.verifiedAt,
    this.verificationData = const {},
    this.message,
    this.trustLevel = 0.0,
    this.signature,
    this.dataHash,
    this.status = VerificationResultStatus.completed,
  });

  @override
  List<Object?> get props => [
        verificationId,
        identityId,
        protocolId,
        fromIdentityId,
        toIdentityId,
        trustScore,
        verificationType,
        isVerified,
        verifiedAt,
        verificationData,
        message,
        trustLevel,
        signature,
        dataHash,
        status,
      ];

  TrustVerification copyWith({
    String? verificationId,
    String? identityId,
    String? protocolId,
    String? fromIdentityId,
    String? toIdentityId,
    double? trustScore,
    String? verificationType,
    bool? isVerified,
    DateTime? verifiedAt,
    Map<String, dynamic>? verificationData,
    String? message,
    double? trustLevel,
    String? signature,
    String? dataHash,
    VerificationResultStatus? status,
  }) {
    return TrustVerification(
      verificationId: verificationId ?? this.verificationId,
      identityId: identityId ?? this.identityId,
      protocolId: protocolId ?? this.protocolId,
      fromIdentityId: fromIdentityId ?? this.fromIdentityId,
      toIdentityId: toIdentityId ?? this.toIdentityId,
      trustScore: trustScore ?? this.trustScore,
      verificationType: verificationType ?? this.verificationType,
      isVerified: isVerified ?? this.isVerified,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verificationData: verificationData ?? this.verificationData,
      message: message ?? this.message,
      trustLevel: trustLevel ?? this.trustLevel,
      signature: signature ?? this.signature,
      dataHash: dataHash ?? this.dataHash,
      status: status ?? this.status,
    );
  }

  /// Проверка, является ли верификация успешной
  bool get isSuccessful => isVerified && status == VerificationResultStatus.completed;

  /// Проверка, является ли верификация неудачной
  bool get isFailed => !isVerified || status == VerificationResultStatus.failed;

  /// Проверка, истекает ли верификация
  bool isExpired({int timeoutHours = 24}) {
    final hoursSinceVerification = DateTime.now().difference(verifiedAt).inHours;
    return hoursSinceVerification >= timeoutHours;
  }

  /// Получение уровня доверия в виде строки
  String get trustLevelString {
    if (trustLevel >= 0.8) return 'Very High';
    if (trustLevel >= 0.6) return 'High';
    if (trustLevel >= 0.4) return 'Medium';
    if (trustLevel >= 0.2) return 'Low';
    return 'Very Low';
  }

  Map<String, dynamic> toJson() => _$TrustVerificationToJson(this);
  factory TrustVerification.fromJson(Map<String, dynamic> json) => _$TrustVerificationFromJson(json);
}

/// Статус результата верификации
enum VerificationResultStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
  @JsonValue('timeout')
  timeout,
  @JsonValue('cancelled')
  cancelled,
}

/// Типы методов верификации
enum VerificationType {
  @JsonValue('email')
  email,
  @JsonValue('phone')
  phone,
  @JsonValue('certificate')
  certificate,
  @JsonValue('pgp')
  pgp,
  @JsonValue('dkim')
  dkim,
  @JsonValue('spf')
  spf,
  @JsonValue('dmarc')
  dmarc,
  @JsonValue('signature')
  signature,
  @JsonValue('timestamp')
  timestamp,
  @JsonValue('username')
  username,
  @JsonValue('oauth')
  oauth,
  @JsonValue('sso')
  sso,
  @JsonValue('biometric')
  biometric,
  @JsonValue('hardware_token')
  hardwareToken,
  @JsonValue('sms')
  sms,
  @JsonValue('voice')
  voice,
}

/// Конфигурация верификации
@JsonSerializable()
class VerificationConfig extends Equatable {
  /// Тип верификации
  final VerificationType type;

  /// Таймаут в секундах
  final int timeoutSeconds;

  /// Максимальное количество попыток
  final int maxAttempts;

  /// Дополнительные параметры
  final Map<String, dynamic> parameters;

  /// Требуется ли подпись результата
  final bool requireSignature;

  /// Требуется ли хэширование данных
  final bool requireDataHash;

  const VerificationConfig({
    required this.type,
    this.timeoutSeconds = 300, // 5 минут по умолчанию
    this.maxAttempts = 3,
    this.parameters = const {},
    this.requireSignature = false,
    this.requireDataHash = true,
  });

  @override
  List<Object?> get props => [
        type,
        timeoutSeconds,
        maxAttempts,
        parameters,
        requireSignature,
        requireDataHash,
      ];

  Map<String, dynamic> toJson() => _$VerificationConfigToJson(this);
  factory VerificationConfig.fromJson(Map<String, dynamic> json) => _$VerificationConfigFromJson(json);
}

/// Запрос на верификацию
@JsonSerializable()
class VerificationRequest extends Equatable {
  /// Идентификатор запроса
  final String requestId;

  /// Идентификатор личности для верификации
  final String identityId;

  /// Протокол для верификации
  final String protocolId;

  /// Конфигурация верификации
  final VerificationConfig config;

  /// Данные для верификации
  final Map<String, dynamic> data;

  /// Время создания запроса
  final DateTime createdAt;

  /// Статус запроса
  final VerificationRequestStatus status;

  /// Дополнительные метаданные
  final Map<String, dynamic> metadata;

  const VerificationRequest({
    required this.requestId,
    required this.identityId,
    required this.protocolId,
    required this.config,
    required this.data,
    required this.createdAt,
    this.status = VerificationRequestStatus.pending,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
        requestId,
        identityId,
        protocolId,
        config,
        data,
        createdAt,
        status,
        metadata,
      ];

  VerificationRequest copyWith({
    String? requestId,
    String? identityId,
    String? protocolId,
    VerificationConfig? config,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    VerificationRequestStatus? status,
    Map<String, dynamic>? metadata,
  }) {
    return VerificationRequest(
      requestId: requestId ?? this.requestId,
      identityId: identityId ?? this.identityId,
      protocolId: protocolId ?? this.protocolId,
      config: config ?? this.config,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Проверка, истекает ли запрос
  bool isExpired() {
    final now = DateTime.now();
    final expirationTime = createdAt.add(Duration(seconds: config.timeoutSeconds));
    return now.isAfter(expirationTime);
  }

  Map<String, dynamic> toJson() => _$VerificationRequestToJson(this);
  factory VerificationRequest.fromJson(Map<String, dynamic> json) => _$VerificationRequestFromJson(json);
}

/// Статус запроса на верификацию
enum VerificationRequestStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('processing')
  processing,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
  @JsonValue('expired')
  expired,
  @JsonValue('cancelled')
  cancelled,
}
