// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Receipt _$ReceiptFromJson(Map<String, dynamic> json) => Receipt(
      eventId: json['eventId'] as String? ?? '',
      latestRead: json['latestRead'] as int? ?? 0,
      userReadsMapped:
          json['userReadsMapped'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$ReceiptToJson(Receipt instance) => <String, dynamic>{
      'eventId': instance.eventId,
      'latestRead': instance.latestRead,
      'userReadsMapped': instance.userReadsMapped,
    };
