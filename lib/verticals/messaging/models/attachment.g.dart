// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Attachment _$AttachmentFromJson(Map<String, dynamic> json) => Attachment(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      mimeType: json['mimeType'] as String?,
      size: (json['size'] as num).toInt(),
      url: json['url'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      uploadedAt: json['uploadedAt'] == null
          ? null
          : DateTime.parse(json['uploadedAt'] as String),
    );

Map<String, dynamic> _$AttachmentToJson(Attachment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'mimeType': instance.mimeType,
      'size': instance.size,
      'url': instance.url,
      'thumbnailUrl': instance.thumbnailUrl,
      'metadata': instance.metadata,
      'uploadedAt': instance.uploadedAt?.toIso8601String(),
    };

MessageDraft _$MessageDraftFromJson(Map<String, dynamic> json) => MessageDraft(
      roomId: json['roomId'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      attachmentPaths: (json['attachmentPaths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$MessageDraftToJson(MessageDraft instance) =>
    <String, dynamic>{
      'roomId': instance.roomId,
      'content': instance.content,
      'timestamp': instance.timestamp.toIso8601String(),
      'attachmentPaths': instance.attachmentPaths,
    };

ChatPreferences _$ChatPreferencesFromJson(Map<String, dynamic> json) =>
    ChatPreferences(
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      theme: json['theme'] as String? ?? 'system',
      autoDownloadMedia: json['autoDownloadMedia'] as bool? ?? false,
      fontSize: (json['fontSize'] as num?)?.toInt() ?? 14,
      showPreview: json['showPreview'] as bool? ?? true,
    );

Map<String, dynamic> _$ChatPreferencesToJson(ChatPreferences instance) =>
    <String, dynamic>{
      'notificationsEnabled': instance.notificationsEnabled,
      'soundEnabled': instance.soundEnabled,
      'vibrationEnabled': instance.vibrationEnabled,
      'theme': instance.theme,
      'autoDownloadMedia': instance.autoDownloadMedia,
      'fontSize': instance.fontSize,
      'showPreview': instance.showPreview,
    };
