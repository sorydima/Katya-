import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_room.g.dart';

@JsonSerializable()
class ChatRoom extends Equatable {
  final String id;
  final String name;
  final String? description;
  final List<String> participants;
  final String? lastMessage;
  final DateTime lastActivity;
  final bool isGroup;
  final bool isDirect;
  final String? avatarUrl;
  final Map<String, dynamic>? settings;
  final RoomType roomType;
  final String? topic;

  const ChatRoom({
    required this.id,
    required this.name,
    this.description,
    this.participants = const [],
    this.lastMessage,
    required this.lastActivity,
    this.isGroup = false,
    this.isDirect = false,
    this.avatarUrl,
    this.settings,
    this.roomType = RoomType.room,
    this.topic,
  });

  ChatRoom copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? participants,
    String? lastMessage,
    DateTime? lastActivity,
    bool? isGroup,
    bool? isDirect,
    String? avatarUrl,
    Map<String, dynamic>? settings,
    RoomType? roomType,
    String? topic,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastActivity: lastActivity ?? this.lastActivity,
      isGroup: isGroup ?? this.isGroup,
      isDirect: isDirect ?? this.isDirect,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      settings: settings ?? this.settings,
      roomType: roomType ?? this.roomType,
      topic: topic ?? this.topic,
    );
  }

  factory ChatRoom.fromJson(Map<String, dynamic> json) => _$ChatRoomFromJson(json);
  Map<String, dynamic> toJson() => _$ChatRoomToJson(this);

  factory ChatRoom.fromMatrixRoom(dynamic room) {
    return ChatRoom(
      id: room.id,
      name: room.displayName ?? room.canonicalAlias ?? 'Unknown Room',
      description: room.topic,
      participants: room.joinedMembers?.map<String>((m) => m.userId).toList() ?? [],
      lastMessage: room.lastEvent?.body,
      lastActivity: room.lastEvent?.originServerTs != null
          ? DateTime.fromMillisecondsSinceEpoch(room.lastEvent.originServerTs ~/ 1000)
          : DateTime.now(),
      isGroup: !room.isDirectChat,
      isDirect: room.isDirectChat,
      avatarUrl: room.avatar?.toString(),
      roomType: room.isSpace ? RoomType.space : RoomType.room,
      topic: room.topic,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        participants,
        lastMessage,
        lastActivity,
        isGroup,
        isDirect,
        avatarUrl,
        settings,
        roomType,
        topic,
      ];
}

enum RoomType {
  room,
  space,
  direct,
}

@JsonSerializable()
class Attachment extends Equatable {
  final String id;
  final String name;
  final String type;
  final int size;
  final String? url;
  final String? thumbnailUrl;
  final Map<String, dynamic>? metadata;

  const Attachment({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    this.url,
    this.thumbnailUrl,
    this.metadata,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) => _$AttachmentFromJson(json);
  Map<String, dynamic> toJson() => _$AttachmentToJson(this);

  @override
  List<Object?> get props => [id, name, type, size, url, thumbnailUrl, metadata];
}
