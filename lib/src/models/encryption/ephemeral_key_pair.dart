import 'dart:typed_data';

class EphemeralKeyPair {
  final Uint8List publicKey;
  final Uint8List privateKey;

  EphemeralKeyPair({
    required this.publicKey,
    required this.privateKey,
  });
}
