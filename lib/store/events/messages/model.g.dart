// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      id: json['id'] as String?,
      sender: json['sender'] as String?,
      timestamp: (json['timestamp'] as num?)?.toInt() ?? 0,
      type: json['type'] as String?,
      roomId: json['roomId'] as String?,
      pending: json['pending'] as bool? ?? false,
      syncing: json['syncing'] as bool? ?? false,
      failed: json['failed'] as bool? ?? false,
      edited: json['edited'] as bool? ?? false,
      replacement: json['replacement'] as bool? ?? false,
      hasLink: json['hasLink'] as bool? ?? false,
      received: (json['received'] as num?)?.toInt() ?? 0,
      body: json['body'] as String?,
      msgtype: json['msgtype'] as String?,
      format: json['format'] as String?,
      formattedBody: json['formattedBody'] as String?,
      url: json['url'] as String?,
      file: json['file'] as Map<String, dynamic>?,
      info: json['info'] as Map<String, dynamic>?,
      typeDecrypted: json['typeDecrypted'] as String?,
      ciphertext: json['ciphertext'] as String?,
      algorithm: json['algorithm'] as String?,
      tokenGateConfig: json['tokenGateConfig'] == null
          ? null
          : TokenGateConfig.fromJson(
              json['tokenGateConfig'] as Map<String, dynamic>),
      sessionId: json['sessionId'] as String?,
      senderKey: json['senderKey'] as String?,
      deviceId: json['deviceId'] as String?,
      relatedEventId: json['relatedEventId'] as String?,
      editIds: (json['editIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      unsigned: json['unsigned'] as Map<String, dynamic>?,
      prevContent: json['prevContent'] as Map<String, dynamic>?,
      redactedBecause: json['redactedBecause'] as Map<String, dynamic>?,
      relatesTo: json['relatesTo'] as Map<String, dynamic>?,
      relations: json['relations'] as Map<String, dynamic>?,
      edits: (json['edits'] as List<dynamic>?)
          ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList(),
      thread: json['thread'] as Map<String, dynamic>?,
      inviteRoomState: json['inviteRoomState'] as List<dynamic>?,
      originServerTsLocalCreate:
          (json['originServerTsLocalCreate'] as num?)?.toInt(),
      originServerTsLocalEdit:
          (json['originServerTsLocalEdit'] as num?)?.toInt(),
      originServerTsLocalReceipt:
          (json['originServerTsLocalReceipt'] as num?)?.toInt(),
      status: json['status'] as String?,
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'id': instance.id,
      'roomId': instance.roomId,
      'type': instance.type,
      'sender': instance.sender,
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
      'unsigned': instance.unsigned,
      'prevContent': instance.prevContent,
      'redactedBecause': instance.redactedBecause,
      'relatesTo': instance.relatesTo,
      'relations': instance.relations,
      'edits': instance.edits,
      'thread': instance.thread,
      'inviteRoomState': instance.inviteRoomState,
      'originServerTsLocalCreate': instance.originServerTsLocalCreate,
      'originServerTsLocalEdit': instance.originServerTsLocalEdit,
      'originServerTsLocalReceipt': instance.originServerTsLocalReceipt,
      'status': instance.status,
      'algorithm': instance.algorithm,
      'tokenGateConfig': instance.tokenGateConfig,
      'sessionId': instance.sessionId,
      'senderKey': instance.senderKey,
      'deviceId': instance.deviceId,
      'relatedEventId': instance.relatedEventId,
      'editIds': instance.editIds,
    };
