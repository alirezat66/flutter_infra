import 'package:flutter/foundation.dart';
import 'package:flutter_infra/flutter_infra.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageImpl implements LocalStorage {
  static StorageImpl? _instance;
  late SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;
  final StorageConfig _config;
  final Map<String, dynamic> _cache = {};

  StorageImpl._({FlutterSecureStorage? secureStorage, StorageConfig? config})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
      _config = config ?? const StorageConfig();

  static Future<StorageImpl> getInstance({
    FlutterSecureStorage? secureStorage,
    SharedPreferences? sharedPreferences,
    StorageConfig? config,
  }) async {
    if (_instance == null) {
      _instance = StorageImpl._(secureStorage: secureStorage, config: config);
      await _instance!._init(sharedPreferences: sharedPreferences);
    }
    return _instance!;
  }

  Future<void> _init({SharedPreferences? sharedPreferences}) async {
    _prefs = sharedPreferences ?? await SharedPreferences.getInstance();
  }

  static void resetInstance() {
    _instance = null;
  }

  void _log(String message) {
    if (_config.enableLogging) {
      debugPrint('[Storage] $message');
    }
  }

  // Standard storage methods with caching
  @override
  Future<bool> setString(String key, String value) async {
    _log('Setting string key: $key');
    final result = await _prefs.setString(key, value);
    if (result && _config.enableCache) {
      _cache[key] = value;
    }
    return result;
  }

  @override
  String? getString(String key, {String? defaultValue}) {
    if (_config.enableCache && _cache.containsKey(key)) {
      return _cache[key] as String?;
    }
    final value = _prefs.getString(key) ?? defaultValue;
    if (value != null && _config.enableCache) {
      _cache[key] = value;
    }
    return value;
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    _log('Setting bool key: $key');
    final result = await _prefs.setBool(key, value);
    if (result && _config.enableCache) {
      _cache[key] = value;
    }
    return result;
  }

  @override
  bool getBool(String key, {bool defaultValue = false}) {
    if (_config.enableCache && _cache.containsKey(key)) {
      return _cache[key] as bool;
    }
    final value = _prefs.getBool(key) ?? defaultValue;
    if (_config.enableCache) {
      _cache[key] = value;
    }
    return value;
  }

  @override
  bool hasKey(String key) => _prefs.containsKey(key);

  @override
  Future<bool> deleteKey(String key) async {
    _cache.remove(key);
    return await _prefs.remove(key);
  }

  // Secure storage methods
  @override
  Future<bool> setSecureString(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
      return true;
    } catch (e) {
      _log('Error setting secure string: $e');
      return false;
    }
  }

  @override
  Future<String?> getSecureString(String key, {String? defaultValue}) async {
    try {
      return await _secureStorage.read(key: key) ?? defaultValue;
    } catch (e) {
      _log('Error getting secure string: $e');
      return defaultValue;
    }
  }

  @override
  Future<bool> setSecureBool(String key, bool value) async {
    try {
      await _secureStorage.write(key: key, value: value.toString());
      return true;
    } catch (e) {
      _log('Error setting secure bool: $e');
      return false;
    }
  }

  @override
  Future<bool> getSecureBool(String key, {bool defaultValue = false}) async {
    try {
      final value = await _secureStorage.read(key: key);
      if (value == null) return defaultValue;
      return value.toLowerCase() == 'true';
    } catch (e) {
      _log('Error getting secure bool: $e');
      return defaultValue;
    }
  }

  @override
  Future<bool> hasSecureKey(String key) async {
    try {
      final value = await _secureStorage.read(key: key);
      return value != null;
    } catch (e) {
      _log('Error checking secure key: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteSecureKey(String key) async {
    try {
      await _secureStorage.delete(key: key);
      return true;
    } catch (e) {
      _log('Error deleting secure key: $e');
      return false;
    }
  }

  @override
  Future<bool> clearAll() async {
    _cache.clear();
    return await _prefs.clear();
  }

  @override
  Future<bool> clearAllSecure() async {
    try {
      await _secureStorage.deleteAll();
      return true;
    } catch (e) {
      _log('Error clearing secure storage: $e');
      return false;
    }
  }
}
