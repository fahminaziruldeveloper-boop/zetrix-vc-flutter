import 'dart:typed_data';

/// The cryptographic key material belonging to the wallet holder.
///
/// Passed to [DcqlVpService.createVPFromDCQL] so the SDK can:
/// - Sign the VP as a JWT using [ed25519PrivateKey]
/// - Derive the BBS+ selective-disclosure proof using [bbsPrivateKey]
/// - Include the public keys in the submission body
///
/// ⚠️ **Key format confirmation required** — the exact encoding of these fields
/// (base58 vs base64, raw vs multibase-prefixed) must be confirmed with the
/// issuer-onboarding / wallet-setup team before going to production.
/// See Open Question #8 in `FLUTTER_SDK_VP_SUBMISSION.md`.
class WalletKeyMaterial {
  /// DID of the holder, e.g. `"did:zid:<holder-did>"`.
  final String holderDid;

  /// Raw 32-byte Ed25519 private key **seed** (NOT the 64-byte expanded key).
  ///
  /// Usage:
  /// ```dart
  /// final keyPair = await Ed25519().newKeyPairFromSeed(ed25519PrivateKey);
  /// ```
  final Uint8List ed25519PrivateKey;

  /// Base58-encoded Ed25519 public key.
  ///
  /// Included as-is in the `VpSubmissionBody` under `ed25519_public_key`.
  final String ed25519PublicKey;

  /// Raw BBS+ (BLS12-381) private key bytes.
  ///
  /// The exact format depends on the BBS+ library used (see Open Question #5).
  /// Typically matches what the `bbs` Rust crate expects as a 32-byte scalar.
  final Uint8List bbsPrivateKey;

  /// Base58-encoded BBS+ public key.
  ///
  /// Included as-is in the `VpSubmissionBody` under `bbs_public_key`.
  final String bbsPublicKey;

  const WalletKeyMaterial({
    required this.holderDid,
    required this.ed25519PrivateKey,
    required this.ed25519PublicKey,
    required this.bbsPrivateKey,
    required this.bbsPublicKey,
  });
}
