import 'dart:async';
import 'package:katya/global/print.dart';
import 'package:katya/services/protocols/messengers/messenger_bridge_service.dart';
import 'package:katya/services/protocols/messengers/models/messenger_connection.dart';
import 'package:katya/services/protocols/messengers/models/messenger_message.dart';

/// Мост для LinkedIn
class LinkedInBridge extends MessengerBridge {
  @override
  MessengerType get messengerType => MessengerType.linkedin;

  final StreamController<MessengerEvent> _eventController = StreamController<MessengerEvent>.broadcast();

  @override
  Stream<MessengerEvent> get eventStream => _eventController.stream;

  @override
  Future<void> initialize() async {
    log.info('Initializing LinkedIn bridge...');
  }

  @override
  Future<bool> connect(MessengerConnection connection) async {
    log.info('Connecting to LinkedIn for user: ${connection.username}');
    return true;
  }

  @override
  Future<void> disconnect(MessengerConnection connection) async {
    log.info('Disconnecting from LinkedIn');
  }

  @override
  Future<bool> sendMessage(MessengerMessage message) async {
    log.info('Sending LinkedIn message: ${message.content}');
    return true;
  }

  @override
  Future<List<MessengerMessage>> getMessages({
    required MessengerConnection connection,
    String? chatId,
    int limit = 50,
    DateTime? since,
  }) async {
    return [];
  }

  @override
  Future<List<MessengerChat>> getChats({
    required MessengerConnection connection,
    int limit = 100,
  }) async {
    return [];
  }

  @override
  Future<MessengerUser?> getUserInfo({
    required MessengerConnection connection,
    required String userId,
  }) async {
    return null;
  }

  @override
  Future<String?> createGroupChat({
    required MessengerConnection connection,
    required String groupName,
    required List<String> participantIds,
    String? description,
    Map<String, dynamic>? settings,
  }) async {
    return null;
  }

  @override
  void dispose() {
    _eventController.close();
  }
}
