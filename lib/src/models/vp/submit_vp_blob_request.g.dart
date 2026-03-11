// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submit_vp_blob_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubmitVpRequest _$SubmitVpRequestFromJson(Map<String, dynamic> json) =>
    SubmitVpRequest(
      blobId: json['blobId'] as String,
      ed25519SignData: json['ed25519SignData'] as String,
      ed25519PubKey: json['ed25519PubKey'] as String,
    );

Map<String, dynamic> _$SubmitVpRequestToJson(SubmitVpRequest instance) =>
    <String, dynamic>{
      'blobId': instance.blobId,
      'ed25519SignData': instance.ed25519SignData,
      'ed25519PubKey': instance.ed25519PubKey,
    };
