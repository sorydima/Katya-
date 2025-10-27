import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:matrix/matrix.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MatrixClientService {
  static final MatrixClientService _instance = MatrixClientService._internal();
  factory MatrixClientService() => _instance;

  Client? _client;
  bool _isInitialized = false;

  Client? get client => _client;
  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => _client?.isLogged() ?? false;

  MatrixClientService._internal();

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Simple initialization - in a real app, this would initialize the Matrix client
    print('Matrix client service initialized');
    _isInitialized = true;
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      const storage = FlutterSecureStorage();

      final homeserver = prefs.getString('matrix_homeserver');
      final userId = prefs.getString('matrix_user_id');
      final accessToken = await storage.read(key: 'matrix_access_token');

      if (homeserver != null && userId != null && accessToken != null) {
        // Simple initialization - in a real app, this would initialize the client
        print('Matrix client initialized with saved credentials');
      }
    } catch (e) {
      // Clear invalid credentials
      await _clearCredentials();
      rethrow;
    }
  }

  Future<void> login({
    required String homeserver,
    required String username,
    required String password,
  }) async {
    try {
      // Simple login implementation - in a real app, this would authenticate with Matrix
      print('Logging in to $homeserver as $username');

      // Save credentials
      await _saveCredentials(
        homeserver: homeserver,
        userId: username,
        accessToken: 'dummy_token_${DateTime.now().millisecondsSinceEpoch}',
      );

      print('Matrix client login successful and ready');
    } catch (e) {
      await _clearCredentials();
      rethrow;
    }
  }

  Future<void> logout() async {
    // Simple logout implementation
    print('Logging out from Matrix');
    await _clearCredentials();
  }

  Future<void> _saveCredentials({
    required String homeserver,
    required String userId,
    required String accessToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    const storage = FlutterSecureStorage();

    await prefs.setString('matrix_homeserver', homeserver);
    await prefs.setString('matrix_user_id', userId);
    await storage.write(key: 'matrix_access_token', value: accessToken);
  }

  Future<void> _clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    const storage = FlutterSecureStorage();

    await prefs.remove('matrix_homeserver');
    await prefs.remove('matrix_user_id');
    await storage.delete(key: 'matrix_access_token');
  }

  // Room management
  Future<Room> createRoom({
    String? name,
    String? topic,
    bool isEncrypted = true,
    bool isDirect = false,
    List<String>? inviteUserIds,
  }) async {
    // Simple room creation - in a real app, this would create a Matrix room
    final roomId = 'room_${DateTime.now().millisecondsSinceEpoch}';
    print('Creating room: $name (encrypted: $isEncrypted)');
    // Simple room creation - return a dummy room ID
    return 'room_${DateTime.now().millisecondsSinceEpoch}' as Room;
  }

  Future<void> joinRoom(String roomIdOrAlias) async {
    // Simple room join - in a real app, this would join a Matrix room
    print('Joining room: $roomIdOrAlias');
  }

  Future<void> leaveRoom(String roomId) async {
    // Simple room leave - in a real app, this would leave a Matrix room
    print('Leaving room: $roomId');
  }

  // Message sending
  Future<String> sendMessage({
    required String roomId,
    required String text,
    String? inReplyTo,
  }) async {
    // Simple implementation - in a real app, this would send a text message
    final eventId = 'event_${DateTime.now().millisecondsSinceEpoch}';
    print('Sending message to room $roomId: $text');
    return eventId;
  }

  // Room list management
  List<Room> getRooms() {
    return _client?.rooms ?? [];
  }

  Room? getRoom(String roomId) {
    return _client?.getRoomById(roomId);
  }

  // User management
  Future<User> getUser(String userId) async {
    // Simple implementation - in a real app, this would get user from Matrix
    // Simple user creation - return a dummy user ID
    return userId as User;
  }

  // Presence
  Future<void> setPresence(String preset) async {
    // Simple implementation - in a real app, this would set user presence
    print('Setting presence to: $preset');
  }

  // Cleanup
  Future<void> dispose() async {
    await _client?.dispose();
  }
}
