import 'package:drift/drift.dart';
import 'package:drift/web.dart';
import 'package:katya/context/types.dart';
import 'package:katya/global/print.dart';

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
