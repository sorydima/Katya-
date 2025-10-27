import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:katya/global/print.dart';
import 'package:katya/store/auth/actions.dart';
import 'package:katya/store/index.dart';
import 'package:katya/store/room/room.dart';
import 'package:katya/store/room/state.dart';
import 'package:katya/store/room/timeline.dart';
import 'package:katya/store/room/typing.dart';
import 'package:katya/store/room/typing/typing.dart';
import 'package:katya/store/room/typing/typing_notifier.dart';
import 'package:katya/store/room/typing/typing_timer.dart';
import 'package:katya/store/room/typing/typing_timer_manager.dart';
import 'package:matrix/matrix.dart';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();

  // Services
  late Client _client;
  late final OlmService _olmService;
  late final KeyManager _keyManager;

  // State
  bool _isInitialized = false;
  final Map<String, bool> _encryptionEnabled = {};

  // Singleton pattern
  factory EncryptionService() {
    return _instance;
  }

  EncryptionService._internal() {
    _olmService = OlmService();
    _keyManager = KeyManager();
  }

  // Getters
  bool get isInitialized => _isInitialized;
  bool isEncryptionEnabled(String roomId) => _encryptionEnabled[roomId] ?? false;

  // Initialize the encryption service
  Future<void> initialize({
    required String userId,
    required String deviceId,
    required String homeserverUrl,
    required String accessToken,
  }) async {
    if (_isInitialized) return;

    try {
      // Initialize Olm service
      await _olmService.initialize(
        userId: userId,
        deviceId: deviceId,
        homeserverUrl: homeserverUrl,
        accessToken: accessToken,
      );

      // Initialize key manager
      await _keyManager.initialize();

      // Set up cross-signing if not already set up
      if (!_keyManager.isCrossSigningEnabled) {
        await _keyManager.generateCrossSigningKeys();
      }

      _isInitialized = true;
      log.info('EncryptionService initialized');
    } catch (e) {
      log.error('Error initializing EncryptionService: $e');
      rethrow;
    }
  }

  // Enable encryption for a room
  Future<void> enableEncryption(String roomId, {bool force = false}) async {
    if (_encryptionEnabled[roomId] == true && !force) return;

    try {
      // TODO: Implement room encryption enablement
      // This would involve setting up megolm sessions, etc.

      _encryptionEnabled[roomId] = true;
      log.info('Encryption enabled for room: $roomId');
    } catch (e) {
      log.error('Error enabling encryption for room $roomId: $e');
      rethrow;
    }
  }

  // Encrypt a message for a room
  Future<Map<String, dynamic>> encryptMessage(String roomId, String message) async {
    try {
      if (!_encryptionEnabled[roomId] ?? false) {
        // Return plaintext if encryption is not enabled for this room
        return {
          'msgtype': 'm.text',
          'body': message,
        };
      }

      // Encrypt the message
      final encrypted = await _olmService.encryptMessage(roomId, message);
      return jsonDecode(encrypted);
    } catch (e) {
      log.error('Error encrypting message: $e');
      rethrow;
    }
  }

  // Decrypt an encrypted message
  Future<String> decryptMessage(String roomId, Map<String, dynamic> encrypted) async {
    try {
      if (!_encryptionEnabled[roomId] ?? false) {
        // Return as-is if encryption is not enabled for this room
        return encrypted['body'] ?? '';
      }

      // Decrypt the message
      return await _olmService.decryptMessage(roomId, encrypted);
    } catch (e) {
      log.error('Error decrypting message: $e');
      return '[Unable to decrypt message]';
    }
  }

  // Handle incoming encrypted events
  Future<void> handleEncryptedEvent(String roomId, Map<String, dynamic> event) async {
    try {
      if (!_encryptionEnabled[roomId] ?? false) {
        log.warn('Received encrypted event in non-encrypted room: $roomId');
        return;
      }

      // TODO: Handle different types of encrypted events
      // This would include handling m.room.encrypted events, key requests, etc.
    } catch (e) {
      log.error('Error handling encrypted event: $e');
    }
  }

  // Verify a user's device
  Future<bool> verifyDevice(String userId, String deviceId) async {
    try {
      // TODO: Implement device verification
      // This would involve checking the device's keys against the user's master key
      return true;
    } catch (e) {
      log.error('Error verifying device: $e');
      return false;
    }
  }

  // Request verification for a user
  Future<void> requestVerification(String userId) async {
    try {
      // TODO: Implement verification request
      // This would involve starting a verification request with the user
    } catch (e) {
      log.error('Error requesting verification: $e');
      rethrow;
    }
  }

  // Clean up resources
  void dispose() {
    _olmService.dispose();
    _isInitialized = false;
    _encryptionEnabled.clear();
  }
}
