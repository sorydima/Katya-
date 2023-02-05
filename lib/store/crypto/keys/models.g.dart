// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OneTimeKey _$OneTimeKeyFromJson(Map<String, dynamic> json) => OneTimeKey(
      userId: json['userId'] as String?,
      deviceId: json['deviceId'] as String?,
      keys: (json['keys'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String?),
          ) ??
          const {},
      signatures: (json['signatures'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, Map<String, String>.from(e as Map)),
          ) ??
          const {},
    );

Map<String, dynamic> _$OneTimeKeyToJson(OneTimeKey instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'deviceId': instance.deviceId,
      'keys': instance.keys,
      'signatures': instance.signatures,
    };

DeviceKey _$DeviceKeyFromJson(Map<String, dynamic> json) => DeviceKey(
      userId: json['userId'] as String?,
      deviceId: json['deviceId'] as String?,
      algorithms: (json['algorithms'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      keys: (json['keys'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      signatures: json['signatures'] as Map<String, dynamic>?,
      extras: (json['extras'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$DeviceKeyToJson(DeviceKey instance) => <String, dynamic>{
      'userId': instance.userId,
      'deviceId': instance.deviceId,
      'algorithms': instance.algorithms,
      'keys': instance.keys,
      'signatures': instance.signatures,
      'extras': instance.extras,
    };
