import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:katya/services/protocols/email/models/dkim_verification.dart';

part 'email_message.g.dart';

/// Модель E-Mail сообщения
@JsonSerializable()
class EmailMessage extends Equatable {
  /// Уникальный идентификатор сообщения
  final String id;

  /// Отправитель
  final String from;

  /// Получатели
  final List<String> to;

  /// Копия
  final List<String> cc;

  /// Скрытая копия
  final List<String> bcc;

  /// Тема
  final String subject;

  /// Тело сообщения
  final String body;

  /// HTML версия тела
  final String? htmlBody;

  /// Вложения
  final List<EmailAttachment> attachments;

  /// Заголовки
  final Map<String, String> headers;

  /// Временная метка
  final DateTime timestamp;

  /// Статус сообщения
  final EmailMessageStatus status;

  /// Зашифровано ли сообщение
  final bool encrypted;

  /// Подписано ли сообщение
  final bool signed;

  /// Результат верификации DKIM
  DKIMVerificationResult? dkimVerification;

  /// Результат верификации SPF
  SPFVerificationResult? spfVerification;

  /// Результат верификации DMARC
  DMARCVerificationResult? dmarcVerification;

  /// Размер сообщения в байтах
  final int size;

  /// Флаги сообщения
  final List<EmailFlag> flags;

  /// Метаданные
  final Map<String, dynamic> metadata;

  const EmailMessage({
    required this.id,
    required this.from,
    required this.to,
    this.cc = const [],
    this.bcc = const [],
    required this.subject,
    required this.body,
    this.htmlBody,
    this.attachments = const [],
    this.headers = const {},
    required this.timestamp,
    this.status = EmailMessageStatus.unread,
    this.encrypted = false,
    this.signed = false,
    this.dkimVerification,
    this.spfVerification,
    this.dmarcVerification,
    this.size = 0,
    this.flags = const [],
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
        id,
        from,
        to,
        cc,
        bcc,
        subject,
        body,
        htmlBody,
        attachments,
        headers,
        timestamp,
        status,
        encrypted,
        signed,
        dkimVerification,
        spfVerification,
        dmarcVerification,
        size,
        flags,
        metadata,
      ];

  EmailMessage copyWith({
    String? id,
    String? from,
    List<String>? to,
    List<String>? cc,
    List<String>? bcc,
    String? subject,
    String? body,
    String? htmlBody,
    List<EmailAttachment>? attachments,
    Map<String, String>? headers,
    DateTime? timestamp,
    EmailMessageStatus? status,
    bool? encrypted,
    bool? signed,
    DKIMVerificationResult? dkimVerification,
    SPFVerificationResult? spfVerification,
    DMARCVerificationResult? dmarcVerification,
    int? size,
    List<EmailFlag>? flags,
    Map<String, dynamic>? metadata,
  }) {
    return EmailMessage(
      id: id ?? this.id,
      from: from ?? this.from,
      to: to ?? this.to,
      cc: cc ?? this.cc,
      bcc: bcc ?? this.bcc,
      subject: subject ?? this.subject,
      body: body ?? this.body,
      htmlBody: htmlBody ?? this.htmlBody,
      attachments: attachments ?? this.attachments,
      headers: headers ?? this.headers,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      encrypted: encrypted ?? this.encrypted,
      signed: signed ?? this.signed,
      dkimVerification: dkimVerification ?? this.dkimVerification,
      spfVerification: spfVerification ?? this.spfVerification,
      dmarcVerification: dmarcVerification ?? this.dmarcVerification,
      size: size ?? this.size,
      flags: flags ?? this.flags,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Получение всех получателей
  List<String> get allRecipients => [...to, ...cc, ...bcc];

  /// Проверка, прочитано ли сообщение
  bool get isRead => status == EmailMessageStatus.read;

  /// Проверка, является ли сообщение важным
  bool get isImportant => flags.contains(EmailFlag.important);

  /// Проверка, является ли сообщение черновиком
  bool get isDraft => status == EmailMessageStatus.draft;

  /// Проверка, отправлено ли сообщение
  bool get isSent => status == EmailMessageStatus.sent;

  /// Проверка, удалено ли сообщение
  bool get isDeleted => status == EmailMessageStatus.deleted;

  /// Получение домена отправителя
  String get senderDomain => from.split('@').last;

  /// Получение локальной части отправителя
  String get senderLocal => from.split('@').first;

  /// Проверка, имеет ли сообщение вложения
  bool get hasAttachments => attachments.isNotEmpty;

  /// Получение размера вложений
  int get attachmentsSize {
    return attachments.fold(0, (sum, attachment) => sum + attachment.size);
  }

  /// Проверка, верифицировано ли DKIM
  bool get isDKIMVerified => dkimVerification?.isVerified ?? false;

  /// Проверка, верифицирован ли SPF
  bool get isSPFVerified => spfVerification?.result == SPFResult.pass;

  /// Проверка, верифицирован ли DMARC
  bool get isDMARCVerified => dmarcVerification?.result == DMARCResult.pass;

  /// Получение общего уровня безопасности
  SecurityLevel get securityLevel {
    if (encrypted && signed && isDKIMVerified && isSPFVerified && isDMARCVerified) {
      return SecurityLevel.veryHigh;
    } else if (encrypted && signed && (isDKIMVerified || isSPFVerified)) {
      return SecurityLevel.high;
    } else if (encrypted || signed) {
      return SecurityLevel.medium;
    } else if (isDKIMVerified || isSPFVerified) {
      return SecurityLevel.low;
    } else {
      return SecurityLevel.none;
    }
  }

  /// Получение краткого предварительного просмотра
  String get preview {
    final preview = body.length > 100 ? '${body.substring(0, 100)}...' : body;
    return preview.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Получение времени в локальном формате
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Map<String, dynamic> toJson() => _$EmailMessageToJson(this);
  factory EmailMessage.fromJson(Map<String, dynamic> json) => _$EmailMessageFromJson(json);
}

/// Статус E-Mail сообщения
enum EmailMessageStatus {
  @JsonValue('unread')
  unread,
  @JsonValue('read')
  read,
  @JsonValue('draft')
  draft,
  @JsonValue('sent')
  sent,
  @JsonValue('deleted')
  deleted,
  @JsonValue('spam')
  spam,
  @JsonValue('archived')
  archived,
}

/// Флаги E-Mail сообщения
enum EmailFlag {
  @JsonValue('important')
  important,
  @JsonValue('flagged')
  flagged,
  @JsonValue('replied')
  replied,
  @JsonValue('forwarded')
  forwarded,
  @JsonValue('encrypted')
  encrypted,
  @JsonValue('signed')
  signed,
  @JsonValue('verified')
  verified,
}

/// Уровень безопасности
enum SecurityLevel {
  @JsonValue('none')
  none,
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('very_high')
  veryHigh,
}

/// Вложение E-Mail
@JsonSerializable()
class EmailAttachment extends Equatable {
  /// Имя файла
  final String filename;

  /// MIME тип
  final String mimeType;

  /// Размер в байтах
  final int size;

  /// Данные вложения
  @JsonKey(ignore: true)
  final Uint8List? data;

  /// Путь к файлу
  final String? filePath;

  /// Content-ID для встроенных изображений
  final String? contentId;

  /// Описание вложения
  final String? description;

  /// Зашифровано ли вложение
  final bool encrypted;

  /// Подписано ли вложение
  final bool signed;

  const EmailAttachment({
    required this.filename,
    required this.mimeType,
    required this.size,
    this.data,
    this.filePath,
    this.contentId,
    this.description,
    this.encrypted = false,
    this.signed = false,
  });

  @override
  List<Object?> get props => [
        filename,
        mimeType,
        size,
        data,
        filePath,
        contentId,
        description,
        encrypted,
        signed,
      ];

  EmailAttachment copyWith({
    String? filename,
    String? mimeType,
    int? size,
    Uint8List? data,
    String? filePath,
    String? contentId,
    String? description,
    bool? encrypted,
    bool? signed,
  }) {
    return EmailAttachment(
      filename: filename ?? this.filename,
      mimeType: mimeType ?? this.mimeType,
      size: size ?? this.size,
      data: data ?? this.data,
      filePath: filePath ?? this.filePath,
      contentId: contentId ?? this.contentId,
      description: description ?? this.description,
      encrypted: encrypted ?? this.encrypted,
      signed: signed ?? this.signed,
    );
  }

  /// Получение расширения файла
  String get extension {
    final parts = filename.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  /// Проверка, является ли вложение изображением
  bool get isImage {
    return mimeType.startsWith('image/');
  }

  /// Проверка, является ли вложение документом
  bool get isDocument {
    return mimeType.startsWith('application/') && ['pdf', 'doc', 'docx', 'txt', 'rtf'].contains(extension);
  }

  /// Проверка, является ли вложение архивом
  bool get isArchive {
    return ['zip', 'rar', '7z', 'tar', 'gz'].contains(extension);
  }

  /// Получение размера в человекочитаемом формате
  String get formattedSize {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  Map<String, dynamic> toJson() => _$EmailAttachmentToJson(this);
  factory EmailAttachment.fromJson(Map<String, dynamic> json) => _$EmailAttachmentFromJson(json);
}

/// Папка E-Mail
@JsonSerializable()
class EmailFolder extends Equatable {
  /// Название папки
  final String name;

  /// Полный путь к папке
  final String path;

  /// Количество сообщений
  final int messageCount;

  /// Количество непрочитанных сообщений
  final int unreadCount;

  /// Размер папки в байтах
  final int size;

  /// Атрибуты папки
  final List<FolderAttribute> attributes;

  /// Подпапки
  final List<EmailFolder> subfolders;

  const EmailFolder({
    required this.name,
    required this.path,
    this.messageCount = 0,
    this.unreadCount = 0,
    this.size = 0,
    this.attributes = const [],
    this.subfolders = const [],
  });

  @override
  List<Object?> get props => [
        name,
        path,
        messageCount,
        unreadCount,
        size,
        attributes,
        subfolders,
      ];

  EmailFolder copyWith({
    String? name,
    String? path,
    int? messageCount,
    int? unreadCount,
    int? size,
    List<FolderAttribute>? attributes,
    List<EmailFolder>? subfolders,
  }) {
    return EmailFolder(
      name: name ?? this.name,
      path: path ?? this.path,
      messageCount: messageCount ?? this.messageCount,
      unreadCount: unreadCount ?? this.unreadCount,
      size: size ?? this.size,
      attributes: attributes ?? this.attributes,
      subfolders: subfolders ?? this.subfolders,
    );
  }

  /// Проверка, является ли папка системной
  bool get isSystemFolder {
    return attributes.contains(FolderAttribute.system) || ['INBOX', 'Sent', 'Drafts', 'Trash', 'Spam'].contains(name);
  }

  /// Проверка, можно ли записывать в папку
  bool get isWritable {
    return !attributes.contains(FolderAttribute.readOnly);
  }

  /// Проверка, имеет ли папка подпапки
  bool get hasSubfolders => subfolders.isNotEmpty;

  Map<String, dynamic> toJson() => _$EmailFolderToJson(this);
  factory EmailFolder.fromJson(Map<String, dynamic> json) => _$EmailFolderFromJson(json);
}

/// Атрибуты папки
enum FolderAttribute {
  @JsonValue('system')
  system,
  @JsonValue('read_only')
  readOnly,
  @JsonValue('subscribed')
  subscribed,
  @JsonValue('has_children')
  hasChildren,
  @JsonValue('no_inferiors')
  noInferiors,
  @JsonValue('no_select')
  noSelect,
}
