import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:zetrix_vc_flutter/src/models/did_comm/ack.dart';
import 'package:zetrix_vc_flutter/src/models/did_comm/constraints.dart';
import 'package:zetrix_vc_flutter/src/models/did_comm/credential_type.dart'
    hide Field;
import 'package:zetrix_vc_flutter/src/models/did_comm/field.dart';
import 'package:zetrix_vc_flutter/src/models/did_comm/input_descriptor.dart';
import 'package:zetrix_vc_flutter/src/models/did_comm/presentation.dart';
import 'package:zetrix_vc_flutter/src/models/did_comm/presentation_definition.dart';
import 'package:zetrix_vc_flutter/src/models/did_comm/propose_presentation.dart';
import 'package:zetrix_vc_flutter/src/models/did_comm/request_presentation.dart';
import 'package:zetrix_vc_flutter/src/models/did_comm/schema.dart';
import 'package:zetrix_vc_flutter/src/models/did_comm/submission_requirement.dart';

class PresentProofProtocol {
  Field createField(List<String> path, String purpose, [dynamic filter]) {
    return Field(path: path, purpose: purpose, filter: filter);
  }

  Schema createSchema(String uri, [bool? required]) {
    return Schema(uri: uri, required: required);
  }

  InputDescriptor createInputDescriptor(
    String id,
    String? name,
    String? purpose,
    String? group,
    List<Schema> schema,
    String? limitDisclosure,
    List<Field> fields,
  ) {
    return InputDescriptor(
      id: id,
      name: name,
      purpose: purpose,
      group: group != null ? [group] : null,
      schema: schema,
      constraints: Constraints(
        fields: fields,
        limitDisclosure: limitDisclosure,
      ),
    );
  }

  SubmissionRequirement createSubmissionRequirement(
    String name,
    String purpose,
    String rule,
    int? count,
    String from,
  ) {
    return SubmissionRequirement(
      name: name,
      purpose: purpose,
      rule: rule,
      from: from,
      count: count,
    );
  }

  Map<String, dynamic> createFrame(
    dynamic context,
    String type,
    List<CredentialType> credentialTypes,
  ) {
    final Map<String, dynamic> frame = {
      "@context": context,
      "type": type,
      "credentialSubject": {}
    };

    for (var cred in credentialTypes) {
      frame["credentialSubject"][cred.name] = {};

      for (var field in cred.fields) {
        if (field.range != null) {
          frame["credentialSubject"][cred.name][field.name] = {
            "@value": {"@${field.range!.operator}": field.range!.value}
          };
        } else {
          frame["credentialSubject"][cred.name][field.name] = {};
        }
      }
    }

    return frame;
  }

  Map<String, dynamic>? createFormat(
    String type,
    List<String>? proofType,
    dynamic alg,
  ) {
    if (proofType != null) {
      return {
        type: {
          'proof_type': proofType,
        }
      };
    } else if (alg != null) {
      return {
        type: {
          'alg': alg,
        }
      };
    }
    return null;
  }

  PresentationDefinition createPresentationDefinition(
    String id,
    dynamic inputDescriptors,
    dynamic submissionRequirements,
    String? name,
    String? purpose,
    dynamic format,
  ) {
    return PresentationDefinition(
      id: id,
      inputDescriptors: inputDescriptors,
      submissionRequirements: submissionRequirements,
      name: name,
      purpose: purpose,
      format: format,
    );
  }

  String createRequestPresentation(
    String from,
    String to,
    String thid,
    String goalCode,
    String comment,
    bool isWillConfirm,
    PresentationDefinition presentationDefinition,
  ) {
    final message = RequestPresentation(
        id: const Uuid().v4(),
        thid: thid,
        typ: 'application/didcomm-plain+json',
        type: 'https://didcomm.org/present-proof/3.0/request-presentation',
        from: from,
        to: [to],
        createdTime: DateTime.now().millisecondsSinceEpoch,
        body: RequestPresentationBody(
          goalCode: goalCode,
          comment: comment,
          willConfirm: isWillConfirm,
        ),
        attachments: [
          RequestPresentationAttachment(
              id: const Uuid().v4(),
              mediaType: 'application/json',
              format: 'dif/presentation-exchange/definitions@v1.0',
              data: RequestPresentationData(json: {
                'presentation_definition': presentationDefinition,
              }))
        ]);

    return jsonEncode(message);
  }

  String createProposePresentation(
    String from,
    String to,
    String pthid,
    String goalCode,
    String comment,
    PresentationDefinition? presentationDefinition,
  ) {
    final message = ProposePresentation(
      id: const Uuid().v4(),
      pthid: pthid,
      typ: 'application/didcomm-plain+json',
      type: 'https://didcomm.org/present-proof/3.0/propose-presentation',
      from: from,
      to: [to],
      createdTime: DateTime.now().microsecondsSinceEpoch,
      body: ProposePresentationBody(
        goalCode: goalCode,
        comment: comment,
      ),
      attachments: presentationDefinition != null
          ? [
              ProposePresentationAttachment(
                  id: const Uuid().v4(),
                  mediaType: 'application/json',
                  data: ProposePresentationData(json: {
                    'presentation_definition': presentationDefinition,
                  }))
            ]
          : [],
    );

    return jsonEncode(message);
  }

  Map<String, dynamic> createVpSubmission(
    Map<String, dynamic> vp,
    String id,
    String definitionId,
    String descriptorId,
    dynamic format,
    String path,
  ) {
    final presentationSubmission = {
      'id': id,
      'definition_id': definitionId,
      'descriptor_map': [
        {
          'id': descriptorId,
          'format': format,
          'path': path,
        }
      ],
    };

    vp['presentation_submission'] = presentationSubmission;

    var type = vp['type'];
    List<String> typeArray;
    if (type is List) {
      typeArray = List<String>.from(type);
    } else {
      typeArray = [type as String];
    }

    typeArray.removeWhere((t) => t == "PresentationSubmission");
    typeArray.add("PresentationSubmission");
    vp['type'] = typeArray;

    return vp;
  }

  String createPresentation(
    String from,
    String to,
    String thid,
    Map<String, dynamic> vpSubmission,
  ) {
    final message = Presentation(
        id: const Uuid().v4(),
        typ: 'application/didcomm-plain+json',
        type: 'https://didcomm.org/present-proof/3.0/presentation',
        from: from,
        to: [to],
        thid: thid,
        createdTime: DateTime.now().millisecondsSinceEpoch,
        body: {},
        attachments: [
          PresentationAttachment(
              id: const Uuid().v4(),
              mediaType: 'application/json',
              data: PresentationAttachmentData(
                json: vpSubmission,
              ))
        ]);

    return jsonEncode(message);
  }

  String createAck(
    String from,
    String to,
    String pthid,
    String status,
  ) {
    final message = Ack(
        id: const Uuid().v4(),
        typ: 'application/didcomm-plain+json',
        type: 'https://didcomm.org/present-proof/3.0/ack',
        from: from,
        to: [to],
        pthid: pthid,
        createdTime: DateTime.now().microsecondsSinceEpoch,
        body: AckBody(
          status: status,
        ));

    return jsonEncode(message);
  }
}
