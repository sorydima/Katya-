import 'package:katya/services/token_gate_service.dart';
import 'package:katya/store/rooms/room/model.dart';

/// Checks if a user has access to a room based on token gate configuration
Future<bool> checkTokenGateAccess({
  required Room room,
  required String? userId,
  required TokenGateService tokenGateService,
}) async {
  // If no token gate is configured, allow access
  if (room.tokenGateConfig == null || !room.tokenGateConfig!.isEnabled) {
    return true;
  }

  // TODO: Implement power levels check
  // If user is a room admin/moderator, bypass token gate
  // if (room.userPowerLevels?.isUserAdmin(userId) ?? false) {
  //   return true;
  // }

  // Check token gate access
  try {
    final hasAccess = await tokenGateService.checkAccess(
      address: userId ?? '',
      config: room.tokenGateConfig!,
    );

    return hasAccess;
  } catch (e) {
    // If there's an error checking access, default to denying access
    return false;
  }
}
