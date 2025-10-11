import "dart:io";

File file = File("/tmp/charlsp");
const loggingEnabled = true;
void log(dynamic msg) {
  file.createSync(recursive: true);
  file.writeAsStringSync(msg.toString(), mode: FileMode.append);
}

void logLine(dynamic msg) {
  log("\n$msg\n");
}
