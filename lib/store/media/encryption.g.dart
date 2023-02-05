// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'encryption.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EncryptInfo _$EncryptInfoFromJson(Map<String, dynamic> json) => EncryptInfo(
      key: json['key'] as String?,
      iv: json['iv'] as String?,
      shasum: json['shasum'] as String?,
    );

Map<String, dynamic> _$EncryptInfoToJson(EncryptInfo instance) =>
    <String, dynamic>{
      'iv': instance.iv,
      'key': instance.key,
      'shasum': instance.shasum,
    };
