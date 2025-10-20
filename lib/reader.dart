import 'dart:convert';
import 'dart:io';

import 'package:change_case_lsp/constants.dart';

Map<String, dynamic> read({Stdin? input}) {
  input = input ?? stdin;
  List<String> output = [];
  while (!output.endsWith(separator)) {
    output.add(String.fromCharCode(input.readByteSync()));
  }
  StringBuffer buffer = StringBuffer();
  for (final ch in output) {
    buffer.write(ch);
  }
  return jsonDecode(_readExact(_getLength(buffer.toString()), input));
}

extension EndsWith on List<String> {
  bool endsWith(String text) {
    if (text.length > length) {
      return false;
    }
    for (int i = 0; i < text.length; i++) {
      if (this[length - text.length + i] != text[i]) {
        return false;
      }
    }
    return true;
  }
}

extension ReplaceControl on String {
  String replaceControl() => replaceAll("\r", r"\r").replaceAll("\n", "\\n");
}

String _readExact(int length, Stdin stdin) {
  List<int> out = [];
  for (int i = 0; i < length; i++) {
    out.add(stdin.readByteSync());
  }
  return utf8.decode(out);
}

int _getLength(String header) =>
    int.parse(header.substring(header.indexOf(":") + 1).trim());
