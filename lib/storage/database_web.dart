import 'package:drift/drift.dart';
import 'package:drift/web.dart';
import 'package:katya/context/types.dart';
import 'package:katya/global/print.dart';
import 'package:katya/storage/converters.dart';
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

part 'database.g.dart';

LazyDatabase openDatabase(AppContext context, {String pin = ''}) {
  return LazyDatabase(() async {
    return WebDatabase.withStorage(DriftWebStorage.indexedDb('katya_db'));
  });
}

class StorageDatabase extends _$StorageDatabase {
  StorageDatabase(AppContext context, {String pin = ''}) : super(openDatabase(context, pin: pin));

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) {
          log.info('[web] creating all tables');
          return m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          log.info('[web] MIGRATION VERSION $from to $to');
        },
      );
}

StorageDatabase openDatabaseThreaded(AppContext context, {String pin = ''}) {
  return StorageDatabase(context, pin: pin);
}


