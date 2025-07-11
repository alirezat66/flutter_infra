import 'dart:convert';
import 'package:flutter_infra/flutter_infra.dart';

class NetworkService {
  final NetworkClient _client;

  NetworkService({NetworkClient? client})
    : _client = client ?? _getDefaultClient();

  static NetworkClient _getDefaultClient() {
    // This will be replaced with actual default when implementations are ready
    throw UnimplementedError('Default network client not yet implemented');
  }

  // Factory method for easy creation with defaults
  static Future<NetworkService> create({
    NetworkClient? client,
    NetworkConfig? config,
  }) async {
    return NetworkService(client: client ?? HttpNetworkClient(config: config));
  }

  // Factory method for creating NetworkService with TokenInterceptor
  static Future<NetworkService> createWithTokenSupport({
    NetworkClient? client,
    NetworkConfig? config,
    TokenManager? tokenManager,
    TokenRefreshStrategy? refreshStrategy,
  }) async {
    // Create TokenInterceptor with optional refresh strategy
    final tokenInterceptor = TokenInterceptor(
      tokenManager: tokenManager,
      refreshStrategy: refreshStrategy,
    );

    // Merge with existing interceptors or create new list
    final existingInterceptors =
        config?.interceptors ?? [const LoggerInterceptor()];
    final allInterceptors = [...existingInterceptors, tokenInterceptor];

    final finalConfig = NetworkConfig(
      enableLogging: config?.enableLogging ?? true,
      maxLoggerWidth: config?.maxLoggerWidth ?? 200,
      timeout: config?.timeout ?? const Duration(seconds: 30),
      baseUrl: config?.baseUrl,
      defaultHeaders:
          config?.defaultHeaders ??
          const {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
      interceptors: allInterceptors,
    );

    return NetworkService(
      client: client ?? HttpNetworkClient(config: finalConfig),
    );
  }

  // Basic HTTP methods
  Future<NetworkResponse> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) => _client.get(path, queryParameters: queryParameters);

  Future<NetworkResponse> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) => _client.post(path, data: data, queryParameters: queryParameters);

  Future<NetworkResponse> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) => _client.put(path, data: data, queryParameters: queryParameters);

  Future<NetworkResponse> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) => _client.delete(path, queryParameters: queryParameters);

  // Convenience JSON methods
  Future<Map<String, dynamic>?> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await get(path, queryParameters: queryParameters);
    if (response.isSuccess && response.data != null) {
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else if (response.data is String) {
        try {
          return jsonDecode(response.data as String) as Map<String, dynamic>;
        } catch (e) {
          throw Exception('Failed to parse JSON response: ${e.toString()}');
        }
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> postJson(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? jsonBody,
  }) async {
    final response = await post(
      path,
      data: jsonBody,
      queryParameters: queryParameters,
    );

    if (response.isSuccess && response.data != null) {
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else if (response.data is String) {
        try {
          return jsonDecode(response.data as String) as Map<String, dynamic>;
        } catch (e) {
          throw Exception('Failed to parse JSON response: ${e.toString()}');
        }
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> putJson(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? jsonBody,
  }) async {
    final response = await put(
      path,
      data: jsonBody,
      queryParameters: queryParameters,
    );

    if (response.isSuccess && response.data != null) {
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else if (response.data is String) {
        try {
          return jsonDecode(response.data as String) as Map<String, dynamic>;
        } catch (e) {
          throw Exception('Failed to parse JSON response: ${e.toString()}');
        }
      }
    }
    return null;
  }

  // Utility methods
  NetworkClient get client => _client;

  void dispose() {
    if (_client is HttpNetworkClient) {
      (_client).dispose();
    } else if (_client is DioNetworkClient) {
      (_client).dispose();
    }
  }
}
