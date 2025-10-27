import 'package:flutter/foundation.dart';
import 'package:katya/services/encryption/encryption_manager.dart';
import 'package:matrix/matrix.dart';

class EncryptionProvider with ChangeNotifier {
  EncryptionManager? _encryptionManager;
  bool _isInitialized = false;

  // Getters
  EncryptionManager? get encryptionManager => _encryptionManager;
  bool get isInitialized => _isInitialized;

  // Initialize the encryption manager
  void initialize(Client matrixClient) {
    if (_isInitialized) return;

    try {
      _encryptionManager = EncryptionManager(matrixClient);
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing EncryptionProvider: $e');
      rethrow;
    }
  }

  // Initialize encryption features
  Future<void> initializeEncryption() async {
    if (_encryptionManager == null) {
      throw Exception('EncryptionManager not initialized');
    }

    try {
      await _encryptionManager!.initializeEncryption();
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing encryption features: $e');
      rethrow;
    }
  }

  // Clean up resources
  @override
  void dispose() {
    _encryptionManager = null;
    _isInitialized = false;
    super.dispose();
  }
}
