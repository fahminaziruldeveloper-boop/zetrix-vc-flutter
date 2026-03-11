// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'disclose.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Disclose _$DiscloseFromJson(Map<String, dynamic> json) => Disclose(
      id: json['id'] as String,
      typ: json['typ'] as String,
      type: json['type'] as String,
      from: json['from'] as String,
      body: DiscloseBody.fromJson(json['body'] as Map<String, dynamic>),
      to: (json['to'] as List<dynamic>).map((e) => e as String).toList(),
      thid: json['thid'] as String,
      createdTime: (json['created_time'] as num).toInt(),
    );

Map<String, dynamic> _$DiscloseToJson(Disclose instance) => <String, dynamic>{
      'id': instance.id,
      'typ': instance.typ,
      'type': instance.type,
      'from': instance.from,
      'body': instance.body.toJson(),
      'to': instance.to,
      'thid': instance.thid,
      'created_time': instance.createdTime,
    };

DiscloseBody _$DiscloseBodyFromJson(Map<String, dynamic> json) => DiscloseBody(
      disclosures: (json['disclosures'] as List<dynamic>)
          .map((e) => DisclosureItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DiscloseBodyToJson(DiscloseBody instance) =>
    <String, dynamic>{
      'disclosures': instance.disclosures,
    };

DisclosureItem _$DisclosureItemFromJson(Map<String, dynamic> json) =>
    DisclosureItem(
      featureType: json['feature-type'] as String,
      id: json['id'] as String,
    );

Map<String, dynamic> _$DisclosureItemToJson(DisclosureItem instance) =>
    <String, dynamic>{
      'feature-type': instance.featureType,
      'id': instance.id,
    };
