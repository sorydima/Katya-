import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

import '../services/matrix_client_service.dart';

class MatrixProvider extends ChangeNotifier {
  final MatrixClientService _matrixService = MatrixClientService();

  bool _isInitialized = false;
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _matrixService.isLoggedIn;
  String? get error => _error;
  Client? get client => _isInitialized ? _matrixService.client : null;

  Future<void> joinRoom(String roomIdOrAlias) async {
    if (!_isInitialized || client == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      await client!.joinRoom(roomIdOrAlias);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Initialize the Matrix client
  Future<void> initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _matrixService.initialize();
      _isInitialized = true;
    } catch (e) {
      _error = 'Failed to initialize Matrix client: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login to Matrix
  Future<void> login({
    required String homeserver,
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _matrixService.login(
        homeserver: homeserver,
        username: username,
        password: password,
      );
    } catch (e) {
      _error = 'Login failed: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout from Matrix
  Future<void> logout() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _matrixService.logout();
    } catch (e) {
      _error = 'Logout failed: $e';
      rethrow;
    } finally {
      _isLoading = false;
      _isInitialized = false;
      notifyListeners();
    }
  }

  // Create a new room
  Future<Room> createRoom({
    String? name,
    String? topic,
    bool isEncrypted = true,
    bool isDirect = false,
    List<String>? inviteUserIds,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final room = await _matrixService.createRoom(
        name: name,
        topic: topic,
        isEncrypted: isEncrypted,
        isDirect: isDirect,
        inviteUserIds: inviteUserIds,
      );
      return room;
    } catch (e) {
      _error = 'Failed to create room: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send a message to a room
  Future<String> sendMessage({
    required String roomId,
    required String text,
    String? inReplyTo,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final eventId = await _matrixService.sendMessage(
        roomId: roomId,
        text: text,
        inReplyTo: inReplyTo,
      );
      return eventId;
    } catch (e) {
      _error = 'Failed to send message: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get a list of rooms
  List<Room> getRooms() {
    return _matrixService.getRooms();
  }

  // Get a specific room by ID
  Room? getRoom(String roomId) {
    return _matrixService.getRoom(roomId);
  }

  // Get user information
  Future<User> getUser(String userId) async {
    return await _matrixService.getUser(userId);
  }

  // Set user presence
  Future<void> setPresence(String preset) async {
    // Simple implementation - in a real app, this would set user presence
    print('Setting presence to: $preset');
  }

  // Clean up resources
  @override
  Future<void> dispose() async {
    await _matrixService.dispose();
    super.dispose();
  }
}
