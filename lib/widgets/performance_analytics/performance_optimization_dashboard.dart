import 'package:flutter/material.dart';
import '../../services/performance_analytics/performance_optimization_service.dart';

/// Дашборд для управления рекомендациями по оптимизации производительности
class PerformanceOptimizationDashboard extends StatefulWidget {
  const PerformanceOptimizationDashboard({super.key});

  @override
  State<PerformanceOptimizationDashboard> createState() => _PerformanceOptimizationDashboardState();
}

class _PerformanceOptimizationDashboardState extends State<PerformanceOptimizationDashboard> {
  final PerformanceOptimizationService _optimizationService = PerformanceOptimizationService();
  final List<OptimizationRecommendation> _recommendations = [];
  final List<PerformanceAnalysis> _analyses = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  String _selectedPriority = 'all';
  String _selectedStatus = 'all';

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
      final recommendations = _optimizationService.getAllRecommendations();
      final analyses = _optimizationService.getAllAnalyses();

      setState(() {
        _recommendations.clear();
        _recommendations.addAll(recommendations);
        _analyses.clear();
        _analyses.addAll(analyses);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load optimization data: $e');
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

  Future<void> _performAnalysis() async {
    try {
      final analysis = await _optimizationService.performAnalysis();
      setState(() {
        _analyses.add(analysis);
        _recommendations.addAll(analysis.recommendations);
      });
      _showSuccessSnackBar('Performance analysis completed');
    } catch (e) {
      _showErrorSnackBar('Failed to perform analysis: $e');
    }
  }

  void _updateRecommendationStatus(String id, RecommendationStatus status) {
    _optimizationService.updateRecommendationStatus(id, status);
    setState(() {
      final index = _recommendations.indexWhere((r) => r.id == id);
      if (index != -1) {
        _recommendations[index] = _recommendations[index].copyWith(
          status: status,
          completedAt: status == RecommendationStatus.completed ? DateTime.now() : null,
        );
      }
    });
    _showSuccessSnackBar('Recommendation status updated');
  }

  List<OptimizationRecommendation> _getFilteredRecommendations() {
    var filtered = _recommendations;

    // Фильтр по типу
    if (_selectedFilter != 'all') {
      final type = OptimizationType.values.firstWhere(
        (t) => t.name == _selectedFilter,
        orElse: () => OptimizationType.cpu,
      );
      filtered = filtered.where((r) => r.type == type).toList();
    }

    // Фильтр по приоритету
    if (_selectedPriority != 'all') {
      final priority = OptimizationPriority.values.firstWhere(
        (p) => p.name == _selectedPriority,
        orElse: () => OptimizationPriority.medium,
      );
      filtered = filtered.where((r) => r.priority == priority).toList();
    }

    // Фильтр по статусу
    if (_selectedStatus != 'all') {
      final status = RecommendationStatus.values.firstWhere(
        (s) => s.name == _selectedStatus,
        orElse: () => RecommendationStatus.pending,
      );
      filtered = filtered.where((r) => r.status == status).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecommendations = _getFilteredRecommendations();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Optimization Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: _performAnalysis,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilters(),
                _buildSummaryCards(),
                Expanded(
                  child: _buildRecommendationsList(filteredRecommendations),
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
                initialValue: _selectedFilter,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: 'all', child: Text('All Types')),
                  ...OptimizationType.values.map((type) => DropdownMenuItem(
                        value: type.name,
                        child: Text(type.name.toUpperCase()),
                      )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value ?? 'all';
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: 'all', child: Text('All Priorities')),
                  ...OptimizationPriority.values.map((priority) => DropdownMenuItem(
                        value: priority.name,
                        child: Text(priority.name.toUpperCase()),
                      )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedPriority = value ?? 'all';
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: 'all', child: Text('All Statuses')),
                  ...RecommendationStatus.values.map((status) => DropdownMenuItem(
                        value: status.name,
                        child: Text(status.name.toUpperCase()),
                      )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value ?? 'all';
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final criticalCount = _recommendations.where((r) => r.priority == OptimizationPriority.critical).length;
    final highCount = _recommendations.where((r) => r.priority == OptimizationPriority.high).length;
    final pendingCount = _recommendations.where((r) => r.status == RecommendationStatus.pending).length;
    final completedCount = _recommendations.where((r) => r.status == RecommendationStatus.completed).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Critical',
              criticalCount.toString(),
              Colors.red,
              Icons.warning,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard(
              'High Priority',
              highCount.toString(),
              Colors.orange,
              Icons.priority_high,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard(
              'Pending',
              pendingCount.toString(),
              Colors.blue,
              Icons.pending,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard(
              'Completed',
              completedCount.toString(),
              Colors.green,
              Icons.check_circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsList(List<OptimizationRecommendation> recommendations) {
    if (recommendations.isEmpty) {
      return const Center(
        child: Text(
          'No recommendations match the selected filters',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recommendations.length,
      itemBuilder: (context, index) {
        final recommendation = recommendations[index];
        return _buildRecommendationCard(recommendation);
      },
    );
  }

  Widget _buildRecommendationCard(OptimizationRecommendation recommendation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(recommendation.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildPriorityChip(recommendation.priority),
                const SizedBox(width: 8),
                _buildStatusChip(recommendation.status),
                const SizedBox(width: 8),
                _buildTypeChip(recommendation.type),
              ],
            ),
            if (recommendation.expectedImprovement != null)
              Text(
                'Expected improvement: ${(recommendation.expectedImprovement! * 100).toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Text(recommendation.description),
                if (recommendation.steps != null && recommendation.steps!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Steps',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  ...recommendation.steps!.map((step) => Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• '),
                            Expanded(child: Text(step)),
                          ],
                        ),
                      )),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Status: ',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    DropdownButton<RecommendationStatus>(
                      value: recommendation.status,
                      items: RecommendationStatus.values
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status.name.toUpperCase()),
                            ),
                          )
                          .toList(),
                      onChanged: (status) {
                        if (status != null) {
                          _updateRecommendationStatus(recommendation.id, status);
                        }
                      },
                    ),
                  ],
                ),
                if (recommendation.metadata != null && recommendation.metadata!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Metadata',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      recommendation.metadata.toString(),
                      style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(OptimizationPriority priority) {
    Color color;
    switch (priority) {
      case OptimizationPriority.critical:
        color = Colors.red;
      case OptimizationPriority.high:
        color = Colors.orange;
      case OptimizationPriority.medium:
        color = Colors.blue;
      case OptimizationPriority.low:
        color = Colors.green;
    }

    return Chip(
      label: Text(priority.name.toUpperCase()),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(color: color, fontSize: 10),
    );
  }

  Widget _buildStatusChip(RecommendationStatus status) {
    Color color;
    switch (status) {
      case RecommendationStatus.pending:
        color = Colors.orange;
      case RecommendationStatus.inProgress:
        color = Colors.blue;
      case RecommendationStatus.completed:
        color = Colors.green;
      case RecommendationStatus.rejected:
        color = Colors.red;
      case RecommendationStatus.failed:
        color = Colors.grey;
    }

    return Chip(
      label: Text(status.name.toUpperCase()),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(color: color, fontSize: 10),
    );
  }

  Widget _buildTypeChip(OptimizationType type) {
    return Chip(
      label: Text(type.name.toUpperCase()),
      backgroundColor: Colors.grey.withOpacity(0.2),
      labelStyle: const TextStyle(color: Colors.grey, fontSize: 10),
    );
  }
}
