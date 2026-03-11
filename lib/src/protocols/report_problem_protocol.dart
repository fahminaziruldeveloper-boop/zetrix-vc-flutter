import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:zetrix_vc_flutter/src/models/did_comm/problem_report.dart';

class ReportProblemProtocol {
  String createProblemReport(String pthid, String code, String comment) {
    final message = ProblemReport(
        id: const Uuid().v4(),
        type: 'https://didcomm.org/report-problem/2.0/problem-report',
        pthid: pthid,
        body: ProblemReportBody(code: code, comment: comment));

    return jsonEncode(message);
  }
}
