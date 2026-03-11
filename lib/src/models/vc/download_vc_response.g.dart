// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_vc_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DownloadVcResponse _$DownloadVcResponseFromJson(Map<String, dynamic> json) =>
    DownloadVcResponse(
      vc: VerifiableCredential.fromJson(json['vc'] as Map<String, dynamic>),
      vcPassBase64: (json['vcPassBase64'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      downloadExpiryDate: DateTime.parse(json['downloadExpiryDate'] as String),
    );

Map<String, dynamic> _$DownloadVcResponseToJson(DownloadVcResponse instance) =>
    <String, dynamic>{
      'vc': instance.vc.toJson(),
      'vcPassBase64': instance.vcPassBase64,
      'downloadExpiryDate': instance.downloadExpiryDate.toIso8601String(),
    };
