// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_delivery_change.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LiveDeliveryChange _$LiveDeliveryChangeFromJson(Map<String, dynamic> json) =>
    LiveDeliveryChange(
      id: json['id'] as String,
      typ: json['typ'] as String,
      type: json['type'] as String,
      from: json['from'] as String,
      to: (json['to'] as List<dynamic>).map((e) => e as String).toList(),
      createdTime: (json['createdTime'] as num).toInt(),
      body:
          LiveDeliveryChangeBody.fromJson(json['body'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LiveDeliveryChangeToJson(LiveDeliveryChange instance) =>
    <String, dynamic>{
      'id': instance.id,
      'typ': instance.typ,
      'type': instance.type,
      'from': instance.from,
      'to': instance.to,
      'createdTime': instance.createdTime,
      'body': instance.body.toJson(),
    };

LiveDeliveryChangeBody _$LiveDeliveryChangeBodyFromJson(
        Map<String, dynamic> json) =>
    LiveDeliveryChangeBody(
      liveDelivery: json['live_delivery'] as bool,
    );

Map<String, dynamic> _$LiveDeliveryChangeBodyToJson(
        LiveDeliveryChangeBody instance) =>
    <String, dynamic>{
      'live_delivery': instance.liveDelivery,
    };
