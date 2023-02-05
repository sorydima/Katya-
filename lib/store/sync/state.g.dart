// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncStore _$SyncStoreFromJson(Map<String, dynamic> json) => SyncStore(
      synced: json['synced'] as bool? ?? false,
      offline: json['offline'] as bool? ?? false,
      backgrounded: json['backgrounded'] as bool? ?? false,
      lastUpdate: json['lastUpdate'] as int? ?? 0,
      lastAttempt: json['lastAttempt'] as int? ?? 0,
      lastSince: json['lastSince'] as String?,
    );

Map<String, dynamic> _$SyncStoreToJson(SyncStore instance) => <String, dynamic>{
      'synced': instance.synced,
      'offline': instance.offline,
      'backgrounded': instance.backgrounded,
      'lastUpdate': instance.lastUpdate,
      'lastAttempt': instance.lastAttempt,
      'lastSince': instance.lastSince,
    };
