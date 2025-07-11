# ⚙️ Configuration Guide

Complete configuration options for Flutter Infra services.

## 📖 Table of Contents
- [Storage Configuration](#storage-configuration)
- [Network Configuration](#network-configuration)
- [Token Configuration](#token-configuration)
- [Environment-Specific Configuration](#environment-specific-configuration)
- [Advanced Configuration](#advanced-configuration)

## 💾 Storage Configuration

### StorageConfig Options

```dart
final config = StorageConfig(
  // Logging
  enableLogging: true,              // Enable debug logging
  
  // Performance
  enableCache: true,                // Enable in-memory caching
  cacheTimeout: Duration(minutes: 30), // Cache timeout duration
  
  // Security
  encryptionKey: 'your-secret-key', // Optional encryption key for Hive
  
  // Custom settings
  customSettings: {
    'hive_box_name': 'custom_box',
    'secure_storage_options': {
      'accessibility': 'first_unlock_this_device',
    },
  },
);

final storageService = await StorageService.create(config: config);
```

### Platform-Specific Settings

#### iOS Configuration
```dart
final iosConfig = StorageConfig(
  customSettings: {
    'ios_options': {
      'accessibility': 'first_unlock_this_device',
      'synchronizable': false,
      'accountName': 'MyApp',
    }
  },
);
```

#### Android Configuration
```dart
final androidConfig = StorageConfig(
  customSettings: {
    'android_options': {
      'encryptedSharedPreferences': true,
      'keyCipherAlgorithm': 'AES/GCM/NoPadding',
      'prefsMasterKeyAlias': 'MyAppMasterKey',
    }
  },
);
```

### Storage Implementation Selection

#### Manual Implementation Setup
```dart
// Custom storage implementations
final normalStorage = await PreferencesStorageImpl.getInstance(
  config: StorageConfig(
    enableCache: true,
    enableLogging: true,
  ),
);

final secureStorage = SecureStorageImpl.getInstance(
  config: StorageConfig(
    enableLogging: true,
    customSettings: {
      'accessibility': 'first_unlock_this_device',
    },
  ),
);

// Use with StorageService
final storageService = StorageService(
  normalStorage: normalStorage,
  secureStorage: secureStorage,
);
```

#### Hive Configuration
```dart
// Normal Hive storage
final hiveStorage = await HiveStorageImpl.getInstance(
  boxName: 'user_data',
  config: StorageConfig(
    enableLogging: true,
    enableCache: false, // Hive has its own caching
  ),
);

// Encrypted Hive storage
final encryptedHiveStorage = await HiveStorageImpl.getInstance(
  boxName: 'secure_data',
  encryptionKey: 'your-256-bit-key',
  config: StorageConfig(
    enableLogging: true,
  ),
);
```

## 🌐 Network Configuration

### NetworkConfig Options

```dart
final config = NetworkConfig(
  // Base URL
  baseUrl: 'https://api.example.com',
  
  // Logging
  enableLogging: true,
  maxLoggerWidth: 200,
  
  // Timeouts
  timeout: Duration(seconds: 30),
  connectTimeout: Duration(seconds: 15),
  receiveTimeout: Duration(seconds: 30),
  
  // Headers
  defaultHeaders: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'MyApp/1.0.0',
    'X-API-Version': '2.0',
  },
  
  // Interceptors
  interceptors: [
    LoggerInterceptor(maxWidth: 150),
    TokenInterceptor(),
    CustomHeaderInterceptor(),
  ],
  
  // Custom settings
  customSettings: {
    'followRedirects': true,
    'maxRedirects': 5,
    'persistentConnection': true,
  },
);
```

### Client-Specific Configuration

#### HTTP Client Configuration
```dart
final httpConfig = NetworkConfig(
  baseUrl: 'https://api.example.com',
  timeout: Duration(seconds: 15),
  customSettings: {
    'userAgent': 'MyApp/1.0',
    'connectionTimeout': Duration(seconds: 10),
    'idleTimeout': Duration(seconds: 15),
  },
);

final networkService = await NetworkService.create(
  client: HttpNetworkClient.withConfig(httpConfig),
);
```

#### Dio Client Configuration
```dart
final dioConfig = NetworkConfig(
  baseUrl: 'https://api.example.com',
  timeout: Duration(seconds: 30),
  customSettings: {
    'maxRedirects': 3,
    'followRedirects': true,
    'persistentConnection': true,
    'sendTimeout': Duration(seconds: 15),
    'receiveTimeout': Duration(seconds: 30),
  },
);

final networkService = await NetworkService.create(
  client: DioNetworkClient.withConfig(dioConfig),
);
```

### Custom Headers and Authentication

```dart
final config = NetworkConfig(
  baseUrl: 'https://api.example.com',
  defaultHeaders: {
    // Standard headers
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    
    // Custom headers
    'X-Client-Version': '1.0.0',
    'X-Platform': Platform.isIOS ? 'iOS' : 'Android',
    'X-App-Build': '123',
    
    // Optional static API key
    'X-API-Key': 'your-api-key',
  },
);
```

## 🔐 Token Configuration

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
  refreshTokenMethod: 'POST',             // HTTP method for refresh
  
  // Custom settings
  customSettings: {
    'token_expiry_field': 'expires_in',
    'scope_field': 'scope',
    'auto_refresh': true,
  },
);
```

### Token Manager Configuration

```dart
final tokenManager = DefaultTokenManager(
  storage: storageService,
  config: tokenConfig,
);

// Use with NetworkService
final networkService = await NetworkService.createWithTokenSupport(
  config: networkConfig,
  tokenManager: tokenManager,
);
```

### Custom Token Headers

```dart
// For APIs that use different authentication schemes
final apiKeyConfig = TokenConfig(
  tokenHeaderKey: 'X-API-Key',
  tokenPrefix: '',  // No prefix
  tokenStorageKey: 'api_key',
  // No refresh token for API keys
);

// For JWT with custom header
final jwtConfig = TokenConfig(
  tokenHeaderKey: 'X-Access-Token',
  tokenPrefix: 'JWT',
  tokenStorageKey: 'jwt_token',
  refreshTokenStorageKey: 'jwt_refresh',
  refreshTokenEndPoint: '/auth/refresh-jwt',
);

// For OAuth2 with custom fields
final oauthConfig = TokenConfig(
  tokenHeaderKey: 'Authorization',
  tokenPrefix: 'Bearer',
  tokenResponseField: 'accessToken',
  refreshTokenResponseField: 'refreshToken',
  tokenStorageKey: 'oauth_access_token',
  refreshTokenStorageKey: 'oauth_refresh_token',
  refreshTokenEndPoint: '/oauth/token',
);
```

## 🌍 Environment-Specific Configuration

### Environment Detection

```dart
enum Environment { development, staging, production }

class AppConfig {
  static Environment get environment {
    const env = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
    switch (env) {
      case 'staging': return Environment.staging;
      case 'production': return Environment.production;
      default: return Environment.development;
    }
  }
  
  static bool get isProduction => environment == Environment.production;
  static bool get isDevelopment => environment == Environment.development;
}
```

### Environment-Based Configuration

```dart
class ConfigFactory {
  static StorageConfig createStorageConfig() {
    switch (AppConfig.environment) {
      case Environment.development:
        return StorageConfig(
          enableLogging: true,
          enableCache: true,
          encryptionKey: 'dev_key_123',
          customSettings: {
            'hive_box_name': 'dev_storage',
          },
        );
        
      case Environment.staging:
        return StorageConfig(
          enableLogging: true,
          enableCache: true,
          encryptionKey: 'staging_key_456',
          customSettings: {
            'hive_box_name': 'staging_storage',
          },
        );
        
      case Environment.production:
        return StorageConfig(
          enableLogging: false, // Disable logging in production
          enableCache: true,
          encryptionKey: const String.fromEnvironment('STORAGE_ENCRYPTION_KEY'),
          customSettings: {
            'hive_box_name': 'prod_storage',
          },
        );
    }
  }
  
  static NetworkConfig createNetworkConfig() {
    switch (AppConfig.environment) {
      case Environment.development:
        return NetworkConfig(
          baseUrl: 'https://dev-api.example.com',
          enableLogging: true,
          timeout: Duration(seconds: 60), // Longer for debugging
          defaultHeaders: {
            'X-Environment': 'development',
            'X-Debug': 'true',
          },
        );
        
      case Environment.staging:
        return NetworkConfig(
          baseUrl: 'https://staging-api.example.com',
          enableLogging: true,
          timeout: Duration(seconds: 45),
          defaultHeaders: {
            'X-Environment': 'staging',
          },
        );
        
      case Environment.production:
        return NetworkConfig(
          baseUrl: 'https://api.example.com',
          enableLogging: false,
          timeout: Duration(seconds: 30),
          defaultHeaders: {
            'X-Environment': 'production',
          },
        );
    }
  }
  
  static TokenConfig createTokenConfig() {
    final baseKey = '${AppConfig.environment.name}_token';
    
    return TokenConfig(
      tokenHeaderKey: 'Authorization',
      tokenPrefix: 'Bearer',
      tokenStorageKey: '${baseKey}_access',
      refreshTokenStorageKey: '${baseKey}_refresh',
      refreshTokenEndPoint: '/auth/refresh',
    );
  }
}
```

### Service Factory Pattern

```dart
class ServiceFactory {
  static Future<StorageService> createStorageService() async {
    return await StorageService.create(
      config: ConfigFactory.createStorageConfig(),
    );
  }
  
  static Future<NetworkService> createNetworkService(
    StorageService storageService,
  ) async {
    final tokenManager = DefaultTokenManager(
      storage: storageService,
      config: ConfigFactory.createTokenConfig(),
    );
    
    return await NetworkService.createWithTokenSupport(
      config: ConfigFactory.createNetworkConfig(),
      tokenManager: tokenManager,
    );
  }
}
```

## 🚀 Advanced Configuration

### Custom Interceptors

```dart
class ApiVersionInterceptor implements NetworkInterceptor {
  final String version;
  
  ApiVersionInterceptor(this.version);
  
  @override
  Future<void> onRequest(NetworkRequest request) async {
    request.headers['X-API-Version'] = version;
  }
  
  @override
  Future<void> onResponse(NetworkResponse response) async {
    // Handle version-specific responses
  }
  
  @override
  Future<void> onError(NetworkError error) async {
    // Handle version-specific errors
  }
}

// Use in configuration
final config = NetworkConfig(
  baseUrl: 'https://api.example.com',
  interceptors: [
    LoggerInterceptor(),
    ApiVersionInterceptor('2.0'),
    TokenInterceptor(),
  ],
);
```

### Dynamic Configuration

```dart
class DynamicConfig {
  static Future<NetworkConfig> createNetworkConfig() async {
    // Load configuration from remote or local file
    final remoteConfig = await loadRemoteConfig();
    
    return NetworkConfig(
      baseUrl: remoteConfig['api_base_url'] ?? 'https://api.example.com',
      enableLogging: remoteConfig['enable_logging'] ?? false,
      timeout: Duration(
        seconds: remoteConfig['timeout_seconds'] ?? 30,
      ),
      defaultHeaders: Map<String, String>.from(
        remoteConfig['default_headers'] ?? {},
      ),
    );
  }
  
  static Future<Map<String, dynamic>> loadRemoteConfig() async {
    // Implementation to load from Firebase Remote Config,
    // API endpoint, or local config file
    return {};
  }
}
```

### Configuration Validation

```dart
class ConfigValidator {
  static void validateStorageConfig(StorageConfig config) {
    if (config.encryptionKey != null && config.encryptionKey!.length < 16) {
      throw ArgumentError('Encryption key must be at least 16 characters');
    }
    
    if (config.cacheTimeout != null && config.cacheTimeout!.isNegative) {
      throw ArgumentError('Cache timeout cannot be negative');
    }
  }
  
  static void validateNetworkConfig(NetworkConfig config) {
    if (config.baseUrl.isEmpty) {
      throw ArgumentError('Base URL cannot be empty');
    }
    
    if (!config.baseUrl.startsWith('http')) {
      throw ArgumentError('Base URL must start with http or https');
    }
    
    if (config.timeout != null && config.timeout!.isNegative) {
      throw ArgumentError('Timeout cannot be negative');
    }
  }
  
  static void validateTokenConfig(TokenConfig config) {
    if (config.tokenHeaderKey.isEmpty) {
      throw ArgumentError('Token header key cannot be empty');
    }
    
    if (config.tokenStorageKey.isEmpty) {
      throw ArgumentError('Token storage key cannot be empty');
    }
  }
}
```

### Usage Example with Validation

```dart
Future<void> setupServices() async {
  // Create configurations
  final storageConfig = ConfigFactory.createStorageConfig();
  final networkConfig = ConfigFactory.createNetworkConfig();
  final tokenConfig = ConfigFactory.createTokenConfig();
  
  // Validate configurations
  ConfigValidator.validateStorageConfig(storageConfig);
  ConfigValidator.validateNetworkConfig(networkConfig);
  ConfigValidator.validateTokenConfig(tokenConfig);
  
  // Create services
  final storageService = await StorageService.create(config: storageConfig);
  final networkService = await NetworkService.createWithTokenSupport(
    config: networkConfig,
    tokenManager: DefaultTokenManager(
      storage: storageService,
      config: tokenConfig,
    ),
  );
  
  // Register with DI container
  getIt.registerSingleton<StorageService>(storageService);
  getIt.registerSingleton<NetworkService>(networkService);
}
```

## 🔗 Related Documentation

- [Quick Start Guide](quick-start.md)
- [Architecture Overview](architecture.md)
- [Storage Service Documentation](storage-service.md)
- [Network Service Documentation](network-service.md)
- [Token Management Documentation](token-management.md)
- [Best Practices](best-practices.md) 