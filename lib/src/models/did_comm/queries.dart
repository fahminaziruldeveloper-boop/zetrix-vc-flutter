import 'package:json_annotation/json_annotation.dart';

part 'queries.g.dart';

@JsonSerializable(explicitToJson: true)
class Queries {
  final String id;
  final String typ;
  final String type;
  final String from;
  final QueriesBody body;
  final List<String> to;
  @JsonKey(name: 'created_time')
  final int createdTime;

  Queries({
    required this.id,
    required this.typ,
    required this.type,
    required this.from,
    required this.body,
    required this.to,
    required this.createdTime,
  });


  factory Queries.fromJson(Map<String, dynamic> json) =>
      _$QueriesFromJson(json);

  Map<String, dynamic> toJson() => _$QueriesToJson(this);
}

@JsonSerializable(explicitToJson: true)
class QueriesBody {
  final List<QueryItem> queries;

  QueriesBody({required this.queries});

  factory QueriesBody.fromJson(Map<String, dynamic> json) =>
      _$QueriesBodyFromJson(json);

  Map<String, dynamic> toJson() => _$QueriesBodyToJson(this);
}

@JsonSerializable(explicitToJson: true)
class QueryItem {
  @JsonKey(name: 'feature-type')
  final String featureType;
  final String match;

  QueryItem({
    required this.featureType,
    required this.match,
  });

  factory QueryItem.fromJson(Map<String, dynamic> json) =>
      _$QueryItemFromJson(json);

  Map<String, dynamic> toJson() => _$QueryItemToJson(this);
}
