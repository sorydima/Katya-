import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pgp_key.g.dart';

/// Модель PGP ключа
@JsonSerializable()
class PGPKey extends Equatable {
  /// Идентификатор ключа
  final String keyId;

  /// E-Mail адрес
  final String email;

  /// Данные ключа
  final String keyData;

  /// Тип ключа (RSA, DSA, ECDSA, etc.)
  final String keyType;

  /// Размер ключа в битах
  final int keySize;

  /// Время создания ключа
  final DateTime createdAt;

  /// Время истечения ключа
  final DateTime? expiresAt;

  /// Статус ключа
  final PGPKeyStatus status;

  /// Отпечаток ключа
  final String? fingerprint;

  /// Дополнительные метаданные
  final Map<String, dynamic> metadata;

  const PGPKey({
    required this.keyId,
    required this.email,
    required this.keyData,
    required this.keyType,
    required this.keySize,
    required this.createdAt,
    this.expiresAt,
    this.status = PGPKeyStatus.active,
    this.fingerprint,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
        keyId,
        email,
        keyData,
        keyType,
        keySize,
        createdAt,
        expiresAt,
        status,
        fingerprint,
        metadata,
      ];

  PGPKey copyWith({
    String? keyId,
    String? email,
    String? keyData,
    String? keyType,
    int? keySize,
    DateTime? createdAt,
    DateTime? expiresAt,
    PGPKeyStatus? status,
    String? fingerprint,
    Map<String, dynamic>? metadata,
  }) {
    return PGPKey(
      keyId: keyId ?? this.keyId,
      email: email ?? this.email,
      keyData: keyData ?? this.keyData,
      keyType: keyType ?? this.keyType,
      keySize: keySize ?? this.keySize,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      fingerprint: fingerprint ?? this.fingerprint,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Создание из строки
  static PGPKey fromString(String keyString) {
    // Упрощенная реализация парсинга PGP ключа
    return PGPKey(
      keyId: 'parsed_key_id',
      email: 'parsed@example.com',
      keyData: keyString,
      keyType: 'RSA',
      keySize: 2048,
      createdAt: DateTime.now(),
    );
  }

  /// Проверка, действителен ли ключ
  bool get isValid {
    if (status != PGPKeyStatus.active) return false;

    final now = DateTime.now();
    if (expiresAt != null && now.isAfter(expiresAt!)) return false;

    return true;
  }

  /// Проверка, истекает ли ключ в ближайшее время
  bool isExpiringSoon({int daysThreshold = 30}) {
    if (expiresAt == null) return false;

    final now = DateTime.now();
    final expirationThreshold = now.add(Duration(days: daysThreshold));
    return expiresAt!.isBefore(expirationThreshold);
  }

  /// Получение краткого отпечатка
  String get shortFingerprint {
    if (fingerprint == null) return keyId;
    return fingerprint!.length > 8 ? fingerprint!.substring(fingerprint!.length - 8) : fingerprint!;
  }

  /// Получение длинного отпечатка
  String get longFingerprint => fingerprint ?? keyId;

  /// Получение типа ключа в читаемом формате
  String get readableKeyType {
    switch (keyType.toUpperCase()) {
      case 'RSA':
        return 'RSA ($keySize bits)';
      case 'DSA':
        return 'DSA ($keySize bits)';
      case 'ECDSA':
        return 'ECDSA ($keySize bits)';
      case 'ED25519':
        return 'Ed25519';
      default:
        return '$keyType ($keySize bits)';
    }
  }

  Map<String, dynamic> toJson() => _$PGPKeyToJson(this);
  factory PGPKey.fromJson(Map<String, dynamic> json) => _$PGPKeyFromJson(json);
}

/// Статус PGP ключа
enum PGPKeyStatus {
  @JsonValue('active')
  active,
  @JsonValue('revoked')
  revoked,
  @JsonValue('expired')
  expired,
  @JsonValue('disabled')
  disabled,
  @JsonValue('unknown')
  unknown,
}

/// PGP ключевая пара
@JsonSerializable()
class PGPKeyPair extends Equatable {
  /// Публичный ключ
  final PGPKey publicKey;

  /// Приватный ключ
  final PGPKey privateKey;

  /// Парольная фраза
  @JsonKey(ignore: true)
  final String? passphrase;

  /// Время создания пары
  final DateTime createdAt;

  const PGPKeyPair({
    required this.publicKey,
    required this.privateKey,
    this.passphrase,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        publicKey,
        privateKey,
        passphrase,
        createdAt,
      ];

  PGPKeyPair copyWith({
    PGPKey? publicKey,
    PGPKey? privateKey,
    String? passphrase,
    DateTime? createdAt,
  }) {
    return PGPKeyPair(
      publicKey: publicKey ?? this.publicKey,
      privateKey: privateKey ?? this.privateKey,
      passphrase: passphrase ?? this.passphrase,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Проверка, действительна ли ключевая пара
  bool get isValid => publicKey.isValid && privateKey.isValid;

  /// Проверка, истекает ли ключевая пара в ближайшее время
  bool isExpiringSoon({int daysThreshold = 30}) {
    return publicKey.isExpiringSoon(daysThreshold: daysThreshold) ||
        privateKey.isExpiringSoon(daysThreshold: daysThreshold);
  }

  Map<String, dynamic> toJson() => _$PGPKeyPairToJson(this);
  factory PGPKeyPair.fromJson(Map<String, dynamic> json) => _$PGPKeyPairFromJson(json);
}

/// PGP подпись
@JsonSerializable()
class PGPSignature extends Equatable {
  /// Идентификатор подписи
  final String signatureId;

  /// Идентификатор ключа, которым подписано
  final String keyId;

  /// E-Mail адрес подписанта
  final String signerEmail;

  /// Время создания подписи
  final DateTime signedAt;

  /// Данные подписи
  final String signatureData;

  /// Статус подписи
  final PGPSignatureStatus status;

  /// Отпечаток ключа подписанта
  final String? signerFingerprint;

  /// Дополнительные метаданные
  final Map<String, dynamic> metadata;

  const PGPSignature({
    required this.signatureId,
    required this.keyId,
    required this.signerEmail,
    required this.signedAt,
    required this.signatureData,
    this.status = PGPSignatureStatus.valid,
    this.signerFingerprint,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
        signatureId,
        keyId,
        signerEmail,
        signedAt,
        signatureData,
        status,
        signerFingerprint,
        metadata,
      ];

  PGPSignature copyWith({
    String? signatureId,
    String? keyId,
    String? signerEmail,
    DateTime? signedAt,
    String? signatureData,
    PGPSignatureStatus? status,
    String? signerFingerprint,
    Map<String, dynamic>? metadata,
  }) {
    return PGPSignature(
      signatureId: signatureId ?? this.signatureId,
      keyId: keyId ?? this.keyId,
      signerEmail: signerEmail ?? this.signerEmail,
      signedAt: signedAt ?? this.signedAt,
      signatureData: signatureData ?? this.signatureData,
      status: status ?? this.status,
      signerFingerprint: signerFingerprint ?? this.signerFingerprint,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Проверка, действительна ли подпись
  bool get isValid => status == PGPSignatureStatus.valid;

  Map<String, dynamic> toJson() => _$PGPSignatureToJson(this);
  factory PGPSignature.fromJson(Map<String, dynamic> json) => _$PGPSignatureFromJson(json);
}

/// Статус PGP подписи
enum PGPSignatureStatus {
  @JsonValue('valid')
  valid,
  @JsonValue('invalid')
  invalid,
  @JsonValue('expired')
  expired,
  @JsonValue('revoked')
  revoked,
  @JsonValue('unknown')
  unknown,
}

/// PGP сертификат
@JsonSerializable()
class PGPCertificate extends Equatable {
  /// Идентификатор сертификата
  final String certificateId;

  /// E-Mail адрес владельца
  final String email;

  /// Имя владельца
  final String? name;

  /// Комментарий
  final String? comment;

  /// Публичный ключ
  final PGPKey publicKey;

  /// Время создания сертификата
  final DateTime createdAt;

  /// Время истечения сертификата
  final DateTime? expiresAt;

  /// Статус сертификата
  final PGPCertificateStatus status;

  /// Доверие к сертификату
  final PGPCertificateTrust trust;

  /// Дополнительные метаданные
  final Map<String, dynamic> metadata;

  const PGPCertificate({
    required this.certificateId,
    required this.email,
    this.name,
    this.comment,
    required this.publicKey,
    required this.createdAt,
    this.expiresAt,
    this.status = PGPCertificateStatus.valid,
    this.trust = PGPCertificateTrust.none,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
        certificateId,
        email,
        name,
        comment,
        publicKey,
        createdAt,
        expiresAt,
        status,
        trust,
        metadata,
      ];

  PGPCertificate copyWith({
    String? certificateId,
    String? email,
    String? name,
    String? comment,
    PGPKey? publicKey,
    DateTime? createdAt,
    DateTime? expiresAt,
    PGPCertificateStatus? status,
    PGPCertificateTrust? trust,
    Map<String, dynamic>? metadata,
  }) {
    return PGPCertificate(
      certificateId: certificateId ?? this.certificateId,
      email: email ?? this.email,
      name: name ?? this.name,
      comment: comment ?? this.comment,
      publicKey: publicKey ?? this.publicKey,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      trust: trust ?? this.trust,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Проверка, действителен ли сертификат
  bool get isValid => status == PGPCertificateStatus.valid && publicKey.isValid;

  /// Проверка, истекает ли сертификат в ближайшее время
  bool isExpiringSoon({int daysThreshold = 30}) {
    if (expiresAt == null) return false;

    final now = DateTime.now();
    final expirationThreshold = now.add(Duration(days: daysThreshold));
    return expiresAt!.isBefore(expirationThreshold);
  }

  /// Получение отображаемого имени
  String get displayName {
    if (name != null && name!.isNotEmpty) {
      return '$name <$email>';
    }
    return email;
  }

  Map<String, dynamic> toJson() => _$PGPCertificateToJson(this);
  factory PGPCertificate.fromJson(Map<String, dynamic> json) => _$PGPCertificateFromJson(json);
}

/// Статус PGP сертификата
enum PGPCertificateStatus {
  @JsonValue('valid')
  valid,
  @JsonValue('expired')
  expired,
  @JsonValue('revoked')
  revoked,
  @JsonValue('unknown')
  unknown,
}

/// Доверие к PGP сертификату
enum PGPCertificateTrust {
  @JsonValue('none')
  none,
  @JsonValue('marginal')
  marginal,
  @JsonValue('full')
  full,
  @JsonValue('ultimate')
  ultimate,
}
