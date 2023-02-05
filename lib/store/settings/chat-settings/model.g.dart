// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatSetting _$ChatSettingFromJson(Map<String, dynamic> json) => ChatSetting(
      roomId: json['roomId'] as String,
      language: json['language'] as String? ?? 'English',
      smsEnabled: json['smsEnabled'] as bool? ?? false,
      primaryColor: json['primaryColor'] as int? ?? AppColors.greyDefault,
      notificationOptions: json['notificationOptions'] == null
          ? null
          : NotificationOptions.fromJson(
              json['notificationOptions'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ChatSettingToJson(ChatSetting instance) =>
    <String, dynamic>{
      'roomId': instance.roomId,
      'primaryColor': instance.primaryColor,
      'smsEnabled': instance.smsEnabled,
      'language': instance.language,
      'notificationOptions': instance.notificationOptions,
    };
