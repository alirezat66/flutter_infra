# Flutter Infra

A comprehensive Flutter package providing local storage capabilities with both standard and secure storage options. Supports simple static methods, direct implementation access, and dependency injection patterns.

## Features

- 🚀 **Simple Static API** - Easy-to-use static methods via `SimpleStorage`
- 🔧 **Advanced Features** - Direct access to typed extensions via `StorageImpl`
- 🔒 **Secure Storage** - Encrypted storage using Flutter Secure Storage
- 📱 **Standard Storage** - Key-value storage using SharedPreferences
- 🏗️ **Dependency Injection** - Service wrapper for DI frameworks
- ⚡ **Performance** - Built-in caching with configurable options
- 🎯 **Null Safe** - Full Dart null safety support
- ⚙️ **Configurable** - Customizable logging, caching, and more

## Getting Started

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_infra: ^1.0.0
```

Import the package:

```dart
import 'package:flutter_infra/flutter_infra.dart';
```

## Usage Patterns

### 1. Simple Static API (Recommended for Basic Operations)

Initialize once and use static methods:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage (required)
  await SimpleStorage.init();
  
  runApp(MyApp());
}

// Use anywhere in your app
await SimpleStorage.setString('username', 'john_doe');
String? username = SimpleStorage.getString('username');
bool isDarkMode = SimpleStorage.getBool('darkMode', defaultValue: false);
```

### 2. Direct Implementation Access (For Advanced Features)

Get the storage implementation for typed operations:

```dart
// Get the storage implementation
final storage = await StorageImpl.getInstance();

// Use typed extensions
await storage.setJson('user', {'name': 'John', 'age': 30});
Map<String, dynamic>? user = storage.getJson('user');

await storage.setStringList('tags', ['flutter', 'dart']);
List<String>? tags = storage.getStringList('tags');

await storage.setDateTime('lastLogin', DateTime.now());
DateTime? lastLogin = storage.getDateTime('lastLogin');
```

### 3. Dependency Injection Pattern

For clean architecture and testability:

```dart
// Setup in your DI container
final storageImpl = await StorageImpl.getInstance();
final storageService = StorageService(storageImpl);

// Inject into repositories
class UserRepository {
  final StorageService _storage;
  
  UserRepository(this._storage);
  
  Future<void> saveUser(User user) async {
    await _storage.setString('userId', user.id);
    await _storage.setBool('isLoggedIn', true);
  }
  
  Future<bool> isUserLoggedIn() async {
    return _storage.getBool('isLoggedIn');
  }
}
```

## API Reference

### SimpleStorage (Static Methods)

Perfect for simple key-value operations:

```dart
// Initialization (required)
await SimpleStorage.init({StorageConfig? config});

// String operations
await SimpleStorage.setString('key', 'value');
String? value = SimpleStorage.getString('key', defaultValue: 'default');

// Boolean operations
await SimpleStorage.setBool('key', true);
bool value = SimpleStorage.getBool('key', defaultValue: false);

// Key management
bool exists = SimpleStorage.hasKey('key');
await SimpleStorage.deleteKey('key');
await SimpleStorage.clearAll();

// Secure storage
await SimpleStorage.setSecureString('token', 'secret');
String? token = await SimpleStorage.getSecureString('token');
await SimpleStorage.setSecureBool('biometric', true);
bool biometric = await SimpleStorage.getSecureBool('biometric');
bool hasToken = await SimpleStorage.hasSecureKey('token');
await SimpleStorage.deleteSecureKey('token');
await SimpleStorage.clearAllSecure();
```

### StorageImpl (Advanced Features)

Access the full LocalStorage interface with typed extensions:

```dart
// Get instance (singleton)
final storage = await StorageImpl.getInstance({
  StorageConfig? config,
  FlutterSecureStorage? secureStorage,  // For testing
  SharedPreferences? sharedPreferences, // For testing
});

// All SimpleStorage methods plus:

// JSON operations
await storage.setJson('data', {'key': 'value'});
Map<String, dynamic>? data = storage.getJson('data');

// List operations
await storage.setStringList('items', ['a', 'b', 'c']);
List<String>? items = storage.getStringList('items');

// DateTime operations
await storage.setDateTime('timestamp', DateTime.now());
DateTime? timestamp = storage.getDateTime('timestamp');
```

### StorageService (Dependency Injection)

Service wrapper implementing the same interface as StorageImpl:

```dart
final service = StorageService(storageImpl);

// Same methods as StorageImpl but without extensions
await service.setString('key', 'value');
String? value = service.getString('key');
// ... all other LocalStorage methods
```

### StorageConfig

Configure storage behavior:

```dart
await SimpleStorage.init(
  config: StorageConfig(
    enableLogging: true,           // Debug logging
    enableCache: true,             // In-memory caching
    cacheTimeout: Duration(minutes: 30),
    encryptionKey: 'custom-key',   // Custom encryption
    customSettings: {'setting': 'value'},
  ),
);
```

## Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_infra/flutter_infra.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize with configuration
  await SimpleStorage.init(
    config: StorageConfig(enableLogging: true, enableCache: true),
  );
  
  runApp(MyApp());
}

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  String _username = '';
  List<String> _recentSearches = [];
  DateTime? _lastLogin;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    // Load basic settings using SimpleStorage
    final darkMode = SimpleStorage.getBool('darkMode', defaultValue: false);
    final username = SimpleStorage.getString('username', defaultValue: '');
    
    // Load complex data using StorageImpl extensions
    final storage = await StorageImpl.getInstance();
    final searches = storage.getStringList('recentSearches') ?? <String>[];
    final lastLogin = storage.getDateTime('lastLogin');
    
    setState(() {
      _darkMode = darkMode;
      _username = username;
      _recentSearches = searches;
      _lastLogin = lastLogin;
    });
  }
  
  Future<void> _saveDarkMode(bool value) async {
    await SimpleStorage.setBool('darkMode', value);
    setState(() => _darkMode = value);
  }
  
  Future<void> _saveUsername(String value) async {
    await SimpleStorage.setString('username', value);
    setState(() => _username = value);
  }
  
  Future<void> _addRecentSearch(String search) async {
    final storage = await StorageImpl.getInstance();
    final updated = [..._recentSearches, search];
    await storage.setStringList('recentSearches', updated);
    setState(() => _recentSearches = updated);
  }
  
  Future<void> _updateLastLogin() async {
    final storage = await StorageImpl.getInstance();
    final now = DateTime.now();
    await storage.setDateTime('lastLogin', now);
    setState(() => _lastLogin = now);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Column(
        children: [
          SwitchListTile(
            title: Text('Dark Mode'),
            value: _darkMode,
            onChanged: _saveDarkMode,
          ),
          ListTile(
            title: Text('Username'),
            subtitle: Text(_username.isEmpty ? 'Not set' : _username),
            trailing: Icon(Icons.edit),
            onTap: () => _showUsernameDialog(),
          ),
          ListTile(
            title: Text('Recent Searches'),
            subtitle: Text('${_recentSearches.length} items'),
            trailing: Icon(Icons.add),
            onTap: () => _addRecentSearch('Flutter ${DateTime.now().millisecond}'),
          ),
          ListTile(
            title: Text('Last Login'),
            subtitle: Text(_lastLogin?.toString() ?? 'Never'),
            trailing: Icon(Icons.refresh),
            onTap: _updateLastLogin,
          ),
        ],
      ),
    );
  }
  
  void _showUsernameDialog() {
    // Implementation for username dialog
  }
}
```

## Key Differences Between Classes

| Feature | SimpleStorage | StorageImpl | StorageService |
|---------|---------------|-------------|----------------|
| **Usage** | Static methods | Direct instance | DI wrapper |
| **Basic Operations** | ✅ | ✅ | ✅ |
| **Secure Operations** | ✅ | ✅ | ✅ |
| **Typed Extensions** | ❌ | ✅ | ❌ |
| **JSON Support** | ❌ | ✅ | ❌ |
| **List Support** | ❌ | ✅ | ❌ |
| **DateTime Support** | ❌ | ✅ | ❌ |
| **Configuration** | ✅ | ✅ | Via constructor |
| **Singleton** | ✅ | ✅ | No |

## When to Use What

- **SimpleStorage**: Quick setup, basic string/bool operations, simple apps
- **StorageImpl**: Need JSON/List/DateTime storage, complex data structures
- **StorageService**: Clean architecture, dependency injection, testing

## Storage Types

### Standard Storage (SharedPreferences)
```dart
await SimpleStorage.setString('key', 'value');
await SimpleStorage.setBool('flag', true);
bool exists = SimpleStorage.hasKey('key');
await SimpleStorage.deleteKey('key');
await SimpleStorage.clearAll();
```

### Secure Storage (Flutter Secure Storage)
```dart
await SimpleStorage.setSecureString('token', 'secret');
await SimpleStorage.setSecureBool('biometric', true);
bool hasToken = await SimpleStorage.hasSecureKey('token');
await SimpleStorage.deleteSecureKey('token');
await SimpleStorage.clearAllSecure();
```

### Typed Storage (Extensions on LocalStorage)
```dart
final storage = await StorageImpl.getInstance();

// JSON
await storage.setJson('user', {'name': 'John', 'age': 30});
Map<String, dynamic>? user = storage.getJson('user');

// Lists
await storage.setStringList('tags', ['flutter', 'dart']);
List<String>? tags = storage.getStringList('tags');

// DateTime
await storage.setDateTime('created', DateTime.now());
DateTime? created = storage.getDateTime('created');
```

## Configuration Options

```dart
StorageConfig(
  enableLogging: false,        // Enable debug logs
  enableCache: true,           // Enable in-memory caching
  cacheTimeout: Duration(minutes: 30),  // Cache expiration
  encryptionKey: null,         // Custom encryption key
  customSettings: {},          // Additional settings
)
```

## Architecture

```
SimpleStorage (Static API)
    ↓
StorageImpl (Singleton)
    ↓
LocalStorage (Interface)
    ↓
SharedPreferences + FlutterSecureStorage

StorageService (DI Wrapper)
    ↓
LocalStorage (Interface)
```

## Dependencies

- `shared_preferences` for standard storage
- `flutter_secure_storage` for encrypted storage

## Contributing

Contributions welcome! Please submit Pull Requests.
