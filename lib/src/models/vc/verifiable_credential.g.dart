// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verifiable_credential.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifiableCredential _$VerifiableCredentialFromJson(
        Map<String, dynamic> json) =>
    VerifiableCredential(
      context: (json['@context'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      id: json['id'] as String?,
      type: (json['type'] as List<dynamic>?)?.map((e) => e as String).toList(),
      issuer: json['issuer'] as String?,
      validFrom: json['validFrom'] as String?,
      validUntil: json['validUntil'] as String?,
      credentialSubject: json['credentialSubject'] as Map<String, dynamic>?,
      proof: (json['proof'] as List<dynamic>?)
          ?.map((e) => Proof.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$VerifiableCredentialToJson(
        VerifiableCredential instance) =>
    <String, dynamic>{
      if (instance.context case final value?) '@context': value,
      if (instance.id case final value?) 'id': value,
      if (instance.type case final value?) 'type': value,
      if (instance.issuer case final value?) 'issuer': value,
      if (instance.validFrom case final value?) 'validFrom': value,
      if (instance.validUntil case final value?) 'validUntil': value,
      if (instance.credentialSubject case final value?)
        'credentialSubject': value,
      if (instance.proof?.map((e) => e.toJson()).toList() case final value?)
        'proof': value,
    };
