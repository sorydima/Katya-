import 'dart:async';

import 'package:olm/olm.dart' as olm;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class OlmWrapper {
  static const int _olmVersion = 3; // Minimum required version of libolm
  static const String _dbName = 'olm_sessions.db';
  static const String _sessionsTable = 'sessions';
  static const String _prekeyTable = 'prekeys';

  static final OlmWrapper _instance = OlmWrapper._internal();
  late final Database _database;

  factory OlmWrapper() => _instance;

  OlmWrapper._internal();

  // Initialize the Olm library and database
  Future<void> init() async {
    // Initialize Olm library
    await olm.init();
    final olmVersion = olm.get_library_version();
    if (olmVersion.major < _olmVersion) {
      throw Exception('Libolm version too old. Need at least $_olmVersion.0.0');
    }

    // Initialize database for session storage
    final appDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDir.path, _dbName);

    _database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_sessionsTable (
            id TEXT PRIMARY KEY,
            session TEXT NOT NULL,
            last_used INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE $_prekeyTable (
            id TEXT PRIMARY KEY,
            prekey TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // Create a new Olm account
  Future<OlmAccount> createAccount() async {
    final account = olm.Account();
    account.create();
    return OlmAccount(account);
  }

  // Store a session in the database
  Future<void> storeSession(String sessionId, String sessionData) async {
    await _database.insert(
      _sessionsTable,
      {
        'id': sessionId,
        'session': sessionData,
        'last_used': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieve a session from the database
  Future<String?> getSession(String sessionId) async {
    final result = await _database.query(
      _sessionsTable,
      where: 'id = ?',
      whereArgs: [sessionId],
    );

    if (result.isEmpty) return null;

    // Update last used timestamp
    await _database.update(
      _sessionsTable,
      {'last_used': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [sessionId],
    );

    return result.first['session'] as String?;
  }

  // Store a prekey in the database
  Future<void> storePrekey(String prekeyId, String prekey) async {
    await _database.insert(
      _prekeyTable,
      {
        'id': prekeyId,
        'prekey': prekey,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieve a prekey from the database
  Future<String?> getPrekey(String prekeyId) async {
    final result = await _database.query(
      _prekeyTable,
      where: 'id = ?',
      whereArgs: [prekeyId],
    );

    if (result.isEmpty) return null;
    return result.first['prekey'] as String?;
  }

  // Clean up old sessions
  Future<void> cleanupSessions({int maxAgeDays = 30}) async {
    final cutoff = DateTime.now().subtract(Duration(days: maxAgeDays)).millisecondsSinceEpoch;

    await _database.delete(
      _sessionsTable,
      where: 'last_used < ?',
      whereArgs: [cutoff],
    );
  }
}

class OlmAccount {
  final olm.Account _account;

  OlmAccount(this._account);

  // Get the identity keys (curve25519 and ed25519)
  String get identityKeys => _account.identity_keys();

  // Generate one-time keys
  String generateOneTimeKeys(int count) {
    _account.generate_one_time_keys(count);
    return _account.one_time_keys();
  }

  // Generate fallback key
  String generateFallbackKey() {
    _account.generate_fallback_key();
    return _account.fallback_key();
  }

  // Mark keys as published
  void markKeysAsPublished() {
    _account.mark_keys_as_published();
  }

  // Create an outbound session
  Future<OlmSession> createOutboundSession(String theirIdentityKey, String theirOneTimeKey) async {
    final session = olm.Session();
    try {
      session.create_outbound(_account, theirIdentityKey, theirOneTimeKey);
      return OlmSession(session);
    } catch (e) {
      session.free();
      rethrow;
    }
  }

  // Create an inbound session from a message
  Future<OlmSession> createInboundSession(String oneTimeKeyMessage) async {
    final session = olm.Session();
    try {
      session.create_inbound_from(_account, oneTimeKeyMessage);
      return OlmSession(session);
    } catch (e) {
      session.free();
      rethrow;
    }
  }

  // Encrypt a message
  String encrypt(String plaintext) {
    return _account.encrypt(plaintext);
  }

  // Decrypt a message
  String decrypt(String message) {
    return _account.decrypt(message);
  }

  // Free resources
  void dispose() {
    _account.free();
  }
}

class OlmSession {
  final olm.Session _session;

  OlmSession(this._session);

  // Encrypt a message
  String encrypt(String plaintext) {
    return _session.encrypt(plaintext);
  }

  // Decrypt a message
  String decrypt(String message) {
    return _session.decrypt(0, message);
  }

  // Get session ID
  String get sessionId => _session.session_id();

  // Check if session is valid
  bool get isValid => !_session.is_freed();

  // Serialize session to string
  String pickle(String key) {
    return _session.pickle(key);
  }

  // Deserialize session from string
  static OlmSession fromPickle(String key, String pickle) {
    final session = olm.Session();
    session.unpickle(key, pickle);
    return OlmSession(session);
  }

  // Free resources
  void dispose() {
    _session.free();
  }
}
