class NetworkRequest {
  final String method;
  final String path;
  final Map<String, dynamic>? queryParameters;
  final dynamic body;
  final Map<String, String> headers;

  NetworkRequest({
    required this.method,
    required this.path,
    this.queryParameters,
    this.body,
    this.headers = const {},
  });
}
