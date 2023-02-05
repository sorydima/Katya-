// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationSettings _$NotificationSettingsFromJson(
        Map<String, dynamic> json) =>
    NotificationSettings(
      enabled: json['enabled'] as bool? ?? false,
      rules: (json['rules'] as List<dynamic>?)
              ?.map((e) => Rule.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Rule>[],
      pushers: (json['pushers'] as List<dynamic>?)
              ?.map((e) => Pusher.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Pusher>[],
      toggleType:
          $enumDecodeNullable(_$ToggleTypeEnumMap, json['toggleType']) ??
              ToggleType.Enabled,
      styleType: $enumDecodeNullable(_$StyleTypeEnumMap, json['styleType']) ??
          StyleType.Itemized,
      notificationOptions:
          (json['notificationOptions'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(
                    k, NotificationOptions.fromJson(e as Map<String, dynamic>)),
              ) ??
              const {},
    );

Map<String, dynamic> _$NotificationSettingsToJson(
        NotificationSettings instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'styleType': _$StyleTypeEnumMap[instance.styleType]!,
      'toggleType': _$ToggleTypeEnumMap[instance.toggleType]!,
      'notificationOptions': instance.notificationOptions,
      'rules': instance.rules,
      'pushers': instance.pushers,
    };

const _$ToggleTypeEnumMap = {
  ToggleType.Enabled: 'Enabled',
  ToggleType.Disabled: 'Disabled',
};

const _$StyleTypeEnumMap = {
  StyleType.Itemized: 'Itemized',
  StyleType.Latest: 'Latest',
  StyleType.Inbox: 'Inbox',
};
