// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatRoom _$ChatRoomFromJson(Map<String, dynamic> json) => ChatRoom(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      participants: (json['participants'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      lastMessage: json['lastMessage'] as String?,
      lastActivity: DateTime.parse(json['lastActivity'] as String),
      isGroup: json['isGroup'] as bool? ?? false,
      isDirect: json['isDirect'] as bool? ?? false,
      avatarUrl: json['avatarUrl'] as String?,
      settings: json['settings'] as Map<String, dynamic>?,
      roomType: $enumDecodeNullable(_$RoomTypeEnumMap, json['roomType']) ??
          RoomType.room,
      topic: json['topic'] as String?,
    );

Map<String, dynamic> _$ChatRoomToJson(ChatRoom instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'participants': instance.participants,
      'lastMessage': instance.lastMessage,
      'lastActivity': instance.lastActivity.toIso8601String(),
      'isGroup': instance.isGroup,
      'isDirect': instance.isDirect,
      'avatarUrl': instance.avatarUrl,
      'settings': instance.settings,
      'roomType': _$RoomTypeEnumMap[instance.roomType]!,
      'topic': instance.topic,
    };

const _$RoomTypeEnumMap = {
  RoomType.room: 'room',
  RoomType.space: 'space',
  RoomType.direct: 'direct',
};

Attachment _$AttachmentFromJson(Map<String, dynamic> json) => Attachment(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      size: (json['size'] as num).toInt(),
      url: json['url'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$AttachmentToJson(Attachment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'size': instance.size,
      'url': instance.url,
      'thumbnailUrl': instance.thumbnailUrl,
      'metadata': instance.metadata,
    };
