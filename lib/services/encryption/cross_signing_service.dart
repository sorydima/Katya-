import 'dart:async';
import 'dart:convert';

import 'package:katya/global/print.dart';
import 'package:matrix/matrix.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CrossSigningService {
  static const String _crossSigningKey = 'matrix_cross_signing_keys';

  final Client _client;
  final SharedPreferences _prefs;

  CrossSigningService(this._client, this._prefs);

  // Check if cross-signing is enabled
  bool get isCrossSigningEnabled {
    // TODO: Update to use new Matrix SDK API
    return _client.encryption?.crossSigning.enabled ?? false;
  }

  // Initialize cross-signing
  Future<void> initializeCrossSigning() async {
    try {
      if (isCrossSigningEnabled) {
        log.info('Cross-signing is already enabled');
        return;
      }

      log.info('Initializing cross-signing...');

      // First, check if we have cross-signing keys stored
      final storedKeys = await _getStoredCrossSigningKeys();

      // TODO: Update to use new Matrix SDK API
      // Cross-signing initialization has changed in newer Matrix SDK versions
      if (storedKeys != null) {
        log.info('Stored keys found but enableWithStoredKeys() is deprecated');
      } else {
        log.info('Cross-signing enable() is deprecated');
      }

      // Store the keys for future use
      await _storeCrossSigningKeys();

      log.info('Cross-signing initialized successfully');
    } catch (e) {
      log.error('Error initializing cross-signing: $e');
      rethrow;
    }
  }

  // Verify this device with cross-signing
  Future<void> verifyThisDevice() async {
    try {
      if (!isCrossSigningEnabled) {
        throw Exception('Cross-signing is not enabled');
      }

      // TODO: Update to use new Matrix SDK API
      // The signUser() method has been deprecated
      throw UnimplementedError('Cross-signing API has changed. Please update implementation.');
    } catch (e) {
      log.error('Error verifying this device: $e');
      rethrow;
    }
  }

  // Verify another user's device
  Future<void> verifyDevice(String userId, String deviceId) async {
    try {
      if (!isCrossSigningEnabled) {
        throw Exception('Cross-signing is not enabled');
      }

      // TODO: Update to use new Matrix SDK API
      throw UnimplementedError('Cross-signing verifyDevice API has changed.');
    } catch (e) {
      log.error('Error verifying device: $e');
      rethrow;
    }
  }

  // Get the cross-signing keys for this device
  Future<Map<String, dynamic>?> _getStoredCrossSigningKeys() async {
    try {
      final keysJson = _prefs.getString(_crossSigningKey);
      if (keysJson == null) return null;

      return jsonDecode(keysJson) as Map<String, dynamic>?;
    } catch (e) {
      log.error('Error getting stored cross-signing keys: $e');
      return null;
    }
  }

  // Store the cross-signing keys
  Future<void> _storeCrossSigningKeys() async {
    try {
      // TODO: Update to use new Matrix SDK API
      log.info('Cross-signing keys storage not implemented');
    } catch (e) {
      log.error('Error storing cross-signing keys: $e');
      rethrow;
    }
  }

  // Reset cross-signing (for testing/debugging)
  Future<void> resetCrossSigning() async {
    try {
      // TODO: Update to use new Matrix SDK API
      await _prefs.remove(_crossSigningKey);
      log.info('Cross-signing reset (partial)');
    } catch (e) {
      log.error('Error resetting cross-signing: $e');
      rethrow;
    }
  }

  // Check if a device is verified
  Future<bool> isDeviceVerified(String userId, String deviceId) async {
    try {
      if (!isCrossSigningEnabled) {
        return false;
      }

      // TODO: Update to use new Matrix SDK API
      return false;
    } catch (e) {
      log.error('Error checking device verification status: $e');
      return false;
    }
  }

  // Get the cross-signing status
  Future<Map<String, dynamic>> getCrossSigningStatus() async {
    try {
      final status = <String, dynamic>{
        'enabled': isCrossSigningEnabled,
        'thisDeviceVerified': false,
        'keysStored': await _getStoredCrossSigningKeys() != null,
      };

      if (isCrossSigningEnabled && _client.userID != null) {
        // TODO: Update to use new Matrix SDK API
        status['thisDeviceVerified'] = false;
      }

      return status;
    } catch (e) {
      log.error('Error getting cross-signing status: $e');
      return {'error': e.toString()};
    }
  }
}
