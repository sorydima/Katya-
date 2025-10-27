import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:katya/services/protocols/messengers/messenger_bridge_service.dart';

part 'messenger_connection.g.dart';

/// Модель подключения к мессенджеру
@JsonSerializable()
class MessengerConnection extends Equatable {
  /// Уникальный идентификатор подключения
  final String id;

  /// Тип мессенджера
  final MessengerType messengerType;

  /// Имя пользователя
  final String username;

  /// Пароль
  @JsonKey(ignore: true)
  final String password;

  /// Дополнительные учетные данные
  final Map<String, dynamic> additionalCredentials;

  /// Статус подключения
  final ConnectionStatus status;

  /// Время подключения
  final DateTime connectedAt;

  /// Время последней активности
  DateTime lastActivity;

  /// Количество переподключений
  int reconnectCount;

  /// Статистика подключения
  final ConnectionStats stats;

  /// Настройки подключения
  final ConnectionSettings settings;

  /// Метаданные
  final Map<String, dynamic> metadata;

  const MessengerConnection({
    required this.id,
    required this.messengerType,
    required this.username,
    required this.password,
    this.additionalCredentials = const {},
    required this.status,
    required this.connectedAt,
    required this.lastActivity,
    this.reconnectCount = 0,
    this.stats = const ConnectionStats(),
    this.settings = const ConnectionSettings(),
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
        id,
        messengerType,
        username,
        additionalCredentials,
        status,
        connectedAt,
        lastActivity,
        reconnectCount,
        stats,
        settings,
        metadata,
      ];

  MessengerConnection copyWith({
    String? id,
    MessengerType? messengerType,
    String? username,
    String? password,
    Map<String, dynamic>? additionalCredentials,
    ConnectionStatus? status,
    DateTime? connectedAt,
    DateTime? lastActivity,
    int? reconnectCount,
    ConnectionStats? stats,
    ConnectionSettings? settings,
    Map<String, dynamic>? metadata,
  }) {
    return MessengerConnection(
      id: id ?? this.id,
      messengerType: messengerType ?? this.messengerType,
      username: username ?? this.username,
      password: password ?? this.password,
      additionalCredentials: additionalCredentials ?? this.additionalCredentials,
      status: status ?? this.status,
      connectedAt: connectedAt ?? this.connectedAt,
      lastActivity: lastActivity ?? this.lastActivity,
      reconnectCount: reconnectCount ?? this.reconnectCount,
      stats: stats ?? this.stats,
      settings: settings ?? this.settings,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Обновление времени последней активности
  void updateLastActivity() {
    lastActivity = DateTime.now();
  }

  /// Увеличение счетчика переподключений
  void incrementReconnectCount() {
    reconnectCount++;
  }

  /// Проверка, активно ли подключение
  bool get isActive {
    if (status != ConnectionStatus.connected) return false;

    final now = DateTime.now();
    final inactiveDuration = now.difference(lastActivity);

    // Считаем подключение неактивным, если нет активности более 5 минут
    return inactiveDuration.inMinutes < 5;
  }

  /// Получение строки подключения
  String get connectionString => '${messengerType.name}://$username';

  /// Проверка, нужно ли переподключение
  bool get needsReconnect {
    if (status == ConnectionStatus.connected) return false;
    if (status == ConnectionStatus.failed && reconnectCount < settings.maxReconnects) {
      return true;
    }
    return false;
  }

  Map<String, dynamic> toJson() => _$MessengerConnectionToJson(this);
  factory MessengerConnection.fromJson(Map<String, dynamic> json) => _$MessengerConnectionFromJson(json);
}

/// Статистика подключения
@JsonSerializable()
class ConnectionStats extends Equatable {
  /// Общее количество отправленных сообщений
  final int messagesSent;

  /// Общее количество полученных сообщений
  final int messagesReceived;

  /// Общее количество ошибок
  final int errorCount;

  /// Общее количество переподключений
  final int totalReconnects;

  /// Время последней ошибки
  final DateTime? lastErrorTime;

  /// Последнее сообщение об ошибке
  final String? lastErrorMessage;

  /// Объем переданных данных (в байтах)
  final int bytesTransmitted;

  /// Объем полученных данных (в байтах)
  final int bytesReceived;

  /// Среднее время отклика (в миллисекундах)
  final double averageResponseTime;

  /// Время работы (в секундах)
  final int uptime;

  const ConnectionStats({
    this.messagesSent = 0,
    this.messagesReceived = 0,
    this.errorCount = 0,
    this.totalReconnects = 0,
    this.lastErrorTime,
    this.lastErrorMessage,
    this.bytesTransmitted = 0,
    this.bytesReceived = 0,
    this.averageResponseTime = 0.0,
    this.uptime = 0,
  });

  @override
  List<Object?> get props => [
        messagesSent,
        messagesReceived,
        errorCount,
        totalReconnects,
        lastErrorTime,
        lastErrorMessage,
        bytesTransmitted,
        bytesReceived,
        averageResponseTime,
        uptime,
      ];

  ConnectionStats copyWith({
    int? messagesSent,
    int? messagesReceived,
    int? errorCount,
    int? totalReconnects,
    DateTime? lastErrorTime,
    String? lastErrorMessage,
    int? bytesTransmitted,
    int? bytesReceived,
    double? averageResponseTime,
    int? uptime,
  }) {
    return ConnectionStats(
      messagesSent: messagesSent ?? this.messagesSent,
      messagesReceived: messagesReceived ?? this.messagesReceived,
      errorCount: errorCount ?? this.errorCount,
      totalReconnects: totalReconnects ?? this.totalReconnects,
      lastErrorTime: lastErrorTime ?? this.lastErrorTime,
      lastErrorMessage: lastErrorMessage ?? this.lastErrorMessage,
      bytesTransmitted: bytesTransmitted ?? this.bytesTransmitted,
      bytesReceived: bytesReceived ?? this.bytesReceived,
      averageResponseTime: averageResponseTime ?? this.averageResponseTime,
      uptime: uptime ?? this.uptime,
    );
  }

  /// Добавление отправленного сообщения
  ConnectionStats addSentMessage(int bytes) {
    return copyWith(
      messagesSent: messagesSent + 1,
      bytesTransmitted: bytesTransmitted + bytes,
    );
  }

  /// Добавление полученного сообщения
  ConnectionStats addReceivedMessage(int bytes, double responseTime) {
    final newAverageResponseTime = (averageResponseTime * messagesReceived + responseTime) / (messagesReceived + 1);

    return copyWith(
      messagesReceived: messagesReceived + 1,
      bytesReceived: bytesReceived + bytes,
      averageResponseTime: newAverageResponseTime,
    );
  }

  /// Добавление ошибки
  ConnectionStats addError(String errorMessage) {
    return copyWith(
      errorCount: errorCount + 1,
      lastErrorTime: DateTime.now(),
      lastErrorMessage: errorMessage,
    );
  }

  /// Добавление переподключения
  ConnectionStats addReconnect() {
    return copyWith(
      totalReconnects: totalReconnects + 1,
    );
  }

  /// Получение процента успешности
  double get successRate {
    final total = messagesSent + messagesReceived;
    if (total == 0) return 0.0;

    final errors = errorCount;
    return ((total - errors) / total) * 100;
  }

  /// Получение общего объема трафика
  int get totalTraffic => bytesTransmitted + bytesReceived;

  /// Получение времени работы в читаемом формате
  String get formattedUptime {
    final hours = uptime ~/ 3600;
    final minutes = (uptime % 3600) ~/ 60;
    final seconds = uptime % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  Map<String, dynamic> toJson() => _$ConnectionStatsToJson(this);
  factory ConnectionStats.fromJson(Map<String, dynamic> json) => _$ConnectionStatsFromJson(json);
}

/// Настройки подключения
@JsonSerializable()
class ConnectionSettings extends Equatable {
  /// Максимальное количество переподключений
  final int maxReconnects;

  /// Интервал между переподключениями (в секундах)
  final int reconnectInterval;

  /// Таймаут подключения (в миллисекундах)
  final int connectionTimeout;

  /// Таймаут чтения (в миллисекундах)
  final int readTimeout;

  /// Интервал heartbeat (в миллисекундах)
  final int heartbeatInterval;

  /// Включить ли автоматическое переподключение
  final bool autoReconnect;

  /// Включить ли сжатие данных
  final bool enableCompression;

  /// Включить ли шифрование
  final bool enableEncryption;

  /// Включить ли логирование
  final bool enableLogging;

  /// Максимальный размер сообщения (в байтах)
  final int maxMessageSize;

  /// Кэшировать ли сообщения
  final bool cacheMessages;

  /// Максимальный размер кэша (в сообщениях)
  final int maxCacheSize;

  const ConnectionSettings({
    this.maxReconnects = 5,
    this.reconnectInterval = 10,
    this.connectionTimeout = 30000,
    this.readTimeout = 10000,
    this.heartbeatInterval = 60000,
    this.autoReconnect = true,
    this.enableCompression = false,
    this.enableEncryption = true,
    this.enableLogging = true,
    this.maxMessageSize = 1024 * 1024, // 1MB
    this.cacheMessages = true,
    this.maxCacheSize = 1000,
  });

  @override
  List<Object?> get props => [
        maxReconnects,
        reconnectInterval,
        connectionTimeout,
        readTimeout,
        heartbeatInterval,
        autoReconnect,
        enableCompression,
        enableEncryption,
        enableLogging,
        maxMessageSize,
        cacheMessages,
        maxCacheSize,
      ];

  ConnectionSettings copyWith({
    int? maxReconnects,
    int? reconnectInterval,
    int? connectionTimeout,
    int? readTimeout,
    int? heartbeatInterval,
    bool? autoReconnect,
    bool? enableCompression,
    bool? enableEncryption,
    bool? enableLogging,
    int? maxMessageSize,
    bool? cacheMessages,
    int? maxCacheSize,
  }) {
    return ConnectionSettings(
      maxReconnects: maxReconnects ?? this.maxReconnects,
      reconnectInterval: reconnectInterval ?? this.reconnectInterval,
      connectionTimeout: connectionTimeout ?? this.connectionTimeout,
      readTimeout: readTimeout ?? this.readTimeout,
      heartbeatInterval: heartbeatInterval ?? this.heartbeatInterval,
      autoReconnect: autoReconnect ?? this.autoReconnect,
      enableCompression: enableCompression ?? this.enableCompression,
      enableEncryption: enableEncryption ?? this.enableEncryption,
      enableLogging: enableLogging ?? this.enableLogging,
      maxMessageSize: maxMessageSize ?? this.maxMessageSize,
      cacheMessages: cacheMessages ?? this.cacheMessages,
      maxCacheSize: maxCacheSize ?? this.maxCacheSize,
    );
  }

  Map<String, dynamic> toJson() => _$ConnectionSettingsToJson(this);
  factory ConnectionSettings.fromJson(Map<String, dynamic> json) => _$ConnectionSettingsFromJson(json);
}
