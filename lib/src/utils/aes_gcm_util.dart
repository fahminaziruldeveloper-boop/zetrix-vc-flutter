import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

/// A utility class for performing AES-GCM encryption and decryption operations.
/// 
/// AES-GCM (Advanced Encryption Standard - Galois/Counter Mode) is a mode of
/// operation for symmetric key cryptographic block ciphers that provides both
/// data confidentiality and authenticity.
/// 
/// This class provides methods to securely encrypt and decrypt data using
/// AES-GCM, ensuring that the data remains protected during transmission or storage.
class AesGcmUtil {
  /// The size of the AES key in bytes.
  /// 
  /// This constant represents the key size for AES encryption, which is 32 bytes
  /// (equivalent to 256 bits). It is used to ensure the encryption key meets the
  /// required length for AES-256 encryption.
  static const int aesKeySize = 32; // 256 bits
  /// The length of the initialization vector (IV) for AES-GCM encryption, 
  /// specified as 12 bytes (96 bits). This is a standard length for GCM mode.
  static const int gcmIvLength = 12; // 96 bits
  /// The length of the GCM (Galois/Counter Mode) authentication tag in bytes.
  /// 
  /// This constant represents the size of the authentication tag used in AES-GCM
  /// encryption, which is 16 bytes (128 bits). The authentication tag is used to
  /// ensure the integrity and authenticity of the encrypted data.
  static const int gcmTagLength = 16; // 128 bits in bytes

  /// Derive 256-bit AES key from sharedSecret using HKDF-SHA256
  static Future<SecretKey> deriveAesKey(Uint8List sharedSecret) async {
    final hkdf = Hkdf(
      hmac: Hmac.sha256(),
      outputLength: aesKeySize,
    );
    final List<int> nonce = [0];
    return await hkdf.deriveKey(
      secretKey: SecretKey(sharedSecret),
      nonce: nonce
    );
  }

  /// Generate 12-byte IV
  static Uint8List generateIV() {
    final random = Random.secure();
    return Uint8List.fromList(
        List.generate(gcmIvLength, (_) => random.nextInt(256)));
  }

  /// Encrypt (returns IV + ciphertext + tag in one Uint8List)
  static Future<Uint8List> encrypt({
    required Uint8List plaintext,
    required SecretKey secretKey,
  }) async {
    final algorithm = AesGcm.with256bits();
    final iv = generateIV();

    final secretBox = await algorithm.encrypt(
      plaintext,
      secretKey: secretKey,
      nonce: iv,
    );

    // Return IV + ciphertext + tag
    final result = Uint8List(iv.length + secretBox.cipherText.length + gcmTagLength);
    result.setRange(0, iv.length, iv);
    result.setRange(iv.length, iv.length + secretBox.cipherText.length, secretBox.cipherText);
    result.setRange(
        iv.length + secretBox.cipherText.length,
        result.length,
        secretBox.mac.bytes);

    return result;
  }

  /// Decrypt (expects IV + ciphertext + tag)
  static Future<Uint8List> decrypt({
    required Uint8List ivCiphertextMac,
    required SecretKey secretKey,
  }) async {
    final iv = ivCiphertextMac.sublist(0, gcmIvLength);
    final cipherTextLength = ivCiphertextMac.length - gcmIvLength - gcmTagLength;
    final cipherText = ivCiphertextMac.sublist(gcmIvLength, gcmIvLength + cipherTextLength);
    final macBytes = ivCiphertextMac.sublist(ivCiphertextMac.length - gcmTagLength);

    final algorithm = AesGcm.with256bits();

    final secretBox = SecretBox(
      cipherText,
      nonce: iv,
      mac: Mac(macBytes),
    );

    return await algorithm.decrypt(secretBox, secretKey: secretKey) as Uint8List;
  }
}
