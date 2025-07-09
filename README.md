# Flutter Infra

A simple and easy-to-use Flutter package that provides local storage capabilities without the complexity of dependency injection. Perfect for storing user preferences, app settings, and sensitive data.

## Features

- 🚀 **Easy to use** - No dependency injection required, use directly out of the box
- 🔒 **Secure storage** - Built-in support for encrypted storage using Flutter Secure Storage
- 📱 **Standard storage** - Regular key-value storage using SharedPreferences
- 🔧 **Simple API** - Intuitive methods for common data types (String, bool)
- 📦 **Ready to use** - Global instance available immediately
- 🎯 **Type safe** - Full Dart null safety support

## Getting started

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_infra: ^1.0.0
```

Then import and start using immediately:

```dart
import 'package:flutter_infra/flutter_infra.dart';
```

## Usage

### Basic Usage (Recommended)

Use the global `storage` instance for immediate access:

```dart
import 'package:flutter_infra/flutter_infra.dart';

// Save data
await storage.setString('username', 'john_doe');
await storage.setBool('isDarkMode', true);

// Retrieve data
String? username = storage.getString('username');
bool isDarkMode = storage.getBool('isDarkMode', defaultValue: false);

// Check if key exists
bool hasUsername = storage.hasKey('username');

// Delete data
await storage.deleteKey('username');
```

### Secure Storage

For sensitive data like tokens, passwords, or personal information:

```dart
// Save secure data
await storage.setSecureString('auth_token', 'your_secret_token');
await storage.setSecureBool('biometric_enabled', true);

// Retrieve secure data
String? token = await storage.getSecureString('auth_token');
bool biometricEnabled = await storage.getSecureBool('biometric_enabled');

// Check secure key
bool hasToken = await storage.hasSecureKey('auth_token');

// Delete secure data
await storage.deleteSecureKey('auth_token');
```

### Advanced Usage

Create your own instance if needed:

```dart
final myStorage = SimpleStorage();
await myStorage.setString('app_version', '1.0.0');
```

Clear all data:

```dart
// Clear all standard storage
await storage.clearAll();

// Clear all secure storage
await storage.clearAllSecure();
```

Manual initialization (optional):

```dart
// Usually not needed as initialization happens automatically
await storage.initialize();
```

### Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_infra/flutter_infra.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _isDarkMode = storage.getBool('dark_mode', defaultValue: false);
      _username = storage.getString('username', defaultValue: 'Guest') ?? 'Guest';
    });
  }

  void _toggleDarkMode(bool value) async {
    await storage.setBool('dark_mode', value);
    setState(() {
      _isDarkMode = value;
    });
  }

  void _saveUsername(String username) async {
    await storage.setString('username', username);
    setState(() {
      _username = username;
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
        ],
      ),
    );
  }
}
```

## API Reference

### LocalStorage Interface

| Method | Description | Storage Type |
|--------|-------------|--------------|
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

### Additional Methods

| Method | Description |
|--------|-------------|
| `clearAll()` | Clear all standard storage |
| `clearAllSecure()` | Clear all secure storage |
| `initialize()` | Manual initialization (optional) |

## Why Flutter Infra?

- **No Setup Required**: Start using immediately without any configuration
- **No DI Complexity**: No need for dependency injection frameworks
- **Battle Tested**: Built on SharedPreferences and Flutter Secure Storage
- **Simple API**: Intuitive methods that just work
- **Null Safe**: Full null safety support for modern Flutter apps

## Dependencies

This package uses:
- `shared_preferences` for standard local storage
- `flutter_secure_storage` for encrypted storage

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
