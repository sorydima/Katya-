import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/analytics/network_analytics_service.dart';
import '../../services/monitoring/performance_monitoring_service.dart';
import '../../services/trust_network/trust_network_service.dart';
import '../i18n/statistics_widget.dart';
import '../i18n/translation_widget.dart';
import 'analytics_dashboard.dart';
import 'device_management_panel.dart';
import 'real_time_monitor.dart';
import 'system_settings_panel.dart';
import 'trust_network_visualization.dart';

/// Главная административная панель Katya
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with TickerProviderStateMixin {
  late TabController _tabController;
  final TrustNetworkService _trustService = TrustNetworkService();
  final NetworkAnalyticsService _analyticsService = NetworkAnalyticsService();
  final PerformanceMonitoringService _monitoringService = PerformanceMonitoringService();

  int _selectedIndex = 0;
  bool _isLoading = true;
  Map<String, dynamic> _systemMetrics = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadSystemMetrics();

    // Обновление метрик каждые 30 секунд
    _startMetricsRefresh();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSystemMetrics() async {
    setState(() => _isLoading = true);

    try {
      final metrics = _analyticsService.getSystemMetrics();
      final performanceMetrics = _monitoringService.getCurrentMetrics();

      setState(() {
        _systemMetrics = {
          'network': metrics,
          'performance': performanceMetrics,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load system metrics: $e');
    }
  }

  void _startMetricsRefresh() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _loadSystemMetrics();
        _startMetricsRefresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                _buildSidebar(),
                Expanded(
                  child: _buildMainContent(),
                ),
              ],
            ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const TranslationWidget('dashboard.title'),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      elevation: 2,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadSystemMetrics,
          tooltip: 'Refresh',
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: _showSettings,
          tooltip: 'Settings',
        ),
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'export',
              child: ListTile(
                leading: Icon(Icons.download),
                title: Text('Export Data'),
              ),
            ),
            const PopupMenuItem(
              value: 'backup',
              child: ListTile(
                leading: Icon(Icons.backup),
                title: Text('Create Backup'),
              ),
            ),
            const PopupMenuItem(
              value: 'logs',
              child: ListTile(
                leading: Icon(Icons.description),
                title: Text('View Logs'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildSystemStatus(),
          const Divider(),
          _buildQuickStats(),
          const Divider(),
          Expanded(
            child: _buildNavigationList(),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildSystemStatus() {
    final isHealthy = _systemMetrics['performance']?['cpuUsage'] < 80;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isHealthy ? Icons.check_circle : Icons.warning,
                color: isHealthy ? Colors.green : Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'System Status',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isHealthy ? 'All systems operational' : 'Performance issues detected',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isHealthy ? Colors.green : Colors.orange,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final metrics = _systemMetrics['network'] ?? {};

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Stats',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _buildStatCard('Active Users', '${metrics['activeUsers'] ?? 0}', Icons.people),
          const SizedBox(height: 8),
          _buildStatCard('Total Verifications', '${metrics['totalVerifications'] ?? 0}', Icons.verified),
          const SizedBox(height: 8),
          _buildStatCard('Network Health', '${metrics['networkHealth'] ?? 0}%', Icons.network_check),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationList() {
    final navigationItems = [
      NavigationItem(
        title: 'Overview',
        icon: Icons.dashboard,
        index: 0,
      ),
      NavigationItem(
        title: 'Trust Network',
        icon: Icons.account_tree,
        index: 1,
      ),
      NavigationItem(
        title: 'Devices',
        icon: Icons.devices,
        index: 2,
      ),
      NavigationItem(
        title: 'Analytics',
        icon: Icons.analytics,
        index: 3,
      ),
      NavigationItem(
        title: 'Settings',
        icon: Icons.settings,
        index: 4,
      ),
      NavigationItem(
        title: 'Monitor',
        icon: Icons.monitor,
        index: 5,
      ),
    ];

    return ListView.builder(
      itemCount: navigationItems.length,
      itemBuilder: (context, index) {
        final item = navigationItems[index];
        final isSelected = _selectedIndex == index;

        return ListTile(
          leading: Icon(
            item.icon,
            color: isSelected ? Theme.of(context).colorScheme.primary : null,
          ),
          title: Text(
            item.title,
            style: TextStyle(
              color: isSelected ? Theme.of(context).colorScheme.primary : null,
              fontWeight: isSelected ? FontWeight.bold : null,
            ),
          ),
          selected: isSelected,
          onTap: () => _onNavigationItemSelected(index),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Divider(),
          Text(
            'Katya Admin Panel v1.0',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            'Last updated: ${DateTime.now().toString().substring(0, 19)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return const TrustNetworkVisualization();
      case 2:
        return const DeviceManagementPanel();
      case 3:
        return const AnalyticsDashboard();
      case 4:
        return const SystemSettingsPanel();
      case 5:
        return const RealTimeMonitor();
      default:
        return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    final metrics = _systemMetrics['network'] ?? {};
    final performanceMetrics = _systemMetrics['performance'] ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Overview',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),

          // Системные метрики
          _buildMetricsGrid(metrics, performanceMetrics),

          const SizedBox(height: 24),

          // Последние активности
          _buildRecentActivity(),

          const SizedBox(height: 24),

          // Быстрые действия
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(Map<String, dynamic> networkMetrics, Map<String, dynamic> performanceMetrics) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(
          'Active Users',
          '${networkMetrics['activeUsers'] ?? 0}',
          Icons.people,
          Colors.blue,
        ),
        _buildMetricCard(
          'Total Verifications',
          '${networkMetrics['totalVerifications'] ?? 0}',
          Icons.verified,
          Colors.green,
        ),
        _buildMetricCard(
          'CPU Usage',
          '${performanceMetrics['cpuUsage'] ?? 0}%',
          Icons.memory,
          Colors.orange,
        ),
        _buildMetricCard(
          'Memory Usage',
          '${performanceMetrics['memoryUsage'] ?? 0}%',
          Icons.storage,
          Colors.purple,
        ),
        _buildMetricCard(
          'Network Health',
          '${networkMetrics['networkHealth'] ?? 0}%',
          Icons.network_check,
          Colors.teal,
        ),
        _buildMetricCard(
          'Response Time',
          '${performanceMetrics['avgResponseTime'] ?? 0}ms',
          Icons.speed,
          Colors.red,
        ),
        _buildMetricCard(
          'Connected Devices',
          '${networkMetrics['connectedDevices'] ?? 0}',
          Icons.devices,
          Colors.indigo,
        ),
        _buildMetricCard(
          'Security Score',
          '${networkMetrics['securityScore'] ?? 0}/100',
          Icons.security,
          Colors.amber,
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Live',
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...List.generate(5, (index) => _buildActivityItem(index)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(int index) {
    final activities = [
      'New user registered: john.doe@example.com',
      'Device connected: IoT Sensor #${index + 1}',
      'Trust verification completed: Alice → Bob',
      'System backup created successfully',
      'Performance alert resolved: CPU usage normalized',
    ];

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: Icon(
          Icons.info,
          color: Theme.of(context).colorScheme.primary,
          size: 16,
        ),
      ),
      title: Text(activities[index]),
      subtitle: Text('${index + 1} minute${index == 0 ? '' : 's'} ago'),
      dense: true,
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildActionButton('Export Data', Icons.download, Colors.blue),
                _buildActionButton('Create Backup', Icons.backup, Colors.green),
                _buildActionButton('View Logs', Icons.description, Colors.orange),
                _buildActionButton('System Health', Icons.health_and_safety, Colors.red),
                _buildActionButton('User Management', Icons.people, Colors.purple),
                _buildActionButton('Network Settings', Icons.network_ping, Colors.teal),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color) {
    return ElevatedButton.icon(
      onPressed: () => _handleQuickAction(title),
      icon: Icon(icon, size: 18),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _showQuickActionsMenu,
      tooltip: 'Quick Actions',
      child: const Icon(Icons.add),
    );
  }

  void _onNavigationItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        _exportData();
      case 'backup':
        _createBackup();
      case 'logs':
        _viewLogs();
    }
  }

  void _handleQuickAction(String action) {
    HapticFeedback.lightImpact();

    switch (action) {
      case 'Export Data':
        _exportData();
      case 'Create Backup':
        _createBackup();
      case 'View Logs':
        _viewLogs();
      case 'System Health':
        _showSystemHealth();
      case 'User Management':
        _showUserManagement();
      case 'Network Settings':
        _showNetworkSettings();
    }
  }

  void _showQuickActionsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              children: [
                _buildQuickActionItem('Export', Icons.download, Colors.blue),
                _buildQuickActionItem('Backup', Icons.backup, Colors.green),
                _buildQuickActionItem('Logs', Icons.description, Colors.orange),
                _buildQuickActionItem('Health', Icons.health_and_safety, Colors.red),
                _buildQuickActionItem('Users', Icons.people, Colors.purple),
                _buildQuickActionItem('Network', Icons.network_ping, Colors.teal),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(String title, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _handleQuickAction(title);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettings() {
    setState(() => _selectedIndex = 4);
  }

  void _exportData() {
    // TODO: Implement data export
    _showSuccessSnackBar('Data export started...');
  }

  void _createBackup() {
    // TODO: Implement backup creation
    _showSuccessSnackBar('Backup creation started...');
  }

  void _viewLogs() {
    // TODO: Implement log viewer
    _showInfoSnackBar('Opening log viewer...');
  }

  void _showSystemHealth() {
    // TODO: Implement system health dialog
    _showInfoSnackBar('Opening system health...');
  }

  void _showUserManagement() {
    // TODO: Implement user management
    _showInfoSnackBar('Opening user management...');
  }

  void _showNetworkSettings() {
    // TODO: Implement network settings
    _showInfoSnackBar('Opening network settings...');
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class NavigationItem {
  final String title;
  final IconData icon;
  final int index;

  NavigationItem({
    required this.title,
    required this.icon,
    required this.index,
  });
}
