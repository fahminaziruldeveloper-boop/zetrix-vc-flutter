// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proof.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Proof _$ProofFromJson(Map<String, dynamic> json) => Proof(
      type: json['type'] as String?,
      created: json['created'] as String?,
      proofPurpose: json['proofPurpose'] as String?,
      proofValue: json['proofValue'] as String?,
      verificationMethod: json['verificationMethod'] as String?,
      jws: json['jws'] as String?,
      nonce: json['nonce'] as String?,
    );

Map<String, dynamic> _$ProofToJson(Proof instance) => <String, dynamic>{
      'type': instance.type,
      'created': instance.created,
      'proofPurpose': instance.proofPurpose,
      if (instance.proofValue case final value?) 'proofValue': value,
      'verificationMethod': instance.verificationMethod,
      if (instance.jws case final value?) 'jws': value,
      if (instance.nonce case final value?) 'nonce': value,
    };
