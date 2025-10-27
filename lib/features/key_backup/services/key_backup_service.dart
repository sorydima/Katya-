import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:pointycastle/export.dart';
import 'package:uuid/uuid.dart';

import '../../../crypto/secure_storage.dart';
import '../../../utils/crypto_utils.dart';

/// Service for handling secure key backups
///
/// Implements MSC1210 (Secure Key Backup) for backing up and restoring
/// encryption keys used for end-to-end encryption.
class KeyBackupService {
  static const String _storageKeyPrefix = 'key_backup_';
  static const String _backupKeyKey = '${_storageKeyPrefix}backup_key';
  static const String _backupVersionKey = '${_storageKeyPrefix}version';
  static const String _recoveryKeyKey = '${_storageKeyPrefix}recovery_key';

  final SecureStorage _secureStorage;
  final matrix.Client _client;
  final Logger _logger = Logger('KeyBackupService');

  /// The current backup version, if any
  String? _currentVersion;

  /// The backup encryption key
  Uint8List? _backupKey;

  /// Whether the backup is enabled
  bool _isEnabled = false;

  /// Whether the backup is trusted
  bool _isTrusted = false;

  /// Get whether the backup is enabled
  bool get isEnabled => _isEnabled;

  /// Get whether the backup is trusted
  bool get isTrusted => _isTrusted;

  /// Get the current backup version
  String? get currentVersion => _currentVersion;

  /// Create a new KeyBackupService
  KeyBackupService(this._client, this._secureStorage);

  /// Initialize the key backup service
  Future<void> initialize() async {
    try {
      // Load the backup key from secure storage
      final backupKeyBase64 = await _secureStorage.read(_backupKeyKey);
      if (backupKeyBase64 != null) {
        _backupKey = base64.decode(backupKeyBase64);
        _isEnabled = true;

        // Check if we have a recovery key
        final recoveryKey = await _secureStorage.read(_recoveryKeyKey);
        _isTrusted = recoveryKey != null;
      }

      // Check for existing backup on the server
      await _checkServerBackup();

      _logger.info('Key backup service initialized');
    } catch (e, stackTrace) {
      _logger.severe('Failed to initialize key backup service', e, stackTrace);
      rethrow;
    }
  }

  /// Enable key backup with a new passphrase
  ///
  /// This will generate a new backup key and upload it to the server.
  /// The passphrase is used to encrypt the backup key.
  Future<void> enableWithPassphrase(String passphrase) async {
    _logger.info('Enabling key backup with passphrase');

    try {
      // Generate a new backup key
      _backupKey = await _generateBackupKey();

      // Derive a key from the passphrase
      final salt = await _generateSalt();
      final key = await _deriveKey(passphrase, salt);

      // Encrypt the backup key
      final encryptedKey = await _encryptBackupKey(_backupKey!, key);

      // Generate a recovery key
      final recoveryKey = _generateRecoveryKey();

      // Create the backup version
      final version = await _createBackupVersion(
        algorithm: 'm.megolm_backup.v1.curve25519-aes-sha2',
        authData: {
          'public_key': base64.encode(_backupKey!),
          'private_key_encrypted': encryptedKey,
          'private_key_salt': base64.encode(salt),
          'private_key_iterations': 500000,
        },
      );

      // Save the recovery key
      await _secureStorage.write(_recoveryKeyKey, recoveryKey);

      // Update state
      _isEnabled = true;
      _isTrusted = true;
      _currentVersion = version;

      _logger.info('Key backup enabled with passphrase');
    } catch (e, stackTrace) {
      _logger.severe('Failed to enable key backup with passphrase', e, stackTrace);
      rethrow;
    }
  }

  /// Enable key backup with an existing recovery key
  ///
  /// This will use the provided recovery key to decrypt the backup key
  /// from the server.
  Future<void> enableWithRecoveryKey(String recoveryKey) async {
    _logger.info('Enabling key backup with recovery key');

    try {
      // Get the backup version from the server
      final version = await _getServerBackupVersion();
      if (version == null) {
        throw Exception('No backup found on server');
      }

      // Decode the recovery key
      final keyData = _decodeRecoveryKey(recoveryKey);

      // Decrypt the backup key
      _backupKey = await _decryptBackupKey(
        base64.decode(version.authData['private_key_encrypted']),
        keyData['privateKey'],
      );

      // Verify the backup key
      if (base64.encode(_backupKey!) != version.authData['public_key']) {
        throw Exception('Invalid recovery key');
      }

      // Save the recovery key
      await _secureStorage.write(_backupKeyKey, base64.encode(_backupKey!));
      await _secureStorage.write(_recoveryKeyKey, recoveryKey);

      // Update state
      _isEnabled = true;
      _isTrusted = true;
      _currentVersion = version.version;

      _logger.info('Key backup enabled with recovery key');
    } catch (e, stackTrace) {
      _logger.severe('Failed to enable key backup with recovery key', e, stackTrace);
      rethrow;
    }
  }

  /// Disable key backup
  ///
  /// This will remove the backup key from local storage and delete the backup
  /// from the server.
  Future<void> disable() async {
    _logger.info('Disabling key backup');

    try {
      // Delete the backup from the server
      if (_currentVersion != null) {
        await _client.deleteBackupVersion(_currentVersion!);
      }

      // Clear local state
      await _secureStorage.delete(_backupKeyKey);
      await _secureStorage.delete(_recoveryKeyKey);
      await _secureStorage.delete(_backupVersionKey);

      _backupKey = null;
      _currentVersion = null;
      _isEnabled = false;
      _isTrusted = false;

      _logger.info('Key backup disabled');
    } catch (e, stackTrace) {
      _logger.severe('Failed to disable key backup', e, stackTrace);
      rethrow;
    }
  }

  /// Get the recovery key
  ///
  /// Returns the recovery key as a string that can be shown to the user.
  Future<String?> getRecoveryKey() async {
    return await _secureStorage.read(_recoveryKeyKey);
  }

  /// Back up room keys to the server
  ///
  /// This will encrypt the room keys with the backup key and upload them
  /// to the server.
  Future<void> backupRoomKeys() async {
    if (!_isEnabled || _backupKey == null) {
      throw Exception('Key backup is not enabled');
    }

    _logger.info('Backing up room keys');

    try {
      // Get the room keys to back up
      final roomKeys = await _client.getRoomKeys();

      // Encrypt the room keys
      final encryptedKeys = <String, dynamic>{};

      for (final roomId in roomKeys.rooms.keys) {
        final room = roomKeys.rooms[roomId]!;
        final encryptedRoom = <String, dynamic>{};

        for (final sessionId in room.sessions.keys) {
          final session = room.sessions[sessionId]!;

          // Encrypt the session key
          final encryptedSession = await _encryptRoomKey(
            roomId: roomId,
            sessionId: sessionId,
            sessionKey: session.sessionKey,
          );

          encryptedRoom[sessionId] = encryptedSession;
        }

        encryptedKeys[roomId] = encryptedRoom;
      }

      // Upload the encrypted keys to the server
      await _client.uploadRoomKeys(
        _currentVersion!,
        encryptedKeys,
      );

      _logger.info('Successfully backed up room keys');
    } catch (e, stackTrace) {
      _logger.severe('Failed to back up room keys', e, stackTrace);
      rethrow;
    }
  }

  /// Restore room keys from the server
  ///
  /// This will download the encrypted room keys from the server, decrypt them,
  /// and import them into the client.
  Future<Map<String, int>> restoreRoomKeys() async {
    if (!_isEnabled || _backupKey == null) {
      throw Exception('Key backup is not enabled');
    }

    _logger.info('Restoring room keys');

    try {
      // Download the encrypted keys from the server
      final encryptedKeys = await _client.downloadRoomKeys(_currentVersion!);

      // Decrypt and import the keys
      int total = 0;
      int imported = 0;

      for (final roomId in encryptedKeys.keys) {
        final room = encryptedKeys[roomId];

        for (final sessionId in room.keys) {
          total++;

          try {
            final encryptedSession = room[sessionId];
            final sessionKey = await _decryptRoomKey(
              roomId: roomId,
              sessionId: sessionId,
              encryptedSession: encryptedSession,
            );

            // Import the session key
            await _client.importRoomKey(
              roomId: roomId,
              sessionId: sessionId,
              sessionKey: sessionKey,
            );

            imported++;
          } catch (e) {
            _logger.warning('Failed to restore session $sessionId in room $roomId: $e');
          }
        }
      }

      _logger.info('Successfully restored $imported of $total room keys');

      return {
        'total': total,
        'imported': imported,
      };
    } catch (e, stackTrace) {
      _logger.severe('Failed to restore room keys', e, stackTrace);
      rethrow;
    }
  }

  // Private methods

  /// Check for an existing backup on the server
  Future<void> _checkServerBackup() async {
    try {
      final version = await _getServerBackupVersion();

      if (version != null) {
        _currentVersion = version.version;

        // If we have a backup key, check if it matches the server
        if (_backupKey != null) {
          _isTrusted = base64.encode(_backupKey!) == version.authData['public_key'];
        } else {
          _isTrusted = false;
        }

        _logger.info('Found backup on server: ${version.version}');
      } else {
        _logger.info('No backup found on server');
      }
    } catch (e, stackTrace) {
      _logger.severe('Failed to check server backup', e, stackTrace);
      rethrow;
    }
  }

  /// Get the current backup version from the server
  Future<matrix.BackupVersion?> _getServerBackupVersion() async {
    try {
      final versions = await _client.getBackupVersions();

      if (versions.isEmpty) {
        return null;
      }

      // Get the most recent version
      return versions.first;
    } catch (e) {
      _logger.warning('Failed to get backup versions: $e');
      return null;
    }
  }

  /// Create a new backup version on the server
  Future<String> _createBackupVersion({
    required String algorithm,
    required Map<String, dynamic> authData,
  }) async {
    final version = const Uuid().v4();

    await _client.createBackupVersion(
      version,
      algorithm,
      authData,
    );

    // Save the backup key to secure storage
    await _secureStorage.write(_backupKeyKey, base64.encode(_backupKey!));
    await _secureStorage.write(_backupVersionKey, version);

    _currentVersion = version;

    return version;
  }

  /// Generate a new backup key
  Future<Uint8List> _generateBackupKey() async {
    final random = Random.secure();
    final key = Uint8List(32);

    for (var i = 0; i < key.length; i++) {
      key[i] = random.nextInt(256);
    }

    return key;
  }

  /// Generate a new salt
  Future<Uint8List> _generateSalt() async {
    final random = Random.secure();
    final salt = Uint8List(32);

    for (var i = 0; i < salt.length; i++) {
      salt[i] = random.nextInt(256);
    }

    return salt;
  }

  /// Derive a key from a passphrase and salt
  Future<Uint8List> _deriveKey(String passphrase, Uint8List salt) async {
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    final params = Pbkdf2Parameters(salt, 500000, 32);

    pbkdf2.init(params);
    return pbkdf2.process(Uint8List.fromList(utf8.encode(passphrase)));
  }

  /// Encrypt the backup key with a key derived from the passphrase
  Future<String> _encryptBackupKey(Uint8List backupKey, Uint8List key) async {
    // Use AES-CBC with PKCS7 padding
    final iv = await _generateIv();
    final cipher = PaddedBlockCipherImpl(
      PKCS7Padding(),
      CBCBlockCipher(AESFastEngine()),
    );

    final params = ParametersWithIV(KeyParameter(key), iv);
    cipher.init(true, params);

    final encrypted = cipher.process(backupKey);

    // Combine IV and encrypted data
    final result = Uint8List(iv.length + encrypted.length);
    result.setAll(0, iv);
    result.setAll(iv.length, encrypted);

    return base64.encode(result);
  }

  /// Decrypt the backup key with a key derived from the passphrase
  Future<Uint8List> _decryptBackupKey(Uint8List encryptedKey, Uint8List key) async {
    // Extract IV and encrypted data
    final iv = encryptedKey.sublist(0, 16);
    final encrypted = encryptedKey.sublist(16);

    // Use AES-CBC with PKCS7 padding
    final cipher = PaddedBlockCipherImpl(
      PKCS7Padding(),
      CBCBlockCipher(AESFastEngine()),
    );

    final params = ParametersWithIV(KeyParameter(key), iv);
    cipher.init(false, params);

    return cipher.process(encrypted);
  }

  /// Generate a new IV for encryption
  Future<Uint8List> _generateIv() async {
    final random = Random.secure();
    final iv = Uint8List(16);

    for (var i = 0; i < iv.length; i++) {
      iv[i] = random.nextInt(256);
    }

    return iv;
  }

  /// Generate a new recovery key
  String _generateRecoveryKey() {
    final random = Random.secure();
    final bytes = Uint8List(32);

    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = random.nextInt(256);
    }

    // Encode as base58 for better readability
    return base58Encode(bytes);
  }

  /// Decode a recovery key
  Map<String, dynamic> _decodeRecoveryKey(String recoveryKey) {
    try {
      // Try to decode as base58
      final bytes = base58Decode(recoveryKey);

      if (bytes.length != 32) {
        throw Exception('Invalid recovery key length');
      }

      // The first 16 bytes are the private key, the rest is the public key
      return {
        'privateKey': bytes.sublist(0, 16),
        'publicKey': bytes.sublist(16),
      };
    } catch (e) {
      throw Exception('Invalid recovery key format');
    }
  }

  /// Encrypt a room key with the backup key
  Future<Map<String, dynamic>> _encryptRoomKey({
    required String roomId,
    required String sessionId,
    required String sessionKey,
  }) async {
    final iv = await _generateIv();
    final cipher = PaddedBlockCipherImpl(
      PKCS7Padding(),
      CBCBlockCipher(AESFastEngine()),
    );

    final params = ParametersWithIV(KeyParameter(_backupKey!), iv);
    cipher.init(true, params);

    final encrypted = cipher.process(Uint8List.fromList(utf8.encode(sessionKey)));

    return {
      'ciphertext': base64.encode(encrypted),
      'iv': base64.encode(iv),
      'mac': base64.encode(await _computeHmac(encrypted, iv)),
    };
  }

  /// Decrypt a room key with the backup key
  Future<String> _decryptRoomKey({
    required String roomId,
    required String sessionId,
    required Map<String, dynamic> encryptedSession,
  }) async {
    final encrypted = base64.decode(encryptedSession['ciphertext']);
    final iv = base64.decode(encryptedSession['iv']);
    final mac = base64.decode(encryptedSession['mac']);

    // Verify the MAC
    final computedMac = await _computeHmac(encrypted, iv);
    if (!_constantTimeEquals(computedMac, mac)) {
      throw Exception('Invalid MAC');
    }

    // Decrypt the session key
    final cipher = PaddedBlockCipherImpl(
      PKCS7Padding(),
      CBCBlockCipher(AESFastEngine()),
    );

    final params = ParametersWithIV(KeyParameter(_backupKey!), iv);
    cipher.init(false, params);

    final decrypted = cipher.process(encrypted);
    return utf8.decode(decrypted);
  }

  /// Compute HMAC for a message
  Future<Uint8List> _computeHmac(Uint8List message, Uint8List iv) async {
    final hmac = HMac(SHA256Digest(), 64);
    hmac.init(KeyParameter(_backupKey!));

    final data = Uint8List(iv.length + message.length);
    data.setAll(0, iv);
    data.setAll(iv.length, message);

    return hmac.process(data);
  }

  /// Compare two byte arrays in constant time
  bool _constantTimeEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) {
      return false;
    }

    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }

    return result == 0;
  }

  /// Clean up resources
  Future<void> dispose() async {
    // Nothing to do here
  }
}

// Helper functions for base58 encoding/decoding
const _alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
final _alphabetMap = {
  for (var i = 0; i < _alphabet.length; i++) _alphabet[i]: i,
};

String base58Encode(Uint8List input) {
  if (input.isEmpty) return '';

  // Count leading zeros
  var zeros = 0;
  while (zeros < input.length && input[zeros] == 0) {
    zeros++;
  }

  // Convert to base58
  final digits = <int>[];
  digits.add(0);

  for (var i = 0; i < input.length; i++) {
    var carry = input[i] & 0xFF;

    for (var j = 0; j < digits.length; j++) {
      carry += digits[j] << 8;
      digits[j] = carry % 58;
      carry = carry ~/ 58;
    }

    while (carry > 0) {
      digits.add(carry % 58);
      carry = carry ~/ 58;
    }
  }

  // Add leading zeros
  for (var i = 0; i < zeros; i++) {
    digits.add(0);
  }

  // Convert to string
  final result = StringBuffer();
  for (var i = digits.length - 1; i >= 0; i--) {
    result.write(_alphabet[digits[i]]);
  }

  return result.toString();
}

Uint8List base58Decode(String input) {
  if (input.isEmpty) return Uint8List(0);

  // Count leading zeros
  var zeros = 0;
  while (zeros < input.length && input[zeros] == _alphabet[0]) {
    zeros++;
  }

  // Convert from base58
  final bytes = <int>[];
  bytes.add(0);

  for (var i = 0; i < input.length; i++) {
    final c = input[i];
    var value = _alphabetMap[c];

    if (value == null) {
      throw FormatException('Invalid character: $c');
    }

    for (var j = 0; j < bytes.length; j++) {
      value += bytes[j] * 58;
      bytes[j] = value & 0xFF;
      value >>= 8;
    }

    while (value > 0) {
      bytes.add(value & 0xFF);
      value >>= 8;
    }
  }

  // Add leading zeros
  for (var i = 0; i < input.length && input[i] == _alphabet[0]; i++) {
    bytes.add(0);
  }

  // Convert to big-endian
  bytes.reversed;

  return Uint8List.fromList(bytes);
}
