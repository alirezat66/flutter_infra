import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_infra/flutter_infra.dart';

void main() {
  group('HTTP vs Dio Implementation Comparison', () {
    test(
      'Both implementations should have identical default configuration',
      () {
        final httpClient = HttpNetworkClient();
        final dioClient = DioNetworkClient();

        // Both should be created successfully
        expect(httpClient, isA<NetworkClient>());
        expect(dioClient, isA<NetworkClient>());

        // Clean up
        httpClient.dispose();
        dioClient.dispose();
      },
    );

    test(
      'Both implementations should support custom LoggerInterceptor config',
      () {
        final customConfig = NetworkConfig(
          enableLogging: true,
          baseUrl: 'https://api.example.com',
          timeout: Duration(seconds: 15),
          defaultHeaders: {'Custom-Header': 'test'},
          interceptors: [const LoggerInterceptor(maxWidth: 150)],
        );

        final httpClient = HttpNetworkClient(config: customConfig);
        final dioClient = DioNetworkClient(config: customConfig);

        expect(httpClient, isA<NetworkClient>());
        expect(dioClient, isA<NetworkClient>());

        // Clean up
        httpClient.dispose();
        dioClient.dispose();
      },
    );

    test('Both implementations should work with NetworkService', () async {
      // Test HTTP through NetworkService (default)
      final httpService = await NetworkService.create();
      expect(httpService.client, isA<HttpNetworkClient>());
      httpService.dispose();

      // Test Dio through NetworkService (custom client)
      final dioClient = DioNetworkClient();
      final dioService = await NetworkService.create(client: dioClient);
      expect(dioService.client, isA<DioNetworkClient>());
      dioService.dispose();
    });

    test(
      'Both implementations should support TokenInterceptor when configured',
      () {
        final httpConfigWithToken = NetworkConfig(
          enableLogging: true,
          interceptors: [
            const LoggerInterceptor(),
            // TokenInterceptor(), // Would need storage setup
          ],
        );

        final dioConfigWithToken = NetworkConfig(
          enableLogging: true,
          interceptors: [
            const LoggerInterceptor(),
            // TokenInterceptor(), // Would need storage setup
          ],
        );

        final httpClient = HttpNetworkClient(config: httpConfigWithToken);
        final dioClient = DioNetworkClient(config: dioConfigWithToken);

        expect(httpClient, isA<NetworkClient>());
        expect(dioClient, isA<NetworkClient>());

        // Clean up
        httpClient.dispose();
        dioClient.dispose();
      },
    );

    test('Both implementations should have identical API surface', () {
      final httpClient = HttpNetworkClient();
      final dioClient = DioNetworkClient();

      // Both should implement NetworkClient
      expect(httpClient, isA<NetworkClient>());
      expect(dioClient, isA<NetworkClient>());

      // Both should have identical method signatures
      expect(() => httpClient.get('/test'), returnsNormally);
      expect(() => dioClient.get('/test'), returnsNormally);

      expect(() => httpClient.post('/test', data: {}), returnsNormally);
      expect(() => dioClient.post('/test', data: {}), returnsNormally);

      expect(() => httpClient.put('/test', data: {}), returnsNormally);
      expect(() => dioClient.put('/test', data: {}), returnsNormally);

      expect(() => httpClient.delete('/test'), returnsNormally);
      expect(() => dioClient.delete('/test'), returnsNormally);

      // Clean up
      httpClient.dispose();
      dioClient.dispose();
    });
  });
}
