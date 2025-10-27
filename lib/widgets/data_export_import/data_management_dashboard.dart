import 'package:flutter/material.dart';

import '../../services/data_export_import/bulk_operations_service.dart';
import '../../services/data_export_import/data_validation_service.dart';
import 'export_widget.dart';
import 'import_widget.dart';

/// Дашборд для управления экспортом и импортом данных
class DataManagementDashboard extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final Map<String, dynamic>? schema;
  final List<BusinessRule>? businessRules;

  const DataManagementDashboard({
    super.key,
    this.initialData,
    this.schema,
    this.businessRules,
  });

  @override
  State<DataManagementDashboard> createState() => _DataManagementDashboardState();
}

class _DataManagementDashboardState extends State<DataManagementDashboard> with TickerProviderStateMixin {
  late TabController _tabController;
  final BulkOperationsService _bulkService = BulkOperationsService();
  final DataValidationService _validationService = DataValidationService();

  // Данные для экспорта
  Map<String, dynamic> _exportData = {};

  // Статистика операций
  int _totalExports = 0;
  int _totalImports = 0;
  int _successfulOperations = 0;
  int _failedOperations = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _exportData = widget.initialData ?? {};
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Management Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.download), text: 'Export'),
            Tab(icon: Icon(Icons.upload), text: 'Import'),
            Tab(icon: Icon(Icons.sync), text: 'Sync'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExportTab(),
          _buildImportTab(),
          _buildSyncTab(),
          _buildAnalyticsTab(),
        ],
      ),
    );
  }

  Widget _buildExportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Статистика экспорта
          _buildExportStatistics(),
          const SizedBox(height: 16),

          // Виджет экспорта
          ExportWidget(
            data: _exportData,
            defaultFileName: 'katya_export_${DateTime.now().millisecondsSinceEpoch}',
            onExportCompleted: _onExportCompleted,
            onError: _onOperationError,
          ),
          const SizedBox(height: 16),

          // Быстрые действия экспорта
          _buildQuickExportActions(),
        ],
      ),
    );
  }

  Widget _buildImportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Статистика импорта
          _buildImportStatistics(),
          const SizedBox(height: 16),

          // Виджет импорта
          ImportWidget(
            schema: widget.schema,
            businessRules: widget.businessRules,
            onImportCompleted: _onImportCompleted,
            onError: _onOperationError,
          ),
          const SizedBox(height: 16),

          // Шаблоны импорта
          _buildImportTemplates(),
        ],
      ),
    );
  }

  Widget _buildSyncTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Настройки синхронизации
          _buildSyncSettings(),
          const SizedBox(height: 16),

          // История синхронизации
          _buildSyncHistory(),
          const SizedBox(height: 16),

          // Управление конфликтами
          _buildConflictResolution(),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Общая статистика
          _buildOverallStatistics(),
          const SizedBox(height: 16),

          // Графики операций
          _buildOperationCharts(),
          const SizedBox(height: 16),

          // Отчеты
          _buildReports(),
        ],
      ),
    );
  }

  Widget _buildExportStatistics() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Exports',
                    _totalExports.toString(),
                    Icons.download,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Successful',
                    _successfulOperations.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Failed',
                    _failedOperations.toString(),
                    Icons.error,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportStatistics() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Import Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Imports',
                    _totalImports.toString(),
                    Icons.upload,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Successful',
                    _successfulOperations.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Failed',
                    _failedOperations.toString(),
                    Icons.error,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
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
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickExportActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Export Actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _exportUsers(),
                  icon: const Icon(Icons.people),
                  label: const Text('Export Users'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _exportMessages(),
                  icon: const Icon(Icons.message),
                  label: const Text('Export Messages'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _exportRooms(),
                  icon: const Icon(Icons.room),
                  label: const Text('Export Rooms'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _exportAllData(),
                  icon: const Icon(Icons.data_object),
                  label: const Text('Export All'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportTemplates() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Import Templates',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Users Template'),
              subtitle: const Text('CSV template for importing users'),
              trailing: const Icon(Icons.download),
              onTap: () => _downloadTemplate('users'),
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Messages Template'),
              subtitle: const Text('CSV template for importing messages'),
              trailing: const Icon(Icons.download),
              onTap: () => _downloadTemplate('messages'),
            ),
            ListTile(
              leading: const Icon(Icons.room),
              title: const Text('Rooms Template'),
              subtitle: const Text('CSV template for importing rooms'),
              trailing: const Icon(Icons.download),
              onTap: () => _downloadTemplate('rooms'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sync Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Auto Sync'),
              subtitle: const Text('Automatically sync data changes'),
              value: false,
              onChanged: (value) {
                // TODO: Implement auto sync
              },
            ),
            SwitchListTile(
              title: const Text('Create Backup'),
              subtitle: const Text('Create backup before sync'),
              value: true,
              onChanged: (value) {
                // TODO: Implement backup setting
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _performSync(),
              icon: const Icon(Icons.sync),
              label: const Text('Sync Now'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncHistory() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sync History',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.sync, color: Colors.green),
              title: Text('Full Sync'),
              subtitle: Text('2024-01-15 14:30:00 - 1,234 records synced'),
              trailing: Icon(Icons.check_circle, color: Colors.green),
            ),
            const ListTile(
              leading: Icon(Icons.sync, color: Colors.orange),
              title: Text('Partial Sync'),
              subtitle: Text('2024-01-14 09:15:00 - 567 records synced'),
              trailing: Icon(Icons.warning, color: Colors.orange),
            ),
            const ListTile(
              leading: Icon(Icons.sync, color: Colors.red),
              title: Text('Failed Sync'),
              subtitle: Text('2024-01-13 16:45:00 - Connection timeout'),
              trailing: Icon(Icons.error, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConflictResolution() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conflict Resolution',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            RadioListTile<String>(
              title: const Text('Source Wins'),
              subtitle: const Text('Use source data when conflicts occur'),
              value: 'source',
              groupValue: 'source',
              onChanged: (value) {
                // TODO: Implement conflict resolution strategy
              },
            ),
            RadioListTile<String>(
              title: const Text('Target Wins'),
              subtitle: const Text('Keep target data when conflicts occur'),
              value: 'target',
              groupValue: 'source',
              onChanged: (value) {
                // TODO: Implement conflict resolution strategy
              },
            ),
            RadioListTile<String>(
              title: const Text('Manual Review'),
              subtitle: const Text('Review conflicts manually'),
              value: 'manual',
              groupValue: 'source',
              onChanged: (value) {
                // TODO: Implement conflict resolution strategy
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStatistics() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Operations',
                    (_totalExports + _totalImports).toString(),
                    Icons.analytics,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Success Rate',
                    _calculateSuccessRate(),
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationCharts() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Operation Trends',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Chart Placeholder\n(Operation trends over time)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReports() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reports',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Export Report'),
              subtitle: const Text('Detailed export activity report'),
              trailing: const Icon(Icons.download),
              onTap: () => _generateReport('export'),
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Import Report'),
              subtitle: const Text('Detailed import activity report'),
              trailing: const Icon(Icons.download),
              onTap: () => _generateReport('import'),
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Sync Report'),
              subtitle: const Text('Data synchronization report'),
              trailing: const Icon(Icons.download),
              onTap: () => _generateReport('sync'),
            ),
          ],
        ),
      ),
    );
  }

  String _calculateSuccessRate() {
    final int total = _totalExports + _totalImports;
    if (total == 0) return '0%';
    final double rate = (_successfulOperations / total) * 100;
    return '${rate.toStringAsFixed(1)}%';
  }

  // Event handlers

  void _onExportCompleted(dynamic result) {
    setState(() {
      _totalExports++;
      if (result.success) {
        _successfulOperations++;
      } else {
        _failedOperations++;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.success ? 'Export completed successfully' : 'Export failed'),
        backgroundColor: result.success ? Colors.green : Colors.red,
      ),
    );
  }

  void _onImportCompleted(dynamic result) {
    setState(() {
      _totalImports++;
      if (result.success) {
        _successfulOperations++;
      } else {
        _failedOperations++;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.success ? 'Import completed successfully' : 'Import failed'),
        backgroundColor: result.success ? Colors.green : Colors.red,
      ),
    );
  }

  void _onOperationError(String error) {
    setState(() {
      _failedOperations++;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Operation failed: $error'),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Quick export actions

  void _exportUsers() {
    // TODO: Implement user export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User export not implemented yet')),
    );
  }

  void _exportMessages() {
    // TODO: Implement message export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message export not implemented yet')),
    );
  }

  void _exportRooms() {
    // TODO: Implement room export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Room export not implemented yet')),
    );
  }

  void _exportAllData() {
    // TODO: Implement full data export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Full data export not implemented yet')),
    );
  }

  void _downloadTemplate(String type) {
    // TODO: Implement template download
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$type template download not implemented yet')),
    );
  }

  void _performSync() {
    // TODO: Implement sync operation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sync operation not implemented yet')),
    );
  }

  void _generateReport(String type) {
    // TODO: Implement report generation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$type report generation not implemented yet')),
    );
  }
}
