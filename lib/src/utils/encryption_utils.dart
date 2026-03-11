import 'dart:convert';

import 'package:bs58/bs58.dart';
import 'package:convert/convert.dart';
import 'package:cryptography/cryptography.dart' as crypto;
import 'package:hex/hex.dart';
import 'package:pinenacl/digests.dart';
import 'package:pinenacl/ed25519.dart';
import 'package:zetrix_vc_flutter/src/models/account/create_account.dart';
import 'package:zetrix_vc_flutter/src/models/transaction/sign_blob.dart';
import 'package:zetrix_vc_flutter/src/models/transaction/sign_message.dart';
import 'package:zetrix_vc_flutter/src/models/vc/verifiable_presentation.dart';
import 'package:zetrix_vc_flutter/src/utils/encoding_utils.dart';
import 'package:zetrix_vc_flutter/src/utils/helpers.dart';

/// A utility class designed for encryption-related operations,
/// such as key pair generation, public/private key manipulation, and address generation.
class EncryptionUtils {
  /// Generates a cryptographic key pair consisting of a private key, public key, address, and DID.
  Future<CreateAccount> generateKeyPair() async {
    Uint8List rawPrivateKey = PineNaClUtils.randombytes(32);

    String privateKey = generatePrivateKey(rawPrivateKey);
    String publicKey = await generatePublicKey(rawPrivateKey);
    String address = getAddress(publicKey);
    String did = await generateDid(rawPrivateKey);

    CreateAccount keypair = CreateAccount();
    keypair.privateKey = privateKey;
    keypair.publicKey = publicKey;
    keypair.address = address;
    keypair.did = did;

    return keypair;
  }

  /// Generates the encryption public key associated with the input [privateKey].
  Future<String> getEncPublicKey(String privateKey) async {
    Uint8List rawPriv = parsePrivateKey(privateKey);

    String pubKey = await generatePublicKey(rawPriv);

    return pubKey;
  }

  /// Generates an encoded private key from a [Uint8List] raw private key.
  String generatePrivateKey(Uint8List rawPrivKey) {
    Uint8List prefixBytes = Uint8List.fromList([0xda, 0x37, 0x9f, 0x1]);
    // Tools.logDebug('raw priv key: $randBytes');
    BytesBuilder byteBuilder = BytesBuilder(copy: true);
    //Add prefixBytes bytes
    byteBuilder.add(prefixBytes);
    //Add raw privkey bytes
    byteBuilder.add(rawPrivKey);
    //Add version byte
    byteBuilder.addByte(0);

    Uint8List seedHash2Bytes = Hash.sha256(Hash.sha256(byteBuilder.toBytes()));

    Uint8List checksumBytes = seedHash2Bytes.sublist(0, 4);

    byteBuilder.add(checksumBytes);

    Uint8List privKeyFinalBytes = byteBuilder.toBytes();

    String privateKey = base58.encode(privKeyFinalBytes);

    return privateKey;
  }

  /// Generates an encoded public key from a given [seed] (raw private key).
  Future<String> generatePublicKey(Uint8List seed) async {
    var algorithm = crypto.Ed25519();
    var rawKeypair = await algorithm.newKeyPairFromSeed(seed);
    crypto.SimplePublicKey pubKeybytes = await rawKeypair.extractPublicKey();

    var rawPubKeybytes = pubKeybytes.bytes;

    Uint8List pubKeyPrefix = Uint8List.fromList([0xb0, 0x1]);

    BytesBuilder pubKeyByteBuilder = BytesBuilder(copy: true);
    pubKeyByteBuilder.add(pubKeyPrefix);
    pubKeyByteBuilder.add(rawPubKeybytes);
    Uint8List pubKeyHash2 =
        Hash.sha256(Hash.sha256(pubKeyByteBuilder.toBytes()));

    Uint8List pubKeyChecksum = pubKeyHash2.sublist(0, 4);
    pubKeyByteBuilder.add(pubKeyChecksum);
    Uint8List pubKeyFinal = pubKeyByteBuilder.toBytes();

    String pubKeyString = hex.encode(pubKeyFinal);

    return pubKeyString;
  }

  /// Generates the raw public key (unencoded) associated with the given [seed].
  Future<String> generatePublicKeyRaw(Uint8List seed) async {
    var algorithm = crypto.Ed25519();
    var rawKeypair = await algorithm.newKeyPairFromSeed(seed);
    crypto.SimplePublicKey pubKeybytes = await rawKeypair.extractPublicKey();

    var rawPubKeybytes = pubKeybytes.bytes;

    BytesBuilder pubKeyByteBuilder = BytesBuilder(copy: true);
    pubKeyByteBuilder.add(rawPubKeybytes);

    Uint8List pubKeyFinal = pubKeyByteBuilder.toBytes();

    String rawPubKeyString = hex.encode(pubKeyFinal);

    return rawPubKeyString;
  }

  /// Generates the address associated with a given encoded [encPublicKey].
  String getAddress(String encPublicKey) {
    Uint8List rawpubKey = parsePublicKey(encPublicKey);

    //Generate address
    BytesBuilder pubkeyRawBuilder = BytesBuilder(copy: true);
    pubkeyRawBuilder.add(rawpubKey);

    Uint8List rawPubKey = pubkeyRawBuilder.toBytes();
    Uint8List addressHash = Hash.sha256(rawPubKey);
    Uint8List tailBytes = addressHash.sublist(12, addressHash.length);

    Uint8List addressPrefixByte = Uint8List.fromList([0xf0, 0x26, 0x1]);
    BytesBuilder addressByteBuilder = BytesBuilder(copy: true);
    addressByteBuilder.add(addressPrefixByte);
    addressByteBuilder.add(tailBytes);

    Uint8List shaTwiceAddressByte =
        Hash.sha256(Hash.sha256(addressByteBuilder.toBytes()));
    Uint8List addressChecksumByte = shaTwiceAddressByte.sublist(0, 4);
    addressByteBuilder.add(addressChecksumByte);
    String address = base58.encode(addressByteBuilder.toBytes());

    return address;
  }

  /// Generates a decentralized identifier (DID) from a given raw private key.
  ///
  /// The method generates a DID based on the `Zetrix Identifier (zid)` format by
  /// first deriving the raw public key from the provided raw private key and then
  /// formatting it as `"did:zid:<rawPublicKey>"`.
  Future<String> generateDid(Uint8List rawPrivateKey) async {
    final raw = await generatePublicKeyRaw(rawPrivateKey);
    return "did:zid:$raw";
  }

  /// Checks if the encoded private key is valid.
  ///
  /// This method validates the encoded private key by performing the
  /// following checks:
  /// - Ensures the key is a non-empty [String].
  /// - Decodes the key using Base58 encoding.
  /// - Verifies specific byte values at designated positions (e.g., prefix bytes and compression bit).
  /// - Confirms the checksum is valid by recalculating it from the decoded data.
  bool checkEncPrivateKey(String encPrivateKey) {
    try {
      if (encPrivateKey.isEmpty) {
        return false;
      }

      Uint8List decoded = base58.decode(encPrivateKey);

      if (decoded[0] != 0xda ||
          decoded[1] != 0x37 ||
          decoded[2] != 0x9f ||
          decoded[3] > 4 ||
          decoded[3] < 1) {
        return false;
      }

      int privateLength = decoded.length;

      if (decoded[privateLength - 5] != 0x00) {
        return false;
      }

      Uint8List addHeaderPriv = decoded.sublist(0, privateLength - 4);
      Uint8List privHash = decoded.sublist(privateLength - 4, privateLength);
      Uint8List calHash = Hash.sha256(Hash.sha256(addHeaderPriv));
      Uint8List checkSum = calHash.sublist(0, 4);

      if (privHash.join() != checkSum.join()) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Validates the encoded public key.
  ///
  /// This method performs validation on the provided encoded public key string by:
  /// - Ensuring the key is a non-empty [String].
  /// - Decoding the key using hexadecimal decoding.
  /// - Verifying specific byte values in the decoded public key (e.g., prefix bytes and type).
  /// - Checking the checksum at the end of the public key.
  bool checkEncPublicKey(String encPublicKey) {
    try {
      if (encPublicKey.isEmpty) {
        return false;
      }

      var decoded = hex.decode(encPublicKey.trim());
      Uint8List publicKeyBytes = Uint8List.fromList(decoded);

      if (publicKeyBytes[0] != 0xb0 ||
          publicKeyBytes[1] > 4 ||
          publicKeyBytes[1] < 1) {
        return false;
      }

      int publicLength = publicKeyBytes.length;

      Uint8List addHeaderPub = publicKeyBytes.sublist(0, publicLength - 4);
      Uint8List pubHash =
          publicKeyBytes.sublist(publicLength - 4, publicLength);
      Uint8List calHash = Hash.sha256(Hash.sha256(addHeaderPub));
      Uint8List checkSum = calHash.sublist(0, 4);

      if (pubHash.join() != checkSum.join()) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Validates the encoded address.
  ///
  /// This method checks whether the given encoded address is valid by:
  /// - Ensuring the input is a non-empty string.
  /// - Decoding the address using Base58 decoding.
  /// - Verifying the prefix bytes and length of the decoded address.
  /// - Validating the checksum to ensure integrity.
  bool checkAddress(String address) {
    try {
      if (address.isEmpty) {
        return false;
      }

      Uint8List addressBytes = base58.decode(address.trim());
      Uint8List head = Uint8List.fromList([0xf0, 0x26, 0x1]);

      if (addressBytes[0] != head[0] ||
          addressBytes[1] != head[1] ||
          addressBytes[2] != head[2] ||
          addressBytes.length != 27) {
        return false;
      }

      int addressByteLength = addressBytes.length;
      Uint8List addrHead = addressBytes.sublist(0, addressByteLength - 4);
      Uint8List addrHash =
          addressBytes.sublist(addressByteLength - 4, addressByteLength);
      Uint8List testHash = Hash.sha256(Hash.sha256(addrHead));
      Uint8List checkSum = testHash.sublist(0, 4);

      if (addrHash.join() != checkSum.join()) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Parses and validates an encoded private key.
  ///
  /// This function decodes an encoded private key using Base58 and performs multiple
  /// validation checks, including header bytes, type, compression bit, and checksum integrity.
  /// If the validation passes, it extracts and returns the raw private key bytes.
  Uint8List parsePrivateKey(String encPrivateKey) {
    Uint8List rawByte = base58.decode(encPrivateKey);

    if (rawByte[0] != 0xda || rawByte[1] != 0x37 || rawByte[2] != 0x9f) {
      throw Exception('private key $encPrivateKey is invalid, header is wrong');
    }

    if (rawByte[3] > 4 || rawByte[3] < 1) {
      throw Exception('private key $encPrivateKey is invalid, type is wrong');
    }

    int privateLength = rawByte.length;

    if (rawByte[privateLength - 5] != 0x00) {
      throw Exception(
          'private key $encPrivateKey is invalid, compression bit is wrong');
    }

    Uint8List addHeaderPriv = rawByte.sublist(0, privateLength - 4);
    Uint8List privHash = rawByte.sublist(privateLength - 4, privateLength);
    Uint8List calHash = Hash.sha256(Hash.sha256(addHeaderPriv));
    Uint8List checkSum = calHash.sublist(0, 4);

    if (privHash.join() != checkSum.join()) {
      throw Exception('private key $encPrivateKey is invalid, hash is wrong');
    }
    Uint8List rawPriv = rawByte.sublist(4, (rawByte.length) - 5);
    return rawPriv;
  }

  /// Parses and validates an encoded public key.
  ///
  /// This function decodes an encoded public key and performs multiple
  /// validation checks, including header bytes, type, and checksum integrity.
  /// If the validation is successful, it extracts and returns the raw public key bytes.
  Uint8List parsePublicKey(String encPublicKey) {
    var rawBytes = hex.decode(encPublicKey);
    Uint8List publicKeyBytes = Uint8List.fromList(rawBytes);
    if (publicKeyBytes[0] != 0xb0) {
      throw Exception('public key $encPublicKey is invalid, header is wrong');
    }
    if (publicKeyBytes[1] > 4 || publicKeyBytes[1] < 1) {
      throw Exception('public key $encPublicKey is invalid, type is wrong');
    }
    int publicLength = publicKeyBytes.length;

    Uint8List addHeaderPub = publicKeyBytes.sublist(0, publicLength - 4);
    Uint8List pubHash = publicKeyBytes.sublist(publicLength - 4, publicLength);
    Uint8List calHash = Hash.sha256(Hash.sha256(addHeaderPub));
    Uint8List checkSum = calHash.sublist(0, 4);
    if (pubHash.join() != checkSum.join()) {
      throw Exception('public key $encPublicKey is invalid, hash is wrong');
    }

    Uint8List rawPub = publicKeyBytes.sublist(2, publicKeyBytes.length - 4);
    return rawPub;
  }

  /// Signs a message with the provided private key.
  ///
  /// This function takes a message and an encoded private key, performs validation, and then uses
  /// the Ed25519 cryptographic algorithm to sign the message. The resulting signature and the
  /// corresponding public key are returned in a `SignBlob` object.
  Future<SignBlob> signBlob(String msg, String privateKey) async {
    if (msg.isEmpty || privateKey.isEmpty) {
      throw Exception('require message or encPrivateKey');
    }

    Uint8List msgByte =
        EncodingUtils.hexStringToBytes(msg); 

    Uint8List privateKeyByte = parsePrivateKey(privateKey);

    final algorithm = crypto.Ed25519();
    // Generate a key pair
    final keyPair = await algorithm.newKeyPairFromSeed(privateKeyByte);

    // Sign a message
    final signature = await algorithm.sign(
      msgByte,
      keyPair: keyPair,
    );

    SignBlob resp = SignBlob();
    resp.publicKey = await getEncPublicKey(privateKey);
    resp.signBlob = HEX.encode(signature.bytes);

    return resp;
  }

  /// Signs a message with the provided private key.
  ///
  /// This function takes a message and an encoded private key, performs validation,
  /// and uses the Ed25519 cryptographic algorithm to generate a signature for the message.
  /// It returns a `SignMessage` object containing the encoded public key and the generated signature.
  Future<SignMessage> signMessage(String msg, String privateKey) async {
    if (msg.isEmpty || privateKey.isEmpty) {
      throw Exception('require message or encPrivateKey');
    }

    Uint8List msgByte = utf8.encode(msg);

    Uint8List privateKeyByte = parsePrivateKey(privateKey);

    final algorithm = crypto.Ed25519();
    // Generate a key pair
    final keyPair = await algorithm.newKeyPairFromSeed(privateKeyByte);

    // Sign a message
    final signature = await algorithm.sign(
      msgByte,
      keyPair: keyPair,
    );

    SignMessage resp = SignMessage();
    resp.publicKey = await getEncPublicKey(privateKey);
    resp.signData = HEX.encode(signature.bytes);

    return resp;
  }

  /// Verifies a message's signature using the provided public key.
  ///
  /// This function takes the signature, message, and an encoded public key, and validates
  /// the signature using the Ed25519 cryptographic algorithm. It returns a boolean
  /// indicating whether the signature is valid.
  Future<bool> verify(
      List<int> signatureData, List<int> msg, String encPublicKey) async {
    Uint8List bytes = parsePublicKey(encPublicKey);

    final algorithm = crypto.Ed25519();

    crypto.SimplePublicKey publicKey =
        crypto.SimplePublicKey(bytes, type: crypto.KeyPairType.ed25519);

    crypto.Signature signature =
        crypto.Signature(signatureData, publicKey: publicKey);
    bool isValid = await algorithm.verify(
      msg,
      signature: signature,
    );

    return isValid;
  }

  /// Signs a message using the provided private key.
  ///
  /// This function uses the NaCl cryptographic library to sign a message
  /// with the given private key and returns the signed message object.
  SignedMessage naclSign(String privateKey, Uint8List message) {
    Uint8List rawPriv = parsePrivateKey(privateKey);

    // Generate a new random signing key
    final signingKey = SigningKey(seed: rawPriv);

    SignedMessage signed = signingKey.sign(message);

    return signed;
  }

  /// Verifies a message and its signature using the provided public key.
  ///
  /// This function uses the NaCl cryptographic library to verify the given
  /// signature, message, and encoded public key. It returns a boolean indicating
  /// whether the verification succeeded.
  bool naclVerify(
      SignatureBase signature, Uint8List message, String encPublicKey) {
    Uint8List pubByte = parsePublicKey(encPublicKey);
    final verifyKey = VerifyKey(pubByte);

    return verifyKey.verify(signature: signature, message: message);
  }

  /// Verifies a JWS (JSON Web Signature) using EDDSA and the provided public key.
  ///
  /// This function takes a JWS string and a public key (in hexadecimal format),
  /// splits the JWS into its three parts (header, payload, and signature),
  /// and verifies the EDDSA signature based on the decoded message and public key.
  Future<bool> verifyEddsaSignature(String jws, String publicKeyHex) async {
    final parts = jws.split('.');
    if (parts.length != 3) throw FormatException("Invalid JWS");
    final String msg = Helpers.formatJwsSignData(parts[0], parts[1]);
    final String signature = parts[2];

    List<int> signatureBytes = HEX.decode(Helpers.base64UrlDecodeString(signature));
    List<int> messageByte = EncodingUtils.hexStringToBytes(EncodingUtils.utfToHex(msg));

    return verify(signatureBytes, messageByte, publicKeyHex);
  }

  /// Decodes a Base64Url string to a Base64-compatible format.
  ///
  /// This function converts a Base64Url-encoded string into a standard Base64
  /// format string by replacing URL-safe characters (`-` and `_`) with
  /// Base64 characters (`+` and `/`) and padding it appropriately for valid decoding.
  String formatDecode(String arg) {
    String s = arg;
    s = s.replaceAll('-', '+').replaceAll('_', '/');

    switch (s.length % 4) {
      case 0:
        break;
      case 2:
        s += '==';
        break;
      case 3:
        s += '=';
        break;
      case 1:
      default:
        return "";
    }

    return s;
  }

  /// Encodes a Verifiable Presentation (VP) into a Base64 string.
  ///
  /// This function takes a [VerifiablePresentation] (VP), converts it to a JSON
  /// structure, minifies the resulting JSON string, and encodes it into a Base64 string.
  String encodeVpToBase64(VerifiablePresentation vp) {
    // Convert to JSON map
    final jsonMap = vp.toJson();

    // Minify JSON string (no indentation)
    final minifiedJsonString = json.encode(jsonMap);

    // Encode to Base64
    final base64Encoded = base64Encode(utf8.encode(minifiedJsonString));

    return base64Encoded;
  }
}
