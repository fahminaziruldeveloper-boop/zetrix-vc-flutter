import 'dart:typed_data';
import 'package:pointycastle/asymmetric/oaep.dart';
import 'package:pointycastle/asymmetric/rsa.dart';
import 'package:pointycastle/digests/sha1.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:basic_utils/basic_utils.dart' as bu;

/// A utility class for handling RSA-related operations.
/// 
/// This class provides methods and functionalities to work with RSA encryption,
/// decryption, and key management. It is designed to simplify the process of
/// performing cryptographic operations using RSA within the application.
class RsaUtil {
  /// RSA encryption algorithm; RSA/ECB/OAEPWithSHA-256AndMGF1Padding
  static Uint8List encrypt(RSAPublicKey myPublic, Uint8List input) {
    try {
      final engine = RSAEngine();
      final encryptor = OAEPEncoding.withSHA256(engine, Uint8List(0));
      // encryptor.mgf1Hash = SHA1Digest();

      encryptor.init(
        true, // true = encryption
        PublicKeyParameter<RSAPublicKey>(myPublic),
      );

      // Must override after init(), before processBlock — needed for Java OAEP SHA-256 + MGF1-SHA1 compatibility
      encryptor.mgf1Hash = SHA1Digest();

      if (input.length > encryptor.inputBlockSize) {
        throw ArgumentError(
          'Input too long: max ${encryptor.inputBlockSize} bytes allowed, but got ${input.length}',
        );
      }

      final out = Uint8List(encryptor.outputBlockSize);
      final written = encryptor.processBlock(input, 0, input.length, out, 0);
      return Uint8List.sublistView(out, 0, written);
    } on ArgumentError catch (e) {
      throw Exception('RSA encryption failed: ${e.message}');
    } catch (e) {
      throw Exception('RSA encryption failed: $e');
    }
  }

  /// Load public key from PEM
  static RSAPublicKey loadPublicKey(String pem) {
    try {
      return bu.CryptoUtils.rsaPublicKeyFromPem(pem);
    } catch (e) {
      throw Exception('Failed to load RSA public key: $e');
    }
  }
}
