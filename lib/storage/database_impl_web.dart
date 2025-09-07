import 'package:drift/drift.dart';
import 'package:drift/web.dart';
import 'package:katya/context/types.dart';

LazyDatabase createLazyDatabase(AppContext context, {String pin = ''}) {
  return LazyDatabase(() async {
    return WebDatabase.withStorage(DriftWebStorage.indexedDb('katya_db'));
  });
}

DatabaseConnection createThreadedConnection(AppContext context, {String pin = ''}) {
  final executor = WebDatabase.withStorage(DriftWebStorage.indexedDb('katya_db'));
  return DatabaseConnection.fromExecutor(executor);
}


