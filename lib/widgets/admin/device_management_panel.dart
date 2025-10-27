import 'package:flutter/material.dart';

import '../../services/iot/iot_integration_service.dart';
import '../../services/iot/models/iot_command.dart';
import '../../services/iot/models/iot_device.dart';

/// Панель управления IoT устройствами
class DeviceManagementPanel extends StatefulWidget {
  const DeviceManagementPanel({super.key});

  @override
  State<DeviceManagementPanel> createState() => _DeviceManagementPanelState();
}

class _DeviceManagementPanelState extends State<DeviceManagementPanel> with TickerProviderStateMixin {
  final IoTIntegrationService _iotService = IoTIntegrationService();

  late TabController _tabController;

  List<IoTDevice> _devices = [];
  List<IoTCommand> _commandHistory = [];
  bool _isLoading = true;
  String _searchQuery = '';
  DeviceType? _selectedDeviceType;
  ConnectionStatus? _selectedConnectionStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDevices();

    // Обновление данных каждые 10 секунд
    _startPeriodicUpdate();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDevices() async {
    setState(() => _isLoading = true);

    try {
      final devices = _iotService.getAllDevices();
      final commandHistory = _iotService.getCommandHistory();

      setState(() {
        _devices = devices;
        _commandHistory = commandHistory;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load devices: $e');
    }
  }

  void _startPeriodicUpdate() {
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        _loadDevices();
        _startPeriodicUpdate();
      }
    });
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
                      _buildDevicesTab(),
                      _buildDeviceDetailsTab(),
                      _buildCommandHistoryTab(),
                      _buildDeviceAnalyticsTab(),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDeviceDialog,
        tooltip: 'Add Device',
        child: const Icon(Icons.add),
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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSearchBar(),
              ),
              const SizedBox(width: 16),
              _buildFilterDropdowns(),
              const SizedBox(width: 16),
              _buildActionButtons(),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatistics(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: const InputDecoration(
        hintText: 'Search devices...',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  Widget _buildFilterDropdowns() {
    return Row(
      children: [
        // Фильтр по типу устройства
        SizedBox(
          width: 150,
          child: DropdownButtonFormField<DeviceType?>(
            initialValue: _selectedDeviceType,
            decoration: const InputDecoration(
              labelText: 'Type',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: [
              const DropdownMenuItem<DeviceType?>(
                value: null,
                child: Text('All Types'),
              ),
              ...DeviceType.values.map((type) {
                return DropdownMenuItem<DeviceType?>(
                  value: type,
                  child: Text(_getDeviceTypeName(type)),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                _selectedDeviceType = value;
              });
            },
          ),
        ),
        const SizedBox(width: 12),

        // Фильтр по статусу подключения
        SizedBox(
          width: 150,
          child: DropdownButtonFormField<ConnectionStatus?>(
            initialValue: _selectedConnectionStatus,
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: [
              const DropdownMenuItem<ConnectionStatus?>(
                value: null,
                child: Text('All Status'),
              ),
              ...ConnectionStatus.values.map((status) {
                return DropdownMenuItem<ConnectionStatus?>(
                  value: status,
                  child: Text(_getConnectionStatusName(status)),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                _selectedConnectionStatus = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadDevices,
          tooltip: 'Refresh',
        ),
        IconButton(
          icon: const Icon(Icons.download),
          onPressed: _exportDevices,
          tooltip: 'Export',
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: _showDeviceSettings,
          tooltip: 'Settings',
        ),
      ],
    );
  }

  Widget _buildStatistics() {
    final filteredDevices = _getFilteredDevices();
    final connectedDevices = filteredDevices.where((d) => d.status == ConnectionStatus.connected).length;
    final totalDevices = filteredDevices.length;

    return Row(
      children: [
        _buildStatChip('Total', totalDevices.toString()),
        const SizedBox(width: 8),
        _buildStatChip('Connected', connectedDevices.toString()),
        const SizedBox(width: 8),
        _buildStatChip('Disconnected', (totalDevices - connectedDevices).toString()),
        const SizedBox(width: 8),
        _buildStatChip('Types', _devices.map((d) => d.type).toSet().length.toString()),
      ],
    );
  }

  Widget _buildStatChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(icon: Icon(Icons.list), text: 'Devices'),
        Tab(icon: Icon(Icons.info), text: 'Details'),
        Tab(icon: Icon(Icons.history), text: 'History'),
        Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
      ],
    );
  }

  Widget _buildDevicesTab() {
    final filteredDevices = _getFilteredDevices();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredDevices.length,
      itemBuilder: (context, index) {
        final device = filteredDevices[index];
        return _buildDeviceCard(device);
      },
    );
  }

  Widget _buildDeviceCard(IoTDevice device) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getDeviceStatusColor(device.status),
          child: Icon(
            _getDeviceTypeIcon(device.type),
            color: Colors.white,
          ),
        ),
        title: Text(device.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${_getDeviceTypeName(device.type)} • ${device.model}'),
            Text(
              'ID: ${device.id} • ${_getConnectionStatusName(device.status)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                device.isActive ? Icons.power_off : Icons.power,
                color: device.isActive ? Colors.red : Colors.green,
              ),
              onPressed: () => _toggleDevicePower(device),
              tooltip: device.isActive ? 'Turn Off' : 'Turn On',
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleDeviceAction(device, value),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'details',
                  child: ListTile(
                    leading: Icon(Icons.info),
                    title: Text('View Details'),
                    dense: true,
                  ),
                ),
                const PopupMenuItem(
                  value: 'configure',
                  child: ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Configure'),
                    dense: true,
                  ),
                ),
                const PopupMenuItem(
                  value: 'commands',
                  child: ListTile(
                    leading: Icon(Icons.send),
                    title: Text('Send Command'),
                    dense: true,
                  ),
                ),
                const PopupMenuItem(
                  value: 'remove',
                  child: ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Remove'),
                    dense: true,
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () => _showDeviceDetails(device),
      ),
    );
  }

  Widget _buildDeviceDetailsTab() {
    return const Center(
      child: Text('Device Details Tab - Select a device to view details'),
    );
  }

  Widget _buildCommandHistoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _commandHistory.length,
      itemBuilder: (context, index) {
        final command = _commandHistory[index];
        return _buildCommandCard(command);
      },
    );
  }

  Widget _buildCommandCard(IoTCommand command) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCommandStatusColor(command.status),
          child: Icon(
            _getCommandTypeIcon(command.type),
            color: Colors.white,
            size: 16,
          ),
        ),
        title: Text(command.command),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Device: ${command.deviceId}'),
            Text(
              'Sent: ${command.sentAt.toString().substring(0, 19)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getCommandStatusName(command.status),
              style: TextStyle(
                color: _getCommandStatusColor(command.status),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (command.executedAt != null)
              Text(
                'Executed: ${command.executedAt!.toString().substring(0, 19)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        onTap: () => _showCommandDetails(command),
      ),
    );
  }

  Widget _buildDeviceAnalyticsTab() {
    return const Center(
      child: Text('Device Analytics Tab - Charts and metrics will be displayed here'),
    );
  }

  List<IoTDevice> _getFilteredDevices() {
    return _devices.where((device) {
      // Поиск по имени или ID
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!device.name.toLowerCase().contains(query) && !device.id.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Фильтр по типу устройства
      if (_selectedDeviceType != null && device.type != _selectedDeviceType) {
        return false;
      }

      // Фильтр по статусу подключения
      if (_selectedConnectionStatus != null && device.status != _selectedConnectionStatus) {
        return false;
      }

      return true;
    }).toList();
  }

  Color _getDeviceStatusColor(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return Colors.green;
      case ConnectionStatus.disconnected:
        return Colors.red;
      case ConnectionStatus.connecting:
        return Colors.orange;
      case ConnectionStatus.error:
        return Colors.red;
    }
  }

  Color _getCommandStatusColor(CommandStatus status) {
    switch (status) {
      case CommandStatus.pending:
        return Colors.orange;
      case CommandStatus.executed:
        return Colors.green;
      case CommandStatus.failed:
        return Colors.red;
      case CommandStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData _getDeviceTypeIcon(DeviceType type) {
    switch (type) {
      case DeviceType.sensor:
        return Icons.sensors;
      case DeviceType.actuator:
        return Icons.settings_input_component;
      case DeviceType.camera:
        return Icons.camera_alt;
      case DeviceType.gateway:
        return Icons.router;
      case DeviceType.controller:
        return Icons.memory;
    }
  }

  IconData _getCommandTypeIcon(CommandType type) {
    switch (type) {
      case CommandType.read:
        return Icons.read_more;
      case CommandType.write:
        return Icons.edit;
      case CommandType.control:
        return Icons.settings;
      case CommandType.config:
        return Icons.build;
    }
  }

  String _getDeviceTypeName(DeviceType type) {
    switch (type) {
      case DeviceType.sensor:
        return 'Sensor';
      case DeviceType.actuator:
        return 'Actuator';
      case DeviceType.camera:
        return 'Camera';
      case DeviceType.gateway:
        return 'Gateway';
      case DeviceType.controller:
        return 'Controller';
    }
  }

  String _getConnectionStatusName(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return 'Connected';
      case ConnectionStatus.disconnected:
        return 'Disconnected';
      case ConnectionStatus.connecting:
        return 'Connecting';
      case ConnectionStatus.error:
        return 'Error';
    }
  }

  String _getCommandStatusName(CommandStatus status) {
    switch (status) {
      case CommandStatus.pending:
        return 'Pending';
      case CommandStatus.executed:
        return 'Executed';
      case CommandStatus.failed:
        return 'Failed';
      case CommandStatus.cancelled:
        return 'Cancelled';
    }
  }

  Future<void> _toggleDevicePower(IoTDevice device) async {
    try {
      if (device.isActive) {
        await _iotService.disconnectDevice(device.id);
        _showSuccessSnackBar('Device ${device.name} turned off');
      } else {
        await _iotService.connectDevice(device.id);
        _showSuccessSnackBar('Device ${device.name} turned on');
      }
      _loadDevices();
    } catch (e) {
      _showErrorSnackBar('Failed to toggle device power: $e');
    }
  }

  void _handleDeviceAction(IoTDevice device, String action) {
    switch (action) {
      case 'details':
        _showDeviceDetails(device);
      case 'configure':
        _showDeviceConfiguration(device);
      case 'commands':
        _showSendCommandDialog(device);
      case 'remove':
        _removeDevice(device);
    }
  }

  void _showAddDeviceDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddDeviceDialog(
        onDeviceAdded: () {
          _loadDevices();
        },
      ),
    );
  }

  void _showDeviceDetails(IoTDevice device) {
    showDialog(
      context: context,
      builder: (context) => _DeviceDetailsDialog(device: device),
    );
  }

  void _showDeviceConfiguration(IoTDevice device) {
    showDialog(
      context: context,
      builder: (context) => _DeviceConfigurationDialog(device: device),
    );
  }

  void _showSendCommandDialog(IoTDevice device) {
    showDialog(
      context: context,
      builder: (context) => _SendCommandDialog(
        device: device,
        onCommandSent: () {
          _loadDevices();
        },
      ),
    );
  }

  void _showCommandDetails(IoTCommand command) {
    showDialog(
      context: context,
      builder: (context) => _CommandDetailsDialog(command: command),
    );
  }

  void _removeDevice(IoTDevice device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Device'),
        content: Text('Are you sure you want to remove device "${device.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _iotService.removeDevice(device.id);
                _showSuccessSnackBar('Device removed successfully');
                _loadDevices();
              } catch (e) {
                _showErrorSnackBar('Failed to remove device: $e');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _exportDevices() {
    // TODO: Implement device export
    _showInfoSnackBar('Device export started...');
  }

  void _showDeviceSettings() {
    // TODO: Implement device settings
    _showInfoSnackBar('Opening device settings...');
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

// Диалоги для управления устройствами

class _AddDeviceDialog extends StatefulWidget {
  final VoidCallback onDeviceAdded;

  const _AddDeviceDialog({required this.onDeviceAdded});

  @override
  State<_AddDeviceDialog> createState() => _AddDeviceDialogState();
}

class _AddDeviceDialogState extends State<_AddDeviceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _modelController = TextEditingController();
  final _connectionStringController = TextEditingController();

  DeviceType _selectedType = DeviceType.sensor;
  String _selectedProtocol = 'MQTT';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Device'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Device Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter device name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<DeviceType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Device Type',
                  border: OutlineInputBorder(),
                ),
                items: DeviceType.values.map((type) {
                  return DropdownMenuItem<DeviceType>(
                    value: type,
                    child: Text(_getDeviceTypeName(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Model',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter device model';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedProtocol,
                decoration: const InputDecoration(
                  labelText: 'Protocol',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'MQTT', child: Text('MQTT')),
                  DropdownMenuItem(value: 'HTTP', child: Text('HTTP')),
                  DropdownMenuItem(value: 'CoAP', child: Text('CoAP')),
                  DropdownMenuItem(value: 'Modbus', child: Text('Modbus')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedProtocol = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _connectionStringController,
                decoration: const InputDecoration(
                  labelText: 'Connection String',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter connection string';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addDevice,
          child: const Text('Add Device'),
        ),
      ],
    );
  }

  String _getDeviceTypeName(DeviceType type) {
    switch (type) {
      case DeviceType.sensor:
        return 'Sensor';
      case DeviceType.actuator:
        return 'Actuator';
      case DeviceType.camera:
        return 'Camera';
      case DeviceType.gateway:
        return 'Gateway';
      case DeviceType.controller:
        return 'Controller';
    }
  }

  void _addDevice() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement device addition
      Navigator.pop(context);
      widget.onDeviceAdded();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _modelController.dispose();
    _connectionStringController.dispose();
    super.dispose();
  }
}

class _DeviceDetailsDialog extends StatelessWidget {
  final IoTDevice device;

  const _DeviceDetailsDialog({required this.device});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(device.name),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('ID', device.id),
            _buildDetailRow('Type', _getDeviceTypeName(device.type)),
            _buildDetailRow('Model', device.model),
            _buildDetailRow('Status', _getConnectionStatusName(device.status)),
            _buildDetailRow('Active', device.isActive ? 'Yes' : 'No'),
            _buildDetailRow('Last Seen', device.lastSeen.toString()),
            _buildDetailRow('Created', device.createdAt.toString()),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
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

  String _getDeviceTypeName(DeviceType type) {
    switch (type) {
      case DeviceType.sensor:
        return 'Sensor';
      case DeviceType.actuator:
        return 'Actuator';
      case DeviceType.camera:
        return 'Camera';
      case DeviceType.gateway:
        return 'Gateway';
      case DeviceType.controller:
        return 'Controller';
    }
  }

  String _getConnectionStatusName(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return 'Connected';
      case ConnectionStatus.disconnected:
        return 'Disconnected';
      case ConnectionStatus.connecting:
        return 'Connecting';
      case ConnectionStatus.error:
        return 'Error';
    }
  }
}

class _DeviceConfigurationDialog extends StatelessWidget {
  final IoTDevice device;

  const _DeviceConfigurationDialog({required this.device});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Configure ${device.name}'),
      content: const SizedBox(
        width: 400,
        child: Text('Device configuration options will be displayed here.'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            // TODO: Implement device configuration
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _SendCommandDialog extends StatefulWidget {
  final IoTDevice device;
  final VoidCallback onCommandSent;

  const _SendCommandDialog({
    required this.device,
    required this.onCommandSent,
  });

  @override
  State<_SendCommandDialog> createState() => _SendCommandDialogState();
}

class _SendCommandDialogState extends State<_SendCommandDialog> {
  final _formKey = GlobalKey<FormState>();
  final _commandController = TextEditingController();

  CommandType _selectedType = CommandType.control;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Send Command to ${widget.device.name}'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<CommandType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Command Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: CommandType.read, child: Text('Read')),
                  DropdownMenuItem(value: CommandType.write, child: Text('Write')),
                  DropdownMenuItem(value: CommandType.control, child: Text('Control')),
                  DropdownMenuItem(value: CommandType.config, child: Text('Config')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _commandController,
                decoration: const InputDecoration(
                  labelText: 'Command',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter command';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _sendCommand,
          child: const Text('Send'),
        ),
      ],
    );
  }

  void _sendCommand() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement command sending
      Navigator.pop(context);
      widget.onCommandSent();
    }
  }

  @override
  void dispose() {
    _commandController.dispose();
    super.dispose();
  }
}

class _CommandDetailsDialog extends StatelessWidget {
  final IoTCommand command;

  const _CommandDetailsDialog({required this.command});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Command Details'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Command ID', command.id),
            _buildDetailRow('Type', _getCommandTypeName(command.type)),
            _buildDetailRow('Device ID', command.deviceId),
            _buildDetailRow('Status', _getCommandStatusName(command.status)),
            _buildDetailRow('Sent At', command.sentAt.toString()),
            if (command.executedAt != null) _buildDetailRow('Executed At', command.executedAt!.toString()),
            if (command.result != null) _buildDetailRow('Result', command.result!),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
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

  String _getCommandTypeName(CommandType type) {
    switch (type) {
      case CommandType.read:
        return 'Read';
      case CommandType.write:
        return 'Write';
      case CommandType.execute:
        return 'Execute';
      case CommandType.configure:
        return 'Configure';
    }
  }

  String _getCommandStatusName(CommandStatus status) {
    switch (status) {
      case CommandStatus.pending:
        return 'Pending';
      case CommandStatus.executing:
        return 'Executing';
      case CommandStatus.completed:
        return 'Completed';
      case CommandStatus.failed:
        return 'Failed';
    }
  }
}
