import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:katya/store/events/model.dart';
import 'package:katya/store/rooms/room/model.dart';
import 'package:katya/verticals/messaging/models/attachment.dart';
import 'package:katya/verticals/messaging/models/chat_room.dart';
import 'package:katya/verticals/messaging/models/message.dart';
import 'package:matrix/matrix.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Core messaging functionality including message sending, receiving, and management
class MessageService {
  final Client _matrixClient;
  final String _baseUrl;
  final Map<String, StreamController<Message>> _messageStreams = {};
  final Map<String, List<Message>> _messageCache = {};
  static const int _messagesPerPage = 50;

  MessageService({required Client matrixClient, String? baseUrl})
      : _matrixClient = matrixClient,
        _baseUrl = baseUrl ?? 'https://matrix.org';

  /// Fetches messages for a room with pagination
  Future<List<Message>> getMessages({
    required String roomId,
    String? fromToken,
    int limit = _messagesPerPage,
    bool updateCache = true,
  }) async {
    try {
      final messages = await _matrixClient.getRoomMessages(
        roomId,
        from: fromToken,
        limit: limit,
      );

      final parsedMessages = messages.chunk
          .where((event) => event.type == EventTypes.Message)
          .map((event) => Message.fromMatrixEvent(event))
          .toList();

      if (updateCache) {
        _messageCache.update(
          roomId,
          (existing) => [...existing, ...parsedMessages],
          ifAbsent: () => parsedMessages,
        );
      }

      return parsedMessages;
    } catch (e) {
      throw MessagingException('Failed to fetch messages: $e');
    }
  }

  /// Sends a text message to a room
  Future<String> sendMessage({
    required String roomId,
    required String body,
    MessageType type = MessageType.text,
    String? inReplyTo,
    Map<String, dynamic>? customData,
  }) async {
    try {
      final eventId = await _matrixClient.sendMessage(
        roomId,
        type == MessageType.text ? body : '[$type]',
        customData: customData,
        inReplyTo: inReplyTo,
      );

      // Update local cache immediately
      final message = Message(
        id: eventId,
        roomId: roomId,
        senderId: _matrixClient.userID!,
        content: body,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
        type: type,
      );

      _messageCache.update(
        roomId,
        (messages) => [message, ...messages],
        ifAbsent: () => [message],
      );

      // Notify listeners
      _messageStreams[roomId]?.add(message);

      return eventId;
    } catch (e) {
      throw MessagingException('Failed to send message: $e');
    }
  }

  /// Sends a message with file attachment
  Future<String> sendAttachment({
    required String roomId,
    required File file,
    String? caption,
    String? mimeType,
  }) async {
    try {
      final fileSize = await file.length();
      final fileName = path.basename(file.path);

      final uploadResponse = await _matrixClient.uploadFile(
        file,
        filename: fileName,
        contentType: mimeType,
      );

      final content = {
        'msgtype': 'm.file',
        'body': fileName,
        'filename': fileName,
        'url': uploadResponse.contentUri.toString(),
        'info': {
          'size': fileSize,
          'mimetype': mimeType,
        },
      };

      if (caption != null) {
        content['body'] = '$caption ($fileName)';
        content['filename'] = fileName;
      }

      return await sendMessage(
        roomId: roomId,
        body: caption ?? fileName,
        type: _getMessageTypeFromMime(mimeType),
        customData: content,
      );
    } catch (e) {
      throw MessagingException('Failed to send attachment: $e');
    }
  }

  /// Edits an existing message
  Future<void> editMessage({
    required String roomId,
    required String messageId,
    required String newContent,
  }) async {
    try {
      await _matrixClient.sendEvent(
        roomId,
        EventTypes.Message,
        {
          'msgtype': 'm.text',
          'body': newContent,
          'm.new_content': {
            'msgtype': 'm.text',
            'body': newContent,
          },
          'm.relates_to': {
            'rel_type': 'm.replace',
            'event_id': messageId,
          },
        },
      );

      // Update local cache
      _messageCache.update(roomId, (messages) {
        final index = messages.indexWhere((m) => m.id == messageId);
        if (index != -1) {
          final updated = messages[index].copyWith(
            content: newContent,
            editedAt: DateTime.now(),
          );
          messages[index] = updated;
          _messageStreams[roomId]?.add(updated);
        }
        return messages;
      });
    } catch (e) {
      throw MessagingException('Failed to edit message: $e');
    }
  }

  /// Deletes a message
  Future<void> deleteMessage({
    required String roomId,
    required String messageId,
    String? reason,
  }) async {
    try {
      await _matrixClient.redactEvent(roomId, messageId, reason: reason);

      // Update local cache
      _messageCache.update(roomId, (messages) {
        messages.removeWhere((m) => m.id == messageId);
        return messages;
      });

      // Notify listeners
      _messageStreams[roomId]?.add(Message.deleted(
        id: messageId,
        roomId: roomId,
      ));
    } catch (e) {
      throw MessagingException('Failed to delete message: $e');
    }
  }

  /// Reacts to a message with an emoji
  Future<void> reactToMessage({
    required String roomId,
    required String messageId,
    required String emoji,
  }) async {
    try {
      await _matrixClient.sendEvent(
        roomId,
        'm.reaction',
        {
          'm.relates_to': {
            'rel_type': 'm.annotation',
            'event_id': messageId,
            'key': emoji,
          },
        },
      );
    } catch (e) {
      throw MessagingException('Failed to react to message: $e');
    }
  }

  /// Subscribes to message updates for a room
  Stream<Message> messageStream(String roomId) {
    _messageStreams[roomId] ??= StreamController<Message>.broadcast();
    return _messageStreams[roomId]!.stream;
  }

  /// Disposes resources for a room
  void disposeRoom(String roomId) {
    _messageStreams[roomId]?.close();
    _messageStreams.remove(roomId);
    _messageCache.remove(roomId);
  }

  // Helper method to determine message type from MIME type
  MessageType _getMessageTypeFromMime(String? mimeType) {
    if (mimeType == null) return MessageType.file;

    if (mimeType.startsWith('image/')) {
      return MessageType.image;
    } else if (mimeType.startsWith('video/')) {
      return MessageType.video;
    } else if (mimeType.startsWith('audio/')) {
      return MessageType.audio;
    } else if (mimeType == 'application/pdf') {
      return MessageType.document;
    } else {
      return MessageType.file;
    }
  }
}

/// Chat room management and operations
class ChatService {
  final Client _matrixClient;
  final Map<String, Room> _roomCache = {};
  final StreamController<Room> _roomUpdates = StreamController<Room>.broadcast();

  ChatService({required Client matrixClient}) : _matrixClient = matrixClient;

  /// Fetches all chat rooms with optional filtering
  Future<List<Room>> getChats({
    bool includeDirectMessages = true,
    bool includeGroups = true,
    bool includeSpaces = true,
    bool updateCache = true,
  }) async {
    try {
      await _matrixClient.onSync.stream.firstWhere((sync) => sync.rooms?.join != null);

      final rooms = _matrixClient.rooms.where((room) {
        if (room.isDirect && !includeDirectMessages) return false;
        if (room.isSpace && !includeSpaces) return false;
        if (!room.isDirect && !room.isSpace && !includeGroups) return false;
        return true;
      }).toList();

      if (updateCache) {
        for (final room in rooms) {
          _roomCache[room.id] = room;
        }
      }

      return rooms;
    } catch (e) {
      throw ChatException('Failed to fetch chats: $e');
    }
  }

  /// Creates a new chat room
  Future<Room> createChat({
    String? name,
    required List<String> participants,
    bool isEncrypted = true,
    bool isDirect = true,
    String? avatarUrl,
    Map<String, dynamic>? customData,
  }) async {
    try {
      final createRequest = CreateRoomRequest(
        preset: isDirect ? CreateRoomPreset.trustedPrivateChat : CreateRoomPreset.privateChat,
        name: name,
        invite: participants,
        isDirect: isDirect,
        initialState: isEncrypted
            ? [
                StateEvent(
                  type: 'm.room.encryption',
                  stateKey: '',
                  content: {'algorithm': 'm.megolm.v1.aes-sha2'},
                ),
              ]
            : null,
        powerLevelContentOverride: {
          'users': {
            _matrixClient.userID!: 100, // Set creator as admin
            for (final user in participants) user: 50, // Set participants as standard users
          },
        },
      );

      final roomId = await _matrixClient.createRoom(createRequest);
      final room = _matrixClient.getRoomById(roomId)!;

      if (avatarUrl != null) {
        await _matrixClient.setRoomAvatar(roomId, avatarUrl);
      }

      _roomCache[roomId] = room;
      _roomUpdates.add(room);

      return room;
    } catch (e) {
      throw ChatException('Failed to create chat: $e');
    }
  }

  /// Leaves a chat room
  Future<void> leaveChat(String roomId) async {
    try {
      await _matrixClient.leave(roomId);
      _roomCache.remove(roomId);
    } catch (e) {
      throw ChatException('Failed to leave chat: $e');
    }
  }

  /// Invites a user to a chat room
  Future<void> inviteToChat(String roomId, String userId) async {
    try {
      await _matrixClient.invite(roomId, userId);
    } catch (e) {
      throw ChatException('Failed to invite user: $e');
    }
  }

  /// Updates room metadata
  Future<void> updateRoomInfo({
    required String roomId,
    String? name,
    String? topic,
    String? avatarUrl,
  }) async {
    try {
      if (name != null) {
        await _matrixClient.setRoomName(roomId, name);
      }
      if (topic != null) {
        await _matrixClient.setRoomTopic(roomId, topic);
      }
      if (avatarUrl != null) {
        await _matrixClient.setRoomAvatar(roomId, avatarUrl);
      }

      // Update cache
      final room = _matrixClient.getRoomById(roomId);
      if (room != null) {
        _roomCache[roomId] = room;
        _roomUpdates.add(room);
      }
    } catch (e) {
      throw ChatException('Failed to update room info: $e');
    }
  }

  /// Subscribes to room updates
  Stream<Room> get roomUpdates => _roomUpdates.stream;

  /// Disposes resources
  void dispose() {
    _roomUpdates.close();
  }
}

/// Handles push notifications and in-app notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final Map<String, ReceivedNotification> _activeNotifications = {};
  final StreamController<ReceivedNotification> _notificationStream = StreamController<ReceivedNotification>.broadcast();

  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Initializes the notification service
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        final payload = details.payload;
        if (payload != null) {
          final notification = ReceivedNotification.fromJson(jsonDecode(payload));
          _notificationStream.add(notification);
        }
      },
    );

    // Request permissions
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();

    await _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  /// Shows a message notification
  Future<void> showMessageNotification({
    required String title,
    required String body,
    String? roomId,
    String? messageId,
    String? senderId,
    String? avatarUrl,
    NotificationImportance importance = NotificationImportance.high,
    String? channelId = 'messages',
    String? channelName = 'Messages',
  }) async {
    final notification = ReceivedNotification(
      id: messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: body,
      payload: jsonEncode({
        'type': 'message',
        'roomId': roomId,
        'messageId': messageId,
        'senderId': senderId,
      }),
      timestamp: DateTime.now(),
    );

    _activeNotifications[notification.id.toString()] = notification;

    final androidDetails = AndroidNotificationDetails(
      channelId!,
      channelName!,
      channelDescription: 'Incoming messages',
      importance: importance,
      priority: Priority.high,
      ticker: 'ticker',
      styleInformation: const MessagingStyleInformation(
        Person(
          name: title,
          icon: null,
        ),
        conversationTitle: title,
        messages: [
          AndroidNotificationMessage(
            body,
            DateTime.now(),
            Person(name: title),
          ),
        ],
      ),
    );

    final iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      notification.id,
      notification.title,
      notification.body,
      platformDetails,
      payload: notification.payload,
    );
  }

  /// Schedules a notification for a future time
  Future<void> scheduleNotification({
    required DateTime scheduledTime,
    required String title,
    required String body,
    String? payload,
    String? androidChannelId,
    String? androidChannelName,
  }) async {
    final notification = ReceivedNotification(
      id: scheduledTime.millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      payload: payload,
      timestamp: scheduledTime,
    );

    final androidDetails = AndroidNotificationDetails(
      androidChannelId ?? 'scheduled_notifications',
      androidChannelName ?? 'Scheduled Notifications',
      channelDescription: 'Scheduled notifications',
    );

    final iosDetails = const DarwinNotificationDetails();

    final platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      notification.id,
      notification.title,
      notification.body,
      scheduledTime.toLocal(),
      platformDetails,
      payload: notification.payload,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancels a scheduled notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    _activeNotifications.remove(id.toString());
  }

  /// Cancels all active notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    _activeNotifications.clear();
  }

  /// Stream of received notifications
  Stream<ReceivedNotification> get notificationStream => _notificationStream.stream;
}

/// Represents a received notification
class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String? payload;
  final DateTime timestamp;

  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    this.payload,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ReceivedNotification.fromJson(Map<String, dynamic> json) {
    return ReceivedNotification(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      payload: json['payload'] as String?,
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'payload': payload,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Custom exception for messaging-related errors
class MessagingException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  MessagingException(this.message, [this.stackTrace]);

  @override
  String toString() => 'MessagingException: $message';
}

/// Custom exception for chat-related errors
class ChatException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  ChatException(this.message, [this.stackTrace]);

  @override
  String toString() => 'ChatException: $message';
}
