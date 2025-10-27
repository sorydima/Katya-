// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trust_verification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrustVerification _$TrustVerificationFromJson(Map<String, dynamic> json) =>
    TrustVerification(
      verificationId: json['verificationId'] as String,
      identityId: json['identityId'] as String,
      protocolId: json['protocolId'] as String,
      fromIdentityId: json['fromIdentityId'] as String,
      toIdentityId: json['toIdentityId'] as String,
      trustScore: (json['trustScore'] as num).toDouble(),
      verificationType: json['verificationType'] as String,
      isVerified: json['isVerified'] as bool,
      verifiedAt: DateTime.parse(json['verifiedAt'] as String),
      verificationData:
          json['verificationData'] as Map<String, dynamic>? ?? const {},
      message: json['message'] as String?,
      trustLevel: (json['trustLevel'] as num?)?.toDouble() ?? 0.0,
      signature: json['signature'] as String?,
      dataHash: json['dataHash'] as String?,
      status: $enumDecodeNullable(
              _$VerificationResultStatusEnumMap, json['status']) ??
          VerificationResultStatus.completed,
    );

Map<String, dynamic> _$TrustVerificationToJson(TrustVerification instance) =>
    <String, dynamic>{
      'verificationId': instance.verificationId,
      'identityId': instance.identityId,
      'protocolId': instance.protocolId,
      'fromIdentityId': instance.fromIdentityId,
      'toIdentityId': instance.toIdentityId,
      'trustScore': instance.trustScore,
      'verificationType': instance.verificationType,
      'isVerified': instance.isVerified,
      'verifiedAt': instance.verifiedAt.toIso8601String(),
      'verificationData': instance.verificationData,
      'message': instance.message,
      'trustLevel': instance.trustLevel,
      'signature': instance.signature,
      'dataHash': instance.dataHash,
      'status': _$VerificationResultStatusEnumMap[instance.status]!,
    };

const _$VerificationResultStatusEnumMap = {
  VerificationResultStatus.pending: 'pending',
  VerificationResultStatus.inProgress: 'in_progress',
  VerificationResultStatus.completed: 'completed',
  VerificationResultStatus.failed: 'failed',
  VerificationResultStatus.timeout: 'timeout',
  VerificationResultStatus.cancelled: 'cancelled',
};

VerificationConfig _$VerificationConfigFromJson(Map<String, dynamic> json) =>
    VerificationConfig(
      type: $enumDecode(_$VerificationTypeEnumMap, json['type']),
      timeoutSeconds: (json['timeoutSeconds'] as num?)?.toInt() ?? 300,
      maxAttempts: (json['maxAttempts'] as num?)?.toInt() ?? 3,
      parameters: json['parameters'] as Map<String, dynamic>? ?? const {},
      requireSignature: json['requireSignature'] as bool? ?? false,
      requireDataHash: json['requireDataHash'] as bool? ?? true,
    );

Map<String, dynamic> _$VerificationConfigToJson(VerificationConfig instance) =>
    <String, dynamic>{
      'type': _$VerificationTypeEnumMap[instance.type]!,
      'timeoutSeconds': instance.timeoutSeconds,
      'maxAttempts': instance.maxAttempts,
      'parameters': instance.parameters,
      'requireSignature': instance.requireSignature,
      'requireDataHash': instance.requireDataHash,
    };

const _$VerificationTypeEnumMap = {
  VerificationType.email: 'email',
  VerificationType.phone: 'phone',
  VerificationType.certificate: 'certificate',
  VerificationType.pgp: 'pgp',
  VerificationType.dkim: 'dkim',
  VerificationType.spf: 'spf',
  VerificationType.dmarc: 'dmarc',
  VerificationType.signature: 'signature',
  VerificationType.timestamp: 'timestamp',
  VerificationType.username: 'username',
  VerificationType.oauth: 'oauth',
  VerificationType.sso: 'sso',
  VerificationType.biometric: 'biometric',
  VerificationType.hardwareToken: 'hardware_token',
  VerificationType.sms: 'sms',
  VerificationType.voice: 'voice',
};

VerificationRequest _$VerificationRequestFromJson(Map<String, dynamic> json) =>
    VerificationRequest(
      requestId: json['requestId'] as String,
      identityId: json['identityId'] as String,
      protocolId: json['protocolId'] as String,
      config:
          VerificationConfig.fromJson(json['config'] as Map<String, dynamic>),
      data: json['data'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: $enumDecodeNullable(
              _$VerificationRequestStatusEnumMap, json['status']) ??
          VerificationRequestStatus.pending,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$VerificationRequestToJson(
        VerificationRequest instance) =>
    <String, dynamic>{
      'requestId': instance.requestId,
      'identityId': instance.identityId,
      'protocolId': instance.protocolId,
      'config': instance.config,
      'data': instance.data,
      'createdAt': instance.createdAt.toIso8601String(),
      'status': _$VerificationRequestStatusEnumMap[instance.status]!,
      'metadata': instance.metadata,
    };

const _$VerificationRequestStatusEnumMap = {
  VerificationRequestStatus.pending: 'pending',
  VerificationRequestStatus.processing: 'processing',
  VerificationRequestStatus.completed: 'completed',
  VerificationRequestStatus.failed: 'failed',
  VerificationRequestStatus.expired: 'expired',
  VerificationRequestStatus.cancelled: 'cancelled',
};
