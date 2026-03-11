import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:zetrix_vc_flutter/src/utils/key_exchange_util.dart';
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';

/// Service class for handling Zetrix VC (Verifiable Credential) operations.
///
/// This service provides methods for:
/// - Applying for a Verifiable Credential (VC)
/// - Downloading a Verifiable Credential (VC)
///
/// It configures the [Dio] client with the appropriate base URL based on
/// whether you are using mainnet or testnet.
class ZetrixVcEncryptedService {
  final Dio _dio;

  /// Indicates whether the service is connected to the mainnet.
  ///
  /// If `true`, the service operates on the mainnet; if `false`, it operates on a testnet or other network.
  final bool isMainnet;

  /// An instance of [EncryptionUtils] used to perform encryption and decryption operations
  /// within the service.
  final EncryptionUtils encryption = EncryptionUtils();

  /// Creates an instance of [ZetrixVcEncryptedService].
  ///
  /// Takes a [Dio] HTTP client and a boolean [isMainnet] to determine
  /// if the service should operate on the mainnet or testnet.
  ///
  /// - [dio]: The Dio HTTP client used for making network requests.
  /// - [isMainnet]: A flag indicating whether to use the mainnet (true) or testnet (false).
  ZetrixVcEncryptedService(this._dio, this.isMainnet) {
    _dio.options.baseUrl = ConfigReader.getBaseUrl(isMainnet);
  }

  /// Applies for a Verifiable Credential (VC) and returns the result.
  ///
  /// This method initiates the process of applying for a VC and returns a [ZetrixSDKResult]
  /// containing an [ApplyVcResponse] upon success. The implementation details, such as
  /// required parameters and error handling, should be provided in the method body.
  ///
  /// Returns a [Future] that completes with the result of the VC application process.
  Future<ZetrixSDKResult<ApplyVcResponse>> postApplyVc(
      String payload, String secretKey, String x25519PubKey) async {
    try {
      final response = await _dio.post(
        '/cred/v1/vc/enc/apply',
        data: payload,
        options: Options(headers: {
          'secretKey': secretKey,
          'x25519PubKey': x25519PubKey,
        }),
      );
      final parsed = StandardApiResponse<ApplyVcResponse>.fromJson(
        response.data,
        (json) => ApplyVcResponse.fromJson(json as Map<String, dynamic>),
      );
      if (parsed.object != null) {
        return ZetrixSDKResult.success(data: parsed.object!);
      }
      final msg = parsed.messages?.first.message ?? 'Failed to apply VC';
      return ZetrixSDKResult.failure(error: DefaultError(msg));
    } on DioException catch (e) {
      final msg = e.response?.data?["messages"]?[0]?["message"];
      return ZetrixSDKResult.failure(
        error: DefaultError(msg ?? 'Apply VC error'),
      );
    }
  }

  /// Applies for a Verifiable Credential (VC) with encryption.
  ///
  /// Returns a [ZetrixSDKResult] containing the [ApplyVcResponse] if the operation is successful.
  /// Handles the process of requesting and encrypting a VC.
  ///
  /// Throws an exception if the application fails.
  Future<ZetrixSDKResult<ApplyVcResponse>> applyVcEnc(ApplyVcRequest reqDto,
      String holderPrivateKey, String issuerPublicKey) async {
    try {
      final keyMaterial = await KeyExchangeUtils.deriveSharedKey(
        privateKeyBase58: holderPrivateKey,
        recipientPubKeyBase58: issuerPublicKey,
      );
      reqDto.x25519PublicKey = keyMaterial.senderPubKeyBase58;

      final secretKey = keyMaterial.secretKey;
      final encryptedSecret = RsaUtil.encrypt(
        RsaUtil.loadPublicKey(ConfigReader.getRSAPublicKey(isMainnet)),
        Uint8List.fromList(await secretKey.extractBytes()),
      );

      final payload = base64Url.encode(await AesGcmUtil.encrypt(
        plaintext: utf8.encode(jsonEncode(reqDto.toJson())),
        secretKey: secretKey,
      ));

      final x25519PubKey = keyMaterial.senderPubKeyBase58;

      return postApplyVc(
          payload, base64Url.encode(encryptedSecret), x25519PubKey);
    } on DioException catch (e) {
      final msg = e.response?.data?["messages"]?[0]?["message"];
      return ZetrixSDKResult.failure(
        error: DefaultError(msg ?? 'Apply VC error'),
      );
    }
  }

  /// Downloads a Verifiable Credential (VC) using the provided payload and secret key.
  ///
  /// This method sends a request to download a VC, decrypting it with the given [secretKey].
  ///
  /// Returns a [ZetrixSDKResult] containing the downloaded VC as a [String] if successful,
  /// or an error message if the operation fails.
  ///
  /// [payload]: The request payload required to identify and download the VC.
  /// [secretKey]: The secret key used to decrypt the downloaded VC.
  ///
  /// Throws an exception if the download or decryption process fails.
  Future<ZetrixSDKResult<String>> postDownloadVc(
      String payload, String secretKey, String x25519PubKey) async {
    try {
      final response = await _dio.post(
        '/cred/v1/vc/enc/download',
        data: payload,
        options: Options(headers: {
          'secretKey': secretKey,
          'x25519PubKey': x25519PubKey,
        }),
      );
      final parsed = StandardApiResponse<String>.fromJson(
        response.data,
        (json) => json as String,
      );
      if (parsed.object != null) {
        return ZetrixSDKResult.success(data: parsed.object);
      }
      final msg = parsed.messages?.first.message ?? 'Failed to download VC';
      return ZetrixSDKResult.failure(error: DefaultError(msg));
    } on DioException catch (e) {
      final msg = e.response?.data?["messages"]?[0]?["message"];
      return ZetrixSDKResult.failure(
        error: DefaultError(msg ?? 'Download VC error'),
      );
    }
  }

  /// Downloads an encrypted Verifiable Credential (VC) from the server.
  ///
  /// Returns a [Future] that completes with a [ZetrixSDKResult] containing the
  /// downloaded [VerifiableCredential] if successful, or an error if the operation fails.
  ///
  /// Throws an exception if the download process encounters an unrecoverable error.
  Future<ZetrixSDKResult<DownloadVcResponse>> downloadVcEnc(
      DownloadVcRequest request,
      String holderPrivateKey,
      String issuerPublicKey) async {
    try {
      final keyMaterial = await KeyExchangeUtils.deriveSharedKey(
        privateKeyBase58: holderPrivateKey,
        recipientPubKeyBase58: issuerPublicKey,
      );

      final payload = base64Url.encode(await AesGcmUtil.encrypt(
        plaintext: utf8.encode(jsonEncode(request.toJson())),
        secretKey: keyMaterial.secretKey,
      ));

      final encryptedSecret = RsaUtil.encrypt(
        RsaUtil.loadPublicKey(ConfigReader.getRSAPublicKey(isMainnet)),
        Uint8List.fromList(await keyMaterial.secretKey.extractBytes()),
      );

      final x25519PubKey = keyMaterial.senderPubKeyBase58;

      final response = await postDownloadVc(
          payload, base64Url.encode(encryptedSecret), x25519PubKey);

      if (response is Success<String>) {
        final decryptedBytes = await AesGcmUtil.decrypt(
          ivCiphertextMac: base64Url.decode(response.data!),
          secretKey: keyMaterial.secretKey,
        );
        final downloadResponse = DownloadVcResponse.fromJson(
          jsonDecode(utf8.decode(decryptedBytes)) as Map<String, dynamic>,
        );
        return ZetrixSDKResult.success(data: downloadResponse);
      } else if (response is Failure<String>) {
        return ZetrixSDKResult.failure(error: response.error);
      }
    } on DioException catch (e) {
      final msg = e.response?.data?["messages"]?[0]?["message"];
      return ZetrixSDKResult.failure(
        error: DefaultError(msg ?? 'Download VC error'),
      );
    }
    return ZetrixSDKResult.failure(
      error: DefaultError('Unexpected error occurred in downloadVcEnc'),
    );
  }
}
