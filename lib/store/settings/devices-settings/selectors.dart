import 'package:redux/redux.dart';
import 'package:katya/global/values.dart';
import 'package:katya/store/index.dart';

String selectCurrentDeviceName(Store<AppState> store) {
  final currentSessionId = store.state.authStore.user.deviceId;
  final currentUserDevices = store.state.settingsStore.devices;

  if (currentUserDevices.isEmpty) {
    return Values.UNKNOWN;
  }

  final currentDeviceName = currentUserDevices.firstWhere(
    (device) => device.deviceId == currentSessionId,
    orElse: () => currentUserDevices.first,
  );

  return currentDeviceName.displayName ?? Values.UNKNOWN;
}
