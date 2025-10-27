import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:provider/provider.dart';

import '../../../matrix/matrix_client.dart';
import '../../verification/screens/verification_screen.dart';
import '../widgets/device_tile.dart';

class DeviceVerificationScreen extends StatefulWidget {
  final String userId;

  const DeviceVerificationScreen({
    super.key,
    required this.userId,
  });

  @override
  _DeviceVerificationScreenState createState() => _DeviceVerificationScreenState();
}

class _DeviceVerificationScreenState extends State<DeviceVerificationScreen> {
  bool _isLoading = true;
  List<matrix.Device> _devices = [];
  final Set<String> _verifyingDevices = {};

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() => _isLoading = true);

    try {
      final client = context.read<MatrixClient>();
      final devices = await client.getDevices(widget.userId);

      if (mounted) {
        setState(() {
          _devices = devices;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load devices: $e')),
        );
      }
    }
  }

  Future<void> _verifyDevice(matrix.Device device) async {
    if (_verifyingDevices.contains(device.deviceId)) return;

    setState(() => _verifyingDevices.add(device.deviceId));

    try {
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => VerificationScreen(
            otherUserId: widget.userId,
            otherDeviceId: device.deviceId,
          ),
        ),
      );

      if (result == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Device verified successfully!')),
        );

        // Refresh the device list
        await _loadDevices();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _verifyingDevices.remove(device.deviceId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Devices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadDevices,
          ),
        ],
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : _buildDeviceList(),
    );
  }

  Widget _buildDeviceList() {
    if (_devices.isEmpty) {
      return const Center(
        child: Text('No devices found'),
      );
    }

    return ListView.builder(
      itemCount: _devices.length,
      itemBuilder: (context, index) {
        final device = _devices[index];
        final isVerifying = _verifyingDevices.contains(device.deviceId);

        return DeviceTile(
          device: device,
          isVerifying: isVerifying,
          onVerify: () => _verifyDevice(device),
        );
      },
    );
  }
}
