import 'dart:convert';
import 'dart:typed_data';

import 'package:bs58/bs58.dart';
import 'package:crypto/crypto.dart';
import 'package:pinenacl/tweetnacl.dart';
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';
import 'package:pointycastle/export.dart';
// import 'package:pointycastle/export.dart' as pc;


/// Unpacks an authenticated encrypted message (ECDH-1PU)
///
/// Equivalent of JS `unpackAuthCrypt`
Map<String, dynamic> unpackAuthCrypt({
  required Map<String, dynamic> jwe,
  required String receiverPrivKeyStr,
  required String senderPubKeyBase58,
}) {
  final encryptionUtils = EncryptionUtils();

  // Remove leading "z" from sender pubkey if present
  if (senderPubKeyBase58.startsWith('z') && senderPubKeyBase58.length == 45) {
    senderPubKeyBase58 = senderPubKeyBase58.substring(1);
  }

  try {
    // Parse protected header
    final protectedFixed = fixBase64Padding(jwe['protected'] as String);
    final decodedHeader = base64Url.decode(protectedFixed);
    final authHeader = jsonDecode(
      utf8.decode(decodedHeader),
    );

    // Parse receiver private key
    final receiverRawPrivateKey =
        encryptionUtils.parsePrivateKey(receiverPrivKeyStr);

    if (receiverRawPrivateKey.length != 32) {
      throw Exception('Receiver Private key must be 32 bytes for X25519!');
    }

    // Derive X25519 keypair from Ed25519 seed
    final pk = Uint8List(32);
    final sk = Uint8List(64);
    TweetNaCl.crypto_sign_keypair(pk, sk, receiverRawPrivateKey);

    final receiverPrivateKey = sk.sublist(0, 32);

    // Decode JWE fields
    final ciphertextFixed = fixBase64Padding(jwe['ciphertext'] as String);
    final ciphertextBytes = base64Url.decode(ciphertextFixed);
    final tagFixed = fixBase64Padding(jwe['tag'] as String);
    final tagBytes = base64Url.decode(tagFixed);
    final ivFixed = fixBase64Padding(jwe['iv'] as String);
    final ivBytes = base64Url.decode(ivFixed);

    final ephemeralPubKeyFixed = fixBase64Padding(authHeader['epk']['x'] as String);
    final ephemeralPubKeyBytes =
        base64Url.decode(ephemeralPubKeyFixed);
    final senderPubKeyBytes = base58.decode(senderPubKeyBase58);

    // Perform ECDH
    final sharedSecret1 = performECDH(receiverPrivateKey, senderPubKeyBytes);
    final sharedSecret2 = performECDH(receiverPrivateKey, ephemeralPubKeyBytes);

    final combinedSharedSecret = concatenate(sharedSecret1, sharedSecret2);

    const encMethod = 'A256CBC-HS512';
    final derivedKey = deriveKey(
      combinedSharedSecret,
      encMethod,
      authHeader['apu'] as String,
      authHeader['apv'] as String,
    );

    final encKey = derivedKey.sublist(0, 32);
    final macKey = derivedKey.sublist(32, 64);

    // Compute HMAC
    final hmacSha512 = Hmac(sha512, macKey);
    final computedMac = hmacSha512.convert(ciphertextBytes).bytes;

    if (!listEquals(computedMac, tagBytes)) {
      throw Exception('HMAC verification failed');
    }

    // AES-256-CBC decrypt
    final decryptedBytes = decryptAES_CBC(ciphertextBytes, encKey, ivBytes);
    final decryptedString = utf8.decode(decryptedBytes);

    return jsonDecode(decryptedString);
  } catch (e) {
    throw Exception('Decryption failed: $e');
  }
}

/// Unpacks an anonymous encrypted message (ECDH-ES)
Map<String, dynamic> unpackAnonCrypt({
  required Map<String, dynamic> jwe,
  required String receiverPrivKeyStr,
}) {
  final encryptionUtils = EncryptionUtils();

  try {
    final protectedFixed = fixBase64Padding(jwe['protected'] as String);
    final decodedHeader = base64Url.decode(protectedFixed);

    final anonHeader = jsonDecode(
      utf8.decode(decodedHeader),
    );

    final receiverRawPrivateKey =
        encryptionUtils.parsePrivateKey(receiverPrivKeyStr);

    if (receiverRawPrivateKey.length != 32) {
      throw Exception('Receiver Private key must be 32 bytes for X25519!');
    }

    final pk = Uint8List(32);
    final sk = Uint8List(64);
    TweetNaCl.crypto_sign_keypair(pk, sk, receiverRawPrivateKey);

    final receiverPrivateKey = sk.sublist(0, 32);

    final ciphertextBytesFixed = fixBase64Padding(jwe['ciphertext'] as String);
    final ciphertextBytes = base64Url.decode(ciphertextBytesFixed);
    final tagBytesFixed = fixBase64Padding(jwe['tag'] as String);
    final tagBytes = base64Url.decode(tagBytesFixed);
    final ivBytesFixed = fixBase64Padding(jwe['iv'] as String);
    final ivBytes = base64Url.decode(ivBytesFixed);

    final ephemeralPubKeyBytesFixed = fixBase64Padding(anonHeader['epk']['x'] as String);
    final ephemeralPubKeyBytes =
        base64Url.decode(ephemeralPubKeyBytesFixed);

    final sharedSecret = performECDH(receiverPrivateKey, ephemeralPubKeyBytes);

    const encMethod = 'A256CBC-HS512';
    final derivedKey = deriveKey(
      sharedSecret,
      encMethod,
      null,
      anonHeader['apv'] as String,
    );

    final encKey = derivedKey.sublist(0, 32);
    final macKey = derivedKey.sublist(32, 64);

    final hmacSha512 = Hmac(sha512, macKey);
    final computedMac = hmacSha512.convert(ciphertextBytes).bytes;

    if (!listEquals(computedMac, tagBytes)) {
      throw Exception('HMAC verification failed');
    }

    final decryptedBytes = decryptAES_CBC(ciphertextBytes, encKey, ivBytes);
    final decryptedString = utf8.decode(decryptedBytes);

    return jsonDecode(decryptedString);
  } catch (e) {
    throw Exception('Decryption failed: $e');
  }
}

/// Compares two lists for equality (like Buffer.equals)
bool listEquals(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

Uint8List decryptAES_CBC(Uint8List ciphertext, Uint8List key, Uint8List iv) {
  final cipher = CBCBlockCipher(AESEngine())
    ..init(
      false, // decrypt
      ParametersWithIV(KeyParameter(key), iv),
    );

  final paddedPlaintext = Uint8List(ciphertext.length);
  for (int offset = 0; offset < ciphertext.length; offset += 16) {
    cipher.processBlock(ciphertext, offset, paddedPlaintext, offset);
  }

  return removePkcs7Padding(paddedPlaintext);
}
Uint8List removePkcs7Padding(Uint8List data) {
  final padLength = data.last;
  return data.sublist(0, data.length - padLength);
}

String fixBase64Padding(String str) {
  final mod4 = str.length % 4;
  if (mod4 > 0) {
    return str + '=' * (4 - mod4);
  }
  return str;
}
