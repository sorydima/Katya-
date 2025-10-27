// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messenger_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessengerUser _$MessengerUserFromJson(Map<String, dynamic> json) =>
    MessengerUser(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      fullName: json['fullName'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      status: $enumDecodeNullable(_$UserStatusEnumMap, json['status']) ??
          UserStatus.offline,
      lastSeen: json['lastSeen'] == null
          ? null
          : DateTime.parse(json['lastSeen'] as String),
      statusMessage: json['statusMessage'] as String?,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      website: json['website'] as String?,
      birthDate: json['birthDate'] == null
          ? null
          : DateTime.parse(json['birthDate'] as String),
      gender: $enumDecodeNullable(_$GenderEnumMap, json['gender']),
      language: json['language'] as String?,
      timezone: json['timezone'] as String?,
      isBot: json['isBot'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
      isPremium: json['isPremium'] as bool? ?? false,
      privacySettings: json['privacySettings'] == null
          ? const PrivacySettings()
          : PrivacySettings.fromJson(
              json['privacySettings'] as Map<String, dynamic>),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$MessengerUserToJson(MessengerUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'displayName': instance.displayName,
      'fullName': instance.fullName,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'avatarUrl': instance.avatarUrl,
      'status': _$UserStatusEnumMap[instance.status]!,
      'lastSeen': instance.lastSeen?.toIso8601String(),
      'statusMessage': instance.statusMessage,
      'bio': instance.bio,
      'location': instance.location,
      'website': instance.website,
      'birthDate': instance.birthDate?.toIso8601String(),
      'gender': _$GenderEnumMap[instance.gender],
      'language': instance.language,
      'timezone': instance.timezone,
      'isBot': instance.isBot,
      'isVerified': instance.isVerified,
      'isPremium': instance.isPremium,
      'privacySettings': instance.privacySettings,
      'metadata': instance.metadata,
    };

const _$UserStatusEnumMap = {
  UserStatus.online: 'online',
  UserStatus.away: 'away',
  UserStatus.busy: 'busy',
  UserStatus.invisible: 'invisible',
  UserStatus.offline: 'offline',
};

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
  Gender.other: 'other',
  Gender.preferNotToSay: 'prefer_not_to_say',
};

PrivacySettings _$PrivacySettingsFromJson(Map<String, dynamic> json) =>
    PrivacySettings(
      allowMessages: json['allowMessages'] as bool? ?? true,
      allowMessagesFromStrangers:
          json['allowMessagesFromStrangers'] as bool? ?? false,
      showStatus: json['showStatus'] as bool? ?? true,
      showLastSeen: json['showLastSeen'] as bool? ?? true,
      showStatusMessage: json['showStatusMessage'] as bool? ?? true,
      showAvatar: json['showAvatar'] as bool? ?? true,
      showPhoneNumber: json['showPhoneNumber'] as bool? ?? false,
      showEmail: json['showEmail'] as bool? ?? false,
      showLocation: json['showLocation'] as bool? ?? false,
      showWebsite: json['showWebsite'] as bool? ?? true,
      allowGroupInvites: json['allowGroupInvites'] as bool? ?? true,
      allowCalls: json['allowCalls'] as bool? ?? true,
      allowVideoCalls: json['allowVideoCalls'] as bool? ?? true,
      allowMessageForwarding: json['allowMessageForwarding'] as bool? ?? true,
      allowMessageSaving: json['allowMessageSaving'] as bool? ?? true,
    );

Map<String, dynamic> _$PrivacySettingsToJson(PrivacySettings instance) =>
    <String, dynamic>{
      'allowMessages': instance.allowMessages,
      'allowMessagesFromStrangers': instance.allowMessagesFromStrangers,
      'showStatus': instance.showStatus,
      'showLastSeen': instance.showLastSeen,
      'showStatusMessage': instance.showStatusMessage,
      'showAvatar': instance.showAvatar,
      'showPhoneNumber': instance.showPhoneNumber,
      'showEmail': instance.showEmail,
      'showLocation': instance.showLocation,
      'showWebsite': instance.showWebsite,
      'allowGroupInvites': instance.allowGroupInvites,
      'allowCalls': instance.allowCalls,
      'allowVideoCalls': instance.allowVideoCalls,
      'allowMessageForwarding': instance.allowMessageForwarding,
      'allowMessageSaving': instance.allowMessageSaving,
    };
