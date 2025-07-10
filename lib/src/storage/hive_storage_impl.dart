import 'package:flutter/foundation.dart';
import 'package:flutter_infra/flutter_infra.dart';
import 'package:hive/hive.dart';

class HiveStorageImpl implements LocalStorage {
  late Box _box;
  final StorageConfig _config;
  final String _boxName;
  final String? _encryptionKey;

  HiveStorageImpl._({
    required String boxName,
    String? encryptionKey,
    StorageConfig? config,
  }) : _boxName = boxName,
       _encryptionKey = encryptionKey,
       _config = config ?? const StorageConfig();

  static Future<HiveStorageImpl> getInstance({
    String boxName = 'default',
    String? encryptionKey,
    StorageConfig? config,
  }) async {
    final instance = HiveStorageImpl._(
      boxName: boxName,
      encryptionKey: encryptionKey,
      config: config,
    );
    await instance._init();
    return instance;
  }

  Future<void> _init() async {
    try {
      // Initialize Hive if not already done
      if (!Hive.isBoxOpen(_boxName)) {
        List<int>? encryptionKeyBytes;

        if (_encryptionKey != null) {
          // Convert string key to bytes for encryption
          encryptionKeyBytes = _encryptionKey.codeUnits;
          // Ensure key is exactly 32 bytes for AES-256
          if (encryptionKeyBytes.length < 32) {
            encryptionKeyBytes = List.from(encryptionKeyBytes)
              ..addAll(List.filled(32 - encryptionKeyBytes.length, 0));
          } else if (encryptionKeyBytes.length > 32) {
            encryptionKeyBytes = encryptionKeyBytes.take(32).toList();
          }
        }

        _box = await Hive.openBox(
          _boxName,
          encryptionCipher:
              encryptionKeyBytes != null
                  ? HiveAesCipher(encryptionKeyBytes)
                  : null,
        );
      } else {
        _box = Hive.box(_boxName);
      }
    } catch (e) {
      _log('Error initializing Hive box: $e');
      rethrow;
    }
  }

  void _log(String message) {
    if (_config.enableLogging) {
      final prefix =
          _encryptionKey != null ? '[HiveSecureStorage]' : '[HiveStorage]';
      debugPrint('$prefix $message');
    }
  }

  @override
  Future<bool> setString(String key, String value) async {
    try {
      _log('Setting string key: $key');
      await _box.put(key, value);
      return true;
    } catch (e) {
      _log('Error setting string: $e');
      return false;
    }
  }

  @override
  Future<String?> getString(String key, {String? defaultValue}) async {
    try {
      final value = _box.get(key, defaultValue: defaultValue);
      return value as String?;
    } catch (e) {
      _log('Error getting string: $e');
      return defaultValue;
    }
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    try {
      _log('Setting bool key: $key');
      await _box.put(key, value);
      return true;
    } catch (e) {
      _log('Error setting bool: $e');
      return false;
    }
  }

  @override
  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    try {
      final value = _box.get(key, defaultValue: defaultValue);
      return value as bool;
    } catch (e) {
      _log('Error getting bool: $e');
      return defaultValue;
    }
  }

  @override
  Future<bool> hasKey(String key) async {
    try {
      return _box.containsKey(key);
    } catch (e) {
      _log('Error checking key: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteKey(String key) async {
    try {
      await _box.delete(key);
      return true;
    } catch (e) {
      _log('Error deleting key: $e');
      return false;
    }
  }

  @override
  Future<bool> clearAll() async {
    try {
      await _box.clear();
      return true;
    } catch (e) {
      _log('Error clearing storage: $e');
      return false;
    }
  }

  /// Close the Hive box (useful for cleanup)
  Future<void> close() async {
    try {
      await _box.close();
    } catch (e) {
      _log('Error closing box: $e');
    }
  }
}
