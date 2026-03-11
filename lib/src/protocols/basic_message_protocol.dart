import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:zetrix_vc_flutter/src/models/did_comm/basic_message.dart';

class BasicMessageProtocol {

  String createBasicMessage({
    required String from,
    required String to,
    required String content,
  }) {
    final message = BasicMessage(
      id: const Uuid().v4(),
      typ: "application/didcomm-plain+json",
      type: "https://didcomm.org/basicmessage/2.0/message",
      from: from,
      lang: "en",
      body: {
        "content": content,
      },
      to: [to],
      createdTime: DateTime.now().millisecondsSinceEpoch,
    );
  
    return jsonEncode(message);
  }

}
