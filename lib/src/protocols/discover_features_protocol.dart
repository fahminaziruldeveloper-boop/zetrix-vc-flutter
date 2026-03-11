import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:zetrix_vc_flutter/src/models/did_comm/disclose.dart';
import 'package:zetrix_vc_flutter/src/models/did_comm/queries.dart';

class DiscoverFeaturesProtocol {
  
  String createDisclose({
    required String from,
    required String to,
    required String thid,
    List<DisclosureItem>? disclosures,
  }) {
    final message = Disclose(
      id: const Uuid().v4(),
      typ: 'application/didcomm-plain+json',
      type: 'https://didcomm.org/discover-features/2.0/disclose',
      from: from,
      body: DiscloseBody(
        disclosures: disclosures ??
            [
              DisclosureItem(
                featureType: 'protocol',
                id: 'https://didcomm.org/discover-features/2.0',
              ),
              DisclosureItem(
                featureType: 'protocol',
                id: 'https://didcomm.org/trust-ping/2.0',
              ),
              DisclosureItem(
                featureType: 'protocol',
                id: 'https://didcomm.org/basicmessage/2.0',
              ),
            ],
      ),
      to: [to],
      thid: thid,
      createdTime: DateTime.now().millisecondsSinceEpoch,
    );

    return jsonEncode(message);
  }

    String createQueries({
    required String from,
    required String to,
  }) {
    final message = Queries(
      id: const Uuid().v4(),
      typ: 'application/didcomm-plain+json',
      type: 'https://didcomm.org/discover-features/2.0/queries',
      from: from,
      body: QueriesBody(queries: [
        QueryItem(
          featureType: 'protocol',
          match: 'https://didcomm.org/*',
        )
      ]),
      to: [to],
      createdTime: DateTime.now().millisecondsSinceEpoch,
    );

    return jsonEncode(message);
  }

}

