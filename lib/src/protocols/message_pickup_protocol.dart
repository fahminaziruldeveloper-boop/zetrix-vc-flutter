import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:zetrix_vc_flutter/src/models/did_comm/live_delivery_change.dart';

class MessagePickupProtocol {
  String createLiveDeliveryChange({
    required String from,
    required String to,
    bool isLive = false,
  }) {
    final message = LiveDeliveryChange(
        id: const Uuid().v4(),
        typ: "application/didcomm-plain+json",
        type: "https://didcomm.org/messagepickup/3.0/live-delivery-change",
        from: from,
        to: [to],
        createdTime: DateTime.now().millisecondsSinceEpoch,
        body: LiveDeliveryChangeBody(liveDelivery: isLive ? isLive : false));
        
    return jsonEncode(message);
  }
}
