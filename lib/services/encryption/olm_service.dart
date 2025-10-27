import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:katya/global/print.dart';
import 'package:katya/store/auth/actions.dart';
import 'package:matrix/encryption.dart';
import 'package:matrix/matrix.dart';
import 'package:olm/olm.dart' as olm;
import 'package:shared_preferences/shared_preferences.dart';

class OlmService {
  static final OlmService _instance = OlmService._internal();
  late Client _client;
  late String _userId;
  late String _deviceId;
  late String _homeserverUrl;
  late String _accessToken;
  late olm.Account _olmAccount;
  late olm.OutboundGroupSession _outboundGroupSession;

  // Singleton pattern
  factory OlmService() {
    return _instance;
  }

  OlmService._internal();

  // Initialize the Olm service
  Future<void> initialize({
    required String userId,
    required String deviceId,
    required String homeserverUrl,
    required String accessToken,
  }) async {
    _userId = userId;
    _deviceId = deviceId;
    _homeserverUrl = homeserverUrl;
    _accessToken = accessToken;

    // Initialize Olm
    await olm.init();
    olm.get_library_version();

    // Load or create Olm account
    await _loadOrCreateAccount();

    // Initialize Matrix client
    _client = Client(
      'Katya',
      databaseBuilder: (client) async {
        return HiveCollectionsDatabase.databaseFactory('katya_encryption');
      },
    );

    await _client.init(
      userId: _userId,
      accessToken: _accessToken,
      homeserver: Uri.parse(_homeserverUrl),
      deviceId: _deviceId,
    );

    // Enable E2EE
    await _client.encryption!.enable();

    // Upload device keys
    await _client.encryption!.crossSigning.enable();

    log.info('OlmService initialized for user: $_userId');
  }

  // Load or create Olm account
  Future<void> _loadOrCreateAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final accountKey = 'olm_account_${_userId}_$_deviceId';

    if (prefs.containsKey(accountKey)) {
      // Load existing account
      final accountData = prefs.getString(accountKey)!;
      _olmAccount = olm.Account.fromJson(accountData);
    } else {
      // Create new account
      _olmAccount = olm.Account();
      _olmAccount.generate_one_time_keys(50);
      _olmAccount.generate_fallback_key();

      // Save account
      await prefs.setString(accountKey, _olmAccount.pickle(''));
    }

    // Initialize outbound group session
    _outboundGroupSession = olm.OutboundGroupSession();
    _outboundGroupSession.create();
  }

  // Encrypt a message for a room
  Future<String> encryptMessage(String roomId, String message) async {
    try {
      final room = _client.getRoomById(roomId);
      if (room == null) {
        throw Exception('Room not found: $roomId');
      }

      // Get the room's encryption settings
      final encryption = room.encrypted ? room.encryption : null;
      if (encryption == null) {
        // Room is not encrypted, return plaintext
        return message;
      }

      // Encrypt the message
      final event = await _client.encryption!.encryptMessage(
        roomId,
        {
          'msgtype': 'm.text',
          'body': message,
        },
      );

      return jsonEncode(event.content);
    } catch (e) {
      log.error('Error encrypting message: $e');
      rethrow;
    }
  }

  // Decrypt an encrypted message
  Future<String> decryptMessage(String roomId, Map<String, dynamic> encryptedContent) async {
    try {
      final room = _client.getRoomById(roomId);
      if (room == null) {
        throw Exception('Room not found: $roomId');
      }

      // Try to decrypt the message
      final decrypted = await _client.encryption!.decryptMessage(
        roomId,
        encryptedContent,
      );

      return decrypted['body'] ?? '';
    } catch (e) {
      log.error('Error decrypting message: $e');
      rethrow;
    }
  }

  // Get the current device's identity keys
  Map<String, String> getIdentityKeys() {
    return {
      'ed25519': _olmAccount.identity_keys['ed25519']!,
      'curve25519': _olmAccount.identity_keys['curve25519']!,
    };
  }

  // Get one-time keys for key exchange
  Map<String, dynamic> getOneTimeKeys() {
    return _olmAccount.one_time_keys;
  }

  // Handle incoming pre-key messages
  Future<void> handlePreKeyMessage(String message) async {
    // TODO: Implement pre-key message handling
  }

  // Clean up resources
  void dispose() {
    _olmAccount.free();
    _outboundGroupSession.free();
    _client.dispose();
  }
}
