import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:katya/store/index.dart';
import 'package:katya/views/navigation.dart';
import 'package:katya/views/widgets/dialogs/dialog-confirm.dart';
import 'package:katya/views/widgets/layouts/modal-scaffold.dart';
import 'package:katya/views/widgets/lifecycle.dart';
import 'package:katya/views/widgets/loader/loader-spinning-wheel.dart';
import 'package:redux/redux.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => StoreConnector<AppState, _Props>(
        distinct: true,
        converter: (Store<AppState> store) => _Props.mapStateToProps(store),
        builder: (context, props) => _View(props: props),
      );
}

class _View extends StatefulWidget {
  final _Props props;

  const _View({required this.props});

  @override
  _ViewState createState() => _ViewState();
}

class _ViewState extends State<_View> with Lifecycle<_View> {
  bool isChangingPassword = false;
  bool isLoggingOutAllDevices = false;

  @override
  void onMounted() {
    // Load security-related data when the screen is mounted
    widget.props.onLoadSecurityData();
  }

  Future<void> _showChangePasswordDialog() async {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match')),
                );
                return;
              }

              setState(() => isChangingPassword = true);

              try {
                await widget.props.onChangePassword(
                  oldPassword: oldPasswordController.text,
                  newPassword: newPasswordController.text,
                );
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password changed successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to change password: $e')),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() => isChangingPassword = false);
                }
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutAllDevicesDialog() async {
    return showDialog(
      context: context,
      builder: (context) => DialogConfirm(
        title: 'Logout All Devices',
        content:
            'This will sign you out of all devices except this one. You will need to sign in again on those devices.',
        confirmText: 'Logout All',
        confirmStyle: const TextStyle(color: Colors.red),
        onConfirm: () async {
          setState(() => isLoggingOutAllDevices = true);
          try {
            await widget.props.onLogoutAllDevices();
            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out all other devices')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to log out devices: $e')),
              );
            }
          } finally {
            if (mounted) {
              setState(() => isLoggingOutAllDevices = false);
            }
          }
        },
      ),
    );
  }

  Widget _buildSecurityItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: subtitle != null ? Text(subtitle) : null,
          trailing: trailing,
          onTap: onTap,
        ),
        if (showDivider) const Divider(height: 1, indent: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModalScaffold(
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _buildSecurityItem(
            icon: Icons.security,
            title: 'Two-Factor Authentication',
            subtitle: 'Add an extra layer of security',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, Routes.settingsTwoFactorAuth);
            },
          ),
          _buildSecurityItem(
            icon: Icons.enhanced_encryption,
            title: 'Encryption Keys',
            subtitle: 'Backup and restore your encryption keys',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, Routes.settingsKeyBackup);
            },
          ),
          _buildSecurityItem(
            icon: Icons.security_update_warning,
            title: 'Security Logs',
            subtitle: 'View recent security events and activities',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, Routes.settingsSecurityLogs);
            },
          ),
          _buildSecurityItem(
            icon: Icons.verified_user,
            title: 'IP Whitelist',
            subtitle: 'Restrict account access to specific IP addresses',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, Routes.settingsIPWhitelist);
            },
          ),
          _buildSecurityItem(
            icon: Icons.lock_clock,
            title: 'Rate Limiting',
            subtitle: 'Prevent brute force attacks with login attempt limits',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, Routes.settingsRateLimit);
            },
          ),
          _buildSecurityItem(
            icon: Icons.phone_android,
            title: 'Device Management',
            subtitle: 'Manage your active sessions and devices',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, Routes.settingsDeviceManagement);
            },
          ),
          _buildSecurityItem(
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Update your account password',
            trailing: isChangingPassword
                ? const LoaderSpinningWheel(
                    size: 20,
                    strokeWidth: 2,
                  )
                : const Icon(Icons.chevron_right),
            onTap: _showChangePasswordDialog,
          ),
          _buildSecurityItem(
            icon: Icons.security,
            title: 'Two-Factor Authentication',
            subtitle: 'Add an extra layer of security',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement 2FA setup
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('2FA setup coming soon')),
              );
            },
          ),
          _buildSecurityItem(
            icon: Icons.devices_other,
            title: 'Active Sessions',
            subtitle: 'Manage your logged-in devices',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to active sessions screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Active sessions coming soon')),
              );
            },
          ),
          _buildSecurityItem(
            icon: Icons.logout,
            title: 'Logout All Devices',
            subtitle: 'Sign out all other logged-in devices',
            trailing: isLoggingOutAllDevices
                ? const LoaderSpinningWheel(
                    size: 20,
                    strokeWidth: 2,
                  )
                : const Icon(Icons.chevron_right),
            onTap: _showLogoutAllDevicesDialog,
          ),
          const SizedBox(height: 16),
          _buildSecurityItem(
            icon: Icons.lock,
            title: 'Encryption',
            subtitle: 'Manage end-to-end encryption settings',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to encryption settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Encryption settings coming soon')),
              );
            },
          ),
          _buildSecurityItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy',
            subtitle: 'Control your privacy settings',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to privacy settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy settings coming soon')),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Props {
  final bool isLoading;
  final Function() onLoadSecurityData;
  final Future<void> Function({required String oldPassword, required String newPassword}) onChangePassword;
  final Future<void> Function() onLogoutAllDevices;

  _Props({
    required this.isLoading,
    required this.onLoadSecurityData,
    required this.onChangePassword,
    required this.onLogoutAllDevices,
  });

  static _Props mapStateToProps(Store<AppState> store) => _Props(
        isLoading: false, // TODO: Add isLoading to AuthStore
        onLoadSecurityData: () {
          // TODO: Implement LoadActiveSessions and Load2FAStatus actions
          // store.dispatch(LoadActiveSessions());
          // store.dispatch(Load2FAStatus());
        },
        onChangePassword: ({required String oldPassword, required String newPassword}) async {
          try {
            // Call the API to change password
            print('Changing password from $oldPassword to $newPassword');

            // Show success message
            print('Password changed successfully');
          } catch (e) {
            // Handle error
            print('Failed to change password: $e');
            rethrow;
          }
        },
        onLogoutAllDevices: () async {
          try {
            // Call the API to log out all other devices
            print('Logging out all other devices');

            // Show success message
            print('Logged out all other devices');
          } catch (e) {
            // Handle error
            print('Failed to log out devices: $e');
            rethrow;
          }
        },
      );
}
