import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';

/// Сервис для мобильной интеграции и push-уведомлений
class MobileIntegrationService {
  static final MobileIntegrationService _instance = MobileIntegrationService._internal();

  // Мобильные устройства
  final Map<String, MobileDevice> _registeredDevices = {};
  final Map<String, PushNotificationChannel> _notificationChannels = {};
  final Map<String, PushNotification> _notifications = {};

  // Конфигурация
  static const Duration _notificationRetentionTime = Duration(days: 30);
  static const int _maxNotificationsPerDevice = 1000;
  static const Duration _deviceHeartbeatInterval = Duration(minutes: 5);

  factory MobileIntegrationService() => _instance;
  MobileIntegrationService._internal();

  /// Инициализация сервиса
  Future<void> initialize() async {
    await _loadDeviceConfigurations();
    _setupDeviceMonitoring();
    _setupNotificationCleanup();
  }

  /// Регистрация мобильного устройства
  Future<DeviceRegistrationResult> registerDevice({
    required String deviceId,
    required String userId,
    required DevicePlatform platform,
    required String deviceToken,
    Map<String, dynamic>? deviceInfo,
  }) async {
    try {
      final device = MobileDevice(
        deviceId: deviceId,
        userId: userId,
        platform: platform,
        deviceToken: deviceToken,
        deviceInfo: deviceInfo ?? {},
        isActive: true,
        registeredAt: DateTime.now(),
        lastSeen: DateTime.now(),
        notificationCount: 0,
        pushEnabled: true,
      );

      _registeredDevices[deviceId] = device;

      // Создаем канал уведомлений по умолчанию
      await _createDefaultNotificationChannel(deviceId);

      return DeviceRegistrationResult(
        deviceId: deviceId,
        success: true,
      );
    } catch (e) {
      return DeviceRegistrationResult(
        deviceId: deviceId,
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Отправка push-уведомления
  Future<PushNotificationResult> sendPushNotification({
    required String deviceId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? channelId,
    PushNotificationPriority priority = PushNotificationPriority.normal,
    bool requireDeliveryConfirmation = false,
  }) async {
    final device = _registeredDevices[deviceId];
    if (device == null) {
      return PushNotificationResult(
        notificationId: '',
        success: false,
        errorMessage: 'Device not found: $deviceId',
      );
    }

    if (!device.isActive || !device.pushEnabled) {
      return const PushNotificationResult(
        notificationId: '',
        success: false,
        errorMessage: 'Device is not active or push notifications are disabled',
      );
    }

    try {
      final notificationId = _generateId();
      final notification = PushNotification(
        notificationId: notificationId,
        deviceId: deviceId,
        userId: device.userId,
        title: title,
        body: body,
        data: data ?? {},
        channelId: channelId,
        priority: priority,
        sentAt: DateTime.now(),
        deliveredAt: null,
        readAt: null,
        status: NotificationStatus.sent,
        requireDeliveryConfirmation: requireDeliveryConfirmation,
      );

      _notifications[notificationId] = notification;

      // Отправляем уведомление
      final deliveryResult = await _deliverNotification(device, notification);

      if (deliveryResult.success) {
        notification.status = NotificationStatus.delivered;
        notification.deliveredAt = DateTime.now();
        device.notificationCount++;
      } else {
        notification.status = NotificationStatus.failed;
      }

      return PushNotificationResult(
        notificationId: notificationId,
        success: deliveryResult.success,
        errorMessage: deliveryResult.errorMessage,
      );
    } catch (e) {
      return PushNotificationResult(
        notificationId: '',
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Создание канала уведомлений
  Future<NotificationChannelResult> createNotificationChannel({
    required String channelId,
    required String deviceId,
    required String name,
    required String description,
    PushNotificationPriority importance = PushNotificationPriority.normal,
    bool enableVibration = true,
    bool enableSound = true,
    String? customSound,
  }) async {
    try {
      final channel = PushNotificationChannel(
        channelId: channelId,
        deviceId: deviceId,
        name: name,
        description: description,
        importance: importance,
        enableVibration: enableVibration,
        enableSound: enableSound,
        customSound: customSound,
        isActive: true,
        createdAt: DateTime.now(),
        notificationCount: 0,
      );

      _notificationChannels[channelId] = channel;

      return NotificationChannelResult(
        channelId: channelId,
        success: true,
      );
    } catch (e) {
      return NotificationChannelResult(
        channelId: channelId,
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Отправка уведомления всем устройствам пользователя
  Future<List<PushNotificationResult>> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? channelId,
    PushNotificationPriority priority = PushNotificationPriority.normal,
  }) async {
    final userDevices = _registeredDevices.values
        .where((device) => device.userId == userId && device.isActive && device.pushEnabled)
        .toList();

    final results = <PushNotificationResult>[];

    for (final device in userDevices) {
      final result = await sendPushNotification(
        deviceId: device.deviceId,
        title: title,
        body: body,
        data: data,
        channelId: channelId,
        priority: priority,
      );
      results.add(result);
    }

    return results;
  }

  /// Отправка массового уведомления
  Future<List<PushNotificationResult>> sendBroadcastNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? channelId,
    PushNotificationPriority priority = PushNotificationPriority.normal,
    List<String>? targetUserIds,
  }) async {
    final targetDevices = _registeredDevices.values
        .where((device) => device.isActive && device.pushEnabled)
        .where((device) => targetUserIds == null || targetUserIds.contains(device.userId))
        .toList();

    final results = <PushNotificationResult>[];

    for (final device in targetDevices) {
      final result = await sendPushNotification(
        deviceId: device.deviceId,
        title: title,
        body: body,
        data: data,
        channelId: channelId,
        priority: priority,
      );
      results.add(result);
    }

    return results;
  }

  /// Получение статистики уведомлений
  Future<NotificationStatistics> getNotificationStatistics({
    String? deviceId,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var notifications = _notifications.values.toList();

    if (deviceId != null) {
      notifications = notifications.where((n) => n.deviceId == deviceId).toList();
    }
    if (userId != null) {
      notifications = notifications.where((n) => n.userId == userId).toList();
    }
    if (startDate != null) {
      notifications = notifications.where((n) => n.sentAt.isAfter(startDate)).toList();
    }
    if (endDate != null) {
      notifications = notifications.where((n) => n.sentAt.isBefore(endDate)).toList();
    }

    final totalSent = notifications.length;
    final delivered = notifications.where((n) => n.status == NotificationStatus.delivered).length;
    final failed = notifications.where((n) => n.status == NotificationStatus.failed).length;
    final read = notifications.where((n) => n.readAt != null).length;

    return NotificationStatistics(
      totalSent: totalSent,
      delivered: delivered,
      failed: failed,
      read: read,
      deliveryRate: totalSent > 0 ? delivered / totalSent : 0.0,
      readRate: delivered > 0 ? read / delivered : 0.0,
      periodStart: startDate,
      periodEnd: endDate,
    );
  }

  /// Обновление статуса устройства
  Future<bool> updateDeviceStatus({
    required String deviceId,
    bool? isActive,
    bool? pushEnabled,
    String? deviceToken,
  }) async {
    final device = _registeredDevices[deviceId];
    if (device == null) return false;

    if (isActive != null) device.isActive = isActive;
    if (pushEnabled != null) device.pushEnabled = pushEnabled;
    if (deviceToken != null) device.deviceToken = deviceToken;

    device.lastSeen = DateTime.now();
    return true;
  }

  /// Получение зарегистрированных устройств
  List<MobileDevice> getRegisteredDevices({String? userId}) {
    final devices = _registeredDevices.values.toList();
    if (userId != null) {
      return devices.where((device) => device.userId == userId).toList();
    }
    return devices;
  }

  /// Получение каналов уведомлений
  List<PushNotificationChannel> getNotificationChannels({String? deviceId}) {
    final channels = _notificationChannels.values.toList();
    if (deviceId != null) {
      return channels.where((channel) => channel.deviceId == deviceId).toList();
    }
    return channels;
  }

  /// Удаление устройства
  Future<bool> unregisterDevice(String deviceId) async {
    final device = _registeredDevices.remove(deviceId);
    if (device == null) return false;

    // Удаляем связанные каналы уведомлений
    _notificationChannels.removeWhere((key, channel) => channel.deviceId == deviceId);

    // Удаляем уведомления устройства
    _notifications.removeWhere((key, notification) => notification.deviceId == deviceId);

    return true;
  }

  /// Загрузка конфигураций устройств
  Future<void> _loadDeviceConfigurations() async {
    // В реальной реализации здесь будет загрузка из базы данных
    // Для демонстрации создаем несколько тестовых устройств
    await _createTestDevices();
  }

  /// Создание тестовых устройств
  Future<void> _createTestDevices() async {
    // Android устройство
    await registerDevice(
      deviceId: 'android_device_1',
      userId: 'user_1',
      platform: DevicePlatform.android,
      deviceToken: 'android_token_123',
      deviceInfo: {
        'model': 'Samsung Galaxy S21',
        'os_version': 'Android 12',
        'app_version': '1.0.0',
      },
    );

    // iOS устройство
    await registerDevice(
      deviceId: 'ios_device_1',
      userId: 'user_2',
      platform: DevicePlatform.ios,
      deviceToken: 'ios_token_456',
      deviceInfo: {
        'model': 'iPhone 13 Pro',
        'os_version': 'iOS 15',
        'app_version': '1.0.0',
      },
    );
  }

  /// Настройка мониторинга устройств
  void _setupDeviceMonitoring() {
    Timer.periodic(_deviceHeartbeatInterval, (timer) async {
      await _checkDeviceHealth();
    });
  }

  /// Настройка очистки уведомлений
  void _setupNotificationCleanup() {
    Timer.periodic(const Duration(hours: 1), (timer) async {
      await _cleanupOldNotifications();
    });
  }

  /// Создание канала уведомлений по умолчанию
  Future<void> _createDefaultNotificationChannel(String deviceId) async {
    await createNotificationChannel(
      channelId: '${deviceId}_default',
      deviceId: deviceId,
      name: 'Default',
      description: 'Default notification channel',
      importance: PushNotificationPriority.normal,
    );
  }

  /// Доставка уведомления
  Future<DeliveryResult> _deliverNotification(MobileDevice device, PushNotification notification) async {
    // Имитация доставки уведомления через FCM/APNS
    await Future.delayed(const Duration(milliseconds: 100));

    // Имитация 95% успешной доставки
    final success = Random().nextDouble() > 0.05;

    return DeliveryResult(
      success: success,
      errorMessage: success ? null : 'Delivery failed: Network error',
    );
  }

  /// Проверка здоровья устройств
  Future<void> _checkDeviceHealth() async {
    final now = DateTime.now();
    final inactiveThreshold = now.subtract(const Duration(minutes: 30));

    for (final device in _registeredDevices.values) {
      if (device.lastSeen.isBefore(inactiveThreshold)) {
        device.isActive = false;
      }
    }
  }

  /// Очистка старых уведомлений
  Future<void> _cleanupOldNotifications() async {
    final cutoffDate = DateTime.now().subtract(_notificationRetentionTime);
    _notifications.removeWhere((key, notification) => notification.sentAt.isBefore(cutoffDate));

    // Ограничиваем количество уведомлений на устройство
    final deviceNotificationCounts = <String, int>{};
    for (final notification in _notifications.values) {
      deviceNotificationCounts[notification.deviceId] = (deviceNotificationCounts[notification.deviceId] ?? 0) + 1;
    }

    for (final entry in deviceNotificationCounts.entries) {
      if (entry.value > _maxNotificationsPerDevice) {
        final deviceNotifications = _notifications.values.where((n) => n.deviceId == entry.key).toList()
          ..sort((a, b) => a.sentAt.compareTo(b.sentAt));

        final toRemove = deviceNotifications.take(entry.value - _maxNotificationsPerDevice);
        for (final notification in toRemove) {
          _notifications.remove(notification.notificationId);
        }
      }
    }
  }

  /// Генерация уникального ID
  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';
  }

  /// Освобождение ресурсов
  void dispose() {
    _registeredDevices.clear();
    _notificationChannels.clear();
    _notifications.clear();
  }
}

/// Модели данных

/// Мобильное устройство
class MobileDevice extends Equatable {
  final String deviceId;
  final String userId;
  final DevicePlatform platform;
  String deviceToken;
  final Map<String, dynamic> deviceInfo;
  bool isActive;
  final DateTime registeredAt;
  DateTime lastSeen;
  int notificationCount;
  bool pushEnabled;

  const MobileDevice({
    required this.deviceId,
    required this.userId,
    required this.platform,
    required this.deviceToken,
    required this.deviceInfo,
    required this.isActive,
    required this.registeredAt,
    required this.lastSeen,
    required this.notificationCount,
    required this.pushEnabled,
  });

  @override
  List<Object?> get props => [
        deviceId,
        userId,
        platform,
        deviceToken,
        deviceInfo,
        isActive,
        registeredAt,
        lastSeen,
        notificationCount,
        pushEnabled,
      ];
}

/// Канал push-уведомлений
class PushNotificationChannel extends Equatable {
  final String channelId;
  final String deviceId;
  final String name;
  final String description;
  final PushNotificationPriority importance;
  final bool enableVibration;
  final bool enableSound;
  final String? customSound;
  bool isActive;
  final DateTime createdAt;
  int notificationCount;

  const PushNotificationChannel({
    required this.channelId,
    required this.deviceId,
    required this.name,
    required this.description,
    required this.importance,
    required this.enableVibration,
    required this.enableSound,
    this.customSound,
    required this.isActive,
    required this.createdAt,
    required this.notificationCount,
  });

  @override
  List<Object?> get props => [
        channelId,
        deviceId,
        name,
        description,
        importance,
        enableVibration,
        enableSound,
        customSound,
        isActive,
        createdAt,
        notificationCount,
      ];
}

/// Push-уведомление
class PushNotification extends Equatable {
  final String notificationId;
  final String deviceId;
  final String userId;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final String? channelId;
  final PushNotificationPriority priority;
  final DateTime sentAt;
  DateTime? deliveredAt;
  DateTime? readAt;
  NotificationStatus status;
  final bool requireDeliveryConfirmation;

  const PushNotification({
    required this.notificationId,
    required this.deviceId,
    required this.userId,
    required this.title,
    required this.body,
    required this.data,
    this.channelId,
    required this.priority,
    required this.sentAt,
    this.deliveredAt,
    this.readAt,
    required this.status,
    required this.requireDeliveryConfirmation,
  });

  @override
  List<Object?> get props => [
        notificationId,
        deviceId,
        userId,
        title,
        body,
        data,
        channelId,
        priority,
        sentAt,
        deliveredAt,
        readAt,
        status,
        requireDeliveryConfirmation,
      ];
}

/// Статистика уведомлений
class NotificationStatistics extends Equatable {
  final int totalSent;
  final int delivered;
  final int failed;
  final int read;
  final double deliveryRate;
  final double readRate;
  final DateTime? periodStart;
  final DateTime? periodEnd;

  const NotificationStatistics({
    required this.totalSent,
    required this.delivered,
    required this.failed,
    required this.read,
    required this.deliveryRate,
    required this.readRate,
    this.periodStart,
    this.periodEnd,
  });

  @override
  List<Object?> get props => [
        totalSent,
        delivered,
        failed,
        read,
        deliveryRate,
        readRate,
        periodStart,
        periodEnd,
      ];
}

/// Результат регистрации устройства
class DeviceRegistrationResult extends Equatable {
  final String deviceId;
  final bool success;
  final String? errorMessage;

  const DeviceRegistrationResult({
    required this.deviceId,
    required this.success,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [deviceId, success, errorMessage];
}

/// Результат отправки push-уведомления
class PushNotificationResult extends Equatable {
  final String notificationId;
  final bool success;
  final String? errorMessage;

  const PushNotificationResult({
    required this.notificationId,
    required this.success,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [notificationId, success, errorMessage];
}

/// Результат создания канала уведомлений
class NotificationChannelResult extends Equatable {
  final String channelId;
  final bool success;
  final String? errorMessage;

  const NotificationChannelResult({
    required this.channelId,
    required this.success,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [channelId, success, errorMessage];
}

/// Результат доставки
class DeliveryResult extends Equatable {
  final bool success;
  final String? errorMessage;

  const DeliveryResult({
    required this.success,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [success, errorMessage];
}

/// Перечисления

/// Платформа устройства
enum DevicePlatform { android, ios, web, desktop }

/// Приоритет push-уведомления
enum PushNotificationPriority { low, normal, high, urgent }

/// Статус уведомления
enum NotificationStatus { sent, delivered, failed, read }
