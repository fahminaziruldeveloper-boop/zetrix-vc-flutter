// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'field.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Field _$FieldFromJson(Map<String, dynamic> json) => Field(
      path: (json['path'] as List<dynamic>).map((e) => e as String).toList(),
      purpose: json['purpose'] as String,
      filter: json['filter'],
    );

Map<String, dynamic> _$FieldToJson(Field instance) => <String, dynamic>{
      'path': instance.path,
      'purpose': instance.purpose,
      'filter': instance.filter,
    };
