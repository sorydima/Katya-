import 'dart:convert';
import 'dart:typed_data';

import 'package:ed25519_edwards/ed25519_edwards.dart' as ed25519;
import 'package:logging/logging.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:pointycastle/export.dart';

import 'secure_storage.dart';

/// Service for handling cross-signing of devices in Matrix
///
/// Cross-signing allows users to verify their own devices and other users'
/// devices, providing a more seamless and secure verification experience.
class CrossSigningService {
  static const String _storageKeyPrefix = 'cross_signing_';
  static const String _masterKeyKey = '${_storageKeyPrefix}master_key';
  static const String _selfSigningKeyKey = '${_storageKeyPrefix}self_signing_key';
  static const String _userSigningKeyKey = '${_storageKeyPrefix}user_signing_key';

  final SecureStorage _secureStorage;
  final matrix.Client _client;
  final Logger _logger = Logger('CrossSigningService');

  /// The master key used for cross-signing
  ed25519.PrivateKey? _masterKey;

  /// The self-signing key used for signing our own devices
  ed25519.PrivateKey? _selfSigningKey;

  /// The user-signing key used for signing other users
  ed25519.PrivateKey? _userSigningKey;

  /// Whether cross-signing has been set up
  bool _isInitialized = false;

  /// Get whether cross-signing has been set up
  bool get isInitialized => _isInitialized;

  /// Create a new CrossSigningService
  CrossSigningService(this._client, this._secureStorage);

  /// Initialize the cross-signing service
  ///
  /// This will load any existing keys from secure storage and check if
  /// cross-signing is set up on the server.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Try to load keys from secure storage
      await _loadKeys();

      // If we have a master key, we consider cross-signing to be set up
      if (_masterKey != null) {
        _isInitialized = true;
        _logger.info('Cross-signing initialized with existing keys');
      } else {
        _logger.info('Cross-signing not yet set up');
      }
    } catch (e, stackTrace) {
      _logger.severe('Failed to initialize cross-signing', e, stackTrace);
      rethrow;
    }
  }

  /// Set up cross-signing for the current user
  ///
  /// This will generate new master, self-signing, and user-signing keys,
  /// upload them to the server, and sign the current device.
  Future<void> bootstrapCrossSigning() async {
    _logger.info('Bootstrapping cross-signing');

    try {
      // Generate new keys if we don't have them
      _masterKey ??= await _generateKey();
      _selfSigningKey ??= await _generateKey();
      _userSigningKey ??= await _generateKey();

      // Save the keys to secure storage
      await _saveKeys();

      // Upload the keys to the server
      await _uploadKeys();

      // Sign the current device with our self-signing key
      await _signCurrentDevice();

      _isInitialized = true;
      _logger.info('Successfully bootstrapped cross-signing');
    } catch (e, stackTrace) {
      _logger.severe('Failed to bootstrap cross-signing', e, stackTrace);
      rethrow;
    }
  }

  /// Verify another user's device
  ///
  /// This will sign the device with our user-signing key and upload the
  /// signature to the server.
  Future<void> verifyDevice(
    String userId,
    String deviceId,
    Map<String, dynamic> deviceKeys,
    Map<String, dynamic>? masterKeys,
  ) async {
    _logger.info('Verifying device $deviceId of user $userId');

    try {
      // Make sure we have our keys
      if (_userSigningKey == null) {
        throw Exception('User-signing key not available');
      }

      // Verify the device's keys
      await _verifyDeviceKeys(userId, deviceId, deviceKeys, masterKeys);

      // Sign the device
      await _signDevice(userId, deviceId, deviceKeys);

      _logger.info('Successfully verified device $deviceId of user $userId');
    } catch (e, stackTrace) {
      _logger.severe('Failed to verify device', e, stackTrace);
      rethrow;
    }
  }

  /// Sign the current device with our self-signing key
  Future<void> _signCurrentDevice() async {
    final deviceId = _client.deviceID;
    if (deviceId == null) {
      throw Exception('No device ID available');
    }

    final userId = _client.userID;
    if (userId == null) {
      throw Exception('No user ID available');
    }

    _logger.info('Signing current device $deviceId');

    try {
      // Get the device keys
      final deviceKeys = await _client.database.getDeviceKeys(userId, deviceId);
      if (deviceKeys == null) {
        throw Exception('Device keys not found');
      }

      // Sign the device
      await _signDevice(userId, deviceId, deviceKeys);

      _logger.info('Successfully signed current device $deviceId');
    } catch (e, stackTrace) {
      _logger.severe('Failed to sign current device', e, stackTrace);
      rethrow;
    }
  }

  /// Sign a device with our user-signing key
  Future<void> _signDevice(
    String userId,
    String deviceId,
    Map<String, dynamic> deviceKeys,
  ) async {
    // TODO: Implement device signing
    // This will involve creating a signature with our user-signing key
    // and uploading it to the server
  }

  /// Verify a device's keys
  Future<void> _verifyDeviceKeys(
    String userId,
    String deviceId,
    Map<String, dynamic> deviceKeys,
    Map<String, dynamic>? masterKeys,
  ) async {
    // TODO: Implement device key verification
    // This will involve checking the device's keys against the master keys
    // and verifying the signatures
  }

  /// Upload the cross-signing keys to the server
  Future<void> _uploadKeys() async {
    if (_masterKey == null || _selfSigningKey == null || _userSigningKey == null) {
      throw Exception('Not all cross-signing keys are available');
    }

    final masterPublicKey = _masterKey!.publicKey;
    final selfSigningPublicKey = _selfSigningKey!.publicKey;
    final userSigningPublicKey = _userSigningKey!.publicKey;

    // Create the master key upload
    final masterKeyUpload = {
      'master_key': {
        'user_id': _client.userID,
        'usage': ['master'],
        'keys': {
          'ed25519:${_keyId(masterPublicKey)}': base64.encode(masterPublicKey.bytes),
        },
      },
      'self_signing_key': {
        'user_id': _client.userID,
        'usage': ['self_signing'],
        'keys': {
          'ed25519:${_keyId(selfSigningPublicKey)}': base64.encode(selfSigningPublicKey.bytes),
        },
      },
      'user_signing_key': {
        'user_id': _client.userID,
        'usage': ['user_signing'],
        'keys': {
          'ed25519:${_keyId(userSigningPublicKey)}': base64.encode(userSigningPublicKey.bytes),
        },
      },
    };

    // Upload the keys to the server
    await _client.uploadCrossSigningKeys(masterKeyUpload);

    _logger.info('Uploaded cross-signing keys to server');
  }

  /// Generate a new Ed25519 key pair
  Future<ed25519.PrivateKey> _generateKey() async {
    final random = FortunaRandom();
    final seed = Uint8List(32);

    // Generate random seed
    for (var i = 0; i < seed.length; i++) {
      seed[i] = random.nextUint8();
    }

    // Create key pair
    return ed25519.newKeyFromSeed(seed);
  }

  /// Load keys from secure storage
  Future<void> _loadKeys() async {
    try {
      // Load master key
      final masterKeyBase64 = await _secureStorage.read(_masterKeyKey);
      if (masterKeyBase64 != null) {
        final keyBytes = base64.decode(masterKeyBase64);
        _masterKey = ed25519.PrivateKey(keyBytes);
      }

      // Load self-signing key
      final selfSigningKeyBase64 = await _secureStorage.read(_selfSigningKeyKey);
      if (selfSigningKeyBase64 != null) {
        final keyBytes = base64.decode(selfSigningKeyBase64);
        _selfSigningKey = ed25519.PrivateKey(keyBytes);
      }

      // Load user-signing key
      final userSigningKeyBase64 = await _secureStorage.read(_userSigningKeyKey);
      if (userSigningKeyBase64 != null) {
        final keyBytes = base64.decode(userSigningKeyBase64);
        _userSigningKey = ed25519.PrivateKey(keyBytes);
      }

      _logger.fine('Loaded cross-signing keys from secure storage');
    } catch (e, stackTrace) {
      _logger.severe('Failed to load cross-signing keys', e, stackTrace);
      rethrow;
    }
  }

  /// Save keys to secure storage
  Future<void> _saveKeys() async {
    try {
      // Save master key
      if (_masterKey != null) {
        await _secureStorage.write(
          _masterKeyKey,
          base64.encode(_masterKey!.bytes),
        );
      }

      // Save self-signing key
      if (_selfSigningKey != null) {
        await _secureStorage.write(
          _selfSigningKeyKey,
          base64.encode(_selfSigningKey!.bytes),
        );
      }

      // Save user-signing key
      if (_userSigningKey != null) {
        await _secureStorage.write(
          _userSigningKeyKey,
          base64.encode(_userSigningKey!.bytes),
        );
      }

      _logger.fine('Saved cross-signing keys to secure storage');
    } catch (e, stackTrace) {
      _logger.severe('Failed to save cross-signing keys', e, stackTrace);
      rethrow;
    }
  }

  /// Get a key ID from a public key
  String _keyId(ed25519.PublicKey key) {
    // Use the first 8 bytes of the key as the ID
    return base64.encode(key.bytes.sublist(0, 8));
  }

  /// Clean up resources
  Future<void> dispose() async {
    // Clear sensitive data from memory
    _masterKey = null;
    _selfSigningKey = null;
    _userSigningKey = null;
    _isInitialized = false;
  }
}
