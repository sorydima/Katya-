import 'package:flutter/material.dart';

import '../../services/performance/performance_analytics_service.dart';
import '../../services/performance/performance_optimization_service.dart';
import '../../services/performance/performance_profiler_service.dart';

/// Дашборд аналитики производительности
class PerformanceAnalyticsDashboard extends StatefulWidget {
  const PerformanceAnalyticsDashboard({super.key});

  @override
  State<PerformanceAnalyticsDashboard> createState() => _PerformanceAnalyticsDashboardState();
}

class _PerformanceAnalyticsDashboardState extends State<PerformanceAnalyticsDashboard> with TickerProviderStateMixin {
  final PerformanceAnalyticsService _analyticsService = PerformanceAnalyticsService();
  final PerformanceProfilerService _profilerService = PerformanceProfilerService();
  final PerformanceOptimizationService _optimizationService = PerformanceOptimizationService();

  late TabController _tabController;
  bool _isLoading = false;
  Map<String, PerformanceMetric> _metrics = {};
  List<PerformanceProfile> _profiles = [];
  List<OptimizationRecommendation> _recommendations = [];
  PerformanceStatistics? _statistics;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
    _startServices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _stopServices();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final Map<String, PerformanceMetric> metrics = _analyticsService.getMetrics();
      final List<PerformanceProfile> profiles = _analyticsService.getProfiles();
      final List<OptimizationRecommendation> recommendations = _optimizationService.getRecommendations();
      final PerformanceStatistics statistics = _analyticsService.getStatistics();

      setState(() {
        _metrics = metrics;
        _profiles = profiles;
        _recommendations = recommendations;
        _statistics = statistics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load performance data: $e');
    }
  }

  Future<void> _startServices() async {
    await _analyticsService.startCollection();
    await _profilerService.startProfiling();
    await _optimizationService.startAutoOptimization();
  }

  Future<void> _stopServices() async {
    await _analyticsService.stopCollection();
    await _profilerService.stopProfiling();
    await _optimizationService.stopAutoOptimization();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Analytics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.analytics), text: 'Metrics'),
            Tab(icon: Icon(Icons.timeline), text: 'Trends'),
            Tab(icon: Icon(Icons.speed), text: 'Profiling'),
            Tab(icon: Icon(Icons.tune), text: 'Optimization'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMetricsTab(),
          _buildTrendsTab(),
          _buildProfilingTab(),
          _buildOptimizationTab(),
        ],
      ),
    );
  }

  Widget _buildMetricsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _buildStatisticsCard(),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _metrics.length,
            itemBuilder: (context, index) {
              final PerformanceMetric metric = _metrics.values.elementAt(index);
              return _buildMetricCard(metric);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsCard() {
    if (_statistics == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Total Metrics', '${_statistics!.totalMetrics}', Icons.analytics),
            _buildStatItem('Active Alerts', '${_statistics!.activeAlerts}', Icons.warning),
            _buildStatItem('Average Score', _statistics!.averageScore.toStringAsFixed(1), Icons.score),
            _buildStatItem('Status', _statistics!.collectionActive ? 'Active' : 'Inactive', Icons.power),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildMetricCard(PerformanceMetric metric) {
    final double percentage = (metric.currentValue - metric.minValue) / (metric.maxValue - metric.minValue);
    final Color color = _getMetricColor(percentage);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    metric.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  _getMetricIcon(metric.id),
                  color: color,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${metric.currentValue.toStringAsFixed(1)} ${metric.unit}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
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
      ),
    );
  }

  Widget _buildTrendsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Trends',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _profiles.length,
              itemBuilder: (context, index) {
                final PerformanceProfile profile = _profiles[index];
                return _buildProfileCard(profile);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(PerformanceProfile profile) {
    final Color color = _getProfileColor(profile.health);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    profile.health.name.toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Score: ${profile.score.toStringAsFixed(1)}/100',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (profile.recommendations.isNotEmpty) ...[
              const Text(
                'Recommendations:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              ...profile.recommendations.map((rec) => Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: Text('• $rec'),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfilingTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Code Profiling',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _startProfiling,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Profiling'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _stopProfiling,
                icon: const Icon(Icons.stop),
                label: const Text('Stop Profiling'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Profiling Statistics',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<ProfilingStatistics>(
                      future: Future.value(_profilerService.getStatistics()),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final ProfilingStatistics stats = snapshot.data!;
                          return Column(
                            children: [
                              _buildProfilingStat('Total Profiles', '${stats.totalProfiles}'),
                              _buildProfilingStat('Total Traces', '${stats.totalTraces}'),
                              _buildProfilingStat('Active Profiles', '${stats.activeProfiles}'),
                              _buildProfilingStat('Profiling Status', stats.isProfiling ? 'Active' : 'Inactive'),
                            ],
                          );
                        }
                        return const CircularProgressIndicator();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilingStat(String label, String value) {
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

  Widget _buildOptimizationTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Optimization',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _startAutoOptimization,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Start Auto Optimization'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _stopAutoOptimization,
                icon: const Icon(Icons.stop),
                label: const Text('Stop Auto Optimization'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _recommendations.isEmpty
                ? const Center(
                    child: Text(
                      'No optimization recommendations available',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _recommendations.length,
                    itemBuilder: (context, index) {
                      final OptimizationRecommendation recommendation = _recommendations[index];
                      return _buildRecommendationCard(recommendation);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(OptimizationRecommendation recommendation) {
    final Color color = _getRecommendationColor(recommendation.severity);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    recommendation.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    recommendation.severity.name.toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              recommendation.description,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Category: ${recommendation.category.name}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            if (recommendation.suggestedActions.isNotEmpty) ...[
              const Text(
                'Suggested Actions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: recommendation.suggestedActions.map((action) {
                  return ActionChip(
                    label: Text(action),
                    onPressed: () => _executeAction(action, recommendation.id),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
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
      default:
        return Icons.analytics;
    }
  }

  Color _getProfileColor(PerformanceHealth health) {
    switch (health) {
      case PerformanceHealth.good:
        return Colors.green;
      case PerformanceHealth.warning:
        return Colors.orange;
      case PerformanceHealth.critical:
        return Colors.red;
    }
  }

  Color _getRecommendationColor(OptimizationSeverity severity) {
    switch (severity) {
      case OptimizationSeverity.low:
        return Colors.blue;
      case OptimizationSeverity.medium:
        return Colors.orange;
      case OptimizationSeverity.high:
        return Colors.red;
      case OptimizationSeverity.critical:
        return Colors.purple;
    }
  }

  // Event handlers

  Future<void> _startProfiling() async {
    try {
      await _profilerService.startProfiling();
      _showSuccessSnackBar('Profiling started');
    } catch (e) {
      _showErrorSnackBar('Failed to start profiling: $e');
    }
  }

  Future<void> _stopProfiling() async {
    try {
      await _profilerService.stopProfiling();
      _showSuccessSnackBar('Profiling stopped');
    } catch (e) {
      _showErrorSnackBar('Failed to stop profiling: $e');
    }
  }

  Future<void> _startAutoOptimization() async {
    try {
      await _optimizationService.startAutoOptimization();
      _showSuccessSnackBar('Auto optimization started');
    } catch (e) {
      _showErrorSnackBar('Failed to start auto optimization: $e');
    }
  }

  Future<void> _stopAutoOptimization() async {
    try {
      await _optimizationService.stopAutoOptimization();
      _showSuccessSnackBar('Auto optimization stopped');
    } catch (e) {
      _showErrorSnackBar('Failed to stop auto optimization: $e');
    }
  }

  Future<void> _executeAction(String actionId, String recommendationId) async {
    try {
      await _optimizationService.executeAction(actionId, recommendationId: recommendationId);
      _showSuccessSnackBar('Action executed successfully');
      _loadData(); // Refresh recommendations
    } catch (e) {
      _showErrorSnackBar('Failed to execute action: $e');
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
