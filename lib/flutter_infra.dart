/// Flutter Infrastructure Package
///
/// A simple and easy-to-use package providing local storage capabilities
/// for Flutter applications.
library;

// Export the LocalStorage interface
export 'src/storage/local_storage.dart';

// Export the main StorageImpl implementation
export 'src/storage/storage_impl.dart';

// Export the SimpleStorage static wrapper for easy usage
export 'src/storage/simple_storage.dart';

// Export the StorageService for dependency injection
export 'src/storage/storage_service.dart';

// Export storage configuration
export 'src/storage/storage_config.dart';

// Export typed storage extensions
export 'src/storage/typed_storage_ext.dart';
