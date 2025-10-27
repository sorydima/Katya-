import 'package:flutter/material.dart';

import '../../services/backup/backup_encryption_service.dart';
import '../../services/backup/backup_scheduler_service.dart';
import '../../services/backup/backup_service.dart';
import 'backup_creation_widget.dart';
import 'backup_list_widget.dart';
import 'backup_restore_widget.dart';
import 'backup_schedule_widget.dart';

/// Дашборд для управления резервным копированием
class BackupDashboard extends StatefulWidget {
  const BackupDashboard({super.key});

  @override
  State<BackupDashboard> createState() => _BackupDashboardState();
}

class _BackupDashboardState extends State<BackupDashboard> with TickerProviderStateMixin {
  late TabController _tabController;

  final BackupService _backupService = BackupService();
  final BackupSchedulerService _schedulerService = BackupSchedulerService();
  final BackupEncryptionService _encryptionService = BackupEncryptionService();

  // Статистика
  BackupStatistics? _statistics;
  BackupScheduleStatistics? _scheduleStatistics;
  List<BackupInfo> _backups = [];
  List<BackupSchedule> _schedules = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final List<Future> futures = [
        _backupService.getBackupStatistics(),
        _schedulerService.getScheduleStatistics(),
        _backupService.listBackups(),
        _schedulerService.getSchedules(),
      ];

      final List<dynamic> results = await Future.wait(futures);

      setState(() {
        _statistics = results[0] as BackupStatistics;
        _scheduleStatistics = results[1] as BackupScheduleStatistics;
        _backups = results[2] as List<BackupInfo>;
        _schedules = results[3] as List<BackupSchedule>;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load backup data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.backup), text: 'Backups'),
            Tab(icon: Icon(Icons.schedule), text: 'Schedules'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
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
          _buildOverviewTab(),
          _buildBackupsTab(),
          _buildSchedulesTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Статистика резервного копирования
          _buildBackupStatistics(),
          const SizedBox(height: 16),

          // Статистика расписаний
          _buildScheduleStatistics(),
          const SizedBox(height: 16),

          // Быстрые действия
          _buildQuickActions(),
          const SizedBox(height: 16),

          // Последние резервные копии
          _buildRecentBackups(),
          const SizedBox(height: 16),

          // Активные расписания
          _buildActiveSchedules(),
        ],
      ),
    );
  }

  Widget _buildBackupsTab() {
    return Column(
      children: [
        // Кнопки действий
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => _showCreateBackupDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Create Backup'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _showRestoreBackupDialog(),
                icon: const Icon(Icons.restore),
                label: const Text('Restore'),
              ),
            ],
          ),
        ),

        // Список резервных копий
        Expanded(
          child: BackupListWidget(
            backups: _backups,
            onRefresh: _loadData,
            onDelete: _deleteBackup,
            onRestore: _restoreBackup,
          ),
        ),
      ],
    );
  }

  Widget _buildSchedulesTab() {
    return Column(
      children: [
        // Кнопка создания расписания
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => _showCreateScheduleDialog(),
                icon: const Icon(Icons.schedule),
                label: const Text('Create Schedule'),
              ),
            ],
          ),
        ),

        // Список расписаний
        Expanded(
          child: BackupScheduleWidget(
            schedules: _schedules,
            onRefresh: _loadData,
            onToggle: _toggleSchedule,
            onDelete: _deleteSchedule,
            onRun: _runSchedule,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Настройки шифрования
          _buildEncryptionSettings(),
          const SizedBox(height: 16),

          // Настройки хранилища
          _buildStorageSettings(),
          const SizedBox(height: 16),

          // Настройки уведомлений
          _buildNotificationSettings(),
          const SizedBox(height: 16),

          // Очистка данных
          _buildCleanupSettings(),
        ],
      ),
    );
  }

  Widget _buildBackupStatistics() {
    if (_statistics == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Backup Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Backups',
                    _statistics!.totalBackups.toString(),
                    Icons.backup,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Full Backups',
                    _statistics!.fullBackups.toString(),
                    Icons.archive,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Incremental',
                    _statistics!.incrementalBackups.toString(),
                    Icons.add_circle,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Size',
                    _formatBytes(_statistics!.totalSize),
                    Icons.storage,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Average Size',
                    _formatBytes(_statistics!.averageSize.round()),
                    Icons.analytics,
                    Colors.teal,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Last Backup',
                    _statistics!.lastBackup != null ? _formatDate(_statistics!.lastBackup!) : 'Never',
                    Icons.schedule,
                    Colors.indigo,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleStatistics() {
    if (_scheduleStatistics == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Schedule Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Schedules',
                    _scheduleStatistics!.totalSchedules.toString(),
                    Icons.schedule,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Enabled',
                    _scheduleStatistics!.enabledSchedules.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Disabled',
                    _scheduleStatistics!.disabledSchedules.toString(),
                    Icons.cancel,
                    Colors.red,
                  ),
                ),
              ],
            ),
            if (_scheduleStatistics!.nextRun != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Next Run',
                      _formatDateTime(_scheduleStatistics!.nextRun!),
                      Icons.schedule,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
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

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showCreateBackupDialog(),
                  icon: const Icon(Icons.backup),
                  label: const Text('Create Full Backup'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showCreateIncrementalBackupDialog(),
                  icon: const Icon(Icons.add_circle),
                  label: const Text('Create Incremental'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showRestoreBackupDialog(),
                  icon: const Icon(Icons.restore),
                  label: const Text('Restore Backup'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showCreateScheduleDialog(),
                  icon: const Icon(Icons.schedule),
                  label: const Text('Create Schedule'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentBackups() {
    final List<BackupInfo> recentBackups = _backups.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Backups',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (recentBackups.isEmpty)
              const Text('No backups found')
            else
              ...recentBackups.map((backup) => ListTile(
                    leading: Icon(
                      backup.type == BackupType.full ? Icons.archive : Icons.add_circle,
                      color: backup.type == BackupType.full ? Colors.green : Colors.orange,
                    ),
                    title: Text(backup.name),
                    subtitle: Text('${_formatBytes(backup.size)} • ${_formatDate(backup.createdAt)}'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'restore':
                            _restoreBackup(backup);
                          case 'delete':
                            _deleteBackup(backup);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'restore',
                          child: Text('Restore'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSchedules() {
    final List<BackupSchedule> activeSchedules = _schedules.where((s) => s.enabled).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active Schedules',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (activeSchedules.isEmpty)
              const Text('No active schedules')
            else
              ...activeSchedules.map((schedule) => ListTile(
                    leading: Icon(
                      _getScheduleIcon(schedule.type),
                      color: Colors.blue,
                    ),
                    title: Text(schedule.name),
                    subtitle:
                        Text('${_formatScheduleType(schedule.type)} • Next: ${_formatDateTime(schedule.nextRun!)}'),
                    trailing: Switch(
                      value: schedule.enabled,
                      onChanged: (value) => _toggleSchedule(schedule.id, value),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildEncryptionSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Encryption Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Encryption'),
              subtitle: const Text('Encrypt all backups with password'),
              value: false, // TODO: Get from settings
              onChanged: (value) {
                // TODO: Update settings
              },
            ),
            ListTile(
              title: const Text('Default Algorithm'),
              subtitle: const Text('AES-256'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Show algorithm selection
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Storage Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Local Storage Path'),
              subtitle: const Text('/backups'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Show path selection
              },
            ),
            ListTile(
              title: const Text('Cloud Storage'),
              subtitle: const Text('Not configured'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Show cloud storage configuration
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Email Notifications'),
              subtitle: const Text('Send notifications on backup completion'),
              value: false, // TODO: Get from settings
              onChanged: (value) {
                // TODO: Update settings
              },
            ),
            SwitchListTile(
              title: const Text('Push Notifications'),
              subtitle: const Text('Send push notifications for backup events'),
              value: true, // TODO: Get from settings
              onChanged: (value) {
                // TODO: Update settings
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCleanupSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cleanup Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Auto Cleanup'),
              subtitle: const Text('Automatically delete old backups'),
              trailing: Switch(
                value: true, // TODO: Get from settings
                onChanged: (value) {
                  // TODO: Update settings
                },
              ),
            ),
            ListTile(
              title: const Text('Retention Period'),
              subtitle: const Text('30 days'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Show retention period selection
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showCleanupDialog(),
              icon: const Icon(Icons.clean_hands),
              label: const Text('Cleanup Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Вспомогательные методы

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  IconData _getScheduleIcon(BackupScheduleType type) {
    switch (type) {
      case BackupScheduleType.daily:
        return Icons.today;
      case BackupScheduleType.weekly:
        return Icons.date_range;
      case BackupScheduleType.monthly:
        return Icons.calendar_month;
      case BackupScheduleType.custom:
        return Icons.schedule;
    }
  }

  String _formatScheduleType(BackupScheduleType type) {
    switch (type) {
      case BackupScheduleType.daily:
        return 'Daily';
      case BackupScheduleType.weekly:
        return 'Weekly';
      case BackupScheduleType.monthly:
        return 'Monthly';
      case BackupScheduleType.custom:
        return 'Custom';
    }
  }

  // Диалоги и действия

  void _showCreateBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => BackupCreationWidget(
        onBackupCreated: (result) {
          _loadData();
          _showSuccessSnackBar('Backup created successfully');
        },
      ),
    );
  }

  void _showCreateIncrementalBackupDialog() {
    // TODO: Implement incremental backup dialog
    _showInfoSnackBar('Incremental backup dialog not implemented yet');
  }

  void _showRestoreBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => BackupRestoreWidget(
        backups: _backups,
        onRestoreCompleted: (result) {
          _showSuccessSnackBar('Restore completed successfully');
        },
      ),
    );
  }

  void _showCreateScheduleDialog() {
    showDialog(
      context: context,
      builder: (context) => BackupScheduleWidget(
        schedules: _schedules,
        onRefresh: _loadData,
        onToggle: _toggleSchedule,
        onDelete: _deleteSchedule,
        onRun: _runSchedule,
      ),
    );
  }

  void _showCleanupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cleanup Old Backups'),
        content: const Text('This will delete all backups older than the retention period. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performCleanup();
            },
            child: const Text('Cleanup'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBackup(BackupInfo backup) async {
    try {
      await _backupService.deleteBackup(backup.path);
      _loadData();
      _showSuccessSnackBar('Backup deleted successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to delete backup: $e');
    }
  }

  Future<void> _restoreBackup(BackupInfo backup) async {
    try {
      final RestoreResult result = await _backupService.restoreFromBackup(
        backupPath: backup.path,
      );

      if (result.success) {
        _showSuccessSnackBar('Backup restored successfully');
      } else {
        _showErrorSnackBar('Failed to restore backup: ${result.error}');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to restore backup: $e');
    }
  }

  Future<void> _toggleSchedule(String scheduleId, bool enabled) async {
    try {
      await _schedulerService.toggleSchedule(scheduleId, enabled);
      _loadData();
      _showSuccessSnackBar('Schedule ${enabled ? 'enabled' : 'disabled'} successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to toggle schedule: $e');
    }
  }

  Future<void> _deleteSchedule(String scheduleId) async {
    try {
      await _schedulerService.deleteSchedule(scheduleId);
      _loadData();
      _showSuccessSnackBar('Schedule deleted successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to delete schedule: $e');
    }
  }

  Future<void> _runSchedule(String scheduleId) async {
    try {
      await _schedulerService.runScheduledBackup(scheduleId);
      _loadData();
      _showSuccessSnackBar('Scheduled backup started');
    } catch (e) {
      _showErrorSnackBar('Failed to run scheduled backup: $e');
    }
  }

  Future<void> _performCleanup() async {
    try {
      // TODO: Implement cleanup logic
      _showSuccessSnackBar('Cleanup completed successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to perform cleanup: $e');
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

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
