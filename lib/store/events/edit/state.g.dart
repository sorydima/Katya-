// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditState _$EditStateFromJson(Map<String, dynamic> json) => EditState(
      editingMessages: (json['editingMessages'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as bool),
          ) ??
          const {},
      messages: (json['messages'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, Message.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
    );

Map<String, dynamic> _$EditStateToJson(EditState instance) => <String, dynamic>{
      'editingMessages': instance.editingMessages,
      'messages': instance.messages,
    };
