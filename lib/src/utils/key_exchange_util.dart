import 'package:bs58/bs58.dart';
import 'package:cryptography/cryptography.dart';
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';

/// A utility class that provides methods for performing key exchange operations,
/// such as generating key pairs, exchanging public keys, and deriving shared secrets.
/// 
/// This class is intended to facilitate secure communication by handling the
/// cryptographic details of key exchange protocols.
class KeyExchangeUtils {
  /// Derives a shared key material using the provided parameters.
  ///
  /// This method performs key exchange operations to generate a shared secret
  /// between two parties. The resulting [KeyMaterial] can be used for secure
  /// communication or encryption purposes.
  ///
  /// Returns a [Future] that completes with the derived [KeyMaterial].
  static Future<KeyMaterial> deriveSharedKey({
    required String privateKeyBase58,
    required String recipientPubKeyBase58,
  }) async {
    final privKeyBytes = EncryptionUtils().parsePrivateKey(privateKeyBase58);
    if (privKeyBytes.length != 32) {
      throw ArgumentError('Private key must be 32 bytes for X25519');
    }

    final x25519KeyPair = generateX25519KeypairFromPrivKey(privKeyBytes);
    final sharedSecret = performECDH(
      x25519KeyPair.privateKey,
      base58.decode(recipientPubKeyBase58),
    );

    final aesKey = await AesGcmUtil.deriveAesKey(sharedSecret);

    return KeyMaterial(
      senderPubKeyBase58: base58.encode(x25519KeyPair.publicKey),
      secretKey: aesKey,
    );
  }
}

/// A class representing cryptographic key material used in key exchange operations.
/// 
/// This class typically holds the necessary information for securely exchanging
/// cryptographic keys between parties, such as public keys, private keys, or
/// other related data required for establishing secure communication channels.
class KeyMaterial {
  /// The sender's public key encoded in Base58 format.
  /// 
  /// This key is typically used for cryptographic operations such as verifying signatures
  /// or establishing secure communication channels with the sender.
  final String senderPubKeyBase58;
  /// The secret key used for cryptographic operations, such as encryption or decryption,
  /// in the key exchange process.
  final SecretKey secretKey;
  /// Constructs a [KeyMaterial] instance with the given sender's public key (in Base58 format)
  /// and the associated secret key.
  /// 
  /// [senderPubKeyBase58]: The sender's public key encoded in Base58.
  /// [secretKey]: The secret key used for key exchange or cryptographic operations.
  KeyMaterial({required this.senderPubKeyBase58, required this.secretKey});
}