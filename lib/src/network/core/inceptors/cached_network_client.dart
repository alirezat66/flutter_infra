import '../api_client.dart';
import '../network_response.dart';
import '../network_request.dart';
import '../network_error.dart';
import 'cache_interceptor.dart';
import 'cache_config.dart';

/// A wrapper NetworkClient that provides caching functionality
/// This wraps any existing NetworkClient and adds transparent caching
class CachedNetworkClient implements NetworkClient {
  final NetworkClient _wrappedClient;
  final CacheInterceptor _cacheInterceptor;

  CachedNetworkClient({
    required NetworkClient wrappedClient,
    CacheConfig? cacheConfig,
  }) : _wrappedClient = wrappedClient,
       _cacheInterceptor = CacheInterceptor(config: cacheConfig);

  @override
  Future<NetworkResponse> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) => _makeRequestWithCache(
    () => _wrappedClient.get(path, queryParameters: queryParameters),
    'GET',
    path,
    queryParameters: queryParameters,
  );

  @override
  Future<NetworkResponse> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) => _makeRequestWithCache(
    () =>
        _wrappedClient.post(path, data: data, queryParameters: queryParameters),
    'POST',
    path,
    data: data,
    queryParameters: queryParameters,
  );

  @override
  Future<NetworkResponse> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) => _makeRequestWithCache(
    () =>
        _wrappedClient.put(path, data: data, queryParameters: queryParameters),
    'PUT',
    path,
    data: data,
    queryParameters: queryParameters,
  );

  @override
  Future<NetworkResponse> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) => _makeRequestWithCache(
    () => _wrappedClient.delete(path, queryParameters: queryParameters),
    'DELETE',
    path,
    queryParameters: queryParameters,
  );

  /// Makes a request with caching support
  Future<NetworkResponse> _makeRequestWithCache(
    Future<NetworkResponse> Function() makeRequest,
    String method,
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    // Create request object for cache interceptor
    final request = NetworkRequest(
      method: method,
      path: path,
      queryParameters: queryParameters,
      body: data,
      headers: {},
    );

    // Check for cached response
    final cachedResponse = _cacheInterceptor.getCachedResponse(request);
    if (cachedResponse != null) {
      return cachedResponse;
    }

    try {
      // Call the onRequest interceptor
      await _cacheInterceptor.onRequest(request);

      // Make the actual request
      final response = await makeRequest();

      // Add request info to response headers for the cache interceptor
      final responseWithRequestInfo = NetworkResponse(
        statusCode: response.statusCode,
        data: response.data,
        error: response.error,
        headers: {
          ...?response.headers,
          'x-request-method': method,
          'x-request-path': path,
        },
      );

      // Call the onResponse interceptor
      await _cacheInterceptor.onResponse(responseWithRequestInfo);

      return response;
    } catch (e) {
      // Call the onError interceptor
      if (e is Exception) {
        await _cacheInterceptor.onError(
          NetworkError(message: e.toString(), originalException: e),
        );
      }
      rethrow;
    }
  }

  /// Gets the cache interceptor for direct access
  CacheInterceptor get cacheInterceptor => _cacheInterceptor;

  /// Clears the cache
  void clearCache() => _cacheInterceptor.clearCache();

  /// Clears cache for a specific endpoint
  void clearCacheForEndpoint(String pathPattern) =>
      _cacheInterceptor.clearCacheForEndpoint(pathPattern);

  /// Gets cache statistics
  Map<String, dynamic> getCacheStats() => _cacheInterceptor.getCacheStats();

  /// Gets the cache configuration
  CacheConfig get cacheConfig => _cacheInterceptor.config;
}
