import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';

void main() {
  final OutOfBandProtocol outOfBandProtocol = OutOfBandProtocol();

  group('Out of Band module', () {
    test('should create an invitation correctly', () {
      final createInvitation = outOfBandProtocol.createInvitation(
        from: "did:example:verifier",
        goalCode: "streamlined-vp",
        goal: "Streamlined Verifiable Presentation",
        accept: ["didcomm/v2"],
        attachments: [],
      );

      print(createInvitation);

      final createUrl = outOfBandProtocol.createUrl(
        "https://example.com/test",
        createInvitation
      );

      final encoded = createUrl.split('?_oob=').last;

      final decoded = outOfBandProtocol.decodeInvitation(encoded);

      expect(
        jsonEncode(decoded),
        equals(jsonEncode(jsonDecode(createInvitation))),
      );

      expect(
        decoded.from,
        equals("did:example:verifier"),
      );

      expect(
        decoded.type,
        equals("https://didcomm.org/out-of-band/2.0/invitation"),
      );
    });
  });
}
