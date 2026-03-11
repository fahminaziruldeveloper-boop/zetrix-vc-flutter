import 'dart:typed_data';

class X25519KeyPair {
  final Uint8List publicKey;
  final Uint8List privateKey;

  X25519KeyPair({
    required this.publicKey,
    required this.privateKey,
  });
}
