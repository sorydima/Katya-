import 'package:flutter/material.dart';
import '../../services/backup/backup_service.dart';

/// Виджет для отображения списка резервных копий
class BackupListWidget extends StatefulWidget {
  final List<BackupInfo> backups;
  final Function()? onRefresh;
  final Function(BackupInfo)? onDelete;
  final Function(BackupInfo)? onRestore;

  const BackupListWidget({
    super.key,
    required this.backups,
    this.onRefresh,
    this.onDelete,
    this.onRestore,
  });

  @override
  State<BackupListWidget> createState() => _BackupListWidgetState();
}

class _BackupListWidgetState extends State<BackupListWidget> {
  String _searchQuery = '';
  BackupType? _filterType;
  String _sortBy = 'date';
  bool _sortAscending = false;

  @override
  Widget build(BuildContext context) {
    final filteredBackups = _getFilteredBackups();

    return Column(
      children: [
        // Панель фильтров и поиска
        _buildFilterBar(),

        // Список резервных копий
        Expanded(
          child: filteredBackups.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: filteredBackups.length,
                  itemBuilder: (context, index) {
                    final backup = filteredBackups[index];
                    return _buildBackupCard(backup);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        children: [
          // Поиск
          TextField(
            decoration: InputDecoration(
              hintText: 'Search backups...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),

          const SizedBox(height: 16),

          // Фильтры и сортировка
          Row(
            children: [
              // Фильтр по типу
              Expanded(
                child: DropdownButtonFormField<BackupType?>(
                  initialValue: _filterType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem<BackupType?>(
                      value: null,
                      child: Text('All Types'),
                    ),
                    DropdownMenuItem<BackupType?>(
                      value: BackupType.full,
                      child: Text('Full Backups'),
                    ),
                    DropdownMenuItem<BackupType?>(
                      value: BackupType.incremental,
                      child: Text('Incremental Backups'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filterType = value;
                    });
                  },
                ),
              ),

              const SizedBox(width: 16),

              // Сортировка
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _sortBy,
                  decoration: const InputDecoration(
                    labelText: 'Sort By',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'date',
                      child: Text('Date'),
                    ),
                    DropdownMenuItem(
                      value: 'name',
                      child: Text('Name'),
                    ),
                    DropdownMenuItem(
                      value: 'size',
                      child: Text('Size'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                    });
                  },
                ),
              ),

              const SizedBox(width: 16),

              // Направление сортировки
              IconButton(
                onPressed: () {
                  setState(() {
                    _sortAscending = !_sortAscending;
                  });
                },
                icon: Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                ),
                tooltip: _sortAscending ? 'Sort Ascending' : 'Sort Descending',
              ),

              // Обновление
              IconButton(
                onPressed: widget.onRefresh,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.backup,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No backups found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first backup to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBackupCard(BackupInfo backup) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            Row(
              children: [
                Icon(
                  backup.type == BackupType.full ? Icons.archive : Icons.add_circle,
                  color: backup.type == BackupType.full ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        backup.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (backup.description != null)
                        Text(
                          backup.description!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'restore':
                        widget.onRestore?.call(backup);
                      case 'delete':
                        _showDeleteDialog(backup);
                      case 'info':
                        _showInfoDialog(backup);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'restore',
                      child: Row(
                        children: [
                          Icon(Icons.restore, size: 20),
                          SizedBox(width: 8),
                          Text('Restore'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'info',
                      child: Row(
                        children: [
                          Icon(Icons.info, size: 20),
                          SizedBox(width: 8),
                          Text('Info'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Информация о резервной копии
            _buildBackupInfo(backup),

            const SizedBox(height: 16),

            // Кнопки действий
            _buildActionButtons(backup),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupInfo(BackupInfo backup) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                'Type',
                backup.type == BackupType.full ? 'Full Backup' : 'Incremental',
                Icons.backup,
                color: backup.type == BackupType.full ? Colors.green : Colors.orange,
              ),
            ),
            Expanded(
              child: _buildInfoItem(
                'Size',
                _formatBytes(backup.size),
                Icons.storage,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                'Created',
                _formatDateTime(backup.createdAt),
                Icons.schedule,
              ),
            ),
            Expanded(
              child: _buildInfoItem(
                'Path',
                _getShortPath(backup.path),
                Icons.folder,
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
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BackupInfo backup) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => widget.onRestore?.call(backup),
            icon: const Icon(Icons.restore, size: 16),
            label: const Text('Restore'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showInfoDialog(backup),
            icon: const Icon(Icons.info, size: 16),
            label: const Text('Info'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showDeleteDialog(backup),
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

  List<BackupInfo> _getFilteredBackups() {
    final List<BackupInfo> filtered = widget.backups.where((backup) {
      // Фильтр по поисковому запросу
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!backup.name.toLowerCase().contains(query) && (backup.description?.toLowerCase().contains(query) != true)) {
          return false;
        }
      }

      // Фильтр по типу
      if (_filterType != null && backup.type != _filterType) {
        return false;
      }

      return true;
    }).toList();

    // Сортировка
    filtered.sort((a, b) {
      int comparison = 0;

      switch (_sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
        case 'size':
          comparison = a.size.compareTo(b.size);
        case 'date':
        default:
          comparison = a.createdAt.compareTo(b.createdAt);
      }

      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getShortPath(String path) {
    if (path.length <= 30) return path;
    return '...${path.substring(path.length - 27)}';
  }

  // Диалоги

  void _showDeleteDialog(BackupInfo backup) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Backup'),
        content: Text('Are you sure you want to delete the backup "${backup.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onDelete?.call(backup);
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

  void _showInfoDialog(BackupInfo backup) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(backup.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (backup.description != null) ...[
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(backup.description!),
                const SizedBox(height: 16),
              ],
              Text(
                'Type',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(backup.type == BackupType.full ? 'Full Backup' : 'Incremental Backup'),
              const SizedBox(height: 16),
              Text(
                'Size',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(_formatBytes(backup.size)),
              const SizedBox(height: 16),
              Text(
                'Created',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(_formatDateTime(backup.createdAt)),
              const SizedBox(height: 16),
              Text(
                'Path',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(backup.path),
              if (backup.metadata != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Metadata',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    backup.metadata.toString(),
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ],
            ],
          ),
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
