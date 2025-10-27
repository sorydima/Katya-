import 'dart:async';

import 'package:olm/olm.dart' as olm;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class MegolmWrapper {
  static const String _dbName = 'megolm_sessions.db';
  static const String _inboundTable = 'inbound_sessions';
  static const String _outboundTable = 'outbound_sessions';
  static const String _roomIndexTable = 'room_sessions';

  static final MegolmWrapper _instance = MegolmWrapper._internal();
  late final Database _database;

  factory MegolmWrapper() => _instance;

  MegolmWrapper._internal();

  // Initialize the database
  Future<void> init() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDir.path, _dbName);

    _database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        // Inbound sessions (sessions we receive)
        await db.execute('''
          CREATE TABLE $_inboundTable (
            session_id TEXT PRIMARY KEY,
            session_key TEXT NOT NULL,
            room_id TEXT NOT NULL,
            sender_key TEXT NOT NULL,
            signing_key TEXT NOT NULL,
            forwarding_chains TEXT,
            first_known_index INTEGER NOT NULL,
            last_known_index INTEGER NOT NULL,
            is_verified INTEGER DEFAULT 0,
            added_at INTEGER NOT NULL,
            last_used INTEGER NOT NULL
          )
        ''');

        // Outbound sessions (sessions we create)
        await db.execute('''
          CREATE TABLE $_outboundTable (
            room_id TEXT PRIMARY KEY,
            session_id TEXT NOT NULL,
            session_key TEXT NOT NULL,
            message_index INTEGER DEFAULT 0,
            created_at INTEGER NOT NULL,
            max_messages INTEGER DEFAULT 100,
            max_age_days INTEGER DEFAULT 7
          )
        ''');

        // Room to session index
        await db.execute('''
          CREATE TABLE $_roomIndexTable (
            room_id TEXT NOT NULL,
            session_id TEXT NOT NULL,
            PRIMARY KEY (room_id, session_id)
          )
        ''');

        // Create indexes for faster lookups
        await db.execute('''
          CREATE INDEX idx_inbound_room ON $_inboundTable(room_id);
        ''');

        await db.execute('''
          CREATE INDEX idx_inbound_sender ON $_inboundTable(sender_key);
        ''');
      },
    );
  }

  // Generate a new outbound session for a room
  Future<OutboundGroupSession> createOutboundSession(String roomId) async {
    final session = olm.OutboundGroupSession();
    session.create();

    final now = DateTime.now().millisecondsSinceEpoch;
    final sessionId = session.session_id();
    final sessionKey = session.session_key();

    await _database.insert(
      _outboundTable,
      {
        'room_id': roomId,
        'session_id': sessionId,
        'session_key': sessionKey,
        'message_index': 0,
        'created_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await _updateRoomSessionIndex(roomId, sessionId);

    return OutboundGroupSession(
      roomId: roomId,
      sessionId: sessionId,
      session: session,
      messageIndex: 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(now),
    );
  }

  // Get the current outbound session for a room
  Future<OutboundGroupSession?> getOutboundSession(String roomId) async {
    final result = await _database.query(
      _outboundTable,
      where: 'room_id = ?',
      whereArgs: [roomId],
    );

    if (result.isEmpty) return null;

    final session = olm.OutboundGroupSession();
    session.unpickle('', result.first['session_key']! as String);

    return OutboundGroupSession(
      roomId: roomId,
      sessionId: result.first['session_id']! as String,
      session: session,
      messageIndex: result.first['message_index']! as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        result.first['created_at']! as int,
      ),
    );
  }

  // Add an inbound session (received from another device)
  Future<void> addInboundSession({
    required String sessionId,
    required String sessionKey,
    required String roomId,
    required String senderKey,
    String? signingKey,
    String? forwardingChains,
    int firstKnownIndex = 0,
    bool isVerified = false,
  }) async {
    await _database.insert(
      _inboundTable,
      {
        'session_id': sessionId,
        'session_key': sessionKey,
        'room_id': roomId,
        'sender_key': senderKey,
        'signing_key': signingKey ?? '',
        'forwarding_chains': forwardingChains ?? '',
        'first_known_index': firstKnownIndex,
        'last_known_index': firstKnownIndex,
        'is_verified': isVerified ? 1 : 0,
        'added_at': DateTime.now().millisecondsSinceEpoch,
        'last_used': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await _updateRoomSessionIndex(roomId, sessionId);
  }

  // Get an inbound session by ID
  Future<InboundGroupSession?> getInboundSession(String sessionId) async {
    final result = await _database.query(
      _inboundTable,
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );

    if (result.isEmpty) return null;

    final session = olm.InboundGroupSession();
    session.unpickle('', result.first['session_key']! as String);

    return InboundGroupSession(
      sessionId: sessionId,
      session: session,
      roomId: result.first['room_id']! as String,
      senderKey: result.first['sender_key']! as String,
      signingKey: result.first['signing_key'] as String?,
      forwardingChains: result.first['forwarding_chains'] as String?,
      firstKnownIndex: result.first['first_known_index']! as int,
      lastKnownIndex: result.first['last_known_index']! as int,
      isVerified: (result.first['is_verified']! as int) == 1,
    );
  }

  // Find the best inbound session for a room and sender
  Future<InboundGroupSession?> findBestInboundSession({
    required String roomId,
    String? senderKey,
  }) async {
    final query = 'room_id = ?${senderKey != null ? ' AND sender_key = ?' : ''}';
    final args = [roomId];
    if (senderKey != null) args.add(senderKey);

    final result = await _database.query(
      _inboundTable,
      where: query,
      whereArgs: args,
      orderBy: 'last_used DESC',
      limit: 1,
    );

    if (result.isEmpty) return null;

    final session = olm.InboundGroupSession();
    session.unpickle('', result.first['session_key']! as String);

    return InboundGroupSession(
      sessionId: result.first['session_id']! as String,
      session: session,
      roomId: roomId,
      senderKey: result.first['sender_key']! as String,
      signingKey: result.first['signing_key'] as String?,
      forwardingChains: result.first['forwarding_chains'] as String?,
      firstKnownIndex: result.first['first_known_index']! as int,
      lastKnownIndex: result.first['last_known_index']! as int,
      isVerified: (result.first['is_verified']! as int) == 1,
    );
  }

  // Mark a session as verified
  Future<void> verifySession(String sessionId) async {
    await _database.update(
      _inboundTable,
      {'is_verified': 1},
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
  }

  // Update the room-session index
  Future<void> _updateRoomSessionIndex(String roomId, String sessionId) async {
    await _database.insert(
      _roomIndexTable,
      {
        'room_id': roomId,
        'session_id': sessionId,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // Get all session IDs for a room
  Future<List<String>> getSessionIdsForRoom(String roomId) async {
    final result = await _database.query(
      _roomIndexTable,
      columns: ['session_id'],
      where: 'room_id = ?',
      whereArgs: [roomId],
    );

    return result.map((row) => row['session_id']! as String).toList();
  }

  // Clean up old sessions
  Future<void> cleanupSessions({int maxAgeDays = 30}) async {
    final cutoff = DateTime.now().subtract(Duration(days: maxAgeDays)).millisecondsSinceEpoch;

    // Clean up old inbound sessions
    await _database.delete(
      _inboundTable,
      where: 'last_used < ?',
      whereArgs: [cutoff],
    );

    // Clean up old outbound sessions (except for the most recent one per room)
    final rooms = await _database.query(
      _outboundTable,
      columns: ['room_id'],
      groupBy: 'room_id',
    );

    for (final room in rooms) {
      final roomId = room['room_id']! as String;
      final sessions = await _database.query(
        _outboundTable,
        where: 'room_id = ?',
        whereArgs: [roomId],
        orderBy: 'created_at DESC',
      );

      if (sessions.length > 1) {
        // Keep only the most recent session
        final sessionsToDelete = sessions.sublist(1);
        for (final session in sessionsToDelete) {
          await _database.delete(
            _outboundTable,
            where: 'room_id = ? AND created_at = ?',
            whereArgs: [roomId, session['created_at']],
          );
        }
      }
    }
  }
}

class OutboundGroupSession {
  final String roomId;
  final String sessionId;
  final olm.OutboundGroupSession session;
  int messageIndex;
  final DateTime createdAt;

  OutboundGroupSession({
    required this.roomId,
    required this.sessionId,
    required this.session,
    required this.messageIndex,
    required this.createdAt,
  });

  // Encrypt a message
  String encrypt(String plaintext) {
    final ciphertext = session.encrypt(plaintext);
    messageIndex++;
    return ciphertext;
  }

  // Get the current message index
  int get messageCount => session.message_index();

  // Get the session key (for sharing with other devices)
  String get sessionKey => session.session_key();

  // Check if the session is valid
  bool get isValid => !session.is_freed();

  // Free resources
  void dispose() {
    session.free();
  }
}

class InboundGroupSession {
  final String sessionId;
  final olm.InboundGroupSession session;
  final String roomId;
  final String senderKey;
  final String? signingKey;
  final String? forwardingChains;
  final int firstKnownIndex;
  final int lastKnownIndex;
  final bool isVerified;

  InboundGroupSession({
    required this.sessionId,
    required this.session,
    required this.roomId,
    required this.senderKey,
    this.signingKey,
    this.forwardingChains,
    this.firstKnownIndex = 0,
    this.lastKnownIndex = 0,
    this.isVerified = false,
  });

  // Decrypt a message
  String decrypt(String ciphertext, int messageIndex) {
    return session.decrypt(ciphertext);
  }

  // Get the session key (for sharing with other devices)
  String exportSession(int messageIndex) {
    return session.export_session(messageIndex);
  }

  // Get the sender's key
  String get senderKey => senderKey;

  // Get the signing key
  String? get signingKey => signingKey;

  // Check if the session is valid
  bool get isValid => !session.is_freed();

  // Free resources
  void dispose() {
    session.free();
  }
}
