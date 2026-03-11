// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'problem_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProblemReport _$ProblemReportFromJson(Map<String, dynamic> json) =>
    ProblemReport(
      id: json['id'] as String,
      type: json['type'] as String,
      pthid: json['pthid'] as String,
      body: ProblemReportBody.fromJson(json['body'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProblemReportToJson(ProblemReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'pthid': instance.pthid,
      'body': instance.body.toJson(),
    };

ProblemReportBody _$ProblemReportBodyFromJson(Map<String, dynamic> json) =>
    ProblemReportBody(
      code: json['code'] as String,
      comment: json['comment'] as String,
    );

Map<String, dynamic> _$ProblemReportBodyToJson(ProblemReportBody instance) =>
    <String, dynamic>{
      'code': instance.code,
      'comment': instance.comment,
    };
