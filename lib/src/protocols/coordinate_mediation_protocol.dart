import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:zetrix_vc_flutter/src/models/did_comm/mediate_request.dart';

@JsonSerializable()
class CoordinateMediationProtocol {


  String createMediateRequest({
    required String from,
    required String to,
  }) {
    final message = MediateRequest(
      id: const Uuid().v4(),
      typ: 'application/didcomm-plain+json',
      type: 'https://didcomm.org/coordinate-mediation/3.0/mediate-request',
      body: {},
      from: from,
      to: [to],
      createdTime: DateTime.now().millisecondsSinceEpoch,
    );

    return jsonEncode(message);
  }

  
}
