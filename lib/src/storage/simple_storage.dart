import 'package:flutter_infra/flutter_infra.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SimpleStorage {
  static LocalStorage? _storage;

  /// Initialize storage (call once in main)
  static Future<void> init({
    StorageConfig? config,
    // Optional parameters for testing
    FlutterSecureStorage? secureStorage,
    SharedPreferences? sharedPreferences,
  }) async {
    _storage = await StorageImpl.getInstance(
      config: config,
      secureStorage: secureStorage,
      sharedPreferences: sharedPreferences,
    );
  }

  static LocalStorage get _instance {
    assert(_storage != null, 'Call SimpleStorage.init() first');
    return _storage!;
  }

  // Static methods for simple usage
  static Future<bool> setString(String key, String value) =>
      _instance.setString(key, value);

  static String? getString(String key, {String? defaultValue}) =>
      _instance.getString(key, defaultValue: defaultValue);

  static Future<bool> setBool(String key, bool value) =>
      _instance.setBool(key, value);

  static bool getBool(String key, {bool defaultValue = false}) =>
      _instance.getBool(key, defaultValue: defaultValue);

  static bool hasKey(String key) => _instance.hasKey(key);

  static Future<bool> deleteKey(String key) => _instance.deleteKey(key);

  // Secure storage methods
  static Future<bool> setSecureString(String key, String value) =>
      _instance.setSecureString(key, value);

  static Future<String?> getSecureString(String key, {String? defaultValue}) =>
      _instance.getSecureString(key, defaultValue: defaultValue);

  static Future<bool> setSecureBool(String key, bool value) =>
      _instance.setSecureBool(key, value);

  static Future<bool> getSecureBool(String key, {bool defaultValue = false}) =>
      _instance.getSecureBool(key, defaultValue: defaultValue);

  static Future<bool> hasSecureKey(String key) => _instance.hasSecureKey(key);

  static Future<bool> deleteSecureKey(String key) =>
      _instance.deleteSecureKey(key);

  static Future<bool> clearAll() => _instance.clearAll();

  static Future<bool> clearAllSecure() => _instance.clearAllSecure();
}
