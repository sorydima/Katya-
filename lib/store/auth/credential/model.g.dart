// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Credential _$CredentialFromJson(Map<String, dynamic> json) => Credential(
      type: json['type'] as String?,
      value: json['value'] as String?,
      params: json['params'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$CredentialToJson(Credential instance) =>
    <String, dynamic>{
      'type': instance.type,
      'value': instance.value,
      'params': instance.params,
    };
