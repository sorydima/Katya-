import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable()
class Message extends Equatable {
  final String id;
  final String senderId;
  final String? roomId;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final MessageStatus status;
  final Map<String, dynamic>? metadata;
  final DateTime? editedAt;
  final List<String>? reactions;

  const Message({
    required this.id,
    required this.senderId,
    this.roomId,
    required this.content,
    required this.timestamp,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    this.metadata,
    this.editedAt,
    this.reactions,
  });

  Message copyWith({
    String? id,
    String? senderId,
    String? roomId,
    String? content,
    DateTime? timestamp,
    MessageType? type,
    MessageStatus? status,
    Map<String, dynamic>? metadata,
    DateTime? editedAt,
    List<String>? reactions,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      roomId: roomId ?? this.roomId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      editedAt: editedAt ?? this.editedAt,
      reactions: reactions ?? this.reactions,
    );
  }

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);

  factory Message.fromMatrixEvent(dynamic event) {
    return Message(
      id: event.eventId ?? '',
      senderId: event.senderId ?? '',
      roomId: event.roomId,
      content: event.content?['body'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (event.originServerTs ?? 0) ~/ 1000,
      ),
      type: _parseMessageType(event.content?['msgtype']),
      status: MessageStatus.sent,
      metadata: event.content,
    );
  }

  static Message deleted({
    required String id,
    required String roomId,
  }) {
    return Message(
      id: id,
      senderId: '',
      roomId: roomId,
      content: 'This message was deleted',
      timestamp: DateTime.now(),
      type: MessageType.text,
      status: MessageStatus.sent,
      metadata: const {'deleted': true},
    );
  }

  @override
  List<Object?> get props => [
        id,
        senderId,
        roomId,
        content,
        timestamp,
        type,
        status,
        metadata,
        editedAt,
        reactions,
      ];

  static MessageType _parseMessageType(String? msgType) {
    switch (msgType) {
      case 'm.text':
        return MessageType.text;
      case 'm.image':
        return MessageType.image;
      case 'm.video':
        return MessageType.video;
      case 'm.audio':
        return MessageType.audio;
      case 'm.file':
        return MessageType.file;
      case 'm.location':
        return MessageType.location;
      default:
        return MessageType.text;
    }
  }
}

enum MessageType {
  text,
  image,
  video,
  audio,
  file,
  location,
  contact,
  document,
  sticker,
  gif,
  poll,
  event,
  custom,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}
