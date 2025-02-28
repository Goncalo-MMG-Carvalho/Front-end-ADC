class TokenInvalidoException implements Exception {
  final String message;

  TokenInvalidoException(this.message);

  @override
  String toString() => 'TokenInvalidoException: $message';
}
