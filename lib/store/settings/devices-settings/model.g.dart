// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Device _$DeviceFromJson(Map<String, dynamic> json) => Device(
      deviceId: json['deviceId'] as String?,
      displayName: json['displayName'] as String?,
      lastSeenIp: json['lastSeenIp'] as String?,
      lastSeenTs: json['lastSeenTs'] as int?,
    );

Map<String, dynamic> _$DeviceToJson(Device instance) => <String, dynamic>{
      'deviceId': instance.deviceId,
      'displayName': instance.displayName,
      'lastSeenIp': instance.lastSeenIp,
      'lastSeenTs': instance.lastSeenTs,
    };
