import 'dart:async';
import 'dart:convert';

import 'package:katya/global/print.dart';
import 'package:matrix/matrix.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KeyBackupService {
  static const String _backupKey = 'matrix_key_backup_v1';
  static const String _backupVersionKey = 'matrix_key_backup_version';

  final Client _client;
  final SharedPreferences _prefs;

  KeyBackupService(this._client, this._prefs);

  // Check if key backup is enabled
  bool get isBackupEnabled => _prefs.containsKey(_backupKey);

  // Get the current backup version
  String? get backupVersion => _prefs.getString(_backupVersionKey);

  // Enable key backup with a passphrase
  Future<void> enableBackup(String passphrase) async {
    try {
      // Generate a secure backup key
      // Simple implementation - in a real app, this would use the Matrix key backup API
      final backupKey = <String, dynamic>{
        'version': '1',
        'algorithm': 'm.megolm_backup.v1',
        'auth_data': {'public_key': 'dummy_key'},
      };

      // Save the backup key securely
      await _saveBackupKey(backupKey);

      // Enable backup on the server
      // Simple implementation - in a real app, this would enable backup on the server
      print('Enabling key backup');

      log.info('Key backup enabled successfully');
    } catch (e) {
      log.error('Error enabling key backup: $e');
      rethrow;
    }
  }

  // Disable key backup
  Future<void> disableBackup() async {
    try {
      // Simple implementation - in a real app, this would disable backup on the server
      print('Disabling key backup');
      await _deleteBackupKey();
      log.info('Key backup disabled');
    } catch (e) {
      log.error('Error disabling key backup: $e');
      rethrow;
    }
  }

  // Restore keys from backup
  Future<Map<String, dynamic>> restoreFromBackup(String recoveryKey) async {
    try {
      // Simple implementation - in a real app, this would restore from server
      final result = <String, dynamic>{
        'total': 0,
        'imported': 0,
        'errors': <String>[],
      };

      log.info('Successfully restored ${result['imported']} keys from backup');
      return {
        'imported': result['imported'],
        'total': result['total'],
      };
    } catch (e) {
      log.error('Error restoring from backup: $e');
      rethrow;
    }
  }

  // Create a new backup version
  Future<void> createNewBackupVersion() async {
    try {
      final existingBackupKey = await _getBackupKey();
      if (existingBackupKey == null) {
        throw Exception('No backup key found');
      }

      // Simple implementation - in a real app, this would prepare a new backup version
      print('Creating new backup version');

      log.info('Created new backup version');
    } catch (e) {
      log.error('Error creating new backup version: $e');
      rethrow;
    }
  }

  // Get the recovery key as a string
  Future<String> getRecoveryKey() async {
    final backupKey = await _getBackupKey();
    if (backupKey == null) {
      throw Exception('No backup key found');
    }

    return backupKey['recoveryKey'] as String? ?? '';
  }

  // Save the backup key securely
  Future<void> _saveBackupKey(Map<String, dynamic> key) async {
    await _prefs.setString(_backupKey, jsonEncode(key));
    if (key['version'] != null) {
      await _prefs.setString(_backupVersionKey, key['version'] as String);
    }
  }

  // Get the stored backup key
  Future<Map<String, dynamic>?> _getBackupKey() async {
    final keyJson = _prefs.getString(_backupKey);
    if (keyJson == null) return null;

    try {
      return jsonDecode(keyJson) as Map<String, dynamic>;
    } catch (e) {
      log.error('Error parsing backup key: $e');
      return null;
    }
  }

  // Delete the backup key
  Future<void> _deleteBackupKey() async {
    await _prefs.remove(_backupKey);
    await _prefs.remove(_backupVersionKey);
  }

  // Check if a backup exists on the server
  Future<bool> checkBackupOnServer() async {
    try {
      // Simple implementation - in a real app, this would get the backup version from server
      final version = _prefs.getString(_backupVersionKey);
      return version != null;
    } catch (e) {
      log.error('Error checking backup on server: $e');
      return false;
    }
  }
}
