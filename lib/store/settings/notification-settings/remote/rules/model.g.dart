// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Rule _$RuleFromJson(Map<String, dynamic> json) => Rule(
      id: json['id'] as String?,
      enabled: json['enabled'] as bool?,
      isDefault: json['isDefault'] as bool?,
      conditions: (json['conditions'] as List<dynamic>?)
          ?.map((e) => Map<String, String>.from(e as Map))
          .toList(),
      actions: json['actions'] as List<dynamic>?,
    );

Map<String, dynamic> _$RuleToJson(Rule instance) => <String, dynamic>{
      'id': instance.id,
      'enabled': instance.enabled,
      'isDefault': instance.isDefault,
      'conditions': instance.conditions,
      'actions': instance.actions,
    };
