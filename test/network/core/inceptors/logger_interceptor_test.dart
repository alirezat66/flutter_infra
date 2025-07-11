import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_infra/flutter_infra.dart';

void main() {
  group('LoggerInterceptor Tests', () {
    test('should create with default maxWidth', () {
      const interceptor = LoggerInterceptor();

      expect(interceptor, isA<NetworkInterceptor>());
      expect(interceptor.maxWidth, 200);
    });

    test('should create with custom maxWidth', () {
      const interceptor = LoggerInterceptor(maxWidth: 100);

      expect(interceptor, isA<NetworkInterceptor>());
      expect(interceptor.maxWidth, 100);
    });

    test('should handle onRequest', () async {
      const interceptor = LoggerInterceptor();

      final request = NetworkRequest(
        method: 'GET',
        path: '/test',
        headers: {'Content-Type': 'application/json'},
        queryParameters: {'id': '123'},
        body: {'data': 'test'},
      );

      // Should not throw
      expect(() => interceptor.onRequest(request), returnsNormally);
      await interceptor.onRequest(request);
    });

    test('should handle onResponse', () async {
      const interceptor = LoggerInterceptor();

      final response = NetworkResponse(
        statusCode: 200,
        data: {'message': 'success'},
        headers: {'Content-Type': 'application/json'},
      );

      // Should not throw
      expect(() => interceptor.onResponse(response), returnsNormally);
      await interceptor.onResponse(response);
    });

    test('should handle onError', () async {
      const interceptor = LoggerInterceptor();

      final error = NetworkError(message: 'Test error', code: 500);

      // Should not throw
      expect(() => interceptor.onError(error), returnsNormally);
      await interceptor.onError(error);
    });

    test('should be usable in NetworkConfig', () {
      const interceptor = LoggerInterceptor(maxWidth: 150);

      final config = NetworkConfig(interceptors: [interceptor]);

      expect(config.interceptors, contains(interceptor));
      expect(config.interceptors.first, isA<LoggerInterceptor>());
    });

    test('should work with both HTTP and Dio clients', () {
      const interceptor = LoggerInterceptor();

      final config = NetworkConfig(
        enableLogging: true,
        interceptors: [interceptor],
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
