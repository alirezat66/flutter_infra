import 'package:flutter_infra/flutter_infra.dart';

class StorageService {
  final LocalStorage _normalStorage;
  final LocalStorage _secureStorage;

  StorageService({LocalStorage? normalStorage, LocalStorage? secureStorage})
    : _normalStorage = normalStorage ?? _getDefaultNormalStorage(),
      _secureStorage = secureStorage ?? _getDefaultSecureStorage();

  static LocalStorage _getDefaultNormalStorage() {
    // This will be replaced with actual default when implementations are ready
    throw UnimplementedError('Default normal storage not yet implemented');
  }

  static LocalStorage _getDefaultSecureStorage() {
    // This will be replaced with actual default when implementations are ready
    throw UnimplementedError('Default secure storage not yet implemented');
  }

  // Factory method for easy creation with defaults
  static Future<StorageService> create({
    LocalStorage? normalStorage,
    LocalStorage? secureStorage,
    StorageConfig? config,
  }) async {
    final defaultNormal =
        normalStorage ??
        await PreferencesStorageImpl.getInstance(config: config);
    final defaultSecure =
        secureStorage ?? SecureStorageImpl.getInstance(config: config);

    return StorageService(
      normalStorage: defaultNormal,
      secureStorage: defaultSecure,
    );
  }

  // Normal storage methods
  Future<bool> setString(String key, String value) =>
      _normalStorage.setString(key, value);

  Future<String?> getString(String key, {String? defaultValue}) =>
      _normalStorage.getString(key, defaultValue: defaultValue);

  Future<bool> setBool(String key, bool value) =>
      _normalStorage.setBool(key, value);

  Future<bool> getBool(String key, {bool defaultValue = false}) =>
      _normalStorage.getBool(key, defaultValue: defaultValue);

  Future<bool> hasKey(String key) => _normalStorage.hasKey(key);

  Future<bool> deleteKey(String key) => _normalStorage.deleteKey(key);

  Future<bool> clearAll() => _normalStorage.clearAll();

  // Secure storage methods
  Future<bool> setSecureString(String key, String value) =>
      _secureStorage.setString(key, value);

  Future<String?> getSecureString(String key, {String? defaultValue}) =>
      _secureStorage.getString(key, defaultValue: defaultValue);

  Future<bool> setSecureBool(String key, bool value) =>
      _secureStorage.setBool(key, value);

  Future<bool> getSecureBool(String key, {bool defaultValue = false}) =>
      _secureStorage.getBool(key, defaultValue: defaultValue);

  Future<bool> hasSecureKey(String key) => _secureStorage.hasKey(key);

  Future<bool> deleteSecureKey(String key) => _secureStorage.deleteKey(key);

  Future<bool> clearAllSecure() => _secureStorage.clearAll();
}
