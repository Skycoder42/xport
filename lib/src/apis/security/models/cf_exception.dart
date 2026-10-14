class CFException(final int code, final String reason, final String description)
    implements Exception {
  @override
  String toString() => 'CFException($code): $reason\nDescription: $description';
}
