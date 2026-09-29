import 'dart:convert';

import 'package:change_case_lsp/lsp_responses.dart';

import 'constants.dart';

String encode(Map<String, dynamic> json) {
  final jsonString = jsonEncode(json);
  return "Content-Length: ${utf8.encode(jsonString).length}$separator$jsonString";
}

String generateShutdownResponse(dynamic id) {
  return encode({"jsonrpc": "2.0", "id": id, "result": null});
}

String generateInvalidResponseShutdown(dynamic id) {
  return generateResponse(
    id,
    error: ErrorResponse(
      code: invalidResponse,
      message: "already shutdown server",
    ),
  );
}

String generateResponse(dynamic id, {dynamic result, ErrorResponse? error}) {
  return encode({
    "jsonrpc": "2.0",
    "id": id,
    if (error == null) "result": result,
    if (error != null) "error": error.toJson(),
  });
}

Map<String, dynamic> getJson(String data) {
  return jsonDecode(data.split(separator)[1]);
}
