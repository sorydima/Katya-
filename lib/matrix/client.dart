import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../crypto/encryption_service.dart';
import '../crypto/secure_storage.dart';

/// Core Matrix client implementation
class MatrixClient {
  static final MatrixClient _instance = MatrixClient._internal();

  late final matrix.Client _client;
  late final EncryptionService _encryptionService;
  late final SecureStorage _secureStorage;

  String? _userId;
  String? _deviceId;
  String? _homeserverUrl;
  String? _accessToken;

  final _stateController = StreamController<ClientState>.broadcast();
  Stream<ClientState> get onStateChanged => _stateController.stream;

  ClientState _currentState = const ClientState.loggedOut();
  ClientState get state => _currentState;

  final Logger _logger = Logger('MatrixClient');

  factory MatrixClient() => _instance;

  MatrixClient._internal();

  /// Initialize the client
  Future<void> initialize() async {
    _secureStorage = SecureStorage();
    await _secureStorage.initialize();
    await _loadStoredCredentials();
    _setupClient();
  }

  void _setupClient() {
    _client = matrix.Client(
      'Katya',
      databaseBuilder: _openDatabase,
      verificationMethods: {
        matrix.VerificationMethod.sas,
        matrix.VerificationMethod.reciprocate,
      },
    );

    _setupEncryption();
  }

  void _setupEncryption() {
    _encryptionService = EncryptionService();
    // Setup encryption callbacks...
  }

  /// Login to Matrix homeserver
  Future<void> login({
    required String homeserverUrl,
    required String username,
    required String password,
  }) async {
    try {
      _updateState(const ClientState.loggingIn());

      _homeserverUrl = homeserverUrl;

      await _client.login(
        username: username,
        password: password,
        initialDeviceDisplayName: 'Katya Mobile',
      );

      _userId = _client.userID;
      _deviceId = _client.deviceID;
      _accessToken = _client.accessToken;

      await _saveCredentials();

      await _encryptionService.init(
        userId: _userId!,
        deviceId: _deviceId!,
        deviceKey: _client.deviceKeys!.ed25519Key,
      );

      await _client.startSync();

      _updateState(ClientState.loggedIn(
        userId: _userId!,
        deviceId: _deviceId!,
        homeserverUrl: _homeserverUrl!,
      ));
    } catch (e) {
      _updateState(ClientState.error(
        'Login failed: $e',
        previousState: _currentState,
      ));
      rethrow;
    }
  }

  /// Logout from Matrix
  Future<void> logout() async {
    try {
      _updateState(const ClientState.loggingOut());

      await _client.logout();
      await _clearCredentials();

      _client.dispose();
      _setupClient();

      _updateState(const ClientState.loggedOut());
    } catch (e) {
      _updateState(ClientState.error(
        'Logout failed: $e',
        previousState: _currentState,
      ));
      rethrow;
    }
  }

  // Credential management
  Future<void> _loadStoredCredentials() async {
    try {
      _userId = await _secureStorage.read('matrix_user_id');
      _deviceId = await _secureStorage.read('matrix_device_id');
      _accessToken = await _secureStorage.read('matrix_access_token');
      _homeserverUrl = await _secureStorage.read('matrix_homeserver_url');

      if (_userId != null && _deviceId != null && _accessToken != null && _homeserverUrl != null) {
        _updateState(ClientState.loggedIn(
          userId: _userId!,
          deviceId: _deviceId!,
          homeserverUrl: _homeserverUrl!,
        ));
        _client.startSync();
      }
    } catch (e) {
      await _clearCredentials();
    }
  }

  Future<void> _saveCredentials() async {
    if (_userId != null) await _secureStorage.write('matrix_user_id', _userId!);
    if (_deviceId != null) await _secureStorage.write('matrix_device_id', _deviceId!);
    if (_accessToken != null) await _secureStorage.write('matrix_access_token', _accessToken!);
    if (_homeserverUrl != null) await _secureStorage.write('matrix_homeserver_url', _homeserverUrl!);
  }

  Future<void> _clearCredentials() async {
    await _secureStorage.delete('matrix_user_id');
    await _secureStorage.delete('matrix_device_id');
    await _secureStorage.delete('matrix_access_token');
    await _secureStorage.delete('matrix_homeserver_url');

    _userId = null;
    _deviceId = null;
    _accessToken = null;
    _homeserverUrl = null;
  }

  // State management
  void _updateState(ClientState newState) {
    if (_currentState == newState) return;
    _currentState = newState;
    _stateController.add(newState);
  }

  // Database
  Future<matrix.Database> _openDatabase(String name) async {
    final directory = await getApplicationDocumentsDirectory();
    final dbPath = path.join(directory.path, 'matrix_database', '$name.db');
    await Directory(path.dirname(dbPath)).create(recursive: true);
    return matrix.Database.open(dbPath, log: _logger);
  }

  // Cleanup
  Future<void> dispose() async {
    await _client.dispose();
    _encryptionService.dispose();
    await _stateController.close();
  }
}

/// Client state
abstract class ClientState {
  const ClientState();
  bool get isLoggedIn => false;
  bool get isLoggingIn => false;
  bool get isLoggingOut => false;
  bool get isError => false;
  String? get error => null;

  const factory ClientState.loggedOut() = LoggedOutState;
  const factory ClientState.loggingIn() = LoggingInState;
  const factory ClientState.loggedIn({
    required String userId,
    required String deviceId,
    required String homeserverUrl,
  }) = LoggedInState;
  const factory ClientState.loggingOut() = LoggingOutState;
  const factory ClientState.error(
    String error, {
    ClientState? previousState,
  }) = ErrorState;
}

class LoggedOutState extends ClientState {
  const LoggedOutState();
  @override
  bool operator ==(Object other) => identical(this, other) || other is LoggedOutState;
  @override
  int get hashCode => 0;
}

class LoggingInState extends ClientState {
  const LoggingInState();
  @override
  bool get isLoggingIn => true;
  @override
  bool operator ==(Object other) => identical(this, other) || other is LoggingInState;
  @override
  int get hashCode => 1;
}

class LoggedInState extends ClientState {
  final String userId;
  final String deviceId;
  final String homeserverUrl;

  const LoggedInState({
    required this.userId,
    required this.deviceId,
    required this.homeserverUrl,
  });

  @override
  bool get isLoggedIn => true;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoggedInState &&
          userId == other.userId &&
          deviceId == other.deviceId &&
          homeserverUrl == other.homeserverUrl;

  @override
  int get hashCode => Object.hash(userId, deviceId, homeserverUrl);
}

class LoggingOutState extends ClientState {
  const LoggingOutState();
  @override
  bool get isLoggingOut => true;
  @override
  bool operator ==(Object other) => identical(this, other) || other is LoggingOutState;
  @override
  int get hashCode => 2;
}

class ErrorState extends ClientState {
  @override
  final String error;
  @override
  final ClientState? previousState;

  const ErrorState(this.error, {this.previousState});

  @override
  bool get isError => true;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ErrorState && error == other.error && previousState == other.previousState;

  @override
  int get hashCode => Object.hash(error, previousState);
}
