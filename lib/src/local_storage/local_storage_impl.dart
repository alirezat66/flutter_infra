import 'package:flutter_infra/src/local_storage/local_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageImpl implements LocalStorage {
  static StorageImpl? _instance;
  late SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  /// Private constructor with optional dependency injection
  StorageImpl._({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Get the singleton instance of Storage
  static Future<StorageImpl> getInstance({
    FlutterSecureStorage? secureStorage,
    SharedPreferences? sharedPreferences,
  }) async {
    if (_instance == null) {
      _instance = StorageImpl._(secureStorage: secureStorage);
      await _instance!._init(sharedPreferences: sharedPreferences);
    }
    return _instance!;
  }

  /// Initialize the storage with optional dependency injection
  Future<void> _init({SharedPreferences? sharedPreferences}) async {
    _prefs = sharedPreferences ?? await SharedPreferences.getInstance();
  }

  /// Reset singleton instance (for testing purposes)
  static void resetInstance() {
    _instance = null;
  }

  /// Save a string value to standard storage
  @override
  Future<bool> setString(String key, String value) async {
    return _prefs.setString(key, value);
  }

  /// Get a string value from standard storage
  @override
  String? getString(String key, {String? defaultValue}) {
    return _prefs.getString(key) ?? defaultValue;
  }

  /// Save a boolean value to standard storage
  @override
  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  /// Get a boolean value from standard storage
  @override
  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  /// Check if a key exists in standard storage
  @override
  bool hasKey(String key) {
    return _prefs.containsKey(key);
  }

  /// Delete a key from standard storage
  @override
  Future<bool> deleteKey(String key) async {
    return await _prefs.remove(key);
  }

  /// Save a string value to secure storage
  @override
  Future<bool> setSecureString(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Get a string value from secure storage
  @override
  Future<String?> getSecureString(String key, {String? defaultValue}) async {
    try {
      return await _secureStorage.read(key: key) ?? defaultValue;
    } catch (_) {
      return defaultValue;
    }
  }

  /// Save a boolean value to secure storage
  @override
  Future<bool> setSecureBool(String key, bool value) async {
    try {
      await _secureStorage.write(key: key, value: value.toString());
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Get a boolean value from secure storage
  @override
  Future<bool> getSecureBool(String key, {bool defaultValue = false}) async {
    try {
      final value = await _secureStorage.read(key: key);
      if (value == null) return defaultValue;
      return value.toLowerCase() == 'true';
    } catch (_) {
      return defaultValue;
    }
  }

  /// Check if a key exists in secure storage
  @override
  Future<bool> hasSecureKey(String key) async {
    try {
      final value = await _secureStorage.read(key: key);
      return value != null;
    } catch (_) {
      return false;
    }
  }

  /// Delete a key from secure storage
  @override
  Future<bool> deleteSecureKey(String key) async {
    try {
      await _secureStorage.delete(key: key);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Clear all values from standard storage
  Future<bool> clearAll() async {
    return await _prefs.clear();
  }

  /// Clear all values from secure storage
  Future<bool> clearAllSecure() async {
    try {
      await _secureStorage.deleteAll();
      return true;
    } catch (_) {
      return false;
    }
  }
}
