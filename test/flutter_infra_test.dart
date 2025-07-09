import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter_infra/flutter_infra.dart';
import 'package:flutter_infra/src/local_storage/local_storage_impl.dart';

import 'flutter_infra_test.mocks.dart';

// Generate mocks for both dependencies
@GenerateMocks([FlutterSecureStorage, SharedPreferences])
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

      // Get storage instance with injected dependencies
      storage = await StorageImpl.getInstance(
        secureStorage: mockSecureStorage,
        sharedPreferences: mockSharedPreferences,
      );
    });

    group('Singleton Pattern', () {
      test('should return same instance on multiple calls', () async {
        final instance1 = await StorageImpl.getInstance(
          secureStorage: mockSecureStorage,
          sharedPreferences: mockSharedPreferences,
        );
        final instance2 = await StorageImpl.getInstance(
          secureStorage: mockSecureStorage,
          sharedPreferences: mockSharedPreferences,
        );

        expect(instance1, same(instance2));
      });

      test('should initialize properly with injected dependencies', () async {
        final instance = await StorageImpl.getInstance(
          secureStorage: mockSecureStorage,
          sharedPreferences: mockSharedPreferences,
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
}
