import 'package:flutter/material.dart';

import '../../services/performance_analytics/performance_profiler_service.dart';

/// Дашборд для управления профилированием производительности
class PerformanceProfilerDashboard extends StatefulWidget {
  const PerformanceProfilerDashboard({super.key});

  @override
  State<PerformanceProfilerDashboard> createState() => _PerformanceProfilerDashboardState();
}

class _PerformanceProfilerDashboardState extends State<PerformanceProfilerDashboard> {
  final PerformanceProfilerService _profilerService = PerformanceProfilerService();
  final List<ProfilingReport> _reports = [];
  final List<ProfilingPoint> _activePoints = [];
  bool _isLoading = true;
  bool _isProfiling = false;
  String? _selectedReportId;

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
      final reports = _profilerService.getAllReports();
      final activePoints = _profilerService.getActivePoints();
      final isProfiling = _profilerService.isProfiling;

      setState(() {
        _reports.clear();
        _reports.addAll(reports);
        _activePoints.clear();
        _activePoints.addAll(activePoints);
        _isProfiling = isProfiling;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load profiler data: $e');
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

  void _startProfiling() {
    try {
      _profilerService.startProfiling(name: 'Manual Profiling Session');
      setState(() {
        _isProfiling = true;
      });
      _showSuccessSnackBar('Profiling started');
    } catch (e) {
      _showErrorSnackBar('Failed to start profiling: $e');
    }
  }

  void _stopProfiling() {
    try {
      final report = _profilerService.stopProfiling(name: 'Manual Profiling Session');
      setState(() {
        _isProfiling = false;
        _reports.add(report);
        _selectedReportId = report.id;
      });
      _showSuccessSnackBar('Profiling stopped. Report generated.');
    } catch (e) {
      _showErrorSnackBar('Failed to stop profiling: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Profiler Dashboard'),
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
                _buildProfilingControls(),
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
    );
  }

  Widget _buildProfilingControls() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profiling Status',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        _isProfiling ? Icons.play_circle : Icons.pause_circle,
                        color: _isProfiling ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isProfiling ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: _isProfiling ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: _isProfiling ? _stopProfiling : _startProfiling,
              icon: Icon(_isProfiling ? Icons.stop : Icons.play_arrow),
              label: Text(_isProfiling ? 'Stop Profiling' : 'Start Profiling'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isProfiling ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Active Points', icon: Icon(Icons.timeline)),
              Tab(text: 'Reports', icon: Icon(Icons.assessment)),
              Tab(text: 'Configuration', icon: Icon(Icons.settings)),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildActivePointsTab(),
                _buildReportsTab(),
                _buildConfigurationTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivePointsTab() {
    if (_activePoints.isEmpty) {
      return const Center(
        child: Text(
          'No active profiling points',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _activePoints.length,
      itemBuilder: (context, index) {
        final point = _activePoints[index];
        return _buildProfilingPointCard(point);
      },
    );
  }

  Widget _buildProfilingPointCard(ProfilingPoint point) {
    final duration =
        point.endTime != null ? point.endTime!.difference(point.startTime) : DateTime.now().difference(point.startTime);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(point.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${point.type.name}'),
            Text('Duration: ${_formatDuration(duration)}'),
            Text('Started: ${_formatTimestamp(point.startTime)}'),
            if (point.metadata != null && point.metadata!.isNotEmpty) Text('Metadata: ${point.metadata}'),
          ],
        ),
        trailing: _buildProfilingTypeIcon(point.type),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildReportsTab() {
    if (_reports.isEmpty) {
      return const Center(
        child: Text(
          'No profiling reports available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reports.length,
      itemBuilder: (context, index) {
        final report = _reports[index];
        return _buildReportCard(report);
      },
    );
  }

  Widget _buildReportCard(ProfilingReport report) {
    final isSelected = _selectedReportId == report.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: ListTile(
        title: Text(report.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Duration: ${_formatDuration(report.totalDuration)}'),
            Text('Points: ${report.rootPoints.length}'),
            Text('Level: ${report.level.name}'),
            Text('Created: ${_formatTimestamp(report.startTime)}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility),
              onPressed: () => _showReportDetails(report),
            ),
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => _exportReport(report),
            ),
          ],
        ),
        onTap: () {
          setState(() {
            _selectedReportId = isSelected ? null : report.id;
          });
        },
        isThreeLine: true,
      ),
    );
  }

  Widget _buildConfigurationTab() {
    final config = _profilerService.config;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profiling Configuration',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  _buildConfigItem('Level', config.level.name),
                  _buildConfigItem('Memory Profiling', config.enableMemoryProfiling.toString()),
                  _buildConfigItem('CPU Profiling', config.enableCpuProfiling.toString()),
                  _buildConfigItem('Network Profiling', config.enableNetworkProfiling.toString()),
                  _buildConfigItem('Max Duration', _formatDuration(config.maxDuration)),
                  _buildConfigItem('Max Depth', config.maxDepth.toString()),
                  _buildConfigItem('Auto Start', config.autoStart.toString()),
                  _buildConfigItem('Auto Stop', config.autoStop.toString()),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Actions',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _clearReports,
                        icon: const Icon(Icons.clear_all),
                        label: const Text('Clear Reports'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _clearOldReports,
                        icon: const Icon(Icons.delete_sweep),
                        label: const Text('Clear Old Reports'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilingTypeIcon(ProfilingType type) {
    IconData iconData;
    Color color;

    switch (type) {
      case ProfilingType.function:
        iconData = Icons.functions;
        color = Colors.blue;
      case ProfilingType.database:
        iconData = Icons.storage;
        color = Colors.green;
      case ProfilingType.api:
        iconData = Icons.api;
        color = Colors.orange;
      case ProfilingType.memory:
        iconData = Icons.memory;
        color = Colors.purple;
      case ProfilingType.cpu:
        iconData = Icons.speed;
        color = Colors.red;
      case ProfilingType.network:
        iconData = Icons.network_check;
        color = Colors.teal;
      case ProfilingType.custom:
        iconData = Icons.analytics;
        color = Colors.grey;
    }

    return Icon(iconData, color: color);
  }

  void _showReportDetails(ProfilingReport report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(report.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildReportDetailItem('ID', report.id),
              _buildReportDetailItem('Start Time', _formatTimestamp(report.startTime)),
              _buildReportDetailItem('End Time', _formatTimestamp(report.endTime)),
              _buildReportDetailItem('Duration', _formatDuration(report.totalDuration)),
              _buildReportDetailItem('Level', report.level.name),
              _buildReportDetailItem('Root Points', report.rootPoints.length.toString()),
              const SizedBox(height: 16),
              const Text('Summary:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...report.summary.entries.map((entry) => _buildReportDetailItem(entry.key, entry.value.toString())),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportDetailItem(String label, String value) {
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

  void _exportReport(ProfilingReport report) {
    try {
      _profilerService.exportReportToJson(report.id);
      // В реальном приложении здесь будет логика экспорта в файл
      _showSuccessSnackBar('Report exported successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to export report: $e');
    }
  }

  void _clearReports() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Reports'),
        content: const Text('Are you sure you want to clear all profiling reports? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _profilerService.clearReports();
              setState(() {
                _reports.clear();
                _selectedReportId = null;
              });
              Navigator.of(context).pop();
              _showSuccessSnackBar('All reports cleared');
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _clearOldReports() {
    _profilerService.clearOldReports();
    _loadData();
    _showSuccessSnackBar('Old reports cleared');
  }

  String _formatDuration(Duration duration) {
    if (duration.inMicroseconds < 1000) {
      return '${duration.inMicroseconds}μs';
    } else if (duration.inMilliseconds < 1000) {
      return '${duration.inMilliseconds}ms';
    } else if (duration.inSeconds < 60) {
      return '${duration.inSeconds}s';
    } else {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
  }
}
