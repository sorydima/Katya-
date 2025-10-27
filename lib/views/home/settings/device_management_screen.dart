import 'package:flutter/material.dart';
import 'package:katya/views/widgets/appbars/appbar-normal.dart';
import 'package:katya/views/widgets/containers/card-section.dart';
import 'package:katya/views/widgets/dialogs/dialog-rounded.dart';

class DeviceManagementScreen extends StatelessWidget {
  const DeviceManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarNormal(
        title: 'Device Management',
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildCurrentDeviceSection(context),
            const SizedBox(height: 16),
            _buildOtherDevicesSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentDeviceSection(BuildContext context) {
    return CardSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This Device',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.phone_android),
            title: const Text('Samsung Galaxy S21'),
            subtitle: Text(
              'Last active: Just now\nIP: 192.168.1.5',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Device Information'),
            subtitle: const Text('View detailed information about this device'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showDeviceInfoDialog(context, isCurrent: true),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherDevicesSection(BuildContext context) {
    return CardSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Active Sessions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'These devices are currently signed in to your account.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          _buildDeviceTile(
            context,
            icon: Icons.phone_android,
            name: 'iPhone 13 Pro',
            model: 'Apple iPhone 13 Pro',
            lastActive: '2 hours ago',
            location: 'New York, NY',
            ip: '192.168.1.10',
            isCurrent: false,
          ),
          const Divider(),
          _buildDeviceTile(
            context,
            icon: Icons.computer,
            name: 'MacBook Pro',
            model: 'Apple MacBook Pro (16", 2021)',
            lastActive: '1 day ago',
            location: 'San Francisco, CA',
            ip: '192.168.1.15',
            isCurrent: false,
          ),
          const Divider(),
          _buildDeviceTile(
            context,
            icon: Icons.tablet_android,
            name: 'iPad Pro',
            model: 'Apple iPad Pro (12.9", 2021)',
            lastActive: '1 week ago',
            location: 'London, UK',
            ip: '192.168.1.20',
            isCurrent: false,
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {
                // TODO: Show all devices
              },
              child: const Text('View All Devices'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceTile(
    BuildContext context, {
    required IconData icon,
    required String name,
    required String model,
    required String lastActive,
    required String location,
    required String ip,
    required bool isCurrent,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(model),
          Text(
            'Last active: $lastActive\nLocation: $location\nIP: $ip',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      trailing: isCurrent
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'This device',
                style: TextStyle(color: Colors.green, fontSize: 12),
              ),
            )
          : PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'sign_out') {
                  _showSignOutConfirmation(context, name);
                } else if (value == 'info') {
                  _showDeviceInfoDialog(context, isCurrent: false);
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'info',
                  child: Text('View Details'),
                ),
                const PopupMenuItem(
                  value: 'sign_out',
                  child: Text('Sign Out'),
                ),
              ],
            ),
    );
  }

  void _showDeviceInfoDialog(BuildContext context, {required bool isCurrent}) {
    showDialog(
      context: context,
      builder: (context) => DialogRounded(
        title: 'Device Information',
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isCurrent) ...[
                  const Text(
                    'Device Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text('iPhone 13 Pro\n'),
                ],
                const Text(
                  'Device ID',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SelectableText('a1b2c3d4e5f6g7h8\n'),
                const Text(
                  'Device Model',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text('Apple iPhone 13 Pro\n'),
                const Text(
                  'Operating System',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text('iOS 15.4.1\n'),
                const Text(
                  'App Version',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text('Katya 1.0.0\n'),
                const Text(
                  'Last Active',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text('2 hours ago\n'),
                const Text(
                  'IP Address',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text('192.168.1.10\n'),
                const Text(
                  'Approximate Location',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text('New York, NY, USA\n'),
                if (!isCurrent) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        foregroundColor: Colors.red,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _showSignOutConfirmation(context, 'iPhone 13 Pro');
                      },
                      child: const Text('Sign Out This Device'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSignOutConfirmation(BuildContext context, String deviceName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out Device'),
        content: Text('Are you sure you want to sign out of $deviceName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Sign out the device
              Navigator.pop(context);
              _showSignOutSuccess(context, deviceName);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showSignOutSuccess(BuildContext context, String deviceName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully signed out of $deviceName'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
