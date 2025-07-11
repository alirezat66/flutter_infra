import 'package:flutter_infra/src/network/core/network_response.dart';

abstract class NetworkClient {
  Future<NetworkResponse> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  });
  Future<NetworkResponse> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  });
  Future<NetworkResponse> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  });
  Future<NetworkResponse> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  });
}
