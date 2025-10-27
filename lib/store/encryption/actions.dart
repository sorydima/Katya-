import 'package:katya/global/print.dart';
import 'package:katya/services/encryption/encryption_manager.dart';
import 'package:katya/store/index.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

// Action to initialize encryption
class InitializeEncryption {
  final EncryptionManager? encryptionManager;

  InitializeEncryption({this.encryptionManager});
}

// Action to update encryption status
class UpdateEncryptionStatus {
  final bool isEncryptionEnabled;
  final bool isCrossSigningEnabled;
  final bool isKeyBackupEnabled;

  UpdateEncryptionStatus({
    this.isEncryptionEnabled = false,
    this.isCrossSigningEnabled = false,
    this.isKeyBackupEnabled = false,
  });
}

// Thunk to initialize encryption after login
ThunkAction<AppState> initializeEncryption() {
  return (Store<AppState> store) async {
    try {
      final authState = store.state.authStore;
      final client = authState.client;

      if (client == null) {
        throw Exception('Matrix client not initialized');
      }

      // Initialize encryption manager
      final encryptionManager = EncryptionManager(client);
      await encryptionManager.initializeEncryption();

      // Update store with encryption manager
      store.dispatch(InitializeEncryption(encryptionManager: encryptionManager));

      // Get encryption status
      final status = await encryptionManager.getEncryptionStatus();

      // Update encryption status in store
      store.dispatch(UpdateEncryptionStatus(
        isEncryptionEnabled: status['e2eeEnabled'] ?? false,
        isCrossSigningEnabled: status['crossSigning']?['enabled'] ?? false,
        isKeyBackupEnabled: status['keyBackup']?['enabled'] ?? false,
      ));

      log.info('Encryption initialized successfully');
    } catch (error) {
      log.error('Error initializing encryption: $error');
      store.dispatch(UpdateEncryptionStatus());
    }
  };
}

// Thunk to enable key backup
ThunkAction<AppState> enableKeyBackup(String passphrase) {
  return (Store<AppState> store) async {
    try {
      final authState = store.state.authStore;
      final encryptionManager = authState.encryptionManager;

      if (encryptionManager == null) {
        throw Exception('Encryption manager not initialized');
      }

      await encryptionManager.keyBackup.enableBackup(passphrase);

      // Update encryption status
      store.dispatch(UpdateEncryptionStatus(
        isKeyBackupEnabled: true,
      ));

      log.info('Key backup enabled successfully');
    } catch (error) {
      log.error('Error enabling key backup: $error');
      rethrow;
    }
  };
}

// Thunk to verify this device with cross-signing
ThunkAction<AppState> verifyThisDevice() {
  return (Store<AppState> store) async {
    try {
      final authState = store.state.authStore;
      final encryptionManager = authState.encryptionManager;

      if (encryptionManager == null) {
        throw Exception('Encryption manager not initialized');
      }

      await encryptionManager.crossSigning.verifyThisDevice();

      log.info('Device verified with cross-signing');
    } catch (error) {
      log.error('Error verifying device: $error');
      rethrow;
    }
  };
}

// Thunk to get recovery key
ThunkAction<AppState> getRecoveryKey() {
  return (Store<AppState> store) async {
    try {
      final authState = store.state.authStore;
      final encryptionManager = authState.encryptionManager;

      if (encryptionManager == null) {
        throw Exception('Encryption manager not initialized');
      }

      return await encryptionManager.keyBackup.getRecoveryKey();
    } catch (error) {
      log.error('Error getting recovery key: $error');
      rethrow;
    }
  };
}
