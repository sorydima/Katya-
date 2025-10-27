import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';

/// Сервис для интеграции с IoT устройствами и умными устройствами
class IoTIntegrationService {
  static final IoTIntegrationService _instance = IoTIntegrationService._internal();

  // Подключенные устройства
  final Map<String, IoTDevice> _connectedDevices = {};
  final Map<String, IoTDeviceGroup> _deviceGroups = {};
  final Map<String, IoTDataStream> _dataStreams = {};

  // Управление устройствами
  final Map<String, IoTCommandQueue> _commandQueues = {};
  final Map<String, IoTAlert> _activeAlerts = {};

  // Конфигурация
  static const int _deviceTimeoutSeconds = 30;
  static const int _maxDataStreamSize = 10000;
  static const int _commandRetryAttempts = 3;

  factory IoTIntegrationService() => _instance;
  IoTIntegrationService._internal();

  /// Инициализация сервиса
  Future<void> initialize() async {
    await _scanForDevices();
    _setupDeviceMonitoring();
    _setupDataCollection();
    _setupCommandProcessing();
  }

  /// Подключение IoT устройства
  Future<IoTConnectionResult> connectDevice({
    required String deviceId,
    required IoTDeviceType deviceType,
    required String connectionString,
    required Map<String, dynamic> deviceConfig,
  }) async {
    try {
      // Создаем объект устройства
      final device = IoTDevice(
        deviceId: deviceId,
        deviceType: deviceType,
        connectionString: connectionString,
        config: deviceConfig,
        status: DeviceStatus.connecting,
        capabilities: _getDeviceCapabilities(deviceType),
        lastSeen: DateTime.now(),
        createdAt: DateTime.now(),
      );

      // Устанавливаем соединение
      final connection = await _establishConnection(device);
      if (connection.status != ConnectionStatus.connected) {
        return IoTConnectionResult(
          deviceId: deviceId,
          success: false,
          errorMessage: connection.errorMessage,
          connectionTime: Duration.zero,
        );
      }

      // Создаем новое устройство с обновленным статусом
      final updatedDevice = IoTDevice(
        deviceId: device.deviceId,
        deviceType: device.deviceType,
        connectionString: device.connectionString,
        config: device.config,
        status: DeviceStatus.connected,
        capabilities: device.capabilities,
        lastSeen: device.lastSeen,
        createdAt: device.createdAt,
        connection: connection,
      );

      _connectedDevices[deviceId] = updatedDevice;

      // Инициализируем потоки данных
      await _initializeDataStreams(device);

      // Запускаем мониторинг
      _startDeviceMonitoring(device);

      return IoTConnectionResult(
        deviceId: deviceId,
        success: true,
        connectionTime: connection.connectionTime,
      );
    } catch (e) {
      return IoTConnectionResult(
        deviceId: deviceId,
        success: false,
        errorMessage: e.toString(),
        connectionTime: Duration.zero,
      );
    }
  }

  /// Отключение устройства
  Future<bool> disconnectDevice(String deviceId) async {
    final device = _connectedDevices[deviceId];
    if (device == null) {
      return false;
    }

    try {
      // Останавливаем мониторинг
      _stopDeviceMonitoring(device);

      // Закрываем соединение
      await _closeConnection(device);

      // Удаляем из активных устройств
      _connectedDevices.remove(deviceId);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Отправка команды устройству
  Future<IoTCommandResult> sendCommand({
    required String deviceId,
    required IoTCommand command,
    Map<String, dynamic>? parameters,
    Duration? timeout,
  }) async {
    final device = _connectedDevices[deviceId];
    if (device == null) {
      return IoTCommandResult(
        commandId: command.commandId,
        deviceId: deviceId,
        success: false,
        errorMessage: 'Device not connected',
        executionTime: Duration.zero,
      );
    }

    if (device.status != DeviceStatus.connected) {
      return IoTCommandResult(
        commandId: command.commandId,
        deviceId: deviceId,
        success: false,
        errorMessage: 'Device not available',
        executionTime: Duration.zero,
      );
    }

    try {
      // Добавляем команду в очередь
      final commandQueue = _commandQueues[deviceId] ?? IoTCommandQueue(deviceId: deviceId, commands: const []);
      commandQueue.commands.add(command);
      _commandQueues[deviceId] = commandQueue;

      // Выполняем команду
      final result = await _executeCommand(device, command, parameters, timeout);

      return result;
    } catch (e) {
      return IoTCommandResult(
        commandId: command.commandId,
        deviceId: deviceId,
        success: false,
        errorMessage: e.toString(),
        executionTime: Duration.zero,
      );
    }
  }

  /// Получение данных с устройства
  Future<List<IoTDataPoint>> getDeviceData({
    required String deviceId,
    required String dataType,
    DateTime? from,
    DateTime? to,
    int? limit,
  }) async {
    final device = _connectedDevices[deviceId];
    if (device == null) {
      return [];
    }

    final streamKey = '${deviceId}_$dataType';
    final stream = _dataStreams[streamKey];
    if (stream == null) {
      return [];
    }

    // Фильтруем данные по времени
    var filteredData = stream.dataPoints;
    if (from != null) {
      filteredData = filteredData.where((dp) => dp.timestamp.isAfter(from)).toList();
    }
    if (to != null) {
      filteredData = filteredData.where((dp) => dp.timestamp.isBefore(to)).toList();
    }

    // Сортировка по времени (новые сначала)
    filteredData.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Ограничение количества
    if (limit != null) {
      filteredData = filteredData.take(limit).toList();
    }

    return filteredData;
  }

  /// Создание группы устройств
  Future<IoTDeviceGroup> createDeviceGroup({
    required String groupId,
    required String name,
    required List<String> deviceIds,
    required IoTGroupConfig config,
  }) async {
    // Проверяем, что все устройства подключены
    final connectedDevices = <IoTDevice>[];
    for (final deviceId in deviceIds) {
      final device = _connectedDevices[deviceId];
      if (device != null) {
        connectedDevices.add(device);
      }
    }

    final group = IoTDeviceGroup(
      groupId: groupId,
      name: name,
      devices: connectedDevices,
      config: config,
      createdAt: DateTime.now(),
      status: GroupStatus.active,
    );

    _deviceGroups[groupId] = group;
    return group;
  }

  /// Отправка команды группе устройств
  Future<List<IoTCommandResult>> sendGroupCommand({
    required String groupId,
    required IoTCommand command,
    Map<String, dynamic>? parameters,
    Duration? timeout,
  }) async {
    final group = _deviceGroups[groupId];
    if (group == null) {
      return [];
    }

    final results = <IoTCommandResult>[];

    for (final device in group.devices) {
      final result = await sendCommand(
        deviceId: device.deviceId,
        command: command,
        parameters: parameters,
        timeout: timeout,
      );
      results.add(result);
    }

    return results;
  }

  /// Получение агрегированных данных группы
  Future<IoTAggregatedData> getGroupData({
    required String groupId,
    required String dataType,
    required AggregationType aggregationType,
    DateTime? from,
    DateTime? to,
  }) async {
    final group = _deviceGroups[groupId];
    if (group == null) {
      return IoTAggregatedData(
        groupId: groupId,
        dataType: dataType,
        aggregationType: aggregationType,
        value: 0.0,
        timestamp: DateTime.now(),
        deviceCount: 0,
      );
    }

    // Собираем данные со всех устройств в группе
    final allDataPoints = <IoTDataPoint>[];
    for (final device in group.devices) {
      final deviceData = await getDeviceData(
        deviceId: device.deviceId,
        dataType: dataType,
        from: from,
        to: to,
      );
      allDataPoints.addAll(deviceData);
    }

    // Выполняем агрегацию
    final aggregatedValue = _performAggregation(allDataPoints, aggregationType);

    return IoTAggregatedData(
      groupId: groupId,
      dataType: dataType,
      aggregationType: aggregationType,
      value: aggregatedValue,
      timestamp: DateTime.now(),
      deviceCount: group.devices.length,
    );
  }

  /// Создание алерта
  Future<IoTAlert> createAlert({
    required String alertId,
    required String deviceId,
    required AlertType alertType,
    required String condition,
    required AlertSeverity severity,
    Map<String, dynamic>? parameters,
  }) async {
    final alert = IoTAlert(
      alertId: alertId,
      deviceId: deviceId,
      alertType: alertType,
      condition: condition,
      severity: severity,
      parameters: parameters ?? {},
      status: AlertStatus.active,
      createdAt: DateTime.now(),
      lastTriggered: null,
    );

    _activeAlerts[alertId] = alert;
    return alert;
  }

  /// Получение статистики устройств
  Future<IoTDeviceStats> getDeviceStats(String deviceId) async {
    final device = _connectedDevices[deviceId];
    if (device == null) {
      return IoTDeviceStats(
        deviceId: deviceId,
        uptime: Duration.zero,
        totalDataPoints: 0,
        averageResponseTime: Duration.zero,
        errorCount: 0,
        lastError: null,
        timestamp: DateTime.now(),
      );
    }

    final streamKey = '${deviceId}_all';
    final stream = _dataStreams[streamKey];
    final totalDataPoints = stream?.dataPoints.length ?? 0;

    return IoTDeviceStats(
      deviceId: deviceId,
      uptime: DateTime.now().difference(device.createdAt),
      totalDataPoints: totalDataPoints,
      averageResponseTime: device.connection?.averageResponseTime ?? Duration.zero,
      errorCount: device.errorCount,
      lastError: device.lastError,
      timestamp: DateTime.now(),
    );
  }

  /// Сканирование устройств
  Future<void> _scanForDevices() async {
    // В реальной реализации здесь будет сканирование сети
    // Для демонстрации создаем несколько тестовых устройств
    await _createTestDevices();
  }

  /// Создание тестовых устройств
  Future<void> _createTestDevices() async {
    final testDevices = [
      {
        'deviceId': 'sensor_temp_001',
        'deviceType': IoTDeviceType.sensor,
        'connectionString': 'mqtt://192.168.1.100:1883',
        'config': {'interval': 5000, 'unit': 'celsius'},
      },
      {
        'deviceId': 'actuator_light_001',
        'deviceType': IoTDeviceType.actuator,
        'connectionString': 'coap://192.168.1.101:5683',
        'config': {'brightness': 80, 'color': 'white'},
      },
      {
        'deviceId': 'camera_security_001',
        'deviceType': IoTDeviceType.camera,
        'connectionString': 'rtsp://192.168.1.102:554',
        'config': {'resolution': '1920x1080', 'fps': 30},
      },
    ];

    for (final deviceInfo in testDevices) {
      await connectDevice(
        deviceId: deviceInfo['deviceId']! as String,
        deviceType: deviceInfo['deviceType']! as IoTDeviceType,
        connectionString: deviceInfo['connectionString']! as String,
        deviceConfig: deviceInfo['config']! as Map<String, dynamic>,
      );
    }
  }

  /// Получение возможностей устройства
  List<IoTCapability> _getDeviceCapabilities(IoTDeviceType deviceType) {
    switch (deviceType) {
      case IoTDeviceType.sensor:
        return [
          IoTCapability.readData,
          IoTCapability.configureInterval,
        ];
      case IoTDeviceType.actuator:
        return [
          IoTCapability.writeData,
          IoTCapability.controlDevice,
        ];
      case IoTDeviceType.camera:
        return [
          IoTCapability.captureImage,
          IoTCapability.streamVideo,
          IoTCapability.configureSettings,
        ];
      case IoTDeviceType.gateway:
        return [
          IoTCapability.readData,
          IoTCapability.writeData,
          IoTCapability.manageDevices,
        ];
      case IoTDeviceType.smartHome:
        return [
          IoTCapability.readData,
          IoTCapability.writeData,
          IoTCapability.controlDevice,
          IoTCapability.configureSettings,
        ];
    }
  }

  /// Установка соединения
  Future<IoTConnection> _establishConnection(IoTDevice device) async {
    final startTime = DateTime.now();

    try {
      // В реальной реализации здесь будет установка реального соединения
      // Для демонстрации имитируем соединение
      await Future.delayed(const Duration(seconds: 2));

      return IoTConnection(
        connectionId: 'conn_${device.deviceId}',
        connectionString: device.connectionString,
        protocol: _detectProtocol(device.connectionString),
        status: ConnectionStatus.connected,
        connectionTime: DateTime.now().difference(startTime),
        averageResponseTime: const Duration(milliseconds: 100),
        lastActivity: DateTime.now(),
      );
    } catch (e) {
      return IoTConnection(
        connectionId: 'conn_${device.deviceId}',
        connectionString: device.connectionString,
        protocol: _detectProtocol(device.connectionString),
        status: ConnectionStatus.failed,
        connectionTime: DateTime.now().difference(startTime),
        averageResponseTime: Duration.zero,
        lastActivity: DateTime.now(),
        errorMessage: e.toString(),
      );
    }
  }

  /// Определение протокола
  IoTProtocol _detectProtocol(String connectionString) {
    if (connectionString.startsWith('mqtt://')) return IoTProtocol.mqtt;
    if (connectionString.startsWith('coap://')) return IoTProtocol.coap;
    if (connectionString.startsWith('rtsp://')) return IoTProtocol.rtsp;
    if (connectionString.startsWith('http://')) return IoTProtocol.http;
    if (connectionString.startsWith('https://')) return IoTProtocol.https;
    return IoTProtocol.unknown;
  }

  /// Инициализация потоков данных
  Future<void> _initializeDataStreams(IoTDevice device) async {
    final streamTypes = _getDataStreamTypes(device.deviceType);

    for (final streamType in streamTypes) {
      final streamKey = '${device.deviceId}_$streamType';
      _dataStreams[streamKey] = IoTDataStream(
        streamId: streamKey,
        deviceId: device.deviceId,
        dataType: streamType,
        dataPoints: const [],
        createdAt: DateTime.now(),
      );
    }
  }

  /// Получение типов потоков данных
  List<String> _getDataStreamTypes(IoTDeviceType deviceType) {
    switch (deviceType) {
      case IoTDeviceType.sensor:
        return ['temperature', 'humidity', 'pressure', 'all'];
      case IoTDeviceType.actuator:
        return ['status', 'power', 'all'];
      case IoTDeviceType.camera:
        return ['image', 'video', 'motion', 'all'];
      case IoTDeviceType.gateway:
        return ['connected_devices', 'network_status', 'all'];
      case IoTDeviceType.smartHome:
        return ['temperature', 'lighting', 'security', 'energy', 'all'];
    }
  }

  /// Запуск мониторинга устройства
  void _startDeviceMonitoring(IoTDevice device) {
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!_connectedDevices.containsKey(device.deviceId)) {
        timer.cancel();
        return;
      }

      await _collectDeviceData(device);
    });
  }

  /// Остановка мониторинга устройства
  void _stopDeviceMonitoring(IoTDevice device) {
    // В реальной реализации здесь будет остановка таймеров мониторинга
  }

  /// Сбор данных с устройства
  Future<void> _collectDeviceData(IoTDevice device) async {
    try {
      final dataTypes = _getDataStreamTypes(device.deviceType);

      for (final dataType in dataTypes) {
        if (dataType == 'all') continue;

        // Генерируем тестовые данные
        final dataPoint = IoTDataPoint(
          pointId: '${device.deviceId}_${DateTime.now().millisecondsSinceEpoch}',
          deviceId: device.deviceId,
          dataType: dataType,
          value: _generateTestValue(dataType),
          unit: _getDataUnit(dataType),
          timestamp: DateTime.now(),
          quality: DataQuality.good,
        );

        // Добавляем в поток данных
        final streamKey = '${device.deviceId}_$dataType';
        final stream = _dataStreams[streamKey];
        if (stream != null) {
          stream.dataPoints.add(dataPoint);

          // Ограничиваем размер потока
          if (stream.dataPoints.length > _maxDataStreamSize) {
            stream.dataPoints.removeAt(0);
          }
        }
      }

      // Обновляем время последней активности
      device.lastSeen = DateTime.now();
      device.connection?.lastActivity = DateTime.now();
    } catch (e) {
      device.errorCount++;
      device.lastError = e.toString();
    }
  }

  /// Генерация тестового значения
  double _generateTestValue(String dataType) {
    switch (dataType) {
      case 'temperature':
        return 20.0 + Random().nextDouble() * 10.0;
      case 'humidity':
        return 40.0 + Random().nextDouble() * 20.0;
      case 'pressure':
        return 1000.0 + Random().nextDouble() * 50.0;
      case 'status':
        return Random().nextBool() ? 1.0 : 0.0;
      case 'power':
        return 50.0 + Random().nextDouble() * 100.0;
      default:
        return Random().nextDouble() * 100.0;
    }
  }

  /// Получение единицы измерения
  String _getDataUnit(String dataType) {
    switch (dataType) {
      case 'temperature':
        return '°C';
      case 'humidity':
        return '%';
      case 'pressure':
        return 'hPa';
      case 'power':
        return 'W';
      default:
        return '';
    }
  }

  /// Выполнение команды
  Future<IoTCommandResult> _executeCommand(
    IoTDevice device,
    IoTCommand command,
    Map<String, dynamic>? parameters,
    Duration? timeout,
  ) async {
    final startTime = DateTime.now();

    try {
      // В реальной реализации здесь будет выполнение команды на устройстве
      // Для демонстрации имитируем выполнение
      await Future.delayed(Duration(milliseconds: 100 + Random().nextInt(500)));

      return IoTCommandResult(
        commandId: command.commandId,
        deviceId: device.deviceId,
        success: true,
        executionTime: DateTime.now().difference(startTime),
        result: {'status': 'completed', 'parameters': parameters},
      );
    } catch (e) {
      return IoTCommandResult(
        commandId: command.commandId,
        deviceId: device.deviceId,
        success: false,
        errorMessage: e.toString(),
        executionTime: DateTime.now().difference(startTime),
      );
    }
  }

  /// Закрытие соединения
  Future<void> _closeConnection(IoTDevice device) async {
    // В реальной реализации здесь будет закрытие реального соединения
    device.connection?.status = ConnectionStatus.disconnected;
  }

  /// Настройка мониторинга устройств
  void _setupDeviceMonitoring() {
    Timer.periodic(const Duration(minutes: 1), (timer) async {
      await _checkDeviceHealth();
    });
  }

  /// Проверка здоровья устройств
  Future<void> _checkDeviceHealth() async {
    final now = DateTime.now();

    for (final device in _connectedDevices.values) {
      final timeSinceLastSeen = now.difference(device.lastSeen);

      if (timeSinceLastSeen.inSeconds > _deviceTimeoutSeconds) {
        device.status = DeviceStatus.disconnected;
        device.connection?.status = ConnectionStatus.disconnected;
      }
    }
  }

  /// Настройка сбора данных
  void _setupDataCollection() {
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      await _processDataStreams();
    });
  }

  /// Обработка потоков данных
  Future<void> _processDataStreams() async {
    for (final stream in _dataStreams.values) {
      await _processDataStream(stream);
    }
  }

  /// Обработка потока данных
  Future<void> _processDataStream(IoTDataStream stream) async {
    // Проверяем алерты
    await _checkAlerts(stream);

    // Выполняем агрегацию данных
    await _aggregateData(stream);
  }

  /// Проверка алертов
  Future<void> _checkAlerts(IoTDataStream stream) async {
    final deviceAlerts = _activeAlerts.values.where((alert) => alert.deviceId == stream.deviceId).toList();

    for (final alert in deviceAlerts) {
      await _evaluateAlert(alert, stream);
    }
  }

  /// Оценка алерта
  Future<void> _evaluateAlert(IoTAlert alert, IoTDataStream stream) async {
    // В реальной реализации здесь будет оценка условий алерта
    // Для демонстрации проверяем простые условия
    if (stream.dataPoints.isNotEmpty) {
      final latestData = stream.dataPoints.last;

      // Пример: алерт на высокую температуру
      if (stream.dataType == 'temperature' && latestData.value > 30.0) {
        alert.lastTriggered = DateTime.now();
        // Здесь можно отправить уведомление
      }
    }
  }

  /// Агрегация данных
  Future<void> _aggregateData(IoTDataStream stream) async {
    // В реальной реализации здесь будет агрегация данных
    // Для демонстрации просто логируем
  }

  /// Настройка обработки команд
  void _setupCommandProcessing() {
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      await _processCommandQueues();
    });
  }

  /// Обработка очередей команд
  Future<void> _processCommandQueues() async {
    for (final queue in _commandQueues.values) {
      if (queue.commands.isNotEmpty) {
        final command = queue.commands.removeAt(0);
        // Команда уже обрабатывается в sendCommand
      }
    }
  }

  /// Выполнение агрегации
  double _performAggregation(List<IoTDataPoint> dataPoints, AggregationType type) {
    if (dataPoints.isEmpty) return 0.0;

    switch (type) {
      case AggregationType.average:
        return dataPoints.map((dp) => dp.value).reduce((a, b) => a + b) / dataPoints.length;
      case AggregationType.sum:
        return dataPoints.map((dp) => dp.value).reduce((a, b) => a + b);
      case AggregationType.min:
        return dataPoints.map((dp) => dp.value).reduce((a, b) => a < b ? a : b);
      case AggregationType.max:
        return dataPoints.map((dp) => dp.value).reduce((a, b) => a > b ? a : b);
      case AggregationType.count:
        return dataPoints.length.toDouble();
    }
  }

  /// Получение всех устройств
  List<IoTDevice> getAllDevices() {
    return _connectedDevices.values.toList();
  }

  /// Получение истории команд
  List<IoTCommand> getCommandHistory() {
    final commands = <IoTCommand>[];
    for (final queue in _commandQueues.values) {
      commands.addAll(queue.commands);
    }
    return commands;
  }

  /// Удаление устройства
  Future<bool> removeDevice(String deviceId) async {
    if (_connectedDevices.containsKey(deviceId)) {
      _connectedDevices.remove(deviceId);
      return true;
    }
    return false;
  }

  /// Освобождение ресурсов
  void dispose() {
    _connectedDevices.clear();
    _deviceGroups.clear();
    _dataStreams.clear();
    _commandQueues.clear();
    _activeAlerts.clear();
  }
}

/// IoT устройство
class IoTDevice extends Equatable {
  final String deviceId;
  final IoTDeviceType deviceType;
  final String connectionString;
  final Map<String, dynamic> config;
  final DeviceStatus status;
  final List<IoTCapability> capabilities;
  final DateTime lastSeen;
  final DateTime createdAt;
  IoTConnection? connection;
  int errorCount = 0;
  String? lastError;

  IoTDevice({
    required this.deviceId,
    required this.deviceType,
    required this.connectionString,
    required this.config,
    required this.status,
    required this.capabilities,
    required this.lastSeen,
    required this.createdAt,
    this.connection,
  });

  @override
  List<Object?> get props =>
      [deviceId, deviceType, connectionString, config, status, capabilities, lastSeen, createdAt, connection];
}

/// Типы IoT устройств
enum IoTDeviceType {
  sensor,
  actuator,
  camera,
  gateway,
  smartHome,
}

/// Статусы устройств
enum DeviceStatus {
  disconnected,
  connecting,
  connected,
  error,
}

/// Возможности IoT устройств
enum IoTCapability {
  readData,
  writeData,
  controlDevice,
  configureSettings,
  configureInterval,
  captureImage,
  streamVideo,
  manageDevices,
}

/// IoT соединение
class IoTConnection extends Equatable {
  final String connectionId;
  final String connectionString;
  final IoTProtocol protocol;
  final ConnectionStatus status;
  final Duration connectionTime;
  final Duration averageResponseTime;
  final DateTime lastActivity;
  final String? errorMessage;

  const IoTConnection({
    required this.connectionId,
    required this.connectionString,
    required this.protocol,
    required this.status,
    required this.connectionTime,
    required this.averageResponseTime,
    required this.lastActivity,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        connectionId,
        connectionString,
        protocol,
        status,
        connectionTime,
        averageResponseTime,
        lastActivity,
        errorMessage
      ];
}

/// Протоколы IoT
enum IoTProtocol {
  mqtt,
  coap,
  rtsp,
  http,
  https,
  unknown,
}

/// Статусы соединений
enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  failed,
}

/// Результат подключения IoT устройства
class IoTConnectionResult extends Equatable {
  final String deviceId;
  final bool success;
  final String? errorMessage;
  final Duration connectionTime;

  const IoTConnectionResult({
    required this.deviceId,
    required this.success,
    this.errorMessage,
    required this.connectionTime,
  });

  @override
  List<Object?> get props => [deviceId, success, errorMessage, connectionTime];
}

/// IoT команда
class IoTCommand extends Equatable {
  final String commandId;
  final String commandName;
  final Map<String, dynamic> parameters;

  const IoTCommand({
    required this.commandId,
    required this.commandName,
    required this.parameters,
  });

  @override
  List<Object?> get props => [commandId, commandName, parameters];
}

/// Результат выполнения IoT команды
class IoTCommandResult extends Equatable {
  final String commandId;
  final String deviceId;
  final bool success;
  final String? errorMessage;
  final Duration executionTime;
  final Map<String, dynamic>? result;

  const IoTCommandResult({
    required this.commandId,
    required this.deviceId,
    required this.success,
    this.errorMessage,
    required this.executionTime,
    this.result,
  });

  @override
  List<Object?> get props => [commandId, deviceId, success, errorMessage, executionTime, result];
}

/// Точка данных IoT
class IoTDataPoint extends Equatable {
  final String pointId;
  final String deviceId;
  final String dataType;
  final double value;
  final String unit;
  final DateTime timestamp;
  final DataQuality quality;

  const IoTDataPoint({
    required this.pointId,
    required this.deviceId,
    required this.dataType,
    required this.value,
    required this.unit,
    required this.timestamp,
    required this.quality,
  });

  @override
  List<Object?> get props => [pointId, deviceId, dataType, value, unit, timestamp, quality];
}

/// Качество данных
enum DataQuality {
  poor,
  fair,
  good,
  excellent,
}

/// Поток данных IoT
class IoTDataStream extends Equatable {
  final String streamId;
  final String deviceId;
  final String dataType;
  final List<IoTDataPoint> dataPoints;
  final DateTime createdAt;

  const IoTDataStream({
    required this.streamId,
    required this.deviceId,
    required this.dataType,
    required this.dataPoints,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [streamId, deviceId, dataType, dataPoints, createdAt];
}

/// Группа IoT устройств
class IoTDeviceGroup extends Equatable {
  final String groupId;
  final String name;
  final List<IoTDevice> devices;
  final IoTGroupConfig config;
  final DateTime createdAt;
  final GroupStatus status;

  const IoTDeviceGroup({
    required this.groupId,
    required this.name,
    required this.devices,
    required this.config,
    required this.createdAt,
    required this.status,
  });

  @override
  List<Object?> get props => [groupId, name, devices, config, createdAt, status];
}

/// Конфигурация группы IoT устройств
class IoTGroupConfig extends Equatable {
  final bool autoSync;
  final Duration syncInterval;
  final List<String> allowedCommands;

  const IoTGroupConfig({
    required this.autoSync,
    required this.syncInterval,
    required this.allowedCommands,
  });

  @override
  List<Object?> get props => [autoSync, syncInterval, allowedCommands];
}

/// Статусы групп
enum GroupStatus {
  active,
  paused,
  inactive,
}

/// Агрегированные данные IoT
class IoTAggregatedData extends Equatable {
  final String groupId;
  final String dataType;
  final AggregationType aggregationType;
  final double value;
  final DateTime timestamp;
  final int deviceCount;

  const IoTAggregatedData({
    required this.groupId,
    required this.dataType,
    required this.aggregationType,
    required this.value,
    required this.timestamp,
    required this.deviceCount,
  });

  @override
  List<Object?> get props => [groupId, dataType, aggregationType, value, timestamp, deviceCount];
}

/// Типы агрегации
enum AggregationType {
  average,
  sum,
  min,
  max,
  count,
}

/// Очередь команд IoT
class IoTCommandQueue extends Equatable {
  final String deviceId;
  final List<IoTCommand> commands;

  const IoTCommandQueue({
    required this.deviceId,
    required this.commands,
  });

  @override
  List<Object?> get props => [deviceId, commands];
}

/// Алерт IoT
class IoTAlert extends Equatable {
  final String alertId;
  final String deviceId;
  final AlertType alertType;
  final String condition;
  final AlertSeverity severity;
  final Map<String, dynamic> parameters;
  final AlertStatus status;
  final DateTime createdAt;
  final DateTime? lastTriggered;

  const IoTAlert({
    required this.alertId,
    required this.deviceId,
    required this.alertType,
    required this.condition,
    required this.severity,
    required this.parameters,
    required this.status,
    required this.createdAt,
    this.lastTriggered,
  });

  @override
  List<Object?> get props =>
      [alertId, deviceId, alertType, condition, severity, parameters, status, createdAt, lastTriggered];
}

/// Типы алертов
enum AlertType {
  threshold,
  anomaly,
  connection,
  battery,
  maintenance,
}

/// Серьезность алертов
enum AlertSeverity {
  low,
  medium,
  high,
  critical,
}

/// Статусы алертов
enum AlertStatus {
  active,
  paused,
  resolved,
  disabled,
}

/// Статистика IoT устройства
class IoTDeviceStats extends Equatable {
  final String deviceId;
  final Duration uptime;
  final int totalDataPoints;
  final Duration averageResponseTime;
  final int errorCount;
  final String? lastError;
  final DateTime timestamp;

  const IoTDeviceStats({
    required this.deviceId,
    required this.uptime,
    required this.totalDataPoints,
    required this.averageResponseTime,
    required this.errorCount,
    this.lastError,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [deviceId, uptime, totalDataPoints, averageResponseTime, errorCount, lastError, timestamp];
}
