import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:zetrix_vc_flutter/src/models/standard_api_response.dart';
import 'package:zetrix_vc_flutter/src/utils/key_exchange_util.dart';
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';

/// Service class for handling Zetrix VP (Verifiable Presentation) operations.
///
/// This service provides methods for:
/// - Create Verifiable Presentation (VP) blob
/// - Submit Verifiable Presentation (VP) blob
///
/// It configures the [Dio] client with the appropriate base URL based on
/// whether you are using mainnet or testnet.
class ZetrixVpEncryptedService {
  final Dio _dio;

  /// Indicates whether the service is connected to the mainnet.
  ///
  /// If `true`, the service operates on the mainnet; if `false`, it operates on a testnet or other network.
  final bool isMainnet;

  /// An instance of [EncryptionUtils] used to perform encryption and decryption operations
  /// within the service.
  final EncryptionUtils encryption = EncryptionUtils();

  /// Creates an instance of [ZetrixVpEncryptedService].
  ///
  /// Takes a [Dio] HTTP client and a boolean [isMainnet] to determine
  /// if the service should operate on the mainnet or testnet.
  ///
  /// - [dio]: The Dio HTTP client used for making network requests.
  /// - [isMainnet]: A flag indicating whether to use the mainnet (true) or testnet (false).
  ZetrixVpEncryptedService(this._dio, this.isMainnet) {
    _dio.options.baseUrl = ConfigReader.getBaseUrl(isMainnet);
  }

  /// Create blob for a Verifiable Presentation (VP) and returns the result.
  ///
  /// This method initiates the process of create blob for a VP and returns a [ZetrixSDKResult]
  /// containing an [CreateVpResponse] upon success. The implementation details, such as
  /// required parameters and error handling, should be provided in the method body.
  ///
  /// Returns a [Future] that completes with the result of the VP blob creation process.
  Future<ZetrixSDKResult<CreateVpResponse>> postCreateVpBlob(
      String payload, String secretKey, String x25519PubKey) async {
    try {
      final response = await _dio.post(
        '/cred/v1/vp/enc/create',
        data: payload,
        options: Options(headers: {
          'secretKey': secretKey,
          'x25519PubKey': x25519PubKey,
        }),
      );

      final parsed = StandardApiResponse<CreateVpResponse>.fromJson(
        response.data,
        (json) => CreateVpResponse.fromJson(json as Map<String, dynamic>),
      );

      if (parsed.object != null) {
        return ZetrixSDKResult.success(data: parsed.object!);
      }

      final msg = parsed.messages?.first.message ?? 'Failed to create VP blob';
      return ZetrixSDKResult.failure(error: DefaultError(msg));
    } on DioException catch (e) {
      final msg = e.response?.data?["messages"]?[0]?["message"];
      return ZetrixSDKResult.failure(
        error: DefaultError(msg ?? 'Create VP blob error'),
      );
    }
  }

  /// Creates a Verifiable Presentation (VP) with encryption.
  ///
  /// Returns a [ZetrixSDKResult] containing the [CreateVpResponse] if the operation is successful.
  /// Handles the process of requesting and encrypting a VP.
  ///
  /// Throws an exception if the application fails.
  Future<ZetrixSDKResult<CreateVpResponse>> createVpBlobEnc(
      CreateVpRequest reqDto,
      String holderPrivateKey,
      String issuerPublicKey) async {
    try {
      final keyMaterial = await KeyExchangeUtils.deriveSharedKey(
        privateKeyBase58: holderPrivateKey,
        recipientPubKeyBase58: issuerPublicKey,
      );

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

      return postCreateVpBlob(
          payload, base64Url.encode(encryptedSecret), x25519PubKey);
    } on DioException catch (e) {
      final msg = e.response?.data?["messages"]?[0]?["message"];
      return ZetrixSDKResult.failure(
        error: DefaultError(msg ?? 'Create VP blob error'),
      );
    }
  }

  /// Submits a Verifiable Presentation (VP) blob to the server.
  ///
  /// Takes a [payload] containing the VP data and a [secretKey] for encryption or authentication.
  /// Returns a [Future] that completes with a [ZetrixSDKResult] containing the [VerifiablePresentation].
  ///
  /// Throws an exception if the submission fails.
  Future<ZetrixSDKResult<VerifiablePresentation>> postSubmitVpBlob(
      String payload, String secretKey, String x25519PubKey) async {
    try {
      final response = await _dio.post(
        '/cred/v1/vp/enc/submit',
        data: payload,
        options: Options(headers: {
          'secretKey': secretKey,
          'x25519PubKey': x25519PubKey,
        }),
      );

      final parsed = StandardApiResponse<VerifiablePresentation>.fromJson(
        response.data,
        (json) => VerifiablePresentation.fromJson(json as Map<String, dynamic>),
      );

      if (parsed.object != null) {
        return ZetrixSDKResult.success(data: parsed.object);
      }

      final msg = parsed.messages?.first.message ?? 'Failed to submit VP blob';
      return ZetrixSDKResult.failure(error: DefaultError(msg));
    } on DioException catch (e) {
      final msg = e.response?.data?["messages"]?[0]?["message"];
      return ZetrixSDKResult.failure(
        error: DefaultError(msg ?? 'Submit VP blob error'),
      );
    }
  }

  /// Submits an encrypted Verifiable Presentation (VP) blob to the server.
  ///
  /// Returns a [ZetrixSDKResult] containing the [VerifiablePresentation] on success.
  /// Handles encryption and submission of the VP data.
  ///
  /// Throws an exception if the submission fails.
  Future<ZetrixSDKResult<VerifiablePresentation>> submitVpBlobEnc(
      SubmitVpRequest request,
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

      return await postSubmitVpBlob(
        payload,
        base64Url.encode(encryptedSecret),
        x25519PubKey,
      );
    } on DioException catch (e) {
      final msg = e.response?.data?["messages"]?[0]?["message"];
      return ZetrixSDKResult.failure(
        error: DefaultError(msg ?? 'Submit VP blob error'),
      );
    }
  }
}
