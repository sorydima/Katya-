import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';

/// Сервис для анонимной коммуникации и приватных сообщений
class AnonymousMessagingService {
  static final AnonymousMessagingService _instance = AnonymousMessagingService._internal();

  // Анонимные сессии и маршрутизация
  final Map<String, AnonymousSession> _activeSessions = {};
  final Map<String, AnonymousRoute> _routingTable = {};
  final Map<String, AnonymousMessage> _messageQueue = {};

  // Криптографические ключи
  final Map<String, AnonymousKeyPair> _keyPairs = {};
  final Map<String, String> _sharedSecrets = {};

  // Конфигурация
  static const int _sessionTimeoutMinutes = 60;
  static const int _maxHops = 5;
  static const int _messageQueueLimit = 1000;
  static const int _routingTableSize = 10000;

  factory AnonymousMessagingService() => _instance;
  AnonymousMessagingService._internal();

  /// Инициализация сервиса
  Future<void> initialize() async {
    await _generateInitialKeyPairs();
    _setupPeriodicCleanup();
    _setupMessageRouting();
  }

  /// Создание анонимной сессии
  Future<AnonymousSession> createAnonymousSession({
    required String sessionId,
    required List<String> targetIdentities,
    required AnonymousSessionConfig config,
  }) async {
    // Генерируем ключи для сессии
    final keyPair = await _generateKeyPair();
    _keyPairs[sessionId] = keyPair;

    // Создаем маршруты к целям
    final routes = <String, AnonymousRoute>{};
    for (final targetId in targetIdentities) {
      routes[targetId] = await _createRoute(sessionId, targetId, config.routingStrategy);
    }

    final session = AnonymousSession(
      sessionId: sessionId,
      keyPair: keyPair,
      targetIdentities: targetIdentities,
      routes: routes,
      config: config,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(minutes: config.durationMinutes)),
      status: SessionStatus.active,
    );

    _activeSessions[sessionId] = session;
    return session;
  }

  /// Отправка анонимного сообщения
  Future<AnonymousMessageResult> sendAnonymousMessage({
    required String sessionId,
    required String targetIdentityId,
    required String content,
    required MessageType messageType,
    Map<String, dynamic>? metadata,
    bool requireDeliveryConfirmation = false,
  }) async {
    final session = _activeSessions[sessionId];
    if (session == null) {
      return const AnonymousMessageResult(
        messageId: '',
        status: MessageStatus.failed,
        errorMessage: 'Session not found',
        estimatedDeliveryTime: Duration.zero,
      );
    }

    if (session.status != SessionStatus.active) {
      return const AnonymousMessageResult(
        messageId: '',
        status: MessageStatus.failed,
        errorMessage: 'Session is not active',
        estimatedDeliveryTime: Duration.zero,
      );
    }

    try {
      // Создаем анонимное сообщение
      final message = await _createAnonymousMessage(
        session: session,
        targetIdentityId: targetIdentityId,
        content: content,
        messageType: messageType,
        metadata: metadata,
        requireDeliveryConfirmation: requireDeliveryConfirmation,
      );

      // Добавляем в очередь сообщений
      _messageQueue[message.messageId] = message;

      // Маршрутизируем сообщение
      await _routeMessage(message, session.routes[targetIdentityId]!);

      return AnonymousMessageResult(
        messageId: message.messageId,
        status: MessageStatus.sent,
        estimatedDeliveryTime: _estimateDeliveryTime(message.route),
      );
    } catch (e) {
      return AnonymousMessageResult(
        messageId: '',
        status: MessageStatus.failed,
        errorMessage: e.toString(),
        estimatedDeliveryTime: Duration.zero,
      );
    }
  }

  /// Получение анонимных сообщений
  Future<List<AnonymousMessage>> receiveAnonymousMessages({
    required String sessionId,
    int limit = 50,
    bool unreadOnly = true,
  }) async {
    final session = _activeSessions[sessionId];
    if (session == null) {
      return [];
    }

    final messages = <AnonymousMessage>[];

    for (final message in _messageQueue.values) {
      if (message.targetSessionId == sessionId) {
        if (!unreadOnly || message.status == MessageStatus.delivered) {
          messages.add(message);
        }
      }
    }

    // Сортировка по времени получения
    messages.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));

    return messages.take(limit).toList();
  }

  /// Создание анонимного канала
  Future<AnonymousChannel> createAnonymousChannel({
    required String channelId,
    required List<String> participants,
    required AnonymousChannelConfig config,
  }) async {
    // Генерируем ключи канала
    final channelKeyPair = await _generateKeyPair();

    // Создаем сессии для всех участников
    final participantSessions = <String, String>{};
    for (final participant in participants) {
      final sessionId = '${channelId}_$participant';
      await createAnonymousSession(
        sessionId: sessionId,
        targetIdentities: participants.where((p) => p != participant).toList(),
        config: AnonymousSessionConfig(
          durationMinutes: config.durationMinutes,
          routingStrategy: config.routingStrategy,
          encryptionLevel: config.encryptionLevel,
          anonymityLevel: config.anonymityLevel,
        ),
      );
      participantSessions[participant] = sessionId;
    }

    final channel = AnonymousChannel(
      channelId: channelId,
      participants: participants,
      channelKeyPair: channelKeyPair,
      participantSessions: participantSessions,
      config: config,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(minutes: config.durationMinutes)),
      status: ChannelStatus.active,
    );

    return channel;
  }

  /// Отправка сообщения в анонимный канал
  Future<AnonymousMessageResult> sendToAnonymousChannel({
    required String channelId,
    required String senderIdentityId,
    required String content,
    required MessageType messageType,
    Map<String, dynamic>? metadata,
  }) async {
    // В реальной реализации здесь будет поиск канала
    // Для демонстрации создаем заглушку
    final channel = await _findChannel(channelId);
    if (channel == null) {
      return const AnonymousMessageResult(
        messageId: '',
        status: MessageStatus.failed,
        errorMessage: 'Channel not found',
        estimatedDeliveryTime: Duration.zero,
      );
    }

    final sessionId = channel.participantSessions[senderIdentityId];
    if (sessionId == null) {
      return const AnonymousMessageResult(
        messageId: '',
        status: MessageStatus.failed,
        errorMessage: 'Sender not in channel',
        estimatedDeliveryTime: Duration.zero,
      );
    }

    // Отправляем сообщение всем участникам канала
    final results = <AnonymousMessageResult>[];
    for (final participant in channel.participants) {
      if (participant != senderIdentityId) {
        final result = await sendAnonymousMessage(
          sessionId: sessionId,
          targetIdentityId: participant,
          content: content,
          messageType: messageType,
          metadata: {
            ...?metadata,
            'channelId': channelId,
            'broadcast': true,
          },
        );
        results.add(result);
      }
    }

    // Возвращаем первый результат (все должны быть одинаковыми)
    return results.isNotEmpty
        ? results.first
        : const AnonymousMessageResult(
            messageId: '',
            status: MessageStatus.failed,
            errorMessage: 'No participants to send to',
            estimatedDeliveryTime: Duration.zero,
          );
  }

  /// Получение статистики анонимности
  Future<AnonymityStats> getAnonymityStats(String sessionId) async {
    final session = _activeSessions[sessionId];
    if (session == null) {
      return AnonymityStats(
        sessionId: sessionId,
        anonymityScore: 0.0,
        messageCount: 0,
        routeCount: 0,
        averageHops: 0.0,
        encryptionStrength: 0.0,
        timestamp: DateTime.now(),
      );
    }

    final messages = _messageQueue.values.where((m) => m.sessionId == sessionId).toList();

    final totalHops = messages.fold(0, (sum, m) => sum + m.route.length);
    final averageHops = messages.isNotEmpty ? totalHops / messages.length : 0.0;

    return AnonymityStats(
      sessionId: sessionId,
      anonymityScore: _calculateAnonymityScore(session, messages),
      messageCount: messages.length,
      routeCount: session.routes.length,
      averageHops: averageHops,
      encryptionStrength: _calculateEncryptionStrength(session.config.encryptionLevel),
      timestamp: DateTime.now(),
    );
  }

  /// Создание анонимного сообщения
  Future<AnonymousMessage> _createAnonymousMessage({
    required AnonymousSession session,
    required String targetIdentityId,
    required String content,
    required MessageType messageType,
    Map<String, dynamic>? metadata,
    required bool requireDeliveryConfirmation,
  }) async {
    final messageId = _generateMessageId();
    final route = session.routes[targetIdentityId]!;

    // Шифруем содержимое
    final encryptedContent = await _encryptContent(content, session.keyPair);

    // Создаем заголовки анонимности
    final anonymousHeaders = _createAnonymousHeaders(
      sessionId: session.sessionId,
      targetIdentityId: targetIdentityId,
      route: route,
    );

    return AnonymousMessage(
      messageId: messageId,
      sessionId: session.sessionId,
      targetSessionId: session.sessionId,
      senderIdentityId: 'anonymous',
      targetIdentityId: targetIdentityId,
      content: encryptedContent,
      originalContent: content,
      messageType: messageType,
      route: route.hops,
      anonymousHeaders: anonymousHeaders,
      metadata: metadata ?? {},
      createdAt: DateTime.now(),
      sentAt: DateTime.now(),
      receivedAt: DateTime.now(),
      status: MessageStatus.sent,
      requireDeliveryConfirmation: requireDeliveryConfirmation,
      encryptionLevel: session.config.encryptionLevel,
      anonymityLevel: session.config.anonymityLevel,
    );
  }

  /// Создание маршрута
  Future<AnonymousRoute> _createRoute(
    String sessionId,
    String targetIdentityId,
    RoutingStrategy strategy,
  ) async {
    final hops = await _generateRoute(targetIdentityId, strategy);

    final route = AnonymousRoute(
      sessionId: sessionId,
      targetIdentityId: targetIdentityId,
      hops: hops,
      strategy: strategy,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );

    _routingTable['${sessionId}_$targetIdentityId'] = route;
    return route;
  }

  /// Генерация маршрута
  Future<List<String>> _generateRoute(String targetIdentityId, RoutingStrategy strategy) async {
    final hops = <String>[];

    switch (strategy) {
      case RoutingStrategy.direct:
        hops.add(targetIdentityId);
      case RoutingStrategy.random:
        final numHops = Random().nextInt(_maxHops - 1) + 2;
        for (int i = 0; i < numHops - 1; i++) {
          hops.add(_generateRandomNodeId());
        }
        hops.add(targetIdentityId);
      case RoutingStrategy.tor:
        // Имитация Tor-подобной маршрутизации
        const numHops = 3;
        for (int i = 0; i < numHops - 1; i++) {
          hops.add(_generateRandomNodeId());
        }
        hops.add(targetIdentityId);
      case RoutingStrategy.mix:
        // Имитация mix-сетей
        final numHops = Random().nextInt(4) + 3;
        for (int i = 0; i < numHops - 1; i++) {
          hops.add(_generateRandomNodeId());
        }
        hops.add(targetIdentityId);
    }

    return hops;
  }

  /// Маршрутизация сообщения
  Future<void> _routeMessage(AnonymousMessage message, AnonymousRoute route) async {
    // В реальной реализации здесь будет отправка через промежуточные узлы
    // Для демонстрации просто обновляем статус
    // Создаем новый объект с обновленным статусом
    final updatedMessage = AnonymousMessage(
      messageId: message.messageId,
      sessionId: message.sessionId,
      targetSessionId: message.targetSessionId,
      senderIdentityId: message.senderIdentityId,
      targetIdentityId: message.targetIdentityId,
      content: message.content,
      originalContent: message.originalContent,
      messageType: message.messageType,
      route: message.route,
      anonymousHeaders: message.anonymousHeaders,
      metadata: message.metadata,
      createdAt: message.createdAt,
      sentAt: message.sentAt,
      receivedAt: DateTime.now(),
      status: MessageStatus.delivered,
      requireDeliveryConfirmation: message.requireDeliveryConfirmation,
      encryptionLevel: message.encryptionLevel,
      anonymityLevel: message.anonymityLevel,
    );

    _messageQueue[message.messageId] = updatedMessage;
  }

  /// Генерация начальных ключевых пар
  Future<void> _generateInitialKeyPairs() async {
    // Генерируем несколько ключевых пар для демонстрации
    for (int i = 0; i < 10; i++) {
      final keyPair = await _generateKeyPair();
      _keyPairs['initial_$i'] = keyPair;
    }
  }

  /// Генерация ключевой пары
  Future<AnonymousKeyPair> _generateKeyPair() async {
    // В реальной реализации здесь будет криптографическая генерация ключей
    // Для демонстрации создаем заглушки
    return AnonymousKeyPair(
      publicKey: 'pub_${_generateRandomString(32)}',
      privateKey: 'priv_${_generateRandomString(32)}',
      keyId: _generateRandomString(16),
      algorithm: 'ed25519',
      createdAt: DateTime.now(),
    );
  }

  /// Шифрование содержимого
  Future<String> _encryptContent(String content, AnonymousKeyPair keyPair) async {
    // В реальной реализации здесь будет криптографическое шифрование
    // Для демонстрации просто кодируем в base64
    final bytes = utf8.encode(content);
    return base64.encode(bytes);
  }

  /// Создание заголовков анонимности
  Map<String, dynamic> _createAnonymousHeaders({
    required String sessionId,
    required String targetIdentityId,
    required AnonymousRoute route,
  }) {
    return {
      'sessionId': sessionId,
      'targetIdentityId': targetIdentityId,
      'routeHash': _hashRoute(route.hops),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'nonce': _generateRandomString(16),
    };
  }

  /// Поиск канала
  Future<AnonymousChannel?> _findChannel(String channelId) async {
    // В реальной реализации здесь будет поиск в базе данных
    // Для демонстрации возвращаем null
    return null;
  }

  /// Расчет скора анонимности
  double _calculateAnonymityScore(AnonymousSession session, List<AnonymousMessage> messages) {
    double score = 0.0;

    // Базовый скор от конфигурации
    score += session.config.anonymityLevel.index / 4.0 * 0.3;

    // Скор от количества хопов
    if (messages.isNotEmpty) {
      final avgHops = messages.fold(0, (sum, m) => sum + m.route.length) / messages.length;
      score += min(1.0, avgHops / _maxHops) * 0.4;
    }

    // Скор от разнообразия маршрутов
    final uniqueRoutes = messages.map((m) => m.route.join(',')).toSet().length;
    score += min(1.0, uniqueRoutes / 10.0) * 0.3;

    return min(1.0, score);
  }

  /// Расчет силы шифрования
  double _calculateEncryptionStrength(EncryptionLevel level) {
    switch (level) {
      case EncryptionLevel.none:
        return 0.0;
      case EncryptionLevel.basic:
        return 0.3;
      case EncryptionLevel.standard:
        return 0.6;
      case EncryptionLevel.high:
        return 0.8;
      case EncryptionLevel.military:
        return 1.0;
    }
  }

  /// Настройка периодической очистки
  void _setupPeriodicCleanup() {
    Timer.periodic(const Duration(minutes: 5), (timer) async {
      await _performPeriodicCleanup();
    });
  }

  /// Периодическая очистка
  Future<void> _performPeriodicCleanup() async {
    final now = DateTime.now();

    // Очистка истекших сессий
    final expiredSessions = <String>[];
    for (final entry in _activeSessions.entries) {
      if (now.isAfter(entry.value.expiresAt)) {
        expiredSessions.add(entry.key);
      }
    }

    for (final sessionId in expiredSessions) {
      _activeSessions.remove(sessionId);
      _keyPairs.remove(sessionId);
    }

    // Очистка старых сообщений
    if (_messageQueue.length > _messageQueueLimit) {
      final sortedMessages = _messageQueue.entries.toList()
        ..sort((a, b) => a.value.createdAt.compareTo(b.value.createdAt));

      final toRemove = sortedMessages.take(_messageQueue.length - _messageQueueLimit);
      for (final entry in toRemove) {
        _messageQueue.remove(entry.key);
      }
    }
  }

  /// Настройка маршрутизации сообщений
  void _setupMessageRouting() {
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      await _processMessageQueue();
    });
  }

  /// Обработка очереди сообщений
  Future<void> _processMessageQueue() async {
    final pendingMessages = _messageQueue.values.where((m) => m.status == MessageStatus.sent).toList();

    for (final message in pendingMessages) {
      // Имитация обработки сообщения
      if (Random().nextDouble() > 0.1) {
        // 90% успешной доставки
        final updatedMessage = AnonymousMessage(
          messageId: message.messageId,
          sessionId: message.sessionId,
          targetSessionId: message.targetSessionId,
          senderIdentityId: message.senderIdentityId,
          targetIdentityId: message.targetIdentityId,
          content: message.content,
          originalContent: message.originalContent,
          messageType: message.messageType,
          route: message.route,
          anonymousHeaders: message.anonymousHeaders,
          metadata: message.metadata,
          createdAt: message.createdAt,
          sentAt: message.sentAt,
          receivedAt: DateTime.now(),
          status: MessageStatus.delivered,
          requireDeliveryConfirmation: message.requireDeliveryConfirmation,
          encryptionLevel: message.encryptionLevel,
          anonymityLevel: message.anonymityLevel,
        );

        _messageQueue[message.messageId] = updatedMessage;
      }
    }
  }

  /// Генерация ID сообщения
  String _generateMessageId() {
    return 'msg_${_generateRandomString(16)}';
  }

  /// Генерация случайного ID узла
  String _generateRandomNodeId() {
    return 'node_${_generateRandomString(12)}';
  }

  /// Генерация случайной строки
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(Random().nextInt(chars.length))),
    );
  }

  /// Хеширование маршрута
  String _hashRoute(List<String> route) {
    final routeString = route.join(',');
    final bytes = utf8.encode(routeString);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Оценка времени доставки
  Duration _estimateDeliveryTime(List<String> route) {
    // Простая оценка на основе количества хопов
    const baseTime = Duration(seconds: 2);
    return baseTime * route.length;
  }

  /// Освобождение ресурсов
  void dispose() {
    _activeSessions.clear();
    _routingTable.clear();
    _messageQueue.clear();
    _keyPairs.clear();
    _sharedSecrets.clear();
  }
}

/// Анонимная сессия
class AnonymousSession extends Equatable {
  final String sessionId;
  final AnonymousKeyPair keyPair;
  final List<String> targetIdentities;
  final Map<String, AnonymousRoute> routes;
  final AnonymousSessionConfig config;
  final DateTime createdAt;
  final DateTime expiresAt;
  final SessionStatus status;

  const AnonymousSession({
    required this.sessionId,
    required this.keyPair,
    required this.targetIdentities,
    required this.routes,
    required this.config,
    required this.createdAt,
    required this.expiresAt,
    required this.status,
  });

  @override
  List<Object?> get props => [sessionId, keyPair, targetIdentities, routes, config, createdAt, expiresAt, status];
}

/// Конфигурация анонимной сессии
class AnonymousSessionConfig extends Equatable {
  final int durationMinutes;
  final RoutingStrategy routingStrategy;
  final EncryptionLevel encryptionLevel;
  final AnonymityLevel anonymityLevel;

  const AnonymousSessionConfig({
    required this.durationMinutes,
    required this.routingStrategy,
    required this.encryptionLevel,
    required this.anonymityLevel,
  });

  @override
  List<Object?> get props => [durationMinutes, routingStrategy, encryptionLevel, anonymityLevel];
}

/// Стратегии маршрутизации
enum RoutingStrategy {
  direct,
  random,
  tor,
  mix,
}

/// Уровни шифрования
enum EncryptionLevel {
  none,
  basic,
  standard,
  high,
  military,
}

/// Уровни анонимности
enum AnonymityLevel {
  low,
  medium,
  high,
  maximum,
}

/// Статусы сессий
enum SessionStatus {
  active,
  paused,
  expired,
  terminated,
}

/// Анонимное сообщение
class AnonymousMessage extends Equatable {
  final String messageId;
  final String sessionId;
  final String targetSessionId;
  final String senderIdentityId;
  final String targetIdentityId;
  final String content;
  final String originalContent;
  final MessageType messageType;
  final List<String> route;
  final Map<String, dynamic> anonymousHeaders;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime sentAt;
  final DateTime receivedAt;
  final MessageStatus status;
  final bool requireDeliveryConfirmation;
  final EncryptionLevel encryptionLevel;
  final AnonymityLevel anonymityLevel;

  const AnonymousMessage({
    required this.messageId,
    required this.sessionId,
    required this.targetSessionId,
    required this.senderIdentityId,
    required this.targetIdentityId,
    required this.content,
    required this.originalContent,
    required this.messageType,
    required this.route,
    required this.anonymousHeaders,
    required this.metadata,
    required this.createdAt,
    required this.sentAt,
    required this.receivedAt,
    required this.status,
    required this.requireDeliveryConfirmation,
    required this.encryptionLevel,
    required this.anonymityLevel,
  });

  @override
  List<Object?> get props => [
        messageId,
        sessionId,
        targetSessionId,
        senderIdentityId,
        targetIdentityId,
        content,
        originalContent,
        messageType,
        route,
        anonymousHeaders,
        metadata,
        createdAt,
        sentAt,
        receivedAt,
        status,
        requireDeliveryConfirmation,
        encryptionLevel,
        anonymityLevel,
      ];
}

/// Типы сообщений
enum MessageType {
  text,
  file,
  image,
  audio,
  video,
  system,
}

/// Статусы сообщений
enum MessageStatus {
  created,
  sent,
  delivered,
  read,
  failed,
}

/// Результат отправки анонимного сообщения
class AnonymousMessageResult extends Equatable {
  final String messageId;
  final MessageStatus status;
  final String? errorMessage;
  final Duration estimatedDeliveryTime;

  const AnonymousMessageResult({
    required this.messageId,
    required this.status,
    this.errorMessage,
    required this.estimatedDeliveryTime,
  });

  @override
  List<Object?> get props => [messageId, status, errorMessage, estimatedDeliveryTime];
}

/// Анонимный маршрут
class AnonymousRoute extends Equatable {
  final String sessionId;
  final String targetIdentityId;
  final List<String> hops;
  final RoutingStrategy strategy;
  final DateTime createdAt;
  final DateTime expiresAt;

  const AnonymousRoute({
    required this.sessionId,
    required this.targetIdentityId,
    required this.hops,
    required this.strategy,
    required this.createdAt,
    required this.expiresAt,
  });

  @override
  List<Object?> get props => [sessionId, targetIdentityId, hops, strategy, createdAt, expiresAt];
}

/// Анонимный канал
class AnonymousChannel extends Equatable {
  final String channelId;
  final List<String> participants;
  final AnonymousKeyPair channelKeyPair;
  final Map<String, String> participantSessions;
  final AnonymousChannelConfig config;
  final DateTime createdAt;
  final DateTime expiresAt;
  final ChannelStatus status;

  const AnonymousChannel({
    required this.channelId,
    required this.participants,
    required this.channelKeyPair,
    required this.participantSessions,
    required this.config,
    required this.createdAt,
    required this.expiresAt,
    required this.status,
  });

  @override
  List<Object?> get props =>
      [channelId, participants, channelKeyPair, participantSessions, config, createdAt, expiresAt, status];
}

/// Конфигурация анонимного канала
class AnonymousChannelConfig extends Equatable {
  final int durationMinutes;
  final RoutingStrategy routingStrategy;
  final EncryptionLevel encryptionLevel;
  final AnonymityLevel anonymityLevel;
  final bool allowAnonymousParticipants;

  const AnonymousChannelConfig({
    required this.durationMinutes,
    required this.routingStrategy,
    required this.encryptionLevel,
    required this.anonymityLevel,
    required this.allowAnonymousParticipants,
  });

  @override
  List<Object?> get props =>
      [durationMinutes, routingStrategy, encryptionLevel, anonymityLevel, allowAnonymousParticipants];
}

/// Статусы каналов
enum ChannelStatus {
  active,
  paused,
  expired,
  closed,
}

/// Ключевая пара для анонимности
class AnonymousKeyPair extends Equatable {
  final String publicKey;
  final String privateKey;
  final String keyId;
  final String algorithm;
  final DateTime createdAt;

  const AnonymousKeyPair({
    required this.publicKey,
    required this.privateKey,
    required this.keyId,
    required this.algorithm,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [publicKey, privateKey, keyId, algorithm, createdAt];
}

/// Статистика анонимности
class AnonymityStats extends Equatable {
  final String sessionId;
  final double anonymityScore;
  final int messageCount;
  final int routeCount;
  final double averageHops;
  final double encryptionStrength;
  final DateTime timestamp;

  const AnonymityStats({
    required this.sessionId,
    required this.anonymityScore,
    required this.messageCount,
    required this.routeCount,
    required this.averageHops,
    required this.encryptionStrength,
    required this.timestamp,
  });

  @override
  List<Object?> get props =>
      [sessionId, anonymityScore, messageCount, routeCount, averageHops, encryptionStrength, timestamp];
}
