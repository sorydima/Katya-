import 'package:drift/drift.dart' as drift;
import 'package:json_annotation/json_annotation.dart';
import 'package:katya/global/print.dart';
import 'package:katya/models/token_gate_config.dart';
import 'package:katya/storage/database.dart';
import 'package:katya/store/events/model.dart';
import 'package:katya/store/events/reactions/model.dart';

part 'model.g.dart';

///
/// Message Model
///
/// Allows converting to Json or Database Entity using
/// JsonSerializable and Drift conversions respectively
///
@JsonSerializable()
class Message extends Event implements drift.Insertable<Message> {
  // message drafting
  @JsonKey(defaultValue: false)
  final bool pending;
  @JsonKey(defaultValue: false)
  final bool syncing;
  @JsonKey(defaultValue: false)
  final bool failed;

  // message editing
  @JsonKey(defaultValue: false)
  final bool edited;
  @JsonKey(defaultValue: false)
  final bool replacement;
  @JsonKey(defaultValue: false)
  final bool hasLink;

  // Message timestamps
  @JsonKey(defaultValue: 0)
  final int received;

  // Message Only
  final String? body;
  final String? msgtype;
  final String? format;
  final String? formattedBody;
  final String? url;
  final Map<String, dynamic>? file;
  final Map<String, dynamic>? info;

  // Encrypted Messages only
  final String? typeDecrypted; // inner type of decrypted event
  final String? ciphertext;

  // Additional properties
  final Map<String, dynamic>? unsigned;
  final Map<String, dynamic>? prevContent;
  final Map<String, dynamic>? redactedBecause;
  final Map<String, dynamic>? relatesTo;
  final Map<String, dynamic>? relations;
  final List<Message>? edits;
  final Map<String, dynamic>? thread;
  final List<dynamic>? inviteRoomState;
  final int? originServerTsLocalCreate;
  final int? originServerTsLocalEdit;
  final int? originServerTsLocalReceipt;
  final String? status;
  final String? algorithm;

  // Token gating
  final TokenGateConfig? tokenGateConfig;
  final String? sessionId;
  final String? senderKey; // Curve25519 device key which initiated the session
  final String? deviceId;
  final String? relatedEventId;
  // References
  final List<String> editIds;

  @JsonKey(ignore: true)
  final List<Reaction> reactions;

  const Message({
    required super.id,
    required super.sender,
    required super.timestamp,
    required super.type,
    required super.roomId,
    super.content,
    this.pending = false,
    this.syncing = false,
    this.failed = false,
    this.edited = false,
    this.replacement = false,
    this.hasLink = false,
    this.received = 0,
    this.body,
    this.msgtype,
    this.format,
    this.formattedBody,
    this.url,
    this.file,
    this.info,
    this.typeDecrypted,
    this.ciphertext,
    this.algorithm,
    this.tokenGateConfig,
    this.sessionId,
    this.senderKey,
    this.deviceId,
    this.relatedEventId,
    this.editIds = const [],
    this.reactions = const [],
    this.unsigned,
    this.prevContent,
    this.redactedBecause,
    this.relatesTo,
    this.relations,
    this.edits,
    this.thread,
    this.inviteRoomState,
    this.originServerTsLocalCreate,
    this.originServerTsLocalEdit,
    this.originServerTsLocalReceipt,
    this.status,
  }) : super();

  Message copyMessageWith({
    String? id,
    String? sender,
    int? timestamp,
    String? type,
    String? roomId,
    Map<String, dynamic>? content,
    bool? pending,
    bool? syncing,
    bool? failed,
    bool? edited,
    bool? replacement,
    bool? hasLink,
    int? received,
    String? body,
    String? msgtype,
    String? format,
    String? formattedBody,
    String? url,
    Map<String, dynamic>? file,
    Map<String, dynamic>? info,
    String? typeDecrypted,
    String? ciphertext,
    String? algorithm,
    TokenGateConfig? tokenGateConfig,
    Map<String, dynamic>? unsigned,
    Map<String, dynamic>? prevContent,
    Map<String, dynamic>? redactedBecause,
    Map<String, dynamic>? relatesTo,
    Map<String, dynamic>? relations,
    Map<String, Reaction>? reactions,
    List<Message>? edits,
    Map<String, dynamic>? thread,
    String? stateKey,
    List<dynamic>? inviteRoomState,
    int? originServerTsLocalCreate,
    int? originServerTsLocalEdit,
    int? originServerTsLocalReceipt,
    String? status,
  }) {
    return Message(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      roomId: roomId ?? this.roomId,
      content: content ?? this.content,
      pending: pending ?? this.pending,
      syncing: syncing ?? this.syncing,
      failed: failed ?? this.failed,
      edited: edited ?? this.edited,
      replacement: replacement ?? this.replacement,
      hasLink: hasLink ?? this.hasLink,
      received: received ?? this.received,
      body: body ?? this.body,
      msgtype: msgtype ?? this.msgtype,
      format: format ?? this.format,
      formattedBody: formattedBody ?? this.formattedBody,
      url: url ?? this.url,
      file: file ?? this.file,
      info: info ?? this.info,
      typeDecrypted: typeDecrypted ?? this.typeDecrypted,
      ciphertext: ciphertext ?? this.ciphertext,
      algorithm: algorithm ?? this.algorithm,
      tokenGateConfig: tokenGateConfig ?? this.tokenGateConfig,
      unsigned: unsigned ?? this.unsigned,
      prevContent: prevContent ?? this.prevContent,
      redactedBecause: redactedBecause ?? this.redactedBecause,
      relatesTo: relatesTo ?? this.relatesTo,
      relations: relations ?? this.relations,
      edits: edits ?? this.edits,
      thread: thread ?? this.thread,
    );
  }

  // Getter methods for commonly used properties
  String get senderId => sender ?? '';
  int get originServerTs => timestamp;
  bool get encrypted => ciphertext != null;
  String? get eventId => id;

  // allows converting to message companion type for saving through drift
  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    return MessagesCompanion(
      id: drift.Value(id!),
      userId: drift.Value(userId),
      roomId: drift.Value(roomId),
      type: drift.Value(type),
      sender: drift.Value(sender),
      stateKey: drift.Value(stateKey),
      batch: drift.Value(batch),
      prevBatch: drift.Value(prevBatch),
      syncing: drift.Value(syncing),
      pending: drift.Value(pending),
      failed: drift.Value(failed),
      replacement: drift.Value(replacement),
      edited: drift.Value(edited),
      timestamp: drift.Value(timestamp),
      received: drift.Value(received),
      body: drift.Value(body),
      msgtype: drift.Value(msgtype),
      format: drift.Value(format),
      url: drift.Value(url),
      file: drift.Value(file),
      formattedBody: drift.Value(formattedBody),
      typeDecrypted: drift.Value(typeDecrypted),
      ciphertext: drift.Value(ciphertext),
      senderKey: drift.Value(senderKey),
      deviceId: drift.Value(deviceId),
      algorithm: drift.Value(algorithm),
      sessionId: drift.Value(sessionId),
      relatedEventId: drift.Value(relatedEventId),
      editIds: drift.Value(editIds),
      hasLink: drift.Value(hasLink),
    ).toColumns(nullToAbsent);
  }

  @override
  Map<String, dynamic> toJson() => _$MessageToJson(this);

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

  factory Message.fromEvent(Event event) {
    try {
      final content = event.content ?? {};
      String body = content['body'] ?? '';
      var msgtype = content['msgtype'];
      var replacement = false;
      var relatedEventId;
      var hasLink = false;

      final relatesTo = content['m.relates_to'];

      if (relatesTo != null && relatesTo['rel_type'] == 'm.replace') {
        replacement = true;
        relatedEventId = relatesTo['event_id'];
      }

      final newContent = content['m.new_content'];

      if (newContent != null) {
        body = content['m.new_content']['body'];
        msgtype = content['m.new_content']['msgtype'];
      }

      var info;
      if (content['info'] != null) {
        try {
          info = Map<String, dynamic>.from(content['info']);
        } catch (error) {
          log.error('[Message.fromEvent] Info Conversion Failed $error');
        }
      }

      hasLink = body.contains('http');

      return Message(
        id: event.id,
        roomId: event.roomId,
        type: event.type,
        typeDecrypted: null,
        sender: event.sender,
        timestamp: event.timestamp,
        content: content,
        body: body,
        msgtype: msgtype,
        format: content['format'],
        formattedBody: content['formatted_body'],
        url: content['url'],
        file: content['file'],
        info: info,
        ciphertext: content['ciphertext'] ?? '',
        algorithm: content['algorithm'],
        senderKey: content['sender_key'],
        sessionId: content['session_id'],
        deviceId: content['device_id'],
        replacement: replacement,
        relatedEventId: relatedEventId,
        received: DateTime.now().millisecondsSinceEpoch,
        hasLink: hasLink,
        failed: false,
        pending: false,
        syncing: false,
        edited: false,
      );
    } catch (error) {
      log.error('[Message.fromEvent] $error');
      return Message(
        id: event.id,
        roomId: event.roomId,
        body: '',
        type: event.type,
        sender: event.sender,
        timestamp: event.timestamp,
        pending: false,
        syncing: false,
        failed: false,
        edited: false,
      );
    }
  }
}
