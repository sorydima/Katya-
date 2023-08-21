import 'package:katya/domain/index.dart';
import 'package:katya/global/values.dart';

String selectCurrentDeviceName(AppState state) {
  final currentSessionId = state.authStore.user.deviceId;
  final currentUserDevices = state.settingsStore.devices;

  if (currentUserDevices.isEmpty) {
    return Values.UNKNOWN;
  }

  final currentDeviceName = currentUserDevices.firstWhere(
    (device) => device.deviceId == currentSessionId,
    orElse: () => currentUserDevices.first,
  );

  return currentDeviceName.displayName ?? Values.UNKNOWN;
}
