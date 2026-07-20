import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:change_case_lsp/constants.dart';

abstract class Reader {
  Future<String> readBytesStr(int count) {
    return readBytes(count).then(String.fromCharCodes);
  }

  Future<List<int>> readBytes(int count);
}

class _StreamReader {
  // WARNING: vibe coded class
  final StreamIterator<List<int>> iterator;
  final List<int> _buffer = [];
  int _offset = 0;
  _StreamReader(this.iterator);

  Future<List<int>> readBytes(int count) async {
    final result = Uint8List(count);
    int written = 0;

    while (written < count) {
      if (_offset >= _buffer.length) {
        if (!await iterator.moveNext()) {
          throw Exception('Socket closed');
        }

        _buffer
          ..clear()
          ..addAll(iterator.current);
        _offset = 0;
      }

      final available = _buffer.length - _offset;
      final needed = count - written;
      final take = available < needed ? available : needed;

      result.setRange(written, written + take, _buffer, _offset);

      written += take;
      _offset += take;
    }

    return result;
  }
}

class TcpReader extends Reader {
  final _StreamReader _reader;

  TcpReader(Socket socket) : _reader = _StreamReader(StreamIterator(socket));

  @override
  Future<List<int>> readBytes(int count) async {
    return _reader.readBytes(count);
  }
}

class StdioReader extends Reader {
  final _StreamReader _reader;

  StdioReader() : _reader = _StreamReader(StreamIterator(stdin));

  @override
  Future<List<int>> readBytes(int count) async {
    return _reader.readBytes(count);
  }
}

Future<Map<String, dynamic>> read(Reader reader) async {
  List<String> output = [];
  while (!output.endsWith(separator)) {
    output.add(await reader.readBytesStr(1));
  }
  StringBuffer buffer = StringBuffer();
  for (final ch in output) {
    buffer.write(ch);
  }
  final int length = _getLength(buffer.toString());
  final String jsonStr = await reader.readBytesStr(length);
  return jsonDecode(jsonStr);
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

int _getLength(String header) =>
    int.parse(header.substring(header.indexOf(":") + 1).trim());
