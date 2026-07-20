import 'dart:io';

import 'package:change_case_lsp/change_case_lsp.dart';
import 'package:change_case_lsp/extensions/list_extensions.dart';
import 'package:change_case_lsp/reader.dart';
import 'package:change_case_lsp/writer.dart';

bool isHelp(List<String> arguments) {
  return arguments.containsAny(["h", "-h", "--help", "help"]);
}

void printHelpMessage() {
  print("-h, --help, h, or help to print all flags");
  print("--tcp <port> to use a tcp connection over a port");
  print("by default stdio happens over stdio");
}

int? extractPort(List<String> arguments) {
  int? port;
  if (arguments.firstOrNull == "--tcp") {
    if (arguments.length < 2) {
      print("you need to pass in a host port number with --tcp");
      exit(1);
    }
    port = int.tryParse(arguments[1]);

    if (port == null) {
      print("${arguments[1]} is not a valid port number");
      exit(1);
    }
  }
  if (port == null) {
    return null;
  }
  return port;
}

void main(List<String> arguments) async {
  if (isHelp(arguments)) {
    printHelpMessage();
    return;
  }
  int? port = extractPort(arguments);

  if (arguments.isNotEmpty && port == null) {
    print("illegal arguments $arguments run -h to see available parameters");
    exit(1);
  }

  final fu = stdioInstance();
  if (port != null) {
    final ServerSocket socket = await ServerSocket.bind(
      InternetAddress.anyIPv4,
      port,
    );
    socket.forEach(onConnect);
  }

  await fu;
}

Future<void> stdioInstance() async {
  final writer = StdioWriter();
  final reader = StdioReader();
  return setUpInstance(writer, reader);
}

void onConnect(Socket socket) {
  final writer = TcpWriter(socket);
  final reader = TcpReader(socket);
  setUpInstance(writer, reader);
}

Future<void> setUpInstance(Writer writer, Reader reader) {
  final lsp = ChangeCaseLsp();
  lsp.initialize(writer);
  return lsp.mainLoop(reader);
}
