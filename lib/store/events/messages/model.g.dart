// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      roomId: json['roomId'] as String?,
      type: json['type'] as String?,
      sender: json['sender'] as String?,
      stateKey: json['stateKey'] as String?,
      batch: json['batch'] as String?,
      prevBatch: json['prevBatch'] as String?,
      timestamp: json['timestamp'] as int? ?? 0,
      body: json['body'] as String?,
      typeDecrypted: json['typeDecrypted'] as String?,
      msgtype: json['msgtype'] as String?,
      format: json['format'] as String?,
      file: json['file'] as Map<String, dynamic>?,
      url: json['url'] as String?,
      info: json['info'] as Map<String, dynamic>?,
      formattedBody: json['formattedBody'] as String?,
      received: json['received'] as int? ?? 0,
      ciphertext: json['ciphertext'] as String?,
      senderKey: json['senderKey'] as String?,
      deviceId: json['deviceId'] as String?,
      algorithm: json['algorithm'] as String?,
      sessionId: json['sessionId'] as String?,
      relatedEventId: json['relatedEventId'] as String?,
      edited: json['edited'] as bool? ?? false,
      syncing: json['syncing'] as bool? ?? false,
      pending: json['pending'] as bool? ?? false,
      failed: json['failed'] as bool? ?? false,
      replacement: json['replacement'] as bool? ?? false,
      hasLink: json['hasLink'] as bool? ?? false,
      editIds: (json['editIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'roomId': instance.roomId,
      'type': instance.type,
      'sender': instance.sender,
      'stateKey': instance.stateKey,
      'batch': instance.batch,
      'prevBatch': instance.prevBatch,
      'timestamp': instance.timestamp,
      'pending': instance.pending,
      'syncing': instance.syncing,
      'failed': instance.failed,
      'edited': instance.edited,
      'replacement': instance.replacement,
      'hasLink': instance.hasLink,
      'received': instance.received,
      'body': instance.body,
      'msgtype': instance.msgtype,
      'format': instance.format,
      'formattedBody': instance.formattedBody,
      'url': instance.url,
      'file': instance.file,
      'info': instance.info,
      'typeDecrypted': instance.typeDecrypted,
      'ciphertext': instance.ciphertext,
      'algorithm': instance.algorithm,
      'sessionId': instance.sessionId,
      'senderKey': instance.senderKey,
      'deviceId': instance.deviceId,
      'relatedEventId': instance.relatedEventId,
      'editIds': instance.editIds,
    };
