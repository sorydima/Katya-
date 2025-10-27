import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:katya/global/libs/storage/secure-storage.dart';
import 'package:katya/global/print.dart';
import 'package:katya/store/sync/service/service.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_linux/path_provider_linux.dart';
import 'package:sqlite3/open.dart';

Future<void> initPlatformDependencies() async {
  if (!kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }

  if (Platform.isLinux) {
    PathProviderLinux.registerWith();

    final appDir = File(Platform.script.toFilePath()).parent;
    final libolmDir = File(path.join(appDir.path, 'lib/libolm.so'));
    final libsqliteDir = File(path.join(appDir.path, './libsqlite3.so'));
    final libsqlcipherDir = File(path.join(appDir.path, './libsqlcipher.so'));
    final libolmExists = await libolmDir.exists();
    final libsqliteExists = await libsqliteDir.exists();
    final libsqlcipherExists = await libsqlcipherDir.exists();

    if (libolmExists) {
      DynamicLibrary.open(libolmDir.path);
    } else {
      log.error('[linux] not found libolmExists ${libolmDir.path}');
    }

    if (libsqliteExists) {
      open.overrideFor(OperatingSystem.linux, () {
        return DynamicLibrary.open(libsqliteDir.path);
      });
    } else {
      log.error('[linux] not found libsqliteExists ${libsqliteDir.path}');
    }

    if (libsqlcipherExists) {
      open.overrideFor(OperatingSystem.linux, () {
        return DynamicLibrary.open(libsqlcipherDir.path);
      });
    } else {
      log.error('[linux] not found libsqlcipherExists ${libsqlcipherDir.path}');
    }
  }

  if (Platform.isMacOS) {
    final directory = await getApplicationSupportDirectory();
    log.info('[macos] ${directory.path}');
    try {
      DynamicLibrary.open('libolm.3.dylib');
    } catch (error) {
      log.info('[macos] $error');
    }
  }

  if (Platform.isAndroid || Platform.isIOS) {
    SecureStorage.instance = const FlutterSecureStorage();
  }

  if (Platform.isAndroid) {
    final backgroundSyncStatus = await SyncService.init();
    log.info('[main] background service initialized $backgroundSyncStatus');
  }
}
