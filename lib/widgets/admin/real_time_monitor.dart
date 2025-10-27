import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/monitoring/performance_monitoring_service.dart';
import '../../services/performance/models/performance_metric.dart';

/// Монитор в реальном времени для отслеживания системных метрик
class RealTimeMonitor extends StatefulWidget {
  const RealTimeMonitor({super.key});

  @override
  State<RealTimeMonitor> createState() => _RealTimeMonitorState();
}

class _RealTimeMonitorState extends State<RealTimeMonitor> with TickerProviderStateMixin {
  final PerformanceMonitoringService _monitoringService = PerformanceMonitoringService();

  late TabController _tabController;
  Timer? _updateTimer;

  List<PerformanceMetric> _metrics = [];
  Map<String, List<double>> _metricHistory = {};
  bool _isMonitoring = false;

  // Настройки мониторинга
  int _updateInterval = 1; // секунды
  bool _showAlerts = true;
  double _alertThreshold = 80.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeMetrics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _stopMonitoring();
    super.dispose();
  }

  void _initializeMetrics() {
    // Инициализация истории метрик
    _metricHistory = {
      'cpu': List.filled(60, 0.0), // 60 точек для минуты
      'memory': List.filled(60, 0.0),
      'network': List.filled(60, 0.0),
      'disk': List.filled(60, 0.0),
    };
  }

  void _startMonitoring() {
    if (_isMonitoring) return;

    setState(() {
      _isMonitoring = true;
    });

    _updateTimer = Timer.periodic(Duration(seconds: _updateInterval), (_) {
      _updateMetrics();
    });

    _showSuccessSnackBar('Real-time monitoring started');
  }

  void _stopMonitoring() {
    _updateTimer?.cancel();
    _updateTimer = null;

    setState(() {
      _isMonitoring = false;
    });

    _showInfoSnackBar('Real-time monitoring stopped');
  }

  Future<void> _updateMetrics() async {
    try {
      final metrics = _monitoringService.getCurrentMetrics();

      setState(() {
        _metrics = metrics;

        // Обновляем историю метрик
        _metricHistory['cpu']!.removeAt(0);
        _metricHistory['cpu']!.add(metrics.firstWhere((m) => m.name == 'CPU Usage').value);

        _metricHistory['memory']!.removeAt(0);
        _metricHistory['memory']!.add(metrics.firstWhere((m) => m.name == 'Memory Usage').value);

        _metricHistory['network']!.removeAt(0);
        _metricHistory['network']!.add(metrics.firstWhere((m) => m.name == 'Network I/O').value);

        _metricHistory['disk']!.removeAt(0);
        _metricHistory['disk']!.add(metrics.firstWhere((m) => m.name == 'Disk I/O').value);
      });

      // Проверяем на превышение порогов
      if (_showAlerts) {
        _checkAlerts(metrics);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to update metrics: $e');
    }
  }

  void _checkAlerts(List<PerformanceMetric> metrics) {
    for (final metric in metrics) {
      if (metric.value > _alertThreshold) {
        _showAlert(metric);
      }
    }
  }

  void _showAlert(PerformanceMetric metric) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ALERT: ${metric.name} is at ${metric.value.toStringAsFixed(1)}%'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildChartsTab(),
                _buildMetricsTab(),
                _buildAlertsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isMonitoring ? _stopMonitoring : _startMonitoring,
        backgroundColor: _isMonitoring ? Colors.red : Colors.green,
        tooltip: _isMonitoring ? 'Stop Monitoring' : 'Start Monitoring',
        child: Icon(_isMonitoring ? Icons.stop : Icons.play_arrow),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Real-Time Monitor',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      _isMonitoring
                          ? 'Monitoring active • Updates every $_updateInterval second(s)'
                          : 'Monitoring stopped',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _isMonitoring ? Colors.green : Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              _buildMonitoringControls(),
            ],
          ),
          const SizedBox(height: 12),
          _buildQuickStats(),
        ],
      ),
    );
  }

  Widget _buildMonitoringControls() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Интервал обновления
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Interval: '),
              DropdownButton<int>(
                value: _updateInterval,
                items: const [
                  DropdownMenuItem(value: 1, child: Text('1s')),
                  DropdownMenuItem(value: 2, child: Text('2s')),
                  DropdownMenuItem(value: 5, child: Text('5s')),
                  DropdownMenuItem(value: 10, child: Text('10s')),
                ],
                onChanged: _isMonitoring
                    ? null
                    : (value) {
                        setState(() {
                          _updateInterval = value!;
                        });
                      },
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Порог предупреждений
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Alert: '),
              DropdownButton<double>(
                value: _alertThreshold,
                items: const [
                  DropdownMenuItem(value: 70.0, child: Text('70%')),
                  DropdownMenuItem(value: 80.0, child: Text('80%')),
                  DropdownMenuItem(value: 90.0, child: Text('90%')),
                  DropdownMenuItem(value: 95.0, child: Text('95%')),
                ],
                onChanged: (value) {
                  setState(() {
                    _alertThreshold = value!;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Переключатель предупреждений
        Switch(
          value: _showAlerts,
          onChanged: (value) {
            setState(() {
              _showAlerts = value;
            });
          },
        ),
        const SizedBox(width: 8),

        // Кнопки управления
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _updateMetrics,
          tooltip: 'Refresh Now',
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: _showSettings,
          tooltip: 'Settings',
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    if (_metrics.isEmpty) {
      return const SizedBox.shrink();
    }

    final cpuMetric = _metrics.firstWhere((m) => m.name == 'CPU Usage',
        orElse: () => PerformanceMetric('CPU Usage', 0.0, DateTime.now()));
    final memoryMetric = _metrics.firstWhere((m) => m.name == 'Memory Usage',
        orElse: () => PerformanceMetric('Memory Usage', 0.0, DateTime.now()));
    final networkMetric = _metrics.firstWhere((m) => m.name == 'Network I/O',
        orElse: () => PerformanceMetric('Network I/O', 0.0, DateTime.now()));
    final diskMetric = _metrics.firstWhere((m) => m.name == 'Disk I/O',
        orElse: () => PerformanceMetric('Disk I/O', 0.0, DateTime.now()));

    return Row(
      children: [
        _buildStatChip('CPU', cpuMetric.value.toStringAsFixed(1), _getMetricColor(cpuMetric.value)),
        const SizedBox(width: 8),
        _buildStatChip('Memory', memoryMetric.value.toStringAsFixed(1), _getMetricColor(memoryMetric.value)),
        const SizedBox(width: 8),
        _buildStatChip('Network', networkMetric.value.toStringAsFixed(1), _getMetricColor(networkMetric.value)),
        const SizedBox(width: 8),
        _buildStatChip('Disk', diskMetric.value.toStringAsFixed(1), _getMetricColor(diskMetric.value)),
      ],
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label: $value%',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getMetricColor(double value) {
    if (value >= 90) return Colors.red;
    if (value >= 80) return Colors.orange;
    if (value >= 60) return Colors.yellow;
    return Colors.green;
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
        Tab(icon: Icon(Icons.show_chart), text: 'Charts'),
        Tab(icon: Icon(Icons.analytics), text: 'Metrics'),
        Tab(icon: Icon(Icons.warning), text: 'Alerts'),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Статус системы
          _buildSystemStatus(),
          const SizedBox(height: 16),

          // Ключевые метрики
          _buildKeyMetrics(),
          const SizedBox(height: 16),

          // Графики в реальном времени
          _buildRealTimeCharts(),
        ],
      ),
    );
  }

  Widget _buildSystemStatus() {
    final overallHealth = _calculateOverallHealth();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getHealthIcon(overallHealth),
                  color: _getHealthColor(overallHealth),
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'System Health: ${_getHealthStatus(overallHealth)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: _getHealthColor(overallHealth),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Last updated: ${DateTime.now().toString().substring(11, 19)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getHealthColor(overallHealth).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${overallHealth.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: _getHealthColor(overallHealth),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _calculateOverallHealth() {
    if (_metrics.isEmpty) return 0.0;

    final cpuValue = _metrics
        .firstWhere((m) => m.name == 'CPU Usage', orElse: () => PerformanceMetric('CPU Usage', 0.0, DateTime.now()))
        .value;
    final memoryValue = _metrics
        .firstWhere((m) => m.name == 'Memory Usage',
            orElse: () => PerformanceMetric('Memory Usage', 0.0, DateTime.now()))
        .value;

    // Здоровье системы = 100 - среднее использование ресурсов
    return 100.0 - ((cpuValue + memoryValue) / 2);
  }

  IconData _getHealthIcon(double health) {
    if (health >= 80) return Icons.check_circle;
    if (health >= 60) return Icons.warning;
    return Icons.error;
  }

  Color _getHealthColor(double health) {
    if (health >= 80) return Colors.green;
    if (health >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getHealthStatus(double health) {
    if (health >= 80) return 'Excellent';
    if (health >= 60) return 'Good';
    if (health >= 40) return 'Fair';
    return 'Poor';
  }

  Widget _buildKeyMetrics() {
    if (_metrics.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('No metrics available. Start monitoring to see data.'),
          ),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: _metrics.take(8).map((metric) => _buildMetricCard(metric)).toList(),
    );
  }

  Widget _buildMetricCard(PerformanceMetric metric) {
    final color = _getMetricColor(metric.value);

    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  _getMetricIcon(metric.name),
                  color: color,
                  size: 24,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'LIVE',
                    style: TextStyle(
                      color: color,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${metric.value.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
                Text(
                  metric.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getMetricIcon(String metricName) {
    switch (metricName.toLowerCase()) {
      case 'cpu usage':
        return Icons.memory;
      case 'memory usage':
        return Icons.storage;
      case 'network i/o':
        return Icons.network_check;
      case 'disk i/o':
        return Icons.storage;
      case 'response time':
        return Icons.speed;
      case 'active connections':
        return Icons.link;
      case 'error rate':
        return Icons.error;
      case 'throughput':
        return Icons.trending_up;
      default:
        return Icons.analytics;
    }
  }

  Widget _buildRealTimeCharts() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Real-Time Performance Charts',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    child: _buildSimpleChart('CPU', _metricHistory['cpu']!, Colors.blue),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSimpleChart('Memory', _metricHistory['memory']!, Colors.green),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSimpleChart('Network', _metricHistory['network']!, Colors.orange),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSimpleChart('Disk', _metricHistory['disk']!, Colors.purple),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleChart(String title, List<double> data, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: CustomPaint(
            painter: RealTimeChartPainter(data, color),
            size: const Size(double.infinity, double.infinity),
          ),
        ),
      ],
    );
  }

  Widget _buildChartsTab() {
    return const Center(
      child: Text('Advanced Charts Tab - More detailed charts will be displayed here'),
    );
  }

  Widget _buildMetricsTab() {
    if (_metrics.isEmpty) {
      return const Center(
        child: Text('No metrics available. Start monitoring to see data.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _metrics.length,
      itemBuilder: (context, index) {
        final metric = _metrics[index];
        return _buildMetricListItem(metric);
      },
    );
  }

  Widget _buildMetricListItem(PerformanceMetric metric) {
    final color = _getMetricColor(metric.value);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(
            _getMetricIcon(metric.name),
            color: Colors.white,
          ),
        ),
        title: Text(metric.name),
        subtitle: Text(
          'Last updated: ${metric.timestamp.toString().substring(11, 19)}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${metric.value.toStringAsFixed(1)}%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (metric.value > _alertThreshold)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'ALERT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsTab() {
    final alertMetrics = _metrics.where((m) => m.value > _alertThreshold).toList();

    if (alertMetrics.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 64,
              color: Colors.green,
            ),
            SizedBox(height: 16),
            Text(
              'No active alerts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('All metrics are within normal ranges'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: alertMetrics.length,
      itemBuilder: (context, index) {
        final metric = alertMetrics[index];
        return _buildAlertCard(metric);
      },
    );
  }

  Widget _buildAlertCard(PerformanceMetric metric) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.red.withOpacity(0.1),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.red,
          child: Icon(
            Icons.warning,
            color: Colors.white,
          ),
        ),
        title: Text(
          'High ${metric.name}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current value: ${metric.value.toStringAsFixed(1)}%'),
            Text('Threshold: ${_alertThreshold.toStringAsFixed(1)}%'),
            Text('Alert time: ${metric.timestamp.toString().substring(11, 19)}'),
          ],
        ),
        trailing: TextButton(
          onPressed: () {
            // TODO: Implement alert acknowledgment
            _showInfoSnackBar('Alert acknowledged');
          },
          child: const Text('Acknowledge'),
        ),
      ),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => _MonitorSettingsDialog(
        updateInterval: _updateInterval,
        alertThreshold: _alertThreshold,
        showAlerts: _showAlerts,
        onSettingsChanged: (interval, threshold, alerts) {
          setState(() {
            _updateInterval = interval;
            _alertThreshold = threshold;
            _showAlerts = alerts;
          });
        },
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

/// Диалог настроек монитора
class _MonitorSettingsDialog extends StatefulWidget {
  final int updateInterval;
  final double alertThreshold;
  final bool showAlerts;
  final Function(int, double, bool) onSettingsChanged;

  const _MonitorSettingsDialog({
    required this.updateInterval,
    required this.alertThreshold,
    required this.showAlerts,
    required this.onSettingsChanged,
  });

  @override
  State<_MonitorSettingsDialog> createState() => _MonitorSettingsDialogState();
}

class _MonitorSettingsDialogState extends State<_MonitorSettingsDialog> {
  late int _updateInterval;
  late double _alertThreshold;
  late bool _showAlerts;

  @override
  void initState() {
    super.initState();
    _updateInterval = widget.updateInterval;
    _alertThreshold = widget.alertThreshold;
    _showAlerts = widget.showAlerts;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Monitor Settings'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Интервал обновления
            ListTile(
              title: const Text('Update Interval'),
              subtitle: Text('$_updateInterval second(s)'),
              trailing: DropdownButton<int>(
                value: _updateInterval,
                items: const [
                  DropdownMenuItem(value: 1, child: Text('1 second')),
                  DropdownMenuItem(value: 2, child: Text('2 seconds')),
                  DropdownMenuItem(value: 5, child: Text('5 seconds')),
                  DropdownMenuItem(value: 10, child: Text('10 seconds')),
                ],
                onChanged: (value) {
                  setState(() {
                    _updateInterval = value!;
                  });
                },
              ),
            ),

            // Порог предупреждений
            ListTile(
              title: const Text('Alert Threshold'),
              subtitle: Text('${_alertThreshold.toStringAsFixed(1)}%'),
              trailing: DropdownButton<double>(
                value: _alertThreshold,
                items: const [
                  DropdownMenuItem(value: 70.0, child: Text('70%')),
                  DropdownMenuItem(value: 80.0, child: Text('80%')),
                  DropdownMenuItem(value: 90.0, child: Text('90%')),
                  DropdownMenuItem(value: 95.0, child: Text('95%')),
                ],
                onChanged: (value) {
                  setState(() {
                    _alertThreshold = value!;
                  });
                },
              ),
            ),

            // Показывать предупреждения
            SwitchListTile(
              title: const Text('Show Alerts'),
              subtitle: const Text('Display alerts when thresholds are exceeded'),
              value: _showAlerts,
              onChanged: (value) {
                setState(() {
                  _showAlerts = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSettingsChanged(_updateInterval, _alertThreshold, _showAlerts);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

/// Painter для отрисовки графиков в реальном времени
class RealTimeChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  RealTimeChartPainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    const maxValue = 100.0; // Максимальное значение для процентов
    const minValue = 0.0;
    const range = maxValue - minValue;
    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - ((data[i] - minValue) / range * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Рисуем текущую точку
    if (data.isNotEmpty) {
      final lastValue = data.last;
      final lastX = (data.length - 1) * stepX;
      final lastY = size.height - ((lastValue - minValue) / range * size.height);

      final pointPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(lastX, lastY), 4, pointPaint);

      // Рисуем значение
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${lastValue.toStringAsFixed(1)}%',
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(lastX - textPainter.width / 2, lastY - 20));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! RealTimeChartPainter || oldDelegate.data != data;
  }
}
