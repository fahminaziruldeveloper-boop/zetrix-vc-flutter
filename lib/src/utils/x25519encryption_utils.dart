import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:pinenacl/tweetnacl.dart';
import 'package:pointycastle/export.dart' as pc;
import 'package:zetrix_vc_flutter/src/models/encryption/ephemeral_key_pair.dart';
import 'package:zetrix_vc_flutter/src/models/encryption/x25519_key_pair.dart';

/// ------------------------------------------------------------
/// Crypto Utilities for ECDH, HKDF, AES Encryption, and JWE Headers
/// ------------------------------------------------------------

/// Computes the Agreement Party V (APV) value from a list of `kid`s.
///
/// - Sorts the list alphabetically.
/// - Concatenates them with "." separator if there’s more than one.
/// - Computes SHA-256 hash.
/// - Encodes result in Base64URL without padding.
///
/// Example:
/// ```dart
/// final apv = computeApv(['kid1', 'kid2']);
/// ```
String computeApv(List<String> kidList) {
  if (kidList.isEmpty) {
    throw ArgumentError("kidList must not be null or empty");
  }

  final sortedKidList = List<String>.from(kidList)..sort();
  final concatenatedKids =
      sortedKidList.length == 1 ? sortedKidList[0] : sortedKidList.join('.');

  final hash = sha256.convert(utf8.encode(concatenatedKids));
  final base64Encoded = base64Url.encode(hash.bytes).replaceAll('=', '');

  return base64Encoded;
}

/// Performs ECDH scalar multiplication using Curve25519.
/// Equivalent to tweetnacl.scalarMult.
///
/// Returns a 32-byte shared secret.
Uint8List performECDH(Uint8List privateKey, Uint8List publicKey) {
  final result = Uint8List(32);
  TweetNaCl.crypto_scalarmult(
    result,
    privateKey,
    publicKey,
  );
  return result;
}

/// Concatenates two byte arrays into one.
Uint8List concatenate(Uint8List a, Uint8List b) {
  return Uint8List.fromList([...a, ...b]);
}

/// Derives a key using HKDF with SHA-512, as per RFC 5869.
///
/// - Uses no salt (null).
/// - Produces a 64-byte output key.
/// - `info` parameter constructed from apu, apv, and encryption method.
Uint8List deriveKey(
  Uint8List combinedSharedSecret,
  String encMethod,
  String? apuEncoded,
  String apvEncoded,
) {
  final infoString = (apuEncoded == null || apuEncoded.isEmpty)
      ? (apvEncoded + encMethod)
      : (apuEncoded + apvEncoded + encMethod);

  final info = utf8.encode(infoString);

  final hkdf = pc.HKDFKeyDerivator(pc.SHA512Digest());
  hkdf.init(
    pc.HkdfParameters(
      combinedSharedSecret,
      64,
      null, // salt = null
      Uint8List.fromList(info),
    ),
  );

  final output = Uint8List(64);
  hkdf.deriveKey(null, 0, output, 0);
  return output;
}

/// Generates a random 16-byte IV (nonce).
Uint8List generateIV() {
  final rand = Random.secure();
  return Uint8List.fromList(List.generate(16, (_) => rand.nextInt(256)));
}

/// Encrypts plaintext using AES-256-CBC with HMAC-SHA-512 authentication.
///
/// Steps:
/// - Splits derived key into encKey and macKey.
/// - PKCS7 pads the plaintext.
/// - Encrypts using AES-CBC.
/// - Computes HMAC-SHA-512 over ciphertext.
/// - Returns ciphertext concatenated with HMAC.
///
/// **Note:** HMAC is computed over the ciphertext only.
// ignore: non_constant_identifier_names
Uint8List encryptAES_CBC_HMAC_SHA512(
  String plaintext,
  Uint8List derivedKey,
  Uint8List iv,
) {
  final encKey = derivedKey.sublist(0, 32);
  final macKey = derivedKey.sublist(32, 64);

  final paddedPlaintext = _pkcs7Pad(Uint8List.fromList(utf8.encode(plaintext)));

  final cipher = pc.CBCBlockCipher(pc.AESEngine());
  final params = pc.ParametersWithIV(pc.KeyParameter(encKey), iv);
  cipher.init(true, params);

  final ciphertext = Uint8List(paddedPlaintext.length);
  for (int offset = 0; offset < paddedPlaintext.length; offset += 16) {
    cipher.processBlock(
      paddedPlaintext,
      offset,
      ciphertext,
      offset,
    );
  }

  // Compute HMAC-SHA512
  final hmac = Hmac(sha512, macKey);
  final mac = hmac.convert(ciphertext).bytes;

  return Uint8List.fromList(ciphertext + mac);
}

/// Base64URL-encodes input without padding.
String base64UrlEncodeNoPadding(Uint8List input) {
  return base64Url.encode(input).replaceAll('=', '');
}

/// Creates a JSON header for Authenticated encryption scenarios (Auth-Protected).
///
/// Includes:
/// - EPK (Ephemeral Public Key)
/// - APU, APV
/// - skID
/// - typ, alg, enc
String createAuthProtectedHeader(
  String crv,
  String kty,
  String apu,
  String apv,
  Uint8List ephemeralPublicKey,
  String skid,
  String typ,
  String alg,
  String enc,
) {
  final epk = {
    'crv': crv,
    'kty': kty,
    'x': base64UrlEncodeNoPadding(ephemeralPublicKey),
  };

  final header = {
    'epk': epk,
    'typ': typ,
    'alg': alg,
    'enc': enc,
    'skid': skid,
    'apu': apu,
    'apv': apv,
  };

  return jsonEncode(header);
}

/// Creates a JSON header for Anonymous encryption scenarios (Anon-Protected).
///
/// Includes:
/// - EPK (Ephemeral Public Key)
/// - APV
/// - typ, alg, enc
String createAnonProtectedHeader(
  String crv,
  String kty,
  String apv,
  Uint8List ephemeralPublicKey,
  String typ,
  String alg,
  String enc,
) {
  final epk = {
    'crv': crv,
    'kty': kty,
    'x': base64UrlEncodeNoPadding(ephemeralPublicKey),
  };

  final header = {
    'epk': epk,
    'typ': typ,
    'alg': alg,
    'enc': enc,
    'apv': apv,
  };

  return jsonEncode(header);
}

/// RFC 3394 AES Key Wrap
///
/// - kek = Key Encryption Key (must be 32 bytes for AES-256)
/// - cek = Content Encryption Key (must be multiple of 8 bytes)
///
/// Returns wrapped CEK as Uint8List
Uint8List aesKeyWrap(Uint8List kek, Uint8List cek) {
  if (kek.length != 32) {
    throw ArgumentError('KEK must be 32 bytes (256-bit).');
  }
  if (cek.length % 8 != 0) {
    throw ArgumentError('CEK length must be multiple of 8 bytes.');
  }

  final cipher = pc.ECBBlockCipher(pc.AESEngine());
  cipher.init(true, pc.KeyParameter(kek));

  final n = cek.length ~/ 8;
  final List<Uint8List> R = List.generate(
    n,
    (j) => cek.sublist(j * 8, (j + 1) * 8),
  );

  // Initial A = IV
  Uint8List A = Uint8List.fromList([
    0xA6, 0xA6, 0xA6, 0xA6, 0xA6, 0xA6, 0xA6, 0xA6,
  ]);

  for (int i = 0; i < 6; i++) {
    for (int j = 0; j < n; j++) {
      // B = AES(K, A | R[j])
      final block = Uint8List(16);
      block.setRange(0, 8, A);
      block.setRange(8, 16, R[j]);

      final B = cipher.process(block);

      // MSB(64, B)
      final newA = B.sublist(0, 8);
      final T = (n * i + j + 1);

      // XOR t into last 8 bytes of A
      final Tbytes = ByteData(8)..setUint64(0, T, Endian.big);
      for (int k = 0; k < 8; k++) {
        newA[k] ^= Tbytes.getUint8(k);
      }
      A = newA;

      // LSB(64, B)
      R[j] = B.sublist(8, 16);
    }
  }

  // Result = A | R[0] | R[1] | ...
  final wrapped = Uint8List(8 + n * 8);
  wrapped.setRange(0, 8, A);
  for (int j = 0; j < n; j++) {
    wrapped.setRange(8 + j * 8, 8 + (j + 1) * 8, R[j]);
  }
  return wrapped;
}

/// Applies PKCS#7 padding for AES block cipher operations.
///
/// Always adds at least one block of padding.
Uint8List _pkcs7Pad(Uint8List data) {
  final blockSize = 16;
  final padLen = blockSize - (data.length % blockSize);
  return Uint8List.fromList(
    data + List.filled(padLen, padLen),
  );
}

X25519KeyPair generateX25519KeypairFromPrivKey(Uint8List ed25519Seed) {
  final pk = Uint8List(32);
  final sk = Uint8List(64);

  TweetNaCl.crypto_sign_keypair(pk, sk, ed25519Seed);

  final x25519PrivKey = sk.sublist(0, 32);
  final x25519PubKey = TweetNaCl.crypto_scalarmult_base(
    Uint8List(32),
    x25519PrivKey,
  );

  return X25519KeyPair(
    publicKey: x25519PubKey,
    privateKey: x25519PrivKey,
  );
}

EphemeralKeyPair generateEphemeralKeyPair() {
  // Ephemeral key pair
  final ephemeralPrivKey = TweetNaCl.randombytes(32);
  final ephemeralPubKey = TweetNaCl.crypto_scalarmult_base(
    Uint8List(32), // output buffer
    ephemeralPrivKey,
  );
  return EphemeralKeyPair(
      publicKey: ephemeralPubKey, privateKey: ephemeralPrivKey);
}
