import 'package:flutter/material.dart';

class BackupStatusCard extends StatelessWidget {
  final bool hasBackup;
  final bool isTrusted;
  final String? version;
  final VoidCallback? onBackupNow;
  final VoidCallback? onRestore;

  const BackupStatusCard({
    super.key,
    required this.hasBackup,
    required this.isTrusted,
    this.version,
    this.onBackupNow,
    this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatusIcon(theme),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStatusTitle(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: _getStatusColor(theme),
                        ),
                      ),
                      if (version != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Version: $version',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (hasBackup) ...[
              const SizedBox(height: 16),
              Text(
                _getStatusDescription(),
                style: theme.textTheme.bodyMedium,
              ),
            ],
            if (onBackupNow != null || onRestore != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (onBackupNow != null) ...[
                    ElevatedButton(
                      onPressed: onBackupNow,
                      child: const Text('Backup Now'),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (onRestore != null)
                    OutlinedButton(
                      onPressed: onRestore,
                      child: const Text('Restore'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(ThemeData theme) {
    if (!hasBackup) {
      return Icon(
        Icons.warning_amber_rounded,
        color: theme.colorScheme.warning,
        size: 40,
      );
    }

    if (!isTrusted) {
      return Icon(
        Icons.warning_amber_rounded,
        color: theme.colorScheme.error,
        size: 40,
      );
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check_circle_outline,
        color: theme.colorScheme.primary,
        size: 40,
      ),
    );
  }

  String _getStatusTitle() {
    if (!hasBackup) return 'Backup not set up';
    if (!isTrusted) return 'Backup not trusted';
    return 'Backup active';
  }

  String _getStatusDescription() {
    if (!hasBackup) {
      return 'Your encryption keys are not backed up. Set up secure backup to avoid losing access to your messages.';
    }

    if (!isTrusted) {
      return 'Your backup is not trusted. Verify your backup to ensure you can recover your messages.';
    }

    return 'Your encryption keys are securely backed up. You can restore your messages on a new device.';
  }

  Color _getStatusColor(ThemeData theme) {
    if (!hasBackup) return theme.colorScheme.warning;
    if (!isTrusted) return theme.colorScheme.error;
    return theme.colorScheme.primary;
  }
}

extension on ThemeData {
  Color get warning => const Color(0xFFFFA000); // Amber 700
}
