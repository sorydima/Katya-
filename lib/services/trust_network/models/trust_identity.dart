import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'trust_identity.g.dart';

/// Модель доверенной идентичности в сети
@JsonSerializable()
class TrustIdentity extends Equatable {
  /// Уникальный идентификатор личности
  final String identityId;

  /// Идентификатор протокола, через который была верифицирована личность
  final String protocolId;

  /// Имя идентичности
  final String name;

  /// Репутационный балл
  final double reputationScore;

  /// Верифицирована ли идентичность
  final bool isVerified;

  /// Время последнего контакта
  final DateTime lastSeen;

  /// Время создания
  final DateTime createdAt;

  /// Оценка доверия (0.0 - 1.0)
  final double trustScore;

  /// Время последней верификации
  final DateTime lastVerified;

  /// Количество успешных верификаций
  final int verificationCount;

  /// Дополнительные метаданные
  final Map<String, dynamic> metadata;

  /// Статус верификации
  final VerificationStatus status;

  /// Список поддерживаемых методов верификации
  final List<String> supportedVerificationMethods;

  /// Информация о сертификатах (если применимо)
  final List<CertificateInfo> certificates;

  const TrustIdentity({
    required this.identityId,
    required this.protocolId,
    required this.name,
    required this.reputationScore,
    required this.isVerified,
    required this.lastSeen,
    required this.createdAt,
    required this.trustScore,
    required this.lastVerified,
    this.verificationCount = 0,
    this.metadata = const {},
    this.status = VerificationStatus.pending,
    this.supportedVerificationMethods = const [],
    this.certificates = const [],
  });

  @override
  List<Object?> get props => [
        identityId,
        protocolId,
        name,
        reputationScore,
        isVerified,
        lastSeen,
        createdAt,
        trustScore,
        lastVerified,
        verificationCount,
        metadata,
        status,
        supportedVerificationMethods,
        certificates,
      ];

  TrustIdentity copyWith({
    String? identityId,
    String? protocolId,
    String? name,
    double? reputationScore,
    bool? isVerified,
    DateTime? lastSeen,
    DateTime? createdAt,
    double? trustScore,
    DateTime? lastVerified,
    int? verificationCount,
    Map<String, dynamic>? metadata,
    VerificationStatus? status,
    List<String>? supportedVerificationMethods,
    List<CertificateInfo>? certificates,
  }) {
    return TrustIdentity(
      identityId: identityId ?? this.identityId,
      protocolId: protocolId ?? this.protocolId,
      name: name ?? this.name,
      reputationScore: reputationScore ?? this.reputationScore,
      isVerified: isVerified ?? this.isVerified,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      trustScore: trustScore ?? this.trustScore,
      lastVerified: lastVerified ?? this.lastVerified,
      verificationCount: verificationCount ?? this.verificationCount,
      metadata: metadata ?? this.metadata,
      status: status ?? this.status,
      supportedVerificationMethods: supportedVerificationMethods ?? this.supportedVerificationMethods,
      certificates: certificates ?? this.certificates,
    );
  }

  /// Получение id (алиас для identityId)
  String get id => identityId;

  /// Получение протокола (алиас для protocolId)
  String get protocol => protocolId;

  /// Проверка, является ли идентичность высоконадежной
  bool get isHighTrust => trustScore >= 0.8;

  /// Проверка, является ли идентичность средне-надежной
  bool get isMediumTrust => trustScore >= 0.5 && trustScore < 0.8;

  /// Проверка, является ли идентичность низконадежной
  bool get isLowTrust => trustScore < 0.5;

  /// Проверка, нуждается ли в повторной верификации
  bool needsReVerification({int timeoutHours = 24}) {
    final hoursSinceVerification = DateTime.now().difference(lastVerified).inHours;
    return hoursSinceVerification >= timeoutHours;
  }

  /// Получение уровня доверия в виде строки
  String get trustLevel {
    if (isHighTrust) return 'High';
    if (isMediumTrust) return 'Medium';
    return 'Low';
  }

  Map<String, dynamic> toJson() => _$TrustIdentityToJson(this);
  factory TrustIdentity.fromJson(Map<String, dynamic> json) => _$TrustIdentityFromJson(json);
}

/// Статус верификации
enum VerificationStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('verified')
  verified,
  @JsonValue('failed')
  failed,
  @JsonValue('expired')
  expired,
  @JsonValue('revoked')
  revoked,
}

/// Информация о сертификате
@JsonSerializable()
class CertificateInfo extends Equatable {
  /// Тип сертификата
  final String type;

  /// Серийный номер
  final String serialNumber;

  /// Выдающий орган
  final String issuer;

  /// Субъект сертификата
  final String subject;

  /// Дата выдачи
  final DateTime issuedAt;

  /// Дата истечения
  final DateTime expiresAt;

  /// Отпечаток сертификата
  final String fingerprint;

  /// Статус сертификата
  final CertificateStatus status;

  const CertificateInfo({
    required this.type,
    required this.serialNumber,
    required this.issuer,
    required this.subject,
    required this.issuedAt,
    required this.expiresAt,
    required this.fingerprint,
    this.status = CertificateStatus.valid,
  });

  @override
  List<Object?> get props => [
        type,
        serialNumber,
        issuer,
        subject,
        issuedAt,
        expiresAt,
        fingerprint,
        status,
      ];

  /// Проверка, действителен ли сертификат
  bool get isValid {
    final now = DateTime.now();
    return status == CertificateStatus.valid && now.isAfter(issuedAt) && now.isBefore(expiresAt);
  }

  /// Проверка, истекает ли сертификат в ближайшее время
  bool isExpiringSoon({int daysThreshold = 30}) {
    final now = DateTime.now();
    final expirationThreshold = now.add(Duration(days: daysThreshold));
    return expiresAt.isBefore(expirationThreshold);
  }

  Map<String, dynamic> toJson() => _$CertificateInfoToJson(this);
  factory CertificateInfo.fromJson(Map<String, dynamic> json) => _$CertificateInfoFromJson(json);
}

/// Статус сертификата
enum CertificateStatus {
  @JsonValue('valid')
  valid,
  @JsonValue('expired')
  expired,
  @JsonValue('revoked')
  revoked,
  @JsonValue('invalid')
  invalid,
}
