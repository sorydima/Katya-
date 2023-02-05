// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettingsStore _$SettingsStoreFromJson(Map<String, dynamic> json) =>
    SettingsStore(
      language: json['language'] as String? ?? '',
      syncInterval: json['syncInterval'] as int? ?? 2000,
      syncPollTimeout: json['syncPollTimeout'] as int? ?? 10000,
      chatLists: (json['chatLists'] as List<dynamic>?)
              ?.map((e) => ChatList.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      globalSortOrder:
          $enumDecodeNullable(_$SortOrderEnumMap, json['globalSortOrder']) ??
              SortOrder.Latest,
      enterSendEnabled: json['enterSendEnabled'] as bool? ?? false,
      autocorrectEnabled: json['autocorrectEnabled'] as bool? ?? false,
      suggestionsEnabled: json['suggestionsEnabled'] as bool? ?? false,
      smsEnabled: json['smsEnabled'] as bool? ?? false,
      typingIndicatorsEnabled:
          json['typingIndicatorsEnabled'] as bool? ?? false,
      membershipEventsEnabled: json['membershipEventsEnabled'] as bool? ?? true,
      roomTypeBadgesEnabled: json['roomTypeBadgesEnabled'] as bool? ?? true,
      timeFormat24Enabled: json['timeFormat24Enabled'] as bool? ?? false,
      dismissKeyboardEnabled: json['dismissKeyboardEnabled'] as bool? ?? false,
      autoDownloadEnabled: json['autoDownloadEnabled'] as bool? ?? false,
      chatSettings: (json['chatSettings'] as Map<String, dynamic>?)?.map(
            (k, e) =>
                MapEntry(k, ChatSetting.fromJson(e as Map<String, dynamic>)),
          ) ??
          const <String, ChatSetting>{},
      devices: (json['devices'] as List<dynamic>?)
              ?.map((e) => Device.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      alphaAgreement: json['alphaAgreement'] as String?,
      readReceipts: $enumDecodeNullable(
              _$ReadReceiptTypesEnumMap, json['readReceipts']) ??
          ReadReceiptTypes.Off,
      themeSettings: json['themeSettings'] == null
          ? const ThemeSettings()
          : ThemeSettings.fromJson(
              json['themeSettings'] as Map<String, dynamic>),
      proxySettings: json['proxySettings'] == null
          ? const ProxySettings()
          : ProxySettings.fromJson(
              json['proxySettings'] as Map<String, dynamic>),
      privacySettings: json['privacySettings'] == null
          ? const PrivacySettings()
          : PrivacySettings.fromJson(
              json['privacySettings'] as Map<String, dynamic>),
      storageSettings: json['storageSettings'] == null
          ? const StorageSettings()
          : StorageSettings.fromJson(
              json['storageSettings'] as Map<String, dynamic>),
      notificationSettings: json['notificationSettings'] == null
          ? const NotificationSettings()
          : NotificationSettings.fromJson(
              json['notificationSettings'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SettingsStoreToJson(SettingsStore instance) =>
    <String, dynamic>{
      'language': instance.language,
      'alphaAgreement': instance.alphaAgreement,
      'smsEnabled': instance.smsEnabled,
      'enterSendEnabled': instance.enterSendEnabled,
      'autocorrectEnabled': instance.autocorrectEnabled,
      'suggestionsEnabled': instance.suggestionsEnabled,
      'typingIndicatorsEnabled': instance.typingIndicatorsEnabled,
      'membershipEventsEnabled': instance.membershipEventsEnabled,
      'roomTypeBadgesEnabled': instance.roomTypeBadgesEnabled,
      'timeFormat24Enabled': instance.timeFormat24Enabled,
      'dismissKeyboardEnabled': instance.dismissKeyboardEnabled,
      'autoDownloadEnabled': instance.autoDownloadEnabled,
      'syncInterval': instance.syncInterval,
      'syncPollTimeout': instance.syncPollTimeout,
      'globalSortOrder': _$SortOrderEnumMap[instance.globalSortOrder]!,
      'chatLists': instance.chatLists,
      'readReceipts': _$ReadReceiptTypesEnumMap[instance.readReceipts]!,
      'devices': instance.devices,
      'proxySettings': instance.proxySettings,
      'themeSettings': instance.themeSettings,
      'storageSettings': instance.storageSettings,
      'privacySettings': instance.privacySettings,
      'chatSettings': instance.chatSettings,
      'notificationSettings': instance.notificationSettings,
    };

const _$SortOrderEnumMap = {
  SortOrder.Custom: 'Custom',
  SortOrder.Latest: 'Latest',
  SortOrder.Oldest: 'Oldest',
  SortOrder.Alphabetical: 'Alphabetical',
};

const _$ReadReceiptTypesEnumMap = {
  ReadReceiptTypes.Off: 'Off',
  ReadReceiptTypes.Private: 'Private',
  ReadReceiptTypes.On: 'On',
};
