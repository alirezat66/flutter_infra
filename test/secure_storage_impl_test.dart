import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter_infra/flutter_infra.dart';

import 'secure_storage_impl_test.mocks.dart';

// Generate mocks for dependencies
@GenerateMocks([FlutterSecureStorage])
void main() {
  group('SecureStorageImpl Tests', () {
    late SecureStorageImpl storage;
    late MockFlutterSecureStorage mockSecureStorage;

    setUp(() {
      mockSecureStorage = MockFlutterSecureStorage();
      storage = SecureStorageImpl.getInstance(
        secureStorage: mockSecureStorage,
        config: const StorageConfig(enableLogging: false),
      );
    });

    group('String Operations', () {
      test('should set and get secure string value', () async {
        const key = 'secure_key';
        const value = 'secure_value';

        when(
          mockSecureStorage.write(key: key, value: value),
        ).thenAnswer((_) async => {});
        when(mockSecureStorage.read(key: key)).thenAnswer((_) async => value);

        final setResult = await storage.setString(key, value);
        expect(setResult, true);

        final getResult = await storage.getString(key);
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

          final result = await storage.getString(
            key,
            defaultValue: defaultValue,
          );
          expect(result, defaultValue);

          verify(mockSecureStorage.read(key: key)).called(1);
        },
      );

      test('should handle errors gracefully', () async {
        const key = 'error_key';
        const value = 'error_value';

        when(
          mockSecureStorage.write(key: key, value: value),
        ).thenThrow(Exception('Storage error'));

        final result = await storage.setString(key, value);
        expect(result, false);

        verify(mockSecureStorage.write(key: key, value: value)).called(1);
      });

      test('should handle read errors gracefully', () async {
        const key = 'error_key';
        const defaultValue = 'default';

        when(
          mockSecureStorage.read(key: key),
        ).thenThrow(Exception('Storage error'));

        final result = await storage.getString(key, defaultValue: defaultValue);
        expect(result, defaultValue);

        verify(mockSecureStorage.read(key: key)).called(1);
      });
    });

    group('Boolean Operations', () {
      test('should set and get secure boolean value', () async {
        const key = 'secure_bool_key';
        const value = true;

        when(
          mockSecureStorage.write(key: key, value: value.toString()),
        ).thenAnswer((_) async => {});
        when(
          mockSecureStorage.read(key: key),
        ).thenAnswer((_) async => value.toString());

        final setResult = await storage.setBool(key, value);
        expect(setResult, true);

        final getResult = await storage.getBool(key);
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

        expect(await storage.getBool(key1), true);
        expect(await storage.getBool(key2), false);
        expect(await storage.getBool(key3), true);
        expect(await storage.getBool(key4), false);

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

          final result = await storage.getBool(key, defaultValue: defaultValue);
          expect(result, defaultValue);

          verify(mockSecureStorage.read(key: key)).called(1);
        },
      );

      test('should handle secure boolean write errors', () async {
        const key = 'error_bool_key';
        const value = true;

        when(
          mockSecureStorage.write(key: key, value: value.toString()),
        ).thenThrow(Exception('Storage error'));

        final result = await storage.setBool(key, value);
        expect(result, false);

        verify(
          mockSecureStorage.write(key: key, value: value.toString()),
        ).called(1);
      });
    });

    group('Key Operations', () {
      test('should check if secure key exists', () async {
        const key = 'secure_existing_key';

        when(
          mockSecureStorage.read(key: key),
        ).thenAnswer((_) async => 'some_value');

        final exists = await storage.hasKey(key);
        expect(exists, true);

        verify(mockSecureStorage.read(key: key)).called(1);
      });

      test('should check if secure key does not exist', () async {
        const key = 'secure_non_existing_key';

        when(mockSecureStorage.read(key: key)).thenAnswer((_) async => null);

        final exists = await storage.hasKey(key);
        expect(exists, false);

        verify(mockSecureStorage.read(key: key)).called(1);
      });

      test('should handle hasKey errors gracefully', () async {
        const key = 'error_key';

        when(
          mockSecureStorage.read(key: key),
        ).thenThrow(Exception('Storage error'));

        final exists = await storage.hasKey(key);
        expect(exists, false);

        verify(mockSecureStorage.read(key: key)).called(1);
      });

      test('should delete secure key', () async {
        const key = 'secure_key_to_delete';

        when(mockSecureStorage.delete(key: key)).thenAnswer((_) async => {});

        final result = await storage.deleteKey(key);
        expect(result, true);

        verify(mockSecureStorage.delete(key: key)).called(1);
      });

      test('should handle secure key deletion errors', () async {
        const key = 'error_delete_key';

        when(
          mockSecureStorage.delete(key: key),
        ).thenThrow(Exception('Delete error'));

        final result = await storage.deleteKey(key);
        expect(result, false);

        verify(mockSecureStorage.delete(key: key)).called(1);
      });

      test('should clear all secure storage', () async {
        when(mockSecureStorage.deleteAll()).thenAnswer((_) async => {});

        final result = await storage.clearAll();
        expect(result, true);

        verify(mockSecureStorage.deleteAll()).called(1);
      });

      test('should handle clear all secure storage errors', () async {
        when(mockSecureStorage.deleteAll()).thenThrow(Exception('Clear error'));

        final result = await storage.clearAll();
        expect(result, false);

        verify(mockSecureStorage.deleteAll()).called(1);
      });
    });

    group('Error Handling', () {
      test('should handle all operations gracefully on errors', () async {
        const key = 'error_key';
        const value = 'error_value';

        // Setup all operations to throw errors
        when(
          mockSecureStorage.write(key: key, value: anyNamed('value')),
        ).thenThrow(Exception('Write error'));
        when(
          mockSecureStorage.read(key: key),
        ).thenThrow(Exception('Read error'));
        when(
          mockSecureStorage.delete(key: key),
        ).thenThrow(Exception('Delete error'));
        when(mockSecureStorage.deleteAll()).thenThrow(Exception('Clear error'));

        // All operations should return sensible defaults without throwing
        expect(await storage.setString(key, value), false);
        expect(await storage.getString(key), null);
        expect(await storage.setBool(key, true), false);
        expect(await storage.getBool(key), false);
        expect(await storage.hasKey(key), false);
        expect(await storage.deleteKey(key), false);
        expect(await storage.clearAll(), false);
      });
    });
  });
}
