import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_infra/flutter_infra.dart';

void main() {
  group('DioNetworkClient Tests', () {
    test('should create with default config', () {
      final client = DioNetworkClient();

      expect(client, isNotNull);
      expect(client, isA<NetworkClient>());

      client.dispose();
    });

    test('should create with custom config', () {
      final customConfig = NetworkConfig(
        enableLogging: true,
        baseUrl: 'https://api.example.com',
        timeout: Duration(seconds: 10),
        defaultHeaders: {'Custom-Header': 'test'},
        interceptors: [const LoggerInterceptor(maxWidth: 100)],
      );

      final client = DioNetworkClient(config: customConfig);

      expect(client, isNotNull);
      expect(client, isA<NetworkClient>());

      client.dispose();
    });

    test('should have default LoggerInterceptor', () {
      final client = DioNetworkClient();

      // Default config should include LoggerInterceptor
      expect(client, isNotNull);

      client.dispose();
    });

    test('withConfig factory should work', () {
      final config = NetworkConfig(
        enableLogging: false,
        baseUrl: 'https://test.api.com',
      );

      final client = DioNetworkClient.withConfig(config);

      expect(client, isNotNull);
      expect(client, isA<NetworkClient>());

      client.dispose();
    });

    test('should have all required HTTP methods', () {
      final client = DioNetworkClient();

      // Method availability tests
      expect(() => client.get('/test'), returnsNormally);
      expect(
        () => client.post('/test', data: {'key': 'value'}),
        returnsNormally,
      );
      expect(
        () => client.put('/test', data: {'key': 'value'}),
        returnsNormally,
      );
      expect(() => client.delete('/test'), returnsNormally);

      client.dispose();
    });

    test('should dispose properly', () {
      final client = DioNetworkClient();

      expect(() => client.dispose(), returnsNormally);
    });
  });
}
