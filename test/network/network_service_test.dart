import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_infra/flutter_infra.dart';

void main() {
  group('NetworkService Tests', () {
    test('NetworkService.create() should use HTTP by default', () async {
      final service = await NetworkService.create();

      expect(service, isNotNull);
      expect(service.client, isA<HttpNetworkClient>());

      service.dispose();
    });

    test('NetworkService.create() should accept custom config', () async {
      final customConfig = NetworkConfig(
        enableLogging: true,
        baseUrl: 'https://api.example.com',
        timeout: Duration(seconds: 10),
        defaultHeaders: {'Custom-Header': 'test'},
        interceptors: [const LoggerInterceptor(maxWidth: 100)],
      );

      final service = await NetworkService.create(config: customConfig);

      expect(service.client, isA<HttpNetworkClient>());

      service.dispose();
    });

    test('NetworkService should accept custom client implementation', () async {
      final customClient = DioNetworkClient(
        config: NetworkConfig(
          enableLogging: false,
          baseUrl: 'https://custom.api.com',
        ),
      );

      final service = await NetworkService.create(client: customClient);

      expect(service.client, same(customClient));

      service.dispose();
    });

    test('NetworkService should have all HTTP methods', () async {
      final service = await NetworkService.create();

      // Should not throw, these are method availability tests
      expect(() => service.get('/test'), returnsNormally);
      expect(
        () => service.post('/test', data: {'key': 'value'}),
        returnsNormally,
      );
      expect(
        () => service.put('/test', data: {'key': 'value'}),
        returnsNormally,
      );
      expect(() => service.delete('/test'), returnsNormally);

      service.dispose();
    });

    test('NetworkService should have JSON convenience methods', () async {
      final service = await NetworkService.create();

      // Should not throw, these are method availability tests
      expect(() => service.getJson('/test'), returnsNormally);
      expect(
        () => service.postJson('/test', jsonBody: {'key': 'value'}),
        returnsNormally,
      );
      expect(
        () => service.putJson('/test', jsonBody: {'key': 'value'}),
        returnsNormally,
      );

      service.dispose();
    });

    test('NetworkService direct constructor should work with defaults', () {
      try {
        NetworkService();
        fail('Should throw UnimplementedError for default client');
      } catch (e) {
        expect(e, isA<UnimplementedError>());
        expect(
          e.toString(),
          contains('Default network client not yet implemented'),
        );
      }
    });

    test(
      'NetworkService direct constructor should work with provided client',
      () {
        final client = HttpNetworkClient();
        final service = NetworkService(client: client);

        expect(service.client, same(client));

        service.dispose();
      },
    );

    group('Dependency Injection Usage Examples', () {
      test('Should work in repository pattern like StorageService', () async {
        // Example repository using NetworkService
        final networkService = await NetworkService.create(
          config: NetworkConfig(
            baseUrl: 'https://jsonplaceholder.typicode.com',
            enableLogging: true,
          ),
        );

        final userRepository = UserRepository(networkService);

        expect(userRepository.networkService, same(networkService));

        networkService.dispose();
      });

      test('Should support both HTTP and Dio through custom clients', () async {
        final httpService = await NetworkService.create();

        final dioClient = DioNetworkClient();
        final dioService = await NetworkService.create(client: dioClient);

        final httpRepository = UserRepository(httpService);
        final dioRepository = UserRepository(dioService);

        expect(httpRepository.networkService.client, isA<HttpNetworkClient>());
        expect(dioRepository.networkService.client, isA<DioNetworkClient>());

        httpService.dispose();
        dioService.dispose();
      });

      test('Should support custom interceptors configuration', () async {
        final serviceWithInterceptors = await NetworkService.create(
          config: NetworkConfig(
            enableLogging: true,
            interceptors: [
              const LoggerInterceptor(maxWidth: 200),
              // TokenInterceptor(), // Would be added when storage is configured
            ],
          ),
        );

        expect(serviceWithInterceptors, isNotNull);

        serviceWithInterceptors.dispose();
      });
    });
  });
}

// Example repository class for testing DI patterns
class UserRepository {
  final NetworkService networkService;

  UserRepository(this.networkService);

  Future<Map<String, dynamic>?> getUser(int id) async {
    return await networkService.getJson('/users/$id');
  }

  Future<Map<String, dynamic>?> createUser(
    Map<String, dynamic> userData,
  ) async {
    return await networkService.postJson('/users', jsonBody: userData);
  }

  Future<Map<String, dynamic>?> updateUser(
    int id,
    Map<String, dynamic> userData,
  ) async {
    return await networkService.putJson('/users/$id', jsonBody: userData);
  }

  Future<NetworkResponse> deleteUser(int id) async {
    return await networkService.delete('/users/$id');
  }
}
