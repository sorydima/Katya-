// GENERATED CODE - DO NOT MODIFY BY HAND

part of 's7_connection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

S7Connection _$S7ConnectionFromJson(Map<String, dynamic> json) => S7Connection(
      connectionId: json['connectionId'] as String,
      host: json['host'] as String,
      port: (json['port'] as num).toInt(),
      rack: (json['rack'] as num).toInt(),
      slot: (json['slot'] as num).toInt(),
      credentials: json['credentials'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastActivity: DateTime.parse(json['lastActivity'] as String),
      reconnectCount: (json['reconnectCount'] as num?)?.toInt() ?? 0,
      stats: json['stats'] == null
          ? const ConnectionStats()
          : ConnectionStats.fromJson(json['stats'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$S7ConnectionToJson(S7Connection instance) =>
    <String, dynamic>{
      'connectionId': instance.connectionId,
      'host': instance.host,
      'port': instance.port,
      'rack': instance.rack,
      'slot': instance.slot,
      'credentials': instance.credentials,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastActivity': instance.lastActivity.toIso8601String(),
      'reconnectCount': instance.reconnectCount,
      'stats': instance.stats,
    };

ConnectionStats _$ConnectionStatsFromJson(Map<String, dynamic> json) =>
    ConnectionStats(
      messagesSent: (json['messagesSent'] as num?)?.toInt() ?? 0,
      messagesReceived: (json['messagesReceived'] as num?)?.toInt() ?? 0,
      errorCount: (json['errorCount'] as num?)?.toInt() ?? 0,
      totalReconnects: (json['totalReconnects'] as num?)?.toInt() ?? 0,
      lastErrorTime: json['lastErrorTime'] == null
          ? null
          : DateTime.parse(json['lastErrorTime'] as String),
      lastErrorMessage: json['lastErrorMessage'] as String?,
      bytesTransmitted: (json['bytesTransmitted'] as num?)?.toInt() ?? 0,
      bytesReceived: (json['bytesReceived'] as num?)?.toInt() ?? 0,
      averageResponseTime:
          (json['averageResponseTime'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$ConnectionStatsToJson(ConnectionStats instance) =>
    <String, dynamic>{
      'messagesSent': instance.messagesSent,
      'messagesReceived': instance.messagesReceived,
      'errorCount': instance.errorCount,
      'totalReconnects': instance.totalReconnects,
      'lastErrorTime': instance.lastErrorTime?.toIso8601String(),
      'lastErrorMessage': instance.lastErrorMessage,
      'bytesTransmitted': instance.bytesTransmitted,
      'bytesReceived': instance.bytesReceived,
      'averageResponseTime': instance.averageResponseTime,
    };

S7ConnectionConfig _$S7ConnectionConfigFromJson(Map<String, dynamic> json) =>
    S7ConnectionConfig(
      maxReconnects: (json['maxReconnects'] as num?)?.toInt() ?? 5,
      reconnectInterval: (json['reconnectInterval'] as num?)?.toInt() ?? 10,
      connectionTimeout: (json['connectionTimeout'] as num?)?.toInt() ?? 5000,
      readTimeout: (json['readTimeout'] as num?)?.toInt() ?? 3000,
      heartbeatInterval: (json['heartbeatInterval'] as num?)?.toInt() ?? 30000,
      autoReconnect: json['autoReconnect'] as bool? ?? true,
      enableCompression: json['enableCompression'] as bool? ?? false,
      enableEncryption: json['enableEncryption'] as bool? ?? true,
    );

Map<String, dynamic> _$S7ConnectionConfigToJson(S7ConnectionConfig instance) =>
    <String, dynamic>{
      'maxReconnects': instance.maxReconnects,
      'reconnectInterval': instance.reconnectInterval,
      'connectionTimeout': instance.connectionTimeout,
      'readTimeout': instance.readTimeout,
      'heartbeatInterval': instance.heartbeatInterval,
      'autoReconnect': instance.autoReconnect,
      'enableCompression': instance.enableCompression,
      'enableEncryption': instance.enableEncryption,
    };
