import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:equatable/equatable.dart';

/// Сервис дашборда для мониторинга системы Katya
class DashboardService {
  static final DashboardService _instance = DashboardService._internal();

  // Компоненты дашборда
  final Map<String, DashboardWidget> _widgets = {};
  final Map<String, DashboardLayout> _layouts = {};
  final Map<String, DashboardTheme> _themes = {};
  final Map<String, DashboardUser> _users = {};

  // Данные и метрики
  final Map<String, DashboardMetric> _metrics = {};
  final Map<String, DashboardAlert> _alerts = {};
  final Map<String, DashboardEvent> _events = {};

  // Конфигурация
  static const Duration _dataRefreshInterval = Duration(seconds: 30);
  static const Duration _alertCheckInterval = Duration(minutes: 1);
  static const int _maxEventsHistory = 1000;

  // Таймеры
  Timer? _dataRefreshTimer;
  Timer? _alertCheckTimer;

  factory DashboardService() => _instance;
  DashboardService._internal();

  /// Инициализация сервиса дашборда
  Future<void> initialize() async {
    await _loadDashboardConfiguration();
    await _initializeDefaultWidgets();
    await _initializeDefaultLayouts();
    await _initializeDefaultThemes();
    _setupDataRefresh();
    _setupAlertMonitoring();
  }

  /// Создание виджета дашборда
  DashboardWidget createWidget({
    required String widgetId,
    required String name,
    required WidgetType type,
    required Map<String, dynamic> configuration,
    WidgetPosition? position,
    WidgetSize? size,
    String? description,
  }) {
    final widget = DashboardWidget(
      widgetId: widgetId,
      name: name,
      type: type,
      configuration: configuration,
      position: position ?? const WidgetPosition(x: 0, y: 0),
      size: size ?? const WidgetSize(width: 300, height: 200),
      description: description,
      isVisible: true,
      refreshInterval: Duration(seconds: configuration['refresh_interval'] ?? 30),
      createdAt: DateTime.now(),
      lastUpdated: null,
    );

    _widgets[widgetId] = widget;
    return widget;
  }

  /// Создание макета дашборда
  DashboardLayout createLayout({
    required String layoutId,
    required String name,
    required List<String> widgetIds,
    LayoutType type = LayoutType.grid,
    Map<String, dynamic>? configuration,
    String? description,
  }) {
    final layout = DashboardLayout(
      layoutId: layoutId,
      name: name,
      widgetIds: widgetIds,
      type: type,
      configuration: configuration ?? {},
      description: description,
      isActive: false,
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
    );

    _layouts[layoutId] = layout;
    return layout;
  }

  /// Создание темы дашборда
  DashboardTheme createTheme({
    required String themeId,
    required String name,
    required Map<String, dynamic> colors,
    required Map<String, dynamic> typography,
    Map<String, dynamic>? spacing,
    Map<String, dynamic>? effects,
    String? description,
  }) {
    final theme = DashboardTheme(
      themeId: themeId,
      name: name,
      colors: colors,
      typography: typography,
      spacing: spacing ?? {},
      effects: effects ?? {},
      description: description,
      isDefault: false,
      createdAt: DateTime.now(),
    );

    _themes[themeId] = theme;
    return theme;
  }

  /// Регистрация пользователя дашборда
  DashboardUser registerUser({
    required String userId,
    required String username,
    required String email,
    List<String>? roles,
    Map<String, dynamic>? preferences,
  }) {
    final user = DashboardUser(
      userId: userId,
      username: username,
      email: email,
      roles: roles ?? ['viewer'],
      preferences: preferences ?? {},
      isActive: true,
      lastLogin: null,
      createdAt: DateTime.now(),
      dashboardLayouts: const [],
    );

    _users[userId] = user;
    return user;
  }

  /// Получение данных виджета
  Future<WidgetData> getWidgetData(
    String widgetId, {
    Map<String, dynamic>? parameters,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final widget = _widgets[widgetId];
    if (widget == null) {
      throw Exception('Widget not found: $widgetId');
    }

    try {
      switch (widget.type) {
        case WidgetType.metricCard:
          return await _getMetricCardData(widget, parameters);
        case WidgetType.chart:
          return await _getChartData(widget, parameters, startDate, endDate);
        case WidgetType.table:
          return await _getTableData(widget, parameters);
        case WidgetType.alertList:
          return await _getAlertListData(widget, parameters);
        case WidgetType.systemStatus:
          return await _getSystemStatusData(widget, parameters);
        case WidgetType.userActivity:
          return await _getUserActivityData(widget, parameters, startDate, endDate);
        case WidgetType.performanceGraph:
          return await _getPerformanceGraphData(widget, parameters, startDate, endDate);
        case WidgetType.logViewer:
          return await _getLogViewerData(widget, parameters);
        case WidgetType.customHtml:
          return await _getCustomHtmlData(widget, parameters);
      }
    } catch (e) {
      return WidgetData(
        widgetId: widgetId,
        data: {'error': e.toString()},
        metadata: {'error': true, 'timestamp': DateTime.now().toIso8601String()},
        lastUpdated: DateTime.now(),
      );
    }
  }

  /// Обновление данных виджета
  Future<void> refreshWidget(String widgetId) async {
    final widget = _widgets[widgetId];
    if (widget == null) return;

    try {
      final data = await getWidgetData(widgetId);
      widget.lastUpdated = DateTime.now();

      _recordEvent(DashboardEventType.widgetRefreshed, widgetId, {
        'widget_name': widget.name,
        'widget_type': widget.type.name,
      });
    } catch (e) {
      _recordEvent(DashboardEventType.widgetError, widgetId, {
        'error': e.toString(),
      });
    }
  }

  /// Обновление всех виджетов
  Future<void> refreshAllWidgets() async {
    final refreshFutures = _widgets.keys.map((widgetId) => refreshWidget(widgetId));
    await Future.wait(refreshFutures);
  }

  /// Получение активного макета пользователя
  DashboardLayout? getUserActiveLayout(String userId) {
    final user = _users[userId];
    if (user == null) return null;

    for (final layoutId in user.dashboardLayouts) {
      final layout = _layouts[layoutId];
      if (layout != null && layout.isActive) {
        return layout;
      }
    }

    // Возвращаем макет по умолчанию
    return _layouts.values.firstWhere(
      (layout) => layout.name == 'Default',
      orElse: () => _layouts.values.first,
    );
  }

  /// Установка активного макета для пользователя
  Future<bool> setUserActiveLayout(String userId, String layoutId) async {
    final user = _users[userId];
    final layout = _layouts[layoutId];

    if (user == null || layout == null) {
      return false;
    }

    // Деактивируем текущий активный макет
    for (final currentLayoutId in user.dashboardLayouts) {
      final currentLayout = _layouts[currentLayoutId];
      if (currentLayout != null) {
        currentLayout.isActive = false;
      }
    }

    // Активируем новый макет
    layout.isActive = true;
    if (!user.dashboardLayouts.contains(layoutId)) {
      user.dashboardLayouts.add(layoutId);
    }

    _recordEvent(DashboardEventType.layoutChanged, userId, {
      'layout_id': layoutId,
      'layout_name': layout.name,
    });

    return true;
  }

  /// Получение метрик системы
  Future<List<DashboardMetric>> getSystemMetrics({
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var metrics = _metrics.values.toList();

    if (category != null) {
      metrics = metrics.where((m) => m.category == category).toList();
    }

    if (startDate != null) {
      metrics = metrics.where((m) => m.timestamp.isAfter(startDate)).toList();
    }

    if (endDate != null) {
      metrics = metrics.where((m) => m.timestamp.isBefore(endDate)).toList();
    }

    metrics.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return metrics;
  }

  /// Получение активных алертов
  List<DashboardAlert> getActiveAlerts({AlertSeverity? severity}) {
    var alerts = _alerts.values.where((alert) => alert.isActive).toList();

    if (severity != null) {
      alerts = alerts.where((alert) => alert.severity == severity).toList();
    }

    alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return alerts;
  }

  /// Получение событий дашборда
  List<DashboardEvent> getDashboardEvents({
    DashboardEventType? type,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) {
    var events = _events.values.toList();

    if (type != null) {
      events = events.where((e) => e.type == type).toList();
    }

    if (startDate != null) {
      events = events.where((e) => e.timestamp.isAfter(startDate)).toList();
    }

    if (endDate != null) {
      events = events.where((e) => e.timestamp.isBefore(endDate)).toList();
    }

    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (limit != null) {
      events = events.take(limit).toList();
    }

    return events;
  }

  /// Экспорт данных дашборда
  Future<DashboardExport> exportDashboard({
    required String userId,
    required ExportFormat format,
    List<String>? widgetIds,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final user = _users[userId];
      if (user == null) {
        throw Exception('User not found: $userId');
      }

      final layout = getUserActiveLayout(userId);
      final widgets = widgetIds != null
          ? _widgets.values.where((w) => widgetIds.contains(w.widgetId)).toList()
          : layout?.widgetIds.map((id) => _widgets[id]).whereType().toList() ?? [];

      final exportData = {
        'user': {
          'id': user.userId,
          'username': user.username,
          'email': user.email,
        },
        'layout': layout?.toMap(),
        'widgets': widgets.map((w) => w.toMap()).toList(),
        'export_info': {
          'format': format.name,
          'exported_at': DateTime.now().toIso8601String(),
          'start_date': startDate?.toIso8601String(),
          'end_date': endDate?.toIso8601String(),
        },
      };

      String data;
      String mimeType;

      switch (format) {
        case ExportFormat.json:
          data = jsonEncode(exportData);
          mimeType = 'application/json';
        case ExportFormat.csv:
          data = _convertToCsv(exportData);
          mimeType = 'text/csv';
        case ExportFormat.xml:
          data = _convertToXml(exportData);
          mimeType = 'application/xml';
        case ExportFormat.pdf:
          data = _convertToPdf(exportData);
          mimeType = 'application/pdf';
      }

      return DashboardExport(
        success: true,
        data: data,
        format: format,
        mimeType: mimeType,
        size: data.length,
        exportedAt: DateTime.now(),
      );
    } catch (e) {
      return DashboardExport(
        success: false,
        data: '',
        format: format,
        mimeType: '',
        size: 0,
        errorMessage: e.toString(),
      );
    }
  }

  /// Получение данных карточки метрики
  Future<WidgetData> _getMetricCardData(DashboardWidget widget, Map<String, dynamic>? parameters) async {
    final metricName = parameters?['metric_name'] ?? widget.configuration['metric_name'] ?? 'system.cpu_usage';

    // Имитация получения метрики
    await Future.delayed(const Duration(milliseconds: 100));

    final value = Random().nextDouble() * 100;
    final previousValue = value + (Random().nextDouble() - 0.5) * 20;
    final change = value - previousValue;
    final changePercent = (change / previousValue) * 100;

    return WidgetData(
      widgetId: widget.widgetId,
      data: {
        'title': widget.name,
        'value': value.toStringAsFixed(2),
        'unit': widget.configuration['unit'] ?? '%',
        'change': change.toStringAsFixed(2),
        'change_percent': changePercent.toStringAsFixed(1),
        'trend': change > 0 ? 'up' : 'down',
        'color': change > 0 ? 'green' : 'red',
      },
      metadata: {
        'metric_name': metricName,
        'timestamp': DateTime.now().toIso8601String(),
      },
      lastUpdated: DateTime.now(),
    );
  }

  /// Получение данных графика
  Future<WidgetData> _getChartData(
      DashboardWidget widget, Map<String, dynamic>? parameters, DateTime? startDate, DateTime? endDate) async {
    final chartType = widget.configuration['chart_type'] ?? 'line';
    final dataPoints = widget.configuration['data_points'] ?? 30;

    // Имитация получения данных графика
    await Future.delayed(const Duration(milliseconds: 200));

    final chartData = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (int i = dataPoints; i >= 0; i--) {
      final timestamp = now.subtract(Duration(hours: i));
      chartData.add({
        'timestamp': timestamp.toIso8601String(),
        'value': Random().nextDouble() * 100,
        'label': timestamp.hour.toString(),
      });
    }

    return WidgetData(
      widgetId: widget.widgetId,
      data: {
        'type': chartType,
        'title': widget.name,
        'data': chartData,
        'x_axis': 'Time',
        'y_axis': widget.configuration['y_axis_label'] ?? 'Value',
        'colors': widget.configuration['colors'] ?? ['#3498db'],
      },
      metadata: {
        'data_points': dataPoints,
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
      },
      lastUpdated: DateTime.now(),
    );
  }

  /// Получение данных таблицы
  Future<WidgetData> _getTableData(DashboardWidget widget, Map<String, dynamic>? parameters) async {
    final columns = widget.configuration['columns'] ?? ['Name', 'Value', 'Status'];
    final rowCount = widget.configuration['row_count'] ?? 10;

    // Имитация получения данных таблицы
    await Future.delayed(const Duration(milliseconds: 150));

    final tableData = <Map<String, dynamic>>[];

    for (int i = 0; i < rowCount; i++) {
      tableData.add({
        'id': i + 1,
        'name': 'Item ${i + 1}',
        'value': (Random().nextDouble() * 1000).toStringAsFixed(2),
        'status': Random().nextBool() ? 'Active' : 'Inactive',
        'last_updated': DateTime.now().subtract(Duration(minutes: Random().nextInt(60))).toIso8601String(),
      });
    }

    return WidgetData(
      widgetId: widget.widgetId,
      data: {
        'title': widget.name,
        'columns': columns,
        'rows': tableData,
        'sortable': widget.configuration['sortable'] ?? true,
        'filterable': widget.configuration['filterable'] ?? true,
      },
      metadata: {
        'row_count': tableData.length,
        'column_count': columns.length,
      },
      lastUpdated: DateTime.now(),
    );
  }

  /// Получение данных списка алертов
  Future<WidgetData> _getAlertListData(DashboardWidget widget, Map<String, dynamic>? parameters) async {
    final alertLimit = widget.configuration['limit'] ?? 10;
    final alerts = getActiveAlerts().take(alertLimit).toList();

    return WidgetData(
      widgetId: widget.widgetId,
      data: {
        'title': widget.name,
        'alerts': alerts
            .map((alert) => {
                  'id': alert.alertId,
                  'title': alert.title,
                  'message': alert.message,
                  'severity': alert.severity.name,
                  'timestamp': alert.timestamp.toIso8601String(),
                  'is_acknowledged': alert.isAcknowledged,
                })
            .toList(),
      },
      metadata: {
        'total_alerts': alerts.length,
        'unacknowledged': alerts.where((a) => !a.isAcknowledged).length,
      },
      lastUpdated: DateTime.now(),
    );
  }

  /// Получение данных статуса системы
  Future<WidgetData> _getSystemStatusData(DashboardWidget widget, Map<String, dynamic>? parameters) async {
    // Имитация получения статуса системы
    await Future.delayed(const Duration(milliseconds: 100));

    final services = [
      {'name': 'Database', 'status': 'healthy', 'uptime': '99.9%'},
      {'name': 'Cache', 'status': 'healthy', 'uptime': '99.8%'},
      {'name': 'API', 'status': 'healthy', 'uptime': '99.7%'},
      {'name': 'WebSocket', 'status': 'warning', 'uptime': '98.5%'},
    ];

    return WidgetData(
      widgetId: widget.widgetId,
      data: {
        'title': widget.name,
        'overall_status': 'healthy',
        'services': services,
        'last_check': DateTime.now().toIso8601String(),
      },
      metadata: {
        'total_services': services.length,
        'healthy_services': services.where((s) => s['status'] == 'healthy').length,
      },
      lastUpdated: DateTime.now(),
    );
  }

  /// Получение данных активности пользователей
  Future<WidgetData> _getUserActivityData(
      DashboardWidget widget, Map<String, dynamic>? parameters, DateTime? startDate, DateTime? endDate) async {
    // Имитация получения данных активности
    await Future.delayed(const Duration(milliseconds: 200));

    final activities = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (int i = 0; i < 20; i++) {
      activities.add({
        'user_id': 'user_${i + 1}',
        'username': 'User ${i + 1}',
        'action': ['login', 'message', 'upload', 'download'][Random().nextInt(4)],
        'timestamp': now.subtract(Duration(minutes: Random().nextInt(60))).toIso8601String(),
        'details': 'User performed an action',
      });
    }

    return WidgetData(
      widgetId: widget.widgetId,
      data: {
        'title': widget.name,
        'activities': activities,
        'total_activities': activities.length,
      },
      metadata: {
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
      },
      lastUpdated: DateTime.now(),
    );
  }

  /// Получение данных графика производительности
  Future<WidgetData> _getPerformanceGraphData(
      DashboardWidget widget, Map<String, dynamic>? parameters, DateTime? startDate, DateTime? endDate) async {
    final metrics = ['cpu', 'memory', 'disk', 'network'];
    final graphData = <String, List<Map<String, dynamic>>>{};

    for (final metric in metrics) {
      final data = <Map<String, dynamic>>[];
      final now = DateTime.now();

      for (int i = 30; i >= 0; i--) {
        data.add({
          'timestamp': now.subtract(Duration(minutes: i)).toIso8601String(),
          'value': Random().nextDouble() * 100,
        });
      }

      graphData[metric] = data;
    }

    return WidgetData(
      widgetId: widget.widgetId,
      data: {
        'title': widget.name,
        'metrics': graphData,
        'time_range': 'Last 30 minutes',
      },
      metadata: {
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
      },
      lastUpdated: DateTime.now(),
    );
  }

  /// Получение данных просмотрщика логов
  Future<WidgetData> _getLogViewerData(DashboardWidget widget, Map<String, dynamic>? parameters) async {
    final logLevel = widget.configuration['log_level'] ?? 'info';
    final logCount = widget.configuration['log_count'] ?? 50;

    // Имитация получения логов
    await Future.delayed(const Duration(milliseconds: 100));

    final logs = <Map<String, dynamic>>[];
    final levels = ['debug', 'info', 'warning', 'error'];

    for (int i = 0; i < logCount; i++) {
      final level = levels[Random().nextInt(levels.length)];
      logs.add({
        'timestamp': DateTime.now().subtract(Duration(seconds: Random().nextInt(3600))).toIso8601String(),
        'level': level,
        'message': 'Log message ${i + 1}',
        'source': 'service_${Random().nextInt(5)}',
      });
    }

    return WidgetData(
      widgetId: widget.widgetId,
      data: {
        'title': widget.name,
        'logs': logs,
        'log_level': logLevel,
        'total_logs': logs.length,
      },
      metadata: {
        'filter_level': logLevel,
        'last_refresh': DateTime.now().toIso8601String(),
      },
      lastUpdated: DateTime.now(),
    );
  }

  /// Получение данных пользовательского HTML
  Future<WidgetData> _getCustomHtmlData(DashboardWidget widget, Map<String, dynamic>? parameters) async {
    final htmlContent = widget.configuration['html_content'] ?? '<p>Custom HTML Widget</p>';

    return WidgetData(
      widgetId: widget.widgetId,
      data: {
        'title': widget.name,
        'html_content': htmlContent,
        'refresh_interval': widget.refreshInterval.inSeconds,
      },
      metadata: {
        'widget_type': 'custom_html',
        'content_size': htmlContent.length,
      },
      lastUpdated: DateTime.now(),
    );
  }

  /// Запись события дашборда
  void _recordEvent(DashboardEventType type, String source, Map<String, dynamic> data) {
    final event = DashboardEvent(
      id: _generateId(),
      type: type,
      source: source,
      data: data,
      timestamp: DateTime.now(),
    );

    _events[event.id] = event;

    // Ограничиваем количество событий в памяти
    if (_events.length > _maxEventsHistory) {
      final oldestEvent = _events.values.reduce((a, b) => a.timestamp.isBefore(b.timestamp) ? a : b);
      _events.remove(oldestEvent.id);
    }
  }

  /// Настройка обновления данных
  void _setupDataRefresh() {
    _dataRefreshTimer = Timer.periodic(_dataRefreshInterval, (timer) async {
      await _refreshSystemMetrics();
    });
  }

  /// Настройка мониторинга алертов
  void _setupAlertMonitoring() {
    _alertCheckTimer = Timer.periodic(_alertCheckInterval, (timer) async {
      await _checkSystemAlerts();
    });
  }

  /// Обновление системных метрик
  Future<void> _refreshSystemMetrics() async {
    final now = DateTime.now();

    // Обновляем метрики системы
    final systemMetrics = [
      'system.cpu_usage',
      'system.memory_usage',
      'system.disk_usage',
      'system.network_io',
      'system.active_users',
      'system.message_count',
    ];

    for (final metricName in systemMetrics) {
      final value = Random().nextDouble() * 100;

      _metrics['${metricName}_${now.millisecondsSinceEpoch}'] = DashboardMetric(
        id: _generateId(),
        name: metricName,
        value: value,
        unit: _getMetricUnit(metricName),
        category: _getMetricCategory(metricName),
        timestamp: now,
      );
    }
  }

  /// Проверка системных алертов
  Future<void> _checkSystemAlerts() async {
    // Проверяем метрики на превышение порогов
    final recentMetrics = _metrics.values.where((m) => DateTime.now().difference(m.timestamp).inMinutes < 5).toList();

    for (final metric in recentMetrics) {
      if (_shouldTriggerAlert(metric)) {
        _createAlert(metric);
      }
    }
  }

  /// Проверка необходимости создания алерта
  bool _shouldTriggerAlert(DashboardMetric metric) {
    switch (metric.name) {
      case 'system.cpu_usage':
        return metric.value > 80.0;
      case 'system.memory_usage':
        return metric.value > 85.0;
      case 'system.disk_usage':
        return metric.value > 90.0;
      default:
        return false;
    }
  }

  /// Создание алерта
  void _createAlert(DashboardMetric metric) {
    final alertId = 'alert_${metric.name}_${DateTime.now().millisecondsSinceEpoch}';

    // Проверяем, нет ли уже активного алерта для этой метрики
    final existingAlert = _alerts.values.firstWhere(
      (alert) => alert.metricName == metric.name && alert.isActive,
      orElse: () => DashboardAlert.empty(),
    );

    if (existingAlert.alertId.isNotEmpty) {
      return; // Алерт уже существует
    }

    final alert = DashboardAlert(
      alertId: alertId,
      title: 'High ${_getMetricDisplayName(metric.name)}',
      message: '${metric.name} is at ${metric.value.toStringAsFixed(1)}${metric.unit}',
      severity: _getAlertSeverity(metric.name, metric.value),
      metricName: metric.name,
      metricValue: metric.value,
      threshold: _getAlertThreshold(metric.name),
      timestamp: DateTime.now(),
      isActive: true,
      isAcknowledged: false,
      acknowledgedBy: null,
      acknowledgedAt: null,
    );

    _alerts[alertId] = alert;

    _recordEvent(DashboardEventType.alertCreated, alertId, {
      'alert_title': alert.title,
      'metric_name': metric.name,
      'metric_value': metric.value,
    });
  }

  /// Получение единицы измерения метрики
  String _getMetricUnit(String metricName) {
    switch (metricName) {
      case 'system.cpu_usage':
      case 'system.memory_usage':
      case 'system.disk_usage':
        return '%';
      case 'system.network_io':
        return 'MB/s';
      case 'system.active_users':
      case 'system.message_count':
        return 'count';
      default:
        return '';
    }
  }

  /// Получение категории метрики
  String _getMetricCategory(String metricName) {
    if (metricName.startsWith('system.')) return 'system';
    if (metricName.startsWith('user.')) return 'user';
    if (metricName.startsWith('network.')) return 'network';
    return 'other';
  }

  /// Получение отображаемого имени метрики
  String _getMetricDisplayName(String metricName) {
    switch (metricName) {
      case 'system.cpu_usage':
        return 'CPU Usage';
      case 'system.memory_usage':
        return 'Memory Usage';
      case 'system.disk_usage':
        return 'Disk Usage';
      case 'system.network_io':
        return 'Network I/O';
      case 'system.active_users':
        return 'Active Users';
      case 'system.message_count':
        return 'Message Count';
      default:
        return metricName;
    }
  }

  /// Получение серьезности алерта
  AlertSeverity _getAlertSeverity(String metricName, double value) {
    if (value >= 95.0) return AlertSeverity.critical;
    if (value >= 85.0) return AlertSeverity.warning;
    return AlertSeverity.info;
  }

  /// Получение порога алерта
  double _getAlertThreshold(String metricName) {
    switch (metricName) {
      case 'system.cpu_usage':
      case 'system.memory_usage':
        return 80.0;
      case 'system.disk_usage':
        return 90.0;
      default:
        return 100.0;
    }
  }

  /// Конвертация в CSV
  String _convertToCsv(Map<String, dynamic> data) {
    // Упрощенная конвертация в CSV
    return 'Type,Value\nDashboard,$data';
  }

  /// Конвертация в XML
  String _convertToXml(Map<String, dynamic> data) {
    // Упрощенная конвертация в XML
    return '<?xml version="1.0" encoding="UTF-8"?><dashboard>$data</dashboard>';
  }

  /// Конвертация в PDF
  String _convertToPdf(Map<String, dynamic> data) {
    // Упрощенная конвертация в PDF (base64)
    return base64Encode(utf8.encode('PDF: $data'));
  }

  /// Загрузка конфигурации дашборда
  Future<void> _loadDashboardConfiguration() async {
    // В реальной реализации здесь будет загрузка из файлов конфигурации
  }

  /// Инициализация виджетов по умолчанию
  Future<void> _initializeDefaultWidgets() async {
    // Виджет метрики CPU
    createWidget(
      widgetId: 'cpu_metric',
      name: 'CPU Usage',
      type: WidgetType.metricCard,
      configuration: {
        'metric_name': 'system.cpu_usage',
        'unit': '%',
        'refresh_interval': 30,
      },
      position: const WidgetPosition(x: 0, y: 0),
      size: const WidgetSize(width: 300, height: 150),
    );

    // Виджет метрики памяти
    createWidget(
      widgetId: 'memory_metric',
      name: 'Memory Usage',
      type: WidgetType.metricCard,
      configuration: {
        'metric_name': 'system.memory_usage',
        'unit': '%',
        'refresh_interval': 30,
      },
      position: const WidgetPosition(x: 320, y: 0),
      size: const WidgetSize(width: 300, height: 150),
    );

    // Виджет графика производительности
    createWidget(
      widgetId: 'performance_chart',
      name: 'Performance Chart',
      type: WidgetType.performanceGraph,
      configuration: {
        'chart_type': 'line',
        'data_points': 30,
        'refresh_interval': 60,
      },
      position: const WidgetPosition(x: 0, y: 170),
      size: const WidgetSize(width: 640, height: 300),
    );

    // Виджет списка алертов
    createWidget(
      widgetId: 'alerts_list',
      name: 'Active Alerts',
      type: WidgetType.alertList,
      configuration: {
        'limit': 10,
        'refresh_interval': 30,
      },
      position: const WidgetPosition(x: 660, y: 0),
      size: const WidgetSize(width: 400, height: 300),
    );

    // Виджет статуса системы
    createWidget(
      widgetId: 'system_status',
      name: 'System Status',
      type: WidgetType.systemStatus,
      configuration: {
        'refresh_interval': 60,
      },
      position: const WidgetPosition(x: 0, y: 490),
      size: const WidgetSize(width: 400, height: 200),
    );

    // Виджет активности пользователей
    createWidget(
      widgetId: 'user_activity',
      name: 'User Activity',
      type: WidgetType.userActivity,
      configuration: {
        'refresh_interval': 30,
      },
      position: const WidgetPosition(x: 420, y: 490),
      size: const WidgetSize(width: 400, height: 200),
    );
  }

  /// Инициализация макетов по умолчанию
  Future<void> _initializeDefaultLayouts() async {
    createLayout(
      layoutId: 'default_layout',
      name: 'Default',
      widgetIds: [
        'cpu_metric',
        'memory_metric',
        'performance_chart',
        'alerts_list',
        'system_status',
        'user_activity',
      ],
      type: LayoutType.grid,
      configuration: {
        'grid_columns': 3,
        'grid_rows': 3,
        'gap': 20,
      },
      isActive: true,
    );

    createLayout(
      layoutId: 'compact_layout',
      name: 'Compact',
      widgetIds: [
        'cpu_metric',
        'memory_metric',
        'alerts_list',
      ],
      type: LayoutType.grid,
      configuration: {
        'grid_columns': 2,
        'grid_rows': 2,
        'gap': 10,
      },
    );
  }

  /// Инициализация тем по умолчанию
  Future<void> _initializeDefaultThemes() async {
    createTheme(
      themeId: 'light_theme',
      name: 'Light',
      colors: {
        'primary': '#3498db',
        'secondary': '#2ecc71',
        'success': '#27ae60',
        'warning': '#f39c12',
        'danger': '#e74c3c',
        'background': '#ffffff',
        'surface': '#f8f9fa',
        'text': '#2c3e50',
        'text_secondary': '#7f8c8d',
      },
      typography: {
        'font_family': 'Inter, sans-serif',
        'font_size_base': '14px',
        'font_size_large': '18px',
        'font_size_small': '12px',
        'font_weight_normal': '400',
        'font_weight_bold': '600',
      },
      isDefault: true,
    );

    createTheme(
      themeId: 'dark_theme',
      name: 'Dark',
      colors: {
        'primary': '#3498db',
        'secondary': '#2ecc71',
        'success': '#27ae60',
        'warning': '#f39c12',
        'danger': '#e74c3c',
        'background': '#1a1a1a',
        'surface': '#2d2d2d',
        'text': '#ffffff',
        'text_secondary': '#b0b0b0',
      },
      typography: {
        'font_family': 'Inter, sans-serif',
        'font_size_base': '14px',
        'font_size_large': '18px',
        'font_size_small': '12px',
        'font_weight_normal': '400',
        'font_weight_bold': '600',
      },
    );
  }

  /// Генерация уникального ID
  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';
  }

  /// Освобождение ресурсов
  void dispose() {
    _dataRefreshTimer?.cancel();
    _alertCheckTimer?.cancel();
    _widgets.clear();
    _layouts.clear();
    _themes.clear();
    _users.clear();
    _metrics.clear();
    _alerts.clear();
    _events.clear();
  }
}

/// Модели данных

/// Виджет дашборда
class DashboardWidget extends Equatable {
  final String widgetId;
  final String name;
  final WidgetType type;
  final Map<String, dynamic> configuration;
  final WidgetPosition position;
  final WidgetSize size;
  final String? description;
  bool isVisible;
  final Duration refreshInterval;
  final DateTime createdAt;
  DateTime? lastUpdated;

  DashboardWidget({
    required this.widgetId,
    required this.name,
    required this.type,
    required this.configuration,
    required this.position,
    required this.size,
    this.description,
    required this.isVisible,
    required this.refreshInterval,
    required this.createdAt,
    this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'widget_id': widgetId,
      'name': name,
      'type': type.name,
      'configuration': configuration,
      'position': {'x': position.x, 'y': position.y},
      'size': {'width': size.width, 'height': size.height},
      'description': description,
      'is_visible': isVisible,
      'refresh_interval': refreshInterval.inSeconds,
      'created_at': createdAt.toIso8601String(),
      'last_updated': lastUpdated?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        widgetId,
        name,
        type,
        configuration,
        position,
        size,
        description,
        isVisible,
        refreshInterval,
        createdAt,
        lastUpdated,
      ];
}

/// Позиция виджета
class WidgetPosition extends Equatable {
  final double x;
  final double y;

  const WidgetPosition({required this.x, required this.y});

  @override
  List<Object?> get props => [x, y];
}

/// Размер виджета
class WidgetSize extends Equatable {
  final double width;
  final double height;

  const WidgetSize({required this.width, required this.height});

  @override
  List<Object?> get props => [width, height];
}

/// Данные виджета
class WidgetData extends Equatable {
  final String widgetId;
  final Map<String, dynamic> data;
  final Map<String, dynamic> metadata;
  final DateTime lastUpdated;

  const WidgetData({
    required this.widgetId,
    required this.data,
    required this.metadata,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [widgetId, data, metadata, lastUpdated];
}

/// Макет дашборда
class DashboardLayout extends Equatable {
  final String layoutId;
  final String name;
  final List<String> widgetIds;
  final LayoutType type;
  final Map<String, dynamic> configuration;
  final String? description;
  bool isActive;
  final DateTime createdAt;
  DateTime lastModified;

  DashboardLayout({
    required this.layoutId,
    required this.name,
    required this.widgetIds,
    required this.type,
    required this.configuration,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.lastModified,
  });

  Map<String, dynamic> toMap() {
    return {
      'layout_id': layoutId,
      'name': name,
      'widget_ids': widgetIds,
      'type': type.name,
      'configuration': configuration,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'last_modified': lastModified.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        layoutId,
        name,
        widgetIds,
        type,
        configuration,
        description,
        isActive,
        createdAt,
        lastModified,
      ];
}

/// Тема дашборда
class DashboardTheme extends Equatable {
  final String themeId;
  final String name;
  final Map<String, dynamic> colors;
  final Map<String, dynamic> typography;
  final Map<String, dynamic> spacing;
  final Map<String, dynamic> effects;
  final String? description;
  bool isDefault;
  final DateTime createdAt;

  DashboardTheme({
    required this.themeId,
    required this.name,
    required this.colors,
    required this.typography,
    required this.spacing,
    required this.effects,
    this.description,
    required this.isDefault,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        themeId,
        name,
        colors,
        typography,
        spacing,
        effects,
        description,
        isDefault,
        createdAt,
      ];
}

/// Пользователь дашборда
class DashboardUser extends Equatable {
  final String userId;
  final String username;
  final String email;
  final List<String> roles;
  final Map<String, dynamic> preferences;
  bool isActive;
  DateTime? lastLogin;
  final DateTime createdAt;
  final List<String> dashboardLayouts;

  DashboardUser({
    required this.userId,
    required this.username,
    required this.email,
    required this.roles,
    required this.preferences,
    required this.isActive,
    this.lastLogin,
    required this.createdAt,
    required this.dashboardLayouts,
  });

  @override
  List<Object?> get props => [
        userId,
        username,
        email,
        roles,
        preferences,
        isActive,
        lastLogin,
        createdAt,
        dashboardLayouts,
      ];
}

/// Метрика дашборда
class DashboardMetric extends Equatable {
  final String id;
  final String name;
  final double value;
  final String unit;
  final String category;
  final DateTime timestamp;

  const DashboardMetric({
    required this.id,
    required this.name,
    required this.value,
    required this.unit,
    required this.category,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, name, value, unit, category, timestamp];
}

/// Алерт дашборда
class DashboardAlert extends Equatable {
  final String alertId;
  final String title;
  final String message;
  final AlertSeverity severity;
  final String metricName;
  final double metricValue;
  final double threshold;
  final DateTime timestamp;
  bool isActive;
  bool isAcknowledged;
  String? acknowledgedBy;
  DateTime? acknowledgedAt;

  DashboardAlert({
    required this.alertId,
    required this.title,
    required this.message,
    required this.severity,
    required this.metricName,
    required this.metricValue,
    required this.threshold,
    required this.timestamp,
    required this.isActive,
    required this.isAcknowledged,
    this.acknowledgedBy,
    this.acknowledgedAt,
  });

  factory DashboardAlert.empty() {
    return DashboardAlert(
      alertId: '',
      title: '',
      message: '',
      severity: AlertSeverity.info,
      metricName: '',
      metricValue: 0.0,
      threshold: 0.0,
      timestamp: DateTime.now(),
      isActive: false,
      isAcknowledged: false,
    );
  }

  @override
  List<Object?> get props => [
        alertId,
        title,
        message,
        severity,
        metricName,
        metricValue,
        threshold,
        timestamp,
        isActive,
        isAcknowledged,
        acknowledgedBy,
        acknowledgedAt,
      ];
}

/// Событие дашборда
class DashboardEvent extends Equatable {
  final String id;
  final DashboardEventType type;
  final String source;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  const DashboardEvent({
    required this.id,
    required this.type,
    required this.source,
    required this.data,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, type, source, data, timestamp];
}

/// Экспорт дашборда
class DashboardExport extends Equatable {
  final bool success;
  final String data;
  final ExportFormat format;
  final String mimeType;
  final int size;
  final DateTime exportedAt;
  final String? errorMessage;

  const DashboardExport({
    required this.success,
    required this.data,
    required this.format,
    required this.mimeType,
    required this.size,
    required this.exportedAt,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [success, data, format, mimeType, size, exportedAt, errorMessage];
}

/// Перечисления

/// Тип виджета
enum WidgetType {
  metricCard, // Карточка метрики
  chart, // График
  table, // Таблица
  alertList, // Список алертов
  systemStatus, // Статус системы
  userActivity, // Активность пользователей
  performanceGraph, // График производительности
  logViewer, // Просмотрщик логов
  customHtml, // Пользовательский HTML
}

/// Тип макета
enum LayoutType {
  grid, // Сетка
  flex, // Гибкий
  custom, // Пользовательский
}

/// Серьезность алерта
enum AlertSeverity {
  info, // Информация
  warning, // Предупреждение
  critical, // Критический
}

/// Тип события дашборда
enum DashboardEventType {
  widgetRefreshed, // Виджет обновлен
  widgetError, // Ошибка виджета
  layoutChanged, // Макет изменен
  alertCreated, // Алерт создан
  alertAcknowledged, // Алерт подтвержден
  userLogin, // Вход пользователя
  userLogout, // Выход пользователя
}

/// Формат экспорта
enum ExportFormat {
  json, // JSON
  csv, // CSV
  xml, // XML
  pdf, // PDF
}
