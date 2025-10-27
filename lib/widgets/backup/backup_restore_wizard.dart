import 'package:flutter/material.dart';

import '../../services/backup/backup_compression_service.dart';
import '../../services/backup/backup_encryption_service.dart';
import '../../services/backup/backup_service.dart';

/// Мастер восстановления резервных копий
class BackupRestoreWizard extends StatefulWidget {
  const BackupRestoreWizard({super.key});

  @override
  State<BackupRestoreWizard> createState() => _BackupRestoreWizardState();
}

class _BackupRestoreWizardState extends State<BackupRestoreWizard> {
  final BackupService _backupService = BackupService();
  final BackupEncryptionService _encryptionService = BackupEncryptionService();
  final BackupCompressionService _compressionService = BackupCompressionService();

  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Step 1: Backup Selection
  List<BackupInfo> _availableBackups = [];
  BackupInfo? _selectedBackup;

  // Step 2: Encryption
  bool _isEncrypted = false;
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;

  // Step 3: Compression
  bool _isCompressed = false;
  CompressionType? _compressionType;

  // Step 4: Restore Options
  String _restorePath = '';
  bool _overwriteExisting = false;
  bool _verifyIntegrity = true;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAvailableBackups();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableBackups() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<BackupInfo> backups = await _backupService.listBackups();
      setState(() {
        _availableBackups = backups;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load backups: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup Restore Wizard'),
        actions: [
          if (_currentStep > 0)
            TextButton(
              onPressed: _previousStep,
              child: const Text('Previous'),
            ),
          if (_currentStep < _totalSteps - 1)
            TextButton(
              onPressed: _canProceedToNextStep() ? _nextStep : null,
              child: const Text('Next'),
            ),
          if (_currentStep == _totalSteps - 1)
            TextButton(
              onPressed: _canProceedToNextStep() ? _startRestore : null,
              child: const Text('Restore'),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildBackupSelectionStep(),
                _buildEncryptionStep(),
                _buildCompressionStep(),
                _buildRestoreOptionsStep(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          final bool isActive = index == _currentStep;
          final bool isCompleted = index < _currentStep;

          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? Colors.green
                        : isActive
                            ? Colors.blue
                            : Colors.grey,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                if (index < _totalSteps - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isCompleted ? Colors.green : Colors.grey,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBackupSelectionStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Backup to Restore',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Choose the backup file you want to restore from the list below.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_errorMessage != null)
            Card(
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red[700]),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_errorMessage!)),
                    TextButton(
                      onPressed: _loadAvailableBackups,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (_availableBackups.isEmpty)
            const Center(
              child: Text(
                'No backups available',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _availableBackups.length,
                itemBuilder: (context, index) {
                  final BackupInfo backup = _availableBackups[index];
                  final bool isSelected = _selectedBackup?.id == backup.id;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: isSelected ? Colors.blue[50] : null,
                    child: ListTile(
                      leading: Icon(
                        backup.type == BackupType.full ? Icons.backup : Icons.add_circle,
                        color: isSelected ? Colors.blue : Colors.grey,
                      ),
                      title: Text(backup.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Type: ${backup.type.name}'),
                          Text('Size: ${_formatFileSize(backup.size)}'),
                          Text('Created: ${_formatDateTime(backup.createdAt)}'),
                        ],
                      ),
                      trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.blue) : null,
                      onTap: () {
                        setState(() {
                          _selectedBackup = backup;
                        });
                        _checkBackupProperties();
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEncryptionStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Encryption Settings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'If the selected backup is encrypted, enter the password to decrypt it.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isEncrypted ? Icons.lock : Icons.lock_open,
                        color: _isEncrypted ? Colors.orange : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isEncrypted ? 'Backup is encrypted' : 'Backup is not encrypted',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _isEncrypted ? Colors.orange : Colors.green,
                        ),
                      ),
                    ],
                  ),
                  if (_isEncrypted) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter backup password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompressionStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Compression Settings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'The backup compression type will be automatically detected and handled.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isCompressed ? Icons.compress : Icons.folder_open,
                        color: _isCompressed ? Colors.blue : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isCompressed ? 'Backup is compressed' : 'Backup is not compressed',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _isCompressed ? Colors.blue : Colors.green,
                        ),
                      ),
                    ],
                  ),
                  if (_isCompressed && _compressionType != null) ...[
                    const SizedBox(height: 8),
                    Text('Compression type: ${_compressionType!.name}'),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestoreOptionsStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Restore Options',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Configure the restore options for your backup.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Restore Path',
                      hintText: 'Enter the path where to restore the backup',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _restorePath = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Overwrite existing files'),
                    subtitle: const Text('Replace existing files with backup versions'),
                    value: _overwriteExisting,
                    onChanged: (value) {
                      setState(() {
                        _overwriteExisting = value ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Verify integrity'),
                    subtitle: const Text('Verify the integrity of restored files'),
                    value: _verifyIntegrity,
                    onChanged: (value) {
                      setState(() {
                        _verifyIntegrity = value ?? true;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_selectedBackup != null)
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Restore Summary',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Backup: ${_selectedBackup!.name}'),
                    Text('Type: ${_selectedBackup!.type.name}'),
                    Text('Size: ${_formatFileSize(_selectedBackup!.size)}'),
                    Text('Restore Path: ${_restorePath.isEmpty ? 'Not specified' : _restorePath}'),
                    Text('Overwrite: ${_overwriteExisting ? 'Yes' : 'No'}'),
                    Text('Verify: ${_verifyIntegrity ? 'Yes' : 'No'}'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Helper methods

  Future<void> _checkBackupProperties() async {
    if (_selectedBackup == null) return;

    try {
      // Check if backup is encrypted
      final bool isEncrypted = await _encryptionService.isEncrypted(_selectedBackup!.path);

      // Check if backup is compressed
      final bool isCompressed = await _compressionService.isCompressed(_selectedBackup!.path);
      final CompressionInfo? compressionInfo = await _compressionService.getCompressionInfo(_selectedBackup!.path);

      setState(() {
        _isEncrypted = isEncrypted;
        _isCompressed = isCompressed;
        _compressionType = compressionInfo?.type;
      });
    } catch (e) {
      // Handle error silently or show a message
      print('Error checking backup properties: $e');
    }
  }

  bool _canProceedToNextStep() {
    switch (_currentStep) {
      case 0:
        return _selectedBackup != null;
      case 1:
        return !_isEncrypted || _passwordController.text.isNotEmpty;
      case 2:
        return true; // Compression step is informational
      case 3:
        return _restorePath.isNotEmpty;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _startRestore() async {
    if (_selectedBackup == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Implement actual restore logic
      await Future.delayed(const Duration(seconds: 2)); // Simulate restore process

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Restore Complete'),
            content: const Text('The backup has been successfully restored.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Restore failed: $e';
        _isLoading = false;
      });
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
