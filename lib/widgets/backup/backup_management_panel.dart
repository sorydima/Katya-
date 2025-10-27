import 'package:flutter/material.dart';

import '../../services/backup/backup_compression_service.dart';
import '../../services/backup/backup_encryption_service.dart';
import '../../services/backup/backup_scheduler_service.dart';
import '../../services/backup/backup_service.dart';
import '../../services/backup/backup_storage_service.dart';

/// Панель управления резервными копиями
class BackupManagementPanel extends StatefulWidget {
  const BackupManagementPanel({super.key});

  @override
  State<BackupManagementPanel> createState() => _BackupManagementPanelState();
}

class _BackupManagementPanelState extends State<BackupManagementPanel> with TickerProviderStateMixin {
  final BackupService _backupService = BackupService();
  final BackupSchedulerService _schedulerService = BackupSchedulerService();
  final BackupEncryptionService _encryptionService = BackupEncryptionService();
  final BackupCompressionService _compressionService = BackupCompressionService();
  final BackupStorageService _storageService = BackupStorageService();

  late TabController _tabController;
  List<BackupInfo> _backups = [];
  List<BackupSchedule> _schedules = [];
  bool _isLoading = false;

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
    setState(() {
      _isLoading = true;
    });

    try {
      final List<BackupInfo> backups = await _backupService.listBackups();
      final List<BackupSchedule> schedules = _schedulerService.getSchedules();

      setState(() {
        _backups = backups;
        _schedules = schedules;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
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
            Tab(icon: Icon(Icons.backup), text: 'Backups'),
            Tab(icon: Icon(Icons.schedule), text: 'Schedules'),
            Tab(icon: Icon(Icons.security), text: 'Encryption'),
            Tab(icon: Icon(Icons.storage), text: 'Storage'),
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
          _buildBackupsTab(),
          _buildSchedulesTab(),
          _buildEncryptionTab(),
          _buildStorageTab(),
        ],
      ),
    );
  }

  Widget _buildBackupsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: _createFullBackup,
                icon: const Icon(Icons.backup),
                label: const Text('Create Full Backup'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _createIncrementalBackup,
                icon: const Icon(Icons.add_circle),
                label: const Text('Create Incremental'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _backups.isEmpty
              ? const Center(child: Text('No backups available'))
              : ListView.builder(
                  itemCount: _backups.length,
                  itemBuilder: (context, index) {
                    final BackupInfo backup = _backups[index];
                    return _buildBackupCard(backup);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildBackupCard(BackupInfo backup) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(
          backup.type == BackupType.full ? Icons.backup : Icons.add_circle,
          color: backup.type == BackupType.full ? Colors.blue : Colors.green,
        ),
        title: Text(backup.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${backup.type.name}'),
            Text('Size: ${_formatFileSize(backup.size)}'),
            Text('Created: ${_formatDateTime(backup.createdAt)}'),
            if (backup.description != null) Text('Description: ${backup.description}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleBackupAction(value, backup),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'restore',
              child: ListTile(
                leading: Icon(Icons.restore),
                title: Text('Restore'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'info',
              child: ListTile(
                leading: Icon(Icons.info),
                title: Text('Info'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchedulesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _createSchedule,
            icon: const Icon(Icons.add),
            label: const Text('Create Schedule'),
          ),
        ),
        Expanded(
          child: _schedules.isEmpty
              ? const Center(child: Text('No schedules configured'))
              : ListView.builder(
                  itemCount: _schedules.length,
                  itemBuilder: (context, index) {
                    final BackupSchedule schedule = _schedules[index];
                    return _buildScheduleCard(schedule);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildScheduleCard(BackupSchedule schedule) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(
          schedule.enabled ? Icons.schedule : Icons.schedule_outlined,
          color: schedule.enabled ? Colors.green : Colors.grey,
        ),
        title: Text(schedule.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${schedule.type.name}'),
            Text('Enabled: ${schedule.enabled}'),
            if (schedule.nextRun != null) Text('Next Run: ${_formatDateTime(schedule.nextRun!)}'),
            if (schedule.lastRun != null) Text('Last Run: ${_formatDateTime(schedule.lastRun!)}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: schedule.enabled,
              onChanged: (value) => _toggleSchedule(schedule.id, value),
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleScheduleAction(value, schedule),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'run',
                  child: ListTile(
                    leading: Icon(Icons.play_arrow),
                    title: Text('Run Now'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Delete'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEncryptionTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Encryption Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Encrypt Backup Files'),
                  const SizedBox(height: 8),
                  const Text(
                    'Enable encryption to protect your backup files with a password.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _encryptBackup,
                    icon: const Icon(Icons.lock),
                    label: const Text('Encrypt Backup'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Decrypt Backup Files'),
                  const SizedBox(height: 8),
                  const Text(
                    'Decrypt encrypted backup files to restore data.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _decryptBackup,
                    icon: const Icon(Icons.lock_open),
                    label: const Text('Decrypt Backup'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Storage Management',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Storage Health'),
                  const SizedBox(height: 8),
                  const Text(
                    'Check the health and availability of your storage locations.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _checkStorageHealth,
                    icon: const Icon(Icons.health_and_safety),
                    label: const Text('Check Health'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Storage Statistics'),
                  const SizedBox(height: 8),
                  const Text(
                    'View storage usage and backup statistics.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _viewStorageStats,
                    icon: const Icon(Icons.analytics),
                    label: const Text('View Statistics'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Event handlers

  Future<void> _createFullBackup() async {
    try {
      final BackupResult result = await _backupService.createFullBackup(
        backupName: 'Full Backup ${DateTime.now().millisecondsSinceEpoch}',
        description: 'Manual full backup',
      );

      if (result.success) {
        _showSuccessSnackBar('Full backup created successfully');
        _loadData();
      } else {
        _showErrorSnackBar('Failed to create full backup: ${result.error}');
      }
    } catch (e) {
      _showErrorSnackBar('Error creating full backup: $e');
    }
  }

  Future<void> _createIncrementalBackup() async {
    try {
      // Find the last full backup
      final List<BackupInfo> backups = await _backupService.listBackups();
      final BackupInfo? lastFullBackup = backups.where((b) => b.type == BackupType.full).isNotEmpty
          ? backups.where((b) => b.type == BackupType.full).first
          : null;

      if (lastFullBackup == null) {
        _showErrorSnackBar('No full backup found. Create a full backup first.');
        return;
      }

      final BackupResult result = await _backupService.createIncrementalBackup(
        backupName: 'Incremental Backup ${DateTime.now().millisecondsSinceEpoch}',
        baseBackupId: lastFullBackup.id,
        description: 'Manual incremental backup',
      );

      if (result.success) {
        _showSuccessSnackBar('Incremental backup created successfully');
        _loadData();
      } else {
        _showErrorSnackBar('Failed to create incremental backup: ${result.error}');
      }
    } catch (e) {
      _showErrorSnackBar('Error creating incremental backup: $e');
    }
  }

  Future<void> _createSchedule() async {
    // TODO: Implement schedule creation dialog
    _showInfoSnackBar('Schedule creation dialog not implemented yet');
  }

  Future<void> _toggleSchedule(String scheduleId, bool enabled) async {
    try {
      await _schedulerService.toggleSchedule(scheduleId, enabled);
      _showSuccessSnackBar('Schedule ${enabled ? 'enabled' : 'disabled'} successfully');
      _loadData();
    } catch (e) {
      _showErrorSnackBar('Failed to toggle schedule: $e');
    }
  }

  Future<void> _handleBackupAction(String action, BackupInfo backup) async {
    switch (action) {
      case 'restore':
        await _restoreBackup(backup);
      case 'delete':
        await _deleteBackup(backup);
      case 'info':
        await _showBackupInfo(backup);
    }
  }

  Future<void> _handleScheduleAction(String action, BackupSchedule schedule) async {
    switch (action) {
      case 'edit':
        // TODO: Implement schedule editing
        _showInfoSnackBar('Schedule editing not implemented yet');
      case 'run':
        await _runSchedule(schedule);
      case 'delete':
        await _deleteSchedule(schedule);
    }
  }

  Future<void> _restoreBackup(BackupInfo backup) async {
    // TODO: Implement backup restoration
    _showInfoSnackBar('Backup restoration not implemented yet');
  }

  Future<void> _deleteBackup(BackupInfo backup) async {
    final bool? confirmed = await _showConfirmDialog(
      'Delete Backup',
      'Are you sure you want to delete this backup? This action cannot be undone.',
    );

    if (confirmed == true) {
      try {
        final bool success = await _backupService.deleteBackup(backup.path);
        if (success) {
          _showSuccessSnackBar('Backup deleted successfully');
          _loadData();
        } else {
          _showErrorSnackBar('Failed to delete backup');
        }
      } catch (e) {
        _showErrorSnackBar('Error deleting backup: $e');
      }
    }
  }

  Future<void> _showBackupInfo(BackupInfo backup) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Backup Info: ${backup.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${backup.id}'),
            Text('Type: ${backup.type.name}'),
            Text('Size: ${_formatFileSize(backup.size)}'),
            Text('Created: ${_formatDateTime(backup.createdAt)}'),
            if (backup.description != null) Text('Description: ${backup.description}'),
            Text('Path: ${backup.path}'),
          ],
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

  Future<void> _runSchedule(BackupSchedule schedule) async {
    try {
      await _schedulerService.runScheduledBackup(schedule.id);
      _showSuccessSnackBar('Schedule executed successfully');
      _loadData();
    } catch (e) {
      _showErrorSnackBar('Failed to run schedule: $e');
    }
  }

  Future<void> _deleteSchedule(BackupSchedule schedule) async {
    final bool? confirmed = await _showConfirmDialog(
      'Delete Schedule',
      'Are you sure you want to delete this schedule?',
    );

    if (confirmed == true) {
      try {
        final bool success = await _schedulerService.deleteSchedule(schedule.id);
        if (success) {
          _showSuccessSnackBar('Schedule deleted successfully');
          _loadData();
        } else {
          _showErrorSnackBar('Failed to delete schedule');
        }
      } catch (e) {
        _showErrorSnackBar('Error deleting schedule: $e');
      }
    }
  }

  Future<void> _encryptBackup() async {
    // TODO: Implement backup encryption
    _showInfoSnackBar('Backup encryption not implemented yet');
  }

  Future<void> _decryptBackup() async {
    // TODO: Implement backup decryption
    _showInfoSnackBar('Backup decryption not implemented yet');
  }

  Future<void> _checkStorageHealth() async {
    // TODO: Implement storage health check
    _showInfoSnackBar('Storage health check not implemented yet');
  }

  Future<void> _viewStorageStats() async {
    // TODO: Implement storage statistics
    _showInfoSnackBar('Storage statistics not implemented yet');
  }

  // Helper methods

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<bool?> _showConfirmDialog(String title, String content) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
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
