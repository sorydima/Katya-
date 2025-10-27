// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<String> roomId = GeneratedColumn<String>(
      'room_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _senderMeta = const VerificationMeta('sender');
  @override
  late final GeneratedColumn<String> sender = GeneratedColumn<String>(
      'sender', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _stateKeyMeta =
      const VerificationMeta('stateKey');
  @override
  late final GeneratedColumn<String> stateKey = GeneratedColumn<String>(
      'state_key', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _prevBatchMeta =
      const VerificationMeta('prevBatch');
  @override
  late final GeneratedColumn<String> prevBatch = GeneratedColumn<String>(
      'prev_batch', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _batchMeta = const VerificationMeta('batch');
  @override
  late final GeneratedColumn<String> batch = GeneratedColumn<String>(
      'batch', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pendingMeta =
      const VerificationMeta('pending');
  @override
  late final GeneratedColumn<bool> pending = GeneratedColumn<bool>(
      'pending', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("pending" IN (0, 1))'));
  static const VerificationMeta _syncingMeta =
      const VerificationMeta('syncing');
  @override
  late final GeneratedColumn<bool> syncing = GeneratedColumn<bool>(
      'syncing', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("syncing" IN (0, 1))'));
  static const VerificationMeta _failedMeta = const VerificationMeta('failed');
  @override
  late final GeneratedColumn<bool> failed = GeneratedColumn<bool>(
      'failed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("failed" IN (0, 1))'));
  static const VerificationMeta _editedMeta = const VerificationMeta('edited');
  @override
  late final GeneratedColumn<bool> edited = GeneratedColumn<bool>(
      'edited', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("edited" IN (0, 1))'));
  static const VerificationMeta _replacementMeta =
      const VerificationMeta('replacement');
  @override
  late final GeneratedColumn<bool> replacement = GeneratedColumn<bool>(
      'replacement', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("replacement" IN (0, 1))'));
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _receivedMeta =
      const VerificationMeta('received');
  @override
  late final GeneratedColumn<int> received = GeneratedColumn<int>(
      'received', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _hasLinkMeta =
      const VerificationMeta('hasLink');
  @override
  late final GeneratedColumn<bool> hasLink = GeneratedColumn<bool>(
      'has_link', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("has_link" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
      'body', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _msgtypeMeta =
      const VerificationMeta('msgtype');
  @override
  late final GeneratedColumn<String> msgtype = GeneratedColumn<String>(
      'msgtype', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
      'format', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _formattedBodyMeta =
      const VerificationMeta('formattedBody');
  @override
  late final GeneratedColumn<String> formattedBody = GeneratedColumn<String>(
      'formatted_body', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>?, String>
      file = GeneratedColumn<String>('file', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<Map<String, dynamic>?>($MessagesTable.$converterfile);
  static const VerificationMeta _typeDecryptedMeta =
      const VerificationMeta('typeDecrypted');
  @override
  late final GeneratedColumn<String> typeDecrypted = GeneratedColumn<String>(
      'type_decrypted', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ciphertextMeta =
      const VerificationMeta('ciphertext');
  @override
  late final GeneratedColumn<String> ciphertext = GeneratedColumn<String>(
      'ciphertext', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _algorithmMeta =
      const VerificationMeta('algorithm');
  @override
  late final GeneratedColumn<String> algorithm = GeneratedColumn<String>(
      'algorithm', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _senderKeyMeta =
      const VerificationMeta('senderKey');
  @override
  late final GeneratedColumn<String> senderKey = GeneratedColumn<String>(
      'sender_key', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _relatedEventIdMeta =
      const VerificationMeta('relatedEventId');
  @override
  late final GeneratedColumn<String> relatedEventId = GeneratedColumn<String>(
      'related_event_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> editIds =
      GeneratedColumn<String>('edit_ids', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('[]'))
          .withConverter<List<String>>($MessagesTable.$convertereditIds);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        roomId,
        userId,
        type,
        sender,
        stateKey,
        prevBatch,
        batch,
        pending,
        syncing,
        failed,
        edited,
        replacement,
        timestamp,
        received,
        hasLink,
        body,
        msgtype,
        format,
        formattedBody,
        url,
        file,
        typeDecrypted,
        ciphertext,
        algorithm,
        sessionId,
        senderKey,
        deviceId,
        relatedEventId,
        editIds
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(Insertable<Message> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('room_id')) {
      context.handle(_roomIdMeta,
          roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('sender')) {
      context.handle(_senderMeta,
          sender.isAcceptableOrUnknown(data['sender']!, _senderMeta));
    }
    if (data.containsKey('state_key')) {
      context.handle(_stateKeyMeta,
          stateKey.isAcceptableOrUnknown(data['state_key']!, _stateKeyMeta));
    }
    if (data.containsKey('prev_batch')) {
      context.handle(_prevBatchMeta,
          prevBatch.isAcceptableOrUnknown(data['prev_batch']!, _prevBatchMeta));
    }
    if (data.containsKey('batch')) {
      context.handle(
          _batchMeta, batch.isAcceptableOrUnknown(data['batch']!, _batchMeta));
    }
    if (data.containsKey('pending')) {
      context.handle(_pendingMeta,
          pending.isAcceptableOrUnknown(data['pending']!, _pendingMeta));
    } else if (isInserting) {
      context.missing(_pendingMeta);
    }
    if (data.containsKey('syncing')) {
      context.handle(_syncingMeta,
          syncing.isAcceptableOrUnknown(data['syncing']!, _syncingMeta));
    } else if (isInserting) {
      context.missing(_syncingMeta);
    }
    if (data.containsKey('failed')) {
      context.handle(_failedMeta,
          failed.isAcceptableOrUnknown(data['failed']!, _failedMeta));
    } else if (isInserting) {
      context.missing(_failedMeta);
    }
    if (data.containsKey('edited')) {
      context.handle(_editedMeta,
          edited.isAcceptableOrUnknown(data['edited']!, _editedMeta));
    } else if (isInserting) {
      context.missing(_editedMeta);
    }
    if (data.containsKey('replacement')) {
      context.handle(
          _replacementMeta,
          replacement.isAcceptableOrUnknown(
              data['replacement']!, _replacementMeta));
    } else if (isInserting) {
      context.missing(_replacementMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('received')) {
      context.handle(_receivedMeta,
          received.isAcceptableOrUnknown(data['received']!, _receivedMeta));
    } else if (isInserting) {
      context.missing(_receivedMeta);
    }
    if (data.containsKey('has_link')) {
      context.handle(_hasLinkMeta,
          hasLink.isAcceptableOrUnknown(data['has_link']!, _hasLinkMeta));
    }
    if (data.containsKey('body')) {
      context.handle(
          _bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    }
    if (data.containsKey('msgtype')) {
      context.handle(_msgtypeMeta,
          msgtype.isAcceptableOrUnknown(data['msgtype']!, _msgtypeMeta));
    }
    if (data.containsKey('format')) {
      context.handle(_formatMeta,
          format.isAcceptableOrUnknown(data['format']!, _formatMeta));
    }
    if (data.containsKey('formatted_body')) {
      context.handle(
          _formattedBodyMeta,
          formattedBody.isAcceptableOrUnknown(
              data['formatted_body']!, _formattedBodyMeta));
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    }
    if (data.containsKey('type_decrypted')) {
      context.handle(
          _typeDecryptedMeta,
          typeDecrypted.isAcceptableOrUnknown(
              data['type_decrypted']!, _typeDecryptedMeta));
    }
    if (data.containsKey('ciphertext')) {
      context.handle(
          _ciphertextMeta,
          ciphertext.isAcceptableOrUnknown(
              data['ciphertext']!, _ciphertextMeta));
    }
    if (data.containsKey('algorithm')) {
      context.handle(_algorithmMeta,
          algorithm.isAcceptableOrUnknown(data['algorithm']!, _algorithmMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    }
    if (data.containsKey('sender_key')) {
      context.handle(_senderKeyMeta,
          senderKey.isAcceptableOrUnknown(data['sender_key']!, _senderKeyMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    }
    if (data.containsKey('related_event_id')) {
      context.handle(
          _relatedEventIdMeta,
          relatedEventId.isAcceptableOrUnknown(
              data['related_event_id']!, _relatedEventIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sender']),
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}timestamp'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type']),
      roomId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}room_id']),
      pending: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}pending'])!,
      syncing: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}syncing'])!,
      failed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}failed'])!,
      edited: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}edited'])!,
      replacement: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}replacement'])!,
      hasLink: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}has_link'])!,
      received: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}received'])!,
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body']),
      msgtype: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}msgtype']),
      format: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}format']),
      formattedBody: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}formatted_body']),
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url']),
      file: $MessagesTable.$converterfile.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file'])),
      typeDecrypted: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type_decrypted']),
      ciphertext: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ciphertext']),
      algorithm: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}algorithm']),
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id']),
      senderKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sender_key']),
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
      relatedEventId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}related_event_id']),
      editIds: $MessagesTable.$convertereditIds.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}edit_ids'])!),
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, dynamic>?, String?> $converterfile =
      const MapToJsonConverter();
  static TypeConverter<List<String>, String> $convertereditIds =
      const ListToTextConverter();
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<String> id;
  final Value<String?> roomId;
  final Value<String?> userId;
  final Value<String?> type;
  final Value<String?> sender;
  final Value<String?> stateKey;
  final Value<String?> prevBatch;
  final Value<String?> batch;
  final Value<bool> pending;
  final Value<bool> syncing;
  final Value<bool> failed;
  final Value<bool> edited;
  final Value<bool> replacement;
  final Value<int> timestamp;
  final Value<int> received;
  final Value<bool> hasLink;
  final Value<String?> body;
  final Value<String?> msgtype;
  final Value<String?> format;
  final Value<String?> formattedBody;
  final Value<String?> url;
  final Value<Map<String, dynamic>?> file;
  final Value<String?> typeDecrypted;
  final Value<String?> ciphertext;
  final Value<String?> algorithm;
  final Value<String?> sessionId;
  final Value<String?> senderKey;
  final Value<String?> deviceId;
  final Value<String?> relatedEventId;
  final Value<List<String>> editIds;
  final Value<int> rowid;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.roomId = const Value.absent(),
    this.userId = const Value.absent(),
    this.type = const Value.absent(),
    this.sender = const Value.absent(),
    this.stateKey = const Value.absent(),
    this.prevBatch = const Value.absent(),
    this.batch = const Value.absent(),
    this.pending = const Value.absent(),
    this.syncing = const Value.absent(),
    this.failed = const Value.absent(),
    this.edited = const Value.absent(),
    this.replacement = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.received = const Value.absent(),
    this.hasLink = const Value.absent(),
    this.body = const Value.absent(),
    this.msgtype = const Value.absent(),
    this.format = const Value.absent(),
    this.formattedBody = const Value.absent(),
    this.url = const Value.absent(),
    this.file = const Value.absent(),
    this.typeDecrypted = const Value.absent(),
    this.ciphertext = const Value.absent(),
    this.algorithm = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.senderKey = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.relatedEventId = const Value.absent(),
    this.editIds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    required String id,
    this.roomId = const Value.absent(),
    this.userId = const Value.absent(),
    this.type = const Value.absent(),
    this.sender = const Value.absent(),
    this.stateKey = const Value.absent(),
    this.prevBatch = const Value.absent(),
    this.batch = const Value.absent(),
    required bool pending,
    required bool syncing,
    required bool failed,
    required bool edited,
    required bool replacement,
    required int timestamp,
    required int received,
    this.hasLink = const Value.absent(),
    this.body = const Value.absent(),
    this.msgtype = const Value.absent(),
    this.format = const Value.absent(),
    this.formattedBody = const Value.absent(),
    this.url = const Value.absent(),
    this.file = const Value.absent(),
    this.typeDecrypted = const Value.absent(),
    this.ciphertext = const Value.absent(),
    this.algorithm = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.senderKey = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.relatedEventId = const Value.absent(),
    this.editIds = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        pending = Value(pending),
        syncing = Value(syncing),
        failed = Value(failed),
        edited = Value(edited),
        replacement = Value(replacement),
        timestamp = Value(timestamp),
        received = Value(received);
  static Insertable<Message> custom({
    Expression<String>? id,
    Expression<String>? roomId,
    Expression<String>? userId,
    Expression<String>? type,
    Expression<String>? sender,
    Expression<String>? stateKey,
    Expression<String>? prevBatch,
    Expression<String>? batch,
    Expression<bool>? pending,
    Expression<bool>? syncing,
    Expression<bool>? failed,
    Expression<bool>? edited,
    Expression<bool>? replacement,
    Expression<int>? timestamp,
    Expression<int>? received,
    Expression<bool>? hasLink,
    Expression<String>? body,
    Expression<String>? msgtype,
    Expression<String>? format,
    Expression<String>? formattedBody,
    Expression<String>? url,
    Expression<String>? file,
    Expression<String>? typeDecrypted,
    Expression<String>? ciphertext,
    Expression<String>? algorithm,
    Expression<String>? sessionId,
    Expression<String>? senderKey,
    Expression<String>? deviceId,
    Expression<String>? relatedEventId,
    Expression<String>? editIds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (roomId != null) 'room_id': roomId,
      if (userId != null) 'user_id': userId,
      if (type != null) 'type': type,
      if (sender != null) 'sender': sender,
      if (stateKey != null) 'state_key': stateKey,
      if (prevBatch != null) 'prev_batch': prevBatch,
      if (batch != null) 'batch': batch,
      if (pending != null) 'pending': pending,
      if (syncing != null) 'syncing': syncing,
      if (failed != null) 'failed': failed,
      if (edited != null) 'edited': edited,
      if (replacement != null) 'replacement': replacement,
      if (timestamp != null) 'timestamp': timestamp,
      if (received != null) 'received': received,
      if (hasLink != null) 'has_link': hasLink,
      if (body != null) 'body': body,
      if (msgtype != null) 'msgtype': msgtype,
      if (format != null) 'format': format,
      if (formattedBody != null) 'formatted_body': formattedBody,
      if (url != null) 'url': url,
      if (file != null) 'file': file,
      if (typeDecrypted != null) 'type_decrypted': typeDecrypted,
      if (ciphertext != null) 'ciphertext': ciphertext,
      if (algorithm != null) 'algorithm': algorithm,
      if (sessionId != null) 'session_id': sessionId,
      if (senderKey != null) 'sender_key': senderKey,
      if (deviceId != null) 'device_id': deviceId,
      if (relatedEventId != null) 'related_event_id': relatedEventId,
      if (editIds != null) 'edit_ids': editIds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith(
      {Value<String>? id,
      Value<String?>? roomId,
      Value<String?>? userId,
      Value<String?>? type,
      Value<String?>? sender,
      Value<String?>? stateKey,
      Value<String?>? prevBatch,
      Value<String?>? batch,
      Value<bool>? pending,
      Value<bool>? syncing,
      Value<bool>? failed,
      Value<bool>? edited,
      Value<bool>? replacement,
      Value<int>? timestamp,
      Value<int>? received,
      Value<bool>? hasLink,
      Value<String?>? body,
      Value<String?>? msgtype,
      Value<String?>? format,
      Value<String?>? formattedBody,
      Value<String?>? url,
      Value<Map<String, dynamic>?>? file,
      Value<String?>? typeDecrypted,
      Value<String?>? ciphertext,
      Value<String?>? algorithm,
      Value<String?>? sessionId,
      Value<String?>? senderKey,
      Value<String?>? deviceId,
      Value<String?>? relatedEventId,
      Value<List<String>>? editIds,
      Value<int>? rowid}) {
    return MessagesCompanion(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      sender: sender ?? this.sender,
      stateKey: stateKey ?? this.stateKey,
      prevBatch: prevBatch ?? this.prevBatch,
      batch: batch ?? this.batch,
      pending: pending ?? this.pending,
      syncing: syncing ?? this.syncing,
      failed: failed ?? this.failed,
      edited: edited ?? this.edited,
      replacement: replacement ?? this.replacement,
      timestamp: timestamp ?? this.timestamp,
      received: received ?? this.received,
      hasLink: hasLink ?? this.hasLink,
      body: body ?? this.body,
      msgtype: msgtype ?? this.msgtype,
      format: format ?? this.format,
      formattedBody: formattedBody ?? this.formattedBody,
      url: url ?? this.url,
      file: file ?? this.file,
      typeDecrypted: typeDecrypted ?? this.typeDecrypted,
      ciphertext: ciphertext ?? this.ciphertext,
      algorithm: algorithm ?? this.algorithm,
      sessionId: sessionId ?? this.sessionId,
      senderKey: senderKey ?? this.senderKey,
      deviceId: deviceId ?? this.deviceId,
      relatedEventId: relatedEventId ?? this.relatedEventId,
      editIds: editIds ?? this.editIds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (sender.present) {
      map['sender'] = Variable<String>(sender.value);
    }
    if (stateKey.present) {
      map['state_key'] = Variable<String>(stateKey.value);
    }
    if (prevBatch.present) {
      map['prev_batch'] = Variable<String>(prevBatch.value);
    }
    if (batch.present) {
      map['batch'] = Variable<String>(batch.value);
    }
    if (pending.present) {
      map['pending'] = Variable<bool>(pending.value);
    }
    if (syncing.present) {
      map['syncing'] = Variable<bool>(syncing.value);
    }
    if (failed.present) {
      map['failed'] = Variable<bool>(failed.value);
    }
    if (edited.present) {
      map['edited'] = Variable<bool>(edited.value);
    }
    if (replacement.present) {
      map['replacement'] = Variable<bool>(replacement.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (received.present) {
      map['received'] = Variable<int>(received.value);
    }
    if (hasLink.present) {
      map['has_link'] = Variable<bool>(hasLink.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (msgtype.present) {
      map['msgtype'] = Variable<String>(msgtype.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (formattedBody.present) {
      map['formatted_body'] = Variable<String>(formattedBody.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (file.present) {
      map['file'] =
          Variable<String>($MessagesTable.$converterfile.toSql(file.value));
    }
    if (typeDecrypted.present) {
      map['type_decrypted'] = Variable<String>(typeDecrypted.value);
    }
    if (ciphertext.present) {
      map['ciphertext'] = Variable<String>(ciphertext.value);
    }
    if (algorithm.present) {
      map['algorithm'] = Variable<String>(algorithm.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (senderKey.present) {
      map['sender_key'] = Variable<String>(senderKey.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (relatedEventId.present) {
      map['related_event_id'] = Variable<String>(relatedEventId.value);
    }
    if (editIds.present) {
      map['edit_ids'] = Variable<String>(
          $MessagesTable.$convertereditIds.toSql(editIds.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('roomId: $roomId, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('sender: $sender, ')
          ..write('stateKey: $stateKey, ')
          ..write('prevBatch: $prevBatch, ')
          ..write('batch: $batch, ')
          ..write('pending: $pending, ')
          ..write('syncing: $syncing, ')
          ..write('failed: $failed, ')
          ..write('edited: $edited, ')
          ..write('replacement: $replacement, ')
          ..write('timestamp: $timestamp, ')
          ..write('received: $received, ')
          ..write('hasLink: $hasLink, ')
          ..write('body: $body, ')
          ..write('msgtype: $msgtype, ')
          ..write('format: $format, ')
          ..write('formattedBody: $formattedBody, ')
          ..write('url: $url, ')
          ..write('file: $file, ')
          ..write('typeDecrypted: $typeDecrypted, ')
          ..write('ciphertext: $ciphertext, ')
          ..write('algorithm: $algorithm, ')
          ..write('sessionId: $sessionId, ')
          ..write('senderKey: $senderKey, ')
          ..write('deviceId: $deviceId, ')
          ..write('relatedEventId: $relatedEventId, ')
          ..write('editIds: $editIds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DecryptedTable extends Decrypted
    with TableInfo<$DecryptedTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DecryptedTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<String> roomId = GeneratedColumn<String>(
      'room_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _senderMeta = const VerificationMeta('sender');
  @override
  late final GeneratedColumn<String> sender = GeneratedColumn<String>(
      'sender', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _stateKeyMeta =
      const VerificationMeta('stateKey');
  @override
  late final GeneratedColumn<String> stateKey = GeneratedColumn<String>(
      'state_key', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _prevBatchMeta =
      const VerificationMeta('prevBatch');
  @override
  late final GeneratedColumn<String> prevBatch = GeneratedColumn<String>(
      'prev_batch', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _batchMeta = const VerificationMeta('batch');
  @override
  late final GeneratedColumn<String> batch = GeneratedColumn<String>(
      'batch', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pendingMeta =
      const VerificationMeta('pending');
  @override
  late final GeneratedColumn<bool> pending = GeneratedColumn<bool>(
      'pending', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("pending" IN (0, 1))'));
  static const VerificationMeta _syncingMeta =
      const VerificationMeta('syncing');
  @override
  late final GeneratedColumn<bool> syncing = GeneratedColumn<bool>(
      'syncing', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("syncing" IN (0, 1))'));
  static const VerificationMeta _failedMeta = const VerificationMeta('failed');
  @override
  late final GeneratedColumn<bool> failed = GeneratedColumn<bool>(
      'failed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("failed" IN (0, 1))'));
  static const VerificationMeta _editedMeta = const VerificationMeta('edited');
  @override
  late final GeneratedColumn<bool> edited = GeneratedColumn<bool>(
      'edited', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("edited" IN (0, 1))'));
  static const VerificationMeta _replacementMeta =
      const VerificationMeta('replacement');
  @override
  late final GeneratedColumn<bool> replacement = GeneratedColumn<bool>(
      'replacement', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("replacement" IN (0, 1))'));
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _receivedMeta =
      const VerificationMeta('received');
  @override
  late final GeneratedColumn<int> received = GeneratedColumn<int>(
      'received', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _hasLinkMeta =
      const VerificationMeta('hasLink');
  @override
  late final GeneratedColumn<bool> hasLink = GeneratedColumn<bool>(
      'has_link', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("has_link" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
      'body', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _msgtypeMeta =
      const VerificationMeta('msgtype');
  @override
  late final GeneratedColumn<String> msgtype = GeneratedColumn<String>(
      'msgtype', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
      'format', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _formattedBodyMeta =
      const VerificationMeta('formattedBody');
  @override
  late final GeneratedColumn<String> formattedBody = GeneratedColumn<String>(
      'formatted_body', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>?, String>
      file = GeneratedColumn<String>('file', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<Map<String, dynamic>?>($DecryptedTable.$converterfile);
  static const VerificationMeta _typeDecryptedMeta =
      const VerificationMeta('typeDecrypted');
  @override
  late final GeneratedColumn<String> typeDecrypted = GeneratedColumn<String>(
      'type_decrypted', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ciphertextMeta =
      const VerificationMeta('ciphertext');
  @override
  late final GeneratedColumn<String> ciphertext = GeneratedColumn<String>(
      'ciphertext', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _algorithmMeta =
      const VerificationMeta('algorithm');
  @override
  late final GeneratedColumn<String> algorithm = GeneratedColumn<String>(
      'algorithm', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _senderKeyMeta =
      const VerificationMeta('senderKey');
  @override
  late final GeneratedColumn<String> senderKey = GeneratedColumn<String>(
      'sender_key', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _relatedEventIdMeta =
      const VerificationMeta('relatedEventId');
  @override
  late final GeneratedColumn<String> relatedEventId = GeneratedColumn<String>(
      'related_event_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> editIds =
      GeneratedColumn<String>('edit_ids', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('[]'))
          .withConverter<List<String>>($DecryptedTable.$convertereditIds);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        roomId,
        userId,
        type,
        sender,
        stateKey,
        prevBatch,
        batch,
        pending,
        syncing,
        failed,
        edited,
        replacement,
        timestamp,
        received,
        hasLink,
        body,
        msgtype,
        format,
        formattedBody,
        url,
        file,
        typeDecrypted,
        ciphertext,
        algorithm,
        sessionId,
        senderKey,
        deviceId,
        relatedEventId,
        editIds
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'decrypted';
  @override
  VerificationContext validateIntegrity(Insertable<Message> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('room_id')) {
      context.handle(_roomIdMeta,
          roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('sender')) {
      context.handle(_senderMeta,
          sender.isAcceptableOrUnknown(data['sender']!, _senderMeta));
    }
    if (data.containsKey('state_key')) {
      context.handle(_stateKeyMeta,
          stateKey.isAcceptableOrUnknown(data['state_key']!, _stateKeyMeta));
    }
    if (data.containsKey('prev_batch')) {
      context.handle(_prevBatchMeta,
          prevBatch.isAcceptableOrUnknown(data['prev_batch']!, _prevBatchMeta));
    }
    if (data.containsKey('batch')) {
      context.handle(
          _batchMeta, batch.isAcceptableOrUnknown(data['batch']!, _batchMeta));
    }
    if (data.containsKey('pending')) {
      context.handle(_pendingMeta,
          pending.isAcceptableOrUnknown(data['pending']!, _pendingMeta));
    } else if (isInserting) {
      context.missing(_pendingMeta);
    }
    if (data.containsKey('syncing')) {
      context.handle(_syncingMeta,
          syncing.isAcceptableOrUnknown(data['syncing']!, _syncingMeta));
    } else if (isInserting) {
      context.missing(_syncingMeta);
    }
    if (data.containsKey('failed')) {
      context.handle(_failedMeta,
          failed.isAcceptableOrUnknown(data['failed']!, _failedMeta));
    } else if (isInserting) {
      context.missing(_failedMeta);
    }
    if (data.containsKey('edited')) {
      context.handle(_editedMeta,
          edited.isAcceptableOrUnknown(data['edited']!, _editedMeta));
    } else if (isInserting) {
      context.missing(_editedMeta);
    }
    if (data.containsKey('replacement')) {
      context.handle(
          _replacementMeta,
          replacement.isAcceptableOrUnknown(
              data['replacement']!, _replacementMeta));
    } else if (isInserting) {
      context.missing(_replacementMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('received')) {
      context.handle(_receivedMeta,
          received.isAcceptableOrUnknown(data['received']!, _receivedMeta));
    } else if (isInserting) {
      context.missing(_receivedMeta);
    }
    if (data.containsKey('has_link')) {
      context.handle(_hasLinkMeta,
          hasLink.isAcceptableOrUnknown(data['has_link']!, _hasLinkMeta));
    }
    if (data.containsKey('body')) {
      context.handle(
          _bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    }
    if (data.containsKey('msgtype')) {
      context.handle(_msgtypeMeta,
          msgtype.isAcceptableOrUnknown(data['msgtype']!, _msgtypeMeta));
    }
    if (data.containsKey('format')) {
      context.handle(_formatMeta,
          format.isAcceptableOrUnknown(data['format']!, _formatMeta));
    }
    if (data.containsKey('formatted_body')) {
      context.handle(
          _formattedBodyMeta,
          formattedBody.isAcceptableOrUnknown(
              data['formatted_body']!, _formattedBodyMeta));
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    }
    if (data.containsKey('type_decrypted')) {
      context.handle(
          _typeDecryptedMeta,
          typeDecrypted.isAcceptableOrUnknown(
              data['type_decrypted']!, _typeDecryptedMeta));
    }
    if (data.containsKey('ciphertext')) {
      context.handle(
          _ciphertextMeta,
          ciphertext.isAcceptableOrUnknown(
              data['ciphertext']!, _ciphertextMeta));
    }
    if (data.containsKey('algorithm')) {
      context.handle(_algorithmMeta,
          algorithm.isAcceptableOrUnknown(data['algorithm']!, _algorithmMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    }
    if (data.containsKey('sender_key')) {
      context.handle(_senderKeyMeta,
          senderKey.isAcceptableOrUnknown(data['sender_key']!, _senderKeyMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    }
    if (data.containsKey('related_event_id')) {
      context.handle(
          _relatedEventIdMeta,
          relatedEventId.isAcceptableOrUnknown(
              data['related_event_id']!, _relatedEventIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sender']),
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}timestamp'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type']),
      roomId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}room_id']),
      pending: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}pending'])!,
      syncing: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}syncing'])!,
      failed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}failed'])!,
      edited: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}edited'])!,
      replacement: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}replacement'])!,
      hasLink: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}has_link'])!,
      received: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}received'])!,
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body']),
      msgtype: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}msgtype']),
      format: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}format']),
      formattedBody: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}formatted_body']),
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url']),
      file: $DecryptedTable.$converterfile.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file'])),
      typeDecrypted: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type_decrypted']),
      ciphertext: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ciphertext']),
      algorithm: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}algorithm']),
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id']),
      senderKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sender_key']),
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
      relatedEventId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}related_event_id']),
      editIds: $DecryptedTable.$convertereditIds.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}edit_ids'])!),
    );
  }

  @override
  $DecryptedTable createAlias(String alias) {
    return $DecryptedTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, dynamic>?, String?> $converterfile =
      const MapToJsonConverter();
  static TypeConverter<List<String>, String> $convertereditIds =
      const ListToTextConverter();
}

class DecryptedCompanion extends UpdateCompanion<Message> {
  final Value<String> id;
  final Value<String?> roomId;
  final Value<String?> userId;
  final Value<String?> type;
  final Value<String?> sender;
  final Value<String?> stateKey;
  final Value<String?> prevBatch;
  final Value<String?> batch;
  final Value<bool> pending;
  final Value<bool> syncing;
  final Value<bool> failed;
  final Value<bool> edited;
  final Value<bool> replacement;
  final Value<int> timestamp;
  final Value<int> received;
  final Value<bool> hasLink;
  final Value<String?> body;
  final Value<String?> msgtype;
  final Value<String?> format;
  final Value<String?> formattedBody;
  final Value<String?> url;
  final Value<Map<String, dynamic>?> file;
  final Value<String?> typeDecrypted;
  final Value<String?> ciphertext;
  final Value<String?> algorithm;
  final Value<String?> sessionId;
  final Value<String?> senderKey;
  final Value<String?> deviceId;
  final Value<String?> relatedEventId;
  final Value<List<String>> editIds;
  final Value<int> rowid;
  const DecryptedCompanion({
    this.id = const Value.absent(),
    this.roomId = const Value.absent(),
    this.userId = const Value.absent(),
    this.type = const Value.absent(),
    this.sender = const Value.absent(),
    this.stateKey = const Value.absent(),
    this.prevBatch = const Value.absent(),
    this.batch = const Value.absent(),
    this.pending = const Value.absent(),
    this.syncing = const Value.absent(),
    this.failed = const Value.absent(),
    this.edited = const Value.absent(),
    this.replacement = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.received = const Value.absent(),
    this.hasLink = const Value.absent(),
    this.body = const Value.absent(),
    this.msgtype = const Value.absent(),
    this.format = const Value.absent(),
    this.formattedBody = const Value.absent(),
    this.url = const Value.absent(),
    this.file = const Value.absent(),
    this.typeDecrypted = const Value.absent(),
    this.ciphertext = const Value.absent(),
    this.algorithm = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.senderKey = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.relatedEventId = const Value.absent(),
    this.editIds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DecryptedCompanion.insert({
    required String id,
    this.roomId = const Value.absent(),
    this.userId = const Value.absent(),
    this.type = const Value.absent(),
    this.sender = const Value.absent(),
    this.stateKey = const Value.absent(),
    this.prevBatch = const Value.absent(),
    this.batch = const Value.absent(),
    required bool pending,
    required bool syncing,
    required bool failed,
    required bool edited,
    required bool replacement,
    required int timestamp,
    required int received,
    this.hasLink = const Value.absent(),
    this.body = const Value.absent(),
    this.msgtype = const Value.absent(),
    this.format = const Value.absent(),
    this.formattedBody = const Value.absent(),
    this.url = const Value.absent(),
    this.file = const Value.absent(),
    this.typeDecrypted = const Value.absent(),
    this.ciphertext = const Value.absent(),
    this.algorithm = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.senderKey = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.relatedEventId = const Value.absent(),
    this.editIds = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        pending = Value(pending),
        syncing = Value(syncing),
        failed = Value(failed),
        edited = Value(edited),
        replacement = Value(replacement),
        timestamp = Value(timestamp),
        received = Value(received);
  static Insertable<Message> custom({
    Expression<String>? id,
    Expression<String>? roomId,
    Expression<String>? userId,
    Expression<String>? type,
    Expression<String>? sender,
    Expression<String>? stateKey,
    Expression<String>? prevBatch,
    Expression<String>? batch,
    Expression<bool>? pending,
    Expression<bool>? syncing,
    Expression<bool>? failed,
    Expression<bool>? edited,
    Expression<bool>? replacement,
    Expression<int>? timestamp,
    Expression<int>? received,
    Expression<bool>? hasLink,
    Expression<String>? body,
    Expression<String>? msgtype,
    Expression<String>? format,
    Expression<String>? formattedBody,
    Expression<String>? url,
    Expression<String>? file,
    Expression<String>? typeDecrypted,
    Expression<String>? ciphertext,
    Expression<String>? algorithm,
    Expression<String>? sessionId,
    Expression<String>? senderKey,
    Expression<String>? deviceId,
    Expression<String>? relatedEventId,
    Expression<String>? editIds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (roomId != null) 'room_id': roomId,
      if (userId != null) 'user_id': userId,
      if (type != null) 'type': type,
      if (sender != null) 'sender': sender,
      if (stateKey != null) 'state_key': stateKey,
      if (prevBatch != null) 'prev_batch': prevBatch,
      if (batch != null) 'batch': batch,
      if (pending != null) 'pending': pending,
      if (syncing != null) 'syncing': syncing,
      if (failed != null) 'failed': failed,
      if (edited != null) 'edited': edited,
      if (replacement != null) 'replacement': replacement,
      if (timestamp != null) 'timestamp': timestamp,
      if (received != null) 'received': received,
      if (hasLink != null) 'has_link': hasLink,
      if (body != null) 'body': body,
      if (msgtype != null) 'msgtype': msgtype,
      if (format != null) 'format': format,
      if (formattedBody != null) 'formatted_body': formattedBody,
      if (url != null) 'url': url,
      if (file != null) 'file': file,
      if (typeDecrypted != null) 'type_decrypted': typeDecrypted,
      if (ciphertext != null) 'ciphertext': ciphertext,
      if (algorithm != null) 'algorithm': algorithm,
      if (sessionId != null) 'session_id': sessionId,
      if (senderKey != null) 'sender_key': senderKey,
      if (deviceId != null) 'device_id': deviceId,
      if (relatedEventId != null) 'related_event_id': relatedEventId,
      if (editIds != null) 'edit_ids': editIds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DecryptedCompanion copyWith(
      {Value<String>? id,
      Value<String?>? roomId,
      Value<String?>? userId,
      Value<String?>? type,
      Value<String?>? sender,
      Value<String?>? stateKey,
      Value<String?>? prevBatch,
      Value<String?>? batch,
      Value<bool>? pending,
      Value<bool>? syncing,
      Value<bool>? failed,
      Value<bool>? edited,
      Value<bool>? replacement,
      Value<int>? timestamp,
      Value<int>? received,
      Value<bool>? hasLink,
      Value<String?>? body,
      Value<String?>? msgtype,
      Value<String?>? format,
      Value<String?>? formattedBody,
      Value<String?>? url,
      Value<Map<String, dynamic>?>? file,
      Value<String?>? typeDecrypted,
      Value<String?>? ciphertext,
      Value<String?>? algorithm,
      Value<String?>? sessionId,
      Value<String?>? senderKey,
      Value<String?>? deviceId,
      Value<String?>? relatedEventId,
      Value<List<String>>? editIds,
      Value<int>? rowid}) {
    return DecryptedCompanion(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      sender: sender ?? this.sender,
      stateKey: stateKey ?? this.stateKey,
      prevBatch: prevBatch ?? this.prevBatch,
      batch: batch ?? this.batch,
      pending: pending ?? this.pending,
      syncing: syncing ?? this.syncing,
      failed: failed ?? this.failed,
      edited: edited ?? this.edited,
      replacement: replacement ?? this.replacement,
      timestamp: timestamp ?? this.timestamp,
      received: received ?? this.received,
      hasLink: hasLink ?? this.hasLink,
      body: body ?? this.body,
      msgtype: msgtype ?? this.msgtype,
      format: format ?? this.format,
      formattedBody: formattedBody ?? this.formattedBody,
      url: url ?? this.url,
      file: file ?? this.file,
      typeDecrypted: typeDecrypted ?? this.typeDecrypted,
      ciphertext: ciphertext ?? this.ciphertext,
      algorithm: algorithm ?? this.algorithm,
      sessionId: sessionId ?? this.sessionId,
      senderKey: senderKey ?? this.senderKey,
      deviceId: deviceId ?? this.deviceId,
      relatedEventId: relatedEventId ?? this.relatedEventId,
      editIds: editIds ?? this.editIds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (sender.present) {
      map['sender'] = Variable<String>(sender.value);
    }
    if (stateKey.present) {
      map['state_key'] = Variable<String>(stateKey.value);
    }
    if (prevBatch.present) {
      map['prev_batch'] = Variable<String>(prevBatch.value);
    }
    if (batch.present) {
      map['batch'] = Variable<String>(batch.value);
    }
    if (pending.present) {
      map['pending'] = Variable<bool>(pending.value);
    }
    if (syncing.present) {
      map['syncing'] = Variable<bool>(syncing.value);
    }
    if (failed.present) {
      map['failed'] = Variable<bool>(failed.value);
    }
    if (edited.present) {
      map['edited'] = Variable<bool>(edited.value);
    }
    if (replacement.present) {
      map['replacement'] = Variable<bool>(replacement.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (received.present) {
      map['received'] = Variable<int>(received.value);
    }
    if (hasLink.present) {
      map['has_link'] = Variable<bool>(hasLink.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (msgtype.present) {
      map['msgtype'] = Variable<String>(msgtype.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (formattedBody.present) {
      map['formatted_body'] = Variable<String>(formattedBody.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (file.present) {
      map['file'] =
          Variable<String>($DecryptedTable.$converterfile.toSql(file.value));
    }
    if (typeDecrypted.present) {
      map['type_decrypted'] = Variable<String>(typeDecrypted.value);
    }
    if (ciphertext.present) {
      map['ciphertext'] = Variable<String>(ciphertext.value);
    }
    if (algorithm.present) {
      map['algorithm'] = Variable<String>(algorithm.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (senderKey.present) {
      map['sender_key'] = Variable<String>(senderKey.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (relatedEventId.present) {
      map['related_event_id'] = Variable<String>(relatedEventId.value);
    }
    if (editIds.present) {
      map['edit_ids'] = Variable<String>(
          $DecryptedTable.$convertereditIds.toSql(editIds.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DecryptedCompanion(')
          ..write('id: $id, ')
          ..write('roomId: $roomId, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('sender: $sender, ')
          ..write('stateKey: $stateKey, ')
          ..write('prevBatch: $prevBatch, ')
          ..write('batch: $batch, ')
          ..write('pending: $pending, ')
          ..write('syncing: $syncing, ')
          ..write('failed: $failed, ')
          ..write('edited: $edited, ')
          ..write('replacement: $replacement, ')
          ..write('timestamp: $timestamp, ')
          ..write('received: $received, ')
          ..write('hasLink: $hasLink, ')
          ..write('body: $body, ')
          ..write('msgtype: $msgtype, ')
          ..write('format: $format, ')
          ..write('formattedBody: $formattedBody, ')
          ..write('url: $url, ')
          ..write('file: $file, ')
          ..write('typeDecrypted: $typeDecrypted, ')
          ..write('ciphertext: $ciphertext, ')
          ..write('algorithm: $algorithm, ')
          ..write('sessionId: $sessionId, ')
          ..write('senderKey: $senderKey, ')
          ..write('deviceId: $deviceId, ')
          ..write('relatedEventId: $relatedEventId, ')
          ..write('editIds: $editIds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoomsTable extends Rooms with TableInfo<$RoomsTable, Room> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoomsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _aliasMeta = const VerificationMeta('alias');
  @override
  late final GeneratedColumn<String> alias = GeneratedColumn<String>(
      'alias', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _homeserverMeta =
      const VerificationMeta('homeserver');
  @override
  late final GeneratedColumn<String> homeserver = GeneratedColumn<String>(
      'homeserver', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _avatarUriMeta =
      const VerificationMeta('avatarUri');
  @override
  late final GeneratedColumn<String> avatarUri = GeneratedColumn<String>(
      'avatar_uri', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _topicMeta = const VerificationMeta('topic');
  @override
  late final GeneratedColumn<String> topic = GeneratedColumn<String>(
      'topic', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _joinRuleMeta =
      const VerificationMeta('joinRule');
  @override
  late final GeneratedColumn<String> joinRule = GeneratedColumn<String>(
      'join_rule', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _draftingMeta =
      const VerificationMeta('drafting');
  @override
  late final GeneratedColumn<bool> drafting = GeneratedColumn<bool>(
      'drafting', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("drafting" IN (0, 1))'));
  static const VerificationMeta _directMeta = const VerificationMeta('direct');
  @override
  late final GeneratedColumn<bool> direct = GeneratedColumn<bool>(
      'direct', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("direct" IN (0, 1))'));
  static const VerificationMeta _sendingMeta =
      const VerificationMeta('sending');
  @override
  late final GeneratedColumn<bool> sending = GeneratedColumn<bool>(
      'sending', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("sending" IN (0, 1))'));
  static const VerificationMeta _inviteMeta = const VerificationMeta('invite');
  @override
  late final GeneratedColumn<bool> invite = GeneratedColumn<bool>(
      'invite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("invite" IN (0, 1))'));
  static const VerificationMeta _guestEnabledMeta =
      const VerificationMeta('guestEnabled');
  @override
  late final GeneratedColumn<bool> guestEnabled = GeneratedColumn<bool>(
      'guest_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("guest_enabled" IN (0, 1))'));
  static const VerificationMeta _encryptionEnabledMeta =
      const VerificationMeta('encryptionEnabled');
  @override
  late final GeneratedColumn<bool> encryptionEnabled = GeneratedColumn<bool>(
      'encryption_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("encryption_enabled" IN (0, 1))'));
  static const VerificationMeta _worldReadableMeta =
      const VerificationMeta('worldReadable');
  @override
  late final GeneratedColumn<bool> worldReadable = GeneratedColumn<bool>(
      'world_readable', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("world_readable" IN (0, 1))'));
  static const VerificationMeta _hiddenMeta = const VerificationMeta('hidden');
  @override
  late final GeneratedColumn<bool> hidden = GeneratedColumn<bool>(
      'hidden', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("hidden" IN (0, 1))'));
  static const VerificationMeta _archivedMeta =
      const VerificationMeta('archived');
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
      'archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("archived" IN (0, 1))'));
  static const VerificationMeta _lastBatchMeta =
      const VerificationMeta('lastBatch');
  @override
  late final GeneratedColumn<String> lastBatch = GeneratedColumn<String>(
      'last_batch', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _prevBatchMeta =
      const VerificationMeta('prevBatch');
  @override
  late final GeneratedColumn<String> prevBatch = GeneratedColumn<String>(
      'prev_batch', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nextBatchMeta =
      const VerificationMeta('nextBatch');
  @override
  late final GeneratedColumn<String> nextBatch = GeneratedColumn<String>(
      'next_batch', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastReadMeta =
      const VerificationMeta('lastRead');
  @override
  late final GeneratedColumn<int> lastRead = GeneratedColumn<int>(
      'last_read', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastUpdateMeta =
      const VerificationMeta('lastUpdate');
  @override
  late final GeneratedColumn<int> lastUpdate = GeneratedColumn<int>(
      'last_update', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalJoinedUsersMeta =
      const VerificationMeta('totalJoinedUsers');
  @override
  late final GeneratedColumn<int> totalJoinedUsers = GeneratedColumn<int>(
      'total_joined_users', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _namePriorityMeta =
      const VerificationMeta('namePriority');
  @override
  late final GeneratedColumn<int> namePriority = GeneratedColumn<int>(
      'name_priority', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(4));
  @override
  late final GeneratedColumnWithTypeConverter<Message?, String> draft =
      GeneratedColumn<String>('draft', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<Message?>($RoomsTable.$converterdraft);
  @override
  late final GeneratedColumnWithTypeConverter<Message?, String> reply =
      GeneratedColumn<String>('reply', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<Message?>($RoomsTable.$converterreply);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> userIds =
      GeneratedColumn<String>('user_ids', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('[]'))
          .withConverter<List<String>>($RoomsTable.$converteruserIds);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        alias,
        homeserver,
        avatarUri,
        topic,
        joinRule,
        drafting,
        direct,
        sending,
        invite,
        guestEnabled,
        encryptionEnabled,
        worldReadable,
        hidden,
        archived,
        lastBatch,
        prevBatch,
        nextBatch,
        lastRead,
        lastUpdate,
        totalJoinedUsers,
        namePriority,
        draft,
        reply,
        userIds
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rooms';
  @override
  VerificationContext validateIntegrity(Insertable<Room> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('alias')) {
      context.handle(
          _aliasMeta, alias.isAcceptableOrUnknown(data['alias']!, _aliasMeta));
    }
    if (data.containsKey('homeserver')) {
      context.handle(
          _homeserverMeta,
          homeserver.isAcceptableOrUnknown(
              data['homeserver']!, _homeserverMeta));
    }
    if (data.containsKey('avatar_uri')) {
      context.handle(_avatarUriMeta,
          avatarUri.isAcceptableOrUnknown(data['avatar_uri']!, _avatarUriMeta));
    }
    if (data.containsKey('topic')) {
      context.handle(
          _topicMeta, topic.isAcceptableOrUnknown(data['topic']!, _topicMeta));
    }
    if (data.containsKey('join_rule')) {
      context.handle(_joinRuleMeta,
          joinRule.isAcceptableOrUnknown(data['join_rule']!, _joinRuleMeta));
    }
    if (data.containsKey('drafting')) {
      context.handle(_draftingMeta,
          drafting.isAcceptableOrUnknown(data['drafting']!, _draftingMeta));
    } else if (isInserting) {
      context.missing(_draftingMeta);
    }
    if (data.containsKey('direct')) {
      context.handle(_directMeta,
          direct.isAcceptableOrUnknown(data['direct']!, _directMeta));
    } else if (isInserting) {
      context.missing(_directMeta);
    }
    if (data.containsKey('sending')) {
      context.handle(_sendingMeta,
          sending.isAcceptableOrUnknown(data['sending']!, _sendingMeta));
    } else if (isInserting) {
      context.missing(_sendingMeta);
    }
    if (data.containsKey('invite')) {
      context.handle(_inviteMeta,
          invite.isAcceptableOrUnknown(data['invite']!, _inviteMeta));
    } else if (isInserting) {
      context.missing(_inviteMeta);
    }
    if (data.containsKey('guest_enabled')) {
      context.handle(
          _guestEnabledMeta,
          guestEnabled.isAcceptableOrUnknown(
              data['guest_enabled']!, _guestEnabledMeta));
    } else if (isInserting) {
      context.missing(_guestEnabledMeta);
    }
    if (data.containsKey('encryption_enabled')) {
      context.handle(
          _encryptionEnabledMeta,
          encryptionEnabled.isAcceptableOrUnknown(
              data['encryption_enabled']!, _encryptionEnabledMeta));
    } else if (isInserting) {
      context.missing(_encryptionEnabledMeta);
    }
    if (data.containsKey('world_readable')) {
      context.handle(
          _worldReadableMeta,
          worldReadable.isAcceptableOrUnknown(
              data['world_readable']!, _worldReadableMeta));
    } else if (isInserting) {
      context.missing(_worldReadableMeta);
    }
    if (data.containsKey('hidden')) {
      context.handle(_hiddenMeta,
          hidden.isAcceptableOrUnknown(data['hidden']!, _hiddenMeta));
    } else if (isInserting) {
      context.missing(_hiddenMeta);
    }
    if (data.containsKey('archived')) {
      context.handle(_archivedMeta,
          archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta));
    } else if (isInserting) {
      context.missing(_archivedMeta);
    }
    if (data.containsKey('last_batch')) {
      context.handle(_lastBatchMeta,
          lastBatch.isAcceptableOrUnknown(data['last_batch']!, _lastBatchMeta));
    }
    if (data.containsKey('prev_batch')) {
      context.handle(_prevBatchMeta,
          prevBatch.isAcceptableOrUnknown(data['prev_batch']!, _prevBatchMeta));
    }
    if (data.containsKey('next_batch')) {
      context.handle(_nextBatchMeta,
          nextBatch.isAcceptableOrUnknown(data['next_batch']!, _nextBatchMeta));
    }
    if (data.containsKey('last_read')) {
      context.handle(_lastReadMeta,
          lastRead.isAcceptableOrUnknown(data['last_read']!, _lastReadMeta));
    }
    if (data.containsKey('last_update')) {
      context.handle(
          _lastUpdateMeta,
          lastUpdate.isAcceptableOrUnknown(
              data['last_update']!, _lastUpdateMeta));
    }
    if (data.containsKey('total_joined_users')) {
      context.handle(
          _totalJoinedUsersMeta,
          totalJoinedUsers.isAcceptableOrUnknown(
              data['total_joined_users']!, _totalJoinedUsersMeta));
    }
    if (data.containsKey('name_priority')) {
      context.handle(
          _namePriorityMeta,
          namePriority.isAcceptableOrUnknown(
              data['name_priority']!, _namePriorityMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Room map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Room(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      alias: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}alias']),
      homeserver: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}homeserver']),
      avatarUri: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_uri']),
      topic: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}topic']),
      joinRule: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}join_rule']),
      drafting: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}drafting'])!,
      invite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}invite'])!,
      direct: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}direct'])!,
      sending: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}sending'])!,
      hidden: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}hidden'])!,
      archived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}archived'])!,
      draft: $RoomsTable.$converterdraft.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}draft'])),
      reply: $RoomsTable.$converterreply.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reply'])),
      userIds: $RoomsTable.$converteruserIds.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_ids'])!),
      lastRead: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_read'])!,
      lastUpdate: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_update'])!,
      namePriority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}name_priority'])!,
      totalJoinedUsers: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}total_joined_users'])!,
      guestEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}guest_enabled'])!,
      encryptionEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}encryption_enabled'])!,
      worldReadable: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}world_readable'])!,
      lastBatch: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_batch']),
      nextBatch: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}next_batch']),
      prevBatch: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}prev_batch']),
    );
  }

  @override
  $RoomsTable createAlias(String alias) {
    return $RoomsTable(attachedDatabase, alias);
  }

  static TypeConverter<Message?, String?> $converterdraft =
      const MessageToJsonConverter();
  static TypeConverter<Message?, String?> $converterreply =
      const MessageToJsonConverter();
  static TypeConverter<List<String>, String> $converteruserIds =
      const ListToTextConverter();
}

class RoomsCompanion extends UpdateCompanion<Room> {
  final Value<String> id;
  final Value<String?> name;
  final Value<String?> alias;
  final Value<String?> homeserver;
  final Value<String?> avatarUri;
  final Value<String?> topic;
  final Value<String?> joinRule;
  final Value<bool> drafting;
  final Value<bool> direct;
  final Value<bool> sending;
  final Value<bool> invite;
  final Value<bool> guestEnabled;
  final Value<bool> encryptionEnabled;
  final Value<bool> worldReadable;
  final Value<bool> hidden;
  final Value<bool> archived;
  final Value<String?> lastBatch;
  final Value<String?> prevBatch;
  final Value<String?> nextBatch;
  final Value<int> lastRead;
  final Value<int> lastUpdate;
  final Value<int> totalJoinedUsers;
  final Value<int> namePriority;
  final Value<Message?> draft;
  final Value<Message?> reply;
  final Value<List<String>> userIds;
  final Value<int> rowid;
  const RoomsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.alias = const Value.absent(),
    this.homeserver = const Value.absent(),
    this.avatarUri = const Value.absent(),
    this.topic = const Value.absent(),
    this.joinRule = const Value.absent(),
    this.drafting = const Value.absent(),
    this.direct = const Value.absent(),
    this.sending = const Value.absent(),
    this.invite = const Value.absent(),
    this.guestEnabled = const Value.absent(),
    this.encryptionEnabled = const Value.absent(),
    this.worldReadable = const Value.absent(),
    this.hidden = const Value.absent(),
    this.archived = const Value.absent(),
    this.lastBatch = const Value.absent(),
    this.prevBatch = const Value.absent(),
    this.nextBatch = const Value.absent(),
    this.lastRead = const Value.absent(),
    this.lastUpdate = const Value.absent(),
    this.totalJoinedUsers = const Value.absent(),
    this.namePriority = const Value.absent(),
    this.draft = const Value.absent(),
    this.reply = const Value.absent(),
    this.userIds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoomsCompanion.insert({
    required String id,
    this.name = const Value.absent(),
    this.alias = const Value.absent(),
    this.homeserver = const Value.absent(),
    this.avatarUri = const Value.absent(),
    this.topic = const Value.absent(),
    this.joinRule = const Value.absent(),
    required bool drafting,
    required bool direct,
    required bool sending,
    required bool invite,
    required bool guestEnabled,
    required bool encryptionEnabled,
    required bool worldReadable,
    required bool hidden,
    required bool archived,
    this.lastBatch = const Value.absent(),
    this.prevBatch = const Value.absent(),
    this.nextBatch = const Value.absent(),
    this.lastRead = const Value.absent(),
    this.lastUpdate = const Value.absent(),
    this.totalJoinedUsers = const Value.absent(),
    this.namePriority = const Value.absent(),
    this.draft = const Value.absent(),
    this.reply = const Value.absent(),
    this.userIds = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        drafting = Value(drafting),
        direct = Value(direct),
        sending = Value(sending),
        invite = Value(invite),
        guestEnabled = Value(guestEnabled),
        encryptionEnabled = Value(encryptionEnabled),
        worldReadable = Value(worldReadable),
        hidden = Value(hidden),
        archived = Value(archived);
  static Insertable<Room> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? alias,
    Expression<String>? homeserver,
    Expression<String>? avatarUri,
    Expression<String>? topic,
    Expression<String>? joinRule,
    Expression<bool>? drafting,
    Expression<bool>? direct,
    Expression<bool>? sending,
    Expression<bool>? invite,
    Expression<bool>? guestEnabled,
    Expression<bool>? encryptionEnabled,
    Expression<bool>? worldReadable,
    Expression<bool>? hidden,
    Expression<bool>? archived,
    Expression<String>? lastBatch,
    Expression<String>? prevBatch,
    Expression<String>? nextBatch,
    Expression<int>? lastRead,
    Expression<int>? lastUpdate,
    Expression<int>? totalJoinedUsers,
    Expression<int>? namePriority,
    Expression<String>? draft,
    Expression<String>? reply,
    Expression<String>? userIds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (alias != null) 'alias': alias,
      if (homeserver != null) 'homeserver': homeserver,
      if (avatarUri != null) 'avatar_uri': avatarUri,
      if (topic != null) 'topic': topic,
      if (joinRule != null) 'join_rule': joinRule,
      if (drafting != null) 'drafting': drafting,
      if (direct != null) 'direct': direct,
      if (sending != null) 'sending': sending,
      if (invite != null) 'invite': invite,
      if (guestEnabled != null) 'guest_enabled': guestEnabled,
      if (encryptionEnabled != null) 'encryption_enabled': encryptionEnabled,
      if (worldReadable != null) 'world_readable': worldReadable,
      if (hidden != null) 'hidden': hidden,
      if (archived != null) 'archived': archived,
      if (lastBatch != null) 'last_batch': lastBatch,
      if (prevBatch != null) 'prev_batch': prevBatch,
      if (nextBatch != null) 'next_batch': nextBatch,
      if (lastRead != null) 'last_read': lastRead,
      if (lastUpdate != null) 'last_update': lastUpdate,
      if (totalJoinedUsers != null) 'total_joined_users': totalJoinedUsers,
      if (namePriority != null) 'name_priority': namePriority,
      if (draft != null) 'draft': draft,
      if (reply != null) 'reply': reply,
      if (userIds != null) 'user_ids': userIds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoomsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? name,
      Value<String?>? alias,
      Value<String?>? homeserver,
      Value<String?>? avatarUri,
      Value<String?>? topic,
      Value<String?>? joinRule,
      Value<bool>? drafting,
      Value<bool>? direct,
      Value<bool>? sending,
      Value<bool>? invite,
      Value<bool>? guestEnabled,
      Value<bool>? encryptionEnabled,
      Value<bool>? worldReadable,
      Value<bool>? hidden,
      Value<bool>? archived,
      Value<String?>? lastBatch,
      Value<String?>? prevBatch,
      Value<String?>? nextBatch,
      Value<int>? lastRead,
      Value<int>? lastUpdate,
      Value<int>? totalJoinedUsers,
      Value<int>? namePriority,
      Value<Message?>? draft,
      Value<Message?>? reply,
      Value<List<String>>? userIds,
      Value<int>? rowid}) {
    return RoomsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      alias: alias ?? this.alias,
      homeserver: homeserver ?? this.homeserver,
      avatarUri: avatarUri ?? this.avatarUri,
      topic: topic ?? this.topic,
      joinRule: joinRule ?? this.joinRule,
      drafting: drafting ?? this.drafting,
      direct: direct ?? this.direct,
      sending: sending ?? this.sending,
      invite: invite ?? this.invite,
      guestEnabled: guestEnabled ?? this.guestEnabled,
      encryptionEnabled: encryptionEnabled ?? this.encryptionEnabled,
      worldReadable: worldReadable ?? this.worldReadable,
      hidden: hidden ?? this.hidden,
      archived: archived ?? this.archived,
      lastBatch: lastBatch ?? this.lastBatch,
      prevBatch: prevBatch ?? this.prevBatch,
      nextBatch: nextBatch ?? this.nextBatch,
      lastRead: lastRead ?? this.lastRead,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      totalJoinedUsers: totalJoinedUsers ?? this.totalJoinedUsers,
      namePriority: namePriority ?? this.namePriority,
      draft: draft ?? this.draft,
      reply: reply ?? this.reply,
      userIds: userIds ?? this.userIds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (alias.present) {
      map['alias'] = Variable<String>(alias.value);
    }
    if (homeserver.present) {
      map['homeserver'] = Variable<String>(homeserver.value);
    }
    if (avatarUri.present) {
      map['avatar_uri'] = Variable<String>(avatarUri.value);
    }
    if (topic.present) {
      map['topic'] = Variable<String>(topic.value);
    }
    if (joinRule.present) {
      map['join_rule'] = Variable<String>(joinRule.value);
    }
    if (drafting.present) {
      map['drafting'] = Variable<bool>(drafting.value);
    }
    if (direct.present) {
      map['direct'] = Variable<bool>(direct.value);
    }
    if (sending.present) {
      map['sending'] = Variable<bool>(sending.value);
    }
    if (invite.present) {
      map['invite'] = Variable<bool>(invite.value);
    }
    if (guestEnabled.present) {
      map['guest_enabled'] = Variable<bool>(guestEnabled.value);
    }
    if (encryptionEnabled.present) {
      map['encryption_enabled'] = Variable<bool>(encryptionEnabled.value);
    }
    if (worldReadable.present) {
      map['world_readable'] = Variable<bool>(worldReadable.value);
    }
    if (hidden.present) {
      map['hidden'] = Variable<bool>(hidden.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (lastBatch.present) {
      map['last_batch'] = Variable<String>(lastBatch.value);
    }
    if (prevBatch.present) {
      map['prev_batch'] = Variable<String>(prevBatch.value);
    }
    if (nextBatch.present) {
      map['next_batch'] = Variable<String>(nextBatch.value);
    }
    if (lastRead.present) {
      map['last_read'] = Variable<int>(lastRead.value);
    }
    if (lastUpdate.present) {
      map['last_update'] = Variable<int>(lastUpdate.value);
    }
    if (totalJoinedUsers.present) {
      map['total_joined_users'] = Variable<int>(totalJoinedUsers.value);
    }
    if (namePriority.present) {
      map['name_priority'] = Variable<int>(namePriority.value);
    }
    if (draft.present) {
      map['draft'] =
          Variable<String>($RoomsTable.$converterdraft.toSql(draft.value));
    }
    if (reply.present) {
      map['reply'] =
          Variable<String>($RoomsTable.$converterreply.toSql(reply.value));
    }
    if (userIds.present) {
      map['user_ids'] =
          Variable<String>($RoomsTable.$converteruserIds.toSql(userIds.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoomsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('alias: $alias, ')
          ..write('homeserver: $homeserver, ')
          ..write('avatarUri: $avatarUri, ')
          ..write('topic: $topic, ')
          ..write('joinRule: $joinRule, ')
          ..write('drafting: $drafting, ')
          ..write('direct: $direct, ')
          ..write('sending: $sending, ')
          ..write('invite: $invite, ')
          ..write('guestEnabled: $guestEnabled, ')
          ..write('encryptionEnabled: $encryptionEnabled, ')
          ..write('worldReadable: $worldReadable, ')
          ..write('hidden: $hidden, ')
          ..write('archived: $archived, ')
          ..write('lastBatch: $lastBatch, ')
          ..write('prevBatch: $prevBatch, ')
          ..write('nextBatch: $nextBatch, ')
          ..write('lastRead: $lastRead, ')
          ..write('lastUpdate: $lastUpdate, ')
          ..write('totalJoinedUsers: $totalJoinedUsers, ')
          ..write('namePriority: $namePriority, ')
          ..write('draft: $draft, ')
          ..write('reply: $reply, ')
          ..write('userIds: $userIds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _idserverMeta =
      const VerificationMeta('idserver');
  @override
  late final GeneratedColumn<String> idserver = GeneratedColumn<String>(
      'idserver', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _homeserverMeta =
      const VerificationMeta('homeserver');
  @override
  late final GeneratedColumn<String> homeserver = GeneratedColumn<String>(
      'homeserver', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _homeserverNameMeta =
      const VerificationMeta('homeserverName');
  @override
  late final GeneratedColumn<String> homeserverName = GeneratedColumn<String>(
      'homeserver_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _accessTokenMeta =
      const VerificationMeta('accessToken');
  @override
  late final GeneratedColumn<String> accessToken = GeneratedColumn<String>(
      'access_token', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _avatarUriMeta =
      const VerificationMeta('avatarUri');
  @override
  late final GeneratedColumn<String> avatarUri = GeneratedColumn<String>(
      'avatar_uri', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        userId,
        deviceId,
        idserver,
        homeserver,
        homeserverName,
        accessToken,
        displayName,
        avatarUri
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<User> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(
          _userIdMeta, userId.isAcceptableOrUnknown(data['id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    }
    if (data.containsKey('idserver')) {
      context.handle(_idserverMeta,
          idserver.isAcceptableOrUnknown(data['idserver']!, _idserverMeta));
    }
    if (data.containsKey('homeserver')) {
      context.handle(
          _homeserverMeta,
          homeserver.isAcceptableOrUnknown(
              data['homeserver']!, _homeserverMeta));
    }
    if (data.containsKey('homeserver_name')) {
      context.handle(
          _homeserverNameMeta,
          homeserverName.isAcceptableOrUnknown(
              data['homeserver_name']!, _homeserverNameMeta));
    }
    if (data.containsKey('access_token')) {
      context.handle(
          _accessTokenMeta,
          accessToken.isAcceptableOrUnknown(
              data['access_token']!, _accessTokenMeta));
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    }
    if (data.containsKey('avatar_uri')) {
      context.handle(_avatarUriMeta,
          avatarUri.isAcceptableOrUnknown(data['avatar_uri']!, _avatarUriMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id']),
      idserver: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}idserver']),
      homeserver: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}homeserver']),
      homeserverName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}homeserver_name']),
      accessToken: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}access_token']),
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name']),
      avatarUri: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_uri']),
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> userId;
  final Value<String?> deviceId;
  final Value<String?> idserver;
  final Value<String?> homeserver;
  final Value<String?> homeserverName;
  final Value<String?> accessToken;
  final Value<String?> displayName;
  final Value<String?> avatarUri;
  final Value<int> rowid;
  const UsersCompanion({
    this.userId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.idserver = const Value.absent(),
    this.homeserver = const Value.absent(),
    this.homeserverName = const Value.absent(),
    this.accessToken = const Value.absent(),
    this.displayName = const Value.absent(),
    this.avatarUri = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String userId,
    this.deviceId = const Value.absent(),
    this.idserver = const Value.absent(),
    this.homeserver = const Value.absent(),
    this.homeserverName = const Value.absent(),
    this.accessToken = const Value.absent(),
    this.displayName = const Value.absent(),
    this.avatarUri = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId);
  static Insertable<User> custom({
    Expression<String>? userId,
    Expression<String>? deviceId,
    Expression<String>? idserver,
    Expression<String>? homeserver,
    Expression<String>? homeserverName,
    Expression<String>? accessToken,
    Expression<String>? displayName,
    Expression<String>? avatarUri,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'id': userId,
      if (deviceId != null) 'device_id': deviceId,
      if (idserver != null) 'idserver': idserver,
      if (homeserver != null) 'homeserver': homeserver,
      if (homeserverName != null) 'homeserver_name': homeserverName,
      if (accessToken != null) 'access_token': accessToken,
      if (displayName != null) 'display_name': displayName,
      if (avatarUri != null) 'avatar_uri': avatarUri,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith(
      {Value<String>? userId,
      Value<String?>? deviceId,
      Value<String?>? idserver,
      Value<String?>? homeserver,
      Value<String?>? homeserverName,
      Value<String?>? accessToken,
      Value<String?>? displayName,
      Value<String?>? avatarUri,
      Value<int>? rowid}) {
    return UsersCompanion(
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      idserver: idserver ?? this.idserver,
      homeserver: homeserver ?? this.homeserver,
      homeserverName: homeserverName ?? this.homeserverName,
      accessToken: accessToken ?? this.accessToken,
      displayName: displayName ?? this.displayName,
      avatarUri: avatarUri ?? this.avatarUri,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['id'] = Variable<String>(userId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (idserver.present) {
      map['idserver'] = Variable<String>(idserver.value);
    }
    if (homeserver.present) {
      map['homeserver'] = Variable<String>(homeserver.value);
    }
    if (homeserverName.present) {
      map['homeserver_name'] = Variable<String>(homeserverName.value);
    }
    if (accessToken.present) {
      map['access_token'] = Variable<String>(accessToken.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (avatarUri.present) {
      map['avatar_uri'] = Variable<String>(avatarUri.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('userId: $userId, ')
          ..write('deviceId: $deviceId, ')
          ..write('idserver: $idserver, ')
          ..write('homeserver: $homeserver, ')
          ..write('homeserverName: $homeserverName, ')
          ..write('accessToken: $accessToken, ')
          ..write('displayName: $displayName, ')
          ..write('avatarUri: $avatarUri, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MediasTable extends Medias with TableInfo<$MediasTable, Media> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _mxcUriMeta = const VerificationMeta('mxcUri');
  @override
  late final GeneratedColumn<String> mxcUri = GeneratedColumn<String>(
      'mxc_uri', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<Uint8List> data = GeneratedColumn<Uint8List>(
      'data', aliasedName, true,
      type: DriftSqlType.blob, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<EncryptInfo?, String> info =
      GeneratedColumn<String>('info', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<EncryptInfo?>($MediasTable.$converterinfo);
  @override
  List<GeneratedColumn> get $columns => [mxcUri, data, type, info];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medias';
  @override
  VerificationContext validateIntegrity(Insertable<Media> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('mxc_uri')) {
      context.handle(_mxcUriMeta,
          mxcUri.isAcceptableOrUnknown(data['mxc_uri']!, _mxcUriMeta));
    } else if (isInserting) {
      context.missing(_mxcUriMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {mxcUri};
  @override
  Media map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Media(
      mxcUri: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mxc_uri'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type']),
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}data']),
      info: $MediasTable.$converterinfo.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}info'])),
    );
  }

  @override
  $MediasTable createAlias(String alias) {
    return $MediasTable(attachedDatabase, alias);
  }

  static TypeConverter<EncryptInfo?, String?> $converterinfo =
      const EncryptInfoToJsonConverter();
}

class MediasCompanion extends UpdateCompanion<Media> {
  final Value<String> mxcUri;
  final Value<Uint8List?> data;
  final Value<String?> type;
  final Value<EncryptInfo?> info;
  final Value<int> rowid;
  const MediasCompanion({
    this.mxcUri = const Value.absent(),
    this.data = const Value.absent(),
    this.type = const Value.absent(),
    this.info = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MediasCompanion.insert({
    required String mxcUri,
    this.data = const Value.absent(),
    this.type = const Value.absent(),
    this.info = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : mxcUri = Value(mxcUri);
  static Insertable<Media> custom({
    Expression<String>? mxcUri,
    Expression<Uint8List>? data,
    Expression<String>? type,
    Expression<String>? info,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (mxcUri != null) 'mxc_uri': mxcUri,
      if (data != null) 'data': data,
      if (type != null) 'type': type,
      if (info != null) 'info': info,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MediasCompanion copyWith(
      {Value<String>? mxcUri,
      Value<Uint8List?>? data,
      Value<String?>? type,
      Value<EncryptInfo?>? info,
      Value<int>? rowid}) {
    return MediasCompanion(
      mxcUri: mxcUri ?? this.mxcUri,
      data: data ?? this.data,
      type: type ?? this.type,
      info: info ?? this.info,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (mxcUri.present) {
      map['mxc_uri'] = Variable<String>(mxcUri.value);
    }
    if (data.present) {
      map['data'] = Variable<Uint8List>(data.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (info.present) {
      map['info'] =
          Variable<String>($MediasTable.$converterinfo.toSql(info.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediasCompanion(')
          ..write('mxcUri: $mxcUri, ')
          ..write('data: $data, ')
          ..write('type: $type, ')
          ..write('info: $info, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReactionsTable extends Reactions
    with TableInfo<$ReactionsTable, Reaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<String> roomId = GeneratedColumn<String>(
      'room_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _senderMeta = const VerificationMeta('sender');
  @override
  late final GeneratedColumn<String> sender = GeneratedColumn<String>(
      'sender', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _stateKeyMeta =
      const VerificationMeta('stateKey');
  @override
  late final GeneratedColumn<String> stateKey = GeneratedColumn<String>(
      'state_key', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _batchMeta = const VerificationMeta('batch');
  @override
  late final GeneratedColumn<String> batch = GeneratedColumn<String>(
      'batch', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _prevBatchMeta =
      const VerificationMeta('prevBatch');
  @override
  late final GeneratedColumn<String> prevBatch = GeneratedColumn<String>(
      'prev_batch', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
      'body', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _relTypeMeta =
      const VerificationMeta('relType');
  @override
  late final GeneratedColumn<String> relType = GeneratedColumn<String>(
      'rel_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _relEventIdMeta =
      const VerificationMeta('relEventId');
  @override
  late final GeneratedColumn<String> relEventId = GeneratedColumn<String>(
      'rel_event_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        roomId,
        userId,
        type,
        sender,
        stateKey,
        batch,
        prevBatch,
        timestamp,
        body,
        relType,
        relEventId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reactions';
  @override
  VerificationContext validateIntegrity(Insertable<Reaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('room_id')) {
      context.handle(_roomIdMeta,
          roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('sender')) {
      context.handle(_senderMeta,
          sender.isAcceptableOrUnknown(data['sender']!, _senderMeta));
    }
    if (data.containsKey('state_key')) {
      context.handle(_stateKeyMeta,
          stateKey.isAcceptableOrUnknown(data['state_key']!, _stateKeyMeta));
    }
    if (data.containsKey('batch')) {
      context.handle(
          _batchMeta, batch.isAcceptableOrUnknown(data['batch']!, _batchMeta));
    }
    if (data.containsKey('prev_batch')) {
      context.handle(_prevBatchMeta,
          prevBatch.isAcceptableOrUnknown(data['prev_batch']!, _prevBatchMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
          _bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    }
    if (data.containsKey('rel_type')) {
      context.handle(_relTypeMeta,
          relType.isAcceptableOrUnknown(data['rel_type']!, _relTypeMeta));
    }
    if (data.containsKey('rel_event_id')) {
      context.handle(
          _relEventIdMeta,
          relEventId.isAcceptableOrUnknown(
              data['rel_event_id']!, _relEventIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id']),
      roomId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}room_id']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type']),
      sender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sender']),
      stateKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}state_key']),
      batch: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}batch']),
      prevBatch: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}prev_batch']),
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}timestamp'])!,
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body']),
      relType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rel_type']),
      relEventId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rel_event_id']),
    );
  }

  @override
  $ReactionsTable createAlias(String alias) {
    return $ReactionsTable(attachedDatabase, alias);
  }
}

class ReactionsCompanion extends UpdateCompanion<Reaction> {
  final Value<String> id;
  final Value<String?> roomId;
  final Value<String?> userId;
  final Value<String?> type;
  final Value<String?> sender;
  final Value<String?> stateKey;
  final Value<String?> batch;
  final Value<String?> prevBatch;
  final Value<int> timestamp;
  final Value<String?> body;
  final Value<String?> relType;
  final Value<String?> relEventId;
  final Value<int> rowid;
  const ReactionsCompanion({
    this.id = const Value.absent(),
    this.roomId = const Value.absent(),
    this.userId = const Value.absent(),
    this.type = const Value.absent(),
    this.sender = const Value.absent(),
    this.stateKey = const Value.absent(),
    this.batch = const Value.absent(),
    this.prevBatch = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.body = const Value.absent(),
    this.relType = const Value.absent(),
    this.relEventId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReactionsCompanion.insert({
    required String id,
    this.roomId = const Value.absent(),
    this.userId = const Value.absent(),
    this.type = const Value.absent(),
    this.sender = const Value.absent(),
    this.stateKey = const Value.absent(),
    this.batch = const Value.absent(),
    this.prevBatch = const Value.absent(),
    required int timestamp,
    this.body = const Value.absent(),
    this.relType = const Value.absent(),
    this.relEventId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        timestamp = Value(timestamp);
  static Insertable<Reaction> custom({
    Expression<String>? id,
    Expression<String>? roomId,
    Expression<String>? userId,
    Expression<String>? type,
    Expression<String>? sender,
    Expression<String>? stateKey,
    Expression<String>? batch,
    Expression<String>? prevBatch,
    Expression<int>? timestamp,
    Expression<String>? body,
    Expression<String>? relType,
    Expression<String>? relEventId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (roomId != null) 'room_id': roomId,
      if (userId != null) 'user_id': userId,
      if (type != null) 'type': type,
      if (sender != null) 'sender': sender,
      if (stateKey != null) 'state_key': stateKey,
      if (batch != null) 'batch': batch,
      if (prevBatch != null) 'prev_batch': prevBatch,
      if (timestamp != null) 'timestamp': timestamp,
      if (body != null) 'body': body,
      if (relType != null) 'rel_type': relType,
      if (relEventId != null) 'rel_event_id': relEventId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReactionsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? roomId,
      Value<String?>? userId,
      Value<String?>? type,
      Value<String?>? sender,
      Value<String?>? stateKey,
      Value<String?>? batch,
      Value<String?>? prevBatch,
      Value<int>? timestamp,
      Value<String?>? body,
      Value<String?>? relType,
      Value<String?>? relEventId,
      Value<int>? rowid}) {
    return ReactionsCompanion(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      sender: sender ?? this.sender,
      stateKey: stateKey ?? this.stateKey,
      batch: batch ?? this.batch,
      prevBatch: prevBatch ?? this.prevBatch,
      timestamp: timestamp ?? this.timestamp,
      body: body ?? this.body,
      relType: relType ?? this.relType,
      relEventId: relEventId ?? this.relEventId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (sender.present) {
      map['sender'] = Variable<String>(sender.value);
    }
    if (stateKey.present) {
      map['state_key'] = Variable<String>(stateKey.value);
    }
    if (batch.present) {
      map['batch'] = Variable<String>(batch.value);
    }
    if (prevBatch.present) {
      map['prev_batch'] = Variable<String>(prevBatch.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (relType.present) {
      map['rel_type'] = Variable<String>(relType.value);
    }
    if (relEventId.present) {
      map['rel_event_id'] = Variable<String>(relEventId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReactionsCompanion(')
          ..write('id: $id, ')
          ..write('roomId: $roomId, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('sender: $sender, ')
          ..write('stateKey: $stateKey, ')
          ..write('batch: $batch, ')
          ..write('prevBatch: $prevBatch, ')
          ..write('timestamp: $timestamp, ')
          ..write('body: $body, ')
          ..write('relType: $relType, ')
          ..write('relEventId: $relEventId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReceiptsTable extends Receipts with TableInfo<$ReceiptsTable, Receipt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReceiptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta =
      const VerificationMeta('eventId');
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
      'event_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _latestReadMeta =
      const VerificationMeta('latestRead');
  @override
  late final GeneratedColumn<int> latestRead = GeneratedColumn<int>(
      'latest_read', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>?, String>
      userReads = GeneratedColumn<String>('user_reads', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<Map<String, dynamic>?>(
              $ReceiptsTable.$converteruserReads);
  @override
  List<GeneratedColumn> get $columns => [eventId, latestRead, userReads];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'receipts';
  @override
  VerificationContext validateIntegrity(Insertable<Receipt> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(_eventIdMeta,
          eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta));
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('latest_read')) {
      context.handle(
          _latestReadMeta,
          latestRead.isAcceptableOrUnknown(
              data['latest_read']!, _latestReadMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId};
  @override
  Receipt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Receipt(
      eventId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_id'])!,
      latestRead: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}latest_read']),
    );
  }

  @override
  $ReceiptsTable createAlias(String alias) {
    return $ReceiptsTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, dynamic>?, String> $converteruserReads =
      const MapToReadConverter();
}

class ReceiptsCompanion extends UpdateCompanion<Receipt> {
  final Value<String> eventId;
  final Value<int?> latestRead;
  final Value<Map<String, dynamic>?> userReads;
  final Value<int> rowid;
  const ReceiptsCompanion({
    this.eventId = const Value.absent(),
    this.latestRead = const Value.absent(),
    this.userReads = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReceiptsCompanion.insert({
    required String eventId,
    this.latestRead = const Value.absent(),
    this.userReads = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : eventId = Value(eventId);
  static Insertable<Receipt> custom({
    Expression<String>? eventId,
    Expression<int>? latestRead,
    Expression<String>? userReads,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (latestRead != null) 'latest_read': latestRead,
      if (userReads != null) 'user_reads': userReads,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReceiptsCompanion copyWith(
      {Value<String>? eventId,
      Value<int?>? latestRead,
      Value<Map<String, dynamic>?>? userReads,
      Value<int>? rowid}) {
    return ReceiptsCompanion(
      eventId: eventId ?? this.eventId,
      latestRead: latestRead ?? this.latestRead,
      userReads: userReads ?? this.userReads,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (latestRead.present) {
      map['latest_read'] = Variable<int>(latestRead.value);
    }
    if (userReads.present) {
      map['user_reads'] = Variable<String>(
          $ReceiptsTable.$converteruserReads.toSql(userReads.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptsCompanion(')
          ..write('eventId: $eventId, ')
          ..write('latestRead: $latestRead, ')
          ..write('userReads: $userReads, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuthsTable extends Auths with TableInfo<$AuthsTable, Auth> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuthsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>?, String>
      store = GeneratedColumn<String>('store', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<Map<String, dynamic>?>($AuthsTable.$converterstore);
  @override
  List<GeneratedColumn> get $columns => [id, store];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'auths';
  @override
  VerificationContext validateIntegrity(Insertable<Auth> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Auth map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Auth(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      store: $AuthsTable.$converterstore.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}store'])),
    );
  }

  @override
  $AuthsTable createAlias(String alias) {
    return $AuthsTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, dynamic>?, String?> $converterstore =
      const MapToJsonConverter();
}

class Auth extends DataClass implements Insertable<Auth> {
  final String id;
  final Map<String, dynamic>? store;
  const Auth({required this.id, this.store});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || store != null) {
      map['store'] = Variable<String>($AuthsTable.$converterstore.toSql(store));
    }
    return map;
  }

  AuthsCompanion toCompanion(bool nullToAbsent) {
    return AuthsCompanion(
      id: Value(id),
      store:
          store == null && nullToAbsent ? const Value.absent() : Value(store),
    );
  }

  factory Auth.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Auth(
      id: serializer.fromJson<String>(json['id']),
      store: serializer.fromJson<Map<String, dynamic>?>(json['store']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'store': serializer.toJson<Map<String, dynamic>?>(store),
    };
  }

  Auth copyWith(
          {String? id,
          Value<Map<String, dynamic>?> store = const Value.absent()}) =>
      Auth(
        id: id ?? this.id,
        store: store.present ? store.value : this.store,
      );
  Auth copyWithCompanion(AuthsCompanion data) {
    return Auth(
      id: data.id.present ? data.id.value : this.id,
      store: data.store.present ? data.store.value : this.store,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Auth(')
          ..write('id: $id, ')
          ..write('store: $store')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, store);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Auth && other.id == this.id && other.store == this.store);
}

class AuthsCompanion extends UpdateCompanion<Auth> {
  final Value<String> id;
  final Value<Map<String, dynamic>?> store;
  final Value<int> rowid;
  const AuthsCompanion({
    this.id = const Value.absent(),
    this.store = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuthsCompanion.insert({
    required String id,
    this.store = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<Auth> custom({
    Expression<String>? id,
    Expression<String>? store,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (store != null) 'store': store,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuthsCompanion copyWith(
      {Value<String>? id,
      Value<Map<String, dynamic>?>? store,
      Value<int>? rowid}) {
    return AuthsCompanion(
      id: id ?? this.id,
      store: store ?? this.store,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (store.present) {
      map['store'] =
          Variable<String>($AuthsTable.$converterstore.toSql(store.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuthsCompanion(')
          ..write('id: $id, ')
          ..write('store: $store, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncsTable extends Syncs with TableInfo<$SyncsTable, Sync> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>?, String>
      store = GeneratedColumn<String>('store', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<Map<String, dynamic>?>($SyncsTable.$converterstore);
  @override
  List<GeneratedColumn> get $columns => [id, store];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'syncs';
  @override
  VerificationContext validateIntegrity(Insertable<Sync> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Sync map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sync(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      store: $SyncsTable.$converterstore.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}store'])),
    );
  }

  @override
  $SyncsTable createAlias(String alias) {
    return $SyncsTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, dynamic>?, String?> $converterstore =
      const MapToJsonConverter();
}

class Sync extends DataClass implements Insertable<Sync> {
  final String id;
  final Map<String, dynamic>? store;
  const Sync({required this.id, this.store});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || store != null) {
      map['store'] = Variable<String>($SyncsTable.$converterstore.toSql(store));
    }
    return map;
  }

  SyncsCompanion toCompanion(bool nullToAbsent) {
    return SyncsCompanion(
      id: Value(id),
      store:
          store == null && nullToAbsent ? const Value.absent() : Value(store),
    );
  }

  factory Sync.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sync(
      id: serializer.fromJson<String>(json['id']),
      store: serializer.fromJson<Map<String, dynamic>?>(json['store']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'store': serializer.toJson<Map<String, dynamic>?>(store),
    };
  }

  Sync copyWith(
          {String? id,
          Value<Map<String, dynamic>?> store = const Value.absent()}) =>
      Sync(
        id: id ?? this.id,
        store: store.present ? store.value : this.store,
      );
  Sync copyWithCompanion(SyncsCompanion data) {
    return Sync(
      id: data.id.present ? data.id.value : this.id,
      store: data.store.present ? data.store.value : this.store,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sync(')
          ..write('id: $id, ')
          ..write('store: $store')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, store);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sync && other.id == this.id && other.store == this.store);
}

class SyncsCompanion extends UpdateCompanion<Sync> {
  final Value<String> id;
  final Value<Map<String, dynamic>?> store;
  final Value<int> rowid;
  const SyncsCompanion({
    this.id = const Value.absent(),
    this.store = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncsCompanion.insert({
    required String id,
    this.store = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<Sync> custom({
    Expression<String>? id,
    Expression<String>? store,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (store != null) 'store': store,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncsCompanion copyWith(
      {Value<String>? id,
      Value<Map<String, dynamic>?>? store,
      Value<int>? rowid}) {
    return SyncsCompanion(
      id: id ?? this.id,
      store: store ?? this.store,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (store.present) {
      map['store'] =
          Variable<String>($SyncsTable.$converterstore.toSql(store.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncsCompanion(')
          ..write('id: $id, ')
          ..write('store: $store, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CryptosTable extends Cryptos with TableInfo<$CryptosTable, Crypto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CryptosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>?, String>
      store = GeneratedColumn<String>('store', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<Map<String, dynamic>?>($CryptosTable.$converterstore);
  @override
  List<GeneratedColumn> get $columns => [id, store];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cryptos';
  @override
  VerificationContext validateIntegrity(Insertable<Crypto> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Crypto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Crypto(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      store: $CryptosTable.$converterstore.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}store'])),
    );
  }

  @override
  $CryptosTable createAlias(String alias) {
    return $CryptosTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, dynamic>?, String?> $converterstore =
      const MapToJsonConverter();
}

class Crypto extends DataClass implements Insertable<Crypto> {
  final String id;
  final Map<String, dynamic>? store;
  const Crypto({required this.id, this.store});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || store != null) {
      map['store'] =
          Variable<String>($CryptosTable.$converterstore.toSql(store));
    }
    return map;
  }

  CryptosCompanion toCompanion(bool nullToAbsent) {
    return CryptosCompanion(
      id: Value(id),
      store:
          store == null && nullToAbsent ? const Value.absent() : Value(store),
    );
  }

  factory Crypto.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Crypto(
      id: serializer.fromJson<String>(json['id']),
      store: serializer.fromJson<Map<String, dynamic>?>(json['store']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'store': serializer.toJson<Map<String, dynamic>?>(store),
    };
  }

  Crypto copyWith(
          {String? id,
          Value<Map<String, dynamic>?> store = const Value.absent()}) =>
      Crypto(
        id: id ?? this.id,
        store: store.present ? store.value : this.store,
      );
  Crypto copyWithCompanion(CryptosCompanion data) {
    return Crypto(
      id: data.id.present ? data.id.value : this.id,
      store: data.store.present ? data.store.value : this.store,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Crypto(')
          ..write('id: $id, ')
          ..write('store: $store')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, store);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Crypto && other.id == this.id && other.store == this.store);
}

class CryptosCompanion extends UpdateCompanion<Crypto> {
  final Value<String> id;
  final Value<Map<String, dynamic>?> store;
  final Value<int> rowid;
  const CryptosCompanion({
    this.id = const Value.absent(),
    this.store = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CryptosCompanion.insert({
    required String id,
    this.store = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<Crypto> custom({
    Expression<String>? id,
    Expression<String>? store,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (store != null) 'store': store,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CryptosCompanion copyWith(
      {Value<String>? id,
      Value<Map<String, dynamic>?>? store,
      Value<int>? rowid}) {
    return CryptosCompanion(
      id: id ?? this.id,
      store: store ?? this.store,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (store.present) {
      map['store'] =
          Variable<String>($CryptosTable.$converterstore.toSql(store.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CryptosCompanion(')
          ..write('id: $id, ')
          ..write('store: $store, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessageSessionsTable extends MessageSessions
    with TableInfo<$MessageSessionsTable, MessageSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessageSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<String> roomId = GeneratedColumn<String>(
      'room_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _indexMeta = const VerificationMeta('index');
  @override
  late final GeneratedColumn<int> index = GeneratedColumn<int>(
      'index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _identityKeyMeta =
      const VerificationMeta('identityKey');
  @override
  late final GeneratedColumn<String> identityKey = GeneratedColumn<String>(
      'identity_key', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sessionMeta =
      const VerificationMeta('session');
  @override
  late final GeneratedColumn<String> session = GeneratedColumn<String>(
      'session', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _inboundMeta =
      const VerificationMeta('inbound');
  @override
  late final GeneratedColumn<bool> inbound = GeneratedColumn<bool>(
      'inbound', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("inbound" IN (0, 1))'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, roomId, index, identityKey, session, inbound, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'message_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<MessageSession> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('room_id')) {
      context.handle(_roomIdMeta,
          roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta));
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('index')) {
      context.handle(
          _indexMeta, index.isAcceptableOrUnknown(data['index']!, _indexMeta));
    } else if (isInserting) {
      context.missing(_indexMeta);
    }
    if (data.containsKey('identity_key')) {
      context.handle(
          _identityKeyMeta,
          identityKey.isAcceptableOrUnknown(
              data['identity_key']!, _identityKeyMeta));
    }
    if (data.containsKey('session')) {
      context.handle(_sessionMeta,
          session.isAcceptableOrUnknown(data['session']!, _sessionMeta));
    } else if (isInserting) {
      context.missing(_sessionMeta);
    }
    if (data.containsKey('inbound')) {
      context.handle(_inboundMeta,
          inbound.isAcceptableOrUnknown(data['inbound']!, _inboundMeta));
    } else if (isInserting) {
      context.missing(_inboundMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MessageSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageSession(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      roomId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}room_id'])!,
      index: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}index'])!,
      identityKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}identity_key']),
      session: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session'])!,
      inbound: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}inbound'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MessageSessionsTable createAlias(String alias) {
    return $MessageSessionsTable(attachedDatabase, alias);
  }
}

class MessageSession extends DataClass implements Insertable<MessageSession> {
  final String id;
  final String roomId;
  final int index;
  final String? identityKey;
  final String session;
  final bool inbound;
  final int createdAt;
  const MessageSession(
      {required this.id,
      required this.roomId,
      required this.index,
      this.identityKey,
      required this.session,
      required this.inbound,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['room_id'] = Variable<String>(roomId);
    map['index'] = Variable<int>(index);
    if (!nullToAbsent || identityKey != null) {
      map['identity_key'] = Variable<String>(identityKey);
    }
    map['session'] = Variable<String>(session);
    map['inbound'] = Variable<bool>(inbound);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  MessageSessionsCompanion toCompanion(bool nullToAbsent) {
    return MessageSessionsCompanion(
      id: Value(id),
      roomId: Value(roomId),
      index: Value(index),
      identityKey: identityKey == null && nullToAbsent
          ? const Value.absent()
          : Value(identityKey),
      session: Value(session),
      inbound: Value(inbound),
      createdAt: Value(createdAt),
    );
  }

  factory MessageSession.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageSession(
      id: serializer.fromJson<String>(json['id']),
      roomId: serializer.fromJson<String>(json['roomId']),
      index: serializer.fromJson<int>(json['index']),
      identityKey: serializer.fromJson<String?>(json['identityKey']),
      session: serializer.fromJson<String>(json['session']),
      inbound: serializer.fromJson<bool>(json['inbound']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'roomId': serializer.toJson<String>(roomId),
      'index': serializer.toJson<int>(index),
      'identityKey': serializer.toJson<String?>(identityKey),
      'session': serializer.toJson<String>(session),
      'inbound': serializer.toJson<bool>(inbound),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  MessageSession copyWith(
          {String? id,
          String? roomId,
          int? index,
          Value<String?> identityKey = const Value.absent(),
          String? session,
          bool? inbound,
          int? createdAt}) =>
      MessageSession(
        id: id ?? this.id,
        roomId: roomId ?? this.roomId,
        index: index ?? this.index,
        identityKey: identityKey.present ? identityKey.value : this.identityKey,
        session: session ?? this.session,
        inbound: inbound ?? this.inbound,
        createdAt: createdAt ?? this.createdAt,
      );
  MessageSession copyWithCompanion(MessageSessionsCompanion data) {
    return MessageSession(
      id: data.id.present ? data.id.value : this.id,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      index: data.index.present ? data.index.value : this.index,
      identityKey:
          data.identityKey.present ? data.identityKey.value : this.identityKey,
      session: data.session.present ? data.session.value : this.session,
      inbound: data.inbound.present ? data.inbound.value : this.inbound,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageSession(')
          ..write('id: $id, ')
          ..write('roomId: $roomId, ')
          ..write('index: $index, ')
          ..write('identityKey: $identityKey, ')
          ..write('session: $session, ')
          ..write('inbound: $inbound, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, roomId, index, identityKey, session, inbound, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageSession &&
          other.id == this.id &&
          other.roomId == this.roomId &&
          other.index == this.index &&
          other.identityKey == this.identityKey &&
          other.session == this.session &&
          other.inbound == this.inbound &&
          other.createdAt == this.createdAt);
}

class MessageSessionsCompanion extends UpdateCompanion<MessageSession> {
  final Value<String> id;
  final Value<String> roomId;
  final Value<int> index;
  final Value<String?> identityKey;
  final Value<String> session;
  final Value<bool> inbound;
  final Value<int> createdAt;
  final Value<int> rowid;
  const MessageSessionsCompanion({
    this.id = const Value.absent(),
    this.roomId = const Value.absent(),
    this.index = const Value.absent(),
    this.identityKey = const Value.absent(),
    this.session = const Value.absent(),
    this.inbound = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessageSessionsCompanion.insert({
    required String id,
    required String roomId,
    required int index,
    this.identityKey = const Value.absent(),
    required String session,
    required bool inbound,
    required int createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        roomId = Value(roomId),
        index = Value(index),
        session = Value(session),
        inbound = Value(inbound),
        createdAt = Value(createdAt);
  static Insertable<MessageSession> custom({
    Expression<String>? id,
    Expression<String>? roomId,
    Expression<int>? index,
    Expression<String>? identityKey,
    Expression<String>? session,
    Expression<bool>? inbound,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (roomId != null) 'room_id': roomId,
      if (index != null) 'index': index,
      if (identityKey != null) 'identity_key': identityKey,
      if (session != null) 'session': session,
      if (inbound != null) 'inbound': inbound,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessageSessionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? roomId,
      Value<int>? index,
      Value<String?>? identityKey,
      Value<String>? session,
      Value<bool>? inbound,
      Value<int>? createdAt,
      Value<int>? rowid}) {
    return MessageSessionsCompanion(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      index: index ?? this.index,
      identityKey: identityKey ?? this.identityKey,
      session: session ?? this.session,
      inbound: inbound ?? this.inbound,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (index.present) {
      map['index'] = Variable<int>(index.value);
    }
    if (identityKey.present) {
      map['identity_key'] = Variable<String>(identityKey.value);
    }
    if (session.present) {
      map['session'] = Variable<String>(session.value);
    }
    if (inbound.present) {
      map['inbound'] = Variable<bool>(inbound.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessageSessionsCompanion(')
          ..write('id: $id, ')
          ..write('roomId: $roomId, ')
          ..write('index: $index, ')
          ..write('identityKey: $identityKey, ')
          ..write('session: $session, ')
          ..write('inbound: $inbound, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KeySessionsTable extends KeySessions
    with TableInfo<$KeySessionsTable, KeySession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KeySessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'UNIQUE');
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _identityKeyMeta =
      const VerificationMeta('identityKey');
  @override
  late final GeneratedColumn<String> identityKey = GeneratedColumn<String>(
      'identity_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sessionMeta =
      const VerificationMeta('session');
  @override
  late final GeneratedColumn<String> session = GeneratedColumn<String>(
      'session', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, sessionId, identityKey, session];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'key_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<KeySession> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('identity_key')) {
      context.handle(
          _identityKeyMeta,
          identityKey.isAcceptableOrUnknown(
              data['identity_key']!, _identityKeyMeta));
    } else if (isInserting) {
      context.missing(_identityKeyMeta);
    }
    if (data.containsKey('session')) {
      context.handle(_sessionMeta,
          session.isAcceptableOrUnknown(data['session']!, _sessionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KeySession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KeySession(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id'])!,
      identityKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}identity_key'])!,
      session: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session']),
    );
  }

  @override
  $KeySessionsTable createAlias(String alias) {
    return $KeySessionsTable(attachedDatabase, alias);
  }
}

class KeySession extends DataClass implements Insertable<KeySession> {
  final String id;
  final String sessionId;
  final String identityKey;
  final String? session;
  const KeySession(
      {required this.id,
      required this.sessionId,
      required this.identityKey,
      this.session});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['identity_key'] = Variable<String>(identityKey);
    if (!nullToAbsent || session != null) {
      map['session'] = Variable<String>(session);
    }
    return map;
  }

  KeySessionsCompanion toCompanion(bool nullToAbsent) {
    return KeySessionsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      identityKey: Value(identityKey),
      session: session == null && nullToAbsent
          ? const Value.absent()
          : Value(session),
    );
  }

  factory KeySession.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KeySession(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      identityKey: serializer.fromJson<String>(json['identityKey']),
      session: serializer.fromJson<String?>(json['session']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'identityKey': serializer.toJson<String>(identityKey),
      'session': serializer.toJson<String?>(session),
    };
  }

  KeySession copyWith(
          {String? id,
          String? sessionId,
          String? identityKey,
          Value<String?> session = const Value.absent()}) =>
      KeySession(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        identityKey: identityKey ?? this.identityKey,
        session: session.present ? session.value : this.session,
      );
  KeySession copyWithCompanion(KeySessionsCompanion data) {
    return KeySession(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      identityKey:
          data.identityKey.present ? data.identityKey.value : this.identityKey,
      session: data.session.present ? data.session.value : this.session,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KeySession(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('identityKey: $identityKey, ')
          ..write('session: $session')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, identityKey, session);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KeySession &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.identityKey == this.identityKey &&
          other.session == this.session);
}

class KeySessionsCompanion extends UpdateCompanion<KeySession> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> identityKey;
  final Value<String?> session;
  final Value<int> rowid;
  const KeySessionsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.identityKey = const Value.absent(),
    this.session = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KeySessionsCompanion.insert({
    required String id,
    required String sessionId,
    required String identityKey,
    this.session = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sessionId = Value(sessionId),
        identityKey = Value(identityKey);
  static Insertable<KeySession> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? identityKey,
    Expression<String>? session,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (identityKey != null) 'identity_key': identityKey,
      if (session != null) 'session': session,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KeySessionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? sessionId,
      Value<String>? identityKey,
      Value<String?>? session,
      Value<int>? rowid}) {
    return KeySessionsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      identityKey: identityKey ?? this.identityKey,
      session: session ?? this.session,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (identityKey.present) {
      map['identity_key'] = Variable<String>(identityKey.value);
    }
    if (session.present) {
      map['session'] = Variable<String>(session.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KeySessionsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('identityKey: $identityKey, ')
          ..write('session: $session, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>?, String>
      store = GeneratedColumn<String>('store', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<Map<String, dynamic>?>($SettingsTable.$converterstore);
  @override
  List<GeneratedColumn> get $columns => [id, store];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<Setting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      store: $SettingsTable.$converterstore.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}store'])),
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, dynamic>?, String?> $converterstore =
      const MapToJsonConverter();
}

class Setting extends DataClass implements Insertable<Setting> {
  final String id;
  final Map<String, dynamic>? store;
  const Setting({required this.id, this.store});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || store != null) {
      map['store'] =
          Variable<String>($SettingsTable.$converterstore.toSql(store));
    }
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      store:
          store == null && nullToAbsent ? const Value.absent() : Value(store),
    );
  }

  factory Setting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      id: serializer.fromJson<String>(json['id']),
      store: serializer.fromJson<Map<String, dynamic>?>(json['store']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'store': serializer.toJson<Map<String, dynamic>?>(store),
    };
  }

  Setting copyWith(
          {String? id,
          Value<Map<String, dynamic>?> store = const Value.absent()}) =>
      Setting(
        id: id ?? this.id,
        store: store.present ? store.value : this.store,
      );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      id: data.id.present ? data.id.value : this.id,
      store: data.store.present ? data.store.value : this.store,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('id: $id, ')
          ..write('store: $store')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, store);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.id == this.id && other.store == this.store);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> id;
  final Value<Map<String, dynamic>?> store;
  final Value<int> rowid;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.store = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String id,
    this.store = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<Setting> custom({
    Expression<String>? id,
    Expression<String>? store,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (store != null) 'store': store,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith(
      {Value<String>? id,
      Value<Map<String, dynamic>?>? store,
      Value<int>? rowid}) {
    return SettingsCompanion(
      id: id ?? this.id,
      store: store ?? this.store,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (store.present) {
      map['store'] =
          Variable<String>($SettingsTable.$converterstore.toSql(store.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('store: $store, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$StorageDatabase extends GeneratedDatabase {
  _$StorageDatabase(QueryExecutor e) : super(e);
  _$StorageDatabase.connect(DatabaseConnection c) : super.connect(c);
  $StorageDatabaseManager get managers => $StorageDatabaseManager(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $DecryptedTable decrypted = $DecryptedTable(this);
  late final $RoomsTable rooms = $RoomsTable(this);
  late final $UsersTable users = $UsersTable(this);
  late final $MediasTable medias = $MediasTable(this);
  late final $ReactionsTable reactions = $ReactionsTable(this);
  late final $ReceiptsTable receipts = $ReceiptsTable(this);
  late final $AuthsTable auths = $AuthsTable(this);
  late final $SyncsTable syncs = $SyncsTable(this);
  late final $CryptosTable cryptos = $CryptosTable(this);
  late final $MessageSessionsTable messageSessions =
      $MessageSessionsTable(this);
  late final $KeySessionsTable keySessions = $KeySessionsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        messages,
        decrypted,
        rooms,
        users,
        medias,
        reactions,
        receipts,
        auths,
        syncs,
        cryptos,
        messageSessions,
        keySessions,
        settings
      ];
}

typedef $$MessagesTableCreateCompanionBuilder = MessagesCompanion Function({
  required String id,
  Value<String?> roomId,
  Value<String?> userId,
  Value<String?> type,
  Value<String?> sender,
  Value<String?> stateKey,
  Value<String?> prevBatch,
  Value<String?> batch,
  required bool pending,
  required bool syncing,
  required bool failed,
  required bool edited,
  required bool replacement,
  required int timestamp,
  required int received,
  Value<bool> hasLink,
  Value<String?> body,
  Value<String?> msgtype,
  Value<String?> format,
  Value<String?> formattedBody,
  Value<String?> url,
  Value<Map<String, dynamic>?> file,
  Value<String?> typeDecrypted,
  Value<String?> ciphertext,
  Value<String?> algorithm,
  Value<String?> sessionId,
  Value<String?> senderKey,
  Value<String?> deviceId,
  Value<String?> relatedEventId,
  Value<List<String>> editIds,
  Value<int> rowid,
});
typedef $$MessagesTableUpdateCompanionBuilder = MessagesCompanion Function({
  Value<String> id,
  Value<String?> roomId,
  Value<String?> userId,
  Value<String?> type,
  Value<String?> sender,
  Value<String?> stateKey,
  Value<String?> prevBatch,
  Value<String?> batch,
  Value<bool> pending,
  Value<bool> syncing,
  Value<bool> failed,
  Value<bool> edited,
  Value<bool> replacement,
  Value<int> timestamp,
  Value<int> received,
  Value<bool> hasLink,
  Value<String?> body,
  Value<String?> msgtype,
  Value<String?> format,
  Value<String?> formattedBody,
  Value<String?> url,
  Value<Map<String, dynamic>?> file,
  Value<String?> typeDecrypted,
  Value<String?> ciphertext,
  Value<String?> algorithm,
  Value<String?> sessionId,
  Value<String?> senderKey,
  Value<String?> deviceId,
  Value<String?> relatedEventId,
  Value<List<String>> editIds,
  Value<int> rowid,
});

class $$MessagesTableFilterComposer
    extends Composer<_$StorageDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get roomId => $composableBuilder(
      column: $table.roomId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sender => $composableBuilder(
      column: $table.sender, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stateKey => $composableBuilder(
      column: $table.stateKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get prevBatch => $composableBuilder(
      column: $table.prevBatch, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get batch => $composableBuilder(
      column: $table.batch, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get pending => $composableBuilder(
      column: $table.pending, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get syncing => $composableBuilder(
      column: $table.syncing, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get failed => $composableBuilder(
      column: $table.failed, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get edited => $composableBuilder(
      column: $table.edited, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get replacement => $composableBuilder(
      column: $table.replacement, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get received => $composableBuilder(
      column: $table.received, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasLink => $composableBuilder(
      column: $table.hasLink, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get msgtype => $composableBuilder(
      column: $table.msgtype, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get format => $composableBuilder(
      column: $table.format, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get formattedBody => $composableBuilder(
      column: $table.formattedBody, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Map<String, dynamic>?, Map<String, dynamic>,
          String>
      get file => $composableBuilder(
          column: $table.file,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get typeDecrypted => $composableBuilder(
      column: $table.typeDecrypted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ciphertext => $composableBuilder(
      column: $table.ciphertext, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get algorithm => $composableBuilder(
      column: $table.algorithm, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get senderKey => $composableBuilder(
      column: $table.senderKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get relatedEventId => $composableBuilder(
      column: $table.relatedEventId,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
      get editIds => $composableBuilder(
          column: $table.editIds,
          builder: (column) => ColumnWithTypeConverterFilters(column));
}

class $$MessagesTableOrderingComposer
    extends Composer<_$StorageDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get roomId => $composableBuilder(
      column: $table.roomId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sender => $composableBuilder(
      column: $table.sender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stateKey => $composableBuilder(
      column: $table.stateKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get prevBatch => $composableBuilder(
      column: $table.prevBatch, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get batch => $composableBuilder(
      column: $table.batch, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get pending => $composableBuilder(
      column: $table.pending, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get syncing => $composableBuilder(
      column: $table.syncing, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get failed => $composableBuilder(
      column: $table.failed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get edited => $composableBuilder(
      column: $table.edited, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get replacement => $composableBuilder(
      column: $table.replacement, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get received => $composableBuilder(
      column: $table.received, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasLink => $composableBuilder(
      column: $table.hasLink, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get msgtype => $composableBuilder(
      column: $table.msgtype, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get format => $composableBuilder(
      column: $table.format, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get formattedBody => $composableBuilder(
      column: $table.formattedBody,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get file => $composableBuilder(
      column: $table.file, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get typeDecrypted => $composableBuilder(
      column: $table.typeDecrypted,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ciphertext => $composableBuilder(
      column: $table.ciphertext, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get algorithm => $composableBuilder(
      column: $table.algorithm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get senderKey => $composableBuilder(
      column: $table.senderKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get relatedEventId => $composableBuilder(
      column: $table.relatedEventId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get editIds => $composableBuilder(
      column: $table.editIds, builder: (column) => ColumnOrderings(column));
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$StorageDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get sender =>
      $composableBuilder(column: $table.sender, builder: (column) => column);

  GeneratedColumn<String> get stateKey =>
      $composableBuilder(column: $table.stateKey, builder: (column) => column);

  GeneratedColumn<String> get prevBatch =>
      $composableBuilder(column: $table.prevBatch, builder: (column) => column);

  GeneratedColumn<String> get batch =>
      $composableBuilder(column: $table.batch, builder: (column) => column);

  GeneratedColumn<bool> get pending =>
      $composableBuilder(column: $table.pending, builder: (column) => column);

  GeneratedColumn<bool> get syncing =>
      $composableBuilder(column: $table.syncing, builder: (column) => column);

  GeneratedColumn<bool> get failed =>
      $composableBuilder(column: $table.failed, builder: (column) => column);

  GeneratedColumn<bool> get edited =>
      $composableBuilder(column: $table.edited, builder: (column) => column);

  GeneratedColumn<bool> get replacement => $composableBuilder(
      column: $table.replacement, builder: (column) => column);

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<int> get received =>
      $composableBuilder(column: $table.received, builder: (column) => column);

  GeneratedColumn<bool> get hasLink =>
      $composableBuilder(column: $table.hasLink, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get msgtype =>
      $composableBuilder(column: $table.msgtype, builder: (column) => column);

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<String> get formattedBody => $composableBuilder(
      column: $table.formattedBody, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, dynamic>?, String> get file =>
      $composableBuilder(column: $table.file, builder: (column) => column);

  GeneratedColumn<String> get typeDecrypted => $composableBuilder(
      column: $table.typeDecrypted, builder: (column) => column);

  GeneratedColumn<String> get ciphertext => $composableBuilder(
      column: $table.ciphertext, builder: (column) => column);

  GeneratedColumn<String> get algorithm =>
      $composableBuilder(column: $table.algorithm, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get senderKey =>
      $composableBuilder(column: $table.senderKey, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get relatedEventId => $composableBuilder(
      column: $table.relatedEventId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get editIds =>
      $composableBuilder(column: $table.editIds, builder: (column) => column);
}

class $$MessagesTableTableManager extends RootTableManager<
    _$StorageDatabase,
    $MessagesTable,
    Message,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableAnnotationComposer,
    $$MessagesTableCreateCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder,
    (Message, BaseReferences<_$StorageDatabase, $MessagesTable, Message>),
    Message,
    PrefetchHooks Function()> {
  $$MessagesTableTableManager(_$StorageDatabase db, $MessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> roomId = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<String?> type = const Value.absent(),
            Value<String?> sender = const Value.absent(),
            Value<String?> stateKey = const Value.absent(),
            Value<String?> prevBatch = const Value.absent(),
            Value<String?> batch = const Value.absent(),
            Value<bool> pending = const Value.absent(),
            Value<bool> syncing = const Value.absent(),
            Value<bool> failed = const Value.absent(),
            Value<bool> edited = const Value.absent(),
            Value<bool> replacement = const Value.absent(),
            Value<int> timestamp = const Value.absent(),
            Value<int> received = const Value.absent(),
            Value<bool> hasLink = const Value.absent(),
            Value<String?> body = const Value.absent(),
            Value<String?> msgtype = const Value.absent(),
            Value<String?> format = const Value.absent(),
            Value<String?> formattedBody = const Value.absent(),
            Value<String?> url = const Value.absent(),
            Value<Map<String, dynamic>?> file = const Value.absent(),
            Value<String?> typeDecrypted = const Value.absent(),
            Value<String?> ciphertext = const Value.absent(),
            Value<String?> algorithm = const Value.absent(),
            Value<String?> sessionId = const Value.absent(),
            Value<String?> senderKey = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<String?> relatedEventId = const Value.absent(),
            Value<List<String>> editIds = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MessagesCompanion(
            id: id,
            roomId: roomId,
            userId: userId,
            type: type,
            sender: sender,
            stateKey: stateKey,
            prevBatch: prevBatch,
            batch: batch,
            pending: pending,
            syncing: syncing,
            failed: failed,
            edited: edited,
            replacement: replacement,
            timestamp: timestamp,
            received: received,
            hasLink: hasLink,
            body: body,
            msgtype: msgtype,
            format: format,
            formattedBody: formattedBody,
            url: url,
            file: file,
            typeDecrypted: typeDecrypted,
            ciphertext: ciphertext,
            algorithm: algorithm,
            sessionId: sessionId,
            senderKey: senderKey,
            deviceId: deviceId,
            relatedEventId: relatedEventId,
            editIds: editIds,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> roomId = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<String?> type = const Value.absent(),
            Value<String?> sender = const Value.absent(),
            Value<String?> stateKey = const Value.absent(),
            Value<String?> prevBatch = const Value.absent(),
            Value<String?> batch = const Value.absent(),
            required bool pending,
            required bool syncing,
            required bool failed,
            required bool edited,
            required bool replacement,
            required int timestamp,
            required int received,
            Value<bool> hasLink = const Value.absent(),
            Value<String?> body = const Value.absent(),
            Value<String?> msgtype = const Value.absent(),
            Value<String?> format = const Value.absent(),
            Value<String?> formattedBody = const Value.absent(),
            Value<String?> url = const Value.absent(),
            Value<Map<String, dynamic>?> file = const Value.absent(),
            Value<String?> typeDecrypted = const Value.absent(),
            Value<String?> ciphertext = const Value.absent(),
            Value<String?> algorithm = const Value.absent(),
            Value<String?> sessionId = const Value.absent(),
            Value<String?> senderKey = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<String?> relatedEventId = const Value.absent(),
            Value<List<String>> editIds = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MessagesCompanion.insert(
            id: id,
            roomId: roomId,
            userId: userId,
            type: type,
            sender: sender,
            stateKey: stateKey,
            prevBatch: prevBatch,
            batch: batch,
            pending: pending,
            syncing: syncing,
            failed: failed,
            edited: edited,
            replacement: replacement,
            timestamp: timestamp,
            received: received,
            hasLink: hasLink,
            body: body,
            msgtype: msgtype,
            format: format,
            formattedBody: formattedBody,
            url: url,
            file: file,
            typeDecrypted: typeDecrypted,
            ciphertext: ciphertext,
            algorithm: algorithm,
            sessionId: sessionId,
            senderKey: senderKey,
            deviceId: deviceId,
            relatedEventId: relatedEventId,
            editIds: editIds,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MessagesTableProcessedTableManager = ProcessedTableManager<
    _$StorageDatabase,
    $MessagesTable,
    Message,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableAnnotationComposer,
    $$MessagesTableCreateCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder,
    (Message, BaseReferences<_$StorageDatabase, $MessagesTable, Message>),
    Message,
    PrefetchHooks Function()>;
typedef $$DecryptedTableCreateCompanionBuilder = DecryptedCompanion Function({
  required String id,
  Value<String?> roomId,
  Value<String?> userId,
  Value<String?> type,
  Value<String?> sender,
  Value<String?> stateKey,
  Value<String?> prevBatch,
  Value<String?> batch,
  required bool pending,
  required bool syncing,
  required bool failed,
  required bool edited,
  required bool replacement,
  required int timestamp,
  required int received,
  Value<bool> hasLink,
  Value<String?> body,
  Value<String?> msgtype,
  Value<String?> format,
  Value<String?> formattedBody,
  Value<String?> url,
  Value<Map<String, dynamic>?> file,
  Value<String?> typeDecrypted,
  Value<String?> ciphertext,
  Value<String?> algorithm,
  Value<String?> sessionId,
  Value<String?> senderKey,
  Value<String?> deviceId,
  Value<String?> relatedEventId,
  Value<List<String>> editIds,
  Value<int> rowid,
});
typedef $$DecryptedTableUpdateCompanionBuilder = DecryptedCompanion Function({
  Value<String> id,
  Value<String?> roomId,
  Value<String?> userId,
  Value<String?> type,
  Value<String?> sender,
  Value<String?> stateKey,
  Value<String?> prevBatch,
  Value<String?> batch,
  Value<bool> pending,
  Value<bool> syncing,
  Value<bool> failed,
  Value<bool> edited,
  Value<bool> replacement,
  Value<int> timestamp,
  Value<int> received,
  Value<bool> hasLink,
  Value<String?> body,
  Value<String?> msgtype,
  Value<String?> format,
  Value<String?> formattedBody,
  Value<String?> url,
  Value<Map<String, dynamic>?> file,
  Value<String?> typeDecrypted,
  Value<String?> ciphertext,
  Value<String?> algorithm,
  Value<String?> sessionId,
  Value<String?> senderKey,
  Value<String?> deviceId,
  Value<String?> relatedEventId,
  Value<List<String>> editIds,
  Value<int> rowid,
});

class $$DecryptedTableFilterComposer
    extends Composer<_$StorageDatabase, $DecryptedTable> {
  $$DecryptedTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get roomId => $composableBuilder(
      column: $table.roomId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sender => $composableBuilder(
      column: $table.sender, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stateKey => $composableBuilder(
      column: $table.stateKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get prevBatch => $composableBuilder(
      column: $table.prevBatch, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get batch => $composableBuilder(
      column: $table.batch, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get pending => $composableBuilder(
      column: $table.pending, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get syncing => $composableBuilder(
      column: $table.syncing, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get failed => $composableBuilder(
      column: $table.failed, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get edited => $composableBuilder(
      column: $table.edited, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get replacement => $composableBuilder(
      column: $table.replacement, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get received => $composableBuilder(
      column: $table.received, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasLink => $composableBuilder(
      column: $table.hasLink, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get msgtype => $composableBuilder(
      column: $table.msgtype, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get format => $composableBuilder(
      column: $table.format, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get formattedBody => $composableBuilder(
      column: $table.formattedBody, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Map<String, dynamic>?, Map<String, dynamic>,
          String>
      get file => $composableBuilder(
          column: $table.file,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get typeDecrypted => $composableBuilder(
      column: $table.typeDecrypted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ciphertext => $composableBuilder(
      column: $table.ciphertext, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get algorithm => $composableBuilder(
      column: $table.algorithm, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get senderKey => $composableBuilder(
      column: $table.senderKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get relatedEventId => $composableBuilder(
      column: $table.relatedEventId,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
      get editIds => $composableBuilder(
          column: $table.editIds,
          builder: (column) => ColumnWithTypeConverterFilters(column));
}

class $$DecryptedTableOrderingComposer
    extends Composer<_$StorageDatabase, $DecryptedTable> {
  $$DecryptedTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get roomId => $composableBuilder(
      column: $table.roomId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sender => $composableBuilder(
      column: $table.sender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stateKey => $composableBuilder(
      column: $table.stateKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get prevBatch => $composableBuilder(
      column: $table.prevBatch, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get batch => $composableBuilder(
      column: $table.batch, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get pending => $composableBuilder(
      column: $table.pending, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get syncing => $composableBuilder(
      column: $table.syncing, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get failed => $composableBuilder(
      column: $table.failed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get edited => $composableBuilder(
      column: $table.edited, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get replacement => $composableBuilder(
      column: $table.replacement, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get received => $composableBuilder(
      column: $table.received, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasLink => $composableBuilder(
      column: $table.hasLink, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get msgtype => $composableBuilder(
      column: $table.msgtype, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get format => $composableBuilder(
      column: $table.format, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get formattedBody => $composableBuilder(
      column: $table.formattedBody,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get file => $composableBuilder(
      column: $table.file, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get typeDecrypted => $composableBuilder(
      column: $table.typeDecrypted,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ciphertext => $composableBuilder(
      column: $table.ciphertext, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get algorithm => $composableBuilder(
      column: $table.algorithm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get senderKey => $composableBuilder(
      column: $table.senderKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get relatedEventId => $composableBuilder(
      column: $table.relatedEventId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get editIds => $composableBuilder(
      column: $table.editIds, builder: (column) => ColumnOrderings(column));
}

class $$DecryptedTableAnnotationComposer
    extends Composer<_$StorageDatabase, $DecryptedTable> {
  $$DecryptedTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get sender =>
      $composableBuilder(column: $table.sender, builder: (column) => column);

  GeneratedColumn<String> get stateKey =>
      $composableBuilder(column: $table.stateKey, builder: (column) => column);

  GeneratedColumn<String> get prevBatch =>
      $composableBuilder(column: $table.prevBatch, builder: (column) => column);

  GeneratedColumn<String> get batch =>
      $composableBuilder(column: $table.batch, builder: (column) => column);

  GeneratedColumn<bool> get pending =>
      $composableBuilder(column: $table.pending, builder: (column) => column);

  GeneratedColumn<bool> get syncing =>
      $composableBuilder(column: $table.syncing, builder: (column) => column);

  GeneratedColumn<bool> get failed =>
      $composableBuilder(column: $table.failed, builder: (column) => column);

  GeneratedColumn<bool> get edited =>
      $composableBuilder(column: $table.edited, builder: (column) => column);

  GeneratedColumn<bool> get replacement => $composableBuilder(
      column: $table.replacement, builder: (column) => column);

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<int> get received =>
      $composableBuilder(column: $table.received, builder: (column) => column);

  GeneratedColumn<bool> get hasLink =>
      $composableBuilder(column: $table.hasLink, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get msgtype =>
      $composableBuilder(column: $table.msgtype, builder: (column) => column);

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<String> get formattedBody => $composableBuilder(
      column: $table.formattedBody, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, dynamic>?, String> get file =>
      $composableBuilder(column: $table.file, builder: (column) => column);

  GeneratedColumn<String> get typeDecrypted => $composableBuilder(
      column: $table.typeDecrypted, builder: (column) => column);

  GeneratedColumn<String> get ciphertext => $composableBuilder(
      column: $table.ciphertext, builder: (column) => column);

  GeneratedColumn<String> get algorithm =>
      $composableBuilder(column: $table.algorithm, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get senderKey =>
      $composableBuilder(column: $table.senderKey, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get relatedEventId => $composableBuilder(
      column: $table.relatedEventId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get editIds =>
      $composableBuilder(column: $table.editIds, builder: (column) => column);
}

class $$DecryptedTableTableManager extends RootTableManager<
    _$StorageDatabase,
    $DecryptedTable,
    Message,
    $$DecryptedTableFilterComposer,
    $$DecryptedTableOrderingComposer,
    $$DecryptedTableAnnotationComposer,
    $$DecryptedTableCreateCompanionBuilder,
    $$DecryptedTableUpdateCompanionBuilder,
    (Message, BaseReferences<_$StorageDatabase, $DecryptedTable, Message>),
    Message,
    PrefetchHooks Function()> {
  $$DecryptedTableTableManager(_$StorageDatabase db, $DecryptedTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DecryptedTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DecryptedTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DecryptedTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> roomId = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<String?> type = const Value.absent(),
            Value<String?> sender = const Value.absent(),
            Value<String?> stateKey = const Value.absent(),
            Value<String?> prevBatch = const Value.absent(),
            Value<String?> batch = const Value.absent(),
            Value<bool> pending = const Value.absent(),
            Value<bool> syncing = const Value.absent(),
            Value<bool> failed = const Value.absent(),
            Value<bool> edited = const Value.absent(),
            Value<bool> replacement = const Value.absent(),
            Value<int> timestamp = const Value.absent(),
            Value<int> received = const Value.absent(),
            Value<bool> hasLink = const Value.absent(),
            Value<String?> body = const Value.absent(),
            Value<String?> msgtype = const Value.absent(),
            Value<String?> format = const Value.absent(),
            Value<String?> formattedBody = const Value.absent(),
            Value<String?> url = const Value.absent(),
            Value<Map<String, dynamic>?> file = const Value.absent(),
            Value<String?> typeDecrypted = const Value.absent(),
            Value<String?> ciphertext = const Value.absent(),
            Value<String?> algorithm = const Value.absent(),
            Value<String?> sessionId = const Value.absent(),
            Value<String?> senderKey = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<String?> relatedEventId = const Value.absent(),
            Value<List<String>> editIds = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DecryptedCompanion(
            id: id,
            roomId: roomId,
            userId: userId,
            type: type,
            sender: sender,
            stateKey: stateKey,
            prevBatch: prevBatch,
            batch: batch,
            pending: pending,
            syncing: syncing,
            failed: failed,
            edited: edited,
            replacement: replacement,
            timestamp: timestamp,
            received: received,
            hasLink: hasLink,
            body: body,
            msgtype: msgtype,
            format: format,
            formattedBody: formattedBody,
            url: url,
            file: file,
            typeDecrypted: typeDecrypted,
            ciphertext: ciphertext,
            algorithm: algorithm,
            sessionId: sessionId,
            senderKey: senderKey,
            deviceId: deviceId,
            relatedEventId: relatedEventId,
            editIds: editIds,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> roomId = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<String?> type = const Value.absent(),
            Value<String?> sender = const Value.absent(),
            Value<String?> stateKey = const Value.absent(),
            Value<String?> prevBatch = const Value.absent(),
            Value<String?> batch = const Value.absent(),
            required bool pending,
            required bool syncing,
            required bool failed,
            required bool edited,
            required bool replacement,
            required int timestamp,
            required int received,
            Value<bool> hasLink = const Value.absent(),
            Value<String?> body = const Value.absent(),
            Value<String?> msgtype = const Value.absent(),
            Value<String?> format = const Value.absent(),
            Value<String?> formattedBody = const Value.absent(),
            Value<String?> url = const Value.absent(),
            Value<Map<String, dynamic>?> file = const Value.absent(),
            Value<String?> typeDecrypted = const Value.absent(),
            Value<String?> ciphertext = const Value.absent(),
            Value<String?> algorithm = const Value.absent(),
            Value<String?> sessionId = const Value.absent(),
            Value<String?> senderKey = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<String?> relatedEventId = const Value.absent(),
            Value<List<String>> editIds = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DecryptedCompanion.insert(
            id: id,
            roomId: roomId,
            userId: userId,
            type: type,
            sender: sender,
            stateKey: stateKey,
            prevBatch: prevBatch,
            batch: batch,
            pending: pending,
            syncing: syncing,
            failed: failed,
            edited: edited,
            replacement: replacement,
            timestamp: timestamp,
            received: received,
            hasLink: hasLink,
            body: body,
            msgtype: msgtype,
            format: format,
            formattedBody: formattedBody,
            url: url,
            file: file,
            typeDecrypted: typeDecrypted,
            ciphertext: ciphertext,
            algorithm: algorithm,
            sessionId: sessionId,
            senderKey: senderKey,
            deviceId: deviceId,
            relatedEventId: relatedEventId,
            editIds: editIds,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DecryptedTableProcessedTableManager = ProcessedTableManager<
    _$StorageDatabase,
    $DecryptedTable,
    Message,
    $$DecryptedTableFilterComposer,
    $$DecryptedTableOrderingComposer,
    $$DecryptedTableAnnotationComposer,
    $$DecryptedTableCreateCompanionBuilder,
    $$DecryptedTableUpdateCompanionBuilder,
    (Message, BaseReferences<_$StorageDatabase, $DecryptedTable, Message>),
    Message,
    PrefetchHooks Function()>;
typedef $$RoomsTableCreateCompanionBuilder = RoomsCompanion Function({
  required String id,
  Value<String?> name,
  Value<String?> alias,
  Value<String?> homeserver,
  Value<String?> avatarUri,
  Value<String?> topic,
  Value<String?> joinRule,
  required bool drafting,
  required bool direct,
  required bool sending,
  required bool invite,
  required bool guestEnabled,
  required bool encryptionEnabled,
  required bool worldReadable,
  required bool hidden,
  required bool archived,
  Value<String?> lastBatch,
  Value<String?> prevBatch,
  Value<String?> nextBatch,
  Value<int> lastRead,
  Value<int> lastUpdate,
  Value<int> totalJoinedUsers,
  Value<int> namePriority,
  Value<Message?> draft,
  Value<Message?> reply,
  Value<List<String>> userIds,
  Value<int> rowid,
});
typedef $$RoomsTableUpdateCompanionBuilder = RoomsCompanion Function({
  Value<String> id,
  Value<String?> name,
  Value<String?> alias,
  Value<String?> homeserver,
  Value<String?> avatarUri,
  Value<String?> topic,
  Value<String?> joinRule,
  Value<bool> drafting,
  Value<bool> direct,
  Value<bool> sending,
  Value<bool> invite,
  Value<bool> guestEnabled,
  Value<bool> encryptionEnabled,
  Value<bool> worldReadable,
  Value<bool> hidden,
  Value<bool> archived,
  Value<String?> lastBatch,
  Value<String?> prevBatch,
  Value<String?> nextBatch,
  Value<int> lastRead,
  Value<int> lastUpdate,
  Value<int> totalJoinedUsers,
  Value<int> namePriority,
  Value<Message?> draft,
  Value<Message?> reply,
  Value<List<String>> userIds,
  Value<int> rowid,
});

class $$RoomsTableFilterComposer
    extends Composer<_$StorageDatabase, $RoomsTable> {
  $$RoomsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get alias => $composableBuilder(
      column: $table.alias, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get homeserver => $composableBuilder(
      column: $table.homeserver, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatarUri => $composableBuilder(
      column: $table.avatarUri, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get topic => $composableBuilder(
      column: $table.topic, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get joinRule => $composableBuilder(
      column: $table.joinRule, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get drafting => $composableBuilder(
      column: $table.drafting, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get direct => $composableBuilder(
      column: $table.direct, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get sending => $composableBuilder(
      column: $table.sending, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get invite => $composableBuilder(
      column: $table.invite, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get guestEnabled => $composableBuilder(
      column: $table.guestEnabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get encryptionEnabled => $composableBuilder(
      column: $table.encryptionEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get worldReadable => $composableBuilder(
      column: $table.worldReadable, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hidden => $composableBuilder(
      column: $table.hidden, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get archived => $composableBuilder(
      column: $table.archived, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastBatch => $composableBuilder(
      column: $table.lastBatch, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get prevBatch => $composableBuilder(
      column: $table.prevBatch, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nextBatch => $composableBuilder(
      column: $table.nextBatch, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastRead => $composableBuilder(
      column: $table.lastRead, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastUpdate => $composableBuilder(
      column: $table.lastUpdate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalJoinedUsers => $composableBuilder(
      column: $table.totalJoinedUsers,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get namePriority => $composableBuilder(
      column: $table.namePriority, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Message?, Message, String> get draft =>
      $composableBuilder(
          column: $table.draft,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<Message?, Message, String> get reply =>
      $composableBuilder(
          column: $table.reply,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
      get userIds => $composableBuilder(
          column: $table.userIds,
          builder: (column) => ColumnWithTypeConverterFilters(column));
}

class $$RoomsTableOrderingComposer
    extends Composer<_$StorageDatabase, $RoomsTable> {
  $$RoomsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get alias => $composableBuilder(
      column: $table.alias, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get homeserver => $composableBuilder(
      column: $table.homeserver, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatarUri => $composableBuilder(
      column: $table.avatarUri, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get topic => $composableBuilder(
      column: $table.topic, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get joinRule => $composableBuilder(
      column: $table.joinRule, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get drafting => $composableBuilder(
      column: $table.drafting, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get direct => $composableBuilder(
      column: $table.direct, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get sending => $composableBuilder(
      column: $table.sending, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get invite => $composableBuilder(
      column: $table.invite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get guestEnabled => $composableBuilder(
      column: $table.guestEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get encryptionEnabled => $composableBuilder(
      column: $table.encryptionEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get worldReadable => $composableBuilder(
      column: $table.worldReadable,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hidden => $composableBuilder(
      column: $table.hidden, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get archived => $composableBuilder(
      column: $table.archived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastBatch => $composableBuilder(
      column: $table.lastBatch, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get prevBatch => $composableBuilder(
      column: $table.prevBatch, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nextBatch => $composableBuilder(
      column: $table.nextBatch, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastRead => $composableBuilder(
      column: $table.lastRead, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastUpdate => $composableBuilder(
      column: $table.lastUpdate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalJoinedUsers => $composableBuilder(
      column: $table.totalJoinedUsers,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get namePriority => $composableBuilder(
      column: $table.namePriority,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get draft => $composableBuilder(
      column: $table.draft, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reply => $composableBuilder(
      column: $table.reply, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userIds => $composableBuilder(
      column: $table.userIds, builder: (column) => ColumnOrderings(column));
}

class $$RoomsTableAnnotationComposer
    extends Composer<_$StorageDatabase, $RoomsTable> {
  $$RoomsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get alias =>
      $composableBuilder(column: $table.alias, builder: (column) => column);

  GeneratedColumn<String> get homeserver => $composableBuilder(
      column: $table.homeserver, builder: (column) => column);

  GeneratedColumn<String> get avatarUri =>
      $composableBuilder(column: $table.avatarUri, builder: (column) => column);

  GeneratedColumn<String> get topic =>
      $composableBuilder(column: $table.topic, builder: (column) => column);

  GeneratedColumn<String> get joinRule =>
      $composableBuilder(column: $table.joinRule, builder: (column) => column);

  GeneratedColumn<bool> get drafting =>
      $composableBuilder(column: $table.drafting, builder: (column) => column);

  GeneratedColumn<bool> get direct =>
      $composableBuilder(column: $table.direct, builder: (column) => column);

  GeneratedColumn<bool> get sending =>
      $composableBuilder(column: $table.sending, builder: (column) => column);

  GeneratedColumn<bool> get invite =>
      $composableBuilder(column: $table.invite, builder: (column) => column);

  GeneratedColumn<bool> get guestEnabled => $composableBuilder(
      column: $table.guestEnabled, builder: (column) => column);

  GeneratedColumn<bool> get encryptionEnabled => $composableBuilder(
      column: $table.encryptionEnabled, builder: (column) => column);

  GeneratedColumn<bool> get worldReadable => $composableBuilder(
      column: $table.worldReadable, builder: (column) => column);

  GeneratedColumn<bool> get hidden =>
      $composableBuilder(column: $table.hidden, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<String> get lastBatch =>
      $composableBuilder(column: $table.lastBatch, builder: (column) => column);

  GeneratedColumn<String> get prevBatch =>
      $composableBuilder(column: $table.prevBatch, builder: (column) => column);

  GeneratedColumn<String> get nextBatch =>
      $composableBuilder(column: $table.nextBatch, builder: (column) => column);

  GeneratedColumn<int> get lastRead =>
      $composableBuilder(column: $table.lastRead, builder: (column) => column);

  GeneratedColumn<int> get lastUpdate => $composableBuilder(
      column: $table.lastUpdate, builder: (column) => column);

  GeneratedColumn<int> get totalJoinedUsers => $composableBuilder(
      column: $table.totalJoinedUsers, builder: (column) => column);

  GeneratedColumn<int> get namePriority => $composableBuilder(
      column: $table.namePriority, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Message?, String> get draft =>
      $composableBuilder(column: $table.draft, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Message?, String> get reply =>
      $composableBuilder(column: $table.reply, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get userIds =>
      $composableBuilder(column: $table.userIds, builder: (column) => column);
}

class $$RoomsTableTableManager extends RootTableManager<
    _$StorageDatabase,
    $RoomsTable,
    Room,
    $$RoomsTableFilterComposer,
    $$RoomsTableOrderingComposer,
    $$RoomsTableAnnotationComposer,
    $$RoomsTableCreateCompanionBuilder,
    $$RoomsTableUpdateCompanionBuilder,
    (Room, BaseReferences<_$StorageDatabase, $RoomsTable, Room>),
    Room,
    PrefetchHooks Function()> {
  $$RoomsTableTableManager(_$StorageDatabase db, $RoomsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoomsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoomsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoomsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<String?> alias = const Value.absent(),
            Value<String?> homeserver = const Value.absent(),
            Value<String?> avatarUri = const Value.absent(),
            Value<String?> topic = const Value.absent(),
            Value<String?> joinRule = const Value.absent(),
            Value<bool> drafting = const Value.absent(),
            Value<bool> direct = const Value.absent(),
            Value<bool> sending = const Value.absent(),
            Value<bool> invite = const Value.absent(),
            Value<bool> guestEnabled = const Value.absent(),
            Value<bool> encryptionEnabled = const Value.absent(),
            Value<bool> worldReadable = const Value.absent(),
            Value<bool> hidden = const Value.absent(),
            Value<bool> archived = const Value.absent(),
            Value<String?> lastBatch = const Value.absent(),
            Value<String?> prevBatch = const Value.absent(),
            Value<String?> nextBatch = const Value.absent(),
            Value<int> lastRead = const Value.absent(),
            Value<int> lastUpdate = const Value.absent(),
            Value<int> totalJoinedUsers = const Value.absent(),
            Value<int> namePriority = const Value.absent(),
            Value<Message?> draft = const Value.absent(),
            Value<Message?> reply = const Value.absent(),
            Value<List<String>> userIds = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RoomsCompanion(
            id: id,
            name: name,
            alias: alias,
            homeserver: homeserver,
            avatarUri: avatarUri,
            topic: topic,
            joinRule: joinRule,
            drafting: drafting,
            direct: direct,
            sending: sending,
            invite: invite,
            guestEnabled: guestEnabled,
            encryptionEnabled: encryptionEnabled,
            worldReadable: worldReadable,
            hidden: hidden,
            archived: archived,
            lastBatch: lastBatch,
            prevBatch: prevBatch,
            nextBatch: nextBatch,
            lastRead: lastRead,
            lastUpdate: lastUpdate,
            totalJoinedUsers: totalJoinedUsers,
            namePriority: namePriority,
            draft: draft,
            reply: reply,
            userIds: userIds,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> name = const Value.absent(),
            Value<String?> alias = const Value.absent(),
            Value<String?> homeserver = const Value.absent(),
            Value<String?> avatarUri = const Value.absent(),
            Value<String?> topic = const Value.absent(),
            Value<String?> joinRule = const Value.absent(),
            required bool drafting,
            required bool direct,
            required bool sending,
            required bool invite,
            required bool guestEnabled,
            required bool encryptionEnabled,
            required bool worldReadable,
            required bool hidden,
            required bool archived,
            Value<String?> lastBatch = const Value.absent(),
            Value<String?> prevBatch = const Value.absent(),
            Value<String?> nextBatch = const Value.absent(),
            Value<int> lastRead = const Value.absent(),
            Value<int> lastUpdate = const Value.absent(),
            Value<int> totalJoinedUsers = const Value.absent(),
            Value<int> namePriority = const Value.absent(),
            Value<Message?> draft = const Value.absent(),
            Value<Message?> reply = const Value.absent(),
            Value<List<String>> userIds = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RoomsCompanion.insert(
            id: id,
            name: name,
            alias: alias,
            homeserver: homeserver,
            avatarUri: avatarUri,
            topic: topic,
            joinRule: joinRule,
            drafting: drafting,
            direct: direct,
            sending: sending,
            invite: invite,
            guestEnabled: guestEnabled,
            encryptionEnabled: encryptionEnabled,
            worldReadable: worldReadable,
            hidden: hidden,
            archived: archived,
            lastBatch: lastBatch,
            prevBatch: prevBatch,
            nextBatch: nextBatch,
            lastRead: lastRead,
            lastUpdate: lastUpdate,
            totalJoinedUsers: totalJoinedUsers,
            namePriority: namePriority,
            draft: draft,
            reply: reply,
            userIds: userIds,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RoomsTableProcessedTableManager = ProcessedTableManager<
    _$StorageDatabase,
    $RoomsTable,
    Room,
    $$RoomsTableFilterComposer,
    $$RoomsTableOrderingComposer,
    $$RoomsTableAnnotationComposer,
    $$RoomsTableCreateCompanionBuilder,
    $$RoomsTableUpdateCompanionBuilder,
    (Room, BaseReferences<_$StorageDatabase, $RoomsTable, Room>),
    Room,
    PrefetchHooks Function()>;
typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String userId,
  Value<String?> deviceId,
  Value<String?> idserver,
  Value<String?> homeserver,
  Value<String?> homeserverName,
  Value<String?> accessToken,
  Value<String?> displayName,
  Value<String?> avatarUri,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> userId,
  Value<String?> deviceId,
  Value<String?> idserver,
  Value<String?> homeserver,
  Value<String?> homeserverName,
  Value<String?> accessToken,
  Value<String?> displayName,
  Value<String?> avatarUri,
  Value<int> rowid,
});

class $$UsersTableFilterComposer
    extends Composer<_$StorageDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get idserver => $composableBuilder(
      column: $table.idserver, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get homeserver => $composableBuilder(
      column: $table.homeserver, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get homeserverName => $composableBuilder(
      column: $table.homeserverName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accessToken => $composableBuilder(
      column: $table.accessToken, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatarUri => $composableBuilder(
      column: $table.avatarUri, builder: (column) => ColumnFilters(column));
}

class $$UsersTableOrderingComposer
    extends Composer<_$StorageDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get idserver => $composableBuilder(
      column: $table.idserver, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get homeserver => $composableBuilder(
      column: $table.homeserver, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get homeserverName => $composableBuilder(
      column: $table.homeserverName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accessToken => $composableBuilder(
      column: $table.accessToken, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatarUri => $composableBuilder(
      column: $table.avatarUri, builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer
    extends Composer<_$StorageDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get idserver =>
      $composableBuilder(column: $table.idserver, builder: (column) => column);

  GeneratedColumn<String> get homeserver => $composableBuilder(
      column: $table.homeserver, builder: (column) => column);

  GeneratedColumn<String> get homeserverName => $composableBuilder(
      column: $table.homeserverName, builder: (column) => column);

  GeneratedColumn<String> get accessToken => $composableBuilder(
      column: $table.accessToken, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get avatarUri =>
      $composableBuilder(column: $table.avatarUri, builder: (column) => column);
}

class $$UsersTableTableManager extends RootTableManager<
    _$StorageDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, BaseReferences<_$StorageDatabase, $UsersTable, User>),
    User,
    PrefetchHooks Function()> {
  $$UsersTableTableManager(_$StorageDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> userId = const Value.absent(),
            Value<String?> deviceId = const Value.absent(),
            Value<String?> idserver = const Value.absent(),
            Value<String?> homeserver = const Value.absent(),
            Value<String?> homeserverName = const Value.absent(),
            Value<String?> accessToken = const Value.absent(),
            Value<String?> displayName = const Value.absent(),
            Value<String?> avatarUri = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion(
            userId: userId,
            deviceId: deviceId,
            idserver: idserver,
            homeserver: homeserver,
            homeserverName: homeserverName,
            accessToken: accessToken,
            displayName: displayName,
            avatarUri: avatarUri,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String userId,
            Value<String?> deviceId = const Value.absent(),
            Value<String?> idserver = const Value.absent(),
            Value<String?> homeserver = const Value.absent(),
            Value<String?> homeserverName = const Value.absent(),
            Value<String?> accessToken = const Value.absent(),
            Value<String?> displayName = const Value.absent(),
            Value<String?> avatarUri = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            userId: userId,
            deviceId: deviceId,
            idserver: idserver,
            homeserver: homeserver,
            homeserverName: homeserverName,
            accessToken: accessToken,
            displayName: displayName,
            avatarUri: avatarUri,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$StorageDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, BaseReferences<_$StorageDatabase, $UsersTable, User>),
    User,
    PrefetchHooks Function()>;
typedef $$MediasTableCreateCompanionBuilder = MediasCompanion Function({
  required String mxcUri,
  Value<Uint8List?> data,
  Value<String?> type,
  Value<EncryptInfo?> info,
  Value<int> rowid,
});
typedef $$MediasTableUpdateCompanionBuilder = MediasCompanion Function({
  Value<String> mxcUri,
  Value<Uint8List?> data,
  Value<String?> type,
  Value<EncryptInfo?> info,
  Value<int> rowid,
});

class $$MediasTableFilterComposer
    extends Composer<_$StorageDatabase, $MediasTable> {
  $$MediasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get mxcUri => $composableBuilder(
      column: $table.mxcUri, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<EncryptInfo?, EncryptInfo, String> get info =>
      $composableBuilder(
          column: $table.info,
          builder: (column) => ColumnWithTypeConverterFilters(column));
}

class $$MediasTableOrderingComposer
    extends Composer<_$StorageDatabase, $MediasTable> {
  $$MediasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get mxcUri => $composableBuilder(
      column: $table.mxcUri, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get info => $composableBuilder(
      column: $table.info, builder: (column) => ColumnOrderings(column));
}

class $$MediasTableAnnotationComposer
    extends Composer<_$StorageDatabase, $MediasTable> {
  $$MediasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get mxcUri =>
      $composableBuilder(column: $table.mxcUri, builder: (column) => column);

  GeneratedColumn<Uint8List> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EncryptInfo?, String> get info =>
      $composableBuilder(column: $table.info, builder: (column) => column);
}

class $$MediasTableTableManager extends RootTableManager<
    _$StorageDatabase,
    $MediasTable,
    Media,
    $$MediasTableFilterComposer,
    $$MediasTableOrderingComposer,
    $$MediasTableAnnotationComposer,
    $$MediasTableCreateCompanionBuilder,
    $$MediasTableUpdateCompanionBuilder,
    (Media, BaseReferences<_$StorageDatabase, $MediasTable, Media>),
    Media,
    PrefetchHooks Function()> {
  $$MediasTableTableManager(_$StorageDatabase db, $MediasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> mxcUri = const Value.absent(),
            Value<Uint8List?> data = const Value.absent(),
            Value<String?> type = const Value.absent(),
            Value<EncryptInfo?> info = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MediasCompanion(
            mxcUri: mxcUri,
            data: data,
            type: type,
            info: info,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String mxcUri,
            Value<Uint8List?> data = const Value.absent(),
            Value<String?> type = const Value.absent(),
            Value<EncryptInfo?> info = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MediasCompanion.insert(
            mxcUri: mxcUri,
            data: data,
            type: type,
            info: info,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MediasTableProcessedTableManager = ProcessedTableManager<
    _$StorageDatabase,
    $MediasTable,
    Media,
    $$MediasTableFilterComposer,
    $$MediasTableOrderingComposer,
    $$MediasTableAnnotationComposer,
    $$MediasTableCreateCompanionBuilder,
    $$MediasTableUpdateCompanionBuilder,
    (Media, BaseReferences<_$StorageDatabase, $MediasTable, Media>),
    Media,
    PrefetchHooks Function()>;
typedef $$ReactionsTableCreateCompanionBuilder = ReactionsCompanion Function({
  required String id,
  Value<String?> roomId,
  Value<String?> userId,
  Value<String?> type,
  Value<String?> sender,
  Value<String?> stateKey,
  Value<String?> batch,
  Value<String?> prevBatch,
  required int timestamp,
  Value<String?> body,
  Value<String?> relType,
  Value<String?> relEventId,
  Value<int> rowid,
});
typedef $$ReactionsTableUpdateCompanionBuilder = ReactionsCompanion Function({
  Value<String> id,
  Value<String?> roomId,
  Value<String?> userId,
  Value<String?> type,
  Value<String?> sender,
  Value<String?> stateKey,
  Value<String?> batch,
  Value<String?> prevBatch,
  Value<int> timestamp,
  Value<String?> body,
  Value<String?> relType,
  Value<String?> relEventId,
  Value<int> rowid,
});

class $$ReactionsTableFilterComposer
    extends Composer<_$StorageDatabase, $ReactionsTable> {
  $$ReactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get roomId => $composableBuilder(
      column: $table.roomId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sender => $composableBuilder(
      column: $table.sender, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stateKey => $composableBuilder(
      column: $table.stateKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get batch => $composableBuilder(
      column: $table.batch, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get prevBatch => $composableBuilder(
      column: $table.prevBatch, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get relType => $composableBuilder(
      column: $table.relType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get relEventId => $composableBuilder(
      column: $table.relEventId, builder: (column) => ColumnFilters(column));
}

class $$ReactionsTableOrderingComposer
    extends Composer<_$StorageDatabase, $ReactionsTable> {
  $$ReactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get roomId => $composableBuilder(
      column: $table.roomId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sender => $composableBuilder(
      column: $table.sender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stateKey => $composableBuilder(
      column: $table.stateKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get batch => $composableBuilder(
      column: $table.batch, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get prevBatch => $composableBuilder(
      column: $table.prevBatch, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get relType => $composableBuilder(
      column: $table.relType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get relEventId => $composableBuilder(
      column: $table.relEventId, builder: (column) => ColumnOrderings(column));
}

class $$ReactionsTableAnnotationComposer
    extends Composer<_$StorageDatabase, $ReactionsTable> {
  $$ReactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get sender =>
      $composableBuilder(column: $table.sender, builder: (column) => column);

  GeneratedColumn<String> get stateKey =>
      $composableBuilder(column: $table.stateKey, builder: (column) => column);

  GeneratedColumn<String> get batch =>
      $composableBuilder(column: $table.batch, builder: (column) => column);

  GeneratedColumn<String> get prevBatch =>
      $composableBuilder(column: $table.prevBatch, builder: (column) => column);

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get relType =>
      $composableBuilder(column: $table.relType, builder: (column) => column);

  GeneratedColumn<String> get relEventId => $composableBuilder(
      column: $table.relEventId, builder: (column) => column);
}

class $$ReactionsTableTableManager extends RootTableManager<
    _$StorageDatabase,
    $ReactionsTable,
    Reaction,
    $$ReactionsTableFilterComposer,
    $$ReactionsTableOrderingComposer,
    $$ReactionsTableAnnotationComposer,
    $$ReactionsTableCreateCompanionBuilder,
    $$ReactionsTableUpdateCompanionBuilder,
    (Reaction, BaseReferences<_$StorageDatabase, $ReactionsTable, Reaction>),
    Reaction,
    PrefetchHooks Function()> {
  $$ReactionsTableTableManager(_$StorageDatabase db, $ReactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> roomId = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<String?> type = const Value.absent(),
            Value<String?> sender = const Value.absent(),
            Value<String?> stateKey = const Value.absent(),
            Value<String?> batch = const Value.absent(),
            Value<String?> prevBatch = const Value.absent(),
            Value<int> timestamp = const Value.absent(),
            Value<String?> body = const Value.absent(),
            Value<String?> relType = const Value.absent(),
            Value<String?> relEventId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReactionsCompanion(
            id: id,
            roomId: roomId,
            userId: userId,
            type: type,
            sender: sender,
            stateKey: stateKey,
            batch: batch,
            prevBatch: prevBatch,
            timestamp: timestamp,
            body: body,
            relType: relType,
            relEventId: relEventId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> roomId = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<String?> type = const Value.absent(),
            Value<String?> sender = const Value.absent(),
            Value<String?> stateKey = const Value.absent(),
            Value<String?> batch = const Value.absent(),
            Value<String?> prevBatch = const Value.absent(),
            required int timestamp,
            Value<String?> body = const Value.absent(),
            Value<String?> relType = const Value.absent(),
            Value<String?> relEventId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReactionsCompanion.insert(
            id: id,
            roomId: roomId,
            userId: userId,
            type: type,
            sender: sender,
            stateKey: stateKey,
            batch: batch,
            prevBatch: prevBatch,
            timestamp: timestamp,
            body: body,
            relType: relType,
            relEventId: relEventId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReactionsTableProcessedTableManager = ProcessedTableManager<
    _$StorageDatabase,
    $ReactionsTable,
    Reaction,
    $$ReactionsTableFilterComposer,
    $$ReactionsTableOrderingComposer,
    $$ReactionsTableAnnotationComposer,
    $$ReactionsTableCreateCompanionBuilder,
    $$ReactionsTableUpdateCompanionBuilder,
    (Reaction, BaseReferences<_$StorageDatabase, $ReactionsTable, Reaction>),
    Reaction,
    PrefetchHooks Function()>;
typedef $$ReceiptsTableCreateCompanionBuilder = ReceiptsCompanion Function({
  required String eventId,
  Value<int?> latestRead,
  Value<Map<String, dynamic>?> userReads,
  Value<int> rowid,
});
typedef $$ReceiptsTableUpdateCompanionBuilder = ReceiptsCompanion Function({
  Value<String> eventId,
  Value<int?> latestRead,
  Value<Map<String, dynamic>?> userReads,
  Value<int> rowid,
});

class $$ReceiptsTableFilterComposer
    extends Composer<_$StorageDatabase, $ReceiptsTable> {
  $$ReceiptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get eventId => $composableBuilder(
      column: $table.eventId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get latestRead => $composableBuilder(
      column: $table.latestRead, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Map<String, dynamic>?, Map<String, dynamic>,
          String>
      get userReads => $composableBuilder(
          column: $table.userReads,
          builder: (column) => ColumnWithTypeConverterFilters(column));
}

class $$ReceiptsTableOrderingComposer
    extends Composer<_$StorageDatabase, $ReceiptsTable> {
  $$ReceiptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get eventId => $composableBuilder(
      column: $table.eventId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get latestRead => $composableBuilder(
      column: $table.latestRead, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userReads => $composableBuilder(
      column: $table.userReads, builder: (column) => ColumnOrderings(column));
}

class $$ReceiptsTableAnnotationComposer
    extends Composer<_$StorageDatabase, $ReceiptsTable> {
  $$ReceiptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<int> get latestRead => $composableBuilder(
      column: $table.latestRead, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, dynamic>?, String>
      get userReads => $composableBuilder(
          column: $table.userReads, builder: (column) => column);
}

class $$ReceiptsTableTableManager extends RootTableManager<
    _$StorageDatabase,
    $ReceiptsTable,
    Receipt,
    $$ReceiptsTableFilterComposer,
    $$ReceiptsTableOrderingComposer,
    $$ReceiptsTableAnnotationComposer,
    $$ReceiptsTableCreateCompanionBuilder,
    $$ReceiptsTableUpdateCompanionBuilder,
    (Receipt, BaseReferences<_$StorageDatabase, $ReceiptsTable, Receipt>),
    Receipt,
    PrefetchHooks Function()> {
  $$ReceiptsTableTableManager(_$StorageDatabase db, $ReceiptsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReceiptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReceiptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReceiptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> eventId = const Value.absent(),
            Value<int?> latestRead = const Value.absent(),
            Value<Map<String, dynamic>?> userReads = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReceiptsCompanion(
            eventId: eventId,
            latestRead: latestRead,
            userReads: userReads,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String eventId,
            Value<int?> latestRead = const Value.absent(),
            Value<Map<String, dynamic>?> userReads = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReceiptsCompanion.insert(
            eventId: eventId,
            latestRead: latestRead,
            userReads: userReads,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReceiptsTableProcessedTableManager = ProcessedTableManager<
    _$StorageDatabase,
    $ReceiptsTable,
    Receipt,
    $$ReceiptsTableFilterComposer,
    $$ReceiptsTableOrderingComposer,
    $$ReceiptsTableAnnotationComposer,
    $$ReceiptsTableCreateCompanionBuilder,
    $$ReceiptsTableUpdateCompanionBuilder,
    (Receipt, BaseReferences<_$StorageDatabase, $ReceiptsTable, Receipt>),
    Receipt,
    PrefetchHooks Function()>;
typedef $$AuthsTableCreateCompanionBuilder = AuthsCompanion Function({
  required String id,
  Value<Map<String, dynamic>?> store,
  Value<int> rowid,
});
typedef $$AuthsTableUpdateCompanionBuilder = AuthsCompanion Function({
  Value<String> id,
  Value<Map<String, dynamic>?> store,
  Value<int> rowid,
});

class $$AuthsTableFilterComposer
    extends Composer<_$StorageDatabase, $AuthsTable> {
  $$AuthsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Map<String, dynamic>?, Map<String, dynamic>,
          String>
      get store => $composableBuilder(
          column: $table.store,
          builder: (column) => ColumnWithTypeConverterFilters(column));
}

class $$AuthsTableOrderingComposer
    extends Composer<_$StorageDatabase, $AuthsTable> {
  $$AuthsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get store => $composableBuilder(
      column: $table.store, builder: (column) => ColumnOrderings(column));
}

class $$AuthsTableAnnotationComposer
    extends Composer<_$StorageDatabase, $AuthsTable> {
  $$AuthsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, dynamic>?, String> get store =>
      $composableBuilder(column: $table.store, builder: (column) => column);
}

class $$AuthsTableTableManager extends RootTableManager<
    _$StorageDatabase,
    $AuthsTable,
    Auth,
    $$AuthsTableFilterComposer,
    $$AuthsTableOrderingComposer,
    $$AuthsTableAnnotationComposer,
    $$AuthsTableCreateCompanionBuilder,
    $$AuthsTableUpdateCompanionBuilder,
    (Auth, BaseReferences<_$StorageDatabase, $AuthsTable, Auth>),
    Auth,
    PrefetchHooks Function()> {
  $$AuthsTableTableManager(_$StorageDatabase db, $AuthsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuthsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuthsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuthsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<Map<String, dynamic>?> store = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AuthsCompanion(
            id: id,
            store: store,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<Map<String, dynamic>?> store = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AuthsCompanion.insert(
            id: id,
            store: store,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AuthsTableProcessedTableManager = ProcessedTableManager<
    _$StorageDatabase,
    $AuthsTable,
    Auth,
    $$AuthsTableFilterComposer,
    $$AuthsTableOrderingComposer,
    $$AuthsTableAnnotationComposer,
    $$AuthsTableCreateCompanionBuilder,
    $$AuthsTableUpdateCompanionBuilder,
    (Auth, BaseReferences<_$StorageDatabase, $AuthsTable, Auth>),
    Auth,
    PrefetchHooks Function()>;
typedef $$SyncsTableCreateCompanionBuilder = SyncsCompanion Function({
  required String id,
  Value<Map<String, dynamic>?> store,
  Value<int> rowid,
});
typedef $$SyncsTableUpdateCompanionBuilder = SyncsCompanion Function({
  Value<String> id,
  Value<Map<String, dynamic>?> store,
  Value<int> rowid,
});

class $$SyncsTableFilterComposer
    extends Composer<_$StorageDatabase, $SyncsTable> {
  $$SyncsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Map<String, dynamic>?, Map<String, dynamic>,
          String>
      get store => $composableBuilder(
          column: $table.store,
          builder: (column) => ColumnWithTypeConverterFilters(column));
}

class $$SyncsTableOrderingComposer
    extends Composer<_$StorageDatabase, $SyncsTable> {
  $$SyncsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get store => $composableBuilder(
      column: $table.store, builder: (column) => ColumnOrderings(column));
}

class $$SyncsTableAnnotationComposer
    extends Composer<_$StorageDatabase, $SyncsTable> {
  $$SyncsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, dynamic>?, String> get store =>
      $composableBuilder(column: $table.store, builder: (column) => column);
}

class $$SyncsTableTableManager extends RootTableManager<
    _$StorageDatabase,
    $SyncsTable,
    Sync,
    $$SyncsTableFilterComposer,
    $$SyncsTableOrderingComposer,
    $$SyncsTableAnnotationComposer,
    $$SyncsTableCreateCompanionBuilder,
    $$SyncsTableUpdateCompanionBuilder,
    (Sync, BaseReferences<_$StorageDatabase, $SyncsTable, Sync>),
    Sync,
    PrefetchHooks Function()> {
  $$SyncsTableTableManager(_$StorageDatabase db, $SyncsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<Map<String, dynamic>?> store = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncsCompanion(
            id: id,
            store: store,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<Map<String, dynamic>?> store = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncsCompanion.insert(
            id: id,
            store: store,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncsTableProcessedTableManager = ProcessedTableManager<
    _$StorageDatabase,
    $SyncsTable,
    Sync,
    $$SyncsTableFilterComposer,
    $$SyncsTableOrderingComposer,
    $$SyncsTableAnnotationComposer,
    $$SyncsTableCreateCompanionBuilder,
    $$SyncsTableUpdateCompanionBuilder,
    (Sync, BaseReferences<_$StorageDatabase, $SyncsTable, Sync>),
    Sync,
    PrefetchHooks Function()>;
typedef $$CryptosTableCreateCompanionBuilder = CryptosCompanion Function({
  required String id,
  Value<Map<String, dynamic>?> store,
  Value<int> rowid,
});
typedef $$CryptosTableUpdateCompanionBuilder = CryptosCompanion Function({
  Value<String> id,
  Value<Map<String, dynamic>?> store,
  Value<int> rowid,
});

class $$CryptosTableFilterComposer
    extends Composer<_$StorageDatabase, $CryptosTable> {
  $$CryptosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Map<String, dynamic>?, Map<String, dynamic>,
          String>
      get store => $composableBuilder(
          column: $table.store,
          builder: (column) => ColumnWithTypeConverterFilters(column));
}

class $$CryptosTableOrderingComposer
    extends Composer<_$StorageDatabase, $CryptosTable> {
  $$CryptosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get store => $composableBuilder(
      column: $table.store, builder: (column) => ColumnOrderings(column));
}

class $$CryptosTableAnnotationComposer
    extends Composer<_$StorageDatabase, $CryptosTable> {
  $$CryptosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, dynamic>?, String> get store =>
      $composableBuilder(column: $table.store, builder: (column) => column);
}

class $$CryptosTableTableManager extends RootTableManager<
    _$StorageDatabase,
    $CryptosTable,
    Crypto,
    $$CryptosTableFilterComposer,
    $$CryptosTableOrderingComposer,
    $$CryptosTableAnnotationComposer,
    $$CryptosTableCreateCompanionBuilder,
    $$CryptosTableUpdateCompanionBuilder,
    (Crypto, BaseReferences<_$StorageDatabase, $CryptosTable, Crypto>),
    Crypto,
    PrefetchHooks Function()> {
  $$CryptosTableTableManager(_$StorageDatabase db, $CryptosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CryptosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CryptosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CryptosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<Map<String, dynamic>?> store = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CryptosCompanion(
            id: id,
            store: store,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<Map<String, dynamic>?> store = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CryptosCompanion.insert(
            id: id,
            store: store,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CryptosTableProcessedTableManager = ProcessedTableManager<
    _$StorageDatabase,
    $CryptosTable,
    Crypto,
    $$CryptosTableFilterComposer,
    $$CryptosTableOrderingComposer,
    $$CryptosTableAnnotationComposer,
    $$CryptosTableCreateCompanionBuilder,
    $$CryptosTableUpdateCompanionBuilder,
    (Crypto, BaseReferences<_$StorageDatabase, $CryptosTable, Crypto>),
    Crypto,
    PrefetchHooks Function()>;
typedef $$MessageSessionsTableCreateCompanionBuilder = MessageSessionsCompanion
    Function({
  required String id,
  required String roomId,
  required int index,
  Value<String?> identityKey,
  required String session,
  required bool inbound,
  required int createdAt,
  Value<int> rowid,
});
typedef $$MessageSessionsTableUpdateCompanionBuilder = MessageSessionsCompanion
    Function({
  Value<String> id,
  Value<String> roomId,
  Value<int> index,
  Value<String?> identityKey,
  Value<String> session,
  Value<bool> inbound,
  Value<int> createdAt,
  Value<int> rowid,
});

class $$MessageSessionsTableFilterComposer
    extends Composer<_$StorageDatabase, $MessageSessionsTable> {
  $$MessageSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get roomId => $composableBuilder(
      column: $table.roomId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get index => $composableBuilder(
      column: $table.index, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get identityKey => $composableBuilder(
      column: $table.identityKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get session => $composableBuilder(
      column: $table.session, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get inbound => $composableBuilder(
      column: $table.inbound, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$MessageSessionsTableOrderingComposer
    extends Composer<_$StorageDatabase, $MessageSessionsTable> {
  $$MessageSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get roomId => $composableBuilder(
      column: $table.roomId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get index => $composableBuilder(
      column: $table.index, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get identityKey => $composableBuilder(
      column: $table.identityKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get session => $composableBuilder(
      column: $table.session, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get inbound => $composableBuilder(
      column: $table.inbound, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$MessageSessionsTableAnnotationComposer
    extends Composer<_$StorageDatabase, $MessageSessionsTable> {
  $$MessageSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);

  GeneratedColumn<int> get index =>
      $composableBuilder(column: $table.index, builder: (column) => column);

  GeneratedColumn<String> get identityKey => $composableBuilder(
      column: $table.identityKey, builder: (column) => column);

  GeneratedColumn<String> get session =>
      $composableBuilder(column: $table.session, builder: (column) => column);

  GeneratedColumn<bool> get inbound =>
      $composableBuilder(column: $table.inbound, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MessageSessionsTableTableManager extends RootTableManager<
    _$StorageDatabase,
    $MessageSessionsTable,
    MessageSession,
    $$MessageSessionsTableFilterComposer,
    $$MessageSessionsTableOrderingComposer,
    $$MessageSessionsTableAnnotationComposer,
    $$MessageSessionsTableCreateCompanionBuilder,
    $$MessageSessionsTableUpdateCompanionBuilder,
    (
      MessageSession,
      BaseReferences<_$StorageDatabase, $MessageSessionsTable, MessageSession>
    ),
    MessageSession,
    PrefetchHooks Function()> {
  $$MessageSessionsTableTableManager(
      _$StorageDatabase db, $MessageSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessageSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessageSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessageSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> roomId = const Value.absent(),
            Value<int> index = const Value.absent(),
            Value<String?> identityKey = const Value.absent(),
            Value<String> session = const Value.absent(),
            Value<bool> inbound = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MessageSessionsCompanion(
            id: id,
            roomId: roomId,
            index: index,
            identityKey: identityKey,
            session: session,
            inbound: inbound,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String roomId,
            required int index,
            Value<String?> identityKey = const Value.absent(),
            required String session,
            required bool inbound,
            required int createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              MessageSessionsCompanion.insert(
            id: id,
            roomId: roomId,
            index: index,
            identityKey: identityKey,
            session: session,
            inbound: inbound,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MessageSessionsTableProcessedTableManager = ProcessedTableManager<
    _$StorageDatabase,
    $MessageSessionsTable,
    MessageSession,
    $$MessageSessionsTableFilterComposer,
    $$MessageSessionsTableOrderingComposer,
    $$MessageSessionsTableAnnotationComposer,
    $$MessageSessionsTableCreateCompanionBuilder,
    $$MessageSessionsTableUpdateCompanionBuilder,
    (
      MessageSession,
      BaseReferences<_$StorageDatabase, $MessageSessionsTable, MessageSession>
    ),
    MessageSession,
    PrefetchHooks Function()>;
typedef $$KeySessionsTableCreateCompanionBuilder = KeySessionsCompanion
    Function({
  required String id,
  required String sessionId,
  required String identityKey,
  Value<String?> session,
  Value<int> rowid,
});
typedef $$KeySessionsTableUpdateCompanionBuilder = KeySessionsCompanion
    Function({
  Value<String> id,
  Value<String> sessionId,
  Value<String> identityKey,
  Value<String?> session,
  Value<int> rowid,
});

class $$KeySessionsTableFilterComposer
    extends Composer<_$StorageDatabase, $KeySessionsTable> {
  $$KeySessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get identityKey => $composableBuilder(
      column: $table.identityKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get session => $composableBuilder(
      column: $table.session, builder: (column) => ColumnFilters(column));
}

class $$KeySessionsTableOrderingComposer
    extends Composer<_$StorageDatabase, $KeySessionsTable> {
  $$KeySessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get identityKey => $composableBuilder(
      column: $table.identityKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get session => $composableBuilder(
      column: $table.session, builder: (column) => ColumnOrderings(column));
}

class $$KeySessionsTableAnnotationComposer
    extends Composer<_$StorageDatabase, $KeySessionsTable> {
  $$KeySessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get identityKey => $composableBuilder(
      column: $table.identityKey, builder: (column) => column);

  GeneratedColumn<String> get session =>
      $composableBuilder(column: $table.session, builder: (column) => column);
}

class $$KeySessionsTableTableManager extends RootTableManager<
    _$StorageDatabase,
    $KeySessionsTable,
    KeySession,
    $$KeySessionsTableFilterComposer,
    $$KeySessionsTableOrderingComposer,
    $$KeySessionsTableAnnotationComposer,
    $$KeySessionsTableCreateCompanionBuilder,
    $$KeySessionsTableUpdateCompanionBuilder,
    (
      KeySession,
      BaseReferences<_$StorageDatabase, $KeySessionsTable, KeySession>
    ),
    KeySession,
    PrefetchHooks Function()> {
  $$KeySessionsTableTableManager(_$StorageDatabase db, $KeySessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KeySessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KeySessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KeySessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> sessionId = const Value.absent(),
            Value<String> identityKey = const Value.absent(),
            Value<String?> session = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              KeySessionsCompanion(
            id: id,
            sessionId: sessionId,
            identityKey: identityKey,
            session: session,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String sessionId,
            required String identityKey,
            Value<String?> session = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              KeySessionsCompanion.insert(
            id: id,
            sessionId: sessionId,
            identityKey: identityKey,
            session: session,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$KeySessionsTableProcessedTableManager = ProcessedTableManager<
    _$StorageDatabase,
    $KeySessionsTable,
    KeySession,
    $$KeySessionsTableFilterComposer,
    $$KeySessionsTableOrderingComposer,
    $$KeySessionsTableAnnotationComposer,
    $$KeySessionsTableCreateCompanionBuilder,
    $$KeySessionsTableUpdateCompanionBuilder,
    (
      KeySession,
      BaseReferences<_$StorageDatabase, $KeySessionsTable, KeySession>
    ),
    KeySession,
    PrefetchHooks Function()>;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String id,
  Value<Map<String, dynamic>?> store,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> id,
  Value<Map<String, dynamic>?> store,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$StorageDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Map<String, dynamic>?, Map<String, dynamic>,
          String>
      get store => $composableBuilder(
          column: $table.store,
          builder: (column) => ColumnWithTypeConverterFilters(column));
}

class $$SettingsTableOrderingComposer
    extends Composer<_$StorageDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get store => $composableBuilder(
      column: $table.store, builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$StorageDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, dynamic>?, String> get store =>
      $composableBuilder(column: $table.store, builder: (column) => column);
}

class $$SettingsTableTableManager extends RootTableManager<
    _$StorageDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$StorageDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()> {
  $$SettingsTableTableManager(_$StorageDatabase db, $SettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<Map<String, dynamic>?> store = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion(
            id: id,
            store: store,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<Map<String, dynamic>?> store = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion.insert(
            id: id,
            store: store,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsTableProcessedTableManager = ProcessedTableManager<
    _$StorageDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$StorageDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()>;

class $StorageDatabaseManager {
  final _$StorageDatabase _db;
  $StorageDatabaseManager(this._db);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$DecryptedTableTableManager get decrypted =>
      $$DecryptedTableTableManager(_db, _db.decrypted);
  $$RoomsTableTableManager get rooms =>
      $$RoomsTableTableManager(_db, _db.rooms);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$MediasTableTableManager get medias =>
      $$MediasTableTableManager(_db, _db.medias);
  $$ReactionsTableTableManager get reactions =>
      $$ReactionsTableTableManager(_db, _db.reactions);
  $$ReceiptsTableTableManager get receipts =>
      $$ReceiptsTableTableManager(_db, _db.receipts);
  $$AuthsTableTableManager get auths =>
      $$AuthsTableTableManager(_db, _db.auths);
  $$SyncsTableTableManager get syncs =>
      $$SyncsTableTableManager(_db, _db.syncs);
  $$CryptosTableTableManager get cryptos =>
      $$CryptosTableTableManager(_db, _db.cryptos);
  $$MessageSessionsTableTableManager get messageSessions =>
      $$MessageSessionsTableTableManager(_db, _db.messageSessions);
  $$KeySessionsTableTableManager get keySessions =>
      $$KeySessionsTableTableManager(_db, _db.keySessions);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
