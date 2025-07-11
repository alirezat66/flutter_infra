import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_infra/flutter_infra.dart';

void main() {
  group('NetworkConfig Tests', () {
    test('should create with default values', () {
      const config = NetworkConfig();

      expect(config.enableLogging, false);
      expect(config.timeout, Duration(seconds: 30));
      expect(config.baseUrl, null);
      expect(config.defaultHeaders, isNotEmpty);
      expect(config.defaultHeaders['Content-Type'], 'application/json');
      expect(config.defaultHeaders['Accept'], 'application/json');
      expect(config.interceptors, isEmpty);
    });

    test('should create with custom values', () {
      final customHeaders = {'Custom-Header': 'value'};
      final interceptors = [const LoggerInterceptor()];

      final config = NetworkConfig(
        enableLogging: true,
        timeout: Duration(seconds: 10),
        baseUrl: 'https://api.example.com',
        defaultHeaders: customHeaders,
        interceptors: interceptors,
      );

      expect(config.enableLogging, true);
      expect(config.timeout, Duration(seconds: 10));
      expect(config.baseUrl, 'https://api.example.com');
      expect(config.defaultHeaders, customHeaders);
      expect(config.interceptors, interceptors);
    });

    test('should create with mixed default and custom headers', () {
      final config = NetworkConfig(
        defaultHeaders: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer token',
          'Custom-Header': 'value',
        },
      );

      expect(config.defaultHeaders['Content-Type'], 'application/json');
      expect(config.defaultHeaders['Accept'], 'application/json');
      expect(config.defaultHeaders['Authorization'], 'Bearer token');
      expect(config.defaultHeaders['Custom-Header'], 'value');
    });

    test('should support interceptors list', () {
      final interceptors = [
        const LoggerInterceptor(maxWidth: 100),
        // TokenInterceptor(), // Would require storage setup
      ];

      final config = NetworkConfig(interceptors: interceptors);

      expect(config.interceptors, interceptors);
      expect(config.interceptors.length, 1);
      expect(config.interceptors.first, isA<LoggerInterceptor>());
    });

    test('should be immutable', () {
      const config = NetworkConfig();

      // All fields should be final
      expect(config, isA<NetworkConfig>());

      // Default values should not change
      expect(config.enableLogging, false);
      expect(config.timeout, Duration(seconds: 30));
    });

    test('should work with HTTP and Dio clients', () {
      final config = NetworkConfig(
        enableLogging: true,
        baseUrl: 'https://api.test.com',
        timeout: Duration(seconds: 15),
      );

      final httpClient = HttpNetworkClient(config: config);
      final dioClient = DioNetworkClient(config: config);

      expect(httpClient, isNotNull);
      expect(dioClient, isNotNull);

      httpClient.dispose();
      dioClient.dispose();
    });
  });
}
