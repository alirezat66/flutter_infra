# 💾 Storage Service Documentation

The Storage Service provides a unified interface for managing both normal and secure data storage across multiple backends with type-safe operations.

## 📖 Table of Contents
- [Quick Start](#quick-start)
- [Storage Implementations](#storage-implementations)
- [Typed Extensions](#typed-extensions)
- [Configuration](#configuration)
- [Best Practices](#best-practices)
- [Examples](#examples)

## 🚀 Quick Start

### Default Usage (Recommended for Most Apps)
```dart
import 'package:flutter_infra/flutter_infra.dart';

// Initialize with default implementations
final storageService = await StorageService.create();

// Basic operations
await storageService.setString('username', 'john_doe');
final username = await storageService.getString('username');

// Secure operations for sensitive data
await storageService.setSecureString('api_token', 'secret_token');
final token = await storageService.getSecureString('api_token');
```

### Custom Configuration
```dart
final storageService = await StorageService.create(
  config: StorageConfig(
    enableLogging: true,
    enableCache: true,
    encryptionKey: 'your-encryption-key',
  ),
);
```

### Manual Implementation Selection
```dart
final normalStorage = await PreferencesStorageImpl.getInstance();
final secureStorage = SecureStorageImpl.getInstance();

final storageService = StorageService(
  normalStorage: normalStorage,
  secureStorage: secureStorage,
);
```

## 🏗️ Storage Implementations

### PreferencesStorageImpl (SharedPreferences)
**Best for**: Basic key-value storage, user preferences, app settings

```dart
final storage = await PreferencesStorageImpl.getInstance(
  config: StorageConfig(
    enableCache: true,
    enableLogging: true,
  ),
);

await storage.setString('theme', 'dark');
final theme = await storage.getString('theme');
```

**Features:**
- ✅ Fast access with optional caching
- ✅ Cross-platform support
- ✅ Automatic persistence
- ❌ Not suitable for large amounts of data
- ❌ Not secure for sensitive data

### SecureStorageImpl (FlutterSecureStorage)
**Best for**: Authentication tokens, passwords, sensitive user data

```dart
final storage = SecureStorageImpl.getInstance(
  config: StorageConfig(enableLogging: true),
);

await storage.setString('auth_token', 'eyJhbGciOiJIUzI1NiIs...');
final token = await storage.getString('auth_token');
```

**Features:**
- ✅ Hardware-backed encryption on supported devices
- ✅ Secure by default
- ✅ Automatic key management
- ❌ Slower than normal storage
- ❌ May require user authentication on some platforms

### HiveStorageImpl (Hive Database)
**Best for**: High-performance storage, large datasets, optional encryption

```dart
// Normal Hive storage
final storage = await HiveStorageImpl.getInstance(
  boxName: 'user_data',
  config: StorageConfig(enableLogging: true),
);

// Encrypted Hive storage
final secureStorage = await HiveStorageImpl.getInstance(
  boxName: 'secure_data',
  encryptionKey: 'your-secret-key',
  config: StorageConfig(enableLogging: true),
);
```

**Features:**
- ✅ Very fast read/write operations
- ✅ Supports large amounts of data
- ✅ Optional AES-256 encryption
- ✅ Cross-platform binary format
- ❌ Requires additional setup for complex data structures

## 🧩 Typed Extensions

StorageService includes powerful typed extensions for complex data with **both normal and secure versions**.

### JSON Operations
Perfect for storing complex objects and configurations:

```dart
// User profile (normal storage)
final userProfile = {
  'name': 'John Doe',
  'email': 'john@example.com',
  'preferences': {
    'theme': 'dark',
    'notifications': true,
    'language': 'en'
  },
  'metadata': {
    'lastLogin': '2024-01-15T10:30:00Z',
    'version': '1.2.0'
  }
};

await storageService.setJson('user_profile', userProfile);
final profile = await storageService.getJson('user_profile');

// Authentication data (secure storage)
final authData = {
  'access_token': 'eyJhbGciOiJIUzI1NiIs...',
  'refresh_token': 'dGhpcyBpcyBhIHJlZnJlc2g...',
  'expires_at': '2024-01-16T10:30:00Z',
  'scope': ['read', 'write', 'admin']
};

await storageService.setSecureJson('auth_tokens', authData);
final tokens = await storageService.getSecureJson('auth_tokens');
```

### String List Operations
Ideal for tags, categories, permissions:

```dart
// User interests (normal storage)
const interests = ['technology', 'music', 'travel', 'cooking'];
await storageService.setStringList('user_interests', interests);
final userInterests = await storageService.getStringList('user_interests');

// User permissions (secure storage)
const permissions = ['admin', 'user_management', 'content_creation'];
await storageService.setSecureStringList('user_permissions', permissions);
final userPermissions = await storageService.getSecureStringList('user_permissions');
```

### DateTime Operations
Perfect for timestamps and scheduling:

```dart
// App usage tracking (normal storage)
final lastAppOpen = DateTime.now();
await storageService.setDateTime('last_app_open', lastAppOpen);
final lastOpen = await storageService.getDateTime('last_app_open');

// Security-sensitive timestamps (secure storage)
final tokenExpiry = DateTime.now().add(Duration(hours: 24));
await storageService.setSecureDateTime('token_expiry', tokenExpiry);
final expiry = await storageService.getSecureDateTime('token_expiry');
```

## ⚙️ Configuration

### StorageConfig Options

```dart
const config = StorageConfig(
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
```

### Platform-Specific Considerations

#### iOS
```dart
final config = StorageConfig(
  customSettings: {
    'ios_options': {
      'accessibility': 'first_unlock_this_device',
      'synchronizable': false,
    }
  },
);
```

#### Android
```dart
final config = StorageConfig(
  customSettings: {
    'android_options': {
      'encryptedSharedPreferences': true,
      'keyCipherAlgorithm': 'AES/GCM/NoPadding',
    }
  },
);
```

## 🏆 Best Practices

### 1. **Choose the Right Storage Type**

```dart
// ✅ Good: Normal storage for preferences
await storageService.setString('theme', 'dark');
await storageService.setBool('notifications_enabled', true);

// ✅ Good: Secure storage for sensitive data
await storageService.setSecureString('auth_token', token);
await storageService.setSecureJson('user_credentials', credentials);

// ❌ Bad: Sensitive data in normal storage
await storageService.setString('password', 'secret123'); // Security risk!
```

### 2. **Use Typed Extensions for Complex Data**

```dart
// ✅ Good: Type-safe JSON operations
final settings = {
  'theme': 'dark',
  'language': 'en',
  'notifications': true
};
await storageService.setJson('app_settings', settings);

// ❌ Bad: Manual JSON encoding
await storageService.setString('app_settings', jsonEncode(settings));
```

### 3. **Handle Errors Gracefully**

```dart
// ✅ Good: Proper error handling
try {
  final userData = await storageService.getJson('user_profile');
  if (userData != null) {
    // Process user data
  } else {
    // Handle missing data
    print('No user profile found');
  }
} catch (e) {
  print('Error loading user profile: $e');
  // Fallback logic
}
```

### 4. **Use Default Values**

```dart
// ✅ Good: Provide sensible defaults
final theme = await storageService.getString('theme', defaultValue: 'light') ?? 'light';
final isFirstLaunch = await storageService.getBool('is_first_launch', defaultValue: true);
```

### 5. **Organize Your Keys**

```dart
class StorageKeys {
  // User data
  static const String userProfile = 'user_profile';
  static const String userPreferences = 'user_preferences';
  
  // Security
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  
  // App state
  static const String isFirstLaunch = 'is_first_launch';
  static const String lastAppVersion = 'last_app_version';
}

// Usage
await storageService.setJson(StorageKeys.userProfile, profileData);
final token = await storageService.getSecureString(StorageKeys.authToken);
```

## 💡 Examples

### User Repository Pattern

```dart
class UserRepository {
  final StorageService _storage;
  
  UserRepository(this._storage);
  
  Future<void> saveUser(User user) async {
    await _storage.setJson('user_profile', user.toJson());
    await _storage.setDateTime('profile_updated', DateTime.now());
  }
  
  Future<User?> getUser() async {
    final userData = await _storage.getJson('user_profile');
    return userData != null ? User.fromJson(userData) : null;
  }
  
  Future<void> saveAuthTokens(String accessToken, String refreshToken) async {
    await _storage.setSecureJson('auth_tokens', {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'created_at': DateTime.now().toIso8601String(),
    });
  }
  
  Future<AuthTokens?> getAuthTokens() async {
    final tokenData = await _storage.getSecureJson('auth_tokens');
    return tokenData != null ? AuthTokens.fromJson(tokenData) : null;
  }
  
  Future<void> clearUserData() async {
    await _storage.deleteKey('user_profile');
    await _storage.deleteKey('profile_updated');
    await _storage.deleteSecureKey('auth_tokens');
  }
}
```

### Settings Manager

```dart
class SettingsManager {
  final StorageService _storage;
  
  SettingsManager(this._storage);
  
  // App preferences
  Future<void> setTheme(String theme) async {
    await _storage.setString('theme', theme);
  }
  
  Future<String> getTheme() async {
    return await _storage.getString('theme', defaultValue: 'system') ?? 'system';
  }
  
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _storage.setBool('notifications_enabled', enabled);
  }
  
  Future<bool> areNotificationsEnabled() async {
    return await _storage.getBool('notifications_enabled', defaultValue: true);
  }
  
  // Security preferences (stored securely)
  Future<void> setBiometricsEnabled(bool enabled) async {
    await _storage.setSecureBool('biometrics_enabled', enabled);
  }
  
  Future<bool> isBiometricsEnabled() async {
    return await _storage.getSecureBool('biometrics_enabled', defaultValue: false);
  }
  
  // Complex settings
  Future<void> saveAppSettings(AppSettings settings) async {
    await _storage.setJson('app_settings', settings.toJson());
    await _storage.setDateTime('settings_updated', DateTime.now());
  }
  
  Future<AppSettings?> getAppSettings() async {
    final settingsData = await _storage.getJson('app_settings');
    return settingsData != null ? AppSettings.fromJson(settingsData) : null;
  }
}
```

### Cache Manager with Expiration

```dart
class CacheManager {
  final StorageService _storage;
  final Duration _defaultTtl;
  
  CacheManager(this._storage, {Duration? defaultTtl}) 
    : _defaultTtl = defaultTtl ?? Duration(hours: 1);
  
  Future<void> cacheData<T>(String key, T data, {Duration? ttl}) async {
    final expiryTime = DateTime.now().add(ttl ?? _defaultTtl);
    
    final cacheEntry = {
      'data': data,
      'expires_at': expiryTime.toIso8601String(),
    };
    
    await _storage.setJson('cache_$key', cacheEntry);
  }
  
  Future<T?> getCachedData<T>(String key) async {
    final cacheEntry = await _storage.getJson('cache_$key');
    
    if (cacheEntry == null) return null;
    
    final expiryTime = DateTime.parse(cacheEntry['expires_at']);
    
    if (DateTime.now().isAfter(expiryTime)) {
      await _storage.deleteKey('cache_$key');
      return null;
    }
    
    return cacheEntry['data'] as T?;
  }
  
  Future<void> clearExpiredCache() async {
    // Implementation would iterate through cache keys and remove expired entries
  }
}
```

## 🔗 Related Documentation

- [Network Service Documentation](network-service.md)
- [Token Management Documentation](token-management.md)
- [Complete Examples](examples.md)
- [Migration Guide](migration-guide.md) 