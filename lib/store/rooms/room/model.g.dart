// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Room _$RoomFromJson(Map<String, dynamic> json) => Room(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Empty Chat',
      alias: json['alias'] as String? ?? '',
      homeserver: json['homeserver'] as String?,
      avatarUri: json['avatarUri'] as String?,
      topic: json['topic'] as String? ?? '',
      joinRule: json['joinRule'] as String? ?? 'private',
      drafting: json['drafting'] as bool? ?? false,
      invite: json['invite'] as bool? ?? false,
      direct: json['direct'] as bool? ?? false,
      sending: json['sending'] as bool? ?? false,
      hidden: json['hidden'] as bool? ?? false,
      archived: json['archived'] as bool? ?? false,
      draft: json['draft'] == null
          ? null
          : Message.fromJson(json['draft'] as Map<String, dynamic>),
      reply: json['reply'] == null
          ? null
          : Message.fromJson(json['reply'] as Map<String, dynamic>),
      userIds: (json['userIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      lastRead: json['lastRead'] as int? ?? 0,
      lastUpdate: json['lastUpdate'] as int? ?? 0,
      namePriority: json['namePriority'] as int? ?? 4,
      totalJoinedUsers: json['totalJoinedUsers'] as int? ?? 0,
      guestEnabled: json['guestEnabled'] as bool? ?? false,
      encryptionEnabled: json['encryptionEnabled'] as bool? ?? false,
      worldReadable: json['worldReadable'] as bool? ?? false,
      lastBatch: json['lastBatch'] as String?,
      nextBatch: json['nextBatch'] as String?,
      prevBatch: json['prevBatch'] as String?,
    );

Map<String, dynamic> _$RoomToJson(Room instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'alias': instance.alias,
      'homeserver': instance.homeserver,
      'avatarUri': instance.avatarUri,
      'topic': instance.topic,
      'joinRule': instance.joinRule,
      'drafting': instance.drafting,
      'direct': instance.direct,
      'sending': instance.sending,
      'invite': instance.invite,
      'guestEnabled': instance.guestEnabled,
      'encryptionEnabled': instance.encryptionEnabled,
      'worldReadable': instance.worldReadable,
      'hidden': instance.hidden,
      'archived': instance.archived,
      'lastBatch': instance.lastBatch,
      'prevBatch': instance.prevBatch,
      'nextBatch': instance.nextBatch,
      'lastRead': instance.lastRead,
      'lastUpdate': instance.lastUpdate,
      'totalJoinedUsers': instance.totalJoinedUsers,
      'namePriority': instance.namePriority,
      'draft': instance.draft,
      'reply': instance.reply,
      'userIds': instance.userIds,
    };
