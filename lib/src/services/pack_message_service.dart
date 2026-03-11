import 'dart:convert';
import 'dart:typed_data';
import 'package:pinenacl/tweetnacl.dart';
import 'package:pinenacl/x25519.dart';
import 'package:bs58/bs58.dart';
import 'package:zetrix_vc_flutter/src/models/encryption/ephemeral_key_pair.dart';
import 'package:zetrix_vc_flutter/src/models/encryption/x25519_key_pair.dart';
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';

/// Packs an authenticated encryption message (authcrypt) using ECDH-1PU,
/// converting the sender's Ed25519 private key into an X25519 keypair
/// for encryption, following the DIDComm specification.
///
/// This function performs the following:
///
/// - Parses the sender's Ed25519 private key (as a Base58 or hex string) into raw bytes.
/// - Derives the X25519 keypair from the Ed25519 seed.
/// - Generates an ephemeral X25519 keypair.
/// - Decodes the recipient's X25519 public key (Base58).
/// - Computes two ECDH shared secrets (sender-static and ephemeral-static).
/// - Concatenates the two shared secrets.
/// - Derives a symmetric key using a KDF (HKDF).
/// - Encrypts the message with AES-256-CBC + HMAC-SHA-512.
/// - Wraps the CEK (Content Encryption Key) using AES Key Wrap (A256KW).
/// - Builds a JWE-compatible JSON object containing all encryption data.
///
/// Parameters:
///
/// - [senderPrivKeyStr] – Sender's Ed25519 private key, encoded as a string
///   (typically Base58 or hex) used as seed for X25519 key derivation.
/// - [recipientPubKeyBase58] – Recipient's X25519 public key encoded in Base58.
/// - [skid] – The sender's Key ID (usually the sender's DID).
/// - [kid] – The recipient's Key ID.
/// - [message] – The plaintext message to encrypt.
///
/// Returns:
///
/// A JSON object with the following structure:
///
/// ```json
/// {
///   "protected": "<Base64URL-encoded protected header>",
///   "recipients": [
///     {
///       "encrypted_key": "<Base64URL-encoded encrypted CEK>",
///       "header": {
///         "kid": "<recipient key ID>"
///       }
///     }
///   ],
///   "iv": "<Base64URL-encoded IV>",
///   "ciphertext": "<Base64URL-encoded ciphertext>",
///   "tag": "<Base64URL-encoded authentication tag>"
/// }
/// ```
///
/// Throws:
///
/// - Exception if the sender private key is not 32 bytes after decoding.
Map<String, dynamic> packAuthCrypt({
  required String senderPrivKeyStr,
  required String recipientPubKeyBase58,
  required String skid,
  required String kid,
  required String message,
}) {
  EncryptionUtils encryptionUtils = EncryptionUtils();
  const encMethod = 'A256CBC-HS512';

  // Parse Zetrix Ed25519 private key → raw 32 bytes
  final senderPrivKeyBytes = encryptionUtils.parsePrivateKey(senderPrivKeyStr);

  if (senderPrivKeyBytes.length != 32) {
    throw Exception('Parsed sender private key must be 32 bytes for X25519.');
  }

  X25519KeyPair x25519keyPair =
      generateX25519KeypairFromPrivKey(senderPrivKeyBytes);
  // Allocate output buffers
  final pk = Uint8List(32);
  final sk = Uint8List(64);

// Compute X25519 public key from private seed
  TweetNaCl.crypto_sign_keypair(pk, sk, senderPrivKeyBytes);

// The private scalar is the first 32 bytes of sk
  final senderX25519PrivKey = x25519keyPair.privateKey;

// Ephemeral key pair
  EphemeralKeyPair ephemeralKeyPair = generateEphemeralKeyPair();
  final ephemeralPrivKey = ephemeralKeyPair.privateKey;
  final ephemeralPubKey = ephemeralKeyPair.publicKey;
  // Decode recipient pubkey from base58
  var recipientKeyStr = recipientPubKeyBase58;
  if (recipientKeyStr.startsWith('z') && recipientKeyStr.length == 45) {
    recipientKeyStr = recipientKeyStr.substring(1);
  }
  final recipientPubKeyBytes = base58.decode(recipientKeyStr);

  // apu = sender’s DID
  final apu = skid;
  final apv = [kid];

  // Base64URL encode apu
  final apuEncoded = base64Url.encode(utf8.encode(apu)).replaceAll('=', '');

  // Compute apv
  final apvEncoded = computeApv(apv);

  // ECDH 1PU:
  final sharedSecret1 = performECDH(
    senderX25519PrivKey,
    recipientPubKeyBytes,
  );
  final sharedSecret2 = performECDH(
    ephemeralPrivKey,
    recipientPubKeyBytes,
  );

  final combinedSharedSecret = concatenate(
    sharedSecret1,
    sharedSecret2,
  );

  // Derive final key material
  final derivedKey = deriveKey(
    combinedSharedSecret,
    encMethod,
    apuEncoded,
    apvEncoded,
  );

  final iv = generateIV();

  final ciphertextWithHmac = encryptAES_CBC_HMAC_SHA512(
    message,
    derivedKey,
    iv,
  );

  final tagLength = 64; // 512 bits / 8
  final ciphertext = ciphertextWithHmac.sublist(
    0,
    ciphertextWithHmac.length - tagLength,
  );
  final tag = ciphertextWithHmac.sublist(
    ciphertextWithHmac.length - tagLength,
  );

  final protectedHeader = createAuthProtectedHeader(
    'X25519',
    'OKP',
    apuEncoded,
    apvEncoded,
    ephemeralPubKey,
    skid,
    'application/didcomm-encrypted+json',
    'ECDH-1PU+A256KW',
    'A256CBC-HS512',
  );

  final protectedHeaderEncoded = base64UrlEncodeNoPadding(
    utf8.encode(protectedHeader),
  );

  final kek = derivedKey.sublist(0, 32);
  final cek = derivedKey.sublist(0, 32);

  final wrappedKey = aesKeyWrap(kek, cek);
  final encryptedKey = base64UrlEncodeNoPadding(wrappedKey);

  return {
    'protected': protectedHeaderEncoded,
    'recipients': [
      {
        'encrypted_key': encryptedKey,
        'header': {
          'kid': kid,
        }
      }
    ],
    'iv': base64UrlEncodeNoPadding(iv),
    'ciphertext': base64UrlEncodeNoPadding(ciphertext),
    'tag': base64UrlEncodeNoPadding(tag),
  };
}

/// Packs and encrypts a message using anonymous (anoncrypt) encryption for a given recipient.
///
/// This function prepares a payload for anonymous encryption by taking the recipient's public key,
/// a key identifier, and the plaintext message to encrypt. The output is a JSON-compatible `Map`
/// containing the encrypted message and relevant metadata.
///
/// Typically used in DIDComm or verifiable credential flows where the sender does not reveal their identity
/// but wants to securely send a message to the recipient.
///
/// - [recipientPubKeyBase58]: The recipient's public key encoded in Base58.
/// - [kid]: The key identifier corresponding to the recipient's public key.
/// - [message]: The plaintext message to be encrypted.
///
/// Returns a [Map<String, dynamic>] containing the anoncrypt-encrypted payload.
///
/// Example:
/// ```dart
/// final encrypted = packAnonCrypt(
///   recipientPubKeyBase58: '...base58pubkey...',
///   kid: 'did:example:123#key-1',
///   message: '{"foo": "bar"}',
/// );
/// print(encrypted['ciphertext']); // Access the encrypted data
/// ```
Map<String, dynamic> packAnonCrypt({
  required String recipientPubKeyBase58,
  required String kid,
  required String message,
}) {
  // Remove leading "z" if present
  if (recipientPubKeyBase58.startsWith('z') &&
      recipientPubKeyBase58.length == 45) {
    recipientPubKeyBase58 = recipientPubKeyBase58.substring(1);
  }

  // Generate ephemeral X25519 key pair
  final ephemeralPrivKey = TweetNaCl.randombytes(32);
  final ephemeralPubKey = TweetNaCl.crypto_scalarmult_base(
    Uint8List(32), // output buffer
    ephemeralPrivKey,
  );

  // Decode recipient public key
  final recipientPubKeyBytes = base58.decode(recipientPubKeyBase58);

  // apv = [kid]
  final apv = [kid];
  final apvEncoded = computeApv(apv);

  // Compute shared secret
  final sharedSecret = performECDH(ephemeralPrivKey, recipientPubKeyBytes);

  const encMethod = 'A256CBC-HS512';
  final derivedKey = deriveKey(
    sharedSecret,
    encMethod,
    null,
    apvEncoded,
  );

  final iv = generateIV();

  // Encrypt plaintext
  final ciphertextWithHmac = encryptAES_CBC_HMAC_SHA512(
    message,
    derivedKey,
    iv,
  );

  final tagLength = 64;
  final ciphertext = ciphertextWithHmac.sublist(
    0,
    ciphertextWithHmac.length - tagLength,
  );
  final tag = ciphertextWithHmac.sublist(
    ciphertextWithHmac.length - tagLength,
  );

  final protectedHeader = createAnonProtectedHeader(
    'X25519',
    'OKP',
    apvEncoded,
    ephemeralPubKey,
    'application/didcomm-encrypted+json',
    'ECDH-ES+A256KW',
    'A256CBC-HS512',
  );

  final protectedHeaderEncoded = base64UrlEncodeNoPadding(
    utf8.encode(protectedHeader),
  );

  final kek = derivedKey.sublist(0, 32);
  final cek = derivedKey.sublist(0, 32);

  final wrappedKey = aesKeyWrap(kek, cek);
  final encryptedKey = base64UrlEncodeNoPadding(wrappedKey);

  return {
    'protected': protectedHeaderEncoded,
    'recipients': [
      {
        'encrypted_key': encryptedKey,
        'header': {
          'kid': kid,
        }
      }
    ],
    'iv': base64UrlEncodeNoPadding(iv),
    'ciphertext': base64UrlEncodeNoPadding(ciphertext),
    'tag': base64UrlEncodeNoPadding(tag),
  };
}
