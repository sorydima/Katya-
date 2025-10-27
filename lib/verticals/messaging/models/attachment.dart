import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'attachment.g.dart';

@JsonSerializable()
class Attachment extends Equatable {
  final String id;
  final String name;
  final String type;
  final String? mimeType;
  final int size;
  final String? url;
  final String? thumbnailUrl;
  final Map<String, dynamic>? metadata;
  final DateTime? uploadedAt;

  const Attachment({
    required this.id,
    required this.name,
    required this.type,
    this.mimeType,
    required this.size,
    this.url,
    this.thumbnailUrl,
    this.metadata,
    this.uploadedAt,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) => _$AttachmentFromJson(json);
  Map<String, dynamic> toJson() => _$AttachmentToJson(this);

  factory Attachment.fromMatrixContent(Map<String, dynamic> content, String? url) {
    return Attachment(
      id: content['file']?['v'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: content['body'] ?? 'Unknown File',
      type: _getAttachmentType(content['info']?['mimetype']),
      mimeType: content['info']?['mimetype'],
      size: content['info']?['size'] ?? 0,
      url: url,
      metadata: content['info'],
      uploadedAt: DateTime.now(),
    );
  }

  static String _getAttachmentType(String? mimeType) {
    if (mimeType == null) return 'file';

    if (mimeType.startsWith('image/')) return 'image';
    if (mimeType.startsWith('video/')) return 'video';
    if (mimeType.startsWith('audio/')) return 'audio';
    if (mimeType == 'application/pdf') return 'document';

    return 'file';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        mimeType,
        size,
        url,
        thumbnailUrl,
        metadata,
        uploadedAt,
      ];
}

@JsonSerializable()
class MessageDraft extends Equatable {
  final String roomId;
  final String content;
  final DateTime timestamp;
  final List<String> attachmentPaths;

  const MessageDraft({
    required this.roomId,
    required this.content,
    required this.timestamp,
    this.attachmentPaths = const [],
  });

  factory MessageDraft.fromJson(Map<String, dynamic> json) => _$MessageDraftFromJson(json);
  Map<String, dynamic> toJson() => _$MessageDraftToJson(this);

  @override
  List<Object?> get props => [roomId, content, timestamp, attachmentPaths];
}

@JsonSerializable()
class ChatPreferences extends Equatable {
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String theme;
  final bool autoDownloadMedia;
  final int fontSize;
  final bool showPreview;

  const ChatPreferences({
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.theme = 'system',
    this.autoDownloadMedia = false,
    this.fontSize = 14,
    this.showPreview = true,
  });

  ChatPreferences copyWith({
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? theme,
    bool? autoDownloadMedia,
    int? fontSize,
    bool? showPreview,
  }) {
    return ChatPreferences(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      theme: theme ?? this.theme,
      autoDownloadMedia: autoDownloadMedia ?? this.autoDownloadMedia,
      fontSize: fontSize ?? this.fontSize,
      showPreview: showPreview ?? this.showPreview,
    );
  }

  factory ChatPreferences.fromJson(Map<String, dynamic> json) => _$ChatPreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$ChatPreferencesToJson(this);

  @override
  List<Object?> get props => [
        notificationsEnabled,
        soundEnabled,
        vibrationEnabled,
        theme,
        autoDownloadMedia,
        fontSize,
        showPreview,
      ];
}
