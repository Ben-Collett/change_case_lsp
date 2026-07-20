import 'package:change_case_lsp/constants.dart';
import 'package:change_case_lsp/extensions/string_extensions.dart';
import 'package:change_case_lsp/message_utils.dart';
import 'package:change_case_lsp/writer.dart';

import 'reader.dart';

typedef FilePath = String;
typedef FileContent = List<String>;

String convertToSnakeCase(List<String> text) {
  return text.join("_");
}

String convertToUpperSnakeCase(List<String> text) {
  return text.join("_").toUpperCase();
}

String convertToSpaces(List<String> text) {
  return text.join(' ');
}

String convertToCamelCase(List<String> words) {
  for (int i = 1; i < words.length; i++) {
    words[i] = words[i].capitalizeFistLetter();
  }
  return words.join();
}

String convertToPascelCase(List<String> words) {
  if (words.isNotEmpty) {
    words[0] = words.first.capitalizeFistLetter();
  }
  return convertToCamelCase(words);
}

const Map<CaseType, String Function(List<String>)> converter = {
  CaseType.snakeCase: convertToSnakeCase,
  CaseType.spacedCase: convertToSpaces,
  CaseType.camelCase: convertToCamelCase,
  CaseType.pascalCase: convertToPascelCase,
  CaseType.upperSnakeCase: convertToUpperSnakeCase,
};

class ChangeCaseLsp {
  Map<FilePath, FileContent> files = {};
  final Map<String, SupportedFeature> methods = {};

  bool isWordChar(String ch) {
    return ch.isALetter || // a-z
        ch.isANumberDigit || // 0-9
        ch.isAUnderscore;
  }

  //the line below is for testing
  // ⚠️ please review
  int nextNonWordCharIndex(int index, String content) {
    for (int i = index + 1; i < content.length; i++) {
      if (!isWordChar(content[i])) {
        return i;
      }
    }
    return content.length;
  }

  int previousNonWordCharIndex(int index, String content) {
    for (int i = index - 1; i > 0; i--) {
      if (!isWordChar(content[i])) {
        return i;
      }
    }
    return 0;
  }

  CaseType? getCaseType(String text) {
    if (text.isEmpty) {
      return null;
    }

    if (text.trim().contains(" ")) {
      return CaseType.spacedCase;
    }

    if (text.contains("_") && text[0].isAUpperCaseLetter) {
      return CaseType.upperSnakeCase;
    }
    if (text.contains("_")) {
      return CaseType.snakeCase;
    }

    if (text[0].isAUpperCaseLetter) {
      return CaseType.pascalCase;
    }

    return CaseType.camelCase;
  }

  List<String> breakUpString(String text) {
    bool allUppercase = text.toUpperCase() == text;

    if (text.trim().contains(" ")) {
      return text
          .toLowerCase()
          .split(' ')
          .where((piece) => piece.isNotEmpty)
          .toList();
    }
    if (allUppercase) {
      // Split on underscore or whitespace, and lowercase everything
      return text
          .toLowerCase()
          .split(RegExp(r'[_\s]+'))
          .where((piece) => piece.isNotEmpty)
          .toList();
    } else {
      // Insert a space before capital letters (for splitting), then split
      String withSpaces = text.replaceAllMapped(
        RegExp(r'(?<!^)([A-Z])'),
        (m) => ' ${m.group(1)}',
      );

      return withSpaces
          .split(RegExp(r'[_\s]+'))
          .map((piece) => piece.toLowerCase())
          .where((piece) => piece.isNotEmpty)
          .toList();
    }
  }

  void processTextDocument(Map data) {
    files[data["uri"]!] = data["text"]!.split("\n");
  }

  void initialize(Writer writer) {
    methods["initialize"] = SupportedFeature(
      execute: (request, id) {
        sendInitializeResponse(request, id, writer);
      },
    );

    methods["textDocument/didOpen"] = SupportedFeature(
      execute: (data, _) {
        Map map = data["textDocument"];
        processTextDocument(map);
      },
    );

    methods["textDocument/didChange"] = SupportedFeature(
      responseLabel: "textDocumentSync",
      responseData: {"change": 1, "openClose": true},
      execute: (data, _) {
        files[data["textDocument"]["uri"]] = data["contentChanges"][0]["text"]
            .split("\n");
      },
    );
    methods["textDocument/codeAction"] = SupportedFeature(
      responseLabel: "codeActionProvider",
      responseData: true,
      execute: (data, id) async {
        final uri = data["textDocument"]["uri"];
        Map range = data["range"];
        int startLine = range["start"]["line"];
        int startCharacter = range["start"]["character"];

        int endLine = range["end"]["line"];
        int endCharacter = range["end"]["character"];
        String text;

        int textStartCharacterIndex;
        int textEndCharacterIndex;

        final content = files[uri]!;
        if (startLine != endLine) {
          writer.write(generateResponse(id, result: []));
          return;
        }

        if (startCharacter == endCharacter) {
          if (!isWordChar(content[startLine][startCharacter])) {
            writer.write(generateResponse(id, result: []));
            return;
          }
          textStartCharacterIndex =
              previousNonWordCharIndex(startCharacter, content[startLine]) + 1;
          if (textStartCharacterIndex == 1 &&
              isWordChar(content[startLine][0])) {
            textStartCharacterIndex = 0;
          }
          textEndCharacterIndex = nextNonWordCharIndex(
            endCharacter,
            content[endLine],
          );
        } else {
          textStartCharacterIndex = startCharacter;
          textEndCharacterIndex = endCharacter;
        }

        String line = content[startLine];
        while (textStartCharacterIndex < textEndCharacterIndex &&
            !line[textStartCharacterIndex].isALetter) {
          textStartCharacterIndex++;
        }

        while (textStartCharacterIndex < textEndCharacterIndex &&
            !line[textEndCharacterIndex].isALetter) {
          textEndCharacterIndex--;
        }

        if (textStartCharacterIndex >= textEndCharacterIndex) {
          writer.write(generateResponse(id, result: []));
          return;
        }

        text = line.substring(
          textStartCharacterIndex,
          textEndCharacterIndex + 1,
        );
        List<String> words = breakUpString(text);

        List<CodeActionOption> options = [];

        CaseType? currentType = getCaseType(text);
        for (final entry in converter.entries) {
          if (entry.key != currentType) {
            options.add(
              CodeActionOption(
                startLine: startLine,
                endLine: endLine,
                startCharacter: textStartCharacterIndex,
                endCharacter: textEndCharacterIndex + 1,
                title: entry.key.label,
                uri: uri,
                newText: entry.value(words),
              ),
            );
          }
        }
        List<Map<String, dynamic>> optionMap = options
            .map((option) => option.toJson())
            .toList();

        writer.write(generateResponse(id, result: optionMap));
      },
    );
  }

  Future<void> mainLoop(Reader reader) async {
    try {
      while (true) {
        Map<String, dynamic> map = await read(reader);
        String method = map[methodKey];
        if (!methods.containsKey(method)) {
          continue;
        }

        methods[method]?.execute(map["params"], map["id"]);
      }
    } catch (e) {
      //suppress broken pipes with tcp
    }
  }

  void sendInitializeResponse(
    Map<String, dynamic> request,
    dynamic id,
    Writer writer,
  ) async {
    final response = generateResponse(
      id,
      result: getInitializeResponse(request),
    );
    writer.write(response);
  }

  Map<String, dynamic> getInitializeResponse(Map<String, dynamic> request) {
    Map<String, dynamic> capabilities = {};
    for (SupportedFeature feature in methods.values) {
      if (feature.responseLabel != null) {
        capabilities[feature.responseLabel!] = feature.responseData;
      }
    }
    return {
      "capabilities": capabilities,
      "serverInfo": {"name": "change_case_lsp", "version": "1.0"},
    };
  }
}

class SupportedFeature {
  String? responseLabel;
  dynamic responseData;
  void Function(Map<String, dynamic> params, dynamic id) execute;
  SupportedFeature({
    this.responseLabel,
    this.responseData,
    required this.execute,
  });
}

enum CaseType {
  spacedCase("spaced case"),
  snakeCase("snake_case"),
  upperSnakeCase("UPPER_SNAKE_CASE"),
  camelCase("camelCase"),
  pascalCase("PascalCase");

  final String label;
  const CaseType(this.label);
}

class CodeActionOption {
  final int startLine;
  final int startCharacter;
  final int endLine;
  final int endCharacter;
  final String title;
  final String kind = "refactor.rewrite";
  final String uri;
  final String newText;
  CodeActionOption({
    required this.startLine,
    required this.endLine,
    required this.endCharacter,
    required this.startCharacter,
    required this.title,
    required this.uri,
    required this.newText,
  });
  Map<String, dynamic> toJson() => {
    "title": title,
    "kind": kind,
    "edit": {
      "changes": {
        uri: [
          {
            "range": {
              "start": {"line": startLine, "character": startCharacter},
              "end": {"line": endLine, "character": endCharacter},
            },
            "newText": newText,
          },
        ],
      },
    },
  };
}
