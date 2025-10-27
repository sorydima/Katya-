import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:matrix/matrix.dart' as matrix;

class DeviceTile extends StatelessWidget {
  final matrix.Device device;
  final bool isVerifying;
  final VoidCallback? onVerify;

  const DeviceTile({
    super.key,
    required this.device,
    this.isVerifying = false,
    this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lastSeen = device.lastSeenIp != null
        ? 'Last seen: ${_formatDate(device.lastSeenTs)} from ${device.lastSeenIp}'
        : 'Last seen: Unknown';

    return ListTile(
      leading: _buildDeviceIcon(device),
      title: Text(
        device.displayName ?? 'Unknown Device',
        style: theme.textTheme.titleMedium,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ID: ${device.deviceId}'),
          Text(lastSeen),
          if (device.isVerified) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.verified,
                  color: theme.colorScheme.primary,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Verified',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      trailing: _buildTrailing(context),
      onTap: onVerify,
    );
  }

  Widget _buildDeviceIcon(matrix.Device device) {
    IconData icon;

    if (device.isVerified) {
      icon = Icons.phone_android;
    } else {
      icon = Icons.phone_android_outlined;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(device.context).colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 28),
    );
  }

  Widget? _buildTrailing(BuildContext context) {
    if (isVerifying) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (device.isVerified) {
      return Icon(
        Icons.check_circle,
        color: Theme.of(context).colorScheme.primary,
      );
    }

    return OutlinedButton(
      onPressed: onVerify,
      child: const Text('Verify'),
    );
  }

  String _formatDate(int? timestamp) {
    if (timestamp == null) return 'Unknown';

    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat.yMMMd().add_jm().format(date);
  }
}

extension DeviceExtension on matrix.Device {
  bool get isVerified => this.verified == matrix.DeviceVerified.verified;

  String get lastSeenIp => this.lastSeenIp ?? 'Unknown';

  int? get lastSeenTs => this.lastSeenTs;
}
