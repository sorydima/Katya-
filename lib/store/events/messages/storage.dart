import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:katya/global/print.dart';
import 'package:katya/storage/constants.dart';
import 'package:katya/storage/database.dart';
import 'package:katya/store/events/messages/model.dart';
import 'package:katya/store/events/redaction/model.dart';

///
/// Message Quesies - unencrypted (Cold Storage)
///
/// In storage, messages are indexed by eventId
/// In redux, they're indexed by RoomID and placed in a list
///
extension MessageQueries on StorageDatabase {
  Future<void> insertMessagesBatched(List<Message> messages) {
    // HACK: temporary to account for sqlite versions without UPSERT
    if (Platform.isLinux) {
      return batch(
        (batch) => batch.insertAll(
          this.messages,
          messages,
          mode: InsertMode.insertOrReplace,
        ),
      );
    }
    return batch(
      (batch) => batch.insertAllOnConflictUpdate(
        this.messages,
        messages,
      ),
    );
  }

  Future<void> deleteMessages(List<String> messageIds) {
    return (delete(messages)..where((tbl) => tbl.id.isIn(messageIds))).go();
  }


  Future<List<Message>> selectMessagesIds(List<String> messageIds) {
    return (select(messages)
          ..where((tbl) => tbl.id.isIn(messageIds))
          ..orderBy([
            (tbl) =>
                OrderingTerm(expression: tbl.timestamp, mode: OrderingMode.desc)
          ]))
        .get();
  }

  Future<List<Message>> selectMessagesOrdered(
    String? roomId, {
    int? timestamp,
    int offset = 0,
    int limit = DEFAULT_LOAD_LIMIT,
  }) {
    return (select(messages)
          ..where((tbl) =>
              tbl.roomId.equals(roomId!) &
              tbl.timestamp.isSmallerOrEqualValue(timestamp!))
          ..orderBy([
            (tbl) =>
                OrderingTerm(expression: tbl.timestamp, mode: OrderingMode.desc)
          ])
          ..limit(limit, offset: offset))
        .get();
  }

  ///
  /// Select Messages (Room Only)
  ///
  /// Query the latest messages in time for a particular room
  /// Helps for the initial load from cold storage
  ///
  Future<List<Message>> selectMessagesRoom(String roomId,
      {int offset = 0, int limit = DEFAULT_LOAD_LIMIT}) {
    return (select(messages)
          ..where((tbl) => tbl.roomId.equals(roomId))
          ..orderBy([
            (tbl) =>
                OrderingTerm(expression: tbl.timestamp, mode: OrderingMode.desc)
          ])
          ..limit(limit, offset: offset))
        .get();
  }

  ///
  /// Select Messages (Batch Based)
  ///
  /// Query messages that occured during the batch sent in
  /// This is meant to help resolve gaps in syncing, if a
  /// backfill sync fails to fetch all previous messages
  ///
  Future<List<Message>> selectMessagesBatch(
    String? roomId, {
    String? batch,
  }) {
    return (select(messages)
          ..where(
            (tbl) => tbl.roomId.equals(roomId!) & tbl.batch.equals(batch!),
          ))
        .get();
  }

  ///
  /// Select Messages (All)
  ///
  /// Query every message known in a room
  ///
  Future<List<Message>> selectMessagesAll(String roomId) {
    return (select(messages)..where((tbl) => tbl.roomId.equals(roomId))).get();
  }

  Future<List<Message>> searchMessageBodys(String text,
      {int offset = 0, int limit = DEFAULT_LOAD_LIMIT}) {
    return (select(messages)
          ..where((tbl) => tbl.body.like('%$text%'))
          ..limit(limit, offset: offset))
        .get();
  }
}

Future<void> saveMessages(
  List<Message> messages, {
  required StorageDatabase storage,
}) async {
  await storage.insertMessagesBatched(messages);
}

Future<void> deleteMessages(
  List<Message> messages, {
  required StorageDatabase storage,
}) async {
  await storage.deleteMessages(messages.map((e) => e.id!).toList());
}

Future<void> saveMessagesRedacted(
  List<Redaction> redactions, {
  required StorageDatabase storage,
}) async {
  final messageIds =
      redactions.map((redaction) => redaction.redactId ?? '').toList();
  final messages = await storage.selectMessagesIds(messageIds);

  final messagesUpdated =
      messages.map((message) => message.copyWith(body: null)).toList();
  await storage.insertMessagesBatched(messagesUpdated);
}

Future<List<Message>> loadMessages({
  required StorageDatabase storage,
  required String roomId,
  int timestamp = 0,
  int offset = 0,
  int limit = DEFAULT_LOAD_LIMIT,
  String? batch,
}) async {
  try {
    // load everything
    if (limit < 1) {
      return storage.selectMessagesAll(roomId);
    }

    // load batch based messages
    if (batch != null) {
      return storage.selectMessagesBatch(
        roomId,
        batch: batch,
      );
    }

    return storage.selectMessagesOrdered(
      roomId,
      timestamp: timestamp,
      offset: offset,
      limit: limit,
    );
  } catch (error) {
    log.error(error.toString(), title: 'loadMessages');
    return [];
  }
}

Future<List<Message>> loadMessagesRoom(
  String roomId, {
  required StorageDatabase storage,
  int timestamp = 0,
  int offset = 0,
  int limit = DEFAULT_LOAD_LIMIT,
}) async {
  try {
    return storage.selectMessagesRoom(
      roomId,
      offset: offset,
      limit: limit,
    );
  } catch (error) {
    log.error(error.toString(), title: 'loadMessages');
    return [];
  }
}

Future<List<Message>> searchMessagesStored(
  String text, {
  required StorageDatabase storage,
}) {
  return storage.searchMessageBodys(text);
}

///
///  Decrypted Message Queries (Cold Storage)
///
/// In storage, messages are indexed by eventId
/// In redux, they're indexed by RoomID and placed in a list
///
/// TODO: implemented a quick AOT decryption will
/// prevent needing a cached table for this
//
extension DecryptedQueries on StorageDatabase {
  Future<void> insertDecryptedBatched(List<Message> decrypted) {
    // HACK: temporary to account for sqlite versions without UPSERT
    if (Platform.isLinux) {
      return batch(
        (batch) => batch.insertAll(
          this.decrypted,
          decrypted,
          mode: InsertMode.insertOrReplace,
        ),
      );
    }
    return batch(
      (batch) => batch.insertAllOnConflictUpdate(
        this.decrypted,
        decrypted,
      ),
    );
  }

  Future<List<Message>> selectDecrypted(
    String? roomId, {
    int? timestamp,
    int offset = 0,
    int limit = DEFAULT_LOAD_LIMIT,
  }) {
    return (select(decrypted)
          ..where((tbl) =>
              tbl.roomId.equals(roomId!) &
              tbl.timestamp.isSmallerOrEqualValue(timestamp!))
          ..orderBy([
            (tbl) =>
                OrderingTerm(expression: tbl.timestamp, mode: OrderingMode.desc)
          ])
          ..limit(limit, offset: offset))
        .get();
  }

  Future<List<Message>> selectDecryptedRoom(
    String roomId, {
    int offset = 0,
    int limit = DEFAULT_LOAD_LIMIT,
  }) {
    return (select(decrypted)
          ..where((tbl) => tbl.roomId.equals(roomId))
          ..orderBy([
            (tbl) =>
                OrderingTerm(expression: tbl.timestamp, mode: OrderingMode.desc)
          ])
          ..limit(limit, offset: offset))
        .get();
  }

  ///
  /// Select Messages (All)
  ///
  /// Query every message known in a room
  ///
  Future<List<Message>> selectDecryptedAll(String roomId) {
    return (select(decrypted)..where((tbl) => tbl.roomId.equals(roomId))).get();
  }

  Future<List<Message>> searchDecryptedBodys(
    String text, {
    int offset = 0,
    int limit = DEFAULT_LOAD_LIMIT,
  }) {
    return (select(decrypted)
          ..where((tbl) => tbl.body.like('%$text%'))
          ..limit(limit, offset: offset))
        .get();
  }
}

Future<void> saveDecrypted(
  List<Message> messages, {
  required StorageDatabase storage,
}) async {
  await storage.insertDecryptedBatched(messages);
}

Future<List<Message>> loadDecrypted({
  required StorageDatabase storage,
  String? roomId,
  int offset = 0,
  int limit = DEFAULT_LOAD_LIMIT,
}) async {
  try {
    return storage.selectDecrypted(roomId);
  } catch (error) {
    log.error(error.toString(), title: 'loadMessages');
    return [];
  }
}

///
/// Load Decrypted Room
///
/// that decrypts on the fly only after loading messages
/// from cold storage -> redux
///
/// TODO: convert to cache only ephemeral runner
///
Future<List<Message>> loadDecryptedRoom(
  String roomId, {
  required StorageDatabase storage,
  int offset = 0,
  int limit = DEFAULT_LOAD_LIMIT, // default amount loaded
}) async {
  try {
    // TODO: needs more testing to remove, not pulling correctly
    if (true) {
      return storage.selectDecryptedAll(roomId);
    }

    return storage.selectDecryptedRoom(
      roomId,
      offset: offset,
      limit: limit,
    );
  } catch (error) {
    log.error(error.toString(), title: 'loadMessages');
    return [];
  }
}
