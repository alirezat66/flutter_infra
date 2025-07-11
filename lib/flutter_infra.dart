/// Flutter Infrastructure Package
///
/// A comprehensive package providing local storage and network capabilities
/// for Flutter applications.
library;

// Storage Services
// Export the LocalStorage interface
export 'src/storage/local_storage.dart';

// Export storage implementations
export 'src/storage/preferences_storage_impl.dart';
export 'src/storage/secure_storage_impl.dart';
export 'src/storage/hive_storage_impl.dart';

// Export the SimpleStorage static wrapper for easy usage (commented out until implemented)
// export 'src/storage/simple_storage.dart';

// Export the StorageService for dependency injection
export 'src/storage/storage_service.dart';

// Export storage configuration
export 'src/storage/storage_config.dart';

// Export typed storage extensions
export 'src/storage/typed_storage_ext.dart';

// Network Services
// Export the NetworkClient interface
export 'src/network/core/api_client.dart';

// Export network implementations
export 'src/network/http/http_network_client.dart';
export 'src/network/dio/dio_network_client.dart';
export 'src/network/dio/network_interceptor_adapter.dart';

// Export the NetworkService for dependency injection (recommended)
export 'src/network/network_service.dart';

// Export network configuration and core classes
export 'src/network/core/network_config.dart';
export 'src/network/core/network_request.dart';
export 'src/network/core/network_response.dart';
export 'src/network/core/network_error.dart';
export 'src/network/core/network_interceptor.dart';

// Export network interceptors
export 'src/network/core/inceptors/logger_interceptor.dart';
export 'src/network/core/inceptors/token_interceptor.dart';

// Export token management
export 'src/network/core/token/token_manager.dart';
export 'src/network/core/token/default_token_manager.dart';
export 'src/network/core/token/token_config.dart';
export 'src/network/core/token/token_refresh_strategy.dart';
