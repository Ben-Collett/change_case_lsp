import 'dart:convert';

import 'constants.dart';

String encode(Map<String, dynamic> json) {
  final jsonString = jsonEncode(json);
  return "Content-Length: ${utf8.encode(jsonString).length}$separator$jsonString";
}

String generateResponse(dynamic id, {dynamic result, dynamic error}) {
  return encode({
    "jsonrpc": "2.0",
    "id": id,
    if (result != null) "result": result,
    if (error != null) "error": error,
  });
}

Map<String, dynamic> getJson(String data) {
  return jsonDecode(data.split(separator)[1]);
}
