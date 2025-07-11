class NetworkError {
  final String message;
  final int? code;
  final dynamic originalException;

  NetworkError({required this.message, this.code, this.originalException});
}
