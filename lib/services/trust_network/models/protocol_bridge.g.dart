// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'protocol_bridge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProtocolConfig _$ProtocolConfigFromJson(Map<String, dynamic> json) =>
    ProtocolConfig(
      serverUrl: json['serverUrl'] as String?,
      port: (json['port'] as num?)?.toInt(),
      connectionTimeout: (json['connectionTimeout'] as num?)?.toInt() ?? 30,
      readTimeout: (json['readTimeout'] as num?)?.toInt() ?? 60,
      writeTimeout: (json['writeTimeout'] as num?)?.toInt() ?? 30,
      encryptionConfig: json['encryptionConfig'] == null
          ? const EncryptionConfig()
          : EncryptionConfig.fromJson(
              json['encryptionConfig'] as Map<String, dynamic>),
      authConfig: json['authConfig'] == null
          ? const AuthenticationConfig()
          : AuthenticationConfig.fromJson(
              json['authConfig'] as Map<String, dynamic>),
      customParameters:
          json['customParameters'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$ProtocolConfigToJson(ProtocolConfig instance) =>
    <String, dynamic>{
      'serverUrl': instance.serverUrl,
      'port': instance.port,
      'connectionTimeout': instance.connectionTimeout,
      'readTimeout': instance.readTimeout,
      'writeTimeout': instance.writeTimeout,
      'encryptionConfig': instance.encryptionConfig,
      'authConfig': instance.authConfig,
      'customParameters': instance.customParameters,
    };

EncryptionConfig _$EncryptionConfigFromJson(Map<String, dynamic> json) =>
    EncryptionConfig(
      encryptionType: json['encryptionType'] as String? ?? 'AES-256',
      keySize: (json['keySize'] as num?)?.toInt() ?? 256,
      hashAlgorithm: json['hashAlgorithm'] as String? ?? 'SHA-256',
      usePFS: json['usePFS'] as bool? ?? true,
    );

Map<String, dynamic> _$EncryptionConfigToJson(EncryptionConfig instance) =>
    <String, dynamic>{
      'encryptionType': instance.encryptionType,
      'keySize': instance.keySize,
      'hashAlgorithm': instance.hashAlgorithm,
      'usePFS': instance.usePFS,
    };

AuthenticationConfig _$AuthenticationConfigFromJson(
        Map<String, dynamic> json) =>
    AuthenticationConfig(
      authType: json['authType'] as String? ?? 'token',
      require2FA: json['require2FA'] as bool? ?? false,
      tokenLifetime: (json['tokenLifetime'] as num?)?.toInt() ?? 3600,
      parameters: json['parameters'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$AuthenticationConfigToJson(
        AuthenticationConfig instance) =>
    <String, dynamic>{
      'authType': instance.authType,
      'require2FA': instance.require2FA,
      'tokenLifetime': instance.tokenLifetime,
      'parameters': instance.parameters,
    };
