import 'package:flutter_test/flutter_test.dart';
import 'package:zetrix_vc_flutter/src/models/did_comm/disclose.dart';
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';

void main() {
  final DiscoverFeaturesProtocol discoverFeaturesProtocol =
      DiscoverFeaturesProtocol();

  group('Discover Features module', () {
    test('should create a queries correctly', () {
      final createQueries = discoverFeaturesProtocol.createQueries(
        from: "did:example:alice",
        to: "did:example:bob",
      );

      final Map<String, dynamic> packAuthMsg = packAuthCrypt(
        senderPrivKeyStr:
            "privBve6bpkpdM4jHTkNnDRbVg8DYtizNubhzaYtD37GHsvFghckrNDm",
        recipientPubKeyBase58: "8Vo5BCHe41B4RdaFmYubxZLKo8oj6AwRsP3rK2bv63Bf",
        skid: "did:example:alice#key-2",
        kid: "did:example:bob#key-2",
        message: createQueries,
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
        equals("https://didcomm.org/discover-features/2.0/queries"),
      );
    });

    test('should create a disclose correctly', () {
      final List<DisclosureItem> disclosures = [
        DisclosureItem(
            featureType: 'protocol',
            id: 'https://didcomm.org/discover-features/2.0'),
        DisclosureItem(
          featureType: "protocol",
          id: "https://didcomm.org/trust-ping/2.0",
        ),
        DisclosureItem(
          featureType: "protocol",
          id: "https://didcomm.org/basicmessage/2.0",
        ),
      ];

      final createDisclose = discoverFeaturesProtocol.createDisclose(
        from: "did:example:bob",
        to: "did:example:alice",
        thid: "abc123456",
        disclosures: disclosures,
      );

      final Map<String, dynamic> packAuthMsg = packAuthCrypt(
        senderPrivKeyStr:
            "privBtpaUECfDNku8K8RJgGptKRL24c365AbFHXEctRMDJGTntWkPmJD",
        recipientPubKeyBase58: "CxSNscV5tJDhqAPoGaWz4ZVwaGxKyQPbbp4fwH67iDSH",
        skid: "did:example:bob#key-2",
        kid: "did:example:alice#key-2",
        message: createDisclose,
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
        equals("https://didcomm.org/discover-features/2.0/disclose"),
      );
    });
  });
}
