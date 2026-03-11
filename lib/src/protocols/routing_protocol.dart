import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:zetrix_vc_flutter/src/models/did_comm/forward.dart';

class RoutingProtocol {
  String createForward(from, recipient, to, jwe) {
    final message = Forward(
        id: const Uuid().v4(),
        typ: 'application/didcomm-plain+json',
        type: 'https://didcomm.org/routing/2.0/forward',
        from: from,
        to: [to],
        created_time: DateTime.now().millisecondsSinceEpoch,
        body: ForwardBody(next: recipient),
        attachments: [
          ForwardAttachment(id: const Uuid().v4(), base64: base64Encode(utf8.encode(jsonEncode(jwe))))
        ]);

        return jsonEncode(message);
  }

}
