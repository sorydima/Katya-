// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageSession _$MessageSessionFromJson(Map<String, dynamic> json) =>
    MessageSession(
      index: json['index'] as int? ?? 0,
      serialized: json['serialized'] as String,
      createdAt: json['createdAt'] as int,
    );

Map<String, dynamic> _$MessageSessionToJson(MessageSession instance) =>
    <String, dynamic>{
      'index': instance.index,
      'serialized': instance.serialized,
      'createdAt': instance.createdAt,
    };
