abstract class LocalStorage {
  Future<bool> setString(String key, String value);
  Future<String?> getString(String key, {String? defaultValue});
  Future<bool> setBool(String key, bool value);
  Future<bool> getBool(String key, {bool defaultValue = false});
  Future<bool> hasKey(String key);
  Future<bool> deleteKey(String key);
  Future<bool> clearAll();
}
