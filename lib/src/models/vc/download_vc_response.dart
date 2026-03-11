import 'package:zetrix_vc_flutter/src/models/vc/verifiable_credential.dart';
import 'package:json_annotation/json_annotation.dart';
part 'download_vc_response.g.dart';

@JsonSerializable(explicitToJson: true)
/// Represents the response received after downloading a Verifiable Credential (VC).
/// 
/// This class contains the data and metadata related to the downloaded VC,
/// such as its content, status, and any additional information provided by the API.
class DownloadVcResponse {
  /// The verifiable credential associated with this response.
  /// 
  /// This object contains the credential data that has been issued and can be
  /// used for verification purposes.
  final VerifiableCredential vc;
  /// A list of verifiable credential passes encoded in Base64 format.
  final List<String> vcPassBase64;
  /// The date and time when the download link or resource will expire.
  final DateTime downloadExpiryDate;

  /// Creates a new instance of [DownloadVcResponse].
  ///
  /// The constructor is used to initialize the properties of the response
  /// received after downloading a Verifiable Credential (VC).
  ///
  /// Add parameter descriptions here if available.
  DownloadVcResponse({
    required this.vc,
    required this.vcPassBase64,
    required this.downloadExpiryDate,
  });

  /// Creates a new instance of [DownloadVcResponse] from a JSON map.
  ///
  /// Parses the provided [json] map and returns a [DownloadVcResponse] object.
  /// Typically used for deserializing API responses.
  factory DownloadVcResponse.fromJson(Map<String, dynamic> json) =>
      _$DownloadVcResponseFromJson(json);

  /// Converts this [DownloadVcResponse] instance into a JSON map.
  /// 
  /// Returns a [Map] representation of the current object, suitable for
  /// serialization or network transmission.
  Map<String, dynamic> toJson() => _$DownloadVcResponseToJson(this);
}