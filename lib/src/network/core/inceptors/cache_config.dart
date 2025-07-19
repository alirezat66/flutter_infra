/// Configuration class for caching behavior
class CacheConfig {
  /// Default cache duration for responses
  final Duration defaultCacheDuration;

  /// Maximum number of cached entries
  final int maxCacheSize;

  /// Whether to cache only GET requests
  final bool cacheOnlyGetRequests;

  /// HTTP methods that should be cached
  final Set<String> cacheableMethods;

  /// Status codes that should be cached
  final Set<int> cacheableStatusCodes;

  /// Headers that should be excluded from cache key generation
  final Set<String> excludeHeadersFromCacheKey;

  /// Whether to include query parameters in cache key
  final bool includeQueryParamsInCacheKey;

  /// Whether to enable cache
  final bool enabled;

  /// Custom cache duration per endpoint pattern
  final Map<String, Duration> customCacheDurations;

  /// Endpoints that should never be cached
  final Set<String> noCacheEndpoints;

  const CacheConfig({
    this.defaultCacheDuration = const Duration(minutes: 5),
    this.maxCacheSize = 100,
    this.cacheOnlyGetRequests = true,
    this.cacheableMethods = const {'GET'},
    this.cacheableStatusCodes = const {200, 201, 202, 203, 204},
    this.excludeHeadersFromCacheKey = const {
      'authorization',
      'user-agent',
      'x-request-id',
      'x-correlation-id',
    },
    this.includeQueryParamsInCacheKey = true,
    this.enabled = true,
    this.customCacheDurations = const {},
    this.noCacheEndpoints = const {},
  });

  /// Creates a copy of this config with updated values
  CacheConfig copyWith({
    Duration? defaultCacheDuration,
    int? maxCacheSize,
    bool? cacheOnlyGetRequests,
    Set<String>? cacheableMethods,
    Set<int>? cacheableStatusCodes,
    Set<String>? excludeHeadersFromCacheKey,
    bool? includeQueryParamsInCacheKey,
    bool? enabled,
    Map<String, Duration>? customCacheDurations,
    Set<String>? noCacheEndpoints,
  }) {
    return CacheConfig(
      defaultCacheDuration: defaultCacheDuration ?? this.defaultCacheDuration,
      maxCacheSize: maxCacheSize ?? this.maxCacheSize,
      cacheOnlyGetRequests: cacheOnlyGetRequests ?? this.cacheOnlyGetRequests,
      cacheableMethods: cacheableMethods ?? this.cacheableMethods,
      cacheableStatusCodes: cacheableStatusCodes ?? this.cacheableStatusCodes,
      excludeHeadersFromCacheKey:
          excludeHeadersFromCacheKey ?? this.excludeHeadersFromCacheKey,
      includeQueryParamsInCacheKey:
          includeQueryParamsInCacheKey ?? this.includeQueryParamsInCacheKey,
      enabled: enabled ?? this.enabled,
      customCacheDurations: customCacheDurations ?? this.customCacheDurations,
      noCacheEndpoints: noCacheEndpoints ?? this.noCacheEndpoints,
    );
  }

  /// Gets cache duration for a specific endpoint
  Duration getCacheDurationForEndpoint(String path) {
    // Check for exact endpoint match
    if (customCacheDurations.containsKey(path)) {
      return customCacheDurations[path]!;
    }

    // Check for pattern matches (simple contains check)
    for (final pattern in customCacheDurations.keys) {
      if (path.contains(pattern)) {
        return customCacheDurations[pattern]!;
      }
    }

    return defaultCacheDuration;
  }

  /// Checks if an endpoint should be cached
  bool shouldCacheEndpoint(String path) {
    if (!enabled) return false;

    // Check if endpoint is in no-cache list
    if (noCacheEndpoints.contains(path)) return false;

    // Check for pattern matches in no-cache endpoints
    for (final noCache in noCacheEndpoints) {
      if (path.contains(noCache)) return false;
    }

    return true;
  }
}
