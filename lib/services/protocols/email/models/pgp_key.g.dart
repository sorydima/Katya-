// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pgp_key.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PGPKey _$PGPKeyFromJson(Map<String, dynamic> json) => PGPKey(
      keyId: json['keyId'] as String,
      email: json['email'] as String,
      keyData: json['keyData'] as String,
      keyType: json['keyType'] as String,
      keySize: (json['keySize'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      status: $enumDecodeNullable(_$PGPKeyStatusEnumMap, json['status']) ??
          PGPKeyStatus.active,
      fingerprint: json['fingerprint'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$PGPKeyToJson(PGPKey instance) => <String, dynamic>{
      'keyId': instance.keyId,
      'email': instance.email,
      'keyData': instance.keyData,
      'keyType': instance.keyType,
      'keySize': instance.keySize,
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'status': _$PGPKeyStatusEnumMap[instance.status]!,
      'fingerprint': instance.fingerprint,
      'metadata': instance.metadata,
    };

const _$PGPKeyStatusEnumMap = {
  PGPKeyStatus.active: 'active',
  PGPKeyStatus.revoked: 'revoked',
  PGPKeyStatus.expired: 'expired',
  PGPKeyStatus.disabled: 'disabled',
  PGPKeyStatus.unknown: 'unknown',
};

PGPKeyPair _$PGPKeyPairFromJson(Map<String, dynamic> json) => PGPKeyPair(
      publicKey: PGPKey.fromJson(json['publicKey'] as Map<String, dynamic>),
      privateKey: PGPKey.fromJson(json['privateKey'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$PGPKeyPairToJson(PGPKeyPair instance) =>
    <String, dynamic>{
      'publicKey': instance.publicKey,
      'privateKey': instance.privateKey,
      'createdAt': instance.createdAt.toIso8601String(),
    };

PGPSignature _$PGPSignatureFromJson(Map<String, dynamic> json) => PGPSignature(
      signatureId: json['signatureId'] as String,
      keyId: json['keyId'] as String,
      signerEmail: json['signerEmail'] as String,
      signedAt: DateTime.parse(json['signedAt'] as String),
      signatureData: json['signatureData'] as String,
      status:
          $enumDecodeNullable(_$PGPSignatureStatusEnumMap, json['status']) ??
              PGPSignatureStatus.valid,
      signerFingerprint: json['signerFingerprint'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$PGPSignatureToJson(PGPSignature instance) =>
    <String, dynamic>{
      'signatureId': instance.signatureId,
      'keyId': instance.keyId,
      'signerEmail': instance.signerEmail,
      'signedAt': instance.signedAt.toIso8601String(),
      'signatureData': instance.signatureData,
      'status': _$PGPSignatureStatusEnumMap[instance.status]!,
      'signerFingerprint': instance.signerFingerprint,
      'metadata': instance.metadata,
    };

const _$PGPSignatureStatusEnumMap = {
  PGPSignatureStatus.valid: 'valid',
  PGPSignatureStatus.invalid: 'invalid',
  PGPSignatureStatus.expired: 'expired',
  PGPSignatureStatus.revoked: 'revoked',
  PGPSignatureStatus.unknown: 'unknown',
};

PGPCertificate _$PGPCertificateFromJson(Map<String, dynamic> json) =>
    PGPCertificate(
      certificateId: json['certificateId'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      comment: json['comment'] as String?,
      publicKey: PGPKey.fromJson(json['publicKey'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      status:
          $enumDecodeNullable(_$PGPCertificateStatusEnumMap, json['status']) ??
              PGPCertificateStatus.valid,
      trust: $enumDecodeNullable(_$PGPCertificateTrustEnumMap, json['trust']) ??
          PGPCertificateTrust.none,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$PGPCertificateToJson(PGPCertificate instance) =>
    <String, dynamic>{
      'certificateId': instance.certificateId,
      'email': instance.email,
      'name': instance.name,
      'comment': instance.comment,
      'publicKey': instance.publicKey,
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'status': _$PGPCertificateStatusEnumMap[instance.status]!,
      'trust': _$PGPCertificateTrustEnumMap[instance.trust]!,
      'metadata': instance.metadata,
    };

const _$PGPCertificateStatusEnumMap = {
  PGPCertificateStatus.valid: 'valid',
  PGPCertificateStatus.expired: 'expired',
  PGPCertificateStatus.revoked: 'revoked',
  PGPCertificateStatus.unknown: 'unknown',
};

const _$PGPCertificateTrustEnumMap = {
  PGPCertificateTrust.none: 'none',
  PGPCertificateTrust.marginal: 'marginal',
  PGPCertificateTrust.full: 'full',
  PGPCertificateTrust.ultimate: 'ultimate',
};
