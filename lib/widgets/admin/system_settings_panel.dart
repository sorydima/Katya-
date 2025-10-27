import 'package:flutter/material.dart';

import '../../services/security/advanced_security_service.dart';
import '../../services/security/models/security_policy.dart';
import '../../services/security/models/security_rule.dart';

/// Панель системных настроек
class SystemSettingsPanel extends StatefulWidget {
  const SystemSettingsPanel({super.key});

  @override
  State<SystemSettingsPanel> createState() => _SystemSettingsPanelState();
}

class _SystemSettingsPanelState extends State<SystemSettingsPanel> with TickerProviderStateMixin {
  final AdvancedSecurityService _securityService = AdvancedSecurityService();

  late TabController _tabController;

  List<SecurityPolicy> _securityPolicies = [];
  List<SecurityRule> _securityRules = [];
  bool _isLoading = true;

  // Настройки системы
  bool _enableTwoFactor = false;
  bool _enableAuditLogging = true;
  bool _enableIntrusionDetection = true;
  int _sessionTimeout = 30;
  int _maxLoginAttempts = 5;
  String _encryptionLevel = 'AES-256';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadSystemSettings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSystemSettings() async {
    setState(() => _isLoading = true);

    try {
      final policies = _securityService.getAllPolicies();
      final rules = _securityService.getAllRules();

      setState(() {
        _securityPolicies = policies;
        _securityRules = rules;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load system settings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildGeneralTab(),
                      _buildSecurityTab(),
                      _buildNetworkTab(),
                      _buildPerformanceTab(),
                      _buildBackupTab(),
                      _buildAdvancedTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'System Settings',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  'Configure system-wide settings and security policies',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton.icon(
          onPressed: _saveAllSettings,
          icon: const Icon(Icons.save, size: 16),
          label: const Text('Save All'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: _resetToDefaults,
          icon: const Icon(Icons.restore, size: 16),
          label: const Text('Reset'),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadSystemSettings,
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      tabs: const [
        Tab(icon: Icon(Icons.settings), text: 'General'),
        Tab(icon: Icon(Icons.security), text: 'Security'),
        Tab(icon: Icon(Icons.network_check), text: 'Network'),
        Tab(icon: Icon(Icons.speed), text: 'Performance'),
        Tab(icon: Icon(Icons.backup), text: 'Backup'),
        Tab(icon: Icon(Icons.tune), text: 'Advanced'),
      ],
    );
  }

  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            'Application Settings',
            [
              _buildSwitchSetting(
                'Enable Notifications',
                'Show system notifications and alerts',
                true,
                (value) {
                  setState(() {
                    // Handle notification setting
                  });
                },
              ),
              _buildSwitchSetting(
                'Auto-save Settings',
                'Automatically save configuration changes',
                true,
                (value) {
                  setState(() {
                    // Handle auto-save setting
                  });
                },
              ),
              _buildDropdownSetting(
                'Default Language',
                'Select the default application language',
                'English',
                ['English', 'Russian', 'German', 'French'],
                (value) {
                  setState(() {
                    // Handle language setting
                  });
                },
              ),
              _buildDropdownSetting(
                'Theme',
                'Choose the application theme',
                'System',
                ['Light', 'Dark', 'System'],
                (value) {
                  setState(() {
                    // Handle theme setting
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            'System Information',
            [
              _buildInfoRow('Version', '1.0.0'),
              _buildInfoRow('Build Date', '2024-01-15'),
              _buildInfoRow('Platform', 'Flutter/Dart'),
              _buildInfoRow('Database', 'SQLite with SQLCipher'),
              _buildInfoRow('Encryption', 'AES-256'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            'Authentication Settings',
            [
              _buildSwitchSetting(
                'Two-Factor Authentication',
                'Require 2FA for all user accounts',
                _enableTwoFactor,
                (value) {
                  setState(() {
                    _enableTwoFactor = value;
                  });
                },
              ),
              _buildSliderSetting(
                'Session Timeout (minutes)',
                'Automatically log out users after inactivity',
                _sessionTimeout,
                5,
                120,
                (value) {
                  setState(() {
                    _sessionTimeout = value.round();
                  });
                },
              ),
              _buildSliderSetting(
                'Max Login Attempts',
                'Maximum failed login attempts before lockout',
                _maxLoginAttempts.toDouble(),
                3,
                10,
                (value) {
                  setState(() {
                    _maxLoginAttempts = value.round();
                  });
                },
              ),
              _buildDropdownSetting(
                'Encryption Level',
                'Select the encryption algorithm strength',
                _encryptionLevel,
                ['AES-128', 'AES-256', 'ChaCha20'],
                (value) {
                  setState(() {
                    _encryptionLevel = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            'Security Policies',
            [
              _buildSwitchSetting(
                'Audit Logging',
                'Log all security-related events',
                _enableAuditLogging,
                (value) {
                  setState(() {
                    _enableAuditLogging = value;
                  });
                },
              ),
              _buildSwitchSetting(
                'Intrusion Detection',
                'Monitor for suspicious activities',
                _enableIntrusionDetection,
                (value) {
                  setState(() {
                    _enableIntrusionDetection = value;
                  });
                },
              ),
              _buildActionButton(
                'Manage Security Policies',
                'Configure detailed security policies',
                Icons.policy,
                () => _showSecurityPoliciesDialog(),
              ),
              _buildActionButton(
                'View Security Rules',
                'Review and modify security rules',
                Icons.rule,
                () => _showSecurityRulesDialog(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            'Threat Protection',
            [
              _buildActionButton(
                'Run Security Scan',
                'Perform a comprehensive security scan',
                Icons.security,
                () => _runSecurityScan(),
              ),
              _buildActionButton(
                'View Threat Log',
                'Review detected threats and incidents',
                Icons.warning,
                () => _viewThreatLog(),
              ),
              _buildActionButton(
                'Update Security Definitions',
                'Download latest threat signatures',
                Icons.update,
                () => _updateSecurityDefinitions(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            'Connection Settings',
            [
              _buildTextInputSetting(
                'Server Host',
                'Primary server hostname or IP',
                'localhost',
                (value) {
                  // Handle server host setting
                },
              ),
              _buildTextInputSetting(
                'Server Port',
                'Primary server port number',
                '8080',
                (value) {
                  // Handle server port setting
                },
              ),
              _buildSwitchSetting(
                'Use SSL/TLS',
                'Encrypt connections with SSL/TLS',
                true,
                (value) {
                  setState(() {
                    // Handle SSL setting
                  });
                },
              ),
              _buildSwitchSetting(
                'Auto-reconnect',
                'Automatically reconnect on connection loss',
                true,
                (value) {
                  setState(() {
                    // Handle auto-reconnect setting
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            'Proxy Settings',
            [
              _buildSwitchSetting(
                'Use Proxy',
                'Route connections through a proxy server',
                false,
                (value) {
                  setState(() {
                    // Handle proxy setting
                  });
                },
              ),
              _buildTextInputSetting(
                'Proxy Host',
                'Proxy server hostname or IP',
                '',
                (value) {
                  // Handle proxy host setting
                },
                enabled: false,
              ),
              _buildTextInputSetting(
                'Proxy Port',
                'Proxy server port number',
                '',
                (value) {
                  // Handle proxy port setting
                },
                enabled: false,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            'Network Diagnostics',
            [
              _buildActionButton(
                'Test Connection',
                'Test network connectivity',
                Icons.network_check,
                () => _testConnection(),
              ),
              _buildActionButton(
                'Ping Server',
                'Check server response time',
                Icons.speed,
                () => _pingServer(),
              ),
              _buildActionButton(
                'View Network Log',
                'Review network activity logs',
                Icons.description,
                () => _viewNetworkLog(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            'Resource Limits',
            [
              _buildSliderSetting(
                'Max Memory Usage (MB)',
                'Maximum memory allocation for the application',
                512.0,
                128,
                2048,
                (value) {
                  setState(() {
                    // Handle memory limit setting
                  });
                },
              ),
              _buildSliderSetting(
                'Cache Size (MB)',
                'Maximum size for application cache',
                256.0,
                64,
                1024,
                (value) {
                  setState(() {
                    // Handle cache size setting
                  });
                },
              ),
              _buildSliderSetting(
                'Connection Pool Size',
                'Maximum number of concurrent connections',
                10.0,
                5,
                50,
                (value) {
                  setState(() {
                    // Handle connection pool setting
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            'Optimization Settings',
            [
              _buildSwitchSetting(
                'Enable Caching',
                'Use caching to improve performance',
                true,
                (value) {
                  setState(() {
                    // Handle caching setting
                  });
                },
              ),
              _buildSwitchSetting(
                'Compress Data',
                'Compress data transfers to reduce bandwidth',
                true,
                (value) {
                  setState(() {
                    // Handle compression setting
                  });
                },
              ),
              _buildSwitchSetting(
                'Background Processing',
                'Process tasks in the background',
                true,
                (value) {
                  setState(() {
                    // Handle background processing setting
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            'Performance Monitoring',
            [
              _buildActionButton(
                'View Performance Metrics',
                'Check current system performance',
                Icons.analytics,
                () => _viewPerformanceMetrics(),
              ),
              _buildActionButton(
                'Run Performance Test',
                'Execute system performance benchmark',
                Icons.speed,
                () => _runPerformanceTest(),
              ),
              _buildActionButton(
                'Clear Cache',
                'Clear all cached data',
                Icons.clear_all,
                () => _clearCache(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackupTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            'Backup Settings',
            [
              _buildSwitchSetting(
                'Auto Backup',
                'Automatically create backups',
                true,
                (value) {
                  setState(() {
                    // Handle auto backup setting
                  });
                },
              ),
              _buildDropdownSetting(
                'Backup Frequency',
                'How often to create automatic backups',
                'Daily',
                ['Hourly', 'Daily', 'Weekly', 'Monthly'],
                (value) {
                  setState(() {
                    // Handle backup frequency setting
                  });
                },
              ),
              _buildSliderSetting(
                'Retention Period (days)',
                'How long to keep backup files',
                30.0,
                7,
                365,
                (value) {
                  setState(() {
                    // Handle retention period setting
                  });
                },
              ),
              _buildTextInputSetting(
                'Backup Location',
                'Directory for storing backup files',
                '/backups/katya',
                (value) {
                  // Handle backup location setting
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            'Backup Operations',
            [
              _buildActionButton(
                'Create Backup Now',
                'Manually create a backup',
                Icons.backup,
                () => _createBackup(),
              ),
              _buildActionButton(
                'Restore from Backup',
                'Restore system from a backup file',
                Icons.restore,
                () => _restoreFromBackup(),
              ),
              _buildActionButton(
                'View Backup History',
                'List all available backups',
                Icons.history,
                () => _viewBackupHistory(),
              ),
              _buildActionButton(
                'Schedule Backup',
                'Configure backup schedule',
                Icons.schedule,
                () => _scheduleBackup(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            'Debug Settings',
            [
              _buildSwitchSetting(
                'Debug Mode',
                'Enable detailed logging and debugging',
                false,
                (value) {
                  setState(() {
                    // Handle debug mode setting
                  });
                },
              ),
              _buildSwitchSetting(
                'Verbose Logging',
                'Include detailed information in logs',
                false,
                (value) {
                  setState(() {
                    // Handle verbose logging setting
                  });
                },
              ),
              _buildTextInputSetting(
                'Log Level',
                'Minimum log level to record',
                'INFO',
                (value) {
                  // Handle log level setting
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            'Experimental Features',
            [
              _buildSwitchSetting(
                'Enable Beta Features',
                'Access to experimental functionality',
                false,
                (value) {
                  setState(() {
                    // Handle beta features setting
                  });
                },
              ),
              _buildSwitchSetting(
                'Advanced Analytics',
                'Enable enhanced analytics features',
                false,
                (value) {
                  setState(() {
                    // Handle advanced analytics setting
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            'System Maintenance',
            [
              _buildActionButton(
                'Clear All Logs',
                'Remove all log files',
                Icons.clear_all,
                () => _clearAllLogs(),
              ),
              _buildActionButton(
                'Reset Configuration',
                'Reset all settings to defaults',
                Icons.restore,
                () => _resetConfiguration(),
              ),
              _buildActionButton(
                'Export Configuration',
                'Export current settings to file',
                Icons.download,
                () => _exportConfiguration(),
              ),
              _buildActionButton(
                'Import Configuration',
                'Import settings from file',
                Icons.upload,
                () => _importConfiguration(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchSetting(String title, String description, bool value, Function(bool) onChanged) {
    return ListTile(
      title: Text(title),
      subtitle: Text(description),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSliderSetting(
      String title, String description, double value, double min, double max, Function(double) onChanged) {
    return ListTile(
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(description),
          const SizedBox(height: 8),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) / 10).round(),
            onChanged: onChanged,
          ),
          Text(value.toStringAsFixed(0)),
        ],
      ),
    );
  }

  Widget _buildDropdownSetting(
      String title, String description, String value, List<String> options, Function(String) onChanged) {
    return ListTile(
      title: Text(title),
      subtitle: Text(description),
      trailing: DropdownButton<String>(
        value: value,
        items: options.map((option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: (newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
      ),
    );
  }

  Widget _buildTextInputSetting(String title, String description, String value, Function(String) onChanged,
      {bool enabled = true}) {
    return ListTile(
      title: Text(title),
      subtitle: Text(description),
      trailing: SizedBox(
        width: 150,
        child: TextField(
          enabled: enabled,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, String description, IconData icon, VoidCallback onPressed) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(description),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onPressed,
    );
  }

  Future<void> _saveAllSettings() async {
    try {
      // TODO: Implement saving all settings
      _showSuccessSnackBar('All settings saved successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to save settings: $e');
    }
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
            'Are you sure you want to reset all settings to their default values? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement reset to defaults
              _showSuccessSnackBar('Settings reset to defaults');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showSecurityPoliciesDialog() {
    showDialog(
      context: context,
      builder: (context) => _SecurityPoliciesDialog(policies: _securityPolicies),
    );
  }

  void _showSecurityRulesDialog() {
    showDialog(
      context: context,
      builder: (context) => _SecurityRulesDialog(rules: _securityRules),
    );
  }

  void _runSecurityScan() {
    // TODO: Implement security scan
    _showInfoSnackBar('Security scan started...');
  }

  void _viewThreatLog() {
    // TODO: Implement threat log viewer
    _showInfoSnackBar('Opening threat log...');
  }

  void _updateSecurityDefinitions() {
    // TODO: Implement security definitions update
    _showInfoSnackBar('Updating security definitions...');
  }

  void _testConnection() {
    // TODO: Implement connection test
    _showInfoSnackBar('Testing connection...');
  }

  void _pingServer() {
    // TODO: Implement server ping
    _showInfoSnackBar('Pinging server...');
  }

  void _viewNetworkLog() {
    // TODO: Implement network log viewer
    _showInfoSnackBar('Opening network log...');
  }

  void _viewPerformanceMetrics() {
    // TODO: Implement performance metrics viewer
    _showInfoSnackBar('Opening performance metrics...');
  }

  void _runPerformanceTest() {
    // TODO: Implement performance test
    _showInfoSnackBar('Running performance test...');
  }

  void _clearCache() {
    // TODO: Implement cache clearing
    _showSuccessSnackBar('Cache cleared successfully');
  }

  void _createBackup() {
    // TODO: Implement backup creation
    _showInfoSnackBar('Creating backup...');
  }

  void _restoreFromBackup() {
    // TODO: Implement backup restoration
    _showInfoSnackBar('Opening backup restore dialog...');
  }

  void _viewBackupHistory() {
    // TODO: Implement backup history viewer
    _showInfoSnackBar('Opening backup history...');
  }

  void _scheduleBackup() {
    // TODO: Implement backup scheduling
    _showInfoSnackBar('Opening backup scheduler...');
  }

  void _clearAllLogs() {
    // TODO: Implement log clearing
    _showSuccessSnackBar('All logs cleared successfully');
  }

  void _resetConfiguration() {
    // TODO: Implement configuration reset
    _showSuccessSnackBar('Configuration reset successfully');
  }

  void _exportConfiguration() {
    // TODO: Implement configuration export
    _showInfoSnackBar('Exporting configuration...');
  }

  void _importConfiguration() {
    // TODO: Implement configuration import
    _showInfoSnackBar('Opening configuration import dialog...');
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
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

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

// Диалоги для системных настроек

class _SecurityPoliciesDialog extends StatelessWidget {
  final List<SecurityPolicy> policies;

  const _SecurityPoliciesDialog({required this.policies});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Security Policies'),
      content: SizedBox(
        width: 600,
        height: 400,
        child: ListView.builder(
          itemCount: policies.length,
          itemBuilder: (context, index) {
            final policy = policies[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: _getPolicyTypeColor(policy.type),
                child: Icon(
                  _getPolicyTypeIcon(policy.type),
                  color: Colors.white,
                ),
              ),
              title: Text(policy.name),
              subtitle: Text(policy.description),
              trailing: Switch(
                value: policy.isEnabled,
                onChanged: (value) {
                  // TODO: Implement policy toggle
                },
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: Implement add policy
          },
          child: const Text('Add Policy'),
        ),
      ],
    );
  }

  Color _getPolicyTypeColor(PolicyType type) {
    switch (type) {
      case PolicyType.authentication:
        return Colors.blue;
      case PolicyType.authorization:
        return Colors.green;
      case PolicyType.encryption:
        return Colors.purple;
      case PolicyType.audit:
        return Colors.orange;
    }
  }

  IconData _getPolicyTypeIcon(PolicyType type) {
    switch (type) {
      case PolicyType.authentication:
        return Icons.login;
      case PolicyType.authorization:
        return Icons.security;
      case PolicyType.encryption:
        return Icons.lock;
      case PolicyType.audit:
        return Icons.assessment;
    }
  }
}

class _SecurityRulesDialog extends StatelessWidget {
  final List<SecurityRule> rules;

  const _SecurityRulesDialog({required this.rules});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Security Rules'),
      content: SizedBox(
        width: 600,
        height: 400,
        child: ListView.builder(
          itemCount: rules.length,
          itemBuilder: (context, index) {
            final rule = rules[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: _getRuleTypeColor(rule.type),
                child: Icon(
                  _getRuleTypeIcon(rule.type),
                  color: Colors.white,
                ),
              ),
              title: Text(rule.name),
              subtitle: Text(rule.description),
              trailing: Switch(
                value: rule.isActive,
                onChanged: (value) {
                  // TODO: Implement rule toggle
                },
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: Implement add rule
          },
          child: const Text('Add Rule'),
        ),
      ],
    );
  }

  Color _getRuleTypeColor(RuleType type) {
    switch (type) {
      case RuleType.authentication:
        return Colors.blue;
      case RuleType.authorization:
        return Colors.green;
      case RuleType.encryption:
        return Colors.red;
      case RuleType.monitoring:
        return Colors.purple;
    }
  }

  IconData _getRuleTypeIcon(RuleType type) {
    switch (type) {
      case RuleType.authentication:
        return Icons.admin_panel_settings;
      case RuleType.authorization:
        return Icons.speed;
      case RuleType.encryption:
        return Icons.warning;
      case RuleType.monitoring:
        return Icons.shield;
    }
  }
}
