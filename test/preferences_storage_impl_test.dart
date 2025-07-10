import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:flutter_infra/flutter_infra.dart';

import 'preferences_storage_impl_test.mocks.dart';

// Generate mocks for dependencies
@GenerateMocks([SharedPreferences])
void main() {
  group('PreferencesStorageImpl Tests', () {
    late PreferencesStorageImpl storage;
    late MockSharedPreferences mockSharedPreferences;

    setUp(() async {
      mockSharedPreferences = MockSharedPreferences();
      storage = await PreferencesStorageImpl.getInstance(
        sharedPreferences: mockSharedPreferences,
        config: const StorageConfig(enableCache: false),
      );
    });

    group('String Operations', () {
      test('should set and get string value', () async {
        const key = 'test_key';
        const value = 'test_value';

        when(
          mockSharedPreferences.setString(key, value),
        ).thenAnswer((_) async => true);
        when(mockSharedPreferences.getString(key)).thenReturn(value);

        final setResult = await storage.setString(key, value);
        expect(setResult, true);

        final getResult = await storage.getString(key);
        expect(getResult, value);

        verify(mockSharedPreferences.setString(key, value)).called(1);
        verify(mockSharedPreferences.getString(key)).called(1);
      });

      test('should return default value when key does not exist', () async {
        const key = 'non_existent_key';
        const defaultValue = 'default';

        when(mockSharedPreferences.getString(key)).thenReturn(null);

        final result = await storage.getString(key, defaultValue: defaultValue);
        expect(result, defaultValue);

        verify(mockSharedPreferences.getString(key)).called(1);
      });

      test(
        'should return null when key does not exist and no default',
        () async {
          const key = 'non_existent_key';

          when(mockSharedPreferences.getString(key)).thenReturn(null);

          final result = await storage.getString(key);
          expect(result, null);

          verify(mockSharedPreferences.getString(key)).called(1);
        },
      );
    });

    group('Boolean Operations', () {
      test('should set and get boolean value', () async {
        const key = 'bool_key';
        const value = true;

        when(
          mockSharedPreferences.setBool(key, value),
        ).thenAnswer((_) async => true);
        when(mockSharedPreferences.getBool(key)).thenReturn(value);

        final setResult = await storage.setBool(key, value);
        expect(setResult, true);

        final getResult = await storage.getBool(key);
        expect(getResult, value);

        verify(mockSharedPreferences.setBool(key, value)).called(1);
        verify(mockSharedPreferences.getBool(key)).called(1);
      });

      test('should return default value for non-existent boolean', () async {
        const key = 'non_existent_bool';
        const defaultValue = true;

        when(mockSharedPreferences.getBool(key)).thenReturn(null);

        final result = await storage.getBool(key, defaultValue: defaultValue);
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

        final setResult = await storage.setBool(key, value);
        expect(setResult, true);

        final getResult = await storage.getBool(key, defaultValue: true);
        expect(getResult, value);

        verify(mockSharedPreferences.setBool(key, value)).called(1);
        verify(mockSharedPreferences.getBool(key)).called(1);
      });
    });

    group('Key Operations', () {
      test('should check if key exists', () async {
        const key = 'existing_key';

        when(mockSharedPreferences.containsKey(key)).thenReturn(true);

        final exists = await storage.hasKey(key);
        expect(exists, true);

        verify(mockSharedPreferences.containsKey(key)).called(1);
      });

      test('should check if key does not exist', () async {
        const key = 'non_existing_key';

        when(mockSharedPreferences.containsKey(key)).thenReturn(false);

        final exists = await storage.hasKey(key);
        expect(exists, false);

        verify(mockSharedPreferences.containsKey(key)).called(1);
      });

      test('should delete key', () async {
        const key = 'key_to_delete';

        when(mockSharedPreferences.remove(key)).thenAnswer((_) async => true);

        final result = await storage.deleteKey(key);
        expect(result, true);

        verify(mockSharedPreferences.remove(key)).called(1);
      });

      test('should handle delete key failure', () async {
        const key = 'key_to_delete';

        when(mockSharedPreferences.remove(key)).thenAnswer((_) async => false);

        final result = await storage.deleteKey(key);
        expect(result, false);

        verify(mockSharedPreferences.remove(key)).called(1);
      });

      test('should clear all data', () async {
        when(mockSharedPreferences.clear()).thenAnswer((_) async => true);

        final result = await storage.clearAll();
        expect(result, true);

        verify(mockSharedPreferences.clear()).called(1);
      });

      test('should handle clear all failure', () async {
        when(mockSharedPreferences.clear()).thenAnswer((_) async => false);

        final result = await storage.clearAll();
        expect(result, false);

        verify(mockSharedPreferences.clear()).called(1);
      });
    });

    group('Caching Behavior', () {
      late PreferencesStorageImpl cachedStorage;

      setUp(() async {
        cachedStorage = await PreferencesStorageImpl.getInstance(
          sharedPreferences: mockSharedPreferences,
          config: const StorageConfig(enableCache: true), // Enable caching
        );
      });

      test('should cache string values and avoid subsequent calls', () async {
        const key = 'cached_key';
        const value = 'cached_value';

        when(
          mockSharedPreferences.setString(key, value),
        ).thenAnswer((_) async => true);
        when(mockSharedPreferences.getString(key)).thenReturn(value);

        // First set should call SharedPreferences and cache the value
        await cachedStorage.setString(key, value);

        // First get should use cache, not call SharedPreferences
        final result1 = await cachedStorage.getString(key);
        expect(result1, value);

        // Second get should also use cache
        final result2 = await cachedStorage.getString(key);
        expect(result2, value);

        // Verify SharedPreferences.getString was never called due to caching
        verifyNever(mockSharedPreferences.getString(key));
        verify(mockSharedPreferences.setString(key, value)).called(1);
      });

      test('should clear cache when deleting key', () async {
        const key = 'delete_cached_key';
        const value = 'cached_value';

        when(
          mockSharedPreferences.setString(key, value),
        ).thenAnswer((_) async => true);
        when(mockSharedPreferences.remove(key)).thenAnswer((_) async => true);

        // Set and cache value
        await cachedStorage.setString(key, value);
        final result1 = await cachedStorage.getString(key);
        expect(result1, value);

        // Delete should clear cache
        await cachedStorage.deleteKey(key);

        // Next get should call SharedPreferences again (cache cleared)
        when(mockSharedPreferences.getString(key)).thenReturn(null);
        final result2 = await cachedStorage.getString(key);
        expect(result2, null);

        verify(mockSharedPreferences.getString(key)).called(1);
        verify(mockSharedPreferences.remove(key)).called(1);
      });
    });
  });
}
