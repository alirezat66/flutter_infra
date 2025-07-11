import 'package:flutter_infra/src/network/core/network_interceptor.dart';

class NetworkConfig {
  final bool enableLogging;
  final List<NetworkInterceptor> interceptors;
  final Duration timeout;
  final String? baseUrl;
  final Map<String, String> defaultHeaders;
  final int maxLoggerWidth;

  const NetworkConfig({
    this.enableLogging = false,
    this.maxLoggerWidth = 200,
    this.interceptors = const [],
    this.timeout = const Duration(seconds: 30),
    this.baseUrl,
    this.defaultHeaders = const {
      "Content-Type": "application/json",
      "Accept": "application/json",
    },
  });
}
