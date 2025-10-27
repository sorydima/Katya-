import 'dart:async';

import 'package:katya/global/print.dart';
import 'package:katya/services/encryption/cross_signing_service.dart';
import 'package:katya/services/encryption/key_backup_service.dart';
import 'package:matrix/matrix.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EncryptionManager {
  final Client _client;
  late final KeyBackupService _keyBackupService;
  late final CrossSigningService _crossSigningService;

  final _initialized = Completer<void>();

  // Getters
  KeyBackupService get keyBackup => _keyBackupService;
  CrossSigningService get crossSigning => _crossSigningService;
  Future<void> get initialized => _initialized.future;

  EncryptionManager(this._client) {
    _init();
  }

  Future<void> _init() async {
    try {
      // Initialize shared preferences
      final prefs = await SharedPreferences.getInstance();

      // Initialize services
      _keyBackupService = KeyBackupService(_client, prefs);
      _crossSigningService = CrossSigningService(_client, prefs);

      log.info('EncryptionManager initialized');
      _initialized.complete();
    } catch (e) {
      log.error('Error initializing EncryptionManager: $e');
      _initialized.completeError(e);
    }
  }

  // Initialize encryption features
  Future<void> initializeEncryption() async {
    try {
      await initialized;

      // Initialize cross-signing
      if (!_crossSigningService.isCrossSigningEnabled) {
        log.info('Setting up cross-signing...');
        await _crossSigningService.initializeCrossSigning();
      }

      // Check key backup status
      final hasBackup = await _keyBackupService.checkBackupOnServer();
      if (!hasBackup) {
        log.info('Key backup not found on server. A new backup should be created.');
      }

      log.info('Encryption features initialized');
    } catch (e) {
      log.error('Error initializing encryption features: $e');
      rethrow;
    }
  }

  // Get the overall encryption status
  Future<Map<String, dynamic>> getEncryptionStatus() async {
    try {
      await initialized;

      final crossSigningStatus = await _crossSigningService.getCrossSigningStatus();
      final backupStatus = {
        'enabled': _keyBackupService.isBackupEnabled,
        'version': _keyBackupService.backupVersion,
      };

      return {
        'crossSigning': crossSigningStatus,
        'keyBackup': backupStatus,
        'e2eeEnabled': _client.encryption?.enabled ?? false,
      };
    } catch (e) {
      log.error('Error getting encryption status: $e');
      return {'error': e.toString()};
    }
  }

  // Reset all encryption data (for testing/debugging)
  Future<void> resetEncryption() async {
    try {
      await initialized;

      log.warn('Resetting all encryption data...');

      // Disable key backup
      if (_keyBackupService.isBackupEnabled) {
        await _keyBackupService.disableBackup();
      }

      // Reset cross-signing
      await _crossSigningService.resetCrossSigning();

      log.info('Encryption data reset complete');
    } catch (e) {
      log.error('Error resetting encryption: $e');
      rethrow;
    }
  }
}
