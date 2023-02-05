// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reaction _$ReactionFromJson(Map<String, dynamic> json) => Reaction(
      id: json['id'],
      userId: json['userId'],
      roomId: json['roomId'],
      type: json['type'],
      sender: json['sender'],
      stateKey: json['stateKey'],
      batch: json['batch'],
      prevBatch: json['prevBatch'],
      timestamp: json['timestamp'] ?? 0,
      body: json['body'] as String?,
      relType: json['relType'] as String?,
      relEventId: json['relEventId'] as String?,
    );

Map<String, dynamic> _$ReactionToJson(Reaction instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'roomId': instance.roomId,
      'type': instance.type,
      'sender': instance.sender,
      'stateKey': instance.stateKey,
      'batch': instance.batch,
      'prevBatch': instance.prevBatch,
      'timestamp': instance.timestamp,
      'body': instance.body,
      'relType': instance.relType,
      'relEventId': instance.relEventId,
    };
