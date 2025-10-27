import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:katya/l10n/l10n.dart';
import 'package:katya/store/index.dart';
import 'package:katya/views/widgets/dialogs/dialog-confirm.dart';
import 'package:katya/views/widgets/loader/loader-spinning-wheel.dart';
import 'package:redux/redux.dart';

class KeyBackupScreen extends StatelessWidget {
  const KeyBackupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _Props>(
      distinct: true,
      converter: (Store<AppState> store) => _Props.mapStateToProps(store),
      builder: (context, props) => _View(props: props),
    );
  }
}

class _View extends StatefulWidget {
  final _Props props;

  const _View({required this.props});

  @override
  _ViewState createState() => _ViewState();
}

class _ViewState extends State<_View> {
  bool _isCreatingBackup = false;
  bool _isRestoringBackup = false;

  @override
  void initState() {
    super.initState();
    _loadBackupStatus();
  }

  Future<void> _loadBackupStatus() async {
    await widget.props.onLoadBackupStatus();
  }

  Future<void> _createBackup() async {
    setState(() => _isCreatingBackup = true);
    try {
      final success = await widget.props.onCreateBackup();
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create backup: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreatingBackup = false);
      }
    }
  }

  Future<void> _restoreBackup() async {
    setState(() => _isRestoringBackup = true);
    try {
      final success = await widget.props.onRestoreBackup();
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup restored successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to restore backup: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRestoringBackup = false);
      }
    }
  }

  Future<void> _showDeleteBackupDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const DialogConfirm(
        title: 'Delete Backup',
        content: 'Are you sure you want to delete your encryption key backup?',
        confirmText: 'DELETE',
        confirmStyle: TextStyle(color: Colors.red),
      ),
    );

    if (confirmed == true) {
      try {
        await widget.props.onDeleteBackup();
        if (mounted) {
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

  Widget _buildBackupStatus() {
    final l10n = l10nOf(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.security, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Encryption Key Backup',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.props.isBackupEnabled) ...[
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Backup is enabled',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Last backup: ${widget.props.lastBackupTime ?? 'Never'}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  FilledButton.tonal(
                    onPressed: _isRestoringBackup ? null : _restoreBackup,
                    child: _isRestoringBackup
                        ? const LoaderSpinningWheel(size: 16, strokeWidth: 2)
                        : const Text('RESTORE FROM BACKUP'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonal(
                    onPressed: _isCreatingBackup ? null : _createBackup,
                    child: _isCreatingBackup
                        ? const LoaderSpinningWheel(size: 16, strokeWidth: 2)
                        : const Text('CREATE NEW BACKUP'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _showDeleteBackupDialog,
                child: Text(
                  'DELETE BACKUP',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ] else ...[
              Text(
                'Backup is not set up. Create a backup to secure your encryption keys.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _isCreatingBackup ? null : _createBackup,
                child: _isCreatingBackup
                    ? const LoaderSpinningWheel(size: 16, strokeWidth: 2)
                    : const Text('SET UP BACKUP'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecoveryKey() {
    final l10n = l10nOf(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recovery Key',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Your recovery key is used to restore your encrypted messages if you lose access to your devices.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (widget.props.recoveryKey != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  widget.props.recoveryKey!,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 16,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  FilledButton.tonal(
                    onPressed: () {
                      // TODO: Implement copy to clipboard
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Recovery key copied to clipboard')),
                      );
                    },
                    child: const Text('COPY KEY'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonal(
                    onPressed: () {
                      // TODO: Implement generate new key
                      showDialog(
                        context: context,
                        builder: (context) => DialogConfirm(
                          title: 'Generate New Recovery Key',
                          content: 'Generating a new recovery key will invalidate your current key. '
                              'Make sure to save the new key in a secure location.',
                          onConfirm: () {
                            // TODO: Implement generate new key logic
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('New recovery key generated')),
                            );
                          },
                        ),
                      );
                    },
                    child: const Text('GENERATE NEW KEY'),
                  ),
                ],
              ),
            ] else ...[
              FilledButton(
                onPressed: () {
                  // TODO: Implement generate recovery key
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Generating recovery key...')),
                  );
                },
                child: const Text('GENERATE RECOVERY KEY'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Encryption Keys'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBackupStatus(),
            const SizedBox(height: 16),
            _buildRecoveryKey(),
            const SizedBox(height: 24),
            Text(
              'Security Tips',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildSecurityTip(
              icon: Icons.security,
              title: 'Keep your recovery key safe',
              description:
                  'Store your recovery key in a secure location. If you lose it, you may lose access to your encrypted messages.',
            ),
            _buildSecurityTip(
              icon: Icons.update,
              title: 'Update your backup regularly',
              description: 'Create new backups when you add new devices or change your encryption settings.',
            ),
            _buildSecurityTip(
              icon: Icons.shield,
              title: 'Use a strong password',
              description: 'Protect your backup with a strong, unique password that you don\'t use anywhere else.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityTip({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Props {
  final bool isLoading;
  final bool isBackupEnabled;
  final String? lastBackupTime;
  final String? recoveryKey;
  final Future<void> Function() onLoadBackupStatus;
  final Future<bool> Function() onCreateBackup;
  final Future<bool> Function() onRestoreBackup;
  final Future<void> Function() onDeleteBackup;

  const _Props({
    required this.isLoading,
    required this.isBackupEnabled,
    required this.lastBackupTime,
    required this.recoveryKey,
    required this.onLoadBackupStatus,
    required this.onCreateBackup,
    required this.onRestoreBackup,
    required this.onDeleteBackup,
  });

  static _Props mapStateToProps(Store<AppState> store) {
    return _Props(
      isLoading: store.state.encryptionState.isLoading,
      isBackupEnabled: store.state.encryptionState.isKeyBackupEnabled,
      lastBackupTime: null, // TODO: Add lastBackupTime to EncryptionState
      recoveryKey: null, // TODO: Add recoveryKey to EncryptionState
      onLoadBackupStatus: () async {}, // TODO: Implement LoadBackupStatus action
      onCreateBackup: () async => false, // TODO: Implement CreateBackup action
      onRestoreBackup: () async => false, // TODO: Implement RestoreBackup action
      onDeleteBackup: () async {}, // TODO: Implement DeleteBackup action
    );
  }
}
