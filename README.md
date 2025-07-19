# Flutter Infra 🏗️

A comprehensive Flutter package providing clean, type-safe local storage solutions and robust network infrastructure with advanced token management and refresh strategies.

## ✨ Features

### 💾 Storage Infrastructure
- 🎯 **Multiple Storage Backends**: SharedPreferences, FlutterSecureStorage, and Hive support
- 🔐 **Security First**: Clear separation between normal and secure storage operations  
- 🧩 **Type Safety**: Built-in support for JSON, lists, DateTime, and custom objects
- ⚡ **Performance**: Optional caching and optimized storage implementations

### 🌐 Network Infrastructure  
- 🚀 **Dual HTTP Clients**: Built-in support for both dart:io HTTP and Dio implementations
- 🔑 **Token Management**: Automatic token injection and secure storage integration
- 🔄 **Refresh Token Strategy**: Configurable token refresh with Strategy design pattern
- 📡 **Interceptor System**: LoggerInterceptor, TokenInterceptor, and CacheInterceptor with extensible design

### 🔧 Common Features
- 🔧 **Dependency Injection**: Clean DI support with flexible configuration
- 📱 **Cross Platform**: Works on iOS, Android, Web, Windows, macOS, and Linux
- 🧪 **Fully Tested**: Comprehensive test coverage with mock support

## 🚀 Quick Start

### Installation

```yaml
dependencies:
  flutter_infra: ^0.0.1
```

### Basic Usage

```dart
import 'package:flutter_infra/flutter_infra.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Storage operations
  final storageService = await StorageService.create();
  await storageService.setString('username', 'john_doe');
  await storageService.setSecureString('api_token', 'secret_token');
  
  // Network operations  
  final networkService = await NetworkService.create(
    config: NetworkConfig(baseUrl: 'https://api.example.com'),
  );
  final response = await networkService.getJson('/users/profile');
  
  runApp(MyApp());
}
```

### With Authentication

```dart
// Create network service with automatic token management
final networkService = await NetworkService.createWithTokenSupport(
  config: NetworkConfig(baseUrl: 'https://api.example.com'),
  tokenManager: DefaultTokenManager(storage: storageService),
);

// Tokens are automatically handled
final userProfile = await networkService.getJson('/protected/profile');
```

### With HTTP Response Caching

```dart
// Create network service with caching enabled
final networkService = await NetworkService.createWithCache(
  config: NetworkConfig(baseUrl: 'https://api.example.com'),
  cacheConfig: CacheConfig(
    defaultCacheDuration: Duration(minutes: 5),
    maxCacheSize: 100,
    customCacheDurations: {
      '/users': Duration(hours: 1),
      '/posts': Duration(minutes: 30),
    },
  ),
);

// Responses are automatically cached
final users = await networkService.getJson('/users');  // Network call
final usersAgain = await networkService.getJson('/users');  // Cached response
```

## 📚 Documentation

### 📖 Getting Started
- **[🚀 Quick Start Guide](doc/quick-start.md)** - Get up and running in minutes
- **[🏗️ Architecture Overview](doc/architecture.md)** - System design and component relationships
- **[⚙️ Configuration Guide](doc/configuration.md)** - Advanced setup and customization options

### 📋 Service Documentation
- **[💾 Storage Service](doc/storage-service.md)** - Complete storage documentation with implementations and typed extensions
- **[🌐 Network Service](doc/network-service.md)** - Network client documentation with interceptors and configuration
- **[🗄️ Cache Interceptor](doc/cache-interceptor.md)** - HTTP response caching with configurable options
- **[🔐 Token Management](doc/token-management.md)** - Token manager, refresh strategies, and security

### 💡 Guides & Best Practices
- **[📋 Complete Examples](doc/examples.md)** - Real-world usage patterns and implementation examples
- **[🏆 Best Practices](doc/best-practices.md)** - Recommended patterns, security guidelines, and performance tips

## 🧩 Key Capabilities

### Typed Storage Extensions
```dart
// JSON operations with both normal and secure versions
await storageService.setJson('user_profile', userData);
await storageService.setSecureJson('auth_tokens', tokenData);

// DateTime and list operations
await storageService.setDateTime('last_login', DateTime.now());
await storageService.setStringList('interests', ['tech', 'music']);
```

### Smart Network Client
```dart
// JSON convenience methods
final users = await networkService.getJson('/users');
await networkService.postJson('/users', jsonBody: newUser);

// Automatic token management and refresh
final profile = await networkService.getJson('/protected/profile');
```

## 🏗️ Architecture

Flutter Infra follows a layered architecture with clear separation of concerns:

- **Application Layer**: Your Flutter app, repositories, and services
- **Flutter Infra Layer**: StorageService, NetworkService, TokenManager
- **Implementation Layer**: Storage implementations, network clients, interceptors  
- **Platform Layer**: SharedPreferences, FlutterSecureStorage, Hive, HTTP clients

## 📱 Example App

Check out the [example directory](example/) for a complete Flutter app demonstrating:
- **Default Usage**: Basic storage and network operations
- **Common Usage**: Token management and API integration  
- **Advanced Usage**: Custom configurations and interceptors

## 🧪 Testing

```bash
dart test
```

The package includes comprehensive test coverage with unit tests, integration tests, and mock support for testing your own code.

## 🤝 Getting Help

- 📖 **Documentation**: Browse the [doc](doc/) directory for detailed guides
- 🐛 **Issues**: [GitHub Issues](https://github.com/your-repo/flutter_infra/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/your-repo/flutter_infra/discussions)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Flutter Infra** - Building robust Flutter applications with confidence! 🚀
