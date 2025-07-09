import 'package:flutter_infra/flutter_infra.dart';

class StorageService {
  final LocalStorage _storage;

  StorageService(this._storage);

  // Delegate all methods to the injected storage
  Future<bool> setString(String key, String value) =>
      _storage.setString(key, value);

  String? getString(String key, {String? defaultValue}) =>
      _storage.getString(key, defaultValue: defaultValue);

  Future<bool> setBool(String key, bool value) => _storage.setBool(key, value);

  bool getBool(String key, {bool defaultValue = false}) =>
      _storage.getBool(key, defaultValue: defaultValue);

  bool hasKey(String key) => _storage.hasKey(key);

  Future<bool> deleteKey(String key) => _storage.deleteKey(key);

  Future<bool> setSecureString(String key, String value) =>
      _storage.setSecureString(key, value);

  Future<String?> getSecureString(String key, {String? defaultValue}) =>
      _storage.getSecureString(key, defaultValue: defaultValue);

  Future<bool> setSecureBool(String key, bool value) =>
      _storage.setSecureBool(key, value);

  Future<bool> getSecureBool(String key, {bool defaultValue = false}) =>
      _storage.getSecureBool(key, defaultValue: defaultValue);

  Future<bool> hasSecureKey(String key) => _storage.hasSecureKey(key);

  Future<bool> deleteSecureKey(String key) => _storage.deleteSecureKey(key);

  Future<bool> clearAll() => _storage.clearAll();

  Future<bool> clearAllSecure() => _storage.clearAllSecure();
}
