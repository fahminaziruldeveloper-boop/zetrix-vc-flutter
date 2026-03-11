import 'dart:convert';
import 'dart:typed_data';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:zetrix_vc_flutter/bbs/bbs_ffi_bindings.dart';
import 'package:zetrix_vc_flutter/bbs/bbs_ffi_types.dart';
import 'package:zetrix_vc_flutter/bbs/load_library.dart';
import 'package:zetrix_vc_flutter/src/models/vc/proof.dart';
import 'package:zetrix_vc_flutter/src/utils/encryption_utils.dart';
import 'package:zetrix_vc_flutter/src/utils/generator_utils.dart';
import '../src/utils/tools.dart';
import 'bbs_flutter.dart';
import '../src/models/bbs/proof_message.dart';

/// A class that provides functionality to create BBS+ proofs and interact
/// with the BBS+ library via FFI (Foreign Function Interface).
///
/// The `Bbs` class acts as a wrapper for interacting with the native BBS+ library,
/// providing convenient methods for cryptographic operations such as proof generation.
class Bbs {
  /// FFI bindings for interacting with the native BBS+ library.
  final bbs = BbsBindings(loadBbsLib());

  /// An instance of [EncryptionUtils] for utility methods related to encryption.
  EncryptionUtils encryption = EncryptionUtils();

  /// Creates a BBS+ proof using the BLS public key, nonce, signature, and messages.
  ///
  /// This method leverages FFI calls to interact with the native BBS+ library for proof generation.
  /// - Converts the provided BLS public key to a BBS public key before proceeding with the proof creation.
  /// - Handles the allocation and deallocation of required memory during the FFI calls.
  Future<Uint8List> blsCreateProofFFI({
    required Uint8List publicKey,
    required Uint8List nonce,
    required Uint8List signature,
    required List<ProofMessage> messages,
  }) {
    // Convert publickey bls to bbs
    final bbsPublicKey = blsPublicToBbsPublicKey(publicKey, messages.length);
    Tools.logDebug('bbsPublicKey length = ${bbsPublicKey.length}');

    Tools.logDebug('BBS public key (base64): ${base64.encode(bbsPublicKey)}');

    final err1 = calloc<ExternError>();
    final handle = bbs.bbsCreateProofContextInit(err1);
    Tools.logDebug('handle init: $handle');
    if (handle == 0) {
      throw Exception('Unable to create proof context');
    }
    calloc.free(err1);

    final publicKeyPtr = ByteArrayHelper.allocate(bbsPublicKey);

    final err2 = calloc<ExternError>();

    final result = bbs.bbsCreateProofContextSetPublicKey(
      handle,
      publicKeyPtr.ref,
      err2,
    );
    Tools.logDebug('result bbsCreateProofContextSetPublicKey: $result');

    calloc.free(publicKeyPtr.ref.data);
    calloc.free(publicKeyPtr);

    if (result != 0) {
      throwIfError(result, err2, 'Unable to set public key');
    }

    calloc.free(err2);

    final noncePtr = ByteArrayHelper.allocate(nonce); // nonce is Uint8List
    final err3 = calloc<ExternError>();

    final result1 = bbs.bbsCreateProofContextSetNonceBytes(
      handle,
      noncePtr.ref,
      err3,
    );
    Tools.logDebug('result bbsCreateProofContextSetNonceBytes: $result1');

    calloc.free(noncePtr.ref.data);
    calloc.free(noncePtr);

    if (result1 != 0) {
      throwIfError(result1, err3, 'Unable to set nonce');
    }

    calloc.free(err3);

    final sigPtr = ByteArrayHelper.allocate(signature); // signature: Uint8List
    final err4 = calloc<ExternError>();

    final result2 = bbs.bbsCreateProofContextSetSignature(
      handle,
      sigPtr.ref,
      err4,
    );
    Tools.logDebug('result bbsCreateProofContextSetSignature: $result2');

    calloc.free(sigPtr.ref.data);
    calloc.free(sigPtr);

    if (result2 != 0) {
      throwIfError(result2, err4, 'Unable to set signature');
    }

    calloc.free(err4);

    final err5 = calloc<ExternError>();

    for (final msg in messages) {
      final msgPtr = ByteArrayHelper.allocate(msg.message);
      final blindPtr = ByteArrayHelper.allocate(msg.blindingFactor);

      final result3 = bbs.bbsCreateProofContextAddProofMessageBytes(
        handle,
        msgPtr.ref,
        msg.type,
        blindPtr.ref,
        err5,
      );

      calloc.free(msgPtr.ref.data);
      calloc.free(msgPtr);
      calloc.free(blindPtr.ref.data);
      calloc.free(blindPtr);

      if (result3 != 0) {
        throwIfError(result3, err5, 'Unable to add proof message');
      }
    }

    calloc.free(err5);

    final proofSize = bbs.bbsCreateProofContextSize(handle);
    Tools.logDebug('proofSize: $proofSize');
    if (proofSize <= 0) {
      throw Exception('Invalid proof size from bbs_create_proof_size()');
    }

    final proofPtr = calloc<ByteBuffer>();
    final err6 = calloc<ExternError>();

    final result4 = bbs.bbsCreateProofContextFinish(handle, proofPtr, err6);
    Tools.logDebug('result bbsCreateProofContextFinish: $result4');
    if (result4 != 0) {
      calloc.free(proofPtr);
      throwIfError(result4, err6, 'Unable to create proof');
    }

    calloc.free(err6);

    final proofBytes = proofPtr.ref.data.asTypedList(proofPtr.ref.len);

    calloc.free(proofPtr);

    return Future.value(Uint8List.fromList(proofBytes));
  }

  /// Creates a BBS+ proof using a BLS public key, nonce, signature, and a list of proof messages.
  ///
  /// This function utilizes FFI calls to interact with the native BBS+ library to generate a cryptographic proof.
  /// Given the BLS public key, the function first converts it to a BBS public key before beginning the proof creation process.
  Future<Uint8List> blsCreateProof({
    required Uint8List blsPublicKey,
    required Uint8List nonce,
    required Uint8List signature,
    required List<ProofMessage> messages,
  }) async {
    // Convert public
    final bbsPublicKey = await BbsFlutter.blsPublicToBbsPublicKey(
      blsPublicKey: blsPublicKey,
      messages: messages.length,
    );

    Tools.logDebug('📏 bbsPublicKey.length = ${bbsPublicKey.length}');

    Tools.logDebug('BBS public key (base64): ${base64.encode(bbsPublicKey)}');

    final err1 = calloc<ExternError>();
    final handle = bbs.bbsCreateProofContextInit(err1);
    Tools.logDebug('handle init: $handle');
    if (handle == 0) {
      throw Exception('Unable to create proof context');
    }
    calloc.free(err1);

    final publicKeyPtr = ByteArrayHelper.allocate(bbsPublicKey);

    final err2 = calloc<ExternError>();

    final result = bbs.bbsCreateProofContextSetPublicKey(
      handle,
      publicKeyPtr.ref,
      err2,
    );
    Tools.logDebug('result bbsCreateProofContextSetPublicKey: $result');

    calloc.free(publicKeyPtr.ref.data);
    calloc.free(publicKeyPtr);

    if (result != 0) {
      throwIfError(result, err2, 'Unable to set public key');
    }

    calloc.free(err2);

    final noncePtr = ByteArrayHelper.allocate(nonce); // nonce is Uint8List
    final err3 = calloc<ExternError>();

    final result1 = bbs.bbsCreateProofContextSetNonceBytes(
      handle,
      noncePtr.ref,
      err3,
    );
    Tools.logDebug('result bbsCreateProofContextSetNonceBytes: $result1');

    calloc.free(noncePtr.ref.data);
    calloc.free(noncePtr);

    if (result1 != 0) {
      throwIfError(result1, err3, 'Unable to set nonce');
    }

    calloc.free(err3);

    final sigPtr = ByteArrayHelper.allocate(signature); // signature: Uint8List
    final err4 = calloc<ExternError>();

    final result2 = bbs.bbsCreateProofContextSetSignature(
      handle,
      sigPtr.ref,
      err4,
    );
    Tools.logDebug('result bbsCreateProofContextSetSignature: $result2');

    calloc.free(sigPtr.ref.data);
    calloc.free(sigPtr);

    if (result2 != 0) {
      throwIfError(result2, err4, 'Unable to set signature');
    }

    calloc.free(err4);

    final err5 = calloc<ExternError>();

    for (final msg in messages) {
      final msgPtr = ByteArrayHelper.allocate(msg.message);
      final blindPtr = ByteArrayHelper.allocate(msg.blindingFactor);

      final result3 = bbs.bbsCreateProofContextAddProofMessageBytes(
        handle,
        msgPtr.ref,
        msg.type,
        blindPtr.ref,
        err5,
      );

      calloc.free(msgPtr.ref.data);
      calloc.free(msgPtr);
      calloc.free(blindPtr.ref.data);
      calloc.free(blindPtr);

      if (result3 != 0) {
        throwIfError(result3, err5, 'Unable to add proof message');
      }
    }

    calloc.free(err5);

    final proofSize = bbs.bbsCreateProofContextSize(handle);
    Tools.logDebug('proofSize: $proofSize');
    if (proofSize <= 0) {
      throw Exception('Invalid proof size from bbs_create_proof_size()');
    }

    final proofPtr = calloc<ByteBuffer>();
    final err6 = calloc<ExternError>();

    final result4 = bbs.bbsCreateProofContextFinish(handle, proofPtr, err6);
    Tools.logDebug('result bbsCreateProofContextFinish: $result4');
    if (result4 != 0) {
      calloc.free(proofPtr);
      throwIfError(result4, err6, 'Unable to create proof');
    }

    calloc.free(err6);

    final proofBytes = proofPtr.ref.data.asTypedList(proofPtr.ref.len);

    calloc.free(proofPtr);

    return Future.value(Uint8List.fromList(proofBytes));
  }

  /// Creates a selective disclosure proof using a BLS public key, nonce, signature, and a set of messages.
  ///
  /// Selective disclosure proofs allow for revealing only specific messages while keeping others hidden.
  /// This function prepares the input messages accordingly (marking them as revealed or hidden) and
  /// generates a cryptographic proof via `blsCreateProofFFI`.
  Future<String> createSelectiveDisclosureProofBlsFFI(
    Uint8List publicKey,
    Uint8List nonce,
    Uint8List signature,
    List<Uint8List> messages,
    Set<int> revealedIndices,
  ) {
    final proofMessages = <ProofMessage>[];

    for (int i = 0; i < messages.length; i++) {
      final type = revealedIndices.contains(i)
          ? ProofMessageType.Revealed
          : ProofMessageType.HiddenProofSpecificBlinding;

      proofMessages.add(ProofMessage(
        type,
        messages[i],
        Uint8List(0), // empty blinding factor
      ));
    }

    return Future.sync(() async {
      final proof = await blsCreateProofFFI(
        publicKey: publicKey,
        nonce: nonce,
        signature: signature,
        messages: proofMessages,
      );

      final encoded = base64Url.encode(proof).replaceAll('=', '');
      return 'u$encoded'; // prepend "u"
    });
  }

  /// Creates a selective disclosure proof using a BLS public key, nonce, signature, and a set of messages.
  ///
  /// This function enables selective disclosure by allowing specific messages to be "revealed" in the proof
  /// while keeping the rest "hidden." It prepares messages as `ProofMessage` objects marked as revealed or hidden,
  /// generates the proof using `BbsFlutter.blsCreateProof`, and returns a Base64 URL-encoded proof string.
  Future<String> createSelectiveDisclosureProofBls(
    Uint8List publicKey,
    Uint8List nonce,
    Uint8List signature,
    List<Uint8List> messages,
    Set<int> revealedIndices,
  ) {
    final proofMessages = <ProofMessage>[];

    for (int i = 0; i < messages.length; i++) {
      final type = revealedIndices.contains(i)
          ? ProofMessageType.Revealed
          : ProofMessageType.HiddenProofSpecificBlinding;

      proofMessages.add(ProofMessage(
        type,
        messages[i],
        Uint8List(0), // empty blinding factor
      ));
    }

    return Future.sync(() async {
      final proof = await BbsFlutter.blsCreateProof(
        publicKey: publicKey,
        nonce: nonce,
        signature: signature,
        messages: proofMessages,
      );

      final encoded = base64Url.encode(proof).replaceAll('=', '');
      return 'u$encoded'; // prepend "u"
    });
  }

  /// Converts a BLS public key into a BBS public key.
  ///
  /// BLS public keys are message-agnostic, while BBS public keys are message-specific.
  /// This function generates a BBS public key from a BLS public key for a given number of messages.
  /// It leverages an FFI call to the native BBS+ library for the conversion, ensuring compatibility
  /// with the BBS+ cryptographic protocols.
  Uint8List blsPublicToBbsPublicKey(Uint8List blsPublicKey, int messageCount) {
    final seedPtr = ByteArrayHelper.allocate(blsPublicKey);
    final out = calloc<ByteBuffer>();
    final err = calloc<ExternError>();

    final result =
        bbs.blsPublicKeyToBbsKey(seedPtr.ref, messageCount, out, err);

    if (result != 0) {
      final msg = err.ref.message == nullptr
          ? 'Unknown error'
          : err.ref.message.toDartString();
      calloc.free(err);
      calloc.free(out);
      calloc.free(seedPtr.ref.data);
      calloc.free(seedPtr);
      throw Exception('blsPublicKeyToBbsKey failed: $msg');
    }

    final bbsKey = out.ref.data.asTypedList(out.ref.len);

    calloc.free(err);
    calloc.free(out);
    calloc.free(seedPtr.ref.data);
    calloc.free(seedPtr);

    return Uint8List.fromList(bbsKey);
  }

  /// Decodes a Base64 URL-encoded BBS+ signature back into its original binary form.
  ///
  /// The BBS+ signature string often includes a leading character (e.g., `u`) for formatting purposes.
  /// This function removes the leading character, normalizes the string as needed, and decodes it
  /// back into a [Uint8List] representation of the BBS+ signature.
  Uint8List decodeBbsSignature(String bbsSignature) {
    final base64Body = bbsSignature.substring(1); // remove leading "u"
    final normalized =
        base64Body.padRight((base64Body.length + 3) ~/ 4 * 4, '=');
    return base64Url.decode(normalized);
  }

  /// Generates a BbsBls signature proof using FFI for selective message disclosure.
  ///
  /// The function creates a cryptographic proof using a BBS+ signature and public key.
  /// Messages specified by the `revealIndex` list are revealed, while others remain hidden.
  /// A random nonce is generated to ensure proof uniqueness.
  Future<Proof> setBbsBlsProofFFI(
    List<Uint8List> messages,
    Uint8List publicKey,
    String bbsSignature,
    List<int> revealIndex,
    String id,
  ) async {
    GeneratorUtils generatorUtil = GeneratorUtils();
    final nonce = generatorUtil.generateRandomNonce(32);
    final revealIndexSet = revealIndex.toSet();

    // Decode bbsSignature (skipping first char, as in Java)
    final decodedBbsSignature =
        base64Url.decode(encryption.formatDecode(bbsSignature.substring(1)));

    String proofValue;
    try {
      proofValue = await createSelectiveDisclosureProofBlsFFI(
        publicKey,
        nonce,
        decodedBbsSignature,
        messages,
        revealIndexSet,
      );
    } catch (e) {
      throw Exception("Proof generation error: $e");
    }

    // ISO8601 UTC time
    final created = DateTime.now().toUtc().toIso8601String();

    final proof = Proof()
      ..type = "BbsBlsSignatureProof2020"
      ..created = created
      ..verificationMethod = id
      ..proofPurpose = "assertionMethod"
      ..nonce = "u${base64UrlEncode(nonce)}"
      ..proofValue = proofValue;

    return proof;
  }

  /// Generates a BbsBls signature proof using the BbsFlutter library for selective message disclosure.
  ///
  /// Similar to [setBbsBlsProofFFI], this function creates cryptographic proofs using a BBS+ signature
  /// and public key. Messages specified in the `revealIndex` list are publicly revealed in the proof,
  /// while others remain hidden. A random nonce is generated to ensure uniqueness.
  Future<Proof> setBbsBlsProof(
    List<Uint8List> messages,
    Uint8List publicKey,
    String bbsSignature,
    List<int> revealIndex,
    String id,
  ) async {
    GeneratorUtils generatorUtil = GeneratorUtils();
    final nonce = generatorUtil.generateRandomNonce(32);
    final revealIndexSet = revealIndex.toSet();

    // Decode bbsSignature (skipping first char, as in Java)
    final decodedBbsSignature =
        base64Url.decode(encryption.formatDecode(bbsSignature.substring(1)));

    String proofValue;
    try {
      proofValue = await createSelectiveDisclosureProofBls(
        publicKey,
        nonce,
        decodedBbsSignature,
        messages,
        revealIndexSet,
      );
    } catch (e) {
      throw Exception("Proof generation error: $e");
    }

    // ISO8601 UTC time
    final created = DateTime.now().toUtc().toIso8601String();

    final proof = Proof()
      ..type = "BbsBlsSignatureProof2020"
      ..created = created
      ..verificationMethod = id
      ..proofPurpose = "assertionMethod"
      ..nonce = "u${base64UrlEncode(nonce)}"
      ..proofValue = proofValue;

    return proof;
  }

  /// Throws an exception if a BBS+ library operation results in an error.
  ///
  /// This utility function is used to check the result of FFI calls to the BBS+ library.
  /// If the operation fails (i.e., `result` is non-zero), the function reads the error message from the
  /// provided [ExternError] pointer and throws an [Exception] with the appropriate error description.
  void throwIfError(int result, Pointer<ExternError> err, String label) {
    if (result != 0) {
      final msg = err.ref.message == nullptr
          ? 'Unknown error'
          : err.ref.message.toDartString();
      calloc.free(err);
      throw Exception('$label: $msg');
    }
  }
}
