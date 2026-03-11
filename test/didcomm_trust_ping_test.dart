import 'package:flutter_test/flutter_test.dart';
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';

void main() {
  final TrustPingProtocol trustPingProtocol = TrustPingProtocol();

  group('Trust Ping module', () {
    test('should create a ping correctly', () {
      final createPing = trustPingProtocol.createPing(
        "did:example:alice",
        "did:example:bob",
      );

      final Map<String, dynamic> packAuthMsg = packAuthCrypt(
        senderPrivKeyStr:
            "privBve6bpkpdM4jHTkNnDRbVg8DYtizNubhzaYtD37GHsvFghckrNDm",
        recipientPubKeyBase58: "8Vo5BCHe41B4RdaFmYubxZLKo8oj6AwRsP3rK2bv63Bf",
        skid: "did:example:alice#key-2",
        kid: "did:example:bob#key-2",
        message: createPing,
      );

      final Map<String, dynamic> unpackAuthMsg = unpackAuthCrypt(
        jwe: packAuthMsg,
        receiverPrivKeyStr:
            "privBtpaUECfDNku8K8RJgGptKRL24c365AbFHXEctRMDJGTntWkPmJD",
        senderPubKeyBase58: "CxSNscV5tJDhqAPoGaWz4ZVwaGxKyQPbbp4fwH67iDSH",
      );

      expect(unpackAuthMsg['from'], equals("did:example:alice"));
      expect((unpackAuthMsg['to'] as List).first, equals("did:example:bob"));
      expect(
        unpackAuthMsg['type'],
        equals("https://didcomm.org/trust-ping/2.0/ping"),
      );
    });

    test('should create a ping-response correctly', () {
      final createPingResponse = trustPingProtocol.createPingResponse(
        "did:example:bob",
        "did:example:alice",
        "abc123456",
      );

      final Map<String, dynamic> packAuthMsg = packAuthCrypt(
        senderPrivKeyStr:
            "privBtpaUECfDNku8K8RJgGptKRL24c365AbFHXEctRMDJGTntWkPmJD",
        recipientPubKeyBase58: "CxSNscV5tJDhqAPoGaWz4ZVwaGxKyQPbbp4fwH67iDSH",
        skid: "did:example:bob#key-2",
        kid: "did:example:alice#key-2",
        message: createPingResponse,
      );

      final Map<String, dynamic> unpackAuthMsg = unpackAuthCrypt(
        jwe: packAuthMsg,
        receiverPrivKeyStr:
            "privBve6bpkpdM4jHTkNnDRbVg8DYtizNubhzaYtD37GHsvFghckrNDm",
        senderPubKeyBase58: "8Vo5BCHe41B4RdaFmYubxZLKo8oj6AwRsP3rK2bv63Bf",
      );

      expect(unpackAuthMsg['from'], equals("did:example:bob"));
      expect((unpackAuthMsg['to'] as List).first, equals("did:example:alice"));
      expect(
        unpackAuthMsg['type'],
        equals("https://didcomm.org/trust-ping/2.0/ping-response"),
      );
    });
  });
}
