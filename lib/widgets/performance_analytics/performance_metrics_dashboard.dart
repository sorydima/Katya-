import 'package:flutter/material.dart';

import '../../services/performance_analytics/performance_metrics_service.dart';

/// Дашборд для отображения метрик производительности
class PerformanceMetricsDashboard extends StatefulWidget {
  const PerformanceMetricsDashboard({super.key});

  @override
  State<PerformanceMetricsDashboard> createState() => _PerformanceMetricsDashboardState();
}

class _PerformanceMetricsDashboardState extends State<PerformanceMetricsDashboard> {
  final PerformanceMetricsService _metricsService = PerformanceMetricsService();
  final List<PerformanceMetric> _metrics = [];
  bool _isLoading = true;
  String _selectedMetricType = 'all';
  Duration _selectedTimeRange = const Duration(hours: 1);

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final metrics = _metricsService.getAllMetrics();
      setState(() {
        _metrics.clear();
        _metrics.addAll(metrics);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load metrics: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  List<PerformanceMetric> _getFilteredMetrics() {
    var filtered = _metrics;

    // Фильтр по типу метрики
    if (_selectedMetricType != 'all') {
      final type = MetricType.values.firstWhere(
        (t) => t.name == _selectedMetricType,
        orElse: () => MetricType.custom,
      );
      filtered = filtered.where((m) => m.type == type).toList();
    }

    // Фильтр по времени
    final cutoffTime = DateTime.now().subtract(_selectedTimeRange);
    filtered = filtered.where((m) => m.timestamp.isAfter(cutoffTime)).toList();

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filteredMetrics = _getFilteredMetrics();
    final metricsByType = <MetricType, List<PerformanceMetric>>{};

    for (final metric in filteredMetrics) {
      metricsByType[metric.type] = (metricsByType[metric.type] ?? [])..add(metric);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Metrics Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMetrics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilters(),
                Expanded(
                  child: _buildMetricsContent(metricsByType),
                ),
              ],
            ),
    );
  }

  Widget _buildFilters() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedMetricType,
                decoration: const InputDecoration(
                  labelText: 'Metric Type',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: 'all', child: Text('All Types')),
                  ...MetricType.values.map((type) => DropdownMenuItem(
                        value: type.name,
                        child: Text(type.name.toUpperCase()),
                      )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedMetricType = value ?? 'all';
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<Duration>(
                initialValue: _selectedTimeRange,
                decoration: const InputDecoration(
                  labelText: 'Time Range',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: Duration(minutes: 15), child: Text('Last 15 minutes')),
                  DropdownMenuItem(value: Duration(hours: 1), child: Text('Last hour')),
                  DropdownMenuItem(value: Duration(hours: 6), child: Text('Last 6 hours')),
                  DropdownMenuItem(value: Duration(hours: 24), child: Text('Last 24 hours')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedTimeRange = value ?? const Duration(hours: 1);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsContent(Map<MetricType, List<PerformanceMetric>> metricsByType) {
    if (metricsByType.isEmpty) {
      return const Center(
        child: Text(
          'No metrics available for the selected filters',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: metricsByType.length,
      itemBuilder: (context, index) {
        final entry = metricsByType.entries.elementAt(index);
        final type = entry.key;
        final metrics = entry.value;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            title: Text(
              type.name.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${metrics.length} metrics'),
            children: [
              _buildMetricsList(metrics),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricsList(List<PerformanceMetric> metrics) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: metrics.map((metric) => _buildMetricCard(metric)).toList(),
      ),
    );
  }

  Widget _buildMetricCard(PerformanceMetric metric) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(metric.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Value: ${_formatMetricValue(metric.value, metric.unit)}'),
            Text('Time: ${_formatTimestamp(metric.timestamp)}'),
            if (metric.description != null) Text(metric.description!, style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: _buildMetricIcon(metric.type),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildMetricIcon(MetricType type) {
    IconData iconData;
    Color color;

    switch (type) {
      case MetricType.cpu:
        iconData = Icons.memory;
        color = Colors.blue;
      case MetricType.memory:
        iconData = Icons.storage;
        color = Colors.green;
      case MetricType.disk:
        iconData = Icons.storage;
        color = Colors.orange;
      case MetricType.network:
        iconData = Icons.network_check;
        color = Colors.purple;
      case MetricType.database:
        iconData = Icons.storage;
        color = Colors.red;
      case MetricType.api:
        iconData = Icons.api;
        color = Colors.teal;
      case MetricType.cache:
        iconData = Icons.cached;
        color = Colors.amber;
      case MetricType.custom:
        iconData = Icons.analytics;
        color = Colors.grey;
    }

    return Icon(iconData, color: color);
  }

  String _formatMetricValue(double value, MetricUnit unit) {
    switch (unit) {
      case MetricUnit.percentage:
        return '${(value * 100).toStringAsFixed(1)}%';
      case MetricUnit.bytes:
        return _formatBytes(value);
      case MetricUnit.milliseconds:
        return '${value.toStringAsFixed(1)} ms';
      case MetricUnit.count:
        return value.toStringAsFixed(0);
      case MetricUnit.requestsPerSecond:
        return '${value.toStringAsFixed(1)} req/s';
      case MetricUnit.custom:
        return value.toStringAsFixed(2);
    }
  }

  String _formatBytes(double bytes) {
    if (bytes < 1024) return '${bytes.toStringAsFixed(0)} B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    if (bytes < 1024 * 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    return '${(bytes / (1024 * 1024 * 1024 * 1024)).toStringAsFixed(1)} TB';
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
