import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/performance/performance_analytics_service.dart';

/// Виджет для мониторинга производительности в реальном времени
class PerformanceMonitoringWidget extends StatefulWidget {
  final bool showDetails;
  final Duration updateInterval;
  final List<String>? selectedMetrics;

  const PerformanceMonitoringWidget({
    super.key,
    this.showDetails = false,
    this.updateInterval = const Duration(seconds: 5),
    this.selectedMetrics,
  });

  @override
  State<PerformanceMonitoringWidget> createState() => _PerformanceMonitoringWidgetState();
}

class _PerformanceMonitoringWidgetState extends State<PerformanceMonitoringWidget> {
  final PerformanceAnalyticsService _analyticsService = PerformanceAnalyticsService();

  Map<String, PerformanceMetric> _metrics = {};
  bool _isMonitoring = false;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }

  @override
  void dispose() {
    _stopMonitoring();
    super.dispose();
  }

  void _startMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _updateTimer = Timer.periodic(widget.updateInterval, (_) => _updateMetrics());
    _updateMetrics();
  }

  void _stopMonitoring() {
    _isMonitoring = false;
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  void _updateMetrics() {
    setState(() {
      _metrics = _analyticsService.getMetrics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Performance Monitor',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Icon(
                      _isMonitoring ? Icons.monitor_heart : Icons.monitor_heart_outlined,
                      color: _isMonitoring ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isMonitoring ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: _isMonitoring ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.showDetails) _buildDetailedView() else _buildCompactView(),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactView() {
    final List<String> keyMetrics = widget.selectedMetrics ??
        [
          'cpu_usage',
          'memory_usage',
          'response_time',
          'error_rate',
        ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: keyMetrics.map((metricId) {
        final PerformanceMetric? metric = _metrics[metricId];
        if (metric == null) return const SizedBox.shrink();

        return _buildCompactMetric(metric);
      }).toList(),
    );
  }

  Widget _buildCompactMetric(PerformanceMetric metric) {
    final double percentage = (metric.currentValue - metric.minValue) / (metric.maxValue - metric.minValue);
    final Color color = _getMetricColor(percentage);

    return Column(
      children: [
        Icon(
          _getMetricIcon(metric.id),
          color: color,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          '${metric.currentValue.toStringAsFixed(1)}${_getMetricUnit(metric.unit)}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          _getMetricName(metric.id),
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildDetailedView() {
    final List<PerformanceMetric> metricsToShow = widget.selectedMetrics != null
        ? widget.selectedMetrics!.map((id) => _metrics[id]).where((m) => m != null).cast<PerformanceMetric>().toList()
        : _metrics.values.toList();

    return Column(
      children: metricsToShow.map((metric) => _buildDetailedMetric(metric)).toList(),
    );
  }

  Widget _buildDetailedMetric(PerformanceMetric metric) {
    final double percentage = (metric.currentValue - metric.minValue) / (metric.maxValue - metric.minValue);
    final Color color = _getMetricColor(percentage);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                metric.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${metric.currentValue.toStringAsFixed(1)} ${metric.unit}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          const SizedBox(height: 4),
          Text(
            '${(percentage * 100).toStringAsFixed(1)}% of max',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Helper methods

  Color _getMetricColor(double percentage) {
    if (percentage > 0.8) return Colors.red;
    if (percentage > 0.6) return Colors.orange;
    if (percentage > 0.4) return Colors.yellow;
    return Colors.green;
  }

  IconData _getMetricIcon(String metricId) {
    switch (metricId) {
      case 'cpu_usage':
        return Icons.memory;
      case 'memory_usage':
        return Icons.storage;
      case 'disk_usage':
        return Icons.storage;
      case 'network_io':
        return Icons.network_check;
      case 'response_time':
        return Icons.speed;
      case 'error_rate':
        return Icons.error;
      case 'active_connections':
        return Icons.people;
      case 'queue_length':
        return Icons.queue;
      default:
        return Icons.analytics;
    }
  }

  String _getMetricUnit(String unit) {
    switch (unit) {
      case '%':
        return '%';
      case 'ms':
        return 'ms';
      case 'bytes/s':
        return 'B/s';
      case 'requests/s':
        return 'req/s';
      case 'connections':
        return '';
      case 'items':
        return '';
      default:
        return '';
    }
  }

  String _getMetricName(String metricId) {
    switch (metricId) {
      case 'cpu_usage':
        return 'CPU';
      case 'memory_usage':
        return 'Memory';
      case 'disk_usage':
        return 'Disk';
      case 'network_io':
        return 'Network';
      case 'response_time':
        return 'Response';
      case 'error_rate':
        return 'Errors';
      case 'active_connections':
        return 'Connections';
      case 'queue_length':
        return 'Queue';
      default:
        return metricId;
    }
  }
}

/// Виджет для отображения графика производительности
class PerformanceChartWidget extends StatefulWidget {
  final String metricId;
  final Duration timeRange;
  final int maxDataPoints;

  const PerformanceChartWidget({
    super.key,
    required this.metricId,
    this.timeRange = const Duration(minutes: 10),
    this.maxDataPoints = 50,
  });

  @override
  State<PerformanceChartWidget> createState() => _PerformanceChartWidgetState();
}

class _PerformanceChartWidgetState extends State<PerformanceChartWidget> {
  final PerformanceAnalyticsService _analyticsService = PerformanceAnalyticsService();

  List<PerformanceDataPoint> _dataPoints = [];
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _startUpdates();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _startUpdates() {
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (_) => _updateData());
    _updateData();
  }

  void _updateData() {
    final Map<String, List<PerformanceDataPoint>> timeSeriesData = _analyticsService.getTimeSeriesData();
    final List<PerformanceDataPoint> metricData = timeSeriesData[widget.metricId] ?? [];

    final DateTime cutoff = DateTime.now().subtract(widget.timeRange);
    final List<PerformanceDataPoint> filteredData =
        metricData.where((point) => point.timestamp.isAfter(cutoff)).toList();

    setState(() {
      _dataPoints = filteredData.take(widget.maxDataPoints).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getMetricName(widget.metricId),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _dataPoints.isEmpty
                  ? const Center(
                      child: Text(
                        'No data available',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : _buildChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    if (_dataPoints.length < 2) {
      return const Center(
        child: Text(
          'Insufficient data for chart',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Simple line chart implementation
    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: PerformanceChartPainter(_dataPoints),
    );
  }

  String _getMetricName(String metricId) {
    switch (metricId) {
      case 'cpu_usage':
        return 'CPU Usage (%)';
      case 'memory_usage':
        return 'Memory Usage (%)';
      case 'response_time':
        return 'Response Time (ms)';
      case 'error_rate':
        return 'Error Rate (%)';
      default:
        return metricId;
    }
  }
}

/// Custom painter for performance charts
class PerformanceChartPainter extends CustomPainter {
  final List<PerformanceDataPoint> dataPoints;

  PerformanceChartPainter(this.dataPoints);

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.length < 2) return;

    final Paint linePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Paint fillPaint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final Path linePath = Path();
    final Path fillPath = Path();

    final double minValue = dataPoints.map((p) => p.value).reduce((a, b) => a < b ? a : b);
    final double maxValue = dataPoints.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final double valueRange = maxValue - minValue;

    final DateTime minTime = dataPoints.first.timestamp;
    final DateTime maxTime = dataPoints.last.timestamp;
    final double timeRange = maxTime.difference(minTime).inMilliseconds.toDouble();

    // Start the paths
    const double firstX = 0;
    final double firstY = size.height - ((dataPoints.first.value - minValue) / valueRange) * size.height;
    linePath.moveTo(firstX, firstY);
    fillPath.moveTo(firstX, size.height);
    fillPath.lineTo(firstX, firstY);

    // Draw the line and fill area
    for (int i = 1; i < dataPoints.length; i++) {
      final PerformanceDataPoint point = dataPoints[i];
      final double x = (point.timestamp.difference(minTime).inMilliseconds / timeRange) * size.width;
      final double y = size.height - ((point.value - minValue) / valueRange) * size.height;

      linePath.lineTo(x, y);
      fillPath.lineTo(x, y);
    }

    // Complete the fill area
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Draw the filled area first
    canvas.drawPath(fillPath, fillPaint);

    // Draw the line on top
    canvas.drawPath(linePath, linePaint);

    // Draw data points
    final Paint pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    for (int i = 0; i < dataPoints.length; i++) {
      final PerformanceDataPoint point = dataPoints[i];
      final double x = (point.timestamp.difference(minTime).inMilliseconds / timeRange) * size.width;
      final double y = size.height - ((point.value - minValue) / valueRange) * size.height;

      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Виджет для отображения алертов производительности
class PerformanceAlertsWidget extends StatefulWidget {
  const PerformanceAlertsWidget({super.key});

  @override
  State<PerformanceAlertsWidget> createState() => _PerformanceAlertsWidgetState();
}

class _PerformanceAlertsWidgetState extends State<PerformanceAlertsWidget> {
  final PerformanceAnalyticsService _analyticsService = PerformanceAnalyticsService();

  List<PerformanceAlert> _alerts = [];
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _startUpdates();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _startUpdates() {
    _updateTimer = Timer.periodic(const Duration(seconds: 10), (_) => _updateAlerts());
    _updateAlerts();
  }

  void _updateAlerts() {
    setState(() {
      _alerts = _analyticsService.getAlerts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Performance Alerts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _alerts.isNotEmpty ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_alerts.length} alerts',
                    style: TextStyle(
                      color: _alerts.isNotEmpty ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_alerts.isEmpty)
              const Center(
                child: Text(
                  'No active alerts',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _alerts.length,
                  itemBuilder: (context, index) {
                    final PerformanceAlert alert = _alerts[index];
                    return _buildAlertItem(alert);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(PerformanceAlert alert) {
    final Color color = _getAlertColor(alert.severity);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                alert.message,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  alert.severity.name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Value: ${alert.value.toStringAsFixed(1)} (Threshold: ${alert.threshold.toStringAsFixed(1)})',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Text(
            'Time: ${_formatDateTime(alert.timestamp)}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Color _getAlertColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.info:
        return Colors.blue;
      case AlertSeverity.warning:
        return Colors.orange;
      case AlertSeverity.critical:
        return Colors.red;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
