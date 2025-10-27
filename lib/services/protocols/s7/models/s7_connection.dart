import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 's7_connection.g.dart';

/// Модель подключения к S7 контроллеру
@JsonSerializable()
class S7Connection extends Equatable {
  /// Уникальный идентификатор подключения
  final String connectionId;

  /// Хост S7 контроллера
  final String host;

  /// Порт подключения
  final int port;

  /// Rack номер
  final int rack;

  /// Slot номер
  final int slot;

  /// Учетные данные
  final Map<String, dynamic> credentials;

  /// TCP сокет
  @JsonKey(ignore: true)
  Socket? socket;

  /// Статус подключения
  @JsonKey(ignore: true)
  bool isConnected;

  /// Время создания подключения
  final DateTime createdAt;

  /// Время последней активности
  DateTime lastActivity;

  /// Количество переподключений
  int reconnectCount;

  /// Статистика подключения
  final ConnectionStats stats;

  const S7Connection({
    required this.connectionId,
    required this.host,
    required this.port,
    required this.rack,
    required this.slot,
    required this.credentials,
    this.socket,
    this.isConnected = false,
    required this.createdAt,
    required this.lastActivity,
    this.reconnectCount = 0,
    this.stats = const ConnectionStats(),
  });

  @override
  List<Object?> get props => [
        connectionId,
        host,
        port,
        rack,
        slot,
        credentials,
        isConnected,
        createdAt,
        lastActivity,
        reconnectCount,
        stats,
      ];

  S7Connection copyWith({
    String? connectionId,
    String? host,
    int? port,
    int? rack,
    int? slot,
    Map<String, dynamic>? credentials,
    Socket? socket,
    bool? isConnected,
    DateTime? createdAt,
    DateTime? lastActivity,
    int? reconnectCount,
    ConnectionStats? stats,
  }) {
    return S7Connection(
      connectionId: connectionId ?? this.connectionId,
      host: host ?? this.host,
      port: port ?? this.port,
      rack: rack ?? this.rack,
      slot: slot ?? this.slot,
      credentials: credentials ?? this.credentials,
      socket: socket ?? this.socket,
      isConnected: isConnected ?? this.isConnected,
      createdAt: createdAt ?? this.createdAt,
      lastActivity: lastActivity ?? this.lastActivity,
      reconnectCount: reconnectCount ?? this.reconnectCount,
      stats: stats ?? this.stats,
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

  /// Получение строки подключения
  String get connectionString => '$host:$port (Rack:$rack, Slot:$slot)';

  /// Проверка, активно ли подключение
  bool get isActive {
    if (!isConnected) return false;

    final now = DateTime.now();
    final inactiveDuration = now.difference(lastActivity);

    // Считаем подключение неактивным, если нет активности более 5 минут
    return inactiveDuration.inMinutes < 5;
  }

  Map<String, dynamic> toJson() => _$S7ConnectionToJson(this);
  factory S7Connection.fromJson(Map<String, dynamic> json) => _$S7ConnectionFromJson(json);
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

  Map<String, dynamic> toJson() => _$ConnectionStatsToJson(this);
  factory ConnectionStats.fromJson(Map<String, dynamic> json) => _$ConnectionStatsFromJson(json);
}

/// Конфигурация S7 подключения
@JsonSerializable()
class S7ConnectionConfig extends Equatable {
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

  const S7ConnectionConfig({
    this.maxReconnects = 5,
    this.reconnectInterval = 10,
    this.connectionTimeout = 5000,
    this.readTimeout = 3000,
    this.heartbeatInterval = 30000,
    this.autoReconnect = true,
    this.enableCompression = false,
    this.enableEncryption = true,
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
      ];

  S7ConnectionConfig copyWith({
    int? maxReconnects,
    int? reconnectInterval,
    int? connectionTimeout,
    int? readTimeout,
    int? heartbeatInterval,
    bool? autoReconnect,
    bool? enableCompression,
    bool? enableEncryption,
  }) {
    return S7ConnectionConfig(
      maxReconnects: maxReconnects ?? this.maxReconnects,
      reconnectInterval: reconnectInterval ?? this.reconnectInterval,
      connectionTimeout: connectionTimeout ?? this.connectionTimeout,
      readTimeout: readTimeout ?? this.readTimeout,
      heartbeatInterval: heartbeatInterval ?? this.heartbeatInterval,
      autoReconnect: autoReconnect ?? this.autoReconnect,
      enableCompression: enableCompression ?? this.enableCompression,
      enableEncryption: enableEncryption ?? this.enableEncryption,
    );
  }

  Map<String, dynamic> toJson() => _$S7ConnectionConfigToJson(this);
  factory S7ConnectionConfig.fromJson(Map<String, dynamic> json) => _$S7ConnectionConfigFromJson(json);
}
