// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatList _$ChatListFromJson(Map<String, dynamic> json) => ChatList(
      id: json['id'] as String,
      order: $enumDecodeNullable(_$SortOrderEnumMap, json['order']) ??
          SortOrder.Latest,
      roomIds: (json['roomIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ChatListToJson(ChatList instance) => <String, dynamic>{
      'id': instance.id,
      'order': _$SortOrderEnumMap[instance.order]!,
      'roomIds': instance.roomIds,
    };

const _$SortOrderEnumMap = {
  SortOrder.Custom: 'Custom',
  SortOrder.Latest: 'Latest',
  SortOrder.Oldest: 'Oldest',
  SortOrder.Alphabetical: 'Alphabetical',
};
