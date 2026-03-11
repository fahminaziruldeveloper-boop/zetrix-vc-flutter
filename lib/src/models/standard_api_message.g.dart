// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'standard_api_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StandardApiMessage _$StandardApiMessageFromJson(Map<String, dynamic> json) =>
    StandardApiMessage(
      type: json['type'] as String,
      errorCode: (json['errorCode'] as num).toInt(),
      message: json['message'] as String,
    );

Map<String, dynamic> _$StandardApiMessageToJson(StandardApiMessage instance) =>
    <String, dynamic>{
      'type': instance.type,
      'errorCode': instance.errorCode,
      'message': instance.message,
    };
