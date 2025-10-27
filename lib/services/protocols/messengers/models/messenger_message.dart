import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:katya/services/protocols/messengers/messenger_bridge_service.dart';

part 'messenger_message.g.dart';

/// Модель сообщения мессенджера
@JsonSerializable()
class MessengerMessage extends Equatable {
  /// Уникальный идентификатор сообщения
  final String id;

  /// ID подключения
  final String connectionId;

  /// ID отправителя
  final String senderId;

  /// ID получателя
  final String recipientId;

  /// ID чата (для групповых сообщений)
  final String? chatId;

  /// Содержимое сообщения
  final String content;

  /// Тип сообщения
  final MessageType messageType;

  /// Вложения
  final Map<String, dynamic> attachments;

  /// Метаданные
  final Map<String, dynamic> metadata;

  /// Временная метка
  final DateTime timestamp;

  /// Статус сообщения
  final MessageStatus status;

  /// Ответ на сообщение
  final String? replyTo;

  /// Пересылаемое сообщение
  final String? forwardedFrom;

  /// Редактировано ли сообщение
  final bool isEdited;

  /// Время редактирования
  final DateTime? editedAt;

  /// Удалено ли сообщение
  final bool isDeleted;

  /// Время удаления
  final DateTime? deletedAt;

  /// Зашифровано ли сообщение
  final bool isEncrypted;

  /// Подписано ли сообщение
  final bool isSigned;

  /// Приоритет сообщения
  final MessagePriority priority;

  /// Тема сообщения (для email-подобных сообщений)
  final String? subject;

  const MessengerMessage({
    required this.id,
    required this.connectionId,
    required this.senderId,
    required this.recipientId,
    this.chatId,
    required this.content,
    required this.messageType,
    this.attachments = const {},
    this.metadata = const {},
    required this.timestamp,
    this.status = MessageStatus.sending,
    this.replyTo,
    this.forwardedFrom,
    this.isEdited = false,
    this.editedAt,
    this.isDeleted = false,
    this.deletedAt,
    this.isEncrypted = false,
    this.isSigned = false,
    this.priority = MessagePriority.normal,
    this.subject,
  });

  @override
  List<Object?> get props => [
        id,
        connectionId,
        senderId,
        recipientId,
        chatId,
        content,
        messageType,
        attachments,
        metadata,
        timestamp,
        status,
        replyTo,
        forwardedFrom,
        isEdited,
        editedAt,
        isDeleted,
        deletedAt,
        isEncrypted,
        isSigned,
        priority,
        subject,
      ];

  MessengerMessage copyWith({
    String? id,
    String? connectionId,
    String? senderId,
    String? recipientId,
    String? chatId,
    String? content,
    MessageType? messageType,
    Map<String, dynamic>? attachments,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
    MessageStatus? status,
    String? replyTo,
    String? forwardedFrom,
    bool? isEdited,
    DateTime? editedAt,
    bool? isDeleted,
    DateTime? deletedAt,
    bool? isEncrypted,
    bool? isSigned,
    MessagePriority? priority,
    String? subject,
  }) {
    return MessengerMessage(
      id: id ?? this.id,
      connectionId: connectionId ?? this.connectionId,
      senderId: senderId ?? this.senderId,
      recipientId: recipientId ?? this.recipientId,
      chatId: chatId ?? this.chatId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      replyTo: replyTo ?? this.replyTo,
      forwardedFrom: forwardedFrom ?? this.forwardedFrom,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      isSigned: isSigned ?? this.isSigned,
      priority: priority ?? this.priority,
      subject: subject ?? this.subject,
    );
  }

  /// Проверка, является ли сообщение текстовым
  bool get isText => messageType == MessageType.text;

  /// Проверка, является ли сообщение медиа
  bool get isMedia => [
        MessageType.image,
        MessageType.video,
        MessageType.audio,
        MessageType.voice,
        MessageType.sticker,
        MessageType.gif,
      ].contains(messageType);

  /// Проверка, является ли сообщение файлом
  bool get isFile => [
        MessageType.file,
        MessageType.document,
      ].contains(messageType);

  /// Проверка, является ли сообщение отправленным
  bool get isSent => status == MessageStatus.sent;

  /// Проверка, является ли сообщение доставленным
  bool get isDelivered => status == MessageStatus.delivered;

  /// Проверка, является ли сообщение прочитанным
  bool get isRead => status == MessageStatus.read;

  /// Проверка, является ли сообщение неудачным
  bool get isFailed => status == MessageStatus.failed;

  /// Проверка, имеет ли сообщение вложения
  bool get hasAttachments => attachments.isNotEmpty;

  /// Проверка, является ли сообщение ответом
  bool get isReply => replyTo != null;

  /// Проверка, является ли сообщение пересылкой
  bool get isForwarded => forwardedFrom != null;

  /// Получение размера сообщения в байтах
  int get size {
    int baseSize = content.length * 2; // Примерная оценка для UTF-8

    // Добавляем размер вложений
    for (final attachment in attachments.values) {
      if (attachment is Map<String, dynamic>) {
        baseSize += attachment['size'] as int? ?? 0;
      }
    }

    return baseSize;
  }

  /// Получение размера в человекочитаемом формате
  String get formattedSize {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
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

  /// Получение краткого предварительного просмотра
  String get preview {
    if (isText) {
      final preview = content.length > 100 ? '${content.substring(0, 100)}...' : content;
      return preview.replaceAll(RegExp(r'\s+'), ' ').trim();
    } else {
      switch (messageType) {
        case MessageType.image:
          return '📷 Image';
        case MessageType.video:
          return '🎥 Video';
        case MessageType.audio:
          return '🎵 Audio';
        case MessageType.voice:
          return '🎤 Voice message';
        case MessageType.file:
          return '📄 File';
        case MessageType.document:
          return '📋 Document';
        case MessageType.sticker:
          return '😀 Sticker';
        case MessageType.gif:
          return '🎬 GIF';
        case MessageType.location:
          return '📍 Location';
        case MessageType.contact:
          return '👤 Contact';
        default:
          return 'Message';
      }
    }
  }

  /// Получение уровня приоритета в виде строки
  String get priorityString {
    switch (priority) {
      case MessagePriority.low:
        return 'Low';
      case MessagePriority.normal:
        return 'Normal';
      case MessagePriority.high:
        return 'High';
      case MessagePriority.urgent:
        return 'Urgent';
    }
  }

  Map<String, dynamic> toJson() => _$MessengerMessageToJson(this);
  factory MessengerMessage.fromJson(Map<String, dynamic> json) => _$MessengerMessageFromJson(json);
}

/// Приоритет сообщения
enum MessagePriority {
  @JsonValue('low')
  low,
  @JsonValue('normal')
  normal,
  @JsonValue('high')
  high,
  @JsonValue('urgent')
  urgent,
}

/// Вложение сообщения
@JsonSerializable()
class MessageAttachment extends Equatable {
  /// Идентификатор вложения
  final String id;

  /// Имя файла
  final String filename;

  /// MIME тип
  final String mimeType;

  /// Размер в байтах
  final int size;

  /// URL вложения
  final String? url;

  /// Локальный путь к файлу
  final String? localPath;

  /// Данные вложения
  @JsonKey(ignore: true)
  final List<int>? data;

  /// Ширина (для изображений/видео)
  final int? width;

  /// Высота (для изображений/видео)
  final int? height;

  /// Длительность (для аудио/видео)
  final Duration? duration;

  /// Зашифровано ли вложение
  final bool isEncrypted;

  /// Подписано ли вложение
  final bool isSigned;

  /// Метаданные
  final Map<String, dynamic> metadata;

  const MessageAttachment({
    required this.id,
    required this.filename,
    required this.mimeType,
    required this.size,
    this.url,
    this.localPath,
    this.data,
    this.width,
    this.height,
    this.duration,
    this.isEncrypted = false,
    this.isSigned = false,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
        id,
        filename,
        mimeType,
        size,
        url,
        localPath,
        data,
        width,
        height,
        duration,
        isEncrypted,
        isSigned,
        metadata,
      ];

  MessageAttachment copyWith({
    String? id,
    String? filename,
    String? mimeType,
    int? size,
    String? url,
    String? localPath,
    List<int>? data,
    int? width,
    int? height,
    Duration? duration,
    bool? isEncrypted,
    bool? isSigned,
    Map<String, dynamic>? metadata,
  }) {
    return MessageAttachment(
      id: id ?? this.id,
      filename: filename ?? this.filename,
      mimeType: mimeType ?? this.mimeType,
      size: size ?? this.size,
      url: url ?? this.url,
      localPath: localPath ?? this.localPath,
      data: data ?? this.data,
      width: width ?? this.width,
      height: height ?? this.height,
      duration: duration ?? this.duration,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      isSigned: isSigned ?? this.isSigned,
      metadata: metadata ?? this.metadata,
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

  /// Проверка, является ли вложение видео
  bool get isVideo {
    return mimeType.startsWith('video/');
  }

  /// Проверка, является ли вложение аудио
  bool get isAudio {
    return mimeType.startsWith('audio/');
  }

  /// Проверка, является ли вложение документом
  bool get isDocument {
    return mimeType.startsWith('application/') && ['pdf', 'doc', 'docx', 'txt', 'rtf'].contains(extension);
  }

  /// Получение размера в человекочитаемом формате
  String get formattedSize {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  /// Получение длительности в читаемом формате
  String? get formattedDuration {
    if (duration == null) return null;

    final minutes = duration!.inMinutes;
    final seconds = duration!.inSeconds % 60;

    if (minutes > 0) {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '0:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Получение разрешения (для изображений/видео)
  String? get resolution {
    if (width != null && height != null) {
      return '${width}x$height';
    }
    return null;
  }

  Map<String, dynamic> toJson() => _$MessageAttachmentToJson(this);
  factory MessageAttachment.fromJson(Map<String, dynamic> json) => _$MessageAttachmentFromJson(json);
}
