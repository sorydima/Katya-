import 'package:flutter/foundation.dart';
import 'package:katya/cache/index.dart';
import 'package:katya/cache/threadables.dart';
import 'package:katya/global/print.dart';
import 'package:katya/store/auth/state.dart';
import 'package:katya/store/crypto/state.dart';
import 'package:katya/store/rooms/state.dart';
import 'package:katya/store/sync/state.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:sembast/sembast.dart';

class CacheStorage implements StorageEngine {
  final Database? cache;

  CacheStorage({this.cache});

  @override
  Future<Uint8List> load() async {
    final List<Object> stores = [
      const AuthStore(),
      const SyncStore(),
      const CryptoStore(),
      const RoomStore(),
    ];

    await Future.wait(stores.map((store) async {
      final type = store.runtimeType.toString();
      try {
        // Fetch from database
        final table = StoreRef<String, String>.main();
        final record = table.record(store.runtimeType.toString());
        final jsonEncrypted = await record.get(cache!);

        // Decrypt from database
        final jsonDecoded = await compute(
          decryptJsonBackground,
          {
            'type': type,
            'json': jsonEncrypted,
            'cacheKey': Cache.cacheKey,
          },
          debugLabel: 'decryptJsonBackground',
        );

        // Load for CacheSerializer to use later
        Cache.cacheStores[type] = jsonDecoded as Map<dynamic, dynamic>?;
      } catch (error) {
        log.error(error.toString(), title: 'CacheStorage|$type');
      }
    }));

    // unlock redux_persist after cache loaded from sqflite
    return Uint8List(0);
  }

  @override
  Future<void> save(Uint8List? data) {
    return Future.value();
  }
}
