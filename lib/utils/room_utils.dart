import 'package:katya/models/token_gate_config.dart';
import 'package:katya/models/token_gate_type.dart';
import 'package:katya/services/token_gate_service.dart';
import 'package:katya/store/rooms/room/model.dart';

/// Checks if a user has access to a room based on token gate configuration
/// Returns true if access is granted, false otherwise
Future<bool> checkRoomAccess({
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

/// Gets the token gate error message for a room
String getTokenGateErrorMessage(TokenGateConfig? config) {
  if (config == null || !config.isEnabled) {
    return '';
  }

  switch (config.type) {
    case TokenGateType.nft:
      return config.customMessage ?? 
          'This room requires a specific NFT to join.';
    case TokenGateType.token:
      return config.customMessage ?? 
          'This room requires a minimum token balance to join.';
    case TokenGateType.premium:
      return config.customMessage ?? 
          'This is a premium room. Please upgrade your account to join.';
    default:
      return 'This room has restricted access.';
  }
}
