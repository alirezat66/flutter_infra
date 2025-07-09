abstract class LocalStorage {
  Future<bool> deleteKey(String key);
  Future<bool> deleteSecureKey(String key);
  String? getString(String key, {String? defaultValue});
  Future<String?> getSecureString(String key, {String? defaultValue});
  bool hasKey(String key);
  Future<bool> hasSecureKey(String key);
  Future<bool> setBool(String key, bool value);
  Future<bool> setSecureBool(String key, bool value);
  Future<bool> setString(String key, String value);
  Future<bool> setSecureString(String key, String value);
  bool getBool(String key, {bool defaultValue});
  Future<bool> getSecureBool(String key, {bool defaultValue});
}
