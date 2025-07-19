# Cache Interceptor

The Cache Interceptor provides transparent HTTP response caching to improve app performance and reduce network usage. It's designed to be configurable and optional, allowing you to add caching to your REST APIs with minimal setup.

## Overview

The cache interceptor automatically:
- Caches successful HTTP responses based on configurable rules
- Returns cached responses when available and valid
- Manages cache expiration and cleanup
- Provides cache statistics and management utilities
- Supports custom cache durations per endpoint

## Quick Start

### Basic Usage

```dart
import 'package:flutter_infra/flutter_infra.dart';

// Create a NetworkService with caching enabled
final networkService = await NetworkService.createWithCache(
  config: NetworkConfig(
    baseUrl: 'https://api.example.com',
  ),
  cacheConfig: CacheConfig(
    defaultCacheDuration: Duration(minutes: 5),
    maxCacheSize: 100,
  ),
);

// Make requests - responses will be cached automatically
final response = await networkService.getJson('/users');
```

### Advanced Configuration

```dart
final cacheConfig = CacheConfig(
  // Default cache duration
  defaultCacheDuration: Duration(minutes: 5),
  
  // Maximum number of cached entries
  maxCacheSize: 50,
  
  // Only cache GET requests
  cacheOnlyGetRequests: true,
  
  // Custom cache durations per endpoint
  customCacheDurations: {
    '/users': Duration(hours: 1),
    '/posts': Duration(minutes: 10),
    '/profile': Duration(minutes: 30),
  },
  
  // Endpoints that should never be cached
  noCacheEndpoints: {
    '/auth/login',
    '/auth/logout',
    '/upload',
  },
  
  // HTTP methods that should be cached
  cacheableMethods: {'GET'},
  
  // Status codes that should be cached
  cacheableStatusCodes: {200, 201, 202, 203, 204},
  
  // Headers to exclude from cache key generation
  excludeHeadersFromCacheKey: {
    'authorization',
    'user-agent',
    'x-request-id',
  },
  
  // Include query parameters in cache key
  includeQueryParamsInCacheKey: true,
  
  // Enable/disable caching
  enabled: true,
);

final networkService = await NetworkService.createWithCache(
  cacheConfig: cacheConfig,
);
```

## Cache Configuration Options

### CacheConfig Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `defaultCacheDuration` | `Duration` | `Duration(minutes: 5)` | Default cache duration for responses |
| `maxCacheSize` | `int` | `100` | Maximum number of cached entries |
| `cacheOnlyGetRequests` | `bool` | `true` | Whether to cache only GET requests |
| `cacheableMethods` | `Set<String>` | `{'GET'}` | HTTP methods that should be cached |
| `cacheableStatusCodes` | `Set<int>` | `{200, 201, 202, 203, 204}` | Status codes that should be cached |
| `excludeHeadersFromCacheKey` | `Set<String>` | See below | Headers excluded from cache key |
| `includeQueryParamsInCacheKey` | `bool` | `true` | Include query params in cache key |
| `enabled` | `bool` | `true` | Enable/disable caching |
| `customCacheDurations` | `Map<String, Duration>` | `{}` | Custom cache durations per endpoint |
| `noCacheEndpoints` | `Set<String>` | `{}` | Endpoints that should never be cached |

### Default Excluded Headers

The following headers are excluded from cache key generation by default:
- `authorization`
- `user-agent`
- `x-request-id`
- `x-correlation-id`

## Usage Patterns

### Basic Caching

```dart
// Create service with default cache configuration
final networkService = await NetworkService.createWithCache();

// All GET requests will be cached for 5 minutes
final users = await networkService.getJson('/users');
final posts = await networkService.getJson('/posts');
```

### Custom Cache Durations

```dart
final cacheConfig = CacheConfig(
  customCacheDurations: {
    '/users': Duration(hours: 1),      // Cache users for 1 hour
    '/posts': Duration(minutes: 30),   // Cache posts for 30 minutes
    '/comments': Duration(minutes: 5), // Cache comments for 5 minutes
  },
);

final networkService = await NetworkService.createWithCache(
  cacheConfig: cacheConfig,
);
```

### Selective Caching

```dart
final cacheConfig = CacheConfig(
  noCacheEndpoints: {
    '/auth/login',
    '/auth/refresh',
    '/user/password',
    '/upload',
  },
);

final networkService = await NetworkService.createWithCache(
  cacheConfig: cacheConfig,
);
```

### Cache with Authentication

```dart
final networkService = await NetworkService.createWithTokenAndCache(
  config: NetworkConfig(
    baseUrl: 'https://api.example.com',
  ),
  cacheConfig: CacheConfig(
    defaultCacheDuration: Duration(minutes: 10),
  ),
  tokenManager: MyTokenManager(),
);
```

## Cache Management

### Clearing Cache

```dart
// Clear all cache
networkService.clearCache();

// Clear cache for specific endpoints
networkService.clearCacheForEndpoint('/users');
networkService.clearCacheForEndpoint('/posts');
```

### Cache Statistics

```dart
// Get cache statistics
final stats = networkService.getCacheStats();
if (stats != null) {
  print('Total entries: ${stats['totalEntries']}');
  print('Valid entries: ${stats['validEntries']}');
  print('Expired entries: ${stats['expiredEntries']}');
  print('Hit rate: ${stats['hitRate']}');
}

// Check if caching is enabled
if (networkService.isCacheEnabled) {
  print('Caching is enabled');
}
```

## Cache Key Generation

Cache keys are generated based on:
1. HTTP method (e.g., GET, POST)
2. Request path
3. Query parameters (if `includeQueryParamsInCacheKey` is true)
4. Relevant headers (excluding configured excluded headers)

The final cache key is a SHA-256 hash for consistent length and uniqueness.

## Cache Headers

When a cached response is returned, additional headers are added:
- `x-cache: HIT` - Indicates this is a cached response
- `x-cache-age: <seconds>` - Age of the cached response in seconds

## Using with Wrapper Client

For more control, you can use the `CachedNetworkClient` directly:

```dart
import 'package:flutter_infra/flutter_infra.dart';

// Create base client
final baseClient = HttpNetworkClient(
  config: NetworkConfig(baseUrl: 'https://api.example.com'),
);

// Wrap with caching
final cachedClient = CachedNetworkClient(
  wrappedClient: baseClient,
  cacheConfig: CacheConfig(
    defaultCacheDuration: Duration(minutes: 10),
  ),
);

// Use directly
final response = await cachedClient.get('/users');

// Access cache functionality
cachedClient.clearCache();
final stats = cachedClient.getCacheStats();
```

## Best Practices

### 1. Cache Duration Strategy

```dart
final cacheConfig = CacheConfig(
  customCacheDurations: {
    // Long-lived data
    '/countries': Duration(days: 1),
    '/categories': Duration(hours: 6),
    
    // Frequently updated data
    '/notifications': Duration(minutes: 1),
    '/user/stats': Duration(minutes: 5),
    
    // Moderate update frequency
    '/posts': Duration(minutes: 30),
    '/users': Duration(hours: 1),
  },
);
```

### 2. Exclude Dynamic Endpoints

```dart
final cacheConfig = CacheConfig(
  noCacheEndpoints: {
    '/auth/login',
    '/auth/logout',
    '/auth/refresh',
    '/upload',
    '/download',
    '/user/password',
    '/payments',
  },
);
```

### 3. Appropriate Cache Size

```dart
final cacheConfig = CacheConfig(
  // Adjust based on your app's memory constraints
  maxCacheSize: 50,  // Small app
  // maxCacheSize: 200,  // Medium app
  // maxCacheSize: 500,  // Large app
);
```

### 4. Headers to Exclude

```dart
final cacheConfig = CacheConfig(
  excludeHeadersFromCacheKey: {
    'authorization',      // User-specific auth tokens
    'user-agent',         // Client-specific info
    'x-request-id',       // Request tracing
    'x-correlation-id',   // Request correlation
    'accept-language',    // If you want same data regardless of language
  },
);
```

## Error Handling

The cache interceptor handles errors gracefully:
- Network errors are not cached
- Invalid responses are not cached
- Expired cache entries are automatically cleaned up
- Cache operations don't interfere with request/response flow

## Performance Considerations

- Cache uses in-memory storage (LinkedHashMap)
- LRU (Least Recently Used) eviction when cache size limit is reached
- Automatic cleanup of expired entries
- Cache key generation uses SHA-256 hashing for consistent performance

## Limitations

- Cache is stored in memory and doesn't persist across app restarts
- Cache size is limited to prevent memory issues
- Only successful responses (configurable status codes) are cached
- Cache keys don't currently support complex pattern matching

## Migration Guide

If you're upgrading from a previous version:

1. **Replace manual caching** with the cache interceptor
2. **Update factory methods** to use `createWithCache()`
3. **Configure cache settings** based on your previous implementation
4. **Test cache behavior** with your specific endpoints

For more examples, see the [examples directory](../example/) in the package. 