# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.1] - 2024-12-19

### Added
- **Storage Infrastructure**: Multiple storage backends with SharedPreferences, FlutterSecureStorage, and Hive support
- **Network Infrastructure**: Dual HTTP client support (dart:io HTTP and Dio implementations)
- **Token Management**: Automatic token injection, secure storage integration, and configurable refresh strategies
- **Typed Extensions**: Built-in support for JSON, lists, DateTime, and custom objects with both normal and secure versions
- **Interceptor System**: LoggerInterceptor and TokenInterceptor with extensible design
- **Cross-Platform Support**: Works on iOS, Android, Web, Windows, macOS, and Linux
- **Comprehensive Documentation**: Modular documentation structure with detailed guides and examples
- **Example App**: Complete Flutter example demonstrating all features
- **Testing Support**: Comprehensive test coverage with mock support

### Features
- **StorageService**: High-level storage interface with typed extensions
- **NetworkService**: HTTP service with automatic token management
- **TokenManager**: Secure token storage and retrieval
- **TokenRefreshStrategy**: Configurable token refresh logic
- **Multiple Storage Implementations**: PreferencesStorageImpl, SecureStorageImpl, HiveStorageImpl
- **Network Clients**: HttpNetworkClient and DioNetworkClient
- **Configuration System**: Flexible configuration for storage, network, and token management
- **Dependency Injection**: Clean DI support with service factories
