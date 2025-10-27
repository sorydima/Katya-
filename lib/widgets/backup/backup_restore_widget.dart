import 'package:flutter/material.dart';
import '../../services/backup/backup_service.dart';

/// Виджет для восстановления из резервных копий
class BackupRestoreWidget extends StatefulWidget {
  final List<BackupInfo> backups;
  final Function(RestoreResult)? onRestoreCompleted;

  const BackupRestoreWidget({
    super.key,
    required this.backups,
    this.onRestoreCompleted,
  });

  @override
  State<BackupRestoreWidget> createState() => _BackupRestoreWidgetState();
}

class _BackupRestoreWidgetState extends State<BackupRestoreWidget> {
  final BackupService _backupService = BackupService();
  final _formKey = GlobalKey<FormState>();

  // Выбранная резервная копия
  BackupInfo? _selectedBackup;

  // Настройки восстановления
  final _targetPathController = TextEditingController();
  bool _verifyIntegrity = true;
  bool _overwriteExisting = false;

  // Пути для включения/исключения
  final List<String> _includeFiles = [];
  final List<String> _excludeFiles = [];

  // Состояние
  bool _isRestoring = false;
  RestoreResult? _lastResult;

  @override
  void initState() {
    super.initState();
    _targetPathController.text = 'restored_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  void dispose() {
    _targetPathController.dispose();
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
                const Icon(Icons.restore, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Restore Backup',
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
                      // Выбор резервной копии
                      _buildBackupSelectionSection(),
                      const SizedBox(height: 24),

                      // Настройки восстановления
                      _buildRestoreSettingsSection(),
                      const SizedBox(height: 24),

                      // Фильтры файлов
                      _buildFileFiltersSection(),
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

  Widget _buildBackupSelectionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Backup',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (widget.backups.isEmpty)
              const Text('No backups available')
            else
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListView.builder(
                  itemCount: widget.backups.length,
                  itemBuilder: (context, index) {
                    final backup = widget.backups[index];
                    final isSelected = _selectedBackup?.id == backup.id;

                    return ListTile(
                      leading: Icon(
                        backup.type == BackupType.full ? Icons.archive : Icons.add_circle,
                        color: backup.type == BackupType.full ? Colors.green : Colors.orange,
                      ),
                      title: Text(backup.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${_formatBytes(backup.size)} • ${_formatDate(backup.createdAt)}'),
                          if (backup.description != null) Text(backup.description!),
                        ],
                      ),
                      trailing: Radio<BackupInfo>(
                        value: backup,
                        groupValue: _selectedBackup,
                        onChanged: (value) {
                          setState(() {
                            _selectedBackup = value;
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          _selectedBackup = backup;
                        });
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestoreSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Restore Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Путь назначения
            TextFormField(
              controller: _targetPathController,
              decoration: const InputDecoration(
                labelText: 'Target Path',
                hintText: 'Enter target directory for restore',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a target path';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Проверка целостности
            SwitchListTile(
              title: const Text('Verify Integrity'),
              subtitle: const Text('Verify backup integrity before restore'),
              value: _verifyIntegrity,
              onChanged: (value) {
                setState(() {
                  _verifyIntegrity = value;
                });
              },
            ),

            // Перезапись существующих файлов
            SwitchListTile(
              title: const Text('Overwrite Existing Files'),
              subtitle: const Text('Overwrite existing files during restore'),
              value: _overwriteExisting,
              onChanged: (value) {
                setState(() {
                  _overwriteExisting = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileFiltersSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'File Filters (Optional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Включенные файлы
            Text(
              'Include Files',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Container(
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ListView.builder(
                itemCount: _includeFiles.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_includeFiles[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _includeFiles.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _addIncludeFile,
              icon: const Icon(Icons.add),
              label: const Text('Add Include File'),
            ),

            const SizedBox(height: 16),

            // Исключенные файлы
            Text(
              'Exclude Files',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Container(
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ListView.builder(
                itemCount: _excludeFiles.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_excludeFiles[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _excludeFiles.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _addExcludeFile,
              icon: const Icon(Icons.add),
              label: const Text('Add Exclude File'),
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
              'Restore Result',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (_lastResult!.success) ...[
              const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Restore completed successfully'),
                ],
              ),
              const SizedBox(height: 8),
              if (_lastResult!.restoredFilesCount != null) Text('Files restored: ${_lastResult!.restoredFilesCount}'),
            ] else ...[
              const Row(
                children: [
                  Icon(Icons.error, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Restore failed'),
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
          onPressed: _isRestoring ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _isRestoring ? null : _restoreBackup,
          child: _isRestoring
              ? const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('Restoring...'),
                  ],
                )
              : const Text('Restore Backup'),
        ),
      ],
    );
  }

  // Вспомогательные методы

  void _addIncludeFile() {
    showDialog(
      context: context,
      builder: (context) => _FileInputDialog(
        title: 'Add Include File',
        onFileAdded: (file) {
          setState(() {
            _includeFiles.add(file);
          });
        },
      ),
    );
  }

  void _addExcludeFile() {
    showDialog(
      context: context,
      builder: (context) => _FileInputDialog(
        title: 'Add Exclude File',
        onFileAdded: (file) {
          setState(() {
            _excludeFiles.add(file);
          });
        },
      ),
    );
  }

  Future<void> _restoreBackup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBackup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a backup to restore'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isRestoring = true;
      _lastResult = null;
    });

    try {
      final RestoreResult result = await _backupService.restoreFromBackup(
        backupPath: _selectedBackup!.path,
        targetPath: _targetPathController.text,
        verifyIntegrity: _verifyIntegrity,
        overwriteExisting: _overwriteExisting,
        includeFiles: _includeFiles.isEmpty ? null : _includeFiles,
        excludeFiles: _excludeFiles.isEmpty ? null : _excludeFiles,
      );

      setState(() {
        _lastResult = result;
        _isRestoring = false;
      });

      if (result.success) {
        widget.onRestoreCompleted?.call(result);
      }
    } catch (e) {
      setState(() {
        _lastResult = RestoreResult(
          success: false,
          taskId: '',
          error: e.toString(),
          createdAt: DateTime.now(),
        );
        _isRestoring = false;
      });
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Диалог для ввода файла
class _FileInputDialog extends StatefulWidget {
  final String title;
  final Function(String) onFileAdded;

  const _FileInputDialog({
    required this.title,
    required this.onFileAdded,
  });

  @override
  State<_FileInputDialog> createState() => _FileInputDialogState();
}

class _FileInputDialogState extends State<_FileInputDialog> {
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
            labelText: 'File Pattern',
            hintText: 'Enter file pattern (e.g., *.txt, folder/**)',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a file pattern';
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
              widget.onFileAdded(_controller.text);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
