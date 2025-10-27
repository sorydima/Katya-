// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trust_identity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrustIdentity _$TrustIdentityFromJson(Map<String, dynamic> json) =>
    TrustIdentity(
      identityId: json['identityId'] as String,
      protocolId: json['protocolId'] as String,
      name: json['name'] as String,
      reputationScore: (json['reputationScore'] as num).toDouble(),
      isVerified: json['isVerified'] as bool,
      lastSeen: DateTime.parse(json['lastSeen'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      trustScore: (json['trustScore'] as num).toDouble(),
      lastVerified: DateTime.parse(json['lastVerified'] as String),
      verificationCount: (json['verificationCount'] as num?)?.toInt() ?? 0,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      status:
          $enumDecodeNullable(_$VerificationStatusEnumMap, json['status']) ??
              VerificationStatus.pending,
      supportedVerificationMethods:
          (json['supportedVerificationMethods'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              const [],
      certificates: (json['certificates'] as List<dynamic>?)
              ?.map((e) => CertificateInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TrustIdentityToJson(TrustIdentity instance) =>
    <String, dynamic>{
      'identityId': instance.identityId,
      'protocolId': instance.protocolId,
      'name': instance.name,
      'reputationScore': instance.reputationScore,
      'isVerified': instance.isVerified,
      'lastSeen': instance.lastSeen.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'trustScore': instance.trustScore,
      'lastVerified': instance.lastVerified.toIso8601String(),
      'verificationCount': instance.verificationCount,
      'metadata': instance.metadata,
      'status': _$VerificationStatusEnumMap[instance.status]!,
      'supportedVerificationMethods': instance.supportedVerificationMethods,
      'certificates': instance.certificates,
    };

const _$VerificationStatusEnumMap = {
  VerificationStatus.pending: 'pending',
  VerificationStatus.verified: 'verified',
  VerificationStatus.failed: 'failed',
  VerificationStatus.expired: 'expired',
  VerificationStatus.revoked: 'revoked',
};

CertificateInfo _$CertificateInfoFromJson(Map<String, dynamic> json) =>
    CertificateInfo(
      type: json['type'] as String,
      serialNumber: json['serialNumber'] as String,
      issuer: json['issuer'] as String,
      subject: json['subject'] as String,
      issuedAt: DateTime.parse(json['issuedAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      fingerprint: json['fingerprint'] as String,
      status: $enumDecodeNullable(_$CertificateStatusEnumMap, json['status']) ??
          CertificateStatus.valid,
    );

Map<String, dynamic> _$CertificateInfoToJson(CertificateInfo instance) =>
    <String, dynamic>{
      'type': instance.type,
      'serialNumber': instance.serialNumber,
      'issuer': instance.issuer,
      'subject': instance.subject,
      'issuedAt': instance.issuedAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'fingerprint': instance.fingerprint,
      'status': _$CertificateStatusEnumMap[instance.status]!,
    };

const _$CertificateStatusEnumMap = {
  CertificateStatus.valid: 'valid',
  CertificateStatus.expired: 'expired',
  CertificateStatus.revoked: 'revoked',
  CertificateStatus.invalid: 'invalid',
};
