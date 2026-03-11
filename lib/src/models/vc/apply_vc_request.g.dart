// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apply_vc_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApplyVcRequest _$ApplyVcRequestFromJson(Map<String, dynamic> json) =>
    ApplyVcRequest(
      data: (json['data'] as List<dynamic>)
          .map((e) => ApplyVcItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      signData: json['signData'] as String,
      publicKey: json['publicKey'] as String,
      x25519PublicKey: json['x25519PublicKey'] as String?,
    );

Map<String, dynamic> _$ApplyVcRequestToJson(ApplyVcRequest instance) =>
    <String, dynamic>{
      'data': instance.data.map((e) => e.toJson()).toList(),
      'signData': instance.signData,
      'publicKey': instance.publicKey,
      'x25519PublicKey': instance.x25519PublicKey,
    };

ApplyVcItem _$ApplyVcItemFromJson(Map<String, dynamic> json) => ApplyVcItem(
      templateId: json['templateId'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
      tds: json['tds'] as String,
    );

Map<String, dynamic> _$ApplyVcItemToJson(ApplyVcItem instance) =>
    <String, dynamic>{
      'templateId': instance.templateId,
      'metadata': instance.metadata,
      'tds': instance.tds,
    };
