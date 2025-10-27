import 'dart:async';
import 'dart:convert';

import 'package:matrix/encryption/utils/key_request.dart';

import 'megolm_wrapper.dart';
import 'olm_wrapper.dart';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();

  late final OlmWrapper _olm;
  late final MegolmWrapper _megolm;
  late final String _deviceId;
  late final String _userId;
  late final String _deviceKey;

  final Map<String, OutboundGroupSession> _outboundSessions = {};
  final Map<String, InboundGroupSession> _inboundSessions = {};

  // Event stream for encryption-related events
  final StreamController<EncryptionEvent> _eventController = StreamController<EncryptionEvent>.broadcast();

  factory EncryptionService() => _instance;

  EncryptionService._internal();

  // Initialize the encryption service
  Future<void> init({
    required String userId,
    required String deviceId,
    required String deviceKey,
  }) async {
    _userId = userId;
    _deviceId = deviceId;
    _deviceKey = deviceKey;

    // Initialize Olm and Megolm
    _olm = OlmWrapper();
    await _olm.init();

    _megolm = MegolmWrapper();
    await _megolm.init();

    // Load existing sessions
    await _loadSessions();
  }

  // Get the stream of encryption events
  Stream<EncryptionEvent> get events => _eventController.stream;

  // Generate a new Olm account
  Future<OlmAccount> createAccount() async {
    return await _olm.createAccount();
  }

  // Encrypt a message for a room
  Future<Map<String, dynamic>> encryptMessage({
    required String roomId,
    required String eventType,
    required Map<String, dynamic> content,
  }) async {
    // Get or create an outbound session for the room
    var session = _outboundSessions[roomId];
    if (session == null || !session.isValid) {
      session = await _createOutboundSession(roomId);
    }

    // Encrypt the message content
    final encryptedContent = await _encryptRoomEvent(
      roomId: roomId,
      eventType: eventType,
      content: content,
      session: session,
    );

    // Return the encrypted message
    return {
      'type': 'm.room.encrypted',
      'content': encryptedContent,
      'room_id': roomId,
      'sender': _userId,
      'origin_server_ts': DateTime.now().millisecondsSinceEpoch,
    };
  }

  // Decrypt an encrypted message
  Future<Map<String, dynamic>> decryptMessage({
    required String roomId,
    required Map<String, dynamic> event,
  }) async {
    final content = event['content'] as Map<String, dynamic>;
    final algorithm = content['algorithm'] as String?;

    if (algorithm != 'm.megolm.v1.aes-sha2' && algorithm != 'm.olm.v1.curve25519-aes-sha2') {
      throw Exception('Unsupported encryption algorithm: $algorithm');
    }

    if (algorithm == 'm.megolm.v1.aes-sha2') {
      return await _decryptMegolmMessage(roomId, event);
    } else {
      return await _decryptOlmMessage(roomId, event);
    }
  }

  // Create a new outbound Megolm session for a room
  Future<OutboundGroupSession> _createOutboundSession(String roomId) async {
    final session = await _megolm.createOutboundSession(roomId);
    _outboundSessions[roomId] = session;

    // Share the session with all room members
    await _shareRoomKey(roomId, session);

    return session;
  }

  // Share a room key with all members
  Future<void> _shareRoomKey(
    String roomId,
    OutboundGroupSession session,
  ) async {
    // In a real implementation, we would:
    // 1. Get the list of room members
    // 2. For each member, get their devices
    // 3. Encrypt the session key for each device
    // 4. Send the encrypted key to each device

    // This is a simplified version that just broadcasts the key
    final encryptedKey = await _encryptRoomKey(roomId, session);

    // Broadcast the room key to the room
    _eventController.add(RoomKeySharedEvent(
      roomId: roomId,
      sessionId: session.sessionId,
      sessionKey: session.sessionKey,
    ));

    // In a real implementation, we would send the encrypted key to the server
    // to be distributed to other devices
  }

  // Encrypt a room key for a specific device
  Future<Map<String, dynamic>> _encryptRoomKey(
    String roomId,
    OutboundGroupSession session,
  ) async {
    // In a real implementation, we would:
    // 1. Get the device's Olm session
    // 2. Encrypt the session key using the Olm session
    // 3. Return the encrypted key

    // This is a simplified version
    return {
      'algorithm': 'm.megolm.v1.aes-sha2',
      'room_id': roomId,
      'session_id': session.sessionId,
      'session_key': session.sessionKey,
      'chain_index': 0,
      'sender_key': _deviceKey,
      'sender_claimed_ed25519_key': _deviceKey,
      'forwarding_curve25519_key_chain': [],
      'org.matrix.msc3061.shared_history': true,
    };
  }

  // Encrypt a room event using Megolm
  Future<Map<String, dynamic>> _encryptRoomEvent({
    required String roomId,
    required String eventType,
    required Map<String, dynamic> content,
    required OutboundGroupSession session,
  }) async {
    final plaintext = json.encode({
      'room_id': roomId,
      'type': eventType,
      'content': content,
      'sender': _userId,
      'origin': _deviceId,
      'origin_server_ts': DateTime.now().millisecondsSinceEpoch,
    });

    final ciphertext = session.encrypt(plaintext);

    return {
      'algorithm': 'm.megolm.v1.aes-sha2',
      'sender_key': _deviceKey,
      'ciphertext': ciphertext,
      'session_id': session.sessionId,
      'device_id': _deviceId,
      'sender_key': _deviceKey,
    };
  }

  // Decrypt a Megolm-encrypted message
  Future<Map<String, dynamic>> _decryptMegolmMessage(
    String roomId,
    Map<String, dynamic> event,
  ) async {
    final content = event['content'] as Map<String, dynamic>;
    final senderKey = content['sender_key'] as String;
    final sessionId = content['session_id'] as String;

    // Try to find an existing session
    final session = _inboundSessions[sessionId];

    if (session == null) {
      // If we don't have the session, request it
      _eventController.add(RoomKeyRequestedEvent(
        roomId: roomId,
        sessionId: sessionId,
        senderKey: senderKey,
      ));

      throw Exception('No session found for $sessionId');
    }

    // Decrypt the message
    final ciphertext = content['ciphertext'] as String;
    final plaintext = session.decrypt(ciphertext, 0); // Index is not used in this implementation

    return json.decode(plaintext) as Map<String, dynamic>;
  }

  // Decrypt an Olm-encrypted message
  Future<Map<String, dynamic>> _decryptOlmMessage(
    String roomId,
    Map<String, dynamic> event,
  ) async {
    // Implementation for Olm-encrypted messages (to-device)
    // This is a simplified version

    throw UnimplementedError('Olm message decryption not implemented');
  }

  // Process a room key event (received when someone shares a room key with us)
  Future<void> processRoomKeyEvent(Map<String, dynamic> event) async {
    final content = event['content'] as Map<String, dynamic>;
    final roomId = content['room_id'] as String;
    final sessionId = content['session_id'] as String;
    final sessionKey = content['session_key'] as String;

    // Import the session
    await _megolm.addInboundSession(
      sessionId: sessionId,
      sessionKey: sessionKey,
      roomId: roomId,
      senderKey: content['sender_key'] as String,
      signingKey: content['sender_claimed_ed25519_key'] as String?,
      forwardingChains: content['forwarding_curve25519_key_chain']?.join(','),
    );

    // Load the session
    final session = await _megolm.getInboundSession(sessionId);
    if (session != null) {
      _inboundSessions[sessionId] = session;

      // Notify listeners that we have a new session
      _eventController.add(RoomKeyReceivedEvent(
        roomId: roomId,
        sessionId: sessionId,
        senderKey: session.senderKey,
      ));
    }
  }

  // Load all sessions from storage
  Future<void> _loadSessions() async {
    // Implementation would load sessions from secure storage
    // This is a simplified version
  }

  // Save all sessions to storage
  Future<void> _saveSessions() async {
    // Implementation would save sessions to secure storage
    // This is a simplified version
  }

  // Clean up resources
  void dispose() {
    for (final session in _outboundSessions.values) {
      session.dispose();
    }

    for (final session in _inboundSessions.values) {
      session.dispose();
    }

    _eventController.close();
  }
}

// Event types for the encryption service
typedef EncryptionEvent = dynamic;

class RoomKeySharedEvent {
  final String roomId;
  final String sessionId;
  final String sessionKey;

  RoomKeySharedEvent({
    required this.roomId,
    required this.sessionId,
    required this.sessionKey,
  });
}

class RoomKeyReceivedEvent {
  final String roomId;
  final String sessionId;
  final String senderKey;

  RoomKeyReceivedEvent({
    required this.roomId,
    required this.sessionId,
    required this.senderKey,
  });
}

class RoomKeyRequestedEvent {
  final String roomId;
  final String sessionId;
  final String senderKey;

  RoomKeyRequestedEvent({
    required this.roomId,
    required this.sessionId,
    required this.senderKey,
  });
}

class DecryptionErrorEvent {
  final String roomId;
  final String eventId;
  final dynamic error;

  DecryptionErrorEvent({
    required this.roomId,
    required this.eventId,
    this.error,
  });
}
