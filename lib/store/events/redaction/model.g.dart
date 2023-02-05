// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Redaction _$RedactionFromJson(Map<String, dynamic> json) => Redaction(
      id: json['id'],
      userId: json['userId'],
      roomId: json['roomId'],
      type: json['type'],
      sender: json['sender'],
      stateKey: json['stateKey'],
      batch: json['batch'],
      prevBatch: json['prevBatch'],
      timestamp: json['timestamp'] ?? 0,
      redactId: json['redactId'] as String?,
    );

Map<String, dynamic> _$RedactionToJson(Redaction instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'roomId': instance.roomId,
      'type': instance.type,
      'sender': instance.sender,
      'stateKey': instance.stateKey,
      'batch': instance.batch,
      'prevBatch': instance.prevBatch,
      'timestamp': instance.timestamp,
      'redactId': instance.redactId,
    };
