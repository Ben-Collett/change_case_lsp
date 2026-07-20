class SocketInfo {
  final String host;
  final int port;

  @override
  String toString() {
    return "SocketInfo(host=$host, port=$port)";
  }

  SocketInfo(this.host, this.port);
}
