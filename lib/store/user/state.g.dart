// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserStore _$UserStoreFromJson(Map<String, dynamic> json) => UserStore(
      blocked: (json['blocked'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$UserStoreToJson(UserStore instance) => <String, dynamic>{
      'blocked': instance.blocked,
    };
