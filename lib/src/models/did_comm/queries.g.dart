// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queries.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Queries _$QueriesFromJson(Map<String, dynamic> json) => Queries(
      id: json['id'] as String,
      typ: json['typ'] as String,
      type: json['type'] as String,
      from: json['from'] as String,
      body: QueriesBody.fromJson(json['body'] as Map<String, dynamic>),
      to: (json['to'] as List<dynamic>).map((e) => e as String).toList(),
      createdTime: (json['created_time'] as num).toInt(),
    );

Map<String, dynamic> _$QueriesToJson(Queries instance) => <String, dynamic>{
      'id': instance.id,
      'typ': instance.typ,
      'type': instance.type,
      'from': instance.from,
      'body': instance.body.toJson(),
      'to': instance.to,
      'created_time': instance.createdTime,
    };

QueriesBody _$QueriesBodyFromJson(Map<String, dynamic> json) => QueriesBody(
      queries: (json['queries'] as List<dynamic>)
          .map((e) => QueryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$QueriesBodyToJson(QueriesBody instance) =>
    <String, dynamic>{
      'queries': instance.queries.map((e) => e.toJson()).toList(),
    };

QueryItem _$QueryItemFromJson(Map<String, dynamic> json) => QueryItem(
      featureType: json['feature-type'] as String,
      match: json['match'] as String,
    );

Map<String, dynamic> _$QueryItemToJson(QueryItem instance) => <String, dynamic>{
      'feature-type': instance.featureType,
      'match': instance.match,
    };
