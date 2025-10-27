// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dkim_verification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DKIMVerificationResult _$DKIMVerificationResultFromJson(
        Map<String, dynamic> json) =>
    DKIMVerificationResult(
      isVerified: json['isVerified'] as bool,
      domain: json['domain'] as String?,
      selector: json['selector'] as String?,
      algorithm: json['algorithm'] as String?,
      keyFingerprint: json['keyFingerprint'] as String?,
      verifiedAt: json['verifiedAt'] == null
          ? null
          : DateTime.parse(json['verifiedAt'] as String),
      error: json['error'] as String?,
      details: json['details'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$DKIMVerificationResultToJson(
        DKIMVerificationResult instance) =>
    <String, dynamic>{
      'isVerified': instance.isVerified,
      'domain': instance.domain,
      'selector': instance.selector,
      'algorithm': instance.algorithm,
      'keyFingerprint': instance.keyFingerprint,
      'verifiedAt': instance.verifiedAt?.toIso8601String(),
      'error': instance.error,
      'details': instance.details,
    };

SPFVerificationResult _$SPFVerificationResultFromJson(
        Map<String, dynamic> json) =>
    SPFVerificationResult(
      result: $enumDecode(_$SPFResultEnumMap, json['result']),
      domain: json['domain'] as String?,
      ipAddress: json['ipAddress'] as String?,
      spfRecord: json['spfRecord'] as String?,
      verifiedAt: json['verifiedAt'] == null
          ? null
          : DateTime.parse(json['verifiedAt'] as String),
      error: json['error'] as String?,
      details: json['details'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$SPFVerificationResultToJson(
        SPFVerificationResult instance) =>
    <String, dynamic>{
      'result': _$SPFResultEnumMap[instance.result]!,
      'domain': instance.domain,
      'ipAddress': instance.ipAddress,
      'spfRecord': instance.spfRecord,
      'verifiedAt': instance.verifiedAt?.toIso8601String(),
      'error': instance.error,
      'details': instance.details,
    };

const _$SPFResultEnumMap = {
  SPFResult.pass: 'pass',
  SPFResult.fail: 'fail',
  SPFResult.softfail: 'softfail',
  SPFResult.neutral: 'neutral',
  SPFResult.temperror: 'temperror',
  SPFResult.permerror: 'permerror',
  SPFResult.none: 'none',
  SPFResult.error: 'error',
};

DMARCVerificationResult _$DMARCVerificationResultFromJson(
        Map<String, dynamic> json) =>
    DMARCVerificationResult(
      result: $enumDecode(_$DMARCResultEnumMap, json['result']),
      domain: json['domain'] as String?,
      dkimResult: json['dkimResult'] == null
          ? null
          : DKIMVerificationResult.fromJson(
              json['dkimResult'] as Map<String, dynamic>),
      spfResult: json['spfResult'] == null
          ? null
          : SPFVerificationResult.fromJson(
              json['spfResult'] as Map<String, dynamic>),
      policy: json['policy'] == null
          ? null
          : DMARCPolicy.fromJson(json['policy'] as Map<String, dynamic>),
      verifiedAt: json['verifiedAt'] == null
          ? null
          : DateTime.parse(json['verifiedAt'] as String),
      error: json['error'] as String?,
      details: json['details'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$DMARCVerificationResultToJson(
        DMARCVerificationResult instance) =>
    <String, dynamic>{
      'result': _$DMARCResultEnumMap[instance.result]!,
      'domain': instance.domain,
      'dkimResult': instance.dkimResult,
      'spfResult': instance.spfResult,
      'policy': instance.policy,
      'verifiedAt': instance.verifiedAt?.toIso8601String(),
      'error': instance.error,
      'details': instance.details,
    };

const _$DMARCResultEnumMap = {
  DMARCResult.pass: 'pass',
  DMARCResult.fail: 'fail',
  DMARCResult.quarantine: 'quarantine',
  DMARCResult.reject: 'reject',
  DMARCResult.none: 'none',
  DMARCResult.error: 'error',
};

DKIMSignature _$DKIMSignatureFromJson(Map<String, dynamic> json) =>
    DKIMSignature(
      version: json['version'] as String,
      algorithm: json['algorithm'] as String,
      domain: json['domain'] as String,
      selector: json['selector'] as String,
      signature: json['signature'] as String,
      signedHeaders: (json['signedHeaders'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      bodyHash: json['bodyHash'] as String?,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      expires: json['expires'] == null
          ? null
          : DateTime.parse(json['expires'] as String),
    );

Map<String, dynamic> _$DKIMSignatureToJson(DKIMSignature instance) =>
    <String, dynamic>{
      'version': instance.version,
      'algorithm': instance.algorithm,
      'domain': instance.domain,
      'selector': instance.selector,
      'signature': instance.signature,
      'signedHeaders': instance.signedHeaders,
      'bodyHash': instance.bodyHash,
      'timestamp': instance.timestamp?.toIso8601String(),
      'expires': instance.expires?.toIso8601String(),
    };

DMARCPolicy _$DMARCPolicyFromJson(Map<String, dynamic> json) => DMARCPolicy(
      version: json['version'] as String,
      policy: json['policy'] as String,
      percentage: (json['percentage'] as num?)?.toInt() ?? 100,
      dkimFailureAction: json['dkimFailureAction'] as String?,
      spfFailureAction: json['spfFailureAction'] as String?,
      reportEmail: json['reportEmail'] as String?,
      reportInterval: (json['reportInterval'] as num?)?.toInt(),
      parameters: json['parameters'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$DMARCPolicyToJson(DMARCPolicy instance) =>
    <String, dynamic>{
      'version': instance.version,
      'policy': instance.policy,
      'percentage': instance.percentage,
      'dkimFailureAction': instance.dkimFailureAction,
      'spfFailureAction': instance.spfFailureAction,
      'reportEmail': instance.reportEmail,
      'reportInterval': instance.reportInterval,
      'parameters': instance.parameters,
    };
