// WARNING: none of the isA methods validate a string is only one character and will use the first character if it is not
extension StringUtils on String {
  bool get isAUnderscore {
    return this == "_";
  }

  bool get isAUpperCaseLetter {
    final code = codeUnitAt(0);
    return (code >= 65 && code <= 90);
  }

  bool get isLowercaseLetter {
    final code = codeUnitAt(0);
    return (code >= 97 && code <= 122); // a-z
  }

  bool get isALetter {
    return isAUpperCaseLetter || isLowercaseLetter;
  }

  bool get isANumberDigit {
    final code = codeUnitAt(0);
    return (code >= 48 && code <= 57);
  }

  String replaceAt(int index, String ch) {
    return replaceRange(index, index + 1, ch);
  }

  String repeat(int count) {
    final buffer = StringBuffer();
    for (var i = 0; i < count; i++) {
      buffer.write(this);
    }
    return buffer.toString();
  }

  String capitalizeFistLetter() {
    for (int i = 0; i < length; i++) {
      if (this[i].isALetter) {
        return replaceAt(i, this[i].toUpperCase());
      }
    }
    return this;
  }

  int getLeadingUnderscoreCount() {
    int count = 0;
    for (int i = 0; i < length; i++) {
      if (this[i].isAUnderscore) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  int getTrailingUnderscoreCount() {
    int count = 0;
    for (int i = length - 1; i >= 0; i--) {
      if (this[i].isAUnderscore) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }
}
