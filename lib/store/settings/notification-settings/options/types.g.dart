// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationOptions _$NotificationOptionsFromJson(Map<String, dynamic> json) =>
    NotificationOptions(
      muted: json['muted'] as bool? ?? false,
      enabled: json['enabled'] as bool? ?? false,
      muteTimestamp: json['muteTimestamp'] as int? ?? 0,
    );

Map<String, dynamic> _$NotificationOptionsToJson(
        NotificationOptions instance) =>
    <String, dynamic>{
      'muted': instance.muted,
      'enabled': instance.enabled,
      'muteTimestamp': instance.muteTimestamp,
    };
