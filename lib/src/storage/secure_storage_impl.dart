import 'package:flutter/foundation.dart';
import 'package:flutter_infra/flutter_infra.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageImpl implements LocalStorage {
  final FlutterSecureStorage _secureStorage;
  final StorageConfig _config;

  SecureStorageImpl._({
    FlutterSecureStorage? secureStorage,
    StorageConfig? config,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
       _config = config ?? const StorageConfig();

  static SecureStorageImpl getInstance({
    FlutterSecureStorage? secureStorage,
    StorageConfig? config,
  }) {
    return SecureStorageImpl._(secureStorage: secureStorage, config: config);
  }

  void _log(String message) {
    if (_config.enableLogging) {
      debugPrint('[SecureStorage] $message');
    }
  }

  @override
  Future<bool> setString(String key, String value) async {
    try {
      _log('Setting secure string key: $key');
      await _secureStorage.write(key: key, value: value);
      return true;
    } catch (e) {
      _log('Error setting secure string: $e');
      return false;
    }
  }

  @override
  Future<String?> getString(String key, {String? defaultValue}) async {
    try {
      final value = await _secureStorage.read(key: key);
      return value ?? defaultValue;
    } catch (e) {
      _log('Error getting secure string: $e');
      return defaultValue;
    }
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    try {
      _log('Setting secure bool key: $key');
      await _secureStorage.write(key: key, value: value.toString());
      return true;
    } catch (e) {
      _log('Error setting secure bool: $e');
      return false;
    }
  }

  @override
  Future<bool> getBool(String key, {bool defaultValue = false}) async {
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
  Future<bool> hasKey(String key) async {
    try {
      final value = await _secureStorage.read(key: key);
      return value != null;
    } catch (e) {
      _log('Error checking secure key: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteKey(String key) async {
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
    try {
      await _secureStorage.deleteAll();
      return true;
    } catch (e) {
      _log('Error clearing secure storage: $e');
      return false;
    }
  }
}
