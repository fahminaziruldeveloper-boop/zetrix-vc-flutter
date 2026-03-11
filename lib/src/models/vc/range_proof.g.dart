// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'range_proof.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RangeProof _$RangeProofFromJson(Map<String, dynamic> json) => RangeProof(
  type: json['type'] as String?,
  proof: json['proof'] as String,
  bits: (json['bits'] as num).toInt(),
  domain: json['domain'] as String,
  commitments: (json['commitments'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$RangeProofToJson(RangeProof instance) =>
    <String, dynamic>{
      if (instance.type != null) 'type': instance.type,
      'proof': instance.proof,
      'bits': instance.bits,
      'domain': instance.domain,
      'commitments': instance.commitments,
    };
