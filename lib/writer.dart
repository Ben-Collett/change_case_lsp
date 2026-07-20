import 'dart:io';

abstract class Writer {
  void write(String msg);
}

class StdioWriter extends Writer {
  @override
  void write(String msg) {
    stdout.write(msg);
  }
}

class TcpWriter extends Writer {
  final Socket socket;

  TcpWriter(this.socket);

  @override
  void write(String msg) {
    socket.write(msg);
  }
}
