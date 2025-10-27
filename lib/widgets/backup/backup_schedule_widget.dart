import 'package:flutter/material.dart';
import '../../services/backup/backup_scheduler_service.dart';

/// Виджет для управления расписаниями резервного копирования
class BackupScheduleWidget extends StatefulWidget {
  final List<BackupSchedule> schedules;
  final Function()? onRefresh;
  final Function(String, bool)? onToggle;
  final Function(String)? onDelete;
  final Function(String)? onRun;

  const BackupScheduleWidget({
    super.key,
    required this.schedules,
    this.onRefresh,
    this.onToggle,
    this.onDelete,
    this.onRun,
  });

  @override
  State<BackupScheduleWidget> createState() => _BackupScheduleWidgetState();
}

class _BackupScheduleWidgetState extends State<BackupScheduleWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Заголовок и кнопка создания
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Backup Schedules',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showCreateScheduleDialog,
                icon: const Icon(Icons.add),
                label: const Text('Create Schedule'),
              ),
            ],
          ),
        ),

        // Список расписаний
        Expanded(
          child: widget.schedules.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: widget.schedules.length,
                  itemBuilder: (context, index) {
                    final schedule = widget.schedules[index];
                    return _buildScheduleCard(schedule);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No backup schedules',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a schedule to automatically backup your data',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreateScheduleDialog,
            icon: const Icon(Icons.add),
            label: const Text('Create First Schedule'),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(BackupSchedule schedule) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок и переключатель
            Row(
              children: [
                Icon(
                  _getScheduleIcon(schedule.type),
                  color: schedule.enabled ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (schedule.description != null)
                        Text(
                          schedule.description!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                    ],
                  ),
                ),
                Switch(
                  value: schedule.enabled,
                  onChanged: (value) => widget.onToggle?.call(schedule.id, value),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Информация о расписании
            _buildScheduleInfo(schedule),

            const SizedBox(height: 16),

            // Кнопки действий
            _buildActionButtons(schedule),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleInfo(BackupSchedule schedule) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                'Type',
                _formatScheduleType(schedule.type),
                Icons.schedule,
              ),
            ),
            Expanded(
              child: _buildInfoItem(
                'Status',
                schedule.enabled ? 'Enabled' : 'Disabled',
                schedule.enabled ? Icons.check_circle : Icons.cancel,
                color: schedule.enabled ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                'Last Run',
                schedule.lastRun != null ? _formatDateTime(schedule.lastRun!) : 'Never',
                Icons.history,
              ),
            ),
            Expanded(
              child: _buildInfoItem(
                'Next Run',
                schedule.nextRun != null ? _formatDateTime(schedule.nextRun!) : 'Not scheduled',
                Icons.schedule,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                'Retention',
                '${schedule.maxRetentionDays} days',
                Icons.delete_sweep,
              ),
            ),
            Expanded(
              child: _buildInfoItem(
                'Max Backups',
                '${schedule.maxBackups}',
                Icons.storage,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, {Color? color}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color ?? Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BackupSchedule schedule) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showEditScheduleDialog(schedule),
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Edit'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: schedule.enabled ? () => widget.onRun?.call(schedule.id) : null,
            icon: const Icon(Icons.play_arrow, size: 16),
            label: const Text('Run Now'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showDeleteScheduleDialog(schedule),
            icon: const Icon(Icons.delete, size: 16),
            label: const Text('Delete'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  // Вспомогательные методы

  IconData _getScheduleIcon(BackupScheduleType type) {
    switch (type) {
      case BackupScheduleType.daily:
        return Icons.today;
      case BackupScheduleType.weekly:
        return Icons.date_range;
      case BackupScheduleType.monthly:
        return Icons.calendar_month;
      case BackupScheduleType.custom:
        return Icons.schedule;
    }
  }

  String _formatScheduleType(BackupScheduleType type) {
    switch (type) {
      case BackupScheduleType.daily:
        return 'Daily';
      case BackupScheduleType.weekly:
        return 'Weekly';
      case BackupScheduleType.monthly:
        return 'Monthly';
      case BackupScheduleType.custom:
        return 'Custom';
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Диалоги

  void _showCreateScheduleDialog() {
    showDialog(
      context: context,
      builder: (context) => _ScheduleCreationDialog(
        onScheduleCreated: () {
          widget.onRefresh?.call();
        },
      ),
    );
  }

  void _showEditScheduleDialog(BackupSchedule schedule) {
    showDialog(
      context: context,
      builder: (context) => _ScheduleCreationDialog(
        existingSchedule: schedule,
        onScheduleCreated: () {
          widget.onRefresh?.call();
        },
      ),
    );
  }

  void _showDeleteScheduleDialog(BackupSchedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: Text('Are you sure you want to delete the schedule "${schedule.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onDelete?.call(schedule.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Диалог создания/редактирования расписания
class _ScheduleCreationDialog extends StatefulWidget {
  final BackupSchedule? existingSchedule;
  final Function()? onScheduleCreated;

  const _ScheduleCreationDialog({
    this.existingSchedule,
    this.onScheduleCreated,
  });

  @override
  State<_ScheduleCreationDialog> createState() => _ScheduleCreationDialogState();
}

class _ScheduleCreationDialogState extends State<_ScheduleCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Настройки расписания
  BackupScheduleType _scheduleType = BackupScheduleType.daily;
  int _hour = 2;
  int _minute = 0;
  int _dayOfWeek = 1; // Monday
  int _dayOfMonth = 1;

  // Настройки резервного копирования
  bool _compress = true;
  bool _encrypt = false;
  final _encryptionKeyController = TextEditingController();

  // Настройки очистки
  int _maxRetentionDays = 30;
  int _maxBackups = 10;

  @override
  void initState() {
    super.initState();

    if (widget.existingSchedule != null) {
      final schedule = widget.existingSchedule!;
      _nameController.text = schedule.name;
      _descriptionController.text = schedule.description ?? '';
      _scheduleType = schedule.type;
      _maxRetentionDays = schedule.maxRetentionDays;
      _maxBackups = schedule.maxBackups;

      // Извлечение настроек из scheduleConfig
      final config = schedule.scheduleConfig;
      _hour = config['hour'] ?? 2;
      _minute = config['minute'] ?? 0;
      _dayOfWeek = config['dayOfWeek'] ?? 1;
      _dayOfMonth = config['dayOfMonth'] ?? 1;

      // Извлечение настроек из backupConfig
      final backupConfig = schedule.backupConfig;
      _compress = backupConfig['compress'] ?? true;
      _encrypt = backupConfig['encrypt'] ?? false;
    } else {
      _nameController.text = 'schedule_${DateTime.now().millisecondsSinceEpoch}';
    }
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
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Заголовок
            Row(
              children: [
                const Icon(Icons.schedule, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.existingSchedule != null ? 'Edit Schedule' : 'Create Schedule',
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

                      // Настройки расписания
                      _buildScheduleSettingsSection(),
                      const SizedBox(height: 24),

                      // Настройки резервного копирования
                      _buildBackupSettingsSection(),
                      const SizedBox(height: 24),

                      // Настройки очистки
                      _buildCleanupSettingsSection(),
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
                labelText: 'Schedule Name',
                hintText: 'Enter a name for the schedule',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a schedule name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Enter a description for the schedule',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Schedule Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Тип расписания
            Text(
              'Schedule Type',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            RadioListTile<BackupScheduleType>(
              title: const Text('Daily'),
              subtitle: const Text('Run backup every day'),
              value: BackupScheduleType.daily,
              groupValue: _scheduleType,
              onChanged: (value) {
                setState(() {
                  _scheduleType = value!;
                });
              },
            ),
            RadioListTile<BackupScheduleType>(
              title: const Text('Weekly'),
              subtitle: const Text('Run backup every week'),
              value: BackupScheduleType.weekly,
              groupValue: _scheduleType,
              onChanged: (value) {
                setState(() {
                  _scheduleType = value!;
                });
              },
            ),
            RadioListTile<BackupScheduleType>(
              title: const Text('Monthly'),
              subtitle: const Text('Run backup every month'),
              value: BackupScheduleType.monthly,
              groupValue: _scheduleType,
              onChanged: (value) {
                setState(() {
                  _scheduleType = value!;
                });
              },
            ),

            const SizedBox(height: 16),

            // Время выполнения
            Text(
              'Run Time',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _hour,
                    decoration: const InputDecoration(
                      labelText: 'Hour',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(
                        24,
                        (index) => DropdownMenuItem(
                              value: index,
                              child: Text('${index.toString().padLeft(2, '0')}:00'),
                            )),
                    onChanged: (value) {
                      setState(() {
                        _hour = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _minute,
                    decoration: const InputDecoration(
                      labelText: 'Minute',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(
                        60,
                        (index) => DropdownMenuItem(
                              value: index,
                              child: Text(index.toString().padLeft(2, '0')),
                            )),
                    onChanged: (value) {
                      setState(() {
                        _minute = value!;
                      });
                    },
                  ),
                ),
              ],
            ),

            // Дополнительные настройки для недельного и месячного расписания
            if (_scheduleType == BackupScheduleType.weekly) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _dayOfWeek,
                decoration: const InputDecoration(
                  labelText: 'Day of Week',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Monday')),
                  DropdownMenuItem(value: 2, child: Text('Tuesday')),
                  DropdownMenuItem(value: 3, child: Text('Wednesday')),
                  DropdownMenuItem(value: 4, child: Text('Thursday')),
                  DropdownMenuItem(value: 5, child: Text('Friday')),
                  DropdownMenuItem(value: 6, child: Text('Saturday')),
                  DropdownMenuItem(value: 7, child: Text('Sunday')),
                ],
                onChanged: (value) {
                  setState(() {
                    _dayOfWeek = value!;
                  });
                },
              ),
            ],

            if (_scheduleType == BackupScheduleType.monthly) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _dayOfMonth,
                decoration: const InputDecoration(
                  labelText: 'Day of Month',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(
                    31,
                    (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text('${index + 1}'),
                        )),
                onChanged: (value) {
                  setState(() {
                    _dayOfMonth = value!;
                  });
                },
              ),
            ],
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

  Widget _buildCleanupSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cleanup Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Максимальный период хранения
            TextFormField(
              initialValue: _maxRetentionDays.toString(),
              decoration: const InputDecoration(
                labelText: 'Max Retention Days',
                hintText: 'Number of days to keep backups',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _maxRetentionDays = int.tryParse(value) ?? 30;
              },
            ),

            const SizedBox(height: 16),

            // Максимальное количество резервных копий
            TextFormField(
              initialValue: _maxBackups.toString(),
              decoration: const InputDecoration(
                labelText: 'Max Backups',
                hintText: 'Maximum number of backups to keep',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _maxBackups = int.tryParse(value) ?? 10;
              },
            ),
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _saveSchedule,
          child: Text(widget.existingSchedule != null ? 'Update' : 'Create'),
        ),
      ],
    );
  }

  Future<void> _saveSchedule() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final Map<String, dynamic> scheduleConfig = {
        'hour': _hour,
        'minute': _minute,
      };

      if (_scheduleType == BackupScheduleType.weekly) {
        scheduleConfig['dayOfWeek'] = _dayOfWeek;
      } else if (_scheduleType == BackupScheduleType.monthly) {
        scheduleConfig['dayOfMonth'] = _dayOfMonth;
      }

      final Map<String, dynamic> backupConfig = {
        'compress': _compress,
        'encrypt': _encrypt,
        'includePaths': [
          'lib/',
          'assets/',
          'config/',
          'pubspec.yaml',
          'pubspec.lock',
        ],
        'excludePaths': [
          'build/',
          '.dart_tool/',
          'node_modules/',
          '.git/',
          '*.log',
          '*.tmp',
        ],
      };

      if (_encrypt && _encryptionKeyController.text.isNotEmpty) {
        backupConfig['encryptionKey'] = _encryptionKeyController.text;
      }

      if (widget.existingSchedule != null) {
        // Обновление существующего расписания
        // TODO: Implement update logic
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule update not implemented yet')),
        );
      } else {
        // Создание нового расписания
        // TODO: Implement create logic
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule creation not implemented yet')),
        );
      }

      Navigator.of(context).pop();
      widget.onScheduleCreated?.call();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save schedule: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
