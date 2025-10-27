import 'package:flutter/material.dart';
import '../../services/backup/backup_service.dart';

/// Виджет для создания резервных копий
class BackupCreationWidget extends StatefulWidget {
  final Function(BackupResult)? onBackupCreated;

  const BackupCreationWidget({
    super.key,
    this.onBackupCreated,
  });

  @override
  State<BackupCreationWidget> createState() => _BackupCreationWidgetState();
}

class _BackupCreationWidgetState extends State<BackupCreationWidget> {
  final BackupService _backupService = BackupService();
  final _formKey = GlobalKey<FormState>();

  // Контроллеры формы
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Настройки резервного копирования
  BackupType _backupType = BackupType.full;
  bool _compress = true;
  bool _encrypt = false;
  final _encryptionKeyController = TextEditingController();
  BackupStorageType _storageType = BackupStorageType.local;

  // Пути для включения/исключения
  final List<String> _includePaths = [
    'lib/',
    'assets/',
    'config/',
    'pubspec.yaml',
    'pubspec.lock',
  ];
  final List<String> _excludePaths = [
    'build/',
    '.dart_tool/',
    'node_modules/',
    '.git/',
    '*.log',
    '*.tmp',
  ];

  // Состояние
  bool _isCreating = false;
  BackupResult? _lastResult;

  @override
  void initState() {
    super.initState();
    _nameController.text = 'backup_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _encryptionKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Заголовок
            Row(
              children: [
                const Icon(Icons.backup, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Create Backup',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),

            // Форма
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Основная информация
                      _buildBasicInfoSection(),
                      const SizedBox(height: 24),

                      // Настройки резервного копирования
                      _buildBackupSettingsSection(),
                      const SizedBox(height: 24),

                      // Пути включения/исключения
                      _buildPathsSection(),
                      const SizedBox(height: 24),

                      // Настройки хранилища
                      _buildStorageSection(),
                      const SizedBox(height: 24),

                      // Результат
                      if (_lastResult != null) _buildResultSection(),
                    ],
                  ),
                ),
              ),
            ),

            // Кнопки действий
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Backup Name',
                hintText: 'Enter a name for the backup',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a backup name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Enter a description for the backup',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Backup Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Тип резервного копирования
            Text(
              'Backup Type',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            RadioListTile<BackupType>(
              title: const Text('Full Backup'),
              subtitle: const Text('Backup all selected files and directories'),
              value: BackupType.full,
              groupValue: _backupType,
              onChanged: (value) {
                setState(() {
                  _backupType = value!;
                });
              },
            ),
            RadioListTile<BackupType>(
              title: const Text('Incremental Backup'),
              subtitle: const Text('Backup only changed files since last backup'),
              value: BackupType.incremental,
              groupValue: _backupType,
              onChanged: (value) {
                setState(() {
                  _backupType = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Сжатие
            SwitchListTile(
              title: const Text('Compress Backup'),
              subtitle: const Text('Reduce backup size by compression'),
              value: _compress,
              onChanged: (value) {
                setState(() {
                  _compress = value;
                });
              },
            ),

            // Шифрование
            SwitchListTile(
              title: const Text('Encrypt Backup'),
              subtitle: const Text('Protect backup with password encryption'),
              value: _encrypt,
              onChanged: (value) {
                setState(() {
                  _encrypt = value;
                });
              },
            ),

            if (_encrypt) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _encryptionKeyController,
                decoration: const InputDecoration(
                  labelText: 'Encryption Password',
                  hintText: 'Enter password for encryption',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (_encrypt && (value == null || value.isEmpty)) {
                    return 'Please enter encryption password';
                  }
                  if (_encrypt && value != null && value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPathsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Include/Exclude Paths',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Пути включения
            Text(
              'Include Paths',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Container(
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ListView.builder(
                itemCount: _includePaths.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_includePaths[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _includePaths.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _addIncludePath,
              icon: const Icon(Icons.add),
              label: const Text('Add Include Path'),
            ),

            const SizedBox(height: 16),

            // Пути исключения
            Text(
              'Exclude Paths',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Container(
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ListView.builder(
                itemCount: _excludePaths.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_excludePaths[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _excludePaths.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _addExcludePath,
              icon: const Icon(Icons.add),
              label: const Text('Add Exclude Path'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Storage Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Storage Type',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            RadioListTile<BackupStorageType>(
              title: const Text('Local Storage'),
              subtitle: const Text('Save backup to local directory'),
              value: BackupStorageType.local,
              groupValue: _storageType,
              onChanged: (value) {
                setState(() {
                  _storageType = value!;
                });
              },
            ),
            RadioListTile<BackupStorageType>(
              title: const Text('Cloud Storage'),
              subtitle: const Text('Save backup to cloud service'),
              value: BackupStorageType.cloud,
              groupValue: _storageType,
              onChanged: (value) {
                setState(() {
                  _storageType = value!;
                });
              },
            ),
            RadioListTile<BackupStorageType>(
              title: const Text('Remote Storage'),
              subtitle: const Text('Save backup to remote server'),
              value: BackupStorageType.remote,
              groupValue: _storageType,
              onChanged: (value) {
                setState(() {
                  _storageType = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Backup Result',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (_lastResult!.success) ...[
              const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Backup created successfully'),
                ],
              ),
              const SizedBox(height: 8),
              if (_lastResult!.backupPath != null) Text('Path: ${_lastResult!.backupPath}'),
              if (_lastResult!.size != null) Text('Size: ${_formatBytes(_lastResult!.size!)}'),
            ] else ...[
              const Row(
                children: [
                  Icon(Icons.error, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Backup failed'),
                ],
              ),
              const SizedBox(height: 8),
              if (_lastResult!.error != null) Text('Error: ${_lastResult!.error}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _isCreating ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _isCreating ? null : _createBackup,
          child: _isCreating
              ? const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('Creating...'),
                  ],
                )
              : const Text('Create Backup'),
        ),
      ],
    );
  }

  // Вспомогательные методы

  void _addIncludePath() {
    showDialog(
      context: context,
      builder: (context) => _PathInputDialog(
        title: 'Add Include Path',
        onPathAdded: (path) {
          setState(() {
            _includePaths.add(path);
          });
        },
      ),
    );
  }

  void _addExcludePath() {
    showDialog(
      context: context,
      builder: (context) => _PathInputDialog(
        title: 'Add Exclude Path',
        onPathAdded: (path) {
          setState(() {
            _excludePaths.add(path);
          });
        },
      ),
    );
  }

  Future<void> _createBackup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCreating = true;
      _lastResult = null;
    });

    try {
      BackupResult result;

      if (_backupType == BackupType.full) {
        result = await _backupService.createFullBackup(
          backupName: _nameController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          includePaths: _includePaths,
          excludePaths: _excludePaths,
          compress: _compress,
          encrypt: _encrypt,
          encryptionKey: _encrypt ? _encryptionKeyController.text : null,
          storageType: _storageType,
        );
      } else {
        // Для инкрементального резервного копирования нужна базовая резервная копия
        // TODO: Implement base backup selection
        throw Exception('Incremental backup requires a base backup');
      }

      setState(() {
        _lastResult = result;
        _isCreating = false;
      });

      if (result.success) {
        widget.onBackupCreated?.call(result);
      }
    } catch (e) {
      setState(() {
        _lastResult = BackupResult(
          success: false,
          taskId: '',
          error: e.toString(),
          createdAt: DateTime.now(),
        );
        _isCreating = false;
      });
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// Диалог для ввода пути
class _PathInputDialog extends StatefulWidget {
  final String title;
  final Function(String) onPathAdded;

  const _PathInputDialog({
    required this.title,
    required this.onPathAdded,
  });

  @override
  State<_PathInputDialog> createState() => _PathInputDialogState();
}

class _PathInputDialogState extends State<_PathInputDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'Path',
            hintText: 'Enter path to include/exclude',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a path';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onPathAdded(_controller.text);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
