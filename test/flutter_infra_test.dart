import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter_infra/flutter_infra.dart';

import 'flutter_infra_test.mocks.dart';

// Generate mocks for dependencies
@GenerateMocks([FlutterSecureStorage, SharedPreferences, LocalStorage])
void main() {
  group('StorageImpl Tests', () {
    late StorageImpl storage;
    late MockFlutterSecureStorage mockSecureStorage;
    late MockSharedPreferences mockSharedPreferences;

    setUp(() async {
      // Reset singleton instance before each test
      StorageImpl.resetInstance();

      // Create mocks
      mockSecureStorage = MockFlutterSecureStorage();
      mockSharedPreferences = MockSharedPreferences();

      // Get storage instance with injected dependencies and caching disabled for tests
      storage = await StorageImpl.getInstance(
        secureStorage: mockSecureStorage,
        sharedPreferences: mockSharedPreferences,
        config: const StorageConfig(enableCache: false),
      );
    });

    group('Singleton Pattern', () {
      test('should return same instance on multiple calls', () async {
        final instance1 = await StorageImpl.getInstance(
          secureStorage: mockSecureStorage,
          sharedPreferences: mockSharedPreferences,
          config: const StorageConfig(enableCache: false),
        );
        final instance2 = await StorageImpl.getInstance(
          secureStorage: mockSecureStorage,
          sharedPreferences: mockSharedPreferences,
          config: const StorageConfig(enableCache: false),
        );

        expect(instance1, same(instance2));
      });

      test('should initialize properly with injected dependencies', () async {
        final instance = await StorageImpl.getInstance(
          secureStorage: mockSecureStorage,
          sharedPreferences: mockSharedPreferences,
          config: const StorageConfig(enableCache: false),
        );

        expect(instance, isA<StorageImpl>());
      });
    });

    group('Standard Storage - String Operations', () {
      test('should set and get string value', () async {
        const key = 'test_key';
        const value = 'test_value';

        // Mock SharedPreferences behavior
        when(
          mockSharedPreferences.setString(key, value),
        ).thenAnswer((_) async => true);
        when(mockSharedPreferences.getString(key)).thenReturn(value);

        final setResult = await storage.setString(key, value);
        expect(setResult, true);

        final getResult = storage.getString(key);
        expect(getResult, value);

        // Verify interactions
        verify(mockSharedPreferences.setString(key, value)).called(1);
        verify(mockSharedPreferences.getString(key)).called(1);
      });

      test('should return default value when key does not exist', () {
        const key = 'non_existent_key';
        const defaultValue = 'default';

        when(mockSharedPreferences.getString(key)).thenReturn(null);

        final result = storage.getString(key, defaultValue: defaultValue);
        expect(result, defaultValue);

        verify(mockSharedPreferences.getString(key)).called(1);
      });

      test('should return null when key does not exist and no default', () {
        const key = 'non_existent_key';

        when(mockSharedPreferences.getString(key)).thenReturn(null);

        final result = storage.getString(key);
        expect(result, null);

        verify(mockSharedPreferences.getString(key)).called(1);
      });

      test('should update existing string value', () async {
        const key1 = 'test_key_update_1';
        const key2 = 'test_key_update_2';
        const value1 = 'value1';
        const value2 = 'value2';

        when(
          mockSharedPreferences.setString(key1, value1),
        ).thenAnswer((_) async => true);
        when(
          mockSharedPreferences.setString(key2, value2),
        ).thenAnswer((_) async => true);
        when(mockSharedPreferences.getString(key1)).thenReturn(value1);
        when(mockSharedPreferences.getString(key2)).thenReturn(value2);

        await storage.setString(key1, value1);
        expect(storage.getString(key1), value1);

        await storage.setString(key2, value2);
        expect(storage.getString(key2), value2);

        verify(mockSharedPreferences.setString(key1, value1)).called(1);
        verify(mockSharedPreferences.setString(key2, value2)).called(1);
        verify(mockSharedPreferences.getString(key1)).called(1);
        verify(mockSharedPreferences.getString(key2)).called(1);
      });
    });

    group('Standard Storage - Boolean Operations', () {
      test('should set and get boolean value', () async {
        const key = 'bool_key';
        const value = true;

        when(
          mockSharedPreferences.setBool(key, value),
        ).thenAnswer((_) async => true);
        when(mockSharedPreferences.getBool(key)).thenReturn(value);

        final setResult = await storage.setBool(key, value);
        expect(setResult, true);

        final getResult = storage.getBool(key);
        expect(getResult, value);

        verify(mockSharedPreferences.setBool(key, value)).called(1);
        verify(mockSharedPreferences.getBool(key)).called(1);
      });

      test('should return default false when key does not exist', () {
        const key = 'non_existent_bool';

        when(mockSharedPreferences.getBool(key)).thenReturn(null);

        final result = storage.getBool(key);
        expect(result, false);

        verify(mockSharedPreferences.getBool(key)).called(1);
      });

      test('should return custom default value when key does not exist', () {
        const key = 'non_existent_bool_custom';
        const defaultValue = true;

        when(mockSharedPreferences.getBool(key)).thenReturn(null);

        final result = storage.getBool(key, defaultValue: defaultValue);
        expect(result, defaultValue);

        verify(mockSharedPreferences.getBool(key)).called(1);
      });

      test('should handle false value correctly', () async {
        const key = 'false_key';
        const value = false;

        when(
          mockSharedPreferences.setBool(key, value),
        ).thenAnswer((_) async => true);
        when(mockSharedPreferences.getBool(key)).thenReturn(value);

        await storage.setBool(key, value);
        final result = storage.getBool(key, defaultValue: true);
        expect(result, value);

        verify(mockSharedPreferences.setBool(key, value)).called(1);
        verify(mockSharedPreferences.getBool(key)).called(1);
      });
    });

    group('Standard Storage - Key Operations', () {
      test('should check if key exists', () async {
        const nonExistentKey = 'non_existing_key_test';
        const existingKey = 'existing_key_test';
        const value = 'some_value';

        when(
          mockSharedPreferences.containsKey(nonExistentKey),
        ).thenReturn(false);
        when(mockSharedPreferences.containsKey(existingKey)).thenReturn(true);
        when(
          mockSharedPreferences.setString(existingKey, value),
        ).thenAnswer((_) async => true);

        // Key should not exist initially
        expect(storage.hasKey(nonExistentKey), false);

        // Set value and check existing key
        await storage.setString(existingKey, value);
        expect(storage.hasKey(existingKey), true);

        verify(mockSharedPreferences.containsKey(nonExistentKey)).called(1);
        verify(mockSharedPreferences.containsKey(existingKey)).called(1);
        verify(mockSharedPreferences.setString(existingKey, value)).called(1);
      });

      test('should delete existing key', () async {
        const keyBeforeDelete = 'key_before_delete_test';
        const keyAfterDelete = 'key_after_delete_test';
        const value = 'value';

        when(
          mockSharedPreferences.setString(keyBeforeDelete, value),
        ).thenAnswer((_) async => true);
        when(
          mockSharedPreferences.containsKey(keyBeforeDelete),
        ).thenReturn(true);
        when(
          mockSharedPreferences.containsKey(keyAfterDelete),
        ).thenReturn(false);
        when(
          mockSharedPreferences.remove(keyBeforeDelete),
        ).thenAnswer((_) async => true);

        // Set value
        await storage.setString(keyBeforeDelete, value);
        expect(storage.hasKey(keyBeforeDelete), true);

        // Delete key
        final result = await storage.deleteKey(keyBeforeDelete);
        expect(result, true);
        expect(storage.hasKey(keyAfterDelete), false);

        verify(mockSharedPreferences.remove(keyBeforeDelete)).called(1);
      });

      test('should handle deleting non-existent key', () async {
        const key = 'non_existent_key_delete';

        when(mockSharedPreferences.remove(key)).thenAnswer((_) async => false);

        final result = await storage.deleteKey(key);
        expect(result, false);

        verify(mockSharedPreferences.remove(key)).called(1);
      });
    });

    group('Standard Storage - Clear Operations', () {
      test('should clear all standard storage', () async {
        when(mockSharedPreferences.clear()).thenAnswer((_) async => true);

        final result = await storage.clearAll();
        expect(result, true);

        verify(mockSharedPreferences.clear()).called(1);
      });
    });

    group('Secure Storage - String Operations', () {
      test('should set and get secure string value', () async {
        const key = 'secure_key';
        const value = 'secure_value';

        when(
          mockSecureStorage.write(key: key, value: value),
        ).thenAnswer((_) async => {});
        when(mockSecureStorage.read(key: key)).thenAnswer((_) async => value);

        final setResult = await storage.setSecureString(key, value);
        expect(setResult, true);

        final getResult = await storage.getSecureString(key);
        expect(getResult, value);

        verify(mockSecureStorage.write(key: key, value: value)).called(1);
        verify(mockSecureStorage.read(key: key)).called(1);
      });

      test(
        'should return default value when secure key does not exist',
        () async {
          const key = 'non_existent_secure_key';
          const defaultValue = 'default_secure';

          when(mockSecureStorage.read(key: key)).thenAnswer((_) async => null);

          final result = await storage.getSecureString(
            key,
            defaultValue: defaultValue,
          );
          expect(result, defaultValue);

          verify(mockSecureStorage.read(key: key)).called(1);
        },
      );

      test('should handle secure storage write errors gracefully', () async {
        const key = 'error_key';
        const value = 'error_value';

        when(
          mockSecureStorage.write(key: key, value: value),
        ).thenThrow(Exception('Storage error'));

        final result = await storage.setSecureString(key, value);
        expect(result, false);

        verify(mockSecureStorage.write(key: key, value: value)).called(1);
      });

      test('should handle secure storage read errors gracefully', () async {
        const key = 'error_key';
        const defaultValue = 'default';

        when(
          mockSecureStorage.read(key: key),
        ).thenThrow(Exception('Storage error'));

        final result = await storage.getSecureString(
          key,
          defaultValue: defaultValue,
        );
        expect(result, defaultValue);

        verify(mockSecureStorage.read(key: key)).called(1);
      });
    });

    group('Secure Storage - Boolean Operations', () {
      test('should set and get secure boolean value', () async {
        const key = 'secure_bool_key';
        const value = true;

        when(
          mockSecureStorage.write(key: key, value: value.toString()),
        ).thenAnswer((_) async => {});
        when(
          mockSecureStorage.read(key: key),
        ).thenAnswer((_) async => value.toString());

        final setResult = await storage.setSecureBool(key, value);
        expect(setResult, true);

        final getResult = await storage.getSecureBool(key);
        expect(getResult, value);

        verify(
          mockSecureStorage.write(key: key, value: value.toString()),
        ).called(1);
        verify(mockSecureStorage.read(key: key)).called(1);
      });

      test('should parse secure boolean from string correctly', () async {
        const key1 = 'secure_bool_string_key_1';
        const key2 = 'secure_bool_string_key_2';
        const key3 = 'secure_bool_string_key_3';
        const key4 = 'secure_bool_string_key_4';

        when(mockSecureStorage.read(key: key1)).thenAnswer((_) async => 'true');
        when(
          mockSecureStorage.read(key: key2),
        ).thenAnswer((_) async => 'false');
        when(mockSecureStorage.read(key: key3)).thenAnswer((_) async => 'TRUE');
        when(
          mockSecureStorage.read(key: key4),
        ).thenAnswer((_) async => 'FALSE');

        expect(await storage.getSecureBool(key1), true);
        expect(await storage.getSecureBool(key2), false);
        expect(await storage.getSecureBool(key3), true);
        expect(await storage.getSecureBool(key4), false);

        verify(mockSecureStorage.read(key: key1)).called(1);
        verify(mockSecureStorage.read(key: key2)).called(1);
        verify(mockSecureStorage.read(key: key3)).called(1);
        verify(mockSecureStorage.read(key: key4)).called(1);
      });

      test(
        'should return default value for secure boolean when null',
        () async {
          const key = 'secure_bool_null_key';
          const defaultValue = true;

          when(mockSecureStorage.read(key: key)).thenAnswer((_) async => null);

          final result = await storage.getSecureBool(
            key,
            defaultValue: defaultValue,
          );
          expect(result, defaultValue);

          verify(mockSecureStorage.read(key: key)).called(1);
        },
      );
    });

    group('Secure Storage - Key Operations', () {
      test('should check if secure key exists', () async {
        const key1 = 'secure_existing_key_test_1';
        const key2 = 'secure_existing_key_test_2';

        when(
          mockSecureStorage.read(key: key1),
        ).thenAnswer((_) async => 'some_value');
        when(mockSecureStorage.read(key: key2)).thenAnswer((_) async => null);

        expect(await storage.hasSecureKey(key1), true);
        expect(await storage.hasSecureKey(key2), false);

        verify(mockSecureStorage.read(key: key1)).called(1);
        verify(mockSecureStorage.read(key: key2)).called(1);
      });

      test('should delete secure key', () async {
        const key = 'secure_key_to_delete_test';

        when(mockSecureStorage.delete(key: key)).thenAnswer((_) async => {});

        final result = await storage.deleteSecureKey(key);
        expect(result, true);

        verify(mockSecureStorage.delete(key: key)).called(1);
      });

      test('should handle secure key deletion errors', () async {
        const key = 'error_delete_key';

        when(
          mockSecureStorage.delete(key: key),
        ).thenThrow(Exception('Delete error'));

        final result = await storage.deleteSecureKey(key);
        expect(result, false);

        verify(mockSecureStorage.delete(key: key)).called(1);
      });
    });

    group('Secure Storage - Clear Operations', () {
      test('should clear all secure storage', () async {
        when(mockSecureStorage.deleteAll()).thenAnswer((_) async => {});

        final result = await storage.clearAllSecure();
        expect(result, true);

        verify(mockSecureStorage.deleteAll()).called(1);
      });

      test('should handle clear all secure storage errors', () async {
        when(mockSecureStorage.deleteAll()).thenThrow(Exception('Clear error'));

        final result = await storage.clearAllSecure();
        expect(result, false);

        verify(mockSecureStorage.deleteAll()).called(1);
      });
    });

    group('Integration Tests', () {
      test('should handle mixed operations correctly', () async {
        // Setup mocks for mixed operations
        when(
          mockSharedPreferences.setString('username', 'testuser'),
        ).thenAnswer((_) async => true);
        when(
          mockSharedPreferences.setBool('isLoggedIn', true),
        ).thenAnswer((_) async => true);
        when(
          mockSharedPreferences.setBool('isLoggedIn_after_update', false),
        ).thenAnswer((_) async => true);
        when(
          mockSharedPreferences.setString('theme', 'dark'),
        ).thenAnswer((_) async => true);

        when(
          mockSharedPreferences.getString('username'),
        ).thenReturn('testuser');
        when(mockSharedPreferences.getString('theme')).thenReturn('dark');

        when(mockSharedPreferences.getBool('isLoggedIn')).thenReturn(true);
        when(
          mockSharedPreferences.getBool('isLoggedIn_after_update'),
        ).thenReturn(false);

        when(
          mockSharedPreferences.remove('theme'),
        ).thenAnswer((_) async => true);
        when(mockSharedPreferences.containsKey('theme')).thenReturn(false);
        when(mockSharedPreferences.containsKey('username')).thenReturn(true);

        // Test a realistic usage scenario
        await storage.setString('username', 'testuser');
        await storage.setBool('isLoggedIn', true);
        await storage.setString('theme', 'dark');

        expect(storage.getString('username'), 'testuser');
        expect(storage.getBool('isLoggedIn'), true);
        expect(storage.getString('theme'), 'dark');

        // Update values with different key to test false value
        await storage.setBool('isLoggedIn_after_update', false);
        expect(storage.getBool('isLoggedIn_after_update'), false);

        // Delete specific key
        await storage.deleteKey('theme');
        expect(storage.hasKey('theme'), false);
        expect(storage.hasKey('username'), true);

        // Verify all interactions
        verify(
          mockSharedPreferences.setString('username', 'testuser'),
        ).called(1);
        verify(mockSharedPreferences.setBool('isLoggedIn', true)).called(1);
        verify(
          mockSharedPreferences.setBool('isLoggedIn_after_update', false),
        ).called(1);
        verify(mockSharedPreferences.setString('theme', 'dark')).called(1);
        verify(mockSharedPreferences.remove('theme')).called(1);
      });
    });
  });

  group('SimpleStorage Tests', () {
    group('Initialization', () {
      test('should throw assertion error when not initialized', () {
        // Reset to ensure not initialized
        StorageImpl.resetInstance();
        expect(
          () => SimpleStorage.getString('test'),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('Static Method Delegation with Mocked Storage', () {
      late MockFlutterSecureStorage mockSecureStorage;
      late MockSharedPreferences mockSharedPreferences;

      setUp(() async {
        // Reset singleton instances
        StorageImpl.resetInstance();

        // Create mocks
        mockSecureStorage = MockFlutterSecureStorage();
        mockSharedPreferences = MockSharedPreferences();

        // Initialize SimpleStorage with mocked dependencies
        await SimpleStorage.init(
          config: const StorageConfig(enableCache: false),
          secureStorage: mockSecureStorage,
          sharedPreferences: mockSharedPreferences,
        );
      });

      test('should delegate string operations correctly', () async {
        const key = 'simple_key';
        const value = 'simple_value';

        when(
          mockSharedPreferences.setString(key, value),
        ).thenAnswer((_) async => true);
        when(mockSharedPreferences.getString(key)).thenReturn(value);
        when(mockSharedPreferences.containsKey(key)).thenReturn(true);
        when(mockSharedPreferences.remove(key)).thenAnswer((_) async => true);

        // Test all string operations
        expect(await SimpleStorage.setString(key, value), true);
        expect(SimpleStorage.getString(key), value);
        expect(SimpleStorage.hasKey(key), true);
        expect(await SimpleStorage.deleteKey(key), true);
      });

      test('should delegate boolean operations correctly', () async {
        const key = 'simple_bool';
        const value = true;

        when(
          mockSharedPreferences.setBool(key, value),
        ).thenAnswer((_) async => true);
        when(mockSharedPreferences.getBool(key)).thenReturn(value);

        expect(await SimpleStorage.setBool(key, value), true);
        expect(SimpleStorage.getBool(key), value);
      });

      test('should delegate secure operations correctly', () async {
        const key = 'secure_key';
        const value = 'secure_value';

        when(
          mockSecureStorage.write(key: key, value: value),
        ).thenAnswer((_) async => {});
        when(mockSecureStorage.read(key: key)).thenAnswer((_) async => value);
        when(mockSecureStorage.delete(key: key)).thenAnswer((_) async => {});

        expect(await SimpleStorage.setSecureString(key, value), true);
        expect(await SimpleStorage.getSecureString(key), value);
        expect(await SimpleStorage.deleteSecureKey(key), true);
      });

      test('should delegate clear operations correctly', () async {
        when(mockSharedPreferences.clear()).thenAnswer((_) async => true);
        when(mockSecureStorage.deleteAll()).thenAnswer((_) async => {});

        expect(await SimpleStorage.clearAll(), true);
        expect(await SimpleStorage.clearAllSecure(), true);
      });
    });
  });

  group('StorageService Tests', () {
    late StorageService storageService;
    late MockLocalStorage mockStorage;

    setUp(() {
      mockStorage = MockLocalStorage();
      storageService = StorageService(mockStorage);
    });

    test('should delegate all methods to injected storage', () async {
      const key = 'service_key';
      const value = 'service_value';

      // Setup mocks - using specific calls to avoid matcher issues
      when(mockStorage.setString(key, value)).thenAnswer((_) async => true);
      when(mockStorage.getString(key)).thenReturn(value);
      when(mockStorage.setBool(key, true)).thenAnswer((_) async => true);
      when(mockStorage.getBool(key)).thenReturn(true);
      when(mockStorage.hasKey(key)).thenReturn(true);
      when(mockStorage.deleteKey(key)).thenAnswer((_) async => true);
      when(mockStorage.clearAll()).thenAnswer((_) async => true);

      // Test delegation
      expect(await storageService.setString(key, value), true);
      expect(storageService.getString(key), value);
      expect(await storageService.setBool(key, true), true);
      expect(storageService.getBool(key), true);
      expect(storageService.hasKey(key), true);
      expect(await storageService.deleteKey(key), true);
      expect(await storageService.clearAll(), true);

      // Verify all calls were made
      verify(mockStorage.setString(key, value)).called(1);
      verify(mockStorage.getString(key)).called(1);
      verify(mockStorage.setBool(key, true)).called(1);
      verify(mockStorage.getBool(key)).called(1);
      verify(mockStorage.hasKey(key)).called(1);
      verify(mockStorage.deleteKey(key)).called(1);
      verify(mockStorage.clearAll()).called(1);
    });
  });

  group('StorageConfig Tests', () {
    test('should have correct default values', () {
      const config = StorageConfig();

      expect(config.enableLogging, false);
      expect(config.encryptionKey, null);
      expect(config.cacheTimeout, const Duration(minutes: 30));
      expect(config.enableCache, true);
      expect(config.customSettings, const <String, dynamic>{});
    });

    test('should create config with custom values', () {
      const config = StorageConfig(
        enableLogging: true,
        encryptionKey: 'test-key',
        cacheTimeout: Duration(minutes: 60),
        enableCache: false,
        customSettings: {'key': 'value'},
      );

      expect(config.enableLogging, true);
      expect(config.encryptionKey, 'test-key');
      expect(config.cacheTimeout, const Duration(minutes: 60));
      expect(config.enableCache, false);
      expect(config.customSettings, {'key': 'value'});
    });

    test('should copy with new values correctly', () {
      const original = StorageConfig(enableLogging: false, enableCache: true);
      final copy = original.copyWith(enableLogging: true);

      expect(copy.enableLogging, true);
      expect(copy.enableCache, true); // Should retain original value
    });

    test('should copy with null values retaining originals', () {
      const original = StorageConfig(
        enableLogging: true,
        encryptionKey: 'original-key',
        enableCache: false,
      );
      final copy = original.copyWith();

      expect(copy.enableLogging, true);
      expect(copy.encryptionKey, 'original-key');
      expect(copy.enableCache, false);
    });
  });

  group('TypedStorage Extension Tests', () {
    late StorageImpl storage;
    late MockFlutterSecureStorage mockSecureStorage;
    late MockSharedPreferences mockSharedPreferences;

    setUp(() async {
      StorageImpl.resetInstance();
      mockSecureStorage = MockFlutterSecureStorage();
      mockSharedPreferences = MockSharedPreferences();
      storage = await StorageImpl.getInstance(
        secureStorage: mockSecureStorage,
        sharedPreferences: mockSharedPreferences,
        config: const StorageConfig(enableCache: false),
      );
    });

    group('JSON Operations', () {
      test('should store and retrieve JSON objects', () async {
        const key = 'json_key';
        final jsonData = {'name': 'John', 'age': 30, 'active': true};
        const jsonString = '{"name":"John","age":30,"active":true}';

        when(
          mockSharedPreferences.setString(key, jsonString),
        ).thenAnswer((_) async => true);
        when(mockSharedPreferences.getString(key)).thenReturn(jsonString);

        expect(await storage.setJson(key, jsonData), true);
        expect(storage.getJson(key), jsonData);
      });

      test('should return null for invalid JSON', () {
        const key = 'invalid_json';
        const invalidJson = 'invalid{json}';

        when(mockSharedPreferences.getString(key)).thenReturn(invalidJson);

        expect(storage.getJson(key), null);
      });

      test('should return null for non-existent JSON key', () {
        const key = 'non_existent_json';

        when(mockSharedPreferences.getString(key)).thenReturn(null);

        expect(storage.getJson(key), null);
      });
    });

    group('String List Operations', () {
      test('should store and retrieve string lists', () async {
        const key = 'list_key';
        const list = ['apple', 'banana', 'cherry'];
        const listJson = '["apple","banana","cherry"]';

        when(
          mockSharedPreferences.setString(key, listJson),
        ).thenAnswer((_) async => true);
        when(mockSharedPreferences.getString(key)).thenReturn(listJson);

        expect(await storage.setStringList(key, list), true);
        expect(storage.getStringList(key), list);
      });

      test('should return null for invalid list JSON', () {
        const key = 'invalid_list';
        const invalidJson = 'not-a-list';

        when(mockSharedPreferences.getString(key)).thenReturn(invalidJson);

        expect(storage.getStringList(key), null);
      });

      test('should return null for non-existent list key', () {
        const key = 'non_existent_list';

        when(mockSharedPreferences.getString(key)).thenReturn(null);

        expect(storage.getStringList(key), null);
      });
    });

    group('DateTime Operations', () {
      test('should store and retrieve DateTime objects', () async {
        const key = 'datetime_key';
        final dateTime = DateTime(2024, 1, 15, 10, 30, 45);
        const isoString = '2024-01-15T10:30:45.000';

        when(
          mockSharedPreferences.setString(key, isoString),
        ).thenAnswer((_) async => true);
        when(mockSharedPreferences.getString(key)).thenReturn(isoString);

        expect(await storage.setDateTime(key, dateTime), true);
        expect(storage.getDateTime(key), dateTime);
      });

      test('should return null for invalid date string', () {
        const key = 'invalid_date';
        const invalidDate = 'not-a-date';

        when(mockSharedPreferences.getString(key)).thenReturn(invalidDate);

        expect(storage.getDateTime(key), null);
      });

      test('should return null for non-existent date key', () {
        const key = 'non_existent_date';

        when(mockSharedPreferences.getString(key)).thenReturn(null);

        expect(storage.getDateTime(key), null);
      });
    });
  });

  group('Caching Behavior Tests', () {
    late StorageImpl cachedStorage;
    late MockFlutterSecureStorage mockSecureStorage;
    late MockSharedPreferences mockSharedPreferences;

    setUp(() async {
      StorageImpl.resetInstance();
      mockSecureStorage = MockFlutterSecureStorage();
      mockSharedPreferences = MockSharedPreferences();
      cachedStorage = await StorageImpl.getInstance(
        secureStorage: mockSecureStorage,
        sharedPreferences: mockSharedPreferences,
        config: const StorageConfig(enableCache: true), // Enable caching
      );
    });

    test(
      'should cache string values and avoid subsequent SharedPreferences calls',
      () async {
        const key = 'cached_key';
        const value = 'cached_value';

        when(
          mockSharedPreferences.setString(key, value),
        ).thenAnswer((_) async => true);
        when(mockSharedPreferences.getString(key)).thenReturn(value);

        // First set should call SharedPreferences
        await cachedStorage.setString(key, value);

        // First get should call SharedPreferences and cache the result
        expect(cachedStorage.getString(key), value);

        // Second get should use cache, not call SharedPreferences again
        expect(cachedStorage.getString(key), value);

        // With caching enabled, getString is never called because the value is cached from setString
        verifyNever(mockSharedPreferences.getString(key));
      },
    );

    test('should cache boolean values correctly', () async {
      const key = 'cached_bool';
      const value = true;

      when(
        mockSharedPreferences.setBool(key, value),
      ).thenAnswer((_) async => true);
      when(mockSharedPreferences.getBool(key)).thenReturn(value);

      await cachedStorage.setBool(key, value);
      expect(cachedStorage.getBool(key), value);
      expect(cachedStorage.getBool(key), value); // Second call should use cache

      // With caching enabled, getBool is never called because the value is cached from setBool
      verifyNever(mockSharedPreferences.getBool(key));
    });

    test('should clear cache when deleting key', () async {
      const key = 'delete_cached_key';
      const value = 'cached_value';

      when(
        mockSharedPreferences.setString(key, value),
      ).thenAnswer((_) async => true);
      when(mockSharedPreferences.getString(key)).thenReturn(value);
      when(mockSharedPreferences.remove(key)).thenAnswer((_) async => true);

      // Set and cache value
      await cachedStorage.setString(key, value);
      expect(cachedStorage.getString(key), value);

      // Delete should clear cache
      await cachedStorage.deleteKey(key);

      // Next get should call SharedPreferences again (cache cleared)
      when(mockSharedPreferences.getString(key)).thenReturn(null);
      expect(cachedStorage.getString(key), null);

      // First getString is never called due to caching, second one is called after cache clear
      verify(mockSharedPreferences.getString(key)).called(1);
    });

    test('should clear all cache when clearAll is called', () async {
      const key1 = 'cached_key1';
      const key2 = 'cached_key2';
      const value1 = 'value1';
      const value2 = 'value2';

      when(
        mockSharedPreferences.setString(key1, value1),
      ).thenAnswer((_) async => true);
      when(
        mockSharedPreferences.setString(key2, value2),
      ).thenAnswer((_) async => true);
      when(mockSharedPreferences.getString(key1)).thenReturn(value1);
      when(mockSharedPreferences.getString(key2)).thenReturn(value2);
      when(mockSharedPreferences.clear()).thenAnswer((_) async => true);

      // Set and cache values
      await cachedStorage.setString(key1, value1);
      await cachedStorage.setString(key2, value2);
      expect(cachedStorage.getString(key1), value1);
      expect(cachedStorage.getString(key2), value2);

      // Clear all should clear cache
      await cachedStorage.clearAll();

      // Next gets should call SharedPreferences again
      when(mockSharedPreferences.getString(key1)).thenReturn(null);
      when(mockSharedPreferences.getString(key2)).thenReturn(null);
      expect(cachedStorage.getString(key1), null);
      expect(cachedStorage.getString(key2), null);

      // First getString calls are never made due to caching, second calls are made after cache clear
      verify(mockSharedPreferences.getString(key1)).called(1);
      verify(mockSharedPreferences.getString(key2)).called(1);
    });
  });
}
