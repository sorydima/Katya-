import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:katya/global/colors.dart';
import 'package:katya/store/index.dart';
import 'package:katya/store/security/events/model.dart';
import 'package:katya/store/security/notifications/actions.dart';
import 'package:katya/store/security/notifications/model.dart';
import 'package:katya/views/navigation.dart';

class SecurityNotificationBanner extends StatefulWidget {
  final SecurityEvent event;
  final VoidCallback? onDismissed;
  final bool dismissible;

  const SecurityNotificationBanner({
    super.key,
    required this.event,
    this.onDismissed,
    this.dismissible = true,
  });

  @override
  _SecurityNotificationBannerState createState() => _SecurityNotificationBannerState();
}

class _SecurityNotificationBannerState extends State<SecurityNotificationBanner> {
  bool _isDismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_isDismissed) return const SizedBox.shrink();

    return StoreConnector<AppState, SecurityNotificationBannerViewModel>(
      distinct: true,
      converter: (store) => SecurityNotificationBannerViewModel.fromStore(store),
      builder: (context, viewModel) {
        if (!viewModel.settings.shouldShowBanner(widget.event.type)) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: _getBackgroundColor(widget.event.type, context),
          child: Row(
            children: [
              _getIcon(widget.event.type),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTitle(widget.event.type, context),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: _getTextColor(widget.event.type, context),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (widget.event.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.event.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _getTextColor(widget.event.type, context)?.withOpacity(0.9),
                            ),
                      ),
                    ],
                    if (widget.event.metadata != null && widget.event.metadata!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      ..._buildMetadata(widget.event.metadata!, context),
                    ],
                  ],
                ),
              ),
              if (widget.dismissible) ...[
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 20,
                    color: _getTextColor(widget.event.type, context),
                  ),
                  onPressed: _dismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildMetadata(
    Map<String, dynamic> metadata,
    BuildContext context,
  ) {
    return metadata.entries.map((entry) {
      String value = entry.value.toString();

      // Format timestamps
      if (entry.key.toLowerCase().contains('time') || entry.key.toLowerCase().contains('date')) {
        try {
          final date = DateTime.parse(value);
          value = '${date.toLocal()} (${date.timeZoneName})';
        } catch (e) {
          // If parsing fails, use the original value
        }
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 2.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_formatKey(entry.key)}: ',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getTextColor(widget.event.type, context)?.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
            ),
            Expanded(
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getTextColor(widget.event.type, context)?.withOpacity(0.9),
                    ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _formatKey(String key) {
    // Convert camelCase to Title Case
    final words = key
        .replaceAllMapped(
          RegExp('([A-Z])'),
          (match) => ' ${match.group(1)}',
        )
        .toLowerCase()
        .trim()
        .split(' ');

    return words.map((word) {
      if (word.isEmpty) return '';
      return '${word[0].toUpperCase()}${word.substring(1)}';
    }).join(' ');
  }

  void _dismiss() {
    setState(() {
      _isDismissed = true;
    });
    widget.onDismissed?.call();
  }

  Color _getBackgroundColor(SecurityEventType type, BuildContext context) {
    switch (type) {
      case SecurityEventType.failedLogin:
      case SecurityEventType.accountLocked:
      case SecurityEventType.suspiciousActivity:
      case SecurityEventType.unusualLocation:
      case SecurityEventType.unusualTime:
        return Theme.of(context).colorScheme.errorContainer;
      case SecurityEventType.newDeviceLogin:
      case SecurityEventType.deviceVerified:
        return Theme.of(context).colorScheme.tertiaryContainer;
      case SecurityEventType.passwordChanged:
      case SecurityEventType.passwordResetRequested:
      case SecurityEventType.twoFactorEnabled:
      case SecurityEventType.twoFactorDisabled:
      default:
        return Theme.of(context).colorScheme.surfaceContainerHighest;
    }
  }

  Color? _getTextColor(SecurityEventType type, BuildContext context) {
    switch (type) {
      case SecurityEventType.failedLogin:
      case SecurityEventType.accountLocked:
      case SecurityEventType.suspiciousActivity:
      case SecurityEventType.unusualLocation:
      case SecurityEventType.unusualTime:
        return Theme.of(context).colorScheme.onErrorContainer;
      case SecurityEventType.newDeviceLogin:
      case SecurityEventType.deviceVerified:
        return Theme.of(context).colorScheme.onTertiaryContainer;
      case SecurityEventType.passwordChanged:
      case SecurityEventType.passwordResetRequested:
      case SecurityEventType.twoFactorEnabled:
      case SecurityEventType.twoFactorDisabled:
      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  Widget _getIcon(SecurityEventType type) {
    IconData icon;
    switch (type) {
      case SecurityEventType.failedLogin:
      case SecurityEventType.accountLocked:
        icon = Icons.warning_amber_rounded;
      case SecurityEventType.suspiciousActivity:
      case SecurityEventType.unusualLocation:
      case SecurityEventType.unusualTime:
        icon = Icons.security_rounded;
      case SecurityEventType.newDeviceLogin:
      case SecurityEventType.deviceVerified:
        icon = Icons.devices_other_rounded;
      case SecurityEventType.passwordChanged:
      case SecurityEventType.passwordResetRequested:
        icon = Icons.lock_reset_rounded;
      case SecurityEventType.twoFactorEnabled:
      case SecurityEventType.twoFactorDisabled:
        icon = Icons.two_wheeler_rounded;
      default:
        icon = Icons.notifications_rounded;
    }

    return Icon(
      icon,
      color: _getTextColor(type, context),
      size: 24,
    );
  }

  String _getTitle(SecurityEventType type, BuildContext context) {
    switch (type) {
      case SecurityEventType.failedLogin:
        return 'Failed Login Attempt';
      case SecurityEventType.accountLocked:
        return 'Account Locked';
      case SecurityEventType.newDeviceLogin:
        return 'New Device Login';
      case SecurityEventType.deviceVerified:
        return 'Device Verified';
      case SecurityEventType.passwordChanged:
        return 'Password Changed';
      case SecurityEventType.passwordResetRequested:
        return 'Password Reset Requested';
      case SecurityEventType.twoFactorEnabled:
        return 'Two-Factor Enabled';
      case SecurityEventType.twoFactorDisabled:
        return 'Two-Factor Disabled';
      case SecurityEventType.suspiciousActivity:
        return 'Suspicious Activity Detected';
      case SecurityEventType.unusualLocation:
        return 'Login from New Location';
      case SecurityEventType.unusualTime:
        return 'Unusual Login Time';
      default:
        return 'Security Alert';
    }
  }
}

class SecurityNotificationBannerViewModel {
  final SecurityNotificationSettings settings;
  final Function() onViewSecurityLogs;
  final Function() onDismissAll;

  SecurityNotificationBannerViewModel({
    required this.settings,
    required this.onViewSecurityLogs,
    required this.onDismissAll,
  });

  static SecurityNotificationBannerViewModel fromStore(Store<AppState> store) {
    return SecurityNotificationBannerViewModel(
      settings: store.state.securityNotificationSettings,
      onViewSecurityLogs: () {
        store.dispatch(NavigateAction(payload: Routes.settingsSecurityLogs));
      },
      onDismissAll: () {
        store.dispatch(MarkNotificationsAsRead(timestamp: DateTime.now()));
      },
    );
  }
}
