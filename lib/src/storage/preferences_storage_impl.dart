import 'package:flutter/foundation.dart';
import 'package:flutter_infra/flutter_infra.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesStorageImpl implements LocalStorage {
  late SharedPreferences _prefs;
  final StorageConfig _config;
  final Map<String, dynamic> _cache = {};

  PreferencesStorageImpl._({StorageConfig? config})
    : _config = config ?? const StorageConfig();

  static Future<PreferencesStorageImpl> getInstance({
    SharedPreferences? sharedPreferences,
    StorageConfig? config,
  }) async {
    final instance = PreferencesStorageImpl._(config: config);
    await instance._init(sharedPreferences: sharedPreferences);
    return instance;
  }

  Future<void> _init({SharedPreferences? sharedPreferences}) async {
    _prefs = sharedPreferences ?? await SharedPreferences.getInstance();
  }

  void _log(String message) {
    if (_config.enableLogging) {
      debugPrint('[PreferencesStorage] $message');
    }
  }

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
  Future<String?> getString(String key, {String? defaultValue}) async {
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
  Future<bool> getBool(String key, {bool defaultValue = false}) async {
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
  Future<bool> hasKey(String key) async => _prefs.containsKey(key);

  @override
  Future<bool> deleteKey(String key) async {
    _cache.remove(key);
    return await _prefs.remove(key);
  }

  @override
  Future<bool> clearAll() async {
    _cache.clear();
    return await _prefs.clear();
  }
}
