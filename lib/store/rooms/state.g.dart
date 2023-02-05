// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomStore _$RoomStoreFromJson(Map<String, dynamic> json) => RoomStore(
      rooms: (json['rooms'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, Room.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
    );

Map<String, dynamic> _$RoomStoreToJson(RoomStore instance) => <String, dynamic>{
      'rooms': instance.rooms,
    };
