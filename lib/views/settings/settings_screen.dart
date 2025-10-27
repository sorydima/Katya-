import 'package:flutter/material.dart';
import 'package:katya/providers/matrix_provider.dart';
import 'package:katya/widgets/admin/admin_dashboard.dart';
import 'package:katya/widgets/backup/backup_dashboard.dart';
import 'package:katya/widgets/data_export_import/data_management_dashboard.dart';
import 'package:katya/widgets/i18n/regional_settings_widget.dart';
import 'package:katya/widgets/performance/performance_analytics_dashboard.dart';
import 'package:katya/widgets/performance_analytics/performance_analytics_main_dashboard.dart';
import 'package:katya/widgets/system_status/system_health_dashboard.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // User profile section
          _buildUserProfileSection(context),

          // Account settings
          _buildSectionHeader('Account'),
          _buildListTile(
            context,
            icon: Icons.person_outline,
            title: 'Profile',
            onTap: () {
              // TODO: Navigate to profile screen
            },
          ),
          _buildListTile(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {
              // TODO: Navigate to notifications settings
            },
          ),
          _buildListTile(
            context,
            icon: Icons.lock_outline,
            title: 'Privacy & Security',
            onTap: () {
              // TODO: Navigate to privacy settings
            },
          ),

          // App settings
          _buildSectionHeader('App Settings'),
          _buildListTile(
            context,
            icon: Icons.color_lens_outlined,
            title: 'Theme',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Show theme picker
            },
          ),
          _buildListTile(
            context,
            icon: Icons.language_outlined,
            title: 'Language & Region',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const RegionalSettingsWidget(),
                ),
              );
            },
          ),

          // Performance & Analytics
          _buildSectionHeader('Performance & Analytics'),
          _buildListTile(
            context,
            icon: Icons.analytics_outlined,
            title: 'Performance Analytics',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PerformanceAnalyticsMainDashboard(),
                ),
              );
            },
          ),
          _buildListTile(
            context,
            icon: Icons.monitor_outlined,
            title: 'Performance Monitoring',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PerformanceAnalyticsDashboard(),
                ),
              );
            },
          ),

          // Data Management
          _buildSectionHeader('Data Management'),
          _buildListTile(
            context,
            icon: Icons.backup_outlined,
            title: 'Backup & Recovery',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const BackupDashboard(),
                ),
              );
            },
          ),
          _buildListTile(
            context,
            icon: Icons.import_export_outlined,
            title: 'Data Export/Import',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const DataManagementDashboard(),
                ),
              );
            },
          ),

          // Administration
          _buildSectionHeader('Administration'),
          _buildListTile(
            context,
            icon: Icons.admin_panel_settings_outlined,
            title: 'Admin Dashboard',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AdminDashboard(),
                ),
              );
            },
          ),
          _buildListTile(
            context,
            icon: Icons.health_and_safety_outlined,
            title: 'System Health',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SystemHealthDashboard(),
                ),
              );
            },
          ),

          // About
          _buildSectionHeader('About'),
          _buildListTile(
            context,
            icon: Icons.info_outline,
            title: 'About Katya',
            onTap: () {
              // TODO: Show about dialog
            },
          ),
          _buildListTile(
            context,
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              // TODO: Show help & support
            },
          ),

          // Logout button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<MatrixProvider>(
              builder: (context, matrixProvider, _) {
                return ElevatedButton(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to log out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('CANCEL'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.error,
                            ),
                            child: const Text('LOGOUT'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      await matrixProvider.logout();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacementNamed('/login');
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.errorContainer,
                    foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Logout'),
                );
              },
            ),
          ),

          // App version
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Katya v1.0.0',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileSection(BuildContext context) {
    return Consumer<MatrixProvider>(
      builder: (context, matrixProvider, _) {
        final userId = matrixProvider.client?.userID ?? 'Unknown User';
        final displayName = userId;
        const String? avatarUrl = null;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // User avatar
              CircleAvatar(
                radius: 32,
                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child: avatarUrl == null
                    ? Text(
                        displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 24),
                      )
                    : null,
              ),

              const SizedBox(width: 16),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (userId.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        userId,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Edit profile button
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  // TODO: Edit profile
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      minLeadingWidth: 24,
    );
  }
}
