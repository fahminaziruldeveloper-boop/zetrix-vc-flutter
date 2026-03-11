import 'dart:convert';
import 'dart:typed_data';
import 'package:bs58/bs58.dart';
import 'package:cryptography/cryptography.dart' as crypto;
import 'package:uuid/uuid.dart';
import 'package:zetrix_vc_flutter/src/models/dcql/dcql_exceptions.dart';
import 'package:zetrix_vc_flutter/src/models/dcql/dcql_models.dart';
import 'package:zetrix_vc_flutter/src/models/dcql/vp_submission_body.dart';
import 'package:zetrix_vc_flutter/src/models/dcql/wallet_key_material.dart';
import 'package:zetrix_vc_flutter/src/models/vc/proof.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:zetrix_vc_flutter/src/models/did/verification_method.dart';
import 'package:zetrix_vc_flutter/src/models/did/zid_resolver_response.dart';
import 'package:zetrix_vc_flutter/src/models/proof_type_enum.dart';
import 'package:zetrix_vc_flutter/src/models/standard_api_response.dart';
import 'package:zetrix_vc_flutter/src/models/vc/range_proof.dart';
import 'package:zetrix_vc_flutter/src/models/vc/range_proof_request.dart';
import 'package:zetrix_vc_flutter/src/models/vc/vc_constant.dart';
import 'package:zetrix_vc_flutter/src/services/bulletproof_service.dart';
import 'package:zetrix_vc_flutter/src/services/did_resolver_service.dart';
import 'package:zetrix_vc_flutter/src/utils/encoding_utils.dart';
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';

/// A service class for creating Verifiable Presentations (VP) using Zetrix SDK.
///
/// This class provides methods to create a VP using either FFI or multi-credential-based strategies.
class ZetrixVpService {
  /// The Dio HTTP client for backend communication.
  final Dio? dio;
  /// If true, use mainnet URLs; otherwise, use testnet (default: false).
  final bool isMainnet;

  /// Creates an instance of [ZetrixVpService].
  ///
  /// The [dio] parameter is an optional [Dio] HTTP client for making network requests.
  /// The [isMainnet] parameter determines whether to use the mainnet environment.
  /// Defaults to `false` (testnet).
  /// The [bulletproofService] parameter is optional and defaults to a new instance.
  /// Pass a custom instance to enable unit testing without invoking the Rust FFI.
  ZetrixVpService({
    this.dio,
    this.isMainnet = false,
    BulletproofService? bulletproofService,
  }) : bulletproofService = bulletproofService ?? BulletproofService() {
    if (dio != null) {
      dio!.options.baseUrl = ConfigReader.getBaseUrl(isMainnet);
    }
  }
  /// A utility for encryption-related tasks, used to encode VP to Base64.
  EncryptionUtils encryption = EncryptionUtils();
  
  /// Bulletproof service for generating range proofs
  final BulletproofService bulletproofService;

  /// Creates a Verifiable Presentation (VP) for multiple credential scenarios.
  ///
  /// This method generates a Verifiable Presentation (VP) using the [VerifiableCredential] provided,
  /// allowing selective disclosure of specific attributes (`revealAttribute`) when required.
  /// It leverages the BBS+ proof mechanism for privacy-preserving credentials.
  @Deprecated(
      'createVpMC() is deprecated and will be removed in future releases. '
      'Please use createVpLite() or createVp() instead.')
  Future<ZetrixSDKResult<String>> createVpMC(
      VerifiableCredential vc,
      List<String>? revealAttribute,
      String blsPublicKey,
      String publicKey) async {
    String bbsSignature = '';
    String bbsVerificationMethod = '';

    for (final proof in vc.proof ?? []) {
      if (proof.type == ProofTypeEnum.bbsSign.value) {
        bbsSignature = proof.proofValue;
        bbsVerificationMethod = proof.verificationMethod;
      }
    }

    if (revealAttribute != null &&
        revealAttribute.isNotEmpty &&
        bbsSignature.isEmpty) {
      return ZetrixSDKResult.failure(error: CryptoError('VC_UNSUPPORTED_BBS'));
    }

    final holderDid = vc.credentialSubject?['id'] as String?;

    if (holderDid == null) {
      return ZetrixSDKResult.failure(
          error: VcSchemaError('VC_METADATA_KEY_ID_NULL'));
    }

    final vp = VerifiablePresentation(
      context: List<String>.from(VcConstant.context),
      type: [VcConstant.typeVp],
      holder: holderDid,
    );

    if (revealAttribute != null && revealAttribute.isNotEmpty) {
      // Get BBS public key
      final publicKeyBytes = base58.decode(blsPublicKey.substring(1));

      // Flatten credentialSubject into a list of string values
      final flattenedMessages =
          Tools.flattenMapToListString(vc.credentialSubject ?? {}, '');
      final messages = flattenedMessages.map((s) => utf8.encode(s)).toList();

      // Prepare map to hold selectively disclosed values
      final discloseMap = <String, dynamic>{};

      // Flatten map to get key list for index resolution
      final credentialKeys =
          Tools.flattenMapToMap(vc.credentialSubject ?? {}, '').keys.toList();

      // Collect reveal indexes
      final revealIndex = <int>[];

      for (final fullKey in revealAttribute) {
        if (!credentialKeys.contains(fullKey)) {
          return ZetrixSDKResult.failure(
              error: VcSchemaError('KEY_NOT_FOUND: $fullKey'));
        }

        revealIndex.add(credentialKeys.indexOf(fullKey));

        final value = Tools.getNestedValue(vc.credentialSubject ?? {}, fullKey);
        Tools.insertNestedValue(discloseMap, fullKey, value);
      }

      final bbs = Bbs();

      // Generate BBS+ proof
      final proof = await bbs.setBbsBlsProof(
        messages,
        publicKeyBytes,
        bbsSignature,
        revealIndex,
        bbsVerificationMethod,
      );

      // Update credentialSubject and proof
      vc.credentialSubject = discloseMap;
      vc.proof = [proof];
    }

    final vcList = <VerifiableCredential>[vc];
    vp.verifiableCredential = vcList;

    var vpString = jsonEncode(vp.toJson());
    vpString = Helpers.extractMinimalVp(vpString);

    //Gzip compression
    final compressed = EncodingUtils.compressJsonGzip(vpString);
    final base64Compressed = base64.encode(compressed);

    return ZetrixSDKResult.success(data: base64Compressed);
  }

  /// Creates a Verifiable Presentation (VP) for multiple credential scenarios. Lite Version
  ///
  /// This method generates a Verifiable Presentation (VP) using the [VerifiableCredential] provided,
  /// allowing selective disclosure of specific attributes (`revealAttribute`) when required.
  /// It leverages the BBS+ proof mechanism for privacy-preserving credentials.
  Future<ZetrixSDKResult<String>> createVpLite(
      VerifiableCredential vc,
      List<String>? revealAttribute,
      String blsPublicKey,
      String publicKey,
      RangeProofRequest? rangeProofRequest) async {
    String bbsSignature = '';
    String bbsVerificationMethod = '';

    for (final proof in vc.proof ?? []) {
      if (proof.type == ProofTypeEnum.bbsSign.value) {
        bbsSignature = proof.proofValue;
        bbsVerificationMethod = proof.verificationMethod;
      }
    }

    if (revealAttribute != null &&
        revealAttribute.isNotEmpty &&
        bbsSignature.isEmpty) {
      return ZetrixSDKResult.failure(error: CryptoError('VC_UNSUPPORTED_BBS'));
    }

    final holderDid = vc.credentialSubject?['id'] as String?;

    if (holderDid == null) {
      return ZetrixSDKResult.failure(
          error: VcSchemaError('VC_METADATA_KEY_ID_NULL'));
    }

    final vp = VerifiablePresentation(
      context: List<String>.from(VcConstant.context),
      type: [VcConstant.typeVp],
      holder: holderDid,
    );

    if (revealAttribute != null && revealAttribute.isNotEmpty) {
      // Get BBS public key
      final publicKeyBytes = base58.decode(blsPublicKey.substring(1));

      // Flatten credentialSubject into a list of string values
      final flattenedMessages =
          Tools.flattenMapToListString(vc.credentialSubject ?? {}, '');
      final messages = flattenedMessages.map((s) => utf8.encode(s)).toList();

      // Prepare map to hold selectively disclosed values
      final discloseMap = <String, dynamic>{};

      // Flatten map to get key list for index resolution
      final credentialKeys =
          Tools.flattenMapToMap(vc.credentialSubject ?? {}, '').keys.toList();

      // Collect reveal indexes
      final revealIndex = <int>[];

      for (final fullKey in revealAttribute) {
        if (!credentialKeys.contains(fullKey)) {
          return ZetrixSDKResult.failure(
              error: VcSchemaError('KEY_NOT_FOUND: $fullKey'));
        }

        revealIndex.add(credentialKeys.indexOf(fullKey));

        final value = Tools.getNestedValue(vc.credentialSubject ?? {}, fullKey);
        Tools.insertNestedValue(discloseMap, fullKey, value);
      }

      final bbs = Bbs();

      // Generate BBS+ proof
      final proof = await bbs.setBbsBlsProof(
        messages,
        publicKeyBytes,
        bbsSignature,
        revealIndex,
        bbsVerificationMethod,
      );

      // Update credentialSubject and proof
      vc.credentialSubject = discloseMap;
      vc.proof = [proof];
    }

    final vcList = <VerifiableCredential>[vc];
    vp.verifiableCredential = vcList;
    
    // **Generate bulletproof range proof if requested**
    if (rangeProofRequest != null) {
      try {
        final rangeProof = await _generateRangeProof(
          vc: vc,
          request: rangeProofRequest,
        );
        vp.rangeProof = rangeProof;
      } catch (e) {
        return ZetrixSDKResult.failure(
          error: CryptoError('RANGE_PROOF_GENERATION_FAILED: ${e.toString()}'),
        );
      }
    }

    var vpString = jsonEncode(vp.toJson());
    vpString = Helpers.extractMinimalVp(vpString);

    //Gzip compression
    final compressed = EncodingUtils.compressJsonGzip(vpString);
    final base64Compressed = base64.encode(compressed);

    return ZetrixSDKResult.success(data: base64Compressed);
  }

  /// Creates a Verifiable Presentation (VP) for multiple credential scenarios.
  ///
  /// This method generates a Verifiable Presentation (VP) using the [VerifiableCredential] provided,
  /// allowing selective disclosure of specific attributes (`revealAttribute`) when required.
  /// It leverages the BBS+ proof mechanism for privacy-preserving credentials.
  Future<ZetrixSDKResult<String>> createVp(
      VerifiableCredential vc,
      List<String>? revealAttribute,
      String blsPublicKey,
      String holderPublicKey,
      String holderPrivateKey,
      RangeProofRequest? rangeProofRequest) async {
    final resolverUrl = ConfigReader.getZidResolverUrl();
    //add holder signature in the VP
    final DidResolverService didResolverService =
        DidResolverService(resolverUrl: resolverUrl);

    final ZidResolverResponse resolveIssuer =
        await didResolverService.resolveZid(vc.issuer!);
    String bbsSignature = '';
    String bbsVerificationMethod = '';

    for (final Proof proof in vc.proof ?? []) {
      if (proof.type == ProofTypeEnum.bbsSign.value) {
        bbsSignature = proof.proofValue!;
        bbsVerificationMethod = proof.verificationMethod!;
      } else if (proof.type == ProofTypeEnum.ed25519.value) {
        String publicKeyHex = didResolverService.getEd25519PublicKey(
            verificationMethodId: proof.verificationMethod!,
            resolverResponse: resolveIssuer);
        if (!await encryption.verifyEddsaSignature(proof.jws!, publicKeyHex)) {
          // verify VC signatures
          return ZetrixSDKResult.failure(
              error: ZetrixSDKExceptions.cryptoError(
                  'VC_INVALID_SIGNATURE_EDDSA'));
        }
      }
    }

    if (revealAttribute != null &&
        revealAttribute.isNotEmpty &&
        bbsSignature.isEmpty) {
      return ZetrixSDKResult.failure(error: CryptoError('VC_UNSUPPORTED_BBS'));
    }

    final holderDid = vc.credentialSubject?['id'] as String?;

    if (holderDid == null) {
      return ZetrixSDKResult.failure(
          error: VcSchemaError('VC_METADATA_KEY_ID_NULL'));
    }

    VerifiablePresentation vp = VerifiablePresentation(
      context: List<String>.from(VcConstant.context),
      type: [VcConstant.typeVp],
      holder: holderDid,
    );

    if (revealAttribute != null && revealAttribute.isNotEmpty) {
      // Get BBS public key
      final publicKeyBytes = base58.decode(blsPublicKey.substring(1));

      // Flatten credentialSubject into a list of string values
      final flattenedMessages =
          Tools.flattenMapToListString(vc.credentialSubject ?? {}, '');
      final messages = flattenedMessages.map((s) => utf8.encode(s)).toList();

      // Prepare map to hold selectively disclosed values
      final discloseMap = <String, dynamic>{};

      // Flatten map to get key list for index resolution
      final credentialKeys =
          Tools.flattenMapToMap(vc.credentialSubject ?? {}, '').keys.toList();

      // Collect reveal indexes
      final revealIndex = <int>[];

      for (final fullKey in revealAttribute) {
        if (!credentialKeys.contains(fullKey)) {
          return ZetrixSDKResult.failure(
              error: VcSchemaError('KEY_NOT_FOUND: $fullKey'));
        }

        revealIndex.add(credentialKeys.indexOf(fullKey));

        final value = Tools.getNestedValue(vc.credentialSubject ?? {}, fullKey);
        Tools.insertNestedValue(discloseMap, fullKey, value);
      }

      final bbs = Bbs();

      // Generate BBS+ proof
      final proof = await bbs.setBbsBlsProof(
        messages,
        publicKeyBytes,
        bbsSignature,
        revealIndex,
        bbsVerificationMethod,
      );

      // Update credentialSubject and proof
      vc.credentialSubject = discloseMap;
      vc.proof = [proof];
    }

    final vcList = <VerifiableCredential>[vc];
    vp.verifiableCredential = vcList;

    // Generate bulletproof range proof if requested
    if (rangeProofRequest != null) {
      try {
        final rangeProof = await _generateRangeProof(
          vc: vc,
          request: rangeProofRequest,
        );
        vp.rangeProof = rangeProof;
      } catch (e) {
        return ZetrixSDKResult.failure(
          error: CryptoError('RANGE_PROOF_GENERATION_FAILED: ${e.toString()}'),
        );
      }
    }

    var vpString = jsonEncode(vp.toJson());

    //add holder signature in the VP
    final ZidResolverResponse result =
        await didResolverService.resolveZid(holderDid);

    final verificationMethodsJson =
        result.didDocument?['verificationMethod'] as List<dynamic>?;

    final List<VerificationMethod> verificationMethods =
        verificationMethodsJson?.map((item) {
              return VerificationMethod.fromJson(item as Map<String, dynamic>);
            }).toList() ??
            [];

    if (verificationMethods.isEmpty) {
      return ZetrixSDKResult.failure(
          error: ZetrixSDKExceptions.ResolverError(
              'NO_VERIFICATION_METHODS_FOUND'));
    }

    final matchingVm = verificationMethods.firstWhereOrNull(
      (VerificationMethod vm) =>
          vm.type == 'Ed25519VerificationKey2020' &&
          vm.additionalFields['publicKeyHex'] == holderPublicKey,
    );

    if (matchingVm == null) {
      return ZetrixSDKResult.failure(
          error: ZetrixSDKExceptions.cryptoError('ED25519_KEY_NOT_MATCH'));
    }

    // set eddsa proof
    final Map<String, dynamic> header = {
      "alg": "EdDSA",
    };

    final String headerJson = jsonEncode(header);

    //To create vp blob
    String msg = EncodingUtils.utfToHex(Helpers.formatJwsSignData(
        Helpers.formatJwsStr(headerJson), Helpers.formatJwsStr(vpString)));

    final SignBlob signBlob = await encryption.signBlob(msg, holderPrivateKey);

    String jws = Helpers.createJwsToken(
        header: headerJson, payload: vpString, signature: signBlob.signBlob!);

    // ISO8601 UTC time
    final created = DateTime.now().toUtc().toIso8601String();

    final proof = Proof()
      ..type = ProofTypeEnum.ed25519.value
      ..created = created
      ..verificationMethod = matchingVm.id
      ..proofPurpose = "assertionMethod"
      ..jws = jws;

    vp.proof = proof;

    return ZetrixSDKResult.success(data: jsonEncode(vp));
  }

    /// Creates a Verifiable Presentation (VP) blob.
    ///
    /// This method generates a VP blob based on the provided input and returns a [ZetrixSDKResult]
    /// containing a [CreateVpResponse] on success.
    ///
    /// Returns a [Future] that completes with the result of the VP creation operation.
    Future<ZetrixSDKResult<CreateVpResponse>> createVpBlob(
      CreateVpRequest reqDto) async {
    try {
      final response = await dio?.post(
        '/cred/v1/vp/create',
        data: reqDto.toJson(),
      );

      final parsed = StandardApiResponse<CreateVpResponse>.fromJson(
        response?.data,
        (json) => CreateVpResponse.fromJson(json as Map<String, dynamic>),
      );

      if (parsed.object != null) {
        return ZetrixSDKResult.success(data: parsed.object!);
      } else {
        final msg = parsed.messages?.first.message ?? 'Failed to create VP blob';
        return ZetrixSDKResult.failure(error: DefaultError(msg));
      }
    } on DioException catch (e) {
      String? msg;
      if (e.response?.statusCode == 400) {
        msg = e.response?.data?["messages"]?[0]?["message"];
      }
      return ZetrixSDKResult.failure(
        error: DefaultError(msg ?? 'Create VP blob error'),
      );
    }
  }

    /// Submits a Verifiable Presentation (VP) blob to the designated service.
    ///
    /// Returns a [ZetrixSDKResult] containing the [VerifiablePresentation] on success.
    /// Handles the process of sending the VP data and receiving the response.
    ///
    /// Throws an exception if the submission fails.
    Future<ZetrixSDKResult<VerifiablePresentation>> submitVpBlob(
      SubmitVpRequest reqDto) async {
    try {
      final response = await dio?.post(
        '/cred/v1/vp/submit',
        data: reqDto.toJson(),
      );

      final parsed = StandardApiResponse<VerifiablePresentation>.fromJson(
        response?.data,
        (json) => VerifiablePresentation.fromJson(json as Map<String, dynamic>),
      );

      if (parsed.object != null) {
        return ZetrixSDKResult.success(data: parsed.object!);
      } else {
        final msg = parsed.messages?.first.message ?? 'Failed to submit VP blob';
        return ZetrixSDKResult.failure(error: DefaultError(msg));
      }
    } on DioException catch (e) {
      String? msg;
      if (e.response?.statusCode == 400) {
        msg = e.response?.data?["messages"]?[0]?["message"];
      }
      return ZetrixSDKResult.failure(
        error: DefaultError(msg ?? 'Submit VP blob error'),
      );
    }
  }

  /// Internal helper to generate bulletproof range proof for VP
  ///
  /// **Parameters:**
  /// - [vc]: The verifiable credential containing attribute values
  /// - [request]: Range proof request with attributes, min/max values, etc.
  ///
  /// **Returns:**
  /// A [RangeProof] on success.
  ///
  /// **Throws:**
  /// - [VcSchemaError]: If attribute is not found or not numeric
  /// - [ArgumentError]: If value is outside the specified range
  /// - [Exception]: If proof generation fails
  Future<RangeProof> _generateRangeProof({
    required VerifiableCredential vc,
    required RangeProofRequest request,
  }) async {
    // Extract and validate attribute values from credential
    final values = <int>[];
    for (int i = 0; i < request.attributes.length; i++) {
      final attributeName = request.attributes[i];
      final minValue = request.minValues[i];
      final maxValue = request.maxValues[i];

      // Get value from credential subject
      final value = Tools.getNestedValue(
        vc.credentialSubject ?? {},
        attributeName,
      );

      if (value == null) {
        throw VcSchemaError('ATTRIBUTE_NOT_FOUND: $attributeName');
      }

      // Convert to integer
      int intValue;
      if (value is int) {
        intValue = value;
      } else if (value is double) {
        intValue = value.toInt();
      } else if (value is String) {
        final intParsed = int.tryParse(value);
        final doubleParsed = double.tryParse(value);
        if (intParsed != null) {
          intValue = intParsed;
        } else if (doubleParsed != null) {
          intValue = doubleParsed.toInt();
        } else {
          throw VcSchemaError('ATTRIBUTE_NOT_NUMERIC: $attributeName');
        }
      } else {
        throw VcSchemaError('ATTRIBUTE_NOT_NUMERIC: $attributeName');
      }

      // Validate range (maxValue == BulletproofUtil.noMaxValue means no upper bound)
      if (intValue < minValue ||
          (maxValue != BulletproofUtil.noMaxValue && intValue > maxValue)) {
        throw ArgumentError(
          'ATTRIBUTE_OUT_OF_RANGE: $attributeName ($intValue not in [$minValue, $maxValue])',
        );
      }

      values.add(intValue);
    }

    // Generate bulletproof range proof using correct parameter names
    final proofData = await bulletproofService.generateMultipleMinMaxRangeProof(
      values: values,
      mins: request.minValues,
      maxs: request.maxValues,
      bitSize: request.bits,
      domain: request.domain,
    );

    // Create RangeProof model
    final rangeProof = RangeProof(
      type: ProofTypeEnum.bulletproof.value,
      proof: proofData.proofValue,
      bits: request.bits,
      domain: request.domain,
      commitments: proofData.commitments,
    );

    return rangeProof;
  }

  // ─── DCQL VP ─────────────────────────────────────────────────────────────────

  /// Creates a Verifiable Presentation from a DCQL presentation request.
  ///
  /// [presentationResponse] — raw JSON map from `GET /v1/presentation/{id}`.
  /// [vc] — the holder's Verifiable Credential (raw JSON map from wallet).
  /// [keys] — wallet cryptographic key material.
  ///
  /// Returns a [VpSubmissionBody] ready to POST to `response_uri`.
  ///
  /// Throws:
  /// - [DcqlMatchException] — VC type does not match any requirement.
  /// - [ClaimNotFoundException] — required claim path absent from VC.
  /// - [RangeProofFailException] — resolved value violates min/max filter.
  /// - [ProofCreationException] — BBS+ proof derivation failed.
  /// - [JwtSigningException] — Ed25519 JWT signing failed.
  Future<VpSubmissionBody> createVPFromDCQL({
    required Map<String, dynamic> presentationResponse,
    required Map<String, dynamic> vc,
    required WalletKeyMaterial keys,
  }) async {
    final response = PresentationResponse.fromJson(presentationResponse);
    final requirement = _dcqlMatchRequirement(response.credentialQuery.credentials, vc);

    final disclosedFields = <String, dynamic>{};
    final bbsRevealKeys = <String>[];
    final rangeProofClaims = <_DcqlRangeProofClaim>[];
    final credSubject = vc['credentialSubject'] as Map<String, dynamic>? ?? {};

    for (final claim in requirement.claims) {
      final resolved = _dcqlResolveClaimPath(credSubject, claim.path);
      if (resolved == null) throw ClaimNotFoundException(claim.path.join('.'));
      final (rawValue, actualSegments) = resolved;
      final actualFullPath = ['credentialSubject', ...actualSegments];
      final flatKey = actualSegments.join('.');
      final filter = claim.filter;

      if (filter == null || !filter.requiresRangeProof) {
        _dcqlSetNestedValue(disclosedFields, actualFullPath, rawValue);
        bbsRevealKeys.add(flatKey);
      } else {
        final numValue = _dcqlResolveToNumber(actualSegments.last, rawValue);
        if (filter.minimum != null && numValue < filter.minimum!) {
          throw RangeProofFailException(fieldName: actualSegments.last, value: numValue, minimum: filter.minimum, maximum: filter.maximum);
        }
        if (filter.maximum != null && numValue > filter.maximum!) {
          throw RangeProofFailException(fieldName: actualSegments.last, value: numValue, minimum: filter.minimum, maximum: filter.maximum);
        }
        rangeProofClaims.add(_DcqlRangeProofClaim(path: actualFullPath, numericValue: numValue.toInt(), minimum: filter.minimum?.toInt(), maximum: filter.maximum?.toInt()));
        _dcqlSetNestedValue(disclosedFields, actualFullPath, rawValue);
        bbsRevealKeys.add(flatKey);
      }
    }

    final derivedVc = await _dcqlBuildDerivedVc(
      originalVc: vc,
      disclosedFields: disclosedFields,
      bbsRevealKeys: bbsRevealKeys,
      rangeProofClaims: rangeProofClaims,
      nonce: response.nonce,
      keys: keys,
    );

    final vp = {
      '@context': ['https://www.w3.org/2018/credentials/v1', 'https://w3id.org/security/bbs/v1'],
      'holder': keys.holderDid,
      'type': ['VerifiablePresentation'],
      'verifiableCredential': [derivedVc],
    };

    final vpToken = await _dcqlEncodeAsJwt(vp, keys.ed25519PrivateKey);

    return VpSubmissionBody(
      vpToken: vpToken,
      presentation_id: response.presentation_id,
      presentationSubmission: PresentationSubmission(
        id: const Uuid().v4(),
        definitionId: requirement.id,
        descriptorMap: [
          DescriptorMap(
            id: 'credential_0',
            format: requirement.format,
            path: r'$.verifiableCredential[0]',
          ),
        ],
      ),
      ed25519PublicKey: keys.ed25519PublicKey,
      bbsPublicKey: keys.bbsPublicKey,
    );
  }

  CredentialRequirement _dcqlMatchRequirement(
    List<CredentialRequirement> requirements,
    Map<String, dynamic> vc,
  ) {
    final vcTypes = (vc['type'] as List<dynamic>? ?? []).map((e) => e as String).toList();
    for (final req in requirements) {
      if (req.meta.vctValues.every((t) => vcTypes.contains(t))) return req;
    }
    throw DcqlMatchException(
      'No credential requirement matches VC types: $vcTypes. '
      'Required one of: ${requirements.map((r) => r.meta.vctValues).toList()}',
    );
  }

  (dynamic, List<String>)? _dcqlResolveClaimPath(
      Map<String, dynamic> credSubject, List<String> path) {
    final segments = path.skip(1).toList();
    dynamic current = credSubject;
    bool exactOk = true;
    for (final seg in segments) {
      if (current is! Map) { exactOk = false; break; }
      final next = (current as Map<String, dynamic>)[seg];
      if (next == null) { exactOk = false; break; }
      current = next;
    }
    if (exactOk && segments.isNotEmpty) return (current, segments);
    return _dcqlDeepSearchValue(credSubject, segments.last, []);
  }

  (dynamic, List<String>)? _dcqlDeepSearchValue(
      Map<String, dynamic> map, String targetKey, List<String> prefix) {
    for (final entry in map.entries) {
      if (entry.key == targetKey) return (entry.value, [...prefix, entry.key]);
      if (entry.value is Map<String, dynamic>) {
        final found = _dcqlDeepSearchValue(
            entry.value as Map<String, dynamic>, targetKey, [...prefix, entry.key]);
        if (found != null) return found;
      }
    }
    return null;
  }

  void _dcqlSetNestedValue(Map<String, dynamic> target, List<String> path, dynamic value) {
    final segments = path.skip(1).toList();
    Map<String, dynamic> current = target;
    for (int i = 0; i < segments.length - 1; i++) {
      current.putIfAbsent(segments[i], () => <String, dynamic>{});
      current = current[segments[i]] as Map<String, dynamic>;
    }
    current[segments.last] = value;
  }

  num _dcqlResolveToNumber(String fieldName, dynamic rawValue) {
    if (rawValue is num) return rawValue;
    final s = rawValue.toString();
    if (fieldName == 'icNo') return _dcqlAgeFromIcNo(s);
    const dobAliases = {'DOB', 'dob', 'dateOfBirth', 'birthDate', 'birth_date'};
    if (dobAliases.contains(fieldName)) return _dcqlAgeFromDateString(s);
    final parsed = double.tryParse(s);
    if (parsed != null) return parsed;
    throw ArgumentError('Cannot resolve field "$fieldName" value "$rawValue" to a number');
  }

  int _dcqlAgeFromIcNo(String icNo) {
    final ic = icNo.padLeft(12, '0');
    final yy = int.parse(ic.substring(0, 2));
    final mm = int.parse(ic.substring(2, 4));
    final dd = int.parse(ic.substring(4, 6));
    final now = DateTime.now().toUtc();
    final fullYear = yy <= (now.year % 100) ? 2000 + yy : 1900 + yy;
    return _dcqlComputeAge(DateTime.utc(fullYear, mm, dd));
  }

  int _dcqlAgeFromDateString(String dateStr) {
    final normalized = dateStr.contains('T') ? dateStr.split('T').first : dateStr;
    if (RegExp(r'^\d{2}[-/]\d{2}[-/]\d{4}$').hasMatch(normalized)) {
      final p = normalized.split(RegExp(r'[-/]'));
      return _dcqlComputeAge(DateTime.utc(int.parse(p[2]), int.parse(p[1]), int.parse(p[0])));
    }
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(normalized)) {
      final p = normalized.split('-');
      return _dcqlComputeAge(DateTime.utc(int.parse(p[0]), int.parse(p[1]), int.parse(p[2])));
    }
    throw ArgumentError('Unrecognised date format: "$dateStr"');
  }

  int _dcqlComputeAge(DateTime birthDate) {
    final today = DateTime.now().toUtc();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) age--;
    return age;
  }

  Future<Map<String, dynamic>> _dcqlBuildDerivedVc({
    required Map<String, dynamic> originalVc,
    required Map<String, dynamic> disclosedFields,
    required List<String> bbsRevealKeys,
    required List<_DcqlRangeProofClaim> rangeProofClaims,
    required String nonce,
    required WalletKeyMaterial keys,
  }) async {
    final originalProofs =
        (originalVc['proof'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final bbsProof = originalProofs.firstWhere(
      (p) => p['type'] == 'BbsBlsSignature2020',
      orElse: () => <String, dynamic>{},
    );
    final bbsSignature = bbsProof['proofValue'] as String? ?? '';
    final verificationMethod = bbsProof['verificationMethod'] as String? ?? '';
    final proofPurpose = bbsProof['proofPurpose'] as String? ?? 'assertionMethod';
    if (bbsSignature.isEmpty) {
      throw ProofCreationException('Original VC does not contain a BbsBlsSignature2020 proof entry');
    }

    final publicKeyBytes = base58.decode(keys.bbsPublicKey.substring(1));
    final bbs = Bbs();
    final flattenedMessages =
        Tools.flattenMapToListString(originalVc['credentialSubject'] as Map<String, dynamic>? ?? {}, '');
    final messages = flattenedMessages.map((s) => Uint8List.fromList(utf8.encode(s))).toList();
    final credentialKeys =
        Tools.flattenMapToMap(originalVc['credentialSubject'] as Map<String, dynamic>? ?? {}, '')
            .keys
            .toList();

    final revealIndex = <int>[];
    for (final fullKey in bbsRevealKeys) {
      if (!credentialKeys.contains(fullKey)) throw ProofCreationException('KEY_NOT_FOUND: $fullKey');
      revealIndex.add(credentialKeys.indexOf(fullKey));
    }

    String derivedProofValue = '';
    String derivedNonceField = nonce;
    try {
      if (nonce.isNotEmpty) {
        Uint8List nonceBytes;
        try {
          final nonceBody = nonce.startsWith('u') ? nonce.substring(1) : nonce;
          final normalized = nonceBody.padRight((nonceBody.length + 3) ~/ 4 * 4, '=');
          nonceBytes = Uint8List.fromList(base64Url.decode(normalized));
        } catch (e) {
          throw ProofCreationException('Invalid presentation nonce format', cause: e);
        }
        final sigDecoded = bbs.decodeBbsSignature(bbsSignature);
        final proofValue = await bbs.createSelectiveDisclosureProofBls(
          publicKeyBytes, nonceBytes, sigDecoded, messages, revealIndex.toSet());
        derivedProofValue = proofValue;
        derivedNonceField = 'u${base64Url.encode(nonceBytes).replaceAll('=', '')}';
      } else {
        final Proof bbsProofResult = await bbs.setBbsBlsProof(
          messages, publicKeyBytes, bbsSignature, revealIndex, verificationMethod);
        derivedProofValue = bbsProofResult.proofValue ?? '';
        derivedNonceField = bbsProofResult.nonce ?? nonce;
      }
      if (derivedProofValue.isEmpty) {
        throw ProofCreationException('BBS+ derived proof generation returned empty proofValue');
      }
    } catch (e) {
      throw ProofCreationException('BBS+ derived proof generation failed', cause: e);
    }

    final generatedRangeProofs = <_DcqlGeneratedRangeProof>[];
    for (final claim in rangeProofClaims) {
      try {
        final bpProof = await _dcqlBuildRangeProof(claim);
        generatedRangeProofs.add(_DcqlGeneratedRangeProof(claim: claim, proof: bpProof));
      } catch (e) {
        throw ProofCreationException(
            'BulletProof generation failed for field "${claim.path.last}"', cause: e);
      }
    }

    final derivedProof = <String, dynamic>{
      'type': 'BbsBlsSignatureProof2020',
      'created': DateTime.now().toUtc().toIso8601String(),
      'nonce': derivedNonceField,
      'proofPurpose': proofPurpose,
      'verificationMethod': verificationMethod,
      'proofValue': derivedProofValue,
    };
    if (generatedRangeProofs.isNotEmpty) {
      derivedProof['rangeProofs'] = generatedRangeProofs
          .map((rp) => {
                'fieldPath': rp.claim.path,
                'proofValue': rp.proof.proofValue,
                'commitments': rp.proof.commitments,
                'bits': rp.proof.bitSize,
                'domain': rp.proof.domain,
                if (rp.claim.minimum != null) 'minimum': rp.claim.minimum,
                if (rp.claim.maximum != null) 'maximum': rp.claim.maximum,
              })
          .toList();
    }

    return {
      '@context': originalVc['@context'],
      'id': originalVc['id'],
      'type': originalVc['type'],
      'issuer': originalVc['issuer'],
      if (originalVc['validFrom'] != null) 'validFrom': originalVc['validFrom'],
      if (originalVc['validUntil'] != null) 'validUntil': originalVc['validUntil'],
      'credentialSubject': disclosedFields,
      'proof': [derivedProof],
    };
  }

  Future<_DcqlBpProofResult> _dcqlBuildRangeProof(_DcqlRangeProofClaim claim) async {
    final hasMin = claim.minimum != null;
    final hasMax = claim.maximum != null;
    if (hasMin && hasMax) {
      final bp = await bulletproofService.generateSingleMinMaxRangeProof(
          value: claim.numericValue, min: claim.minimum!, max: claim.maximum!);
      return _DcqlBpProofResult(proofValue: bp.proofValue, commitments: bp.commitments, bitSize: bp.bitSize, domain: bp.domain);
    } else if (hasMin) {
      final bp = await bulletproofService.generateSingleMinRangeProof(
          value: claim.numericValue, min: claim.minimum!);
      return _DcqlBpProofResult(proofValue: bp.proofValue, commitments: bp.commitments, bitSize: bp.bitSize, domain: bp.domain);
    } else {
      final bp = await bulletproofService.generateSingleMaxRangeProof(
          value: claim.numericValue, max: claim.maximum!);
      return _DcqlBpProofResult(proofValue: bp.proofValue, commitments: bp.commitments, bitSize: bp.bitSize, domain: bp.domain);
    }
  }

  Future<String> _dcqlEncodeAsJwt(
    Map<String, dynamic> payload,
    Uint8List ed25519PrivateKeySeed,
  ) async {
    final headerJson = jsonEncode({'alg': 'EdDSA'});
    final payloadJson = jsonEncode(payload);
    final headerB64 = _dcqlBase64UrlNoPad(utf8.encode(headerJson));
    final payloadB64 = _dcqlBase64UrlNoPad(utf8.encode(payloadJson));
    final signingInput = utf8.encode('$headerB64.$payloadB64');
    final String sigB64;
    try {
      final algorithm = crypto.Ed25519();
      final keyPair = await algorithm.newKeyPairFromSeed(ed25519PrivateKeySeed);
      final sig = await algorithm.sign(signingInput, keyPair: keyPair);
      sigB64 = _dcqlBase64UrlNoPad(sig.bytes);
    } catch (e) {
      throw JwtSigningException('Ed25519 signing failed', cause: e);
    }
    return '$headerB64.$payloadB64.$sigB64';
  }

  String _dcqlBase64UrlNoPad(List<int> bytes) =>
      base64Url.encode(bytes).replaceAll('=', '');

}

// ─── DCQL private data classes ───────────────────────────────────────────────

class _DcqlRangeProofClaim {
  final List<String> path;
  final int numericValue;
  final int? minimum;
  final int? maximum;
  const _DcqlRangeProofClaim({required this.path, required this.numericValue, this.minimum, this.maximum});
}

class _DcqlBpProofResult {
  final String proofValue;
  final List<String> commitments;
  final int bitSize;
  final String domain;
  const _DcqlBpProofResult({required this.proofValue, required this.commitments, required this.bitSize, required this.domain});
}

class _DcqlGeneratedRangeProof {
  final _DcqlRangeProofClaim claim;
  final _DcqlBpProofResult proof;
  const _DcqlGeneratedRangeProof({required this.claim, required this.proof});
}
