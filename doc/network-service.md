# 🌐 Network Service Documentation

The Network Service provides a robust HTTP client with automatic token management, interceptors, and support for both simple and advanced networking needs.

## 📖 Table of Contents
- [Quick Start](#quick-start)
- [Client Implementations](#client-implementations)
- [Network Configuration](#network-configuration)
- [Interceptor System](#interceptor-system)
- [Token Integration](#token-integration)
- [Best Practices](#best-practices)
- [Examples](#examples)

## 🚀 Quick Start

### Basic Usage (No Authentication)
```dart
import 'package:flutter_infra/flutter_infra.dart';

// Create a basic network service
final networkService = await NetworkService.create(
  config: NetworkConfig(
    baseUrl: 'https://api.example.com',
    enableLogging: true,
  ),
);

// Make HTTP requests
final response = await networkService.get('/users');
final postResponse = await networkService.post('/users', data: {
  'name': 'John Doe',
  'email': 'john@example.com',
});
```

### With Authentication Support
```dart
// Create storage service for token management
final storageService = await StorageService.create();

// Create network service with token support
final networkService = await NetworkService.createWithTokenSupport(
  config: NetworkConfig(
    baseUrl: 'https://api.example.com',
    enableLogging: true,
    timeout: Duration(seconds: 30),
    defaultHeaders: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'MyApp/1.0',
    },
  ),
  tokenManager: DefaultTokenManager(storage: storageService),
);

// Tokens are automatically added to requests
final userProfile = await networkService.get('/protected/profile');
```

### JSON Convenience Methods
```dart
// GET JSON with automatic parsing
final userMap = await networkService.getJson('/users/123');

// POST JSON with automatic serialization
final createdUser = await networkService.postJson(
  '/users',
  jsonBody: {'name': 'Jane', 'email': 'jane@example.com'},
);

// PUT JSON
final updatedUser = await networkService.putJson(
  '/users/123',
  jsonBody: {'name': 'Jane Smith'},
);
```

## 🏗️ Client Implementations

### HttpNetworkClient (dart:io)
**Best for**: Lightweight applications, minimal dependencies

```dart
final networkService = await NetworkService.create(
  client: HttpNetworkClient.withConfig(
    NetworkConfig(
      baseUrl: 'https://api.example.com',
      timeout: Duration(seconds: 15),
    ),
  ),
);
```

**Features:**
- ✅ Built into Flutter (no extra dependencies)
- ✅ Lightweight and fast
- ✅ Good for simple HTTP operations
- ❌ Limited advanced features
- ❌ Basic error handling

### DioNetworkClient (Dio Package)
**Best for**: Advanced features, complex networking needs

```dart
final networkService = await NetworkService.create(
  client: DioNetworkClient.withConfig(
    NetworkConfig(
      baseUrl: 'https://api.example.com',
      timeout: Duration(seconds: 30),
      interceptors: [
        LoggerInterceptor(),
        TokenInterceptor(),
        CustomRetryInterceptor(),
      ],
    ),
  ),
);
```

**Features:**
- ✅ Advanced interceptor system
- ✅ Built-in retry mechanisms
- ✅ Request/response transformation
- ✅ Detailed error information
- ✅ File upload/download support
- ❌ Additional dependency

## ⚙️ Network Configuration

### Basic Configuration
```dart
const config = NetworkConfig(
  baseUrl: 'https://api.example.com',
  enableLogging: true,
  timeout: Duration(seconds: 30),
);
```

### Advanced Configuration
```dart
final config = NetworkConfig(
  baseUrl: 'https://api.example.com',
  enableLogging: true,
  maxLoggerWidth: 200,
  timeout: Duration(seconds: 45),
  defaultHeaders: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'MyApp/1.2.0',
    'X-API-Version': '2.0',
  },
  interceptors: [
    LoggerInterceptor(maxWidth: 150),
    TokenInterceptor(),
    CustomHeaderInterceptor(),
  ],
);
```

### Environment-Specific Configuration
```dart
class ApiConfig {
  static NetworkConfig development() => NetworkConfig(
    baseUrl: 'https://dev-api.example.com',
    enableLogging: true,
    timeout: Duration(seconds: 60), // Longer timeout for debugging
    defaultHeaders: {
      'X-Environment': 'development',
    },
  );
  
  static NetworkConfig staging() => NetworkConfig(
    baseUrl: 'https://staging-api.example.com',
    enableLogging: true,
    timeout: Duration(seconds: 30),
    defaultHeaders: {
      'X-Environment': 'staging',
    },
  );
  
  static NetworkConfig production() => NetworkConfig(
    baseUrl: 'https://api.example.com',
    enableLogging: false, // Disable logging in production
    timeout: Duration(seconds: 30),
    defaultHeaders: {
      'X-Environment': 'production',
    },
  );
}
```

## 🔧 Interceptor System

### Built-in Interceptors

#### LoggerInterceptor
Logs all network requests and responses for debugging:

```dart
const config = NetworkConfig(
  enableLogging: true,
  interceptors: [
    LoggerInterceptor(maxWidth: 200),
  ],
);
```

#### TokenInterceptor
Automatically handles authentication tokens:

```dart
final tokenInterceptor = TokenInterceptor(
  tokenManager: DefaultTokenManager(storage: storageService),
  refreshStrategy: CustomRefreshStrategy(), // Optional
);

const config = NetworkConfig(
  interceptors: [
    LoggerInterceptor(),
    tokenInterceptor,
  ],
);
```

### Custom Interceptors

```dart
class CustomHeaderInterceptor implements NetworkInterceptor {
  @override
  Future<void> onRequest(NetworkRequest request) async {
    request.headers['X-Timestamp'] = DateTime.now().millisecondsSinceEpoch.toString();
    request.headers['X-Request-ID'] = generateRequestId();
  }

  @override
  Future<void> onResponse(NetworkResponse response) async {
    // Log response times, update metrics, etc.
    print('Response received in ${response.headers?['X-Response-Time']}ms');
  }

  @override
  Future<void> onError(NetworkError error) async {
    // Send error reports, trigger analytics, etc.
    analytics.trackError(error);
  }
}
```

#### Retry Interceptor Example
```dart
class RetryInterceptor implements NetworkInterceptor {
  final int maxRetries;
  final Duration retryDelay;
  
  RetryInterceptor({this.maxRetries = 3, this.retryDelay = const Duration(seconds: 1)});
  
  @override
  Future<void> onRequest(NetworkRequest request) async {
    // Mark request as retryable
  }

  @override
  Future<void> onResponse(NetworkResponse response) async {
    // Success - no retry needed
  }

  @override
  Future<void> onError(NetworkError error) async {
    if (error.code == 503 && shouldRetry(error)) {
      await Future.delayed(retryDelay);
      // Implement retry logic
    }
  }
}
```

## 🔐 Token Integration

### Basic Token Management
```dart
// Create token manager
final tokenManager = DefaultTokenManager(
  storage: await StorageService.create(),
  config: TokenConfig(
    tokenStorageKey: 'auth_token',
    refreshTokenStorageKey: 'refresh_token',
  ),
);

// Create network service with token support
final networkService = await NetworkService.createWithTokenSupport(
  config: NetworkConfig(baseUrl: 'https://api.example.com'),
  tokenManager: tokenManager,
);
```

### Custom Token Configuration
```dart
final tokenConfig = TokenConfig(
  tokenHeaderKey: 'Authorization',
  tokenStorageKey: 'access_token',
  tokenResponseField: 'access_token',
  tokenPrefix: 'Bearer',
  refreshTokenStorageKey: 'refresh_token',
  refreshTokenResponseField: 'refresh_token',
  refreshTokenEndPoint: '/auth/refresh',
);

final tokenManager = DefaultTokenManager(
  storage: storageService,
  config: tokenConfig,
);
```

### Token Refresh Strategy
```dart
class CustomRefreshStrategy implements TokenRefreshStrategy {
  final NetworkService _networkService;
  final TokenManager _tokenManager;
  
  CustomRefreshStrategy(this._networkService, this._tokenManager);
  
  @override
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _tokenManager.getRefreshToken();
      if (refreshToken == null) return false;
      
      final response = await _networkService.post('/auth/refresh', data: {
        'refresh_token': refreshToken,
      });
      
      if (response.isSuccess && response.data is Map) {
        final data = response.data as Map;
        final newAccessToken = data['access_token'];
        final newRefreshToken = data['refresh_token'];
        
        if (newAccessToken != null) {
          await _tokenManager.saveToken(newAccessToken);
          if (newRefreshToken != null) {
            await _tokenManager.saveRefreshToken(newRefreshToken);
          }
          return true;
        }
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
}
```

## 🏆 Best Practices

### 1. **Use Appropriate HTTP Methods**

```dart
// ✅ Good: Use correct HTTP methods
await networkService.get('/users');           // Fetch data
await networkService.post('/users', data: {}); // Create resource
await networkService.put('/users/123', data: {}); // Update resource
await networkService.delete('/users/123');    // Delete resource

// ❌ Bad: Using wrong methods
await networkService.post('/users');          // Without data for creation
await networkService.get('/users', data: {}); // GET with body data
```

### 2. **Handle Errors Properly**

```dart
// ✅ Good: Comprehensive error handling
try {
  final response = await networkService.get('/users');
  
  if (response.isSuccess) {
    // Handle successful response
    return response.data;
  } else {
    // Handle HTTP errors (4xx, 5xx)
    final errorMessage = response.error?.message ?? 'Unknown error';
    throw NetworkException(errorMessage, response.statusCode);
  }
} catch (e) {
  // Handle network exceptions (no internet, timeout, etc.)
  if (e is TimeoutException) {
    throw UserFriendlyException('Request timed out. Please try again.');
  } else {
    throw UserFriendlyException('Network error. Please check your connection.');
  }
}
```

### 3. **Use Query Parameters Correctly**

```dart
// ✅ Good: Proper query parameter usage
final response = await networkService.get('/users', queryParameters: {
  'page': '1',
  'limit': '20',
  'sort': 'created_at',
  'order': 'desc',
});

// ✅ Good: JSON convenience method with parameters
final users = await networkService.getJson('/users', queryParameters: {
  'include': 'profile,settings',
  'fields': 'id,name,email',
});
```

### 4. **Organize API Calls in Services**

```dart
class UserApiService {
  final NetworkService _networkService;
  
  UserApiService(this._networkService);
  
  Future<User> getUser(String userId) async {
    final response = await _networkService.getJson('/users/$userId');
    return User.fromJson(response!);
  }
  
  Future<List<User>> getUsers({int page = 1, int limit = 20}) async {
    final response = await _networkService.getJson('/users', queryParameters: {
      'page': page.toString(),
      'limit': limit.toString(),
    });
    
    final List<dynamic> userList = response!['data'];
    return userList.map((json) => User.fromJson(json)).toList();
  }
  
  Future<User> createUser(CreateUserRequest request) async {
    final response = await _networkService.postJson('/users', 
      jsonBody: request.toJson(),
    );
    return User.fromJson(response!);
  }
  
  Future<User> updateUser(String userId, UpdateUserRequest request) async {
    final response = await _networkService.putJson('/users/$userId',
      jsonBody: request.toJson(),
    );
    return User.fromJson(response!);
  }
  
  Future<void> deleteUser(String userId) async {
    await _networkService.delete('/users/$userId');
  }
}
```

### 5. **Use Proper Headers and Content Types**

```dart
// ✅ Good: Appropriate headers for different content types
final config = NetworkConfig(
  defaultHeaders: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'MyApp/1.0.0 (Flutter)',
  },
);

// For file uploads
final response = await networkService.post('/upload', 
  data: formData,
  // Headers automatically set by implementation
);

// For specific API versions
final response = await networkService.get('/users', queryParameters: {
  'version': '2.0',
});
```

## 💡 Examples

### API Client with Error Handling

```dart
class ApiClient {
  final NetworkService _networkService;
  
  ApiClient({required NetworkService networkService}) 
    : _networkService = networkService;
  
  Future<T> _executeRequest<T>(
    Future<NetworkResponse> request,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await request;
      
      if (response.isSuccess) {
        return fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ApiException(
          message: response.error?.message ?? 'Unknown error',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Network request failed: $e');
    }
  }
  
  Future<User> getUser(String id) => _executeRequest(
    _networkService.get('/users/$id'),
    (json) => User.fromJson(json),
  );
  
  Future<List<Post>> getUserPosts(String userId, {int page = 1}) => _executeRequest(
    _networkService.get('/users/$userId/posts', queryParameters: {
      'page': page.toString(),
      'per_page': '10',
    }),
    (json) => (json['data'] as List)
        .map((postJson) => Post.fromJson(postJson))
        .toList(),
  );
}
```

### Pagination Support

```dart
class PaginatedApiClient {
  final NetworkService _networkService;
  
  PaginatedApiClient(this._networkService);
  
  Future<PaginatedResponse<T>> getPaginated<T>(
    String endpoint, {
    int page = 1,
    int perPage = 20,
    Map<String, String>? filters,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'per_page': perPage.toString(),
      ...?filters,
    };
    
    final response = await _networkService.getJson(endpoint, 
      queryParameters: queryParams,
    );
    
    final data = response!;
    final items = (data['data'] as List)
        .map((json) => fromJson(json as Map<String, dynamic>))
        .toList();
    
    return PaginatedResponse<T>(
      items: items,
      currentPage: data['current_page'],
      totalPages: data['last_page'],
      totalItems: data['total'],
      hasNextPage: data['current_page'] < data['last_page'],
    );
  }
}

class PaginatedResponse<T> {
  final List<T> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasNextPage;
  
  PaginatedResponse({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.hasNextPage,
  });
}
```

### File Upload Service

```dart
class FileUploadService {
  final NetworkService _networkService;
  
  FileUploadService(this._networkService);
  
  Future<UploadResponse> uploadFile(
    String filePath, {
    String endpoint = '/upload',
    Map<String, String>? additionalFields,
    void Function(double progress)? onProgress,
  }) async {
    // Note: Implementation details depend on the network client
    // This is a conceptual example
    
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final fileName = path.basename(filePath);
    
    final formData = {
      'file': {
        'data': bytes,
        'filename': fileName,
        'contentType': lookupMimeType(filePath) ?? 'application/octet-stream',
      },
      ...?additionalFields,
    };
    
    final response = await _networkService.post(endpoint, data: formData);
    
    if (response.isSuccess) {
      return UploadResponse.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw UploadException('Upload failed: ${response.error?.message}');
    }
  }
}
```

## 🔗 Related Documentation

- [Storage Service Documentation](storage-service.md)
- [Token Management Documentation](token-management.md)
- [Complete Examples](examples.md)
- [Migration Guide](migration-guide.md) 