import 'package:json_annotation/json_annotation.dart';

part 'zid_resolver_response.g.dart';

@JsonSerializable(explicitToJson: true)
class ZidResolverResponse {
  @JsonKey(name: 'didDocument')
  final Map<String, dynamic>? didDocument;

  ZidResolverResponse({
    this.didDocument,
  });

  factory ZidResolverResponse.fromJson(Map<String, dynamic> json) =>
      _$ZidResolverResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ZidResolverResponseToJson(this);
}
