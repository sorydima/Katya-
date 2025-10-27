import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:drift/drift.dart';
import 'package:drift/isolate.dart';
import 'package:drift/native.dart';
import 'package:katya/context/auth.dart';
import 'package:katya/context/types.dart';
import 'package:katya/global/libs/storage/key-storage.dart';
import 'package:katya/global/print.dart';
import 'package:katya/global/values.dart';
import 'package:katya/storage/converters.dart';
import 'package:katya/storage/index.dart';
import 'package:katya/storage/models.dart';
import 'package:katya/store/auth/schema.dart';
import 'package:katya/store/crypto/schema.dart';
import 'package:katya/store/crypto/sessions/schema.dart';
import 'package:katya/store/events/messages/model.dart';
import 'package:katya/store/events/messages/schema.dart';
import 'package:katya/store/events/reactions/model.dart';
import 'package:katya/store/events/reactions/schema.dart';
import 'package:katya/store/events/receipts/model.dart';
import 'package:katya/store/events/receipts/schema.dart';
import 'package:katya/store/media/encryption.dart';
import 'package:katya/store/media/model.dart';
import 'package:katya/store/media/schema.dart';
import 'package:katya/store/rooms/room/model.dart';
import 'package:katya/store/rooms/room/schema.dart';
import 'package:katya/store/settings/schema.dart';
import 'package:katya/store/sync/schema.dart';
import 'package:katya/store/user/model.dart';
import 'package:katya/store/user/schema.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqlcipher_library_windows/sqlcipher_library_windows.dart';
import 'package:sqlite3/open.dart';

part 'database.g.dart';

void _openOnIOS() {
  try {
    open.overrideFor(OperatingSystem.iOS, () => DynamicLibrary.process());
  } catch (error) {
    log.error(error.toString());
  }
}

void _openOnAndroid() {
  try {
    open.overrideFor(OperatingSystem.android, () => DynamicLibrary.open('libsqlcipher.so'));
  } catch (error) {
    log.error(error.toString());
  }
}

void _openOnLinux() {
  try {
    open.overrideFor(OperatingSystem.linux, () => DynamicLibrary.open('libsqlcipher.so'));
    return;
  } catch (_) {
    log.error(_.toString());
    try {
      final scriptDir = File(Platform.script.toFilePath()).parent;
      final libraryNextToScript = File('${scriptDir.path}/sqlite3.so');
      final lib = DynamicLibrary.open(libraryNextToScript.path);

      open.overrideFor(OperatingSystem.linux, () => lib);
    } catch (error) {
      log.error(error.toString());
      rethrow;
    }
  }
}

void initDatabase() {
  if (Platform.isWindows) {
    openSQLCipherOnWindows();
  }
  if (Platform.isIOS || Platform.isMacOS) {
    _openOnIOS();
  }
  if (Platform.isLinux) {
    _openOnLinux();
  }
  if (Platform.isAndroid) {
    _openOnAndroid();
  }
}

Future<DatabaseInfo> findDatabase(AppContext context, {String pin = Values.empty, SendPort? port}) async {
  var storageKeyId = Storage.keyLocation;
  var storageLocation = Storage.sqliteLocation;

  final contextId = context.id;
  if (contextId.isNotEmpty) {
    storageKeyId = '$contextId-$storageKeyId';
    storageLocation = '$contextId-$storageLocation';
  }
  storageLocation = DEBUG_MODE ? 'debug-$storageLocation' : storageLocation;

  final dbFolder = await getApplicationSupportDirectory();
  final filePath = File(path.join(dbFolder.path, storageLocation));

  var storageKey = await loadKey(storageKeyId);
  final isLockedContext = context.id.isNotEmpty && context.secretKeyEncrypted.isNotEmpty && pin.isNotEmpty;
  if (isLockedContext) {
    storageKey = await unlockSecretKey(context, pin);
  }

  return DatabaseInfo(
    key: storageKey,
    path: filePath.path,
    port: port,
  );
}

void _openDatabaseBackground(DatabaseInfo info) {
  initDatabase();
  final driftIsolate = DriftIsolate.inCurrent(
    () => DatabaseConnection.fromExecutor(
      NativeDatabase(
        File(info.path),
        logStatements: false,
        setup: (rawDb) {
          rawDb.execute("PRAGMA key = '${info.key}';");
        },
      ),
    ),
  );
  if (info.port == null) {
    return;
  }
  info.port!.send(driftIsolate);
}

Future<DriftIsolate> spawnDatabaseIsolate(AppContext context, {String pin = Values.empty}) async {
  final receivePort = ReceivePort();
  final info = await findDatabase(context, pin: pin, port: receivePort.sendPort);
  await Isolate.spawn(
    _openDatabaseBackground,
    info,
  );
  return await receivePort.first as DriftIsolate;
}

StorageDatabase openDatabaseThreaded(AppContext context, {String pin = Values.empty}) {
  final connection = DatabaseConnection.delayed(
    () async {
      final isolate = await spawnDatabaseIsolate(context, pin: pin);
      return await isolate.connect();
    }(),
  );
  return StorageDatabase.connect(connection);
}

LazyDatabase openDatabase(AppContext context, {String pin = Values.empty}) {
  return LazyDatabase(() async {
    initDatabase();
    final info = await findDatabase(context, pin: pin);
    return NativeDatabase(
      File(info.path),
      logStatements: false,
      setup: (rawDb) {
        rawDb.execute("PRAGMA key = '${info.key}';");
      },
    );
  });
}

@DriftDatabase(
  tables: [
    Messages,
    Decrypted,
    Rooms,
    Users,
    Medias,
    Reactions,
    Receipts,
    Auths,
    Syncs,
    Cryptos,
    MessageSessions,
    KeySessions,
    Settings,
  ],
)
class StorageDatabase extends _$StorageDatabase {
  StorageDatabase(AppContext context, {String pin = ''}) : super(openDatabase(context, pin: pin));
  StorageDatabase.connect(DatabaseConnection connection) : super.connect(connection);
  @override
  int get schemaVersion => 9;
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) {
          return m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          log.info('[MIGRATION] VERSION $from to $to');
          if (from == 8) {
            await m.addColumn(messages, messages.hasLink);
            await m.addColumn(messages, decrypted.hasLink);
          }
          if (from == 7) {
            await m.createTable(keySessions);
            await m.createTable(messageSessions);
          }
          if (from == 6) {
            await m.createTable(syncs);
          }
          if (from == 5) {
            await m.createTable(auths);
            await m.createTable(cryptos);
            await m.createTable(settings);
            await m.createTable(receipts);
            await m.createTable(reactions);
          }
          if (from == 4) {
            await m.addColumn(messages, messages.editIds);
            await m.addColumn(messages, messages.batch);
            await m.addColumn(messages, messages.prevBatch);
            await m.renameColumn(rooms, 'last_hash', rooms.lastBatch);
            await m.renameColumn(rooms, 'prev_hash', rooms.prevBatch);
            await m.renameColumn(rooms, 'next_hash', rooms.nextBatch);
          }
        },
      );
}
