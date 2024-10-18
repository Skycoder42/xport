class CFException implements Exception {
  final int code;
  final String reason;
  final String description;

  CFException(this.code, this.reason, this.description);

  @override
  String toString() => 'CFException($code): $reason\nDescription: $description';
}
