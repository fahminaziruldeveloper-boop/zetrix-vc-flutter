// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_vc_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DownloadVcRequest _$DownloadVcRequestFromJson(Map<String, dynamic> json) =>
    DownloadVcRequest(
      vcId: json['vcId'] as String,
      isIssuer: json['isIssuer'] as bool,
      signVcId: json['signVcId'] as String,
    );

Map<String, dynamic> _$DownloadVcRequestToJson(DownloadVcRequest instance) =>
    <String, dynamic>{
      'vcId': instance.vcId,
      'isIssuer': instance.isIssuer,
      'signVcId': instance.signVcId,
    };
