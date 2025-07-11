# 💡 Complete Examples

This document provides comprehensive, real-world examples demonstrating different usage patterns of the flutter_infra package.

## 📖 Table of Contents
- [Basic Storage Examples](#basic-storage-examples)
- [Network Service Examples](#network-service-examples)
- [Authentication Examples](#authentication-examples)
- [Repository Pattern](#repository-pattern)
- [Error Handling](#error-handling)

## 💾 Basic Storage Examples

### User Preferences Manager
```dart
class UserPreferencesManager {
  final StorageService _storage;
  
  UserPreferencesManager(this._storage);
  
  // Theme preferences
  Future<void> setTheme(String theme) async {
    await _storage.setString('theme', theme);
    await _storage.setDateTime('theme_updated', DateTime.now());
  }
  
  Future<String> getTheme() async {
    return await _storage.getString('theme', defaultValue: 'system') ?? 'system';
  }
  
  // Notification settings (JSON)
  Future<void> setNotificationSettings(Map<String, dynamic> settings) async {
    await _storage.setJson('notification_settings', settings);
  }
  
  Future<Map<String, dynamic>?> getNotificationSettings() async {
    return await _storage.getJson('notification_settings');
  }
  
  // Security settings (secure storage)
  Future<void> setBiometricsEnabled(bool enabled) async {
    await _storage.setSecureBool('biometrics_enabled', enabled);
  }
  
  Future<bool> isBiometricsEnabled() async {
    return await _storage.getSecureBool('biometrics_enabled', defaultValue: false);
  }
  
  // User interests (string list)
  Future<void> setUserInterests(List<String> interests) async {
    await _storage.setStringList('user_interests', interests);
  }
  
  Future<List<String>> getUserInterests() async {
    return await _storage.getStringList('user_interests') ?? [];
  }
}
```

### Cache Manager with TTL
```dart
class CacheManager {
  final StorageService _storage;
  final Duration _defaultTtl;
  
  CacheManager(this._storage, {Duration? defaultTtl})
    : _defaultTtl = defaultTtl ?? const Duration(hours: 1);
  
  Future<void> set<T>(String key, T data, {Duration? ttl}) async {
    final expiryTime = DateTime.now().add(ttl ?? _defaultTtl);
    
    final cacheEntry = {
      'data': data,
      'expires_at': expiryTime.toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    };
    
    await _storage.setJson('cache_$key', cacheEntry);
  }
  
  Future<T?> get<T>(String key, {T Function(dynamic)? fromJson}) async {
    final cacheEntry = await _storage.getJson('cache_$key');
    
    if (cacheEntry == null) return null;
    
    final expiryTime = DateTime.parse(cacheEntry['expires_at']);
    
    if (DateTime.now().isAfter(expiryTime)) {
      await _storage.deleteKey('cache_$key');
      return null;
    }
    
    final data = cacheEntry['data'];
    return fromJson != null ? fromJson(data) : data as T;
  }
  
  Future<void> delete(String key) async {
    await _storage.deleteKey('cache_$key');
  }
}
```

## 🌐 Network Service Examples

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

### User Service with CRUD Operations
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

## 🔐 Authentication Examples

### Login & Token Management
```dart
class AuthService {
  final NetworkService _networkService;
  final TokenManager _tokenManager;
  
  AuthService(this._networkService, this._tokenManager);
  
  Future<LoginResult> login(String email, String password) async {
    try {
      final response = await _networkService.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      if (response.isSuccess && response.data is Map) {
        final data = response.data as Map;
        
        final accessToken = data['access_token'] as String?;
        final refreshToken = data['refresh_token'] as String?;
        final user = data['user'] as Map<String, dynamic>?;
        
        if (accessToken != null && user != null) {
          await _tokenManager.saveToken(accessToken);
          if (refreshToken != null) {
            await _tokenManager.saveRefreshToken(refreshToken);
          }
          
          return LoginResult.success(User.fromJson(user));
        }
      }
      
      return LoginResult.failure('Invalid credentials');
    } catch (e) {
      return LoginResult.failure('Login failed: $e');
    }
  }
  
  Future<void> logout() async {
    try {
      await _networkService.post('/auth/logout');
    } catch (e) {
      print('Server logout failed: $e');
    } finally {
      await _tokenManager.deleteToken();
      await _tokenManager.deleteRefreshToken();
    }
  }
  
  Future<bool> isLoggedIn() async {
    final token = await _tokenManager.getToken();
    return token != null;
  }
}

class LoginResult {
  final bool success;
  final User? user;
  final String? error;
  
  LoginResult._(this.success, this.user, this.error);
  
  factory LoginResult.success(User user) => LoginResult._(true, user, null);
  factory LoginResult.failure(String error) => LoginResult._(false, null, error);
}
```

## 🏗️ Repository Pattern

### User Repository with Cache
```dart
class UserRepository {
  final NetworkService _networkService;
  final StorageService _storageService;
  final CacheManager _cacheManager;
  
  UserRepository({
    required NetworkService networkService,
    required StorageService storageService,
    required CacheManager cacheManager,
  }) : _networkService = networkService,
       _storageService = storageService,
       _cacheManager = cacheManager;
  
  Future<User?> findById(String id) async {
    // Try cache first
    User? user = await _cacheManager.get<User>(
      'user_$id', 
      fromJson: (json) => User.fromJson(json),
    );
    
    if (user != null) return user;
    
    // Fetch from API
    try {
      final response = await _networkService.getJson('/users/$id');
      if (response != null) {
        user = User.fromJson(response);
        
        // Cache the result
        await _cacheManager.set('user_$id', user.toJson(), 
          ttl: const Duration(minutes: 30));
        
        return user;
      }
    } catch (e) {
      print('Failed to fetch user $id: $e');
    }
    
    return null;
  }
  
  Future<User> save(User user) async {
    final isNew = user.id.isEmpty;
    
    final response = isNew
        ? await _networkService.postJson('/users', jsonBody: user.toJson())
        : await _networkService.putJson('/users/${user.id}', jsonBody: user.toJson());
    
    if (response != null) {
      final savedUser = User.fromJson(response);
      
      // Update cache
      await _cacheManager.set('user_${savedUser.id}', savedUser.toJson());
      
      // Update local storage for current user
      final currentUserId = await _getCurrentUserId();
      if (currentUserId == savedUser.id) {
        await _storageService.setJson('current_user', savedUser.toJson());
      }
      
      return savedUser;
    }
    
    throw Exception('Failed to save user');
  }
  
  Future<void> delete(String id) async {
    await _networkService.delete('/users/$id');
    
    // Remove from cache
    await _cacheManager.delete('user_$id');
    
    // Clear from local storage if it's the current user
    final currentUserId = await _getCurrentUserId();
    if (currentUserId == id) {
      await _storageService.deleteKey('current_user');
    }
  }
  
  Future<User?> getCurrentUser() async {
    final userData = await _storageService.getJson('current_user');
    return userData != null ? User.fromJson(userData) : null;
  }
  
  Future<void> setCurrentUser(User user) async {
    await _storageService.setJson('current_user', user.toJson());
    await _storageService.setDateTime('user_updated_at', DateTime.now());
  }
  
  Future<String?> _getCurrentUserId() async {
    final currentUser = await getCurrentUser();
    return currentUser?.id;
  }
}
```

## ⚠️ Error Handling

### Custom Exceptions
```dart
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;
  
  const AppException(this.message, {this.code, this.originalException});
  
  @override
  String toString() => 'AppException: $message';
}

class NetworkException extends AppException {
  final int? statusCode;
  
  const NetworkException(
    String message, {
    this.statusCode,
    String? code,
    dynamic originalException,
  }) : super(message, code: code, originalException: originalException);
}

class ValidationException extends AppException {
  final Map<String, List<String>> fieldErrors;
  
  const ValidationException(
    String message,
    this.fieldErrors, {
    String? code,
  }) : super(message, code: code);
}

class AuthenticationException extends AppException {
  const AuthenticationException(String message, {String? code})
    : super(message, code: code);
}
```

### Error Handler
```dart
class ErrorHandler {
  static String getUserFriendlyMessage(Exception exception) {
    if (exception is NetworkException) {
      switch (exception.statusCode) {
        case 404:
          return 'The requested resource was not found.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return 'Network error. Please check your connection.';
      }
    } else if (exception is AuthenticationException) {
      return 'Please log in to continue.';
    } else if (exception is ValidationException) {
      if (exception.fieldErrors.isNotEmpty) {
        return exception.fieldErrors.values.first.first;
      }
      return 'Please check your input and try again.';
    }
    
    return 'An unexpected error occurred.';
  }
}
```

## 🔗 Related Documentation

- [Storage Service Documentation](storage-service.md)
- [Network Service Documentation](network-service.md)
- [Token Management Documentation](token-management.md) 