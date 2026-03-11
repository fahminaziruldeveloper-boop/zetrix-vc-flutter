// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_vp_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateVpRequest _$CreateVpRequestFromJson(Map<String, dynamic> json) =>
    CreateVpRequest(
      vc: VerifiableCredential.fromJson(json['vc'] as Map<String, dynamic>),
      revealAttribute: (json['revealAttribute'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$CreateVpRequestToJson(CreateVpRequest instance) =>
    <String, dynamic>{
      'vc': instance.vc.toJson(),
      'revealAttribute': instance.revealAttribute,
    };
