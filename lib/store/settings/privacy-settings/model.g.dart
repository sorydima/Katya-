// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrivacySettings _$PrivacySettingsFromJson(Map<String, dynamic> json) =>
    PrivacySettings(
      lastBackupMillis: json['lastBackupMillis'] as String? ?? '0',
      keyBackupInterval: json['keyBackupInterval'] == null
          ? Duration.zero
          : Duration(microseconds: json['keyBackupInterval'] as int),
    );

Map<String, dynamic> _$PrivacySettingsToJson(PrivacySettings instance) =>
    <String, dynamic>{
      'lastBackupMillis': instance.lastBackupMillis,
      'keyBackupInterval': instance.keyBackupInterval.inMicroseconds,
    };
