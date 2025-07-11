import 'package:flutter_infra/src/network/core/network_error.dart';

class NetworkResponse<T> {
  final int statusCode;
  final T? data;
  final NetworkError? error;
  final Map<String, String>? headers;

  bool get isSuccess => error == null;

  NetworkResponse({
    required this.statusCode,
    this.data,
    this.error,
    this.headers,
  });
}
