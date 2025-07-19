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

  // Factory method for creating NetworkService with caching support
  static Future<NetworkService> createWithCache({
    NetworkClient? client,
    NetworkConfig? config,
    CacheConfig? cacheConfig,
  }) async {
    final baseClient = client ?? HttpNetworkClient(config: config);
    final cachedClient = CachedNetworkClient(
      wrappedClient: baseClient,
      cacheConfig: cacheConfig,
    );

    return NetworkService(client: cachedClient);
  }

  // Factory method for creating NetworkService with both token and cache support
  static Future<NetworkService> createWithTokenAndCache({
    NetworkClient? client,
    NetworkConfig? config,
    CacheConfig? cacheConfig,
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

    final baseClient = client ?? HttpNetworkClient(config: finalConfig);
    final cachedClient = CachedNetworkClient(
      wrappedClient: baseClient,
      cacheConfig: cacheConfig,
    );

    return NetworkService(client: cachedClient);
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

  /// Clears the cache if using a cached client
  void clearCache() {
    if (_client is CachedNetworkClient) {
      (_client).clearCache();
    }
  }

  /// Clears cache for a specific endpoint pattern if using a cached client
  void clearCacheForEndpoint(String pathPattern) {
    if (_client is CachedNetworkClient) {
      (_client).clearCacheForEndpoint(pathPattern);
    }
  }

  /// Gets cache statistics if using a cached client
  Map<String, dynamic>? getCacheStats() {
    if (_client is CachedNetworkClient) {
      return (_client).getCacheStats();
    }
    return null;
  }

  /// Checks if this service is using caching
  bool get isCacheEnabled => _client is CachedNetworkClient;

  void dispose() {
    if (_client is HttpNetworkClient) {
      (_client).dispose();
    } else if (_client is DioNetworkClient) {
      (_client).dispose();
    }
  }
}
