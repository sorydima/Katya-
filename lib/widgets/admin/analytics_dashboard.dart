import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../services/analytics/models/analytics_task.dart';
import '../../services/analytics/models/network_metric.dart';
import '../../services/analytics/network_analytics_service.dart';

/// Аналитический дашборд с графиками и метриками
class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({super.key});

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> with TickerProviderStateMixin {
  final NetworkAnalyticsService _analyticsService = NetworkAnalyticsService();

  late TabController _tabController;

  Map<String, dynamic> _systemMetrics = {};
  List<NetworkMetric> _networkMetrics = [];
  List<AnalyticsTask> _analyticsTasks = [];
  bool _isLoading = true;

  // Фильтры
  final DateTime _selectedDateRange = DateTime.now().subtract(const Duration(days: 7));
  String _selectedMetricType = 'All';
  ImportanceLevel _selectedImportanceLevel = ImportanceLevel.medium;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAnalyticsData();

    // Обновление данных каждые 30 секунд
    _startPeriodicUpdate();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() => _isLoading = true);

    try {
      final systemMetrics = _analyticsService.getSystemMetrics();
      final networkMetrics = _analyticsService.getNetworkMetrics();
      final analyticsTasks = _analyticsService.getAnalyticsTasks();

      setState(() {
        _systemMetrics = systemMetrics;
        _networkMetrics = networkMetrics;
        _analyticsTasks = analyticsTasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load analytics data: $e');
    }
  }

  void _startPeriodicUpdate() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _loadAnalyticsData();
        _startPeriodicUpdate();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(),
                      _buildMetricsTab(),
                      _buildChartsTab(),
                      _buildTasksTab(),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateTaskDialog,
        tooltip: 'Create Analytics Task',
        child: const Icon(Icons.add),
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
                child: _buildFilters(),
              ),
              const SizedBox(width: 16),
              _buildActionButtons(),
            ],
          ),
          const SizedBox(height: 12),
          _buildQuickStats(),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        // Фильтр по дате
        Expanded(
          flex: 2,
          child: InkWell(
            onTap: _selectDateRange,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(Icons.date_range, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Last 7 days',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Фильтр по типу метрики
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            initialValue: _selectedMetricType,
            decoration: const InputDecoration(
              labelText: 'Metric Type',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All Types')),
              DropdownMenuItem(value: 'Performance', child: Text('Performance')),
              DropdownMenuItem(value: 'Security', child: Text('Security')),
              DropdownMenuItem(value: 'Network', child: Text('Network')),
              DropdownMenuItem(value: 'User', child: Text('User Activity')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedMetricType = value!;
              });
            },
          ),
        ),
        const SizedBox(width: 16),

        // Фильтр по важности
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<ImportanceLevel>(
            initialValue: _selectedImportanceLevel,
            decoration: const InputDecoration(
              labelText: 'Importance',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: ImportanceLevel.values.map((level) {
              return DropdownMenuItem<ImportanceLevel>(
                value: level,
                child: Text(_getImportanceLevelName(level)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedImportanceLevel = value!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadAnalyticsData,
          tooltip: 'Refresh',
        ),
        IconButton(
          icon: const Icon(Icons.download),
          onPressed: _exportAnalytics,
          tooltip: 'Export',
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: _showAnalyticsSettings,
          tooltip: 'Settings',
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        _buildStatChip('Total Metrics', '${_networkMetrics.length}'),
        const SizedBox(width: 8),
        _buildStatChip('Active Tasks', '${_analyticsTasks.where((t) => t.status == TaskStatus.running).length}'),
        const SizedBox(width: 8),
        _buildStatChip('Avg Response', '${_systemMetrics['avgResponseTime'] ?? 0}ms'),
        const SizedBox(width: 8),
        _buildStatChip('Success Rate', '${(_systemMetrics['successRate'] ?? 0).toStringAsFixed(1)}%'),
      ],
    );
  }

  Widget _buildStatChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
        Tab(icon: Icon(Icons.analytics), text: 'Metrics'),
        Tab(icon: Icon(Icons.show_chart), text: 'Charts'),
        Tab(icon: Icon(Icons.task), text: 'Tasks'),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics Overview',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),

          // Ключевые метрики
          _buildKeyMetrics(),

          const SizedBox(height: 24),

          // Графики производительности
          _buildPerformanceCharts(),

          const SizedBox(height: 24),

          // Последние задачи
          _buildRecentTasks(),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(
          'Active Users',
          '${_systemMetrics['activeUsers'] ?? 0}',
          Icons.people,
          Colors.blue,
          '+12%',
        ),
        _buildMetricCard(
          'Network Health',
          '${_systemMetrics['networkHealth'] ?? 0}%',
          Icons.network_check,
          Colors.green,
          '+5%',
        ),
        _buildMetricCard(
          'Response Time',
          '${_systemMetrics['avgResponseTime'] ?? 0}ms',
          Icons.speed,
          Colors.orange,
          '-8%',
        ),
        _buildMetricCard(
          'Success Rate',
          '${(_systemMetrics['successRate'] ?? 0).toStringAsFixed(1)}%',
          Icons.check_circle,
          Colors.purple,
          '+2%',
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, String change) {
    final isPositive = change.startsWith('+');

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
                Icon(icon, color: color, size: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isPositive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    change,
                    style: TextStyle(
                      color: isPositive ? Colors.green : Colors.red,
                      fontSize: 10,
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
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceCharts() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Trends',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    child: _buildSimpleChart('CPU Usage', [20, 25, 30, 35, 40, 38, 42], Colors.blue),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSimpleChart('Memory Usage', [60, 65, 70, 68, 72, 75, 78], Colors.green),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSimpleChart('Network I/O', [10, 15, 12, 18, 20, 22, 25], Colors.orange),
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
            painter: SimpleChartPainter(data, color),
            size: const Size(double.infinity, double.infinity),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTasks() {
    final recentTasks = _analyticsTasks.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Analytics Tasks',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...recentTasks.map((task) => _buildTaskItem(task)),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(AnalyticsTask task) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getTaskStatusColor(task.status),
        child: Icon(
          _getTaskTypeIcon(task.type),
          color: Colors.white,
          size: 16,
        ),
      ),
      title: Text(task.name),
      subtitle: Text('${_getTaskTypeName(task.type)} • ${task.priority.name}'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _getTaskStatusName(task.status),
            style: TextStyle(
              color: _getTaskStatusColor(task.status),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            task.createdAt.toString().substring(0, 19),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      onTap: () => _showTaskDetails(task),
    );
  }

  Widget _buildMetricsTab() {
    final filteredMetrics = _getFilteredMetrics();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredMetrics.length,
      itemBuilder: (context, index) {
        final metric = filteredMetrics[index];
        return _buildMetricListItem(metric);
      },
    );
  }

  Widget _buildMetricListItem(NetworkMetric metric) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getMetricTypeColor(metric.type),
          child: Icon(
            _getMetricTypeIcon(metric.type),
            color: Colors.white,
          ),
        ),
        title: Text(metric.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(metric.description),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildImportanceChip(metric.importance),
                const SizedBox(width: 8),
                Text(
                  'Value: ${metric.value}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              metric.timestamp.toString().substring(0, 19),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (metric.threshold != null)
              Text(
                'Threshold: ${metric.threshold}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: metric.value > metric.threshold! ? Colors.red : Colors.green,
                    ),
              ),
          ],
        ),
        onTap: () => _showMetricDetails(metric),
      ),
    );
  }

  Widget _buildChartsTab() {
    return const Center(
      child: Text('Advanced Charts Tab - Interactive charts will be displayed here'),
    );
  }

  Widget _buildTasksTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _analyticsTasks.length,
      itemBuilder: (context, index) {
        final task = _analyticsTasks[index];
        return _buildTaskCard(task);
      },
    );
  }

  Widget _buildTaskCard(AnalyticsTask task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getTaskStatusColor(task.status),
          child: Icon(
            _getTaskTypeIcon(task.type),
            color: Colors.white,
          ),
        ),
        title: Text(task.name),
        subtitle: Text('${_getTaskTypeName(task.type)} • ${task.priority.name}'),
        trailing: Text(
          _getTaskStatusName(task.status),
          style: TextStyle(
            color: _getTaskStatusColor(task.status),
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Description', task.description),
                _buildDetailRow('Created', task.createdAt.toString()),
                if (task.startedAt != null) _buildDetailRow('Started', task.startedAt!.toString()),
                if (task.completedAt != null) _buildDetailRow('Completed', task.completedAt!.toString()),
                if (task.errorMessage != null) _buildDetailRow('Error', task.errorMessage!),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => _showTaskDetails(task),
                      child: const Text('View Details'),
                    ),
                    const SizedBox(width: 8),
                    if (task.status == TaskStatus.pending)
                      ElevatedButton(
                        onPressed: () => _runTask(task),
                        child: const Text('Run'),
                      ),
                    if (task.status == TaskStatus.running)
                      ElevatedButton(
                        onPressed: () => _stopTask(task),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Stop'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildImportanceChip(ImportanceLevel importance) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getImportanceLevelColor(importance).withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        importance.name.toUpperCase(),
        style: TextStyle(
          color: _getImportanceLevelColor(importance),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<NetworkMetric> _getFilteredMetrics() {
    return _networkMetrics.where((metric) {
      if (_selectedMetricType != 'All' && metric.type != _selectedMetricType) {
        return false;
      }

      if (metric.importance != _selectedImportanceLevel) {
        return false;
      }

      return true;
    }).toList();
  }

  Color _getTaskStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Colors.orange;
      case TaskStatus.running:
        return Colors.blue;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.failed:
        return Colors.red;
      case TaskStatus.cancelled:
        return Colors.grey;
    }
  }

  Color _getTaskTypeColor(TaskType type) {
    switch (type) {
      case TaskType.performance:
        return Colors.blue;
      case TaskType.security:
        return Colors.red;
      case TaskType.network:
        return Colors.green;
      case TaskType.user:
        return Colors.purple;
    }
  }

  Color _getMetricTypeColor(String type) {
    switch (type) {
      case 'Performance':
        return Colors.blue;
      case 'Security':
        return Colors.red;
      case 'Network':
        return Colors.green;
      case 'User':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getTaskTypeIcon(TaskType type) {
    switch (type) {
      case TaskType.performance:
        return Icons.speed;
      case TaskType.security:
        return Icons.security;
      case TaskType.network:
        return Icons.network_check;
      case TaskType.user:
        return Icons.people;
    }
  }

  IconData _getMetricTypeIcon(String type) {
    switch (type) {
      case 'Performance':
        return Icons.speed;
      case 'Security':
        return Icons.security;
      case 'Network':
        return Icons.network_check;
      case 'User':
        return Icons.people;
      default:
        return Icons.analytics;
    }
  }

  String _getTaskTypeName(TaskType type) {
    switch (type) {
      case TaskType.performance:
        return 'Performance';
      case TaskType.security:
        return 'Security';
      case TaskType.network:
        return 'Network';
      case TaskType.user:
        return 'User Activity';
    }
  }

  String _getTaskStatusName(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.running:
        return 'Running';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.failed:
        return 'Failed';
      case TaskStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _getImportanceLevelName(ImportanceLevel level) {
    switch (level) {
      case ImportanceLevel.low:
        return 'Low';
      case ImportanceLevel.medium:
        return 'Medium';
      case ImportanceLevel.high:
        return 'High';
      case ImportanceLevel.critical:
        return 'Critical';
    }
  }

  Color _getImportanceLevelColor(ImportanceLevel level) {
    switch (level) {
      case ImportanceLevel.low:
        return Colors.green;
      case ImportanceLevel.medium:
        return Colors.blue;
      case ImportanceLevel.high:
        return Colors.orange;
      case ImportanceLevel.critical:
        return Colors.red;
    }
  }

  void _selectDateRange() {
    // TODO: Implement date range picker
    _showInfoSnackBar('Date range picker not implemented yet');
  }

  void _exportAnalytics() {
    // TODO: Implement analytics export
    _showInfoSnackBar('Analytics export started...');
  }

  void _showAnalyticsSettings() {
    // TODO: Implement analytics settings
    _showInfoSnackBar('Opening analytics settings...');
  }

  void _showCreateTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreateTaskDialog(
        onTaskCreated: () {
          _loadAnalyticsData();
        },
      ),
    );
  }

  void _showTaskDetails(AnalyticsTask task) {
    showDialog(
      context: context,
      builder: (context) => _TaskDetailsDialog(task: task),
    );
  }

  void _showMetricDetails(NetworkMetric metric) {
    showDialog(
      context: context,
      builder: (context) => _MetricDetailsDialog(metric: metric),
    );
  }

  Future<void> _runTask(AnalyticsTask task) async {
    try {
      await _analyticsService.runTask(task.id);
      _showSuccessSnackBar('Task started successfully');
      _loadAnalyticsData();
    } catch (e) {
      _showErrorSnackBar('Failed to start task: $e');
    }
  }

  Future<void> _stopTask(AnalyticsTask task) async {
    try {
      await _analyticsService.stopTask(task.id);
      _showSuccessSnackBar('Task stopped successfully');
      _loadAnalyticsData();
    } catch (e) {
      _showErrorSnackBar('Failed to stop task: $e');
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

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

// Диалоги для аналитики

class _CreateTaskDialog extends StatefulWidget {
  final VoidCallback onTaskCreated;

  const _CreateTaskDialog({required this.onTaskCreated});

  @override
  State<_CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<_CreateTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  TaskType _selectedType = TaskType.performance;
  TaskPriority _selectedPriority = TaskPriority.medium;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Analytics Task'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Task Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter task name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Task Type',
                  border: OutlineInputBorder(),
                ),
                items: TaskType.values.map((type) {
                  return DropdownMenuItem<TaskType>(
                    value: type,
                    child: Text(_getTaskTypeName(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskPriority>(
                initialValue: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: TaskPriority.values.map((priority) {
                  return DropdownMenuItem<TaskPriority>(
                    value: priority,
                    child: Text(priority.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPriority = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _createTask,
          child: const Text('Create Task'),
        ),
      ],
    );
  }

  String _getTaskTypeName(TaskType type) {
    switch (type) {
      case TaskType.performance:
        return 'Performance';
      case TaskType.security:
        return 'Security';
      case TaskType.network:
        return 'Network';
      case TaskType.user:
        return 'User Activity';
    }
  }

  void _createTask() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement task creation
      Navigator.pop(context);
      widget.onTaskCreated();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

class _TaskDetailsDialog extends StatelessWidget {
  final AnalyticsTask task;

  const _TaskDetailsDialog({required this.task});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(task.name),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Type', _getTaskTypeName(task.type)),
            _buildDetailRow('Priority', task.priority.name.toUpperCase()),
            _buildDetailRow('Status', _getTaskStatusName(task.status)),
            _buildDetailRow('Description', task.description),
            _buildDetailRow('Created', task.createdAt.toString()),
            if (task.startedAt != null) _buildDetailRow('Started', task.startedAt!.toString()),
            if (task.completedAt != null) _buildDetailRow('Completed', task.completedAt!.toString()),
            if (task.errorMessage != null) _buildDetailRow('Error', task.errorMessage!),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _getTaskTypeName(TaskType type) {
    switch (type) {
      case TaskType.performance:
        return 'Performance';
      case TaskType.security:
        return 'Security';
      case TaskType.network:
        return 'Network';
      case TaskType.user:
        return 'User Activity';
    }
  }

  String _getTaskStatusName(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.running:
        return 'Running';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.failed:
        return 'Failed';
      case TaskStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class _MetricDetailsDialog extends StatelessWidget {
  final NetworkMetric metric;

  const _MetricDetailsDialog({required this.metric});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(metric.name),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Type', metric.type),
            _buildDetailRow('Value', metric.value.toString()),
            _buildDetailRow('Importance', metric.importance.name.toUpperCase()),
            _buildDetailRow('Timestamp', metric.timestamp.toString()),
            if (metric.threshold != null) _buildDetailRow('Threshold', metric.threshold!.toString()),
            _buildDetailRow('Description', metric.description),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

/// Простой painter для отрисовки графиков
class SimpleChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  SimpleChartPainter(this.data, this.color);

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

    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final minValue = data.reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;
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

    // Рисуем точки
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - ((data[i] - minValue) / range * size.height);
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! SimpleChartPainter || oldDelegate.data != data;
  }
}
