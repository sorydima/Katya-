import 'package:flutter/material.dart';
import 'package:katya/services/initialization/app_initialization_service.dart';
import 'package:katya/services/initialization/component_verification_service.dart';

/// Дашборд для отображения состояния системы и всех компонентов
class SystemHealthDashboard extends StatefulWidget {
  const SystemHealthDashboard({super.key});

  @override
  State<SystemHealthDashboard> createState() => _SystemHealthDashboardState();
}

class _SystemHealthDashboardState extends State<SystemHealthDashboard> {
  final AppInitializationService _initService = AppInitializationService();
  final ComponentVerificationService _verificationService = ComponentVerificationService();

  List<ComponentVerificationResult> _verificationResults = [];
  Map<String, dynamic> _initStatus = {};
  Map<String, dynamic> _verificationStats = {};
  bool _isLoading = true;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _loadSystemStatus();
  }

  Future<void> _loadSystemStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Получаем статус инициализации
      _initStatus = _initService.getInitializationStatus();

      // Загружаем результаты проверки компонентов
      _verificationResults = _verificationService.getVerificationResults();
      _verificationStats = _verificationService.getVerificationStatistics();
    } catch (e) {
      print('Error loading system status: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyComponents() async {
    setState(() {
      _isVerifying = true;
    });

    try {
      _verificationResults = await _verificationService.verifyAllComponents();
      _verificationStats = _verificationService.getVerificationStatistics();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Component verification completed'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Health Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSystemStatus,
          ),
          IconButton(
            icon: _isVerifying
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.verified_user),
            onPressed: _isVerifying ? null : _verifyComponents,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSystemOverview(),
                  const SizedBox(height: 24),
                  _buildInitializationStatus(),
                  const SizedBox(height: 24),
                  _buildComponentVerificationStats(),
                  const SizedBox(height: 24),
                  _buildComponentList(),
                ],
              ),
            ),
    );
  }

  Widget _buildSystemOverview() {
    final isInitialized = _initStatus['isInitialized'] as bool? ?? false;
    final errorCount = _initStatus['errorCount'] as int? ?? 0;
    final warningCount = _initStatus['warningCount'] as int? ?? 0;
    final successRate = _verificationStats['successRate'] as String? ?? '0.0';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildOverviewCard(
                    'Initialization',
                    isInitialized ? 'Complete' : 'Failed',
                    isInitialized ? Colors.green : Colors.red,
                    Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildOverviewCard(
                    'Success Rate',
                    '$successRate%',
                    double.parse(successRate) > 80 ? Colors.green : Colors.orange,
                    Icons.analytics,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildOverviewCard(
                    'Errors',
                    errorCount.toString(),
                    errorCount == 0 ? Colors.green : Colors.red,
                    Icons.error,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildOverviewCard(
                    'Warnings',
                    warningCount.toString(),
                    warningCount == 0 ? Colors.green : Colors.orange,
                    Icons.warning,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitializationStatus() {
    final isInitialized = _initStatus['isInitialized'] as bool? ?? false;
    final errors = _initStatus['errors'] as List<dynamic>? ?? [];
    final warnings = _initStatus['warnings'] as List<dynamic>? ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isInitialized ? Icons.check_circle : Icons.error,
                  color: isInitialized ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  'Initialization Status',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (errors.isNotEmpty) ...[
              const Text(
                'Errors:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              ...errors.map((error) => Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: Text(
                      '• $error',
                      style: const TextStyle(color: Colors.red),
                    ),
                  )),
              const SizedBox(height: 16),
            ],
            if (warnings.isNotEmpty) ...[
              const Text(
                'Warnings:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              ...warnings.map((warning) => Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: Text(
                      '• $warning',
                      style: const TextStyle(color: Colors.orange),
                    ),
                  )),
            ],
            if (errors.isEmpty && warnings.isEmpty)
              const Text(
                'No errors or warnings during initialization',
                style: TextStyle(color: Colors.green),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentVerificationStats() {
    final total = _verificationStats['total'] as int? ?? 0;
    final working = _verificationStats['working'] as int? ?? 0;
    final notWorking = _verificationStats['notWorking'] as int? ?? 0;
    final withErrors = _verificationStats['withErrors'] as int? ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Component Verification Statistics',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('Total', total.toString(), Colors.blue),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard('Working', working.toString(), Colors.green),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard('Not Working', notWorking.toString(), Colors.red),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard('With Errors', withErrors.toString(), Colors.orange),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentList() {
    if (_verificationResults.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              children: [
                const Icon(Icons.info_outline, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No component verification results available',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _verifyComponents,
                  child: const Text('Verify Components'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Component Status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ..._verificationResults.map((result) => _buildComponentItem(result)),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentItem(ComponentVerificationResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: result.isWorking ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: result.isWorking ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            result.isWorking ? Icons.check_circle : Icons.error,
            color: result.isWorking ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.componentName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (result.error != null)
                  Text(
                    result.error!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
          ),
          if (result.metadata != null)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showComponentDetails(result),
            ),
        ],
      ),
    );
  }

  void _showComponentDetails(ComponentVerificationResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(result.componentName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${result.isWorking ? 'Working' : 'Not Working'}'),
            if (result.error != null) ...[
              const SizedBox(height: 8),
              Text('Error: ${result.error}'),
            ],
            if (result.metadata != null) ...[
              const SizedBox(height: 8),
              const Text('Metadata:'),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  result.metadata.toString(),
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
            ],
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
}
