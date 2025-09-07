import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:drift/drift.dart';
import 'package:drift/isolate.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqlcipher_library_windows/sqlcipher_library_windows.dart';
import 'package:sqlite3/open.dart';
import 'package:katya/context/auth.dart';
import 'package:katya/context/types.dart';
import 'package:katya/global/libs/storage/key-storage.dart';
import 'package:katya/global/print.dart';
import 'package:katya/global/values.dart';
import 'package:katya/storage/index.dart';

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

class DatabaseInfo {
  DatabaseInfo({required this.key, required this.path, this.port});
  final String key;
  final String path;
  final SendPort? port;
}

Future<DatabaseInfo> findDatabase(AppContext context,
    {String pin = Values.empty, SendPort? port}) async {
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
  final isLockedContext =
      context.id.isNotEmpty && context.secretKeyEncrypted.isNotEmpty && pin.isNotEmpty;
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

DatabaseConnection createThreadedConnection(AppContext context, {String pin = Values.empty}) {
  final connection = DatabaseConnection.delayed(
    () async {
      final receivePort = ReceivePort();
      final info = await findDatabase(context, pin: pin, port: receivePort.sendPort);
      await Isolate.spawn(
        _openDatabaseBackground,
        info,
      );
      return await receivePort.first as DatabaseConnection;
    }(),
  );
  return connection;
}

LazyDatabase createLazyDatabase(AppContext context, {String pin = Values.empty}) {
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


