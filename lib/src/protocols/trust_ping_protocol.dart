import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:zetrix_vc_flutter/src/models/did_comm/ping.dart';
import 'package:zetrix_vc_flutter/src/models/did_comm/ping_response.dart';

class TrustPingProtocol {
  String createPing(String from, String to) {
    final message = Ping(
        id: const Uuid().v4(),
        typ: 'application/didcomm-plain+json',
        type: 'https://didcomm.org/trust-ping/2.0/ping',
        from: from,
        to: [to],
        createdTime: DateTime.now().millisecondsSinceEpoch,
        body: PingBody(responseRequested: true));

    return jsonEncode(message);
  }

  String createPingResponse(from, to, thid) {
    final message = PingResponse(
        id: const Uuid().v4(),
        typ: 'application/didcomm-plain+json',
        type: 'https://didcomm.org/trust-ping/2.0/ping-response',
        from: from,
        to: [to],
        createdTime: DateTime.now().millisecondsSinceEpoch,
        thid: thid,
        body: {});

    return jsonEncode(message);
  }
}
