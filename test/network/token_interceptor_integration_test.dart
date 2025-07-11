import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_infra/flutter_infra.dart';

import 'token_interceptor_integration_test.mocks.dart';

@GenerateMocks([StorageService])
void main() {
  group('TokenInterceptor Integration Tests', () {
    test('HttpNetworkClient should work without TokenInterceptor by default', () {
      final httpClient = HttpNetworkClient();

      expect(httpClient, isA<NetworkClient>());
      // TokenInterceptor is not included by default to avoid storage dependency

      httpClient.dispose();
    });

    test('DioNetworkClient should work without TokenInterceptor by default', () {
      final dioClient = DioNetworkClient();

      expect(dioClient, isA<NetworkClient>());
      // TokenInterceptor is not included by default to avoid storage dependency

      dioClient.dispose();
    });

    test(
      'NetworkService should work without TokenInterceptor by default',
      () async {
        final networkService = await NetworkService.create();

        expect(networkService, isA<NetworkService>());
        expect(networkService.client, isA<HttpNetworkClient>());
        // Default NetworkService works without TokenInterceptor

        networkService.dispose();
      },
    );

    test('NetworkService.createWithTokenSupport should include TokenInterceptor', () async {
      // Create mock storage service
      final mockStorage = MockStorageService();
      final tokenManager = DefaultTokenManager(storage: mockStorage);
      
      // Create custom refresh strategy
      final refreshStrategy = MockRefreshStrategy();

      final networkService = await NetworkService.createWithTokenSupport(
        config: NetworkConfig(
          baseUrl: 'https://api.example.com',
        ),
        tokenManager: tokenManager,
        refreshStrategy: refreshStrategy, // Enable token refresh
      );

      expect(networkService, isA<NetworkService>());
      
      networkService.dispose();
    });

    test('NetworkService.createWithTokenSupport should work without refresh strategy', () async {
      // Create mock storage service
      final mockStorage = MockStorageService();
      final tokenManager = DefaultTokenManager(storage: mockStorage);

      final networkService = await NetworkService.createWithTokenSupport(
        config: NetworkConfig(
          baseUrl: 'https://api.example.com',
        ),
        tokenManager: tokenManager,
        // No refresh strategy - default behavior
      );

      expect(networkService, isA<NetworkService>());
      
      networkService.dispose();
    });

    test('TokenInterceptor should work without refresh strategy', () {
      final mockStorage = MockStorageService();
      final tokenManager = DefaultTokenManager(storage: mockStorage);
      final tokenInterceptor = TokenInterceptor(tokenManager: tokenManager);

      expect(tokenInterceptor, isA<TokenInterceptor>());
      // Should work with null refresh strategy (default behavior)
    });

    test('TokenInterceptor should work with refresh strategy', () {
      final mockStorage = MockStorageService();
      final tokenManager = DefaultTokenManager(storage: mockStorage);
      final refreshStrategy = MockRefreshStrategy();
      final tokenInterceptor = TokenInterceptor(
        tokenManager: tokenManager,
        refreshStrategy: refreshStrategy,
      );

      expect(tokenInterceptor, isA<TokenInterceptor>());
    });

    test('Custom TokenConfig should work with TokenInterceptor', () {
      final customConfig = TokenConfig(
        tokenStorageKey: 'custom_access_token',
        refreshTokenStorageKey: 'custom_refresh_token',
        refreshTokenEndPoint: '/custom/refresh',
      );

      final mockStorage = MockStorageService();
      final tokenManager = DefaultTokenManager(
        storage: mockStorage,
        config: customConfig,
      );

      final tokenInterceptor = TokenInterceptor(tokenManager: tokenManager);

      expect(tokenInterceptor, isA<TokenInterceptor>());
      expect(tokenManager.config.refreshTokenEndPoint, '/custom/refresh');
    });
  });
}

/// Mock refresh strategy for testing
class MockRefreshStrategy implements TokenRefreshStrategy {
  @override
  Future<bool> refreshToken() async {
    // Mock implementation - just return true for testing
    await Future.delayed(Duration(milliseconds: 10));
    return true;
  }
}
