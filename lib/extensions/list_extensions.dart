extension StringListExtensions on List<String> {
  Iterable<String> whereNotEmptyStr() {
    return where((ch) => ch.isNotEmpty);
  }
}
