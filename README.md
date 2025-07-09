# Flutter Infra

A comprehensive and easy-to-use Flutter package that provides local storage capabilities with both standard and secure storage options. Perfect for storing user preferences, app settings, and sensitive data with flexible configuration and dependency injection support.

## Features

- 🚀 **Easy to use** - Simple static API with intuitive methods
- 🔒 **Secure storage** - Built-in support for encrypted storage using Flutter Secure Storage
- 📱 **Standard storage** - Regular key-value storage using SharedPreferences
- 🔧 **Flexible API** - Multiple usage patterns from simple static methods to dependency injection
- 📦 **Type-safe extensions** - Support for JSON, lists, and DateTime storage
- ⚡ **Performance optimized** - Built-in caching for improved performance
- 🎯 **Null safe** - Full Dart null safety support
- ⚙️ **Configurable** - Customizable settings for logging, caching, and more

## Getting started

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_infra: ^1.0.0
```

Then import and initialize:

```dart
import 'package:flutter_infra/flutter_infra.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage (required before using SimpleStorage)
  await SimpleStorage.init();
  
  runApp(MyApp());
}
```

## Usage Patterns

### 1. Simple Static API (Recommended for most use cases)

The easiest way to use flutter_infra with static methods:

```dart
import 'package:flutter_infra/flutter_infra.dart';

// Initialize once in main()
await SimpleStorage.init();

// Save data
await SimpleStorage.setString('username', 'john_doe');
await SimpleStorage.setBool('isDarkMode', true);

// Retrieve data
String? username = SimpleStorage.getString('username');
bool isDarkMode = SimpleStorage.getBool('isDarkMode', defaultValue: false);

// Check if key exists
bool hasUsername = SimpleStorage.hasKey('username');

// Delete data
await SimpleStorage.deleteKey('username');
```

### 2. Dependency Injection Pattern

For apps using dependency injection frameworks:

```dart
import 'package:flutter_infra/flutter_infra.dart';

// Create storage implementation
final storageImpl = await StorageImpl.getInstance();

// Inject into service
final storageService = StorageService(storageImpl);

// Use in your repositories or services
class UserRepository {
  final StorageService _storage;
  
  UserRepository(this._storage);
  
  Future<void> saveUser(User user) async {
    await _storage.setString('user_id', user.id);
    await _storage.setBool('is_logged_in', true);
  }
}
```

### 3. Direct Implementation Access

For advanced use cases requiring direct access:

```dart
import 'package:flutter_infra/flutter_infra.dart';

// Get storage implementation with custom config
final storage = await StorageImpl.getInstance(
  config: StorageConfig(
    enableLogging: true,
    enableCache: true,
    cacheTimeout: Duration(minutes: 30),
  ),
);

await storage.setString('key', 'value');
```

## Storage Types

### Standard Storage

For regular app data using SharedPreferences:

```dart
// String operations
await SimpleStorage.setString('username', 'john_doe');
String? username = SimpleStorage.getString('username', defaultValue: 'guest');

// Boolean operations  
await SimpleStorage.setBool('isDarkMode', true);
bool isDarkMode = SimpleStorage.getBool('isDarkMode', defaultValue: false);

// Key management
bool exists = SimpleStorage.hasKey('username');
await SimpleStorage.deleteKey('username');
await SimpleStorage.clearAll(); // Clear all standard storage
```

### Secure Storage

For sensitive data using Flutter Secure Storage:

```dart
// Save secure data
await SimpleStorage.setSecureString('auth_token', 'your_secret_token');
await SimpleStorage.setSecureBool('biometric_enabled', true);

// Retrieve secure data
String? token = await SimpleStorage.getSecureString('auth_token');
bool biometricEnabled = await SimpleStorage.getSecureBool('biometric_enabled');

// Secure key management
bool hasToken = await SimpleStorage.hasSecureKey('auth_token');
await SimpleStorage.deleteSecureKey('auth_token');
await SimpleStorage.clearAllSecure(); // Clear all secure storage
```

## Advanced Features

### Typed Storage Extensions

Store complex data types with built-in serialization:

```dart
// JSON objects
Map<String, dynamic> userProfile = {'name': 'John', 'age': 30};
await storage.setJson('user_profile', userProfile);
Map<String, dynamic>? profile = storage.getJson('user_profile');

// String lists
List<String> tags = ['flutter', 'dart', 'mobile'];
await storage.setStringList('user_tags', tags);
List<String>? userTags = storage.getStringList('user_tags');

// DateTime objects
DateTime lastLogin = DateTime.now();
await storage.setDateTime('last_login', lastLogin);
DateTime? loginTime = storage.getDateTime('last_login');
```

### Configuration Options

Customize storage behavior with `StorageConfig`:

```dart
await SimpleStorage.init(
  config: StorageConfig(
    enableLogging: true,        // Enable debug logging
    enableCache: true,          // Enable in-memory caching
    cacheTimeout: Duration(minutes: 30), // Cache timeout
    customSettings: {
      'encryption_level': 'high',
    },
  ),
);
```

### Performance Optimization

The package includes built-in caching for improved performance:

```dart
// First call hits storage
String value1 = SimpleStorage.getString('cached_key'); 

// Subsequent calls use cache (faster)
String value2 = SimpleStorage.getString('cached_key'); 
```

## Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_infra/flutter_infra.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage with custom config
  await SimpleStorage.init(
    config: StorageConfig(
      enableLogging: true,
      enableCache: true,
    ),
  );
  
  runApp(MyApp());
}

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  String _username = '';
  List<String> _favoriteFeatures = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    // Load regular settings
    final isDarkMode = SimpleStorage.getBool('dark_mode', defaultValue: false);
    final username = SimpleStorage.getString('username', defaultValue: 'Guest') ?? 'Guest';
    
    // Load complex data using extensions
    final storage = await StorageImpl.getInstance();
    final features = storage.getStringList('favorite_features') ?? <String>[];
    
    setState(() {
      _isDarkMode = isDarkMode;
      _username = username;
      _favoriteFeatures = features;
    });
  }

  void _toggleDarkMode(bool value) async {
    await SimpleStorage.setBool('dark_mode', value);
    setState(() {
      _isDarkMode = value;
    });
  }

  void _saveUsername(String username) async {
    await SimpleStorage.setString('username', username);
    setState(() {
      _username = username;
    });
  }

  void _saveFavoriteFeatures(List<String> features) async {
    final storage = await StorageImpl.getInstance();
    await storage.setStringList('favorite_features', features);
    setState(() {
      _favoriteFeatures = features;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Column(
        children: [
          SwitchListTile(
            title: Text('Dark Mode'),
            value: _isDarkMode,
            onChanged: _toggleDarkMode,
          ),
          ListTile(
            title: Text('Username: $_username'),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // Show dialog to edit username
              },
            ),
          ),
          ListTile(
            title: Text('Favorite Features: ${_favoriteFeatures.length}'),
            subtitle: Text(_favoriteFeatures.join(', ')),
          ),
        ],
      ),
    );
  }
}
```

## API Reference

### SimpleStorage (Static API)

| Method | Description | Storage Type |
|--------|-------------|--------------|
| `init({config, secureStorage, sharedPreferences})` | Initialize storage (required) | - |
| `setString(key, value)` | Save string value | Standard |
| `getString(key, {defaultValue})` | Get string value | Standard |
| `setBool(key, value)` | Save boolean value | Standard |
| `getBool(key, {defaultValue})` | Get boolean value | Standard |
| `hasKey(key)` | Check if key exists | Standard |
| `deleteKey(key)` | Delete key | Standard |
| `setSecureString(key, value)` | Save encrypted string | Secure |
| `getSecureString(key, {defaultValue})` | Get encrypted string | Secure |
| `setSecureBool(key, value)` | Save encrypted boolean | Secure |
| `getSecureBool(key, {defaultValue})` | Get encrypted boolean | Secure |
| `hasSecureKey(key)` | Check if secure key exists | Secure |
| `deleteSecureKey(key)` | Delete secure key | Secure |
| `clearAll()` | Clear all standard storage | Standard |
| `clearAllSecure()` | Clear all secure storage | Secure |

### TypedStorage Extensions

| Method | Description | Data Type |
|--------|-------------|-----------|
| `setJson(key, value)` | Save JSON object | Map<String, dynamic> |
| `getJson(key)` | Get JSON object | Map<String, dynamic>? |
| `setStringList(key, value)` | Save string list | List<String> |
| `getStringList(key)` | Get string list | List<String>? |
| `setDateTime(key, value)` | Save DateTime | DateTime |
| `getDateTime(key)` | Get DateTime | DateTime? |

### StorageConfig

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `enableLogging` | bool | false | Enable debug logging |
| `enableCache` | bool | true | Enable in-memory caching |
| `cacheTimeout` | Duration | 30 minutes | Cache timeout duration |
| `encryptionKey` | String? | null | Custom encryption key |
| `customSettings` | Map<String, dynamic> | {} | Custom configuration |

## Architecture

The package provides multiple layers for different use cases:

```
┌─────────────────────────────────────────┐
│            SimpleStorage                │  ← Static API (Recommended)
│         (Static Methods)                │
├─────────────────────────────────────────┤
│           StorageService                │  ← Dependency Injection
│        (Service Wrapper)                │
├─────────────────────────────────────────┤
│            StorageImpl                  │  ← Core Implementation
│      (LocalStorage Interface)          │
├─────────────────────────────────────────┤
│   SharedPreferences | SecureStorage    │  ← Platform Storage
└─────────────────────────────────────────┘
```

## Dependencies

This package uses:
- `shared_preferences` for standard local storage
- `flutter_secure_storage` for encrypted storage

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
