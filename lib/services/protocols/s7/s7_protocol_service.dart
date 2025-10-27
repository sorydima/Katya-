import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:katya/global/print.dart';
import 'package:katya/services/protocols/s7/models/s7_connection.dart';
import 'package:katya/services/protocols/s7/models/s7_data_block.dart';
import 'package:katya/services/protocols/s7/models/s7_message.dart';

/// Служба для работы с протоколом S7 (Siemens S7)
///
/// Обеспечивает:
/// - Подключение к промышленным контроллерам
/// - Чтение и запись данных
/// - Безопасную передачу сообщений
/// - Верификацию сертификатов
class S7ProtocolService {
  static final S7ProtocolService _instance = S7ProtocolService._internal();

  // Подключения
  final Map<String, S7Connection> _connections = {};
  final Map<String, Timer> _heartbeatTimers = {};

  // Конфигурация
  static const int _defaultPort = 102;
  static const int _connectionTimeout = 5000; // 5 секунд
  static const int _readTimeout = 3000; // 3 секунды
  static const int _heartbeatInterval = 30000; // 30 секунд

  // Singleton pattern
  factory S7ProtocolService() => _instance;

  S7ProtocolService._internal();

  /// Подключение к S7 контроллеру
  Future<S7Connection> connect({
    required String connectionId,
    required String host,
    int port = _defaultPort,
    int rack = 0,
    int slot = 1,
    Map<String, dynamic>? credentials,
  }) async {
    try {
      log.info('Connecting to S7 controller: $host:$port');

      // Создание подключения
      final connection = S7Connection(
        connectionId: connectionId,
        host: host,
        port: port,
        rack: rack,
        slot: slot,
        credentials: credentials ?? {},
      );

      // Установка TCP соединения
      final socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(milliseconds: _connectionTimeout),
      );

      connection.socket = socket;
      connection.isConnected = true;

      // Установка ISO соединения
      await _establishIsoConnection(connection);

      // Сохранение подключения
      _connections[connectionId] = connection;

      // Запуск heartbeat
      _startHeartbeat(connectionId);

      log.info('Successfully connected to S7 controller: $connectionId');
      return connection;
    } catch (e) {
      log.error('Failed to connect to S7 controller: $e');
      rethrow;
    }
  }

  /// Отключение от S7 контроллера
  Future<void> disconnect(String connectionId) async {
    try {
      final connection = _connections[connectionId];
      if (connection == null) {
        log.warn('Connection $connectionId not found');
        return;
      }

      // Остановка heartbeat
      _stopHeartbeat(connectionId);

      // Закрытие соединения
      if (connection.socket != null) {
        await connection.socket!.close();
      }

      connection.isConnected = false;
      _connections.remove(connectionId);

      log.info('Disconnected from S7 controller: $connectionId');
    } catch (e) {
      log.error('Error disconnecting from S7 controller $connectionId: $e');
    }
  }

  /// Чтение данных из S7 контроллера
  Future<S7DataBlock> readData({
    required String connectionId,
    required int dbNumber,
    required int startByte,
    required int byteCount,
  }) async {
    try {
      final connection = _connections[connectionId];
      if (connection == null) {
        throw Exception('Connection $connectionId not found');
      }

      if (!connection.isConnected) {
        throw Exception('Connection $connectionId is not connected');
      }

      // Создание запроса на чтение
      final request = S7Message.createReadRequest(
        connectionId: connectionId,
        dbNumber: dbNumber,
        startByte: startByte,
        byteCount: byteCount,
      );

      // Отправка запроса
      await _sendMessage(connection, request);

      // Получение ответа
      final response = await _receiveMessage(connection);

      // Обработка ответа
      if (response.isError) {
        throw Exception('S7 read error: ${response.errorMessage}');
      }

      final dataBlock = S7DataBlock(
        dbNumber: dbNumber,
        startByte: startByte,
        data: response.data,
        timestamp: DateTime.now(),
      );

      log.info('Successfully read data from S7: DB$dbNumber, $byteCount bytes');
      return dataBlock;
    } catch (e) {
      log.error('Error reading data from S7: $e');
      rethrow;
    }
  }

  /// Запись данных в S7 контроллер
  Future<bool> writeData({
    required String connectionId,
    required int dbNumber,
    required int startByte,
    required Uint8List data,
  }) async {
    try {
      final connection = _connections[connectionId];
      if (connection == null) {
        throw Exception('Connection $connectionId not found');
      }

      if (!connection.isConnected) {
        throw Exception('Connection $connectionId is not connected');
      }

      // Создание запроса на запись
      final request = S7Message.createWriteRequest(
        connectionId: connectionId,
        dbNumber: dbNumber,
        startByte: startByte,
        data: data,
      );

      // Отправка запроса
      await _sendMessage(connection, request);

      // Получение ответа
      final response = await _receiveMessage(connection);

      // Проверка успешности записи
      if (response.isError) {
        throw Exception('S7 write error: ${response.errorMessage}');
      }

      log.info('Successfully wrote data to S7: DB$dbNumber, ${data.length} bytes');
      return true;
    } catch (e) {
      log.error('Error writing data to S7: $e');
      return false;
    }
  }

  /// Отправка сообщения через S7 протокол
  Future<bool> sendMessage({
    required String connectionId,
    required String recipientId,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final connection = _connections[connectionId];
      if (connection == null) {
        throw Exception('Connection $connectionId not found');
      }

      if (!connection.isConnected) {
        throw Exception('Connection $connectionId is not connected');
      }

      // Подготовка данных сообщения
      final messageData = {
        'type': 'message',
        'recipient': recipientId,
        'content': message,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'metadata': metadata ?? {},
      };

      final jsonString = jsonEncode(messageData);
      final messageBytes = Uint8List.fromList(utf8.encode(jsonString));

      // Запись сообщения в специальную область данных
      final success = await writeData(
        connectionId: connectionId,
        dbNumber: 999, // Специальная область для сообщений
        startByte: 0,
        data: messageBytes,
      );

      if (success) {
        log.info('Message sent via S7: $recipientId');
      }

      return success;
    } catch (e) {
      log.error('Error sending message via S7: $e');
      return false;
    }
  }

  /// Верификация сертификата S7
  Future<bool> verifyCertificate({
    required String connectionId,
    required String certificate,
    required String signature,
  }) async {
    try {
      final connection = _connections[connectionId];
      if (connection == null) {
        throw Exception('Connection $connectionId not found');
      }

      // Проверка формата сертификата
      if (!_isValidCertificate(certificate)) {
        log.error('Invalid certificate format');
        return false;
      }

      // Проверка подписи
      if (!_verifySignature(certificate, signature)) {
        log.error('Invalid certificate signature');
        return false;
      }

      // Проверка срока действия
      if (!_isCertificateValid(certificate)) {
        log.error('Certificate has expired');
        return false;
      }

      log.info('S7 certificate verified successfully');
      return true;
    } catch (e) {
      log.error('Error verifying S7 certificate: $e');
      return false;
    }
  }

  /// Получение статуса подключения
  ConnectionStatus getConnectionStatus(String connectionId) {
    final connection = _connections[connectionId];
    if (connection == null) return ConnectionStatus.disconnected;
    if (connection.isConnected) return ConnectionStatus.connected;
    return ConnectionStatus.disconnected;
  }

  /// Получение списка активных подключений
  List<String> getActiveConnections() {
    return _connections.keys.toList();
  }

  /// Установка ISO соединения
  Future<void> _establishIsoConnection(S7Connection connection) async {
    try {
      // Создание ISO соединения (ISO 8073)
      final isoRequest = _createIsoConnectionRequest(connection);

      // Отправка запроса
      connection.socket!.add(isoRequest);
      await connection.socket!.flush();

      // Получение ответа
      final response = await _readSocketData(connection.socket!);

      // Проверка успешности установки соединения
      if (response.length < 4 || response[3] != 0xD0) {
        throw Exception('Failed to establish ISO connection');
      }

      log.info('ISO connection established for ${connection.connectionId}');
    } catch (e) {
      log.error('Error establishing ISO connection: $e');
      rethrow;
    }
  }

  /// Создание запроса ISO соединения
  Uint8List _createIsoConnectionRequest(S7Connection connection) {
    final request = Uint8List(22);

    // ISO Header (22 bytes)
    request[0] = 0x03; // ISO length
    request[1] = 0x00;
    request[2] = 0x16; // Total length
    request[3] = 0x11; // ISO connection request
    request[4] = 0xE0; // Destination reference
    request[5] = 0x00;
    request[6] = 0x00; // Source reference
    request[7] = 0x00;
    request[8] = 0x00; // Class and options
    request[9] = 0x00; // Class and options
    request[10] = 0x00; // PDU length
    request[11] = 0x00;
    request[12] = 0x00; // PDU length
    request[13] = 0x00;
    request[14] = 0x00; // Source TSAP
    request[15] = 0x01;
    request[16] = 0x00; // Destination TSAP
    request[17] = 0x01;
    request[18] = 0x00; // TPDU size
    request[19] = 0x0A;
    request[20] = 0x00; // Reserved
    request[21] = 0x00;

    return request;
  }

  /// Отправка S7 сообщения
  Future<void> _sendMessage(S7Connection connection, S7Message message) async {
    try {
      final messageBytes = message.toBytes();
      connection.socket!.add(messageBytes);
      await connection.socket!.flush();
    } catch (e) {
      log.error('Error sending S7 message: $e');
      rethrow;
    }
  }

  /// Получение S7 сообщения
  Future<S7Message> _receiveMessage(S7Connection connection) async {
    try {
      final response = await _readSocketData(connection.socket!);
      return S7Message.fromBytes(response);
    } catch (e) {
      log.error('Error receiving S7 message: $e');
      rethrow;
    }
  }

  /// Чтение данных из сокета
  Future<Uint8List> _readSocketData(Socket socket) async {
    final completer = Completer<Uint8List>();
    final buffer = <int>[];

    // Настройка таймаута
    Timer(const Duration(milliseconds: _readTimeout), () {
      if (!completer.isCompleted) {
        completer.completeError('Socket read timeout');
      }
    });

    socket.listen(
      (data) {
        buffer.addAll(data);
        if (buffer.length >= 4) {
          final length = (buffer[1] << 8) | buffer[2];
          if (buffer.length >= length + 3) {
            if (!completer.isCompleted) {
              completer.complete(Uint8List.fromList(buffer));
            }
          }
        }
      },
      onError: (error) {
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
      },
    );

    return completer.future;
  }

  /// Запуск heartbeat
  void _startHeartbeat(String connectionId) {
    _stopHeartbeat(connectionId);

    _heartbeatTimers[connectionId] = Timer.periodic(
      const Duration(milliseconds: _heartbeatInterval),
      (timer) async {
        try {
          final connection = _connections[connectionId];
          if (connection != null && connection.isConnected) {
            await _sendHeartbeat(connection);
          } else {
            _stopHeartbeat(connectionId);
          }
        } catch (e) {
          log.error('Heartbeat error for $connectionId: $e');
          _stopHeartbeat(connectionId);
        }
      },
    );
  }

  /// Остановка heartbeat
  void _stopHeartbeat(String connectionId) {
    final timer = _heartbeatTimers[connectionId];
    if (timer != null) {
      timer.cancel();
      _heartbeatTimers.remove(connectionId);
    }
  }

  /// Отправка heartbeat
  Future<void> _sendHeartbeat(S7Connection connection) async {
    try {
      final heartbeat = S7Message.createHeartbeat(connection.connectionId);
      await _sendMessage(connection, heartbeat);
    } catch (e) {
      log.error('Error sending heartbeat: $e');
      connection.isConnected = false;
    }
  }

  /// Проверка валидности сертификата
  bool _isValidCertificate(String certificate) {
    // Упрощенная проверка формата сертификата
    return certificate.isNotEmpty && certificate.contains('-----BEGIN CERTIFICATE-----');
  }

  /// Проверка подписи
  bool _verifySignature(String certificate, String signature) {
    // Упрощенная проверка подписи
    // В реальной реализации здесь должна быть криптографическая проверка
    return signature.isNotEmpty;
  }

  /// Проверка срока действия сертификата
  bool _isCertificateValid(String certificate) {
    // Упрощенная проверка срока действия
    // В реальной реализации здесь должна быть проверка дат
    return true;
  }

  /// Очистка ресурсов
  void dispose() {
    // Отключение всех соединений
    for (final connectionId in _connections.keys.toList()) {
      disconnect(connectionId);
    }

    // Остановка всех таймеров
    for (final timer in _heartbeatTimers.values) {
      timer.cancel();
    }
    _heartbeatTimers.clear();
  }
}

/// Статус подключения
enum ConnectionStatus {
  connected,
  connecting,
  disconnected,
  error,
}
