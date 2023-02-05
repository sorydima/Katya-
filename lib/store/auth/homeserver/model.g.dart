// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Homeserver _$HomeserverFromJson(Map<String, dynamic> json) => Homeserver(
      hostname: json['hostname'] as String?,
      baseUrl: json['baseUrl'] as String?,
      photoUrl: json['photoUrl'] as String?,
      identityUrl: json['identityUrl'] as String?,
      loginTypes: (json['loginTypes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      signupTypes: (json['signupTypes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      location: json['location'] as String?,
      description: json['description'] as String?,
      usersActive: json['usersActive'] as String?,
      roomsTotal: json['roomsTotal'] as String?,
      founded: json['founded'] as String?,
      valid: json['valid'] as bool? ?? false,
    );

Map<String, dynamic> _$HomeserverToJson(Homeserver instance) =>
    <String, dynamic>{
      'hostname': instance.hostname,
      'baseUrl': instance.baseUrl,
      'photoUrl': instance.photoUrl,
      'identityUrl': instance.identityUrl,
      'loginTypes': instance.loginTypes,
      'signupTypes': instance.signupTypes,
      'location': instance.location,
      'description': instance.description,
      'usersActive': instance.usersActive,
      'roomsTotal': instance.roomsTotal,
      'founded': instance.founded,
      'valid': instance.valid,
    };
