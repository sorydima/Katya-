// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppContext _$AppContextFromJson(Map<String, dynamic> json) => AppContext(
      id: json['id'] as String? ?? Values.empty,
      pinHash: json['pinHash'] as String? ?? Values.empty,
      secretKeyEncrypted: json['secretKeyEncrypted'] as String? ?? Values.empty,
    );

Map<String, dynamic> _$AppContextToJson(AppContext instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pinHash': instance.pinHash,
      'secretKeyEncrypted': instance.secretKeyEncrypted,
    };
