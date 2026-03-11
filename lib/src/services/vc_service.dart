import 'package:dio/dio.dart';
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';

/// Service class for handling Zetrix VC (Verifiable Credential) operations.
///
/// This service provides methods for:
/// - Applying for a Verifiable Credential (VC)
/// - Downloading a Verifiable Credential (VC)
///
/// It configures the [Dio] client with the appropriate base URL based on
/// whether you are using mainnet or testnet.
class ZetrixVcService {

  final Dio _dio;

  /// Flag indicating whether this service is configured for the mainnet.                                                                               
  final bool isMainnet;

  /// Creates an instance of [ZetrixVcService].
  ///
  /// - [dio] is the Dio client to be used.
  /// - [isMainnet] determines whether the service should use the mainnet or testnet base URL.
  ZetrixVcService(this._dio, this.isMainnet) {
    _dio.options.baseUrl = ConfigReader.getBaseUrl(isMainnet);
  }

  /// A utility for encryption-related tasks, used to encode VP to Base64.
  EncryptionUtils encryption = EncryptionUtils();

 /// Applies for a Verifiable Credential (VP) via the Zetrix API.
  ///
  /// This function sends a request to apply a Verifiable Credential (VC)
  /// using the provided [reqDto] data.
  ///
  /// Returns a [ZetrixSDKResult] containing either:
  /// - a successful [ApplyVcResponse] on success
  /// - an error [DefaultError] on failure
  ///
  Future<ZetrixSDKResult<ApplyVcResponse>> applyVc(
      ApplyVcRequest reqDto) async {
    try {
      final response = await _dio.post(
        '/cred/v1/vc/apply',
        data: reqDto.toJson(),
      );

      final parsed = StandardApiResponse<ApplyVcResponse>.fromJson(
        response.data,
        (json) => ApplyVcResponse.fromJson(json as Map<String, dynamic>),
      );

      if (parsed.object != null) {
        return ZetrixSDKResult.success(data: parsed.object!);
      } else {
        final msg = parsed.messages?.first.message ?? 'Failed to apply VC';
        return ZetrixSDKResult.failure(error: DefaultError(msg));
      }
    } on DioException catch (e) {
      String? msg;
      if (e.response?.statusCode == 400) {
        msg = e.response?.data?["messages"]?[0]?["message"];
      }
      return ZetrixSDKResult.failure(
        error: DefaultError(msg ?? 'Apply VC error'),
      );
    }
  }

  /// Downloads a Verifiable Credential (VC) from the Zetrix API.
  ///
  /// Sends a request to download the VC associated with the provided
  /// [request] object.
  ///
  /// Returns a [ZetrixSDKResult] containing either:
  /// - a successful [DownloadVcResponse] on success
  /// - an error [DefaultError] on failure
  Future<ZetrixSDKResult<DownloadVcResponse>> downloadVc(
    DownloadVcRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/cred/v1/vc/download',
        data: request.toJson(),
      );

      final parsed = StandardApiResponse<DownloadVcResponse>.fromJson(
        response.data,
        (json) => DownloadVcResponse.fromJson(json as Map<String, dynamic>),
      );

      if (parsed.object != null) {
        return ZetrixSDKResult.success(data: parsed.object!);
      } else {
        final msg = parsed.messages?.first.message ?? 'Failed to download VC';
        return ZetrixSDKResult.failure(error: DefaultError(msg));
      }
    } on DioException catch (e) {
      String? msg;
      if (e.response?.statusCode == 400) {
        msg = e.response?.data?["messages"]?[0]?["message"];
      }
      return ZetrixSDKResult.failure(
        error: DefaultError(msg ?? 'Download VC error'),
      );
    }
  }
}
