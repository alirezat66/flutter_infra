# 🏆 Best Practices

Recommended patterns and guidelines for using Flutter Infra effectively and securely.

## 📖 Table of Contents
- [Storage Best Practices](#storage-best-practices)
- [Network Best Practices](#network-best-practices)
- [Security Best Practices](#security-best-practices)
- [Performance Best Practices](#performance-best-practices)
- [Architecture Best Practices](#architecture-best-practices)
- [Testing Best Practices](#testing-best-practices)
- [Error Handling Best Practices](#error-handling-best-practices)

## 💾 Storage Best Practices

### 1. **Choose the Right Storage Type**

```dart
// ✅ Good: Normal storage for preferences
await storageService.setString('theme', 'dark');
await storageService.setBool('notifications_enabled', true);
await storageService.setJson('user_preferences', preferences);

// ✅ Good: Secure storage for sensitive data
await storageService.setSecureString('auth_token', token);
await storageService.setSecureJson('user_credentials', credentials);
await storageService.setSecureBool('biometrics_enabled', true);

// ❌ Bad: Sensitive data in normal storage
await storageService.setString('password', 'secret123'); // Security risk!
await storageService.setString('credit_card', cardNumber); // Never do this!
```

### 2. **Use Typed Extensions**

```dart
// ✅ Good: Type-safe operations
final settings = {
  'theme': 'dark',
  'language': 'en',
  'notifications': true
};
await storageService.setJson('app_settings', settings);
final retrievedSettings = await storageService.getJson('app_settings');

// ✅ Good: DateTime operations
await storageService.setDateTime('last_login', DateTime.now());
final lastLogin = await storageService.getDateTime('last_login');

// ❌ Bad: Manual JSON encoding/decoding
await storageService.setString('app_settings', jsonEncode(settings));
final settingsString = await storageService.getString('app_settings');
final retrievedSettings = jsonDecode(settingsString!); // Prone to errors
```

### 3. **Organize Storage Keys**

```dart
// ✅ Good: Centralized key management
class StorageKeys {
  // User data
  static const String userProfile = 'user_profile';
  static const String userPreferences = 'user_preferences';
  static const String userInterests = 'user_interests';
  
  // Authentication (secure)
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String biometricsEnabled = 'biometrics_enabled';
  
  // App state
  static const String isFirstLaunch = 'is_first_launch';
  static const String lastAppVersion = 'last_app_version';
  static const String lastSync = 'last_sync';
}

// Usage
await storageService.setJson(StorageKeys.userProfile, profileData);
final token = await storageService.getSecureString(StorageKeys.authToken);
```

### 4. **Handle Errors Gracefully**

```dart
// ✅ Good: Comprehensive error handling
Future<User?> loadUserProfile() async {
  try {
    final userData = await storageService.getJson(StorageKeys.userProfile);
    if (userData != null) {
      return User.fromJson(userData);
    } else {
      print('No user profile found');
      return null;
    }
  } catch (e) {
    print('Error loading user profile: $e');
    // Return default or cached data
    return _getDefaultUser();
  }
}

// ✅ Good: Provide sensible defaults
Future<String> getTheme() async {
  try {
    return await storageService.getString('theme', defaultValue: 'system') ?? 'system';
  } catch (e) {
    print('Error getting theme: $e');
    return 'system'; // Safe fallback
  }
}
```

### 5. **Cache Strategy**

```dart
// ✅ Good: Implement cache with TTL
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
}
```

## 🌐 Network Best Practices

### 1. **Use Appropriate HTTP Methods**

```dart
// ✅ Good: Correct HTTP methods
await networkService.get('/users');           // Fetch data
await networkService.post('/users', data: userData); // Create resource
await networkService.put('/users/123', data: updates); // Update entire resource
await networkService.patch('/users/123', data: partialUpdates); // Partial update
await networkService.delete('/users/123');    // Delete resource

// ❌ Bad: Wrong methods
await networkService.post('/users');          // POST without data
await networkService.get('/users', data: {}); // GET with body data
```

### 2. **Organize API Calls in Services**

```dart
// ✅ Good: Dedicated API service classes
class UserApiService {
  final NetworkService _networkService;
  
  UserApiService(this._networkService);
  
  Future<User> getUser(String userId) async {
    try {
      final response = await _networkService.getJson('/users/$userId');
      return User.fromJson(response!);
    } catch (e) {
      throw UserNotFoundException('User $userId not found: $e');
    }
  }
  
  Future<List<User>> getUsers({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (search != null) 'search': search,
    };
    
    final response = await _networkService.getJson('/users', 
      queryParameters: queryParams);
    
    final List<dynamic> userList = response!['data'];
    return userList.map((json) => User.fromJson(json)).toList();
  }
  
  Future<User> createUser(CreateUserRequest request) async {
    final response = await _networkService.postJson('/users', 
      jsonBody: request.toJson());
    return User.fromJson(response!);
  }
}
```

### 3. **Handle Network Errors Properly**

```dart
// ✅ Good: Comprehensive error handling
Future<List<User>> fetchUsers() async {
  try {
    final response = await networkService.get('/users');
    
    if (response.isSuccess) {
      final data = response.data as Map<String, dynamic>;
      final users = (data['users'] as List)
          .map((json) => User.fromJson(json))
          .toList();
      return users;
    } else {
      // Handle HTTP errors
      final errorMessage = response.error?.message ?? 'Unknown error';
      throw ApiException(errorMessage, response.statusCode);
    }
  } on TimeoutException {
    throw NetworkException('Request timed out. Please try again.');
  } on SocketException {
    throw NetworkException('No internet connection. Please check your network.');
  } catch (e) {
    throw NetworkException('Network error: $e');
  }
}
```

### 4. **Use Query Parameters Correctly**

```dart
// ✅ Good: Proper query parameter usage
final response = await networkService.get('/search', queryParameters: {
  'q': searchTerm,
  'page': page.toString(),
  'limit': limit.toString(),
  'sort': 'created_at',
  'order': 'desc',
  'include': 'profile,settings',
});

// ✅ Good: Handle optional parameters
Map<String, String> buildQueryParams({
  required int page,
  required int limit,
  String? search,
  List<String>? categories,
}) {
  final params = <String, String>{
    'page': page.toString(),
    'limit': limit.toString(),
  };
  
  if (search != null && search.isNotEmpty) {
    params['search'] = search;
  }
  
  if (categories != null && categories.isNotEmpty) {
    params['categories'] = categories.join(',');
  }
  
  return params;
}
```

### 5. **Configure Timeouts Appropriately**

```dart
// ✅ Good: Environment-specific timeouts
class NetworkConfigFactory {
  static NetworkConfig createConfig(Environment env) {
    switch (env) {
      case Environment.development:
        return NetworkConfig(
          baseUrl: 'https://dev-api.example.com',
          timeout: const Duration(seconds: 60), // Longer for debugging
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
        );
        
      case Environment.production:
        return NetworkConfig(
          baseUrl: 'https://api.example.com',
          timeout: const Duration(seconds: 30), // Reasonable for production
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
        );
    }
  }
}
```

## 🔐 Security Best Practices

### 1. **Token Security**

```dart
// ✅ Good: Always use secure storage for tokens
final tokenManager = DefaultTokenManager(
  storage: await StorageService.create(),
  config: TokenConfig(
    tokenStorageKey: 'access_token',
    refreshTokenStorageKey: 'refresh_token',
  ),
);

// ✅ Good: Validate tokens before use
class ValidatingTokenManager extends DefaultTokenManager {
  ValidatingTokenManager(super.storage, {super.config});
  
  @override
  Future<String?> getToken() async {
    final token = await super.getToken();
    
    if (token != null && _isTokenExpired(token)) {
      await deleteToken();
      return null;
    }
    
    return token;
  }
  
  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      
      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      
      final exp = payload['exp'] as int?;
      if (exp == null) return false;
      
      final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expirationDate);
    } catch (e) {
      return true;
    }
  }
}
```

### 2. **Sensitive Data Handling**

```dart
// ✅ Good: Clear sensitive data appropriately
class AuthService {
  final TokenManager _tokenManager;
  final StorageService _storage;
  
  AuthService(this._tokenManager, this._storage);
  
  Future<void> logout() async {
    try {
      // Notify server
      await _networkService.post('/auth/logout');
    } catch (e) {
      // Continue with local logout even if server fails
      print('Server logout failed: $e');
    } finally {
      // Always clear sensitive data
      await _tokenManager.deleteToken();
      await _tokenManager.deleteRefreshToken();
      await _clearSensitiveUserData();
    }
  }
  
  Future<void> _clearSensitiveUserData() async {
    // Clear specific sensitive keys
    await _storage.deleteSecureKey('user_credentials');
    await _storage.deleteSecureKey('payment_methods');
    await _storage.deleteSecureKey('biometric_data');
  }
}
```

### 3. **Network Security**

```dart
// ✅ Good: Secure network configuration
final secureConfig = NetworkConfig(
  baseUrl: 'https://api.example.com', // Always use HTTPS
  defaultHeaders: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Requested-With': 'XMLHttpRequest',
    // Don't include sensitive data in headers logged
  },
  customSettings: {
    'certificate_pinning': true,
    'verify_ssl': true,
  },
);

// ✅ Good: Sanitize logged data
class SafeLoggerInterceptor implements NetworkInterceptor {
  final Set<String> _sensitiveHeaders = {
    'authorization',
    'x-api-key',
    'cookie',
  };
  
  @override
  Future<void> onRequest(NetworkRequest request) async {
    final sanitizedHeaders = Map<String, String>.from(request.headers);
    
    for (final header in _sensitiveHeaders) {
      if (sanitizedHeaders.containsKey(header)) {
        sanitizedHeaders[header] = '***REDACTED***';
      }
    }
    
    print('Request: ${request.method} ${request.url}');
    print('Headers: $sanitizedHeaders');
  }
}
```

## ⚡ Performance Best Practices

### 1. **Efficient Storage Operations**

```dart
// ✅ Good: Batch operations when possible
Future<void> saveUserData(User user, List<String> interests) async {
  // Use Future.wait for parallel operations
  await Future.wait([
    storageService.setJson('user_profile', user.toJson()),
    storageService.setStringList('user_interests', interests),
    storageService.setDateTime('profile_updated', DateTime.now()),
  ]);
}

// ✅ Good: Use appropriate storage for data size
class DataManager {
  // Small, frequently accessed data -> SharedPreferences
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await storageService.setJson('settings', settings);
  }
  
  // Large data or complex objects -> Hive
  Future<void> saveLargeDataset(List<Map<String, dynamic>> data) async {
    final hiveStorage = await HiveStorageImpl.getInstance(
      boxName: 'large_data',
      config: StorageConfig(enableCache: false),
    );
    
    for (int i = 0; i < data.length; i++) {
      await hiveStorage.setString('item_$i', jsonEncode(data[i]));
    }
  }
}
```

### 2. **Network Performance**

```dart
// ✅ Good: Implement proper caching
class ApiClient {
  final NetworkService _networkService;
  final CacheManager _cache;
  
  ApiClient(this._networkService, this._cache);
  
  Future<List<User>> getUsers({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cachedUsers = await _cache.get<List<User>>(
        'users',
        fromJson: (data) => (data as List)
            .map((json) => User.fromJson(json))
            .toList(),
      );
      
      if (cachedUsers != null) {
        return cachedUsers;
      }
    }
    
    final response = await _networkService.getJson('/users');
    final users = (response!['data'] as List)
        .map((json) => User.fromJson(json))
        .toList();
    
    // Cache for 30 minutes
    await _cache.set('users', users.map((u) => u.toJson()).toList(),
        ttl: const Duration(minutes: 30));
    
    return users;
  }
}
```

### 3. **Memory Management**

```dart
// ✅ Good: Dispose resources properly
class ApiService {
  NetworkService? _networkService;
  
  Future<void> initialize() async {
    _networkService = await NetworkService.create(/* config */);
  }
  
  Future<void> dispose() async {
    await _networkService?.dispose();
    _networkService = null;
  }
}

// ✅ Good: Use streams for large datasets
class DataStream {
  Stream<List<User>> getUserStream() async* {
    int page = 1;
    const pageSize = 20;
    
    while (true) {
      final users = await _fetchUsers(page: page, limit: pageSize);
      
      if (users.isEmpty) break;
      
      yield users;
      page++;
    }
  }
}
```

## 🏗️ Architecture Best Practices

### 1. **Repository Pattern**

```dart
// ✅ Good: Repository abstracts data sources
abstract class UserRepository {
  Future<User?> getUser(String id);
  Future<List<User>> getUsers();
  Future<User> saveUser(User user);
  Future<void> deleteUser(String id);
}

class UserRepositoryImpl implements UserRepository {
  final NetworkService _networkService;
  final StorageService _storageService;
  final CacheManager _cacheManager;
  
  UserRepositoryImpl({
    required NetworkService networkService,
    required StorageService storageService,
    required CacheManager cacheManager,
  }) : _networkService = networkService,
       _storageService = storageService,
       _cacheManager = cacheManager;
  
  @override
  Future<User?> getUser(String id) async {
    // Try cache first
    User? user = await _cacheManager.get<User>('user_$id');
    if (user != null) return user;
    
    // Try network
    try {
      final response = await _networkService.getJson('/users/$id');
      user = User.fromJson(response!);
      await _cacheManager.set('user_$id', user);
      return user;
    } catch (e) {
      // Fallback to local storage
      final userData = await _storageService.getJson('user_$id');
      return userData != null ? User.fromJson(userData) : null;
    }
  }
}
```

### 2. **Dependency Injection**

```dart
// ✅ Good: Use DI container for clean dependencies
class ServiceLocator {
  static final GetIt _instance = GetIt.instance;
  
  static Future<void> setup() async {
    // Core services
    _instance.registerSingleton<StorageService>(
      await StorageService.create(),
    );
    
    final storageService = _instance<StorageService>();
    _instance.registerSingleton<NetworkService>(
      await NetworkService.createWithTokenSupport(
        config: NetworkConfig(baseUrl: 'https://api.example.com'),
        tokenManager: DefaultTokenManager(storage: storageService),
      ),
    );
    
    // Repositories
    _instance.registerLazySingleton<UserRepository>(
      () => UserRepositoryImpl(
        networkService: _instance<NetworkService>(),
        storageService: _instance<StorageService>(),
        cacheManager: CacheManager(_instance<StorageService>()),
      ),
    );
    
    // Services
    _instance.registerLazySingleton<AuthService>(
      () => AuthService(_instance<UserRepository>()),
    );
  }
  
  static T get<T extends Object>() => _instance<T>();
}
```

### 3. **Error Handling Architecture**

```dart
// ✅ Good: Structured error handling
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;
  
  const AppException(this.message, {this.code, this.originalException});
}

class NetworkException extends AppException {
  final int? statusCode;
  const NetworkException(String message, {this.statusCode, String? code})
    : super(message, code: code);
}

class ErrorHandler {
  static String getUserFriendlyMessage(Exception exception) {
    if (exception is NetworkException) {
      switch (exception.statusCode) {
        case 404: return 'Resource not found';
        case 500: return 'Server error. Please try again later.';
        default: return 'Network error. Please check your connection.';
      }
    }
    
    return 'An unexpected error occurred.';
  }
  
  static void logError(Exception exception, [StackTrace? stackTrace]) {
    // Log to crash reporting service
    FirebaseCrashlytics.instance.recordError(exception, stackTrace);
  }
}
```

## 🧪 Testing Best Practices

### 1. **Mock Dependencies**

```dart
// ✅ Good: Mock external dependencies
class MockStorageService extends Mock implements StorageService {}
class MockNetworkService extends Mock implements NetworkService {}

void main() {
  group('UserRepository Tests', () {
    late UserRepository repository;
    late MockStorageService mockStorage;
    late MockNetworkService mockNetwork;
    
    setUp(() {
      mockStorage = MockStorageService();
      mockNetwork = MockNetworkService();
      repository = UserRepositoryImpl(
        storageService: mockStorage,
        networkService: mockNetwork,
        cacheManager: CacheManager(mockStorage),
      );
    });
    
    test('should return cached user when available', () async {
      // Arrange
      const userId = '123';
      final expectedUser = User(id: userId, name: 'John');
      
      when(mockStorage.getJson('cache_user_$userId'))
          .thenAnswer((_) async => {
            'data': expectedUser.toJson(),
            'expires_at': DateTime.now().add(Duration(hours: 1)).toIso8601String(),
          });
      
      // Act
      final result = await repository.getUser(userId);
      
      // Assert
      expect(result?.id, userId);
      verify(mockStorage.getJson('cache_user_$userId')).called(1);
      verifyNever(mockNetwork.getJson(any));
    });
  });
}
```

### 2. **Integration Testing**

```dart
// ✅ Good: Test real integrations
void main() {
  group('Storage Integration Tests', () {
    late StorageService storageService;
    
    setUp(() async {
      // Use real implementations for integration tests
      storageService = await StorageService.create(
        config: StorageConfig(enableLogging: false),
      );
    });
    
    tearDown(() async {
      // Clean up test data
      await storageService.clearAll();
      await storageService.clearAllSecure();
    });
    
    test('should persist data across app restarts', () async {
      // Arrange
      const testKey = 'integration_test_key';
      const testValue = 'integration_test_value';
      
      // Act
      await storageService.setString(testKey, testValue);
      
      // Simulate app restart by creating new service instance
      final newStorageService = await StorageService.create();
      final retrievedValue = await newStorageService.getString(testKey);
      
      // Assert
      expect(retrievedValue, testValue);
    });
  });
}
```

## ⚠️ Error Handling Best Practices

### 1. **Graceful Degradation**

```dart
// ✅ Good: Provide fallback functionality
class UserService {
  final UserRepository _repository;
  
  UserService(this._repository);
  
  Future<User> getUser(String id) async {
    try {
      // Try to get fresh data
      final user = await _repository.getUser(id);
      if (user != null) return user;
      
      // Fallback to cached data
      final cachedUser = await _repository.getCachedUser(id);
      if (cachedUser != null) {
        _showOfflineNotice();
        return cachedUser;
      }
      
      // Final fallback
      throw UserNotFoundException('User not found');
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }
  
  void _showOfflineNotice() {
    // Show user-friendly offline indicator
  }
  
  void _handleError(dynamic error) {
    // Log error and show appropriate message
    ErrorHandler.logError(error);
  }
}
```

### 2. **Retry Logic**

```dart
// ✅ Good: Implement intelligent retry
class RetryHelper {
  static Future<T> withRetry<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempts = 0;
    
    while (attempts < maxAttempts) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        
        if (attempts >= maxAttempts || 
            (shouldRetry != null && !shouldRetry(e))) {
          rethrow;
        }
        
        await Future.delayed(delay * attempts); // Exponential backoff
      }
    }
    
    throw StateError('Retry logic failed unexpectedly');
  }
}

// Usage
final user = await RetryHelper.withRetry(
  () => userService.getUser('123'),
  shouldRetry: (error) => error is NetworkException,
);
```

## 🔗 Related Documentation

- [Quick Start Guide](quick-start.md)
- [Architecture Overview](architecture.md)
- [Configuration Guide](configuration.md)
- [Storage Service Documentation](storage-service.md)
- [Network Service Documentation](network-service.md)
- [Token Management Documentation](token-management.md)
- [Complete Examples](examples.md) 