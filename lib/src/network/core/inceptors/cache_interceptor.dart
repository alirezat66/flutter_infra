import 'dart:convert';
import 'dart:collection';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import '../network_interceptor.dart';
import '../network_request.dart';
import '../network_response.dart';
import '../network_error.dart';
import 'cache_config.dart';
import 'cache_entry.dart';

/// Network interceptor that provides HTTP response caching
class CacheInterceptor implements NetworkInterceptor {
  final CacheConfig _config;
  final LinkedHashMap<String, CacheEntry> _cache = LinkedHashMap();

  CacheInterceptor({CacheConfig? config})
    : _config = config ?? const CacheConfig();

  @override
  Future<void> onRequest(NetworkRequest request) async {
    if (!_shouldCacheRequest(request)) return;

    final cacheKey = _generateCacheKey(request);
    final cachedEntry = _cache[cacheKey];

    if (cachedEntry != null && cachedEntry.isValid) {
      // Add cache headers to indicate this is a cached response
      final cachedResponse = NetworkResponse(
        statusCode: cachedEntry.response.statusCode,
        data: cachedEntry.response.data,
        error: cachedEntry.response.error,
        headers: {
          ...?cachedEntry.response.headers,
          'x-cache': 'HIT',
          'x-cache-age': cachedEntry.age.inSeconds.toString(),
        },
      );

      // Store cached response in request for later retrieval
      // This is a workaround since we can't return responses from onRequest
      request.headers['x-cached-response'] = jsonEncode({
        'statusCode': cachedResponse.statusCode,
        'data': cachedResponse.data,
        'headers': cachedResponse.headers,
      });

      if (_config.enabled && kDebugMode) {
        debugPrint('🗄️ Cache HIT for: ${request.method} ${request.path}');
      }
    }
  }

  @override
  Future<void> onResponse(NetworkResponse response) async {
    // Check if this response should be cached
    if (!_shouldCacheResponse(response)) return;

    // Extract the request info from response headers (if available)
    final method = response.headers?['x-request-method'] ?? 'GET';
    final path = response.headers?['x-request-path'] ?? '';

    if (path.isEmpty) return;

    final request = NetworkRequest(method: method, path: path, headers: {});

    if (!_shouldCacheRequest(request)) return;

    final cacheKey = _generateCacheKey(request);
    final duration = _config.getCacheDurationForEndpoint(path);

    // Create cache entry
    final cacheEntry = CacheEntry.withDuration(
      response: response,
      duration: duration,
      cacheKey: cacheKey,
    );

    // Add to cache
    _addToCache(cacheKey, cacheEntry);

    if (_config.enabled && kDebugMode) {
      debugPrint(
        '💾 Cached response for: $method $path (expires in ${duration.inMinutes}m)',
      );
    }
  }

  @override
  Future<void> onError(NetworkError error) async {
    // Don't cache error responses
    if (_config.enabled && kDebugMode) {
      debugPrint('❌ Not caching error response: ${error.message}');
    }
  }

  /// Checks if a request should be cached
  bool _shouldCacheRequest(NetworkRequest request) {
    if (!_config.enabled) return false;
    if (!_config.shouldCacheEndpoint(request.path)) return false;

    final method = request.method.toUpperCase();
    return _config.cacheableMethods.contains(method);
  }

  /// Checks if a response should be cached
  bool _shouldCacheResponse(NetworkResponse response) {
    if (!_config.enabled) return false;
    return _config.cacheableStatusCodes.contains(response.statusCode);
  }

  /// Generates a cache key for the request
  String _generateCacheKey(NetworkRequest request) {
    final buffer = StringBuffer();

    // Add method and path
    buffer.write('${request.method.toUpperCase()}:${request.path}');

    // Add query parameters if configured
    if (_config.includeQueryParamsInCacheKey &&
        request.queryParameters != null &&
        request.queryParameters!.isNotEmpty) {
      final sortedParams = Map.fromEntries(
        request.queryParameters!.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key)),
      );
      buffer.write(
        '?${Uri(queryParameters: sortedParams.map((k, v) => MapEntry(k, v.toString()))).query}',
      );
    }

    // Add relevant headers (excluding configured ones)
    if (request.headers.isNotEmpty) {
      final relevantHeaders = <String, String>{};
      for (final entry in request.headers.entries) {
        if (!_config.excludeHeadersFromCacheKey.contains(
          entry.key.toLowerCase(),
        )) {
          relevantHeaders[entry.key.toLowerCase()] = entry.value;
        }
      }

      if (relevantHeaders.isNotEmpty) {
        final sortedHeaders = Map.fromEntries(
          relevantHeaders.entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key)),
        );
        buffer.write('|headers:${jsonEncode(sortedHeaders)}');
      }
    }

    // Generate hash of the key for consistent length
    final bytes = utf8.encode(buffer.toString());
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Adds an entry to the cache with LRU eviction
  void _addToCache(String key, CacheEntry entry) {
    // Remove existing entry if it exists
    _cache.remove(key);

    // Add new entry
    _cache[key] = entry;

    // Evict old entries if cache is too large
    while (_cache.length > _config.maxCacheSize) {
      final oldestKey = _cache.keys.first;
      _cache.remove(oldestKey);

      if (kDebugMode) {
        debugPrint('🗑️ Evicted cache entry: $oldestKey');
      }
    }

    // Clean up expired entries periodically
    _cleanupExpiredEntries();
  }

  /// Removes expired entries from cache
  void _cleanupExpiredEntries() {
    final expiredKeys = <String>[];

    for (final entry in _cache.entries) {
      if (entry.value.isExpired) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      _cache.remove(key);
    }

    if (expiredKeys.isNotEmpty && kDebugMode) {
      debugPrint('🧹 Cleaned up ${expiredKeys.length} expired cache entries');
    }
  }

  /// Gets a cached response for the given request
  NetworkResponse? getCachedResponse(NetworkRequest request) {
    if (!_shouldCacheRequest(request)) return null;

    final cacheKey = _generateCacheKey(request);
    final cachedEntry = _cache[cacheKey];

    if (cachedEntry != null && cachedEntry.isValid) {
      return NetworkResponse(
        statusCode: cachedEntry.response.statusCode,
        data: cachedEntry.response.data,
        error: cachedEntry.response.error,
        headers: {
          ...?cachedEntry.response.headers,
          'x-cache': 'HIT',
          'x-cache-age': cachedEntry.age.inSeconds.toString(),
        },
      );
    }

    return null;
  }

  /// Clears the entire cache
  void clearCache() {
    _cache.clear();
    if (kDebugMode) {
      debugPrint('🗑️ Cache cleared');
    }
  }

  /// Clears cache entries for a specific endpoint pattern
  void clearCacheForEndpoint(String pathPattern) {
    final keysToRemove = <String>[];

    for (final entry in _cache.entries) {
      // This is a simple implementation - in a real scenario you might want
      // to store the original path in the cache entry for more precise matching
      if (entry.key.contains(pathPattern)) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      _cache.remove(key);
    }

    if (kDebugMode) {
      debugPrint(
        '🗑️ Cleared ${keysToRemove.length} cache entries for pattern: $pathPattern',
      );
    }
  }

  /// Gets cache statistics
  Map<String, dynamic> getCacheStats() {
    final totalEntries = _cache.length;
    final expiredEntries =
        _cache.values.where((entry) => entry.isExpired).length;
    final validEntries = totalEntries - expiredEntries;

    return {
      'totalEntries': totalEntries,
      'validEntries': validEntries,
      'expiredEntries': expiredEntries,
      'maxSize': _config.maxCacheSize,
      'hitRate':
          '${((validEntries / (totalEntries > 0 ? totalEntries : 1)) * 100).toStringAsFixed(1)}%',
    };
  }

  /// Gets the current cache configuration
  CacheConfig get config => _config;
}
