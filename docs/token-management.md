# 🔐 Token Management Documentation

The Token Management system provides secure, automatic handling of authentication tokens with support for refresh strategies and flexible configuration.

## 📖 Table of Contents
- [Quick Start](#quick-start)
- [Token Manager](#token-manager)
- [Token Configuration](#token-configuration)
- [Refresh Strategies](#refresh-strategies)
- [Token Interceptor](#token-interceptor)
- [Best Practices](#best-practices)
- [Examples](#examples)

## 🚀 Quick Start

### Basic Token Management
```dart
import 'package:flutter_infra/flutter_infra.dart';

// Create storage service
final storageService = await StorageService.create();

// Create token manager with default configuration
final tokenManager = DefaultTokenManager(storage: storageService);

// Save tokens
await tokenManager.saveToken('your_access_token');
await tokenManager.saveRefreshToken('your_refresh_token');

// Retrieve tokens
final accessToken = await tokenManager.getToken();
final refreshToken = await tokenManager.getRefreshToken();

// Create network service with automatic token injection
final networkService = await NetworkService.createWithTokenSupport(
  config: NetworkConfig(baseUrl: 'https://api.example.com'),
  tokenManager: tokenManager,
);
```

### With Refresh Strategy
```dart
// Create a refresh strategy
final refreshStrategy = CustomRefreshStrategy(
  networkService: networkService,
  tokenManager: tokenManager,
);

// Create network service with token refresh support
final networkService = await NetworkService.createWithTokenSupport(
  config: NetworkConfig(baseUrl: 'https://api.example.com'),
  tokenManager: tokenManager,
  refreshStrategy: refreshStrategy,
);

// Tokens will automatically refresh on 401 errors
final response = await networkService.get('/protected-resource');
```

## 🏗️ Token Manager

### DefaultTokenManager
The default implementation stores tokens securely and provides basic token management:

```dart
final tokenManager = DefaultTokenManager(
  storage: storageService,
  config: TokenConfig(
    tokenStorageKey: 'access_token',
    refreshTokenStorageKey: 'refresh_token',
    tokenHeaderKey: 'Authorization',
    tokenPrefix: 'Bearer',
  ),
);
```

### Custom Token Manager
You can implement your own token manager for specialized needs:

```dart
class CustomTokenManager implements TokenManager {
  final StorageService _storage;
  final TokenConfig _config;
  
  CustomTokenManager(this._storage, this._config);
  
  @override
  Future<String?> getToken() async {
    // Custom logic for token retrieval
    final token = await _storage.getSecureString(_config.tokenStorageKey);
    
    // Add custom validation, decryption, etc.
    if (token != null && _isTokenValid(token)) {
      return token;
    }
    
    return null;
  }
  
  @override
  Future<void> saveToken(String token) async {
    // Custom logic for token storage
    await _storage.setSecureString(_config.tokenStorageKey, token);
    await _storage.setSecureDateTime('token_saved_at', DateTime.now());
  }
  
  @override
  Future<void> deleteToken() async {
    await _storage.deleteSecureKey(_config.tokenStorageKey);
    await _storage.deleteSecureKey('token_saved_at');
  }
  
  // Implement other required methods...
}
```

## ⚙️ Token Configuration

### TokenConfig Options
```dart
final tokenConfig = TokenConfig(
  // HTTP Header Configuration
  tokenHeaderKey: 'Authorization',        // Header name for token
  tokenPrefix: 'Bearer',                  // Prefix for token value
  
  // Storage Configuration
  tokenStorageKey: 'access_token',        // Storage key for access token
  refreshTokenStorageKey: 'refresh_token', // Storage key for refresh token
  
  // API Response Configuration
  tokenResponseField: 'access_token',     // Field name in API response
  refreshTokenResponseField: 'refresh_token', // Refresh token field in response
  
  // Refresh Configuration
  refreshTokenEndPoint: '/auth/refresh',  // Endpoint for token refresh
);
```

### Environment-Specific Configuration
```dart
class TokenConfigs {
  static TokenConfig development() => TokenConfig(
    tokenHeaderKey: 'Authorization',
    tokenPrefix: 'Bearer',
    tokenStorageKey: 'dev_access_token',
    refreshTokenStorageKey: 'dev_refresh_token',
    refreshTokenEndPoint: '/auth/refresh',
  );
  
  static TokenConfig staging() => TokenConfig(
    tokenHeaderKey: 'X-Auth-Token',
    tokenPrefix: 'Token',
    tokenStorageKey: 'staging_access_token',
    refreshTokenStorageKey: 'staging_refresh_token',
    refreshTokenEndPoint: '/api/v1/auth/refresh',
  );
  
  static TokenConfig production() => TokenConfig(
    tokenHeaderKey: 'Authorization',
    tokenPrefix: 'Bearer',
    tokenStorageKey: 'prod_access_token',
    refreshTokenStorageKey: 'prod_refresh_token',
    refreshTokenEndPoint: '/api/auth/refresh',
  );
}
```

### Custom Header Configuration
```dart
// For APIs that use custom authentication headers
final customTokenConfig = TokenConfig(
  tokenHeaderKey: 'X-API-Key',
  tokenPrefix: '',  // No prefix
  tokenStorageKey: 'api_key',
  // No refresh token needed for API keys
);

// For APIs with multiple authentication methods
final multiAuthConfig = TokenConfig(
  tokenHeaderKey: 'X-Access-Token',
  tokenPrefix: 'Custom',
  tokenStorageKey: 'custom_access_token',
  refreshTokenStorageKey: 'custom_refresh_token',
  tokenResponseField: 'accessToken',
  refreshTokenResponseField: 'refreshToken',
  refreshTokenEndPoint: '/oauth/token',
);
```

## 🔄 Refresh Strategies

### DefaultTokenRefreshStrategy
The built-in refresh strategy that works with most OAuth2-style APIs:

```dart
final refreshStrategy = DefaultTokenRefreshStrategy(
  networkService: networkService,
  tokenManager: tokenManager,
);

// Will automatically:
// 1. Use the refresh token to get new tokens
// 2. Save the new tokens
// 3. Retry the original request
```

### Custom Refresh Strategy
Implement your own refresh logic for custom authentication flows:

```dart
class CustomRefreshStrategy implements TokenRefreshStrategy {
  final NetworkService _networkService;
  final TokenManager _tokenManager;
  final String _clientId;
  final String _clientSecret;
  
  CustomRefreshStrategy({
    required NetworkService networkService,
    required TokenManager tokenManager,
    required String clientId,
    required String clientSecret,
  }) : _networkService = networkService,
       _tokenManager = tokenManager,
       _clientId = clientId,
       _clientSecret = clientSecret;
  
  @override
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _tokenManager.getRefreshToken();
      if (refreshToken == null) return false;
      
      final response = await _networkService.post('/oauth/token', data: {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
        'client_id': _clientId,
        'client_secret': _clientSecret,
      });
      
      if (response.isSuccess && response.data is Map) {
        final data = response.data as Map;
        
        final newAccessToken = data['access_token'];
        final newRefreshToken = data['refresh_token'];
        
        if (newAccessToken != null) {
          await _tokenManager.saveToken(newAccessToken);
          
          // Some APIs return a new refresh token
          if (newRefreshToken != null) {
            await _tokenManager.saveRefreshToken(newRefreshToken);
          }
          
          return true;
        }
      }
      
      return false;
    } catch (e) {
      print('Token refresh failed: $e');
      return false;
    }
  }
}
```

### Advanced Refresh Strategy with Retry Logic
```dart
class AdvancedRefreshStrategy implements TokenRefreshStrategy {
  final NetworkService _networkService;
  final TokenManager _tokenManager;
  final int _maxRetries;
  final Duration _retryDelay;
  
  AdvancedRefreshStrategy({
    required NetworkService networkService,
    required TokenManager tokenManager,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) : _networkService = networkService,
       _tokenManager = tokenManager,
       _maxRetries = maxRetries,
       _retryDelay = retryDelay;
  
  @override
  Future<bool> refreshToken() async {
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        final success = await _attemptRefresh();
        if (success) return true;
        
        if (attempt < _maxRetries) {
          await Future.delayed(_retryDelay * attempt);
        }
      } catch (e) {
        print('Refresh attempt $attempt failed: $e');
        
        if (attempt == _maxRetries) {
          // Clean up tokens on final failure
          await _tokenManager.deleteToken();
          await _tokenManager.deleteRefreshToken();
          return false;
        }
      }
    }
    
    return false;
  }
  
  Future<bool> _attemptRefresh() async {
    // Implementation similar to CustomRefreshStrategy
    // but with additional error handling and validation
  }
}
```

## 🛡️ Token Interceptor

### Basic Usage
The TokenInterceptor automatically handles token injection and refresh:

```dart
final tokenInterceptor = TokenInterceptor(
  tokenManager: tokenManager,
  refreshStrategy: refreshStrategy, // Optional
);

final networkService = await NetworkService.create(
  config: NetworkConfig(
    baseUrl: 'https://api.example.com',
    interceptors: [
      LoggerInterceptor(),
      tokenInterceptor,
    ],
  ),
);
```

### How It Works
1. **Request Interception**: Automatically adds tokens to outgoing requests
2. **Response Handling**: Extracts new tokens from successful responses
3. **Error Handling**: Attempts token refresh on 401 errors

### Manual Token Handling
For cases where you need more control:

```dart
class ManualTokenInterceptor implements NetworkInterceptor {
  final TokenManager _tokenManager;
  
  ManualTokenInterceptor(this._tokenManager);
  
  @override
  Future<void> onRequest(NetworkRequest request) async {
    // Only add token to specific endpoints
    if (request.path.startsWith('/api/')) {
      final token = await _tokenManager.getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
    }
  }
  
  @override
  Future<void> onResponse(NetworkResponse response) async {
    // Custom response handling
    if (response.statusCode == 200 && response.data is Map) {
      final data = response.data as Map;
      
      // Check for new tokens in specific responses
      if (data.containsKey('access_token')) {
        await _tokenManager.saveToken(data['access_token']);
      }
    }
  }
  
  @override
  Future<void> onError(NetworkError error) async {
    // Custom error handling
    if (error.code == 401) {
      // Clear tokens and redirect to login
      await _tokenManager.deleteToken();
      await _tokenManager.deleteRefreshToken();
      
      // Trigger app-wide logout
      NavigationService.redirectToLogin();
    }
  }
}
```

## 🏆 Best Practices

### 1. **Secure Token Storage**
```dart
// ✅ Good: Always use secure storage for tokens
final tokenManager = DefaultTokenManager(
  storage: await StorageService.create(),
  config: TokenConfig(/* ... */),
);

// ❌ Bad: Never store tokens in normal storage
// await storageService.setString('token', token); // Security risk!
```

### 2. **Token Validation**
```dart
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
      // Parse JWT token and check expiration
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
      return true; // Assume expired if parsing fails
    }
  }
}
```

### 3. **Handle Refresh Failures Gracefully**
```dart
class GracefulRefreshStrategy implements TokenRefreshStrategy {
  final TokenRefreshStrategy _primaryStrategy;
  final VoidCallback _onRefreshFailure;
  
  GracefulRefreshStrategy(this._primaryStrategy, this._onRefreshFailure);
  
  @override
  Future<bool> refreshToken() async {
    final success = await _primaryStrategy.refreshToken();
    
    if (!success) {
      // Notify the app that refresh failed
      _onRefreshFailure();
    }
    
    return success;
  }
}

// Usage
final refreshStrategy = GracefulRefreshStrategy(
  DefaultTokenRefreshStrategy(networkService: networkService, tokenManager: tokenManager),
  () {
    // Handle refresh failure (redirect to login, show error, etc.)
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  },
);
```

### 4. **Environment-Specific Configuration**
```dart
class TokenManagerFactory {
  static Future<TokenManager> create(Environment env) async {
    final storage = await StorageService.create();
    
    switch (env) {
      case Environment.development:
        return DefaultTokenManager(
          storage: storage,
          config: TokenConfigs.development(),
        );
        
      case Environment.staging:
        return DefaultTokenManager(
          storage: storage,
          config: TokenConfigs.staging(),
        );
        
      case Environment.production:
        return ValidatingTokenManager(
          storage,
          config: TokenConfigs.production(),
        );
    }
  }
}
```

### 5. **Monitor Token Lifecycle**
```dart
class MonitoredTokenManager implements TokenManager {
  final TokenManager _delegate;
  final Analytics _analytics;
  
  MonitoredTokenManager(this._delegate, this._analytics);
  
  @override
  Future<void> saveToken(String token) async {
    await _delegate.saveToken(token);
    _analytics.track('token_saved');
  }
  
  @override
  Future<void> deleteToken() async {
    await _delegate.deleteToken();
    _analytics.track('token_deleted');
  }
  
  @override
  Future<String?> getToken() async {
    final token = await _delegate.getToken();
    if (token == null) {
      _analytics.track('token_missing');
    }
    return token;
  }
  
  // Delegate other methods...
}
```

## 💡 Examples

### Login Flow with Token Management
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
        
        if (accessToken != null) {
          await _tokenManager.saveToken(accessToken);
          
          if (refreshToken != null) {
            await _tokenManager.saveRefreshToken(refreshToken);
          }
          
          return LoginResult.success();
        }
      }
      
      return LoginResult.failure('Invalid credentials');
    } catch (e) {
      return LoginResult.failure('Login failed: $e');
    }
  }
  
  Future<void> logout() async {
    try {
      // Notify server about logout
      await _networkService.post('/auth/logout');
    } catch (e) {
      // Continue with local logout even if server request fails
      print('Server logout failed: $e');
    } finally {
      // Always clear local tokens
      await _tokenManager.deleteToken();
      await _tokenManager.deleteRefreshToken();
    }
  }
  
  Future<bool> isLoggedIn() async {
    final token = await _tokenManager.getToken();
    return token != null;
  }
}
```

### Token Refresh with UI Feedback
```dart
class AuthenticatedApiClient {
  final NetworkService _networkService;
  final TokenManager _tokenManager;
  final StreamController<AuthState> _authStateController;
  
  AuthenticatedApiClient(this._networkService, this._tokenManager)
    : _authStateController = StreamController<AuthState>.broadcast();
  
  Stream<AuthState> get authStateStream => _authStateController.stream;
  
  Future<T> authenticatedRequest<T>(
    Future<NetworkResponse> request,
    T Function(dynamic) parser,
  ) async {
    try {
      _authStateController.add(AuthState.loading);
      
      final response = await request;
      
      if (response.isSuccess) {
        _authStateController.add(AuthState.authenticated);
        return parser(response.data);
      } else if (response.statusCode == 401) {
        // Token might be expired, try refresh
        _authStateController.add(AuthState.refreshing);
        
        final refreshed = await _refreshToken();
        if (refreshed) {
          // Retry original request
          final retryResponse = await request;
          if (retryResponse.isSuccess) {
            _authStateController.add(AuthState.authenticated);
            return parser(retryResponse.data);
          }
        }
        
        _authStateController.add(AuthState.unauthenticated);
        throw AuthenticationException('Authentication failed');
      } else {
        throw ApiException('Request failed: ${response.error?.message}');
      }
    } catch (e) {
      _authStateController.add(AuthState.error);
      rethrow;
    }
  }
  
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _tokenManager.getRefreshToken();
      if (refreshToken == null) return false;
      
      final response = await _networkService.post('/auth/refresh', data: {
        'refresh_token': refreshToken,
      });
      
      if (response.isSuccess && response.data is Map) {
        final data = response.data as Map;
        final newAccessToken = data['access_token'];
        
        if (newAccessToken != null) {
          await _tokenManager.saveToken(newAccessToken);
          return true;
        }
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
}

enum AuthState {
  authenticated,
  unauthenticated,
  loading,
  refreshing,
  error,
}
```

## 🔗 Related Documentation

- [Storage Service Documentation](storage-service.md)
- [Network Service Documentation](network-service.md)
- [Complete Examples](examples.md)
- [Migration Guide](migration-guide.md) 