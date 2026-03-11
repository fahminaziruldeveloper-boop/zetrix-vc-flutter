import 'package:flutter_test/flutter_test.dart';
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';

void main() {
  final CoordinateMediationProtocol coordinateMediationProtocol =
      CoordinateMediationProtocol();

  group('Coordinate Mediation module', () {
    test('should create a mediate-request correctly', () async {
      final createMediateRequest =
          coordinateMediationProtocol.createMediateRequest(
        from: "did:example:alice",
        to: "did:example:bob",
      );

      final Map<String, dynamic> packAuthMsg = packAuthCrypt(
        senderPrivKeyStr:
            "privBve6bpkpdM4jHTkNnDRbVg8DYtizNubhzaYtD37GHsvFghckrNDm",
        recipientPubKeyBase58:
            "8Vo5BCHe41B4RdaFmYubxZLKo8oj6AwRsP3rK2bv63Bf",
        skid: "did:example:alice#key-2",
        kid: "did:example:bob#key-2",
        message: createMediateRequest,
      );

      final Map<String, dynamic> unpackAuthMsg = unpackAuthCrypt(
        jwe: packAuthMsg,
        receiverPrivKeyStr:
            "privBtpaUECfDNku8K8RJgGptKRL24c365AbFHXEctRMDJGTntWkPmJD",
        senderPubKeyBase58:
            "CxSNscV5tJDhqAPoGaWz4ZVwaGxKyQPbbp4fwH67iDSH",
      );

      expect(unpackAuthMsg['from'], equals("did:example:alice"));
      expect((unpackAuthMsg['to'] as List).first, equals("did:example:bob"));
      expect(
        unpackAuthMsg['type'],
        equals("https://didcomm.org/coordinate-mediation/3.0/mediate-request"),
      );
    });
  });
}
