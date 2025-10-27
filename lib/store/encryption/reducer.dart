import 'package:katya/store/encryption/actions.dart';
import 'package:katya/store/encryption/state.dart';

EncryptionState encryptionReducer(
  EncryptionState state,
  dynamic action,
) {
  if (action is InitializeEncryption) {
    return state.copyWith(
      encryptionManager: action.encryptionManager,
    );
  }

  if (action is UpdateEncryptionStatus) {
    return state.copyWith(
      isEncryptionEnabled: action.isEncryptionEnabled,
      isCrossSigningEnabled: action.isCrossSigningEnabled,
      isKeyBackupEnabled: action.isKeyBackupEnabled,
    );
  }

  return state;
}
