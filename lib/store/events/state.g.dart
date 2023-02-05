// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventStore _$EventStoreFromJson(Map<String, dynamic> json) => EventStore(
      events: (json['events'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
                k,
                (e as List<dynamic>)
                    .map((e) => Event.fromJson(e as Map<String, dynamic>))
                    .toList()),
          ) ??
          const {},
      messages: (json['messages'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
                k,
                (e as List<dynamic>)
                    .map((e) => Message.fromJson(e as Map<String, dynamic>))
                    .toList()),
          ) ??
          const {},
      messagesDecrypted:
          (json['messagesDecrypted'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(
                    k,
                    (e as List<dynamic>)
                        .map((e) => Message.fromJson(e as Map<String, dynamic>))
                        .toList()),
              ) ??
              const {},
      reactions: (json['reactions'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
                k,
                (e as List<dynamic>)
                    .map((e) => Reaction.fromJson(e as Map<String, dynamic>))
                    .toList()),
          ) ??
          const {},
      receipts: (json['receipts'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
                k,
                (e as Map<String, dynamic>).map(
                  (k, e) =>
                      MapEntry(k, Receipt.fromJson(e as Map<String, dynamic>)),
                )),
          ) ??
          const {},
      redactions: (json['redactions'] as Map<String, dynamic>?)?.map(
            (k, e) =>
                MapEntry(k, Redaction.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
      outbox: (json['outbox'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
                k,
                (e as Map<String, dynamic>).map(
                  (k, e) =>
                      MapEntry(k, Message.fromJson(e as Map<String, dynamic>)),
                )),
          ) ??
          const {},
    );

Map<String, dynamic> _$EventStoreToJson(EventStore instance) =>
    <String, dynamic>{
      'events': instance.events,
      'redactions': instance.redactions,
      'messages': instance.messages,
      'reactions': instance.reactions,
      'receipts': instance.receipts,
      'outbox': instance.outbox,
      'messagesDecrypted': instance.messagesDecrypted,
    };
