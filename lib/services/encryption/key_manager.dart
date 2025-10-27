import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:katya/global/print.dart';
import 'package:matrix/matrix.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KeyManager {
  static final KeyManager _instance = KeyManager._internal();
  late SharedPreferences _prefs;

  // Cross-signing keys
  String? _masterKey;
  String? _selfSigningKey;
  String? _userSigningKey;

  // Singleton pattern
  factory KeyManager() {
    return _instance;
  }

  KeyManager._internal();

  // Initialize the key manager
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadKeys();
  }

  // Load keys from secure storage
  Future<void> _loadKeys() async {
    _masterKey = _prefs.getString('master_key');
    _selfSigningKey = _prefs.getString('self_signing_key');
    _userSigningKey = _prefs.getString('user_signing_key');
  }

  // Generate new cross-signing keys
  Future<Map<String, String>> generateCrossSigningKeys() async {
    try {
      // Generate new keys
      _masterKey = _generateKey();
      _selfSigningKey = _generateKey();
      _userSigningKey = _generateKey();

      // Save keys to secure storage
      await _saveKeys();

      return {
        'master_key': _masterKey!,
        'self_signing_key': _selfSigningKey!,
        'user_signing_key': _userSigningKey!,
      };
    } catch (e) {
      log.error('Error generating cross-signing keys: $e');
      rethrow;
    }
  }

  // Generate a secure random key
  String _generateKey() {
    final random = Uint8List(32);
    final randomBytes = Random.secure();
    random.fillRange(0, 32, randomBytes.nextInt(256));
    return base64Url.encode(random);
  }

  // Save keys to secure storage
  Future<void> _saveKeys() async {
    await Future.wait([
      if (_masterKey != null) _prefs.setString('master_key', _masterKey!) else Future.value(),
      if (_selfSigningKey != null) _prefs.setString('self_signing_key', _selfSigningKey!) else Future.value(),
      if (_userSigningKey != null) _prefs.setString('user_signing_key', _userSigningKey!) else Future.value(),
    ]);
  }

  // Verify device with cross-signing
  Future<bool> verifyDevice(String userId, String deviceId, String masterKey) async {
    try {
      // TODO: Implement device verification logic
      // This would involve checking the device's key against the master key
      return true;
    } catch (e) {
      log.error('Error verifying device: $e');
      return false;
    }
  }

  // Check if cross-signing is set up
  bool get isCrossSigningEnabled => _masterKey != null && _selfSigningKey != null && _userSigningKey != null;

  // Get cross-signing keys
  Map<String, String?> get crossSigningKeys => {
        'master_key': _masterKey,
        'self_signing_key': _selfSigningKey,
        'user_signing_key': _userSigningKey,
      };

  // Clear all keys (for testing/logout)
  Future<void> clearKeys() async {
    await Future.wait([
      _prefs.remove('master_key'),
      _prefs.remove('self_signing_key'),
      _prefs.remove('user_signing_key'),
    ]);
    _masterKey = null;
    _selfSigningKey = null;
    _userSigningKey = null;
  }
}

// Extension to handle key backup
class KeyBackupManager {
  final Client client;

  KeyBackupManager(this.client);

  // Create a new key backup
  Future<void> createKeyBackup() async {
    try {
      await client.encryption!.keyVerification.request(
        'm.megolm_backup.v1',
        methods: ['m.sas.v1'],
      );

      // TODO: Implement key backup creation
    } catch (e) {
      log.error('Error creating key backup: $e');
      rethrow;
    }
  }

  // Restore keys from backup
  Future<bool> restoreFromBackup(String recoveryKey) async {
    try {
      // TODO: Implement key restoration
      return true;
    } catch (e) {
      log.error('Error restoring from backup: $e');
      return false;
    }
  }
}
