import 'package:flutter/material.dart';
import '../../services/performance_analytics/performance_trend_analyzer_service.dart';

/// Дашборд для анализа трендов и аномалий в метриках производительности
class PerformanceTrendAnalyzerDashboard extends StatefulWidget {
  const PerformanceTrendAnalyzerDashboard({super.key});

  @override
  State<PerformanceTrendAnalyzerDashboard> createState() => _PerformanceTrendAnalyzerDashboardState();
}

class _PerformanceTrendAnalyzerDashboardState extends State<PerformanceTrendAnalyzerDashboard> {
  final PerformanceTrendAnalyzerService _trendService = PerformanceTrendAnalyzerService();
  final List<TrendAnalysis> _analyses = [];
  final List<Anomaly> _anomalies = [];
  final List<Forecast> _forecasts = [];
  bool _isLoading = true;
  String _selectedMetric = 'all';
  String _selectedTab = 'trends';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final analyses = _trendService.getAllAnalyses();
      final anomalies = _trendService.getAllAnomalies();
      final forecasts = _trendService.getAllForecasts();

      setState(() {
        _analyses.clear();
        _analyses.addAll(analyses);
        _anomalies.clear();
        _anomalies.addAll(anomalies);
        _forecasts.clear();
        _forecasts.addAll(forecasts);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load trend analysis data: $e');
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _analyzeTrend(String metricName) async {
    try {
      final analysis = _trendService.analyzeTrend(metricName);
      setState(() {
        _analyses.add(analysis);
        _anomalies.addAll(analysis.anomalies);
        _forecasts.addAll(analysis.forecasts);
      });
      _showSuccessSnackBar('Trend analysis completed for $metricName');
    } catch (e) {
      _showErrorSnackBar('Failed to analyze trend: $e');
    }
  }

  List<String> _getAvailableMetrics() {
    final metrics = <String>{};
    for (final analysis in _analyses) {
      metrics.add(analysis.metricName);
    }
    return metrics.toList()..sort();
  }

  List<TrendAnalysis> _getFilteredAnalyses() {
    if (_selectedMetric == 'all') {
      return _analyses;
    }
    return _analyses.where((analysis) => analysis.metricName == _selectedMetric).toList();
  }

  List<Anomaly> _getFilteredAnomalies() {
    var filtered = _anomalies;
    if (_selectedMetric != 'all') {
      filtered = filtered.where((anomaly) => anomaly.metricName == _selectedMetric).toList();
    }
    return filtered;
  }

  List<Forecast> _getFilteredForecasts() {
    var filtered = _forecasts;
    if (_selectedMetric != 'all') {
      filtered = filtered.where((forecast) => forecast.metricName == _selectedMetric).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Trend Analyzer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilters(),
                _buildTabBar(),
                Expanded(
                  child: _buildTabContent(),
                ),
              ],
            ),
    );
  }

  Widget _buildFilters() {
    final availableMetrics = _getAvailableMetrics();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedMetric,
                decoration: const InputDecoration(
                  labelText: 'Metric',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: 'all', child: Text('All Metrics')),
                  ...availableMetrics.map((metric) => DropdownMenuItem(
                        value: metric,
                        child: Text(metric),
                      )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedMetric = value ?? 'all';
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: _selectedMetric != 'all' ? () => _analyzeTrend(_selectedMetric) : null,
              icon: const Icon(Icons.analytics),
              label: const Text('Analyze Trend'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      onTap: (index) {
        setState(() {
          _selectedTab = ['trends', 'anomalies', 'forecasts'][index];
        });
      },
      tabs: const [
        Tab(text: 'Trends', icon: Icon(Icons.trending_up)),
        Tab(text: 'Anomalies', icon: Icon(Icons.warning)),
        Tab(text: 'Forecasts', icon: Icon(Icons.visibility)),
      ],
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 'trends':
        return _buildTrendsTab();
      case 'anomalies':
        return _buildAnomaliesTab();
      case 'forecasts':
        return _buildForecastsTab();
      default:
        return _buildTrendsTab();
    }
  }

  Widget _buildTrendsTab() {
    final filteredAnalyses = _getFilteredAnalyses();

    if (filteredAnalyses.isEmpty) {
      return const Center(
        child: Text(
          'No trend analyses available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredAnalyses.length,
      itemBuilder: (context, index) {
        final analysis = filteredAnalyses[index];
        return _buildTrendAnalysisCard(analysis);
      },
    );
  }

  Widget _buildTrendAnalysisCard(TrendAnalysis analysis) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(analysis.metricName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Analysis Time: ${_formatTimestamp(analysis.analysisTime)}'),
            if (analysis.trend != null)
              Text(
                  'Trend: ${analysis.trend!.type.name} (confidence: ${(analysis.trend!.confidence * 100).toStringAsFixed(1)}%)'),
            Text('Anomalies: ${analysis.anomalies.length}, Forecasts: ${analysis.forecasts.length}'),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (analysis.trend != null) ...[
                  _buildTrendDetails(analysis.trend!),
                  const SizedBox(height: 16),
                ],
                if (analysis.summary != null) ...[
                  Text(
                    'Summary',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(analysis.summary!),
                  ),
                ],
                const SizedBox(height: 16),
                _buildStatisticsSection(analysis.statistics),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendDetails(Trend trend) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trend Details',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        _buildDetailRow('Type', trend.type.name),
        _buildDetailRow('Slope', trend.slope.toStringAsFixed(4)),
        _buildDetailRow('Confidence', '${(trend.confidence * 100).toStringAsFixed(1)}%'),
        _buildDetailRow('Start Time', _formatTimestamp(trend.startTime)),
        _buildDetailRow('End Time', _formatTimestamp(trend.endTime)),
        if (trend.metadata != null) ...[
          const SizedBox(height: 8),
          Text(
            'Metadata',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              trend.metadata.toString(),
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatisticsSection(Map<String, dynamic> statistics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        ...statistics.entries.map((entry) => _buildDetailRow(entry.key, entry.value.toString())),
      ],
    );
  }

  Widget _buildAnomaliesTab() {
    final filteredAnomalies = _getFilteredAnomalies();

    if (filteredAnomalies.isEmpty) {
      return const Center(
        child: Text(
          'No anomalies detected',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredAnomalies.length,
      itemBuilder: (context, index) {
        final anomaly = filteredAnomalies[index];
        return _buildAnomalyCard(anomaly);
      },
    );
  }

  Widget _buildAnomalyCard(Anomaly anomaly) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(anomaly.metricName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(anomaly.description ?? 'Anomaly detected'),
            Text('Time: ${_formatTimestamp(anomaly.timestamp)}'),
            Text('Severity: ${anomaly.severity.toStringAsFixed(2)}'),
          ],
        ),
        trailing: _buildAnomalyTypeIcon(anomaly.type),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildForecastsTab() {
    final filteredForecasts = _getFilteredForecasts();

    if (filteredForecasts.isEmpty) {
      return const Center(
        child: Text(
          'No forecasts available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredForecasts.length,
      itemBuilder: (context, index) {
        final forecast = filteredForecasts[index];
        return _buildForecastCard(forecast);
      },
    );
  }

  Widget _buildForecastCard(Forecast forecast) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(forecast.metricName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Predicted: ${forecast.predictedValue.toStringAsFixed(2)}'),
            Text('Confidence: ${(forecast.confidence * 100).toStringAsFixed(1)}%'),
            Text('Range: ${forecast.lowerBound.toStringAsFixed(2)} - ${forecast.upperBound.toStringAsFixed(2)}'),
            Text('Method: ${forecast.method}'),
            Text('Forecast Time: ${_formatTimestamp(forecast.forecastTime)}'),
          ],
        ),
        trailing: const Icon(Icons.visibility, color: Colors.blue),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildAnomalyTypeIcon(AnomalyType type) {
    IconData iconData;
    Color color;

    switch (type) {
      case AnomalyType.spike:
        iconData = Icons.trending_up;
        color = Colors.red;
      case AnomalyType.drop:
        iconData = Icons.trending_down;
        color = Colors.blue;
      case AnomalyType.outlier:
        iconData = Icons.circle_outlined;
        color = Colors.orange;
      case AnomalyType.pattern:
        iconData = Icons.pattern;
        color = Colors.purple;
      case AnomalyType.drift:
        iconData = Icons.drive_eta;
        color = Colors.green;
      default:
        iconData = Icons.warning;
        color = Colors.grey;
    }

    return Icon(iconData, color: color);
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
  }
}
