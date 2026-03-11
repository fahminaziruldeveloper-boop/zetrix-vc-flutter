import 'package:flutter_test/flutter_test.dart';
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';

void main() {
  final MessagePickupProtocol messagePickupProtocol = MessagePickupProtocol();

  group('Message Pickup module', () {
    test('should create a live-delivery-change correctly', () {
      final createLiveDeliveryChange =
          messagePickupProtocol.createLiveDeliveryChange(
        from: "did:example:alice",
        to: "did:example:bob",
        isLive: true,
      );

      final Map<String, dynamic> packAuthMsg = packAuthCrypt(
        senderPrivKeyStr:
            "privBve6bpkpdM4jHTkNnDRbVg8DYtizNubhzaYtD37GHsvFghckrNDm",
        recipientPubKeyBase58:
            "8Vo5BCHe41B4RdaFmYubxZLKo8oj6AwRsP3rK2bv63Bf",
        skid: "did:example:alice#key-2",
        kid: "did:example:bob#key-2",
        message: createLiveDeliveryChange,
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
        unpackAuthMsg['body']['live_delivery'],
        equals(true),
      );
      expect(
        unpackAuthMsg['type'],
        equals("https://didcomm.org/messagepickup/3.0/live-delivery-change"),
      );
    });
  });
}
