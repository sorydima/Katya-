// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pusher _$PusherFromJson(Map<String, dynamic> json) => Pusher(
      key: json['key'] as String?,
      kind: json['kind'] as String?,
      appId: json['appId'] as String?,
      appDisplayName: json['appDisplayName'] as String?,
    );

Map<String, dynamic> _$PusherToJson(Pusher instance) => <String, dynamic>{
      'key': instance.key,
      'kind': instance.kind,
      'appId': instance.appId,
      'appDisplayName': instance.appDisplayName,
    };
