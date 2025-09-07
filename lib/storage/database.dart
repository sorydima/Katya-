import 'package:drift/drift.dart';
import 'package:katya/context/types.dart';
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

import 'database_impl_io.dart' if (dart.library.html) 'database_impl_web.dart' as dbimpl;

part 'database.g.dart';

LazyDatabase openDatabase(AppContext context, {String pin = Values.empty}) {
  return dbimpl.createLazyDatabase(context, pin: pin);
}

StorageDatabase openDatabaseThreaded(AppContext context, {String pin = Values.empty}) {
  final connection = dbimpl.createThreadedConnection(context, pin: pin);
  return StorageDatabase.connect(connection);
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
