// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProxySettings _$ProxySettingsFromJson(Map<String, dynamic> json) =>
    ProxySettings(
      enabled: json['enabled'] as bool? ?? false,
      host: json['host'] as String? ?? '127.0.0.1',
      port: json['port'] as String? ?? '8118',
      authenticationEnabled: json['authenticationEnabled'] as bool? ?? false,
      username: json['username'] as String? ?? 'username',
      password: json['password'] as String? ?? 'password',
    );

Map<String, dynamic> _$ProxySettingsToJson(ProxySettings instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'host': instance.host,
      'port': instance.port,
      'username': instance.username,
      'password': instance.password,
      'authenticationEnabled': instance.authenticationEnabled,
    };
