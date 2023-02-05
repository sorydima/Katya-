// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthStore _$AuthStoreFromJson(Map<String, dynamic> json) => AuthStore(
      user: json['user'] == null
          ? const User()
          : User.fromJson(json['user'] as Map<String, dynamic>),
      availableUsers: (json['availableUsers'] as List<dynamic>?)
              ?.map((e) => User.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      authSession: json['authSession'] as String?,
      verified: json['verified'] as bool? ?? false,
      clientSecret: json['clientSecret'] as String?,
      protocol: json['protocol'] as String? ?? Values.DEFAULT_PROTOCOL,
    );

Map<String, dynamic> _$AuthStoreToJson(AuthStore instance) => <String, dynamic>{
      'user': instance.user,
      'authSession': instance.authSession,
      'clientSecret': instance.clientSecret,
      'protocol': instance.protocol,
      'availableUsers': instance.availableUsers,
      'verified': instance.verified,
    };
