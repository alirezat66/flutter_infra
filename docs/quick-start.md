# 🚀 Quick Start Guide

Get up and running with Flutter Infra in minutes!

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_infra: ^0.0.1
```

## 💾 Storage Quick Start

### Basic Storage Operations
```dart
import 'package:flutter_infra/flutter_infra.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage service
  final storageService = await StorageService.create();
  
  // Basic operations
  await storageService.setString('username', 'john_doe');
  final username = await storageService.getString('username');

  // Secure storage for sensitive data
  await storageService.setSecureString('api_token', 'secret_token');
  final token = await storageService.getSecureString('api_token');
  
  runApp(MyApp());
}
```

### Typed Extensions
```dart
final storageService = await StorageService.create();

// JSON Operations
await storageService.setJson('user_profile', {
  'name': 'John Doe',
  'email': 'john@example.com',
  'preferences': {'theme': 'dark'}
});
final profile = await storageService.getJson('user_profile');

// String Lists
await storageService.setStringList('interests', ['tech', 'music', 'travel']);
final interests = await storageService.getStringList('interests');

// DateTime Operations
await storageService.setDateTime('last_login', DateTime.now());
final lastLogin = await storageService.getDateTime('last_login');
```

## 🌐 Network Quick Start

### Basic Network Operations
```dart
import 'package:flutter_infra/flutter_infra.dart';

// Create network service
final networkService = await NetworkService.create(
  config: NetworkConfig(
    baseUrl: 'https://api.example.com',
    enableLogging: true,
  ),
);

// Make API calls
final response = await networkService.getJson('/users/profile');
await networkService.postJson('/users/update', jsonBody: {'name': 'John'});
```

### With Authentication
```dart
// Create storage for token management
final storageService = await StorageService.create();

// Create network service with token support
final networkService = await NetworkService.createWithTokenSupport(
  config: NetworkConfig(
    baseUrl: 'https://api.example.com',
    enableLogging: true,
  ),
  tokenManager: DefaultTokenManager(storage: storageService),
);

// Tokens are automatically managed
final userProfile = await networkService.getJson('/protected/profile');
```

## 🔧 Basic Configuration

### Storage Configuration
```dart
final storageService = await StorageService.create(
  config: StorageConfig(
    enableLogging: true,
    enableCache: true,
    encryptionKey: 'your-encryption-key',
  ),
);
```

### Network Configuration
```dart
final networkService = await NetworkService.create(
  config: NetworkConfig(
    baseUrl: 'https://api.example.com',
    enableLogging: true,
    timeout: Duration(seconds: 30),
    defaultHeaders: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ),
);
```

## 📱 Example App

Check out the [example directory](../example/) for a complete Flutter app demonstrating:
- **Default Usage**: Basic storage and network operations
- **Common Usage**: Token management and API integration  
- **Advanced Usage**: Custom configurations and interceptors

## 📚 Next Steps

Now that you have the basics working, explore the detailed documentation:

- **[💾 Storage Service](storage-service.md)** - Complete storage guide with all implementations
- **[🌐 Network Service](network-service.md)** - Advanced networking with interceptors and tokens
- **[🔐 Token Management](token-management.md)** - Secure authentication handling
- **[💡 Complete Examples](examples.md)** - Real-world usage patterns
- **[🏗️ Architecture Overview](architecture.md)** - System design and patterns
- **[⚙️ Configuration Guide](configuration.md)** - Advanced setup options
- **[🏆 Best Practices](best-practices.md)** - Recommended patterns and security

## 🤝 Need Help?

- 📖 **Documentation**: Browse the [docs](.) directory for detailed guides
- 🐛 **Issues**: [GitHub Issues](https://github.com/your-repo/flutter_infra/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/your-repo/flutter_infra/discussions) 