import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';

/// Утилиты для тестирования системы Katya
class TestUtilities {
  static final TestUtilities _instance = TestUtilities._instance;

  // Генераторы данных
  final Map<String, DataGenerator> _dataGenerators = {};
  final Map<String, MockService> _mockServices = {};
  final Map<String, TestHelper> _testHelpers = {};

  factory TestUtilities() => _instance;
  TestUtilities._internal();

  /// Инициализация утилит тестирования
  Future<void> initialize() async {
    await _initializeDataGenerators();
    await _initializeMockServices();
    await _initializeTestHelpers();
  }

  /// Генерация тестовых данных пользователя
  TestUser generateTestUser({String? id, Map<String, dynamic>? overrides}) {
    final userId = id ?? _generateId();
    final baseData = {
      'id': userId,
      'username': 'testuser_${_generateRandomString(8)}',
      'email': 'test_${_generateRandomString(6)}@example.com',
      'firstName': _generateRandomName(),
      'lastName': _generateRandomName(),
      'createdAt': DateTime.now().toIso8601String(),
      'isActive': true,
      'profile': {
        'avatar': 'https://example.com/avatars/$userId.png',
        'bio': 'Test user profile',
        'location': _generateRandomCity(),
        'timezone': 'UTC',
      },
      'preferences': {
        'theme': 'light',
        'language': 'en',
        'notifications': true,
      },
      'statistics': {
        'reputation': Random().nextInt(1000),
        'posts': Random().nextInt(100),
        'followers': Random().nextInt(500),
        'following': Random().nextInt(200),
      },
    };

    return TestUser.fromMap({...baseData, ...?overrides});
  }

  /// Генерация тестового сообщения
  TestMessage generateTestMessage({
    String? id,
    String? roomId,
    String? userId,
    MessageType type = MessageType.text,
    Map<String, dynamic>? overrides,
  }) {
    final messageId = id ?? _generateId();
    final roomIdValue = roomId ?? 'room_${_generateId()}';
    final userIdValue = userId ?? 'user_${_generateId()}';

    final baseData = {
      'id': messageId,
      'roomId': roomIdValue,
      'userId': userIdValue,
      'type': type.name,
      'content': _generateMessageContent(type),
      'timestamp': DateTime.now().toIso8601String(),
      'edited': false,
      'deleted': false,
      'metadata': {
        'client': 'test_client',
        'version': '1.0.0',
        'platform': 'test',
      },
      'reactions': [],
      'thread': null,
    };

    return TestMessage.fromMap({...baseData, ...?overrides});
  }

  /// Генерация тестовой комнаты
  TestRoom generateTestRoom({
    String? id,
    String? name,
    RoomType type = RoomType.private,
    List<String>? members,
    Map<String, dynamic>? overrides,
  }) {
    final roomId = id ?? _generateId();
    final roomName = name ?? 'Test Room ${_generateRandomString(6)}';
    final roomMembers = members ?? ['user_1', 'user_2', 'user_3'];

    final baseData = {
      'id': roomId,
      'name': roomName,
      'type': type.name,
      'description': 'Test room description',
      'createdAt': DateTime.now().toIso8601String(),
      'createdBy': roomMembers.first,
      'members': roomMembers,
      'admins': [roomMembers.first],
      'settings': {
        'encryption': true,
        'moderation': true,
        'history': true,
        'guestAccess': false,
      },
      'statistics': {
        'messageCount': Random().nextInt(1000),
        'memberCount': roomMembers.length,
        'lastActivity': DateTime.now().toIso8601String(),
      },
    };

    return TestRoom.fromMap({...baseData, ...?overrides});
  }

  /// Генерация тестовых данных репутации
  TestReputation generateTestReputation({
    String? identityId,
    double? score,
    Map<String, dynamic>? overrides,
  }) {
    final id = identityId ?? _generateId();
    final reputationScore = score ?? Random().nextDouble();

    final baseData = {
      'identityId': id,
      'score': reputationScore,
      'level': _determineReputationLevel(reputationScore),
      'factors': {
        'interaction_count': Random().nextInt(1000),
        'response_time': Random().nextDouble() * 5.0,
        'quality_score': Random().nextDouble(),
        'verification_level': Random().nextInt(5),
      },
      'lastUpdated': DateTime.now().toIso8601String(),
      'history': _generateReputationHistory(),
    };

    return TestReputation.fromMap({...baseData, ...?overrides});
  }

  /// Генерация тестовых данных блокчейна
  TestBlockchainData generateTestBlockchainData({
    String? transactionId,
    String? blockNumber,
    Map<String, dynamic>? overrides,
  }) {
    final txId = transactionId ?? _generateBlockchainId();
    final block = blockNumber ?? Random().nextInt(1000000).toString();

    final baseData = {
      'transactionId': txId,
      'blockNumber': block,
      'blockHash': _generateBlockchainId(),
      'from': _generateBlockchainAddress(),
      'to': _generateBlockchainAddress(),
      'value': Random().nextInt(1000000),
      'gasUsed': Random().nextInt(100000),
      'gasPrice': Random().nextInt(100),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'status': 'success',
      'confirmations': Random().nextInt(12) + 1,
    };

    return TestBlockchainData.fromMap({...baseData, ...?overrides});
  }

  /// Создание мок-сервиса
  MockService createMockService(
    String name, {
    Map<String, dynamic>? defaultResponses,
    Duration? responseDelay,
  }) {
    final service = MockService(
      name: name,
      defaultResponses: defaultResponses ?? {},
      responseDelay: responseDelay ?? const Duration(milliseconds: 10),
      callHistory: const [],
      createdAt: DateTime.now(),
    );

    _mockServices[name] = service;
    return service;
  }

  /// Создание тестового помощника
  TestHelper createTestHelper(String name, TestHelperFunction function) {
    final helper = TestHelper(
      name: name,
      function: function,
      usageCount: 0,
      createdAt: DateTime.now(),
    );

    _testHelpers[name] = helper;
    return helper;
  }

  /// Ожидание условия
  Future<void> waitForCondition(
    Future<bool> Function() condition, {
    Duration timeout = const Duration(seconds: 30),
    Duration interval = const Duration(milliseconds: 100),
  }) async {
    final endTime = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(endTime)) {
      if (await condition()) {
        return;
      }
      await Future.delayed(interval);
    }

    throw TimeoutException('Condition not met within timeout', timeout);
  }

  /// Ожидание асинхронной операции
  Future<T> waitForAsyncOperation<T>(
    Future<T> Function() operation, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      return await operation().timeout(timeout);
    } on TimeoutException {
      throw TimeoutException('Async operation timed out', timeout);
    }
  }

  /// Создание тестовой базы данных
  Future<TestDatabase> createTestDatabase({
    String? name,
    List<TestTable>? tables,
  }) async {
    final dbName = name ?? 'test_db_${_generateId()}';
    final dbTables = tables ?? _createDefaultTables();

    final database = TestDatabase(
      name: dbName,
      tables: dbTables,
      isInitialized: false,
      createdAt: DateTime.now(),
    );

    // Имитация инициализации
    await Future.delayed(const Duration(milliseconds: 100));
    database.isInitialized = true;

    return database;
  }

  /// Заполнение тестовыми данными
  Future<void> populateTestData(
    TestDatabase database, {
    int userCount = 100,
    int roomCount = 50,
    int messageCount = 1000,
  }) async {
    if (!database.isInitialized) {
      throw Exception('Database not initialized');
    }

    // Генерируем пользователей
    for (int i = 0; i < userCount; i++) {
      final user = generateTestUser();
      await _insertUser(database, user);
    }

    // Генерируем комнаты
    for (int i = 0; i < roomCount; i++) {
      final room = generateTestRoom();
      await _insertRoom(database, room);
    }

    // Генерируем сообщения
    for (int i = 0; i < messageCount; i++) {
      final message = generateTestMessage();
      await _insertMessage(database, message);
    }
  }

  /// Очистка тестовых данных
  Future<void> cleanupTestData(TestDatabase database) async {
    if (!database.isInitialized) {
      return;
    }

    // Очищаем все таблицы
    for (final table in database.tables) {
      await _clearTable(database, table);
    }
  }

  /// Проверка состояния системы
  Future<SystemState> checkSystemState() async {
    return SystemState(
      timestamp: DateTime.now(),
      services: {
        'database': await _checkServiceHealth('database'),
        'cache': await _checkServiceHealth('cache'),
        'api': await _checkServiceHealth('api'),
        'websocket': await _checkServiceHealth('websocket'),
      },
      metrics: {
        'cpu_usage': Random().nextDouble() * 100,
        'memory_usage': Random().nextInt(8192),
        'disk_usage': Random().nextDouble() * 100,
        'network_io': Random().nextInt(1000000),
      },
    );
  }

  /// Создание тестового HTTP клиента
  TestHttpClient createTestHttpClient({
    Map<String, TestHttpResponse>? responses,
    Duration? defaultDelay,
  }) {
    return TestHttpClient(
      responses: responses ?? {},
      defaultDelay: defaultDelay ?? const Duration(milliseconds: 50),
      requestHistory: const [],
      createdAt: DateTime.now(),
    );
  }

  /// Создание тестового WebSocket клиента
  TestWebSocketClient createTestWebSocketClient({
    List<String>? messages,
    Duration? messageDelay,
  }) {
    return TestWebSocketClient(
      messages: messages ?? [],
      messageDelay: messageDelay ?? const Duration(milliseconds: 100),
      connectionHistory: const [],
      createdAt: DateTime.now(),
    );
  }

  /// Генерация случайного контента сообщения
  String _generateMessageContent(MessageType type) {
    switch (type) {
      case MessageType.text:
        return _generateRandomText();
      case MessageType.image:
        return 'https://example.com/images/${_generateRandomString(10)}.jpg';
      case MessageType.file:
        return 'https://example.com/files/${_generateRandomString(10)}.pdf';
      case MessageType.audio:
        return 'https://example.com/audio/${_generateRandomString(10)}.mp3';
      case MessageType.video:
        return 'https://example.com/videos/${_generateRandomString(10)}.mp4';
      case MessageType.location:
        return '${Random().nextDouble() * 180 - 90},${Random().nextDouble() * 360 - 180}';
    }
  }

  /// Определение уровня репутации
  String _determineReputationLevel(double score) {
    if (score >= 0.9) return 'excellent';
    if (score >= 0.7) return 'high';
    if (score >= 0.5) return 'medium';
    if (score >= 0.3) return 'low';
    return 'poor';
  }

  /// Генерация истории репутации
  List<Map<String, dynamic>> _generateReputationHistory() {
    final history = <Map<String, dynamic>>[];
    final count = Random().nextInt(10) + 5;

    for (int i = 0; i < count; i++) {
      history.add({
        'score': Random().nextDouble(),
        'timestamp': DateTime.now().subtract(Duration(days: i)).toIso8601String(),
        'reason': _generateRandomReason(),
      });
    }

    return history;
  }

  /// Создание таблиц по умолчанию
  List<TestTable> _createDefaultTables() {
    return [
      const TestTable(
        name: 'users',
        columns: ['id', 'username', 'email', 'created_at'],
        indexes: ['id', 'username', 'email'],
      ),
      const TestTable(
        name: 'rooms',
        columns: ['id', 'name', 'type', 'created_at'],
        indexes: ['id', 'name'],
      ),
      const TestTable(
        name: 'messages',
        columns: ['id', 'room_id', 'user_id', 'content', 'timestamp'],
        indexes: ['id', 'room_id', 'user_id', 'timestamp'],
      ),
    ];
  }

  /// Инициализация генераторов данных
  Future<void> _initializeDataGenerators() async {
    _dataGenerators['user'] = DataGenerator(
      name: 'user',
      template: TestUser.empty().toMap(),
      createdAt: DateTime.now(),
    );

    _dataGenerators['message'] = DataGenerator(
      name: 'message',
      template: TestMessage.empty().toMap(),
      createdAt: DateTime.now(),
    );

    _dataGenerators['room'] = DataGenerator(
      name: 'room',
      template: TestRoom.empty().toMap(),
      createdAt: DateTime.now(),
    );
  }

  /// Инициализация мок-сервисов
  Future<void> _initializeMockServices() async {
    createMockService('api', defaultResponses: {
      'GET /users': {'status': 200, 'data': []},
      'POST /users': {'status': 201, 'data': {}},
      'GET /rooms': {'status': 200, 'data': []},
      'POST /messages': {'status': 201, 'data': {}},
    });

    createMockService('database', defaultResponses: {
      'query': {'success': true, 'data': []},
      'insert': {'success': true, 'id': _generateId()},
      'update': {'success': true, 'affected': 1},
      'delete': {'success': true, 'affected': 1},
    });
  }

  /// Инициализация тестовых помощников
  Future<void> _initializeTestHelpers() async {
    createTestHelper('assertUserValid', (data) async {
      final user = TestUser.fromMap(data);
      return user.id.isNotEmpty && user.username.isNotEmpty && user.email.isNotEmpty;
    });

    createTestHelper('assertMessageValid', (data) async {
      final message = TestMessage.fromMap(data);
      return message.id.isNotEmpty && message.roomId.isNotEmpty && message.userId.isNotEmpty;
    });

    createTestHelper('assertRoomValid', (data) async {
      final room = TestRoom.fromMap(data);
      return room.id.isNotEmpty && room.name.isNotEmpty && room.members.isNotEmpty;
    });
  }

  /// Вставка пользователя
  Future<void> _insertUser(TestDatabase database, TestUser user) async {
    await Future.delayed(const Duration(milliseconds: 1));
  }

  /// Вставка комнаты
  Future<void> _insertRoom(TestDatabase database, TestRoom room) async {
    await Future.delayed(const Duration(milliseconds: 1));
  }

  /// Вставка сообщения
  Future<void> _insertMessage(TestDatabase database, TestMessage message) async {
    await Future.delayed(const Duration(milliseconds: 1));
  }

  /// Очистка таблицы
  Future<void> _clearTable(TestDatabase database, TestTable table) async {
    await Future.delayed(const Duration(milliseconds: 10));
  }

  /// Проверка здоровья сервиса
  Future<bool> _checkServiceHealth(String serviceName) async {
    await Future.delayed(const Duration(milliseconds: 10));
    return Random().nextDouble() > 0.1; // 90% вероятность здорового состояния
  }

  /// Генерация случайного текста
  String _generateRandomText() {
    final words = [
      'hello',
      'world',
      'test',
      'message',
      'content',
      'example',
      'sample',
      'data',
      'information',
      'text',
      'string',
      'value'
    ];
    final count = Random().nextInt(10) + 1;
    return List.generate(count, (_) => words[Random().nextInt(words.length)]).join(' ');
  }

  /// Генерация случайного имени
  String _generateRandomName() {
    final names = ['John', 'Jane', 'Bob', 'Alice', 'Charlie', 'Diana', 'Eve', 'Frank'];
    return names[Random().nextInt(names.length)];
  }

  /// Генерация случайного города
  String _generateRandomCity() {
    final cities = ['New York', 'London', 'Tokyo', 'Paris', 'Berlin', 'Sydney', 'Toronto', 'Moscow'];
    return cities[Random().nextInt(cities.length)];
  }

  /// Генерация случайной причины
  String _generateRandomReason() {
    final reasons = ['interaction', 'verification', 'recommendation', 'activity', 'quality'];
    return reasons[Random().nextInt(reasons.length)];
  }

  /// Генерация ID блокчейна
  String _generateBlockchainId() {
    return '0x${_generateRandomString(64)}';
  }

  /// Генерация адреса блокчейна
  String _generateBlockchainAddress() {
    return '0x${_generateRandomString(40)}';
  }

  /// Генерация случайной строки
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(length, (_) => chars[Random().nextInt(chars.length)]).join();
  }

  /// Генерация уникального ID
  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';
  }

  /// Освобождение ресурсов
  void dispose() {
    _dataGenerators.clear();
    _mockServices.clear();
    _testHelpers.clear();
  }
}

/// Модели данных

/// Тестовый пользователь
class TestUser extends Equatable {
  final String id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String createdAt;
  final bool isActive;
  final Map<String, dynamic> profile;
  final Map<String, dynamic> preferences;
  final Map<String, dynamic> statistics;

  const TestUser({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.createdAt,
    required this.isActive,
    required this.profile,
    required this.preferences,
    required this.statistics,
  });

  factory TestUser.fromMap(Map<String, dynamic> map) {
    return TestUser(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      createdAt: map['createdAt'] ?? '',
      isActive: map['isActive'] ?? true,
      profile: map['profile'] ?? {},
      preferences: map['preferences'] ?? {},
      statistics: map['statistics'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'createdAt': createdAt,
      'isActive': isActive,
      'profile': profile,
      'preferences': preferences,
      'statistics': statistics,
    };
  }

  factory TestUser.empty() {
    return const TestUser(
      id: '',
      username: '',
      email: '',
      firstName: '',
      lastName: '',
      createdAt: '',
      isActive: false,
      profile: {},
      preferences: {},
      statistics: {},
    );
  }

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        firstName,
        lastName,
        createdAt,
        isActive,
        profile,
        preferences,
        statistics,
      ];
}

/// Тестовое сообщение
class TestMessage extends Equatable {
  final String id;
  final String roomId;
  final String userId;
  final String type;
  final String content;
  final String timestamp;
  final bool edited;
  final bool deleted;
  final Map<String, dynamic> metadata;
  final List<dynamic> reactions;
  final String? thread;

  const TestMessage({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.type,
    required this.content,
    required this.timestamp,
    required this.edited,
    required this.deleted,
    required this.metadata,
    required this.reactions,
    this.thread,
  });

  factory TestMessage.fromMap(Map<String, dynamic> map) {
    return TestMessage(
      id: map['id'] ?? '',
      roomId: map['roomId'] ?? '',
      userId: map['userId'] ?? '',
      type: map['type'] ?? 'text',
      content: map['content'] ?? '',
      timestamp: map['timestamp'] ?? '',
      edited: map['edited'] ?? false,
      deleted: map['deleted'] ?? false,
      metadata: map['metadata'] ?? {},
      reactions: map['reactions'] ?? [],
      thread: map['thread'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'roomId': roomId,
      'userId': userId,
      'type': type,
      'content': content,
      'timestamp': timestamp,
      'edited': edited,
      'deleted': deleted,
      'metadata': metadata,
      'reactions': reactions,
      'thread': thread,
    };
  }

  factory TestMessage.empty() {
    return const TestMessage(
      id: '',
      roomId: '',
      userId: '',
      type: 'text',
      content: '',
      timestamp: '',
      edited: false,
      deleted: false,
      metadata: {},
      reactions: [],
      thread: null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        roomId,
        userId,
        type,
        content,
        timestamp,
        edited,
        deleted,
        metadata,
        reactions,
        thread,
      ];
}

/// Тестовая комната
class TestRoom extends Equatable {
  final String id;
  final String name;
  final String type;
  final String description;
  final String createdAt;
  final String createdBy;
  final List<String> members;
  final List<String> admins;
  final Map<String, dynamic> settings;
  final Map<String, dynamic> statistics;

  const TestRoom({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.createdAt,
    required this.createdBy,
    required this.members,
    required this.admins,
    required this.settings,
    required this.statistics,
  });

  factory TestRoom.fromMap(Map<String, dynamic> map) {
    return TestRoom(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? 'private',
      description: map['description'] ?? '',
      createdAt: map['createdAt'] ?? '',
      createdBy: map['createdBy'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      admins: List<String>.from(map['admins'] ?? []),
      settings: map['settings'] ?? {},
      statistics: map['statistics'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'members': members,
      'admins': admins,
      'settings': settings,
      'statistics': statistics,
    };
  }

  factory TestRoom.empty() {
    return const TestRoom(
      id: '',
      name: '',
      type: 'private',
      description: '',
      createdAt: '',
      createdBy: '',
      members: [],
      admins: [],
      settings: {},
      statistics: {},
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        description,
        createdAt,
        createdBy,
        members,
        admins,
        settings,
        statistics,
      ];
}

/// Тестовая репутация
class TestReputation extends Equatable {
  final String identityId;
  final double score;
  final String level;
  final Map<String, dynamic> factors;
  final String lastUpdated;
  final List<Map<String, dynamic>> history;

  const TestReputation({
    required this.identityId,
    required this.score,
    required this.level,
    required this.factors,
    required this.lastUpdated,
    required this.history,
  });

  factory TestReputation.fromMap(Map<String, dynamic> map) {
    return TestReputation(
      identityId: map['identityId'] ?? '',
      score: (map['score'] ?? 0.0).toDouble(),
      level: map['level'] ?? 'low',
      factors: map['factors'] ?? {},
      lastUpdated: map['lastUpdated'] ?? '',
      history: List<Map<String, dynamic>>.from(map['history'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'identityId': identityId,
      'score': score,
      'level': level,
      'factors': factors,
      'lastUpdated': lastUpdated,
      'history': history,
    };
  }

  @override
  List<Object?> get props => [identityId, score, level, factors, lastUpdated, history];
}

/// Тестовые данные блокчейна
class TestBlockchainData extends Equatable {
  final String transactionId;
  final String blockNumber;
  final String blockHash;
  final String from;
  final String to;
  final int value;
  final int gasUsed;
  final int gasPrice;
  final int timestamp;
  final String status;
  final int confirmations;

  const TestBlockchainData({
    required this.transactionId,
    required this.blockNumber,
    required this.blockHash,
    required this.from,
    required this.to,
    required this.value,
    required this.gasUsed,
    required this.gasPrice,
    required this.timestamp,
    required this.status,
    required this.confirmations,
  });

  factory TestBlockchainData.fromMap(Map<String, dynamic> map) {
    return TestBlockchainData(
      transactionId: map['transactionId'] ?? '',
      blockNumber: map['blockNumber'] ?? '',
      blockHash: map['blockHash'] ?? '',
      from: map['from'] ?? '',
      to: map['to'] ?? '',
      value: map['value'] ?? 0,
      gasUsed: map['gasUsed'] ?? 0,
      gasPrice: map['gasPrice'] ?? 0,
      timestamp: map['timestamp'] ?? 0,
      status: map['status'] ?? 'pending',
      confirmations: map['confirmations'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'blockNumber': blockNumber,
      'blockHash': blockHash,
      'from': from,
      'to': to,
      'value': value,
      'gasUsed': gasUsed,
      'gasPrice': gasPrice,
      'timestamp': timestamp,
      'status': status,
      'confirmations': confirmations,
    };
  }

  @override
  List<Object?> get props => [
        transactionId,
        blockNumber,
        blockHash,
        from,
        to,
        value,
        gasUsed,
        gasPrice,
        timestamp,
        status,
        confirmations,
      ];
}

/// Остальные модели...

class DataGenerator extends Equatable {
  final String name;
  final Map<String, dynamic> template;
  final DateTime createdAt;

  const DataGenerator({
    required this.name,
    required this.template,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [name, template, createdAt];
}

class MockService extends Equatable {
  final String name;
  final Map<String, dynamic> defaultResponses;
  final Duration responseDelay;
  final List<MockCall> callHistory;
  final DateTime createdAt;

  const MockService({
    required this.name,
    required this.defaultResponses,
    required this.responseDelay,
    required this.callHistory,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [name, defaultResponses, responseDelay, callHistory, createdAt];
}

class MockCall extends Equatable {
  final String method;
  final List<dynamic> arguments;
  final dynamic result;
  final DateTime timestamp;

  const MockCall({
    required this.method,
    required this.arguments,
    required this.result,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [method, arguments, result, timestamp];
}

class TestHelper extends Equatable {
  final String name;
  final TestHelperFunction function;
  int usageCount;
  final DateTime createdAt;

  TestHelper({
    required this.name,
    required this.function,
    required this.usageCount,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [name, function, usageCount, createdAt];
}

class TestDatabase extends Equatable {
  final String name;
  final List<TestTable> tables;
  bool isInitialized;
  final DateTime createdAt;

  TestDatabase({
    required this.name,
    required this.tables,
    required this.isInitialized,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [name, tables, isInitialized, createdAt];
}

class TestTable extends Equatable {
  final String name;
  final List<String> columns;
  final List<String> indexes;

  const TestTable({
    required this.name,
    required this.columns,
    required this.indexes,
  });

  @override
  List<Object?> get props => [name, columns, indexes];
}

class SystemState extends Equatable {
  final DateTime timestamp;
  final Map<String, bool> services;
  final Map<String, dynamic> metrics;

  const SystemState({
    required this.timestamp,
    required this.services,
    required this.metrics,
  });

  @override
  List<Object?> get props => [timestamp, services, metrics];
}

class TestHttpClient extends Equatable {
  final Map<String, TestHttpResponse> responses;
  final Duration defaultDelay;
  final List<TestHttpRequest> requestHistory;
  final DateTime createdAt;

  const TestHttpClient({
    required this.responses,
    required this.defaultDelay,
    required this.requestHistory,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [responses, defaultDelay, requestHistory, createdAt];
}

class TestHttpResponse extends Equatable {
  final int statusCode;
  final Map<String, String> headers;
  final String body;

  const TestHttpResponse({
    required this.statusCode,
    required this.headers,
    required this.body,
  });

  @override
  List<Object?> get props => [statusCode, headers, body];
}

class TestHttpRequest extends Equatable {
  final String method;
  final String url;
  final Map<String, String> headers;
  final String? body;
  final DateTime timestamp;

  const TestHttpRequest({
    required this.method,
    required this.url,
    required this.headers,
    this.body,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [method, url, headers, body, timestamp];
}

class TestWebSocketClient extends Equatable {
  final List<String> messages;
  final Duration messageDelay;
  final List<TestWebSocketConnection> connectionHistory;
  final DateTime createdAt;

  const TestWebSocketClient({
    required this.messages,
    required this.messageDelay,
    required this.connectionHistory,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [messages, messageDelay, connectionHistory, createdAt];
}

class TestWebSocketConnection extends Equatable {
  final String url;
  final DateTime connectedAt;
  final DateTime? disconnectedAt;
  final List<String> messagesReceived;

  const TestWebSocketConnection({
    required this.url,
    required this.connectedAt,
    this.disconnectedAt,
    required this.messagesReceived,
  });

  @override
  List<Object?> get props => [url, connectedAt, disconnectedAt, messagesReceived];
}

/// Перечисления

enum MessageType {
  text,
  image,
  file,
  audio,
  video,
  location,
}

enum RoomType {
  private,
  public,
  direct,
  group,
}

typedef TestHelperFunction = Future<bool> Function(Map<String, dynamic> data);
