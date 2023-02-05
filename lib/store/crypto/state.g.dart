// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CryptoStore _$CryptoStoreFromJson(Map<String, dynamic> json) => CryptoStore(
      olmAccountKey: json['olmAccountKey'] as String?,
      deviceKeysExist: json['deviceKeysExist'] as bool? ?? false,
      deviceKeyVerified: json['deviceKeyVerified'] as bool? ?? false,
      oneTimeKeysStable: json['oneTimeKeysStable'] as bool? ?? true,
      outboundMessageSessions:
          (json['outboundMessageSessions'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, e as String),
              ) ??
              const {},
      keySessions: (json['keySessions'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, Map<String, String>.from(e as Map)),
          ) ??
          const {},
      deviceKeys: (json['deviceKeys'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
                k,
                (e as Map<String, dynamic>).map(
                  (k, e) => MapEntry(
                      k, DeviceKey.fromJson(e as Map<String, dynamic>)),
                )),
          ) ??
          const {},
      deviceKeysOwned: (json['deviceKeysOwned'] as Map<String, dynamic>?)?.map(
            (k, e) =>
                MapEntry(k, DeviceKey.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
      oneTimeKeysClaimed:
          (json['oneTimeKeysClaimed'] as Map<String, dynamic>?)?.map(
                (k, e) =>
                    MapEntry(k, OneTimeKey.fromJson(e as Map<String, dynamic>)),
              ) ??
              const {},
      oneTimeKeysCounts:
          (json['oneTimeKeysCounts'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, e as int),
              ) ??
              const {},
    );

Map<String, dynamic> _$CryptoStoreToJson(CryptoStore instance) =>
    <String, dynamic>{
      'olmAccountKey': instance.olmAccountKey,
      'deviceKeysExist': instance.deviceKeysExist,
      'deviceKeyVerified': instance.deviceKeyVerified,
      'oneTimeKeysStable': instance.oneTimeKeysStable,
      'keySessions': instance.keySessions,
      'outboundMessageSessions': instance.outboundMessageSessions,
      'deviceKeys': instance.deviceKeys,
      'deviceKeysOwned': instance.deviceKeysOwned,
      'oneTimeKeysCounts': instance.oneTimeKeysCounts,
      'oneTimeKeysClaimed': instance.oneTimeKeysClaimed,
    };
