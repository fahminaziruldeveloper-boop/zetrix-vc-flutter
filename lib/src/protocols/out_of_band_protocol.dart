import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:zetrix_vc_flutter/src/models/did_comm/invitation.dart';

class OutOfBandProtocol {
  String createInvitation({
    required String from,
    required String goalCode,
    required String goal,
    required List<String> accept,
    List<InvitationAttachment>? attachments,
  }) {
    final message = Invitation(
        id: const Uuid().v4(),
        type: 'https://didcomm.org/out-of-band/2.0/invitation',
        from: from,
        body: InvitationBody(goalCode: goalCode, goal: goal, accept: accept),
        attachments: attachments);

    return jsonEncode(message);
  }

  String encodeInvitation(String invitation) {
    return base64Url.encode(utf8.encode(invitation));
  }

  Invitation decodeInvitation(String encodedMessage) {
    final decodedBytes = base64Url.decode(encodedMessage);
    final jsonStr = utf8.decode(decodedBytes);
    final map = jsonDecode(jsonStr);
    return Invitation.fromJson(map);
  }

  String createUrl(String baseUrl, message) {
    final url = '$baseUrl?_oob=${encodeInvitation(message)}';
    return url;
  }
}
