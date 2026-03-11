// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verifiable_presentation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************


VerifiablePresentation _$VerifiablePresentationFromJson(
    Map<String, dynamic> json) =>
  VerifiablePresentation(
    context: (json['@context'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
    type: (json['type'] as List<dynamic>?)?.map((e) => e as String).toList(),
    holder: json['holder'] as String?,
    verifiableCredential: (json['verifiableCredential'] as List<dynamic>?)
      ?.map((e) => VerifiableCredential.fromJson(e as Map<String, dynamic>))
      .toList(),
    proof: json['proof'] == null
      ? null
      : Proof.fromJson(json['proof'] as Map<String, dynamic>),
    rangeProof: json['rangeProof'] == null
      ? null
      : RangeProof.fromJson(json['rangeProof'] as Map<String, dynamic>),
  );

Map<String, dynamic> _$VerifiablePresentationToJson(
        VerifiablePresentation instance) =>
    <String, dynamic>{
      if (instance.context case final value?) '@context': value,
      if (instance.type case final value?) 'type': value,
      if (instance.holder case final value?) 'holder': value,
      if (instance.verifiableCredential?.map((e) => e.toJson()).toList()
          case final value?)
        'verifiableCredential': value,
      if (instance.proof?.toJson() case final value?) 'proof': value,
      if (instance.rangeProof?.toJson() case final value?) 'rangeProof': value,
    };
