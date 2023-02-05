// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      userId: json['userId'] as String?,
      deviceId: json['deviceId'] as String?,
      idserver: json['idserver'] as String?,
      homeserver: json['homeserver'] as String?,
      homeserverName: json['homeserverName'] as String?,
      accessToken: json['accessToken'] as String?,
      displayName: json['displayName'] as String?,
      avatarUri: json['avatarUri'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'userId': instance.userId,
      'deviceId': instance.deviceId,
      'idserver': instance.idserver,
      'homeserver': instance.homeserver,
      'homeserverName': instance.homeserverName,
      'accessToken': instance.accessToken,
      'displayName': instance.displayName,
      'avatarUri': instance.avatarUri,
    };
