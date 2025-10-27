import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/export.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A secure storage service that provides encrypted storage for sensitive data.
///
/// This service uses platform-specific secure storage mechanisms and provides
/// additional encryption for stored data. It's designed to store sensitive
/// information like encryption keys, access tokens, and other credentials.
class SecureStorage {
  static final SecureStorage _instance = SecureStorage._internal();
  static const String _encryptionKeyKey = '_secure_storage_encryption_key';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late encrypt.Encrypter _encrypter;
  bool _isInitialized = false;

  /// Get the singleton instance of SecureStorage
  factory SecureStorage() => _instance;

  SecureStorage._internal();

  /// Initialize the secure storage service
  ///
  /// This method must be called before any other methods.
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Generate or retrieve the encryption key
    final encryptionKey = await _getOrCreateEncryptionKey();
    _encrypter = encrypt.Encrypter(
      encrypt.AES(
        encrypt.Key(encryptionKey),
        mode: encrypt.AESMode.cbc,
      ),
    );

    _isInitialized = true;
  }

  /// Store a string value securely
  ///
  /// The value will be encrypted before being stored.
  Future<void> write(String key, String value) async {
    _checkInitialized();

    // Generate a random IV for this encryption
    final iv = encrypt.IV.fromSecureRandom(16);

    // Encrypt the value
    final encrypted = _encrypter.encrypt(value, iv: iv);

    // Store the encrypted value and IV
    await _secureStorage.write(
      key: key,
      value: '${base64.encode(iv.bytes)}.${encrypted.base64}',
    );
  }

  /// Read a securely stored string value
  ///
  /// Returns null if the key does not exist.
  Future<String?> read(String key) async {
    _checkInitialized();

    final value = await _secureStorage.read(key: key);
    if (value == null) return null;

    try {
      // Split the stored value into IV and encrypted data
      final parts = value.split('.');
      if (parts.length != 2) throw Exception('Invalid stored value format');

      final iv = encrypt.IV(base64.decode(parts[0]));
      final encrypted = encrypt.Encrypted.fromBase64(parts[1]);

      // Decrypt the value
      return _encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      // If decryption fails, try to read the raw value (for backward compatibility)
      try {
        return await _secureStorage.read(key: key);
      } catch (_) {
        rethrow;
      }
    }
  }

  /// Store a boolean value securely
  Future<void> writeBool(String key, bool value) async {
    await write(key, value.toString());
  }

  /// Read a securely stored boolean value
  ///
  /// Returns [defaultValue] if the key does not exist.
  Future<bool> readBool(String key, {bool defaultValue = false}) async {
    final value = await read(key);
    if (value == null) return defaultValue;
    return value.toLowerCase() == 'true';
  }

  /// Store an integer value securely
  Future<void> writeInt(String key, int value) async {
    await write(key, value.toString());
  }

  /// Read a securely stored integer value
  ///
  /// Returns [defaultValue] if the key does not exist or is not a valid integer.
  Future<int> readInt(String key, {int defaultValue = 0}) async {
    final value = await read(key);
    if (value == null) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }

  /// Store a map as JSON securely
  Future<void> writeMap(String key, Map<String, dynamic> value) async {
    await write(key, json.encode(value));
  }

  /// Read a securely stored map
  ///
  /// Returns an empty map if the key does not exist or is not valid JSON.
  Future<Map<String, dynamic>> readMap(String key) async {
    final value = await read(key);
    if (value == null) return {};

    try {
      final map = json.decode(value) as Map<String, dynamic>?;
      return map ?? {};
    } catch (e) {
      return {};
    }
  }

  /// Remove a securely stored value
  Future<void> delete(String key) async {
    _checkInitialized();
    await _secureStorage.delete(key: key);
  }

  /// Check if a key exists in secure storage
  Future<bool> containsKey(String key) async {
    _checkInitialized();
    return _secureStorage.containsKey(key: key);
  }

  /// Get all keys in secure storage
  Future<Map<String, String>> readAll() async {
    _checkInitialized();
    return _secureStorage.readAll();
  }

  /// Delete all values in secure storage
  Future<void> deleteAll() async {
    _checkInitialized();
    await _secureStorage.deleteAll();
  }

  /// Migrate data from SharedPreferences to secure storage
  ///
  /// This is useful when upgrading from a version that didn't use secure storage.
  Future<void> migrateFromSharedPrefs(List<String> keysToMigrate) async {
    _checkInitialized();

    final prefs = await SharedPreferences.getInstance();

    for (final key in keysToMigrate) {
      if (prefs.containsKey(key)) {
        final value = prefs.get(key);

        if (value is String) {
          await write(key, value);
        } else if (value is int) {
          await writeInt(key, value);
        } else if (value is bool) {
          await writeBool(key, value);
        } else if (value is double) {
          await write(key, value.toString());
        } else if (value is List<String>) {
          await write(key, json.encode(value));
        }

        // Remove from SharedPreferences after migration
        await prefs.remove(key);
      }
    }
  }

  // Generate a secure random encryption key or retrieve an existing one
  Future<Uint8List> _getOrCreateEncryptionKey() async {
    // Try to read the existing key
    final existingKey = await _secureStorage.read(key: _encryptionKeyKey);

    if (existingKey != null) {
      // Return the existing key
      return base64.decode(existingKey);
    } else {
      // Generate a new secure random key
      final key = _generateSecureRandom(32); // 256 bits

      // Store the key securely
      await _secureStorage.write(
        key: _encryptionKeyKey,
        value: base64.encode(key),
      );

      return key;
    }
  }

  // Generate secure random bytes
  Uint8List _generateSecureRandom(int length) {
    final secureRandom = FortunaRandom();

    // Seed with entropy from the OS
    final seed = Uint8List(32);
    final random = Random.secure();
    for (var i = 0; i < seed.length; i++) {
      seed[i] = random.nextInt(256);
    }

    secureRandom.seed(KeyParameter(seed));

    // Generate random bytes
    final bytes = Uint8List(length);
    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = secureRandom.nextUint8();
    }

    return bytes;
  }

  // Check if the service is initialized
  void _checkInitialized() {
    if (!_isInitialized) {
      throw Exception('SecureStorage has not been initialized. Call initialize() first.');
    }
  }

  // Get the SHA-256 hash of a string
  static String hashString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Generate a secure random string
  static String generateSecureRandomString([int length = 32]) {
    final random = Random.secure();
    final values = List<int>.generate(length, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }
}
