extension StringListExtensions on List<String> {
  Iterable<String> whereNotEmptyStr() {
    return where((ch) => ch.isNotEmpty);
  }
}

extension ListExtensions on List {
  bool containsAny(Iterable elements) {
    for (final element in this) {
      if (elements.contains(element)) {
        return true;
      }
    }
    return false;
  }
}
