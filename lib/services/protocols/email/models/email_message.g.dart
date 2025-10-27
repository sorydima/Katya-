// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmailMessage _$EmailMessageFromJson(Map<String, dynamic> json) => EmailMessage(
      id: json['id'] as String,
      from: json['from'] as String,
      to: (json['to'] as List<dynamic>).map((e) => e as String).toList(),
      cc: (json['cc'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      bcc: (json['bcc'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      subject: json['subject'] as String,
      body: json['body'] as String,
      htmlBody: json['htmlBody'] as String?,
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => EmailAttachment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      headers: (json['headers'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      timestamp: DateTime.parse(json['timestamp'] as String),
      status:
          $enumDecodeNullable(_$EmailMessageStatusEnumMap, json['status']) ??
              EmailMessageStatus.unread,
      encrypted: json['encrypted'] as bool? ?? false,
      signed: json['signed'] as bool? ?? false,
      dkimVerification: json['dkimVerification'] == null
          ? null
          : DKIMVerificationResult.fromJson(
              json['dkimVerification'] as Map<String, dynamic>),
      spfVerification: json['spfVerification'] == null
          ? null
          : SPFVerificationResult.fromJson(
              json['spfVerification'] as Map<String, dynamic>),
      dmarcVerification: json['dmarcVerification'] == null
          ? null
          : DMARCVerificationResult.fromJson(
              json['dmarcVerification'] as Map<String, dynamic>),
      size: (json['size'] as num?)?.toInt() ?? 0,
      flags: (json['flags'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$EmailFlagEnumMap, e))
              .toList() ??
          const [],
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$EmailMessageToJson(EmailMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'from': instance.from,
      'to': instance.to,
      'cc': instance.cc,
      'bcc': instance.bcc,
      'subject': instance.subject,
      'body': instance.body,
      'htmlBody': instance.htmlBody,
      'attachments': instance.attachments,
      'headers': instance.headers,
      'timestamp': instance.timestamp.toIso8601String(),
      'status': _$EmailMessageStatusEnumMap[instance.status]!,
      'encrypted': instance.encrypted,
      'signed': instance.signed,
      'dkimVerification': instance.dkimVerification,
      'spfVerification': instance.spfVerification,
      'dmarcVerification': instance.dmarcVerification,
      'size': instance.size,
      'flags': instance.flags.map((e) => _$EmailFlagEnumMap[e]!).toList(),
      'metadata': instance.metadata,
    };

const _$EmailMessageStatusEnumMap = {
  EmailMessageStatus.unread: 'unread',
  EmailMessageStatus.read: 'read',
  EmailMessageStatus.draft: 'draft',
  EmailMessageStatus.sent: 'sent',
  EmailMessageStatus.deleted: 'deleted',
  EmailMessageStatus.spam: 'spam',
  EmailMessageStatus.archived: 'archived',
};

const _$EmailFlagEnumMap = {
  EmailFlag.important: 'important',
  EmailFlag.flagged: 'flagged',
  EmailFlag.replied: 'replied',
  EmailFlag.forwarded: 'forwarded',
  EmailFlag.encrypted: 'encrypted',
  EmailFlag.signed: 'signed',
  EmailFlag.verified: 'verified',
};

EmailAttachment _$EmailAttachmentFromJson(Map<String, dynamic> json) =>
    EmailAttachment(
      filename: json['filename'] as String,
      mimeType: json['mimeType'] as String,
      size: (json['size'] as num).toInt(),
      filePath: json['filePath'] as String?,
      contentId: json['contentId'] as String?,
      description: json['description'] as String?,
      encrypted: json['encrypted'] as bool? ?? false,
      signed: json['signed'] as bool? ?? false,
    );

Map<String, dynamic> _$EmailAttachmentToJson(EmailAttachment instance) =>
    <String, dynamic>{
      'filename': instance.filename,
      'mimeType': instance.mimeType,
      'size': instance.size,
      'filePath': instance.filePath,
      'contentId': instance.contentId,
      'description': instance.description,
      'encrypted': instance.encrypted,
      'signed': instance.signed,
    };

EmailFolder _$EmailFolderFromJson(Map<String, dynamic> json) => EmailFolder(
      name: json['name'] as String,
      path: json['path'] as String,
      messageCount: (json['messageCount'] as num?)?.toInt() ?? 0,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? 0,
      attributes: (json['attributes'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$FolderAttributeEnumMap, e))
              .toList() ??
          const [],
      subfolders: (json['subfolders'] as List<dynamic>?)
              ?.map((e) => EmailFolder.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$EmailFolderToJson(EmailFolder instance) =>
    <String, dynamic>{
      'name': instance.name,
      'path': instance.path,
      'messageCount': instance.messageCount,
      'unreadCount': instance.unreadCount,
      'size': instance.size,
      'attributes':
          instance.attributes.map((e) => _$FolderAttributeEnumMap[e]!).toList(),
      'subfolders': instance.subfolders,
    };

const _$FolderAttributeEnumMap = {
  FolderAttribute.system: 'system',
  FolderAttribute.readOnly: 'read_only',
  FolderAttribute.subscribed: 'subscribed',
  FolderAttribute.hasChildren: 'has_children',
  FolderAttribute.noInferiors: 'no_inferiors',
  FolderAttribute.noSelect: 'no_select',
};
