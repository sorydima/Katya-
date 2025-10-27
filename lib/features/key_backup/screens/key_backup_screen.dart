import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../matrix/matrix_client.dart';
import '../widgets/backup_status_card.dart';
import 'create_backup_screen.dart';
import 'restore_backup_screen.dart';

class KeyBackupScreen extends StatefulWidget {
  const KeyBackupScreen({super.key});

  @override
  _KeyBackupScreenState createState() => _KeyBackupScreenState();
}

class _KeyBackupScreenState extends State<KeyBackupScreen> {
  bool _isLoading = true;
  bool _hasBackup = false;
  bool _isBackupTrusted = false;
  String? _backupVersion;

  @override
  void initState() {
    super.initState();
    _loadBackupStatus();
  }

  Future<void> _loadBackupStatus() async {
    setState(() => _isLoading = true);

    try {
      final client = context.read<MatrixClient>();
      final version = await client.getBackupVersion();

      if (mounted) {
        setState(() {
          _hasBackup = version != null;
          _isBackupTrusted = version?.isTrusted ?? false;
          _backupVersion = version?.version;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load backup status: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Backup'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadBackupStatus,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BackupStatusCard(
                    hasBackup: _hasBackup,
                    isTrusted: _isBackupTrusted,
                    version: _backupVersion,
                    onBackupNow: _hasBackup ? _backupNow : null,
                    onRestore: _hasBackup ? _restoreBackup : null,
                  ),
                  const SizedBox(height: 24),
                  if (!_hasBackup) ..._buildNoBackupActions(),
                  if (_hasBackup && _isBackupTrusted) ..._buildBackupActions(),
                ],
              ),
            ),
    );
  }

  List<Widget> _buildNoBackupActions() {
    return [
      const Text(
        'Secure Backup is not set up',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 16),
      const Text(
        'Back up your encryption keys to avoid losing access to your messages if you lose your device.',
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 32),
      ElevatedButton(
        onPressed: _createBackup,
        child: const Text('Set up Secure Backup'),
      ),
    ];
  }

  List<Widget> _buildBackupActions() {
    return [
      ListTile(
        leading: const Icon(Icons.backup),
        title: const Text('Backup Now'),
        subtitle: const Text('Manually back up your encryption keys'),
        onTap: _backupNow,
      ),
      const Divider(),
      ListTile(
        leading: const Icon(Icons.restore),
        title: const Text('Restore from Backup'),
        subtitle: const Text('Restore your encryption keys from a backup'),
        onTap: _restoreBackup,
      ),
      const Divider(),
      ListTile(
        leading: const Icon(Icons.delete_forever, color: Colors.red),
        title: const Text('Delete Backup', style: TextStyle(color: Colors.red)),
        subtitle: const Text('Permanently delete your backup from the server'),
        onTap: _deleteBackup,
      ),
    ];
  }

  Future<void> _createBackup() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const CreateBackupScreen(),
      ),
    );

    if (result == true && mounted) {
      await _loadBackupStatus();
    }
  }

  Future<void> _backupNow() async {
    try {
      final client = context.read<MatrixClient>();
      await client.backupRoomKeys();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup completed successfully')),
        );
        await _loadBackupStatus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: $e')),
        );
      }
    }
  }

  Future<void> _restoreBackup() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const RestoreBackupScreen(),
      ),
    );

    if (result == true && mounted) {
      await _loadBackupStatus();
    }
  }

  Future<void> _deleteBackup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Backup?'),
        content: const Text(
          'Are you sure you want to delete your backup? '
          'This will permanently remove all backed up encryption keys from the server.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final client = context.read<MatrixClient>();
        await client.deleteBackup();

        if (mounted) {
          await _loadBackupStatus();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Backup deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete backup: $e')),
          );
        }
      }
    }
  }
}
