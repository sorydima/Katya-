import 'package:equatable/equatable.dart';

/// Messaging Models
/// Data models for messaging functionality

class ChatRoom extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastActivity;
  final bool isGroup;
  final String? avatarUrl;
  final Map<String, dynamic> settings;

  const ChatRoom({
    required this.id,
    required this.name,
    this.description = '',
    this.participants = const [],
    this.lastMessage = '',
    required this.lastActivity,
    this.isGroup = false,
    this.avatarUrl,
    this.settings = const {},
  });

  @override
  List<Object?> get props => [id, name, participants, lastActivity];

  ChatRoom copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? participants,
    String? lastMessage,
    DateTime? lastActivity,
    bool? isGroup,
    String? avatarUrl,
    Map<String, dynamic>? settings,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastActivity: lastActivity ?? this.lastActivity,
      isGroup: isGroup ?? this.isGroup,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      settings: settings ?? this.settings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastActivity': lastActivity.toIso8601String(),
      'isGroup': isGroup,
      'avatarUrl': avatarUrl,
      'settings': settings,
    };
  }

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      participants: (json['participants'] as List?)?.map((e) => e as String).toList() ?? [],
      lastMessage: json['lastMessage'] as String? ?? '',
      lastActivity: DateTime.parse(json['lastActivity'] as String),
      isGroup: json['isGroup'] as bool? ?? false,
      avatarUrl: json['avatarUrl'] as String?,
      settings: (json['settings'] as Map?)?.map((k, v) => MapEntry(k as String, v)) ?? {},
    );
  }
}

class MessageDraft {
  final String roomId;
  final String content;
  final DateTime timestamp;
  final List<String> attachments;

  const MessageDraft({
    required this.roomId,
    required this.content,
    required this.timestamp,
    this.attachments = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'attachments': attachments,
    };
  }

  factory MessageDraft.fromJson(Map<String, dynamic> json) {
    return MessageDraft(
      roomId: json['roomId'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      attachments: (json['attachments'] as List?)?.map((e) => e as String).toList() ?? [],
    );
  }
}

class ChatPreferences {
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String theme;
  final bool autoDownloadMedia;
  final int fontSize;

  const ChatPreferences({
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.theme = 'system',
    this.autoDownloadMedia = false,
    this.fontSize = 14,
  });

  ChatPreferences copyWith({
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? theme,
    bool? autoDownloadMedia,
    int? fontSize,
  }) {
    return ChatPreferences(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      theme: theme ?? this.theme,
      autoDownloadMedia: autoDownloadMedia ?? this.autoDownloadMedia,
      fontSize: fontSize ?? this.fontSize,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'theme': theme,
      'autoDownloadMedia': autoDownloadMedia,
      'fontSize': fontSize,
    };
  }

  factory ChatPreferences.fromJson(Map<String, dynamic> json) {
    return ChatPreferences(
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      theme: json['theme'] as String? ?? 'system',
      autoDownloadMedia: json['autoDownloadMedia'] as bool? ?? false,
      fontSize: json['fontSize'] as int? ?? 14,
    );
  }
}
