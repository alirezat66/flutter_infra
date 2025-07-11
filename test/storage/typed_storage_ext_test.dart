import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:flutter_infra/flutter_infra.dart';

import 'typed_storage_ext_test.mocks.dart';

// Generate mocks for dependencies
@GenerateMocks([LocalStorage])
void main() {
  group('TypedStorage Extension Tests', () {
    late StorageService storageService;
    late MockLocalStorage mockNormalStorage;
    late MockLocalStorage mockSecureStorage;

    setUp(() {
      mockNormalStorage = MockLocalStorage();
      mockSecureStorage = MockLocalStorage();
      storageService = StorageService(
        normalStorage: mockNormalStorage,
        secureStorage: mockSecureStorage,
      );
    });

    group('JSON Operations - Normal Storage', () {
      test('should store and retrieve JSON objects', () async {
        const key = 'json_key';
        final jsonData = {'name': 'John', 'age': 30};
        const jsonString = '{"name":"John","age":30}';

        when(
          mockNormalStorage.setString(key, jsonString),
        ).thenAnswer((_) async => true);
        when(
          mockNormalStorage.getString(
            key,
            defaultValue: anyNamed('defaultValue'),
          ),
        ).thenAnswer((_) async => jsonString);

        expect(await storageService.setJson(key, jsonData), true);
        expect(await storageService.getJson(key), jsonData);

        verify(mockNormalStorage.setString(key, jsonString)).called(1);
        verify(
          mockNormalStorage.getString(
            key,
            defaultValue: anyNamed('defaultValue'),
          ),
        ).called(1);
      });

      test('should return null for invalid JSON', () async {
        const key = 'invalid_json';
        const invalidJson = 'invalid{json}';

        when(
          mockNormalStorage.getString(
            key,
            defaultValue: anyNamed('defaultValue'),
          ),
        ).thenAnswer((_) async => invalidJson);

        expect(await storageService.getJson(key), null);

        verify(
          mockNormalStorage.getString(
            key,
            defaultValue: anyNamed('defaultValue'),
          ),
        ).called(1);
      });

      test('should return null for non-existent JSON key', () async {
        const key = 'non_existent_json';

        when(
          mockNormalStorage.getString(
            key,
            defaultValue: anyNamed('defaultValue'),
          ),
        ).thenAnswer((_) async => null);

        expect(await storageService.getJson(key), null);

        verify(
          mockNormalStorage.getString(
            key,
            defaultValue: anyNamed('defaultValue'),
          ),
        ).called(1);
      });

      test('should handle complex JSON objects', () async {
        const key = 'complex_json';
        final complexData = {
          'user': {
            'name': 'John Doe',
            'email': 'john@example.com',
            'preferences': {'theme': 'dark', 'notifications': true},
            'tags': ['developer', 'flutter'],
          },
          'timestamp': 1234567890,
          'active': true,
        };
        final jsonString =
            '{"user":{"name":"John Doe","email":"john@example.com","preferences":{"theme":"dark","notifications":true},"tags":["developer","flutter"]},"timestamp":1234567890,"active":true}';

        when(
          mockNormalStorage.setString(key, any),
        ).thenAnswer((_) async => true);
        when(
          mockNormalStorage.getString(
            key,
            defaultValue: anyNamed('defaultValue'),
          ),
        ).thenAnswer((_) async => jsonString);

        expect(await storageService.setJson(key, complexData), true);
        final retrieved = await storageService.getJson(key);
        expect(retrieved, complexData);
      });
    });

    group('JSON Operations - Secure Storage', () {
      test('should store and retrieve secure JSON objects', () async {
        const key = 'secure_json_key';
        final jsonData = {'secret': 'value', 'token': 'abc123'};
        const jsonString = '{"secret":"value","token":"abc123"}';

        when(
          mockSecureStorage.setString(key, jsonString),
        ).thenAnswer((_) async => true);
        when(
          mockSecureStorage.getString(
            key,
            defaultValue: anyNamed('defaultValue'),
          ),
        ).thenAnswer((_) async => jsonString);

        expect(await storageService.setSecureJson(key, jsonData), true);
        expect(await storageService.getSecureJson(key), jsonData);

        verify(mockSecureStorage.setString(key, jsonString)).called(1);
        verify(
          mockSecureStorage.getString(
            key,
            defaultValue: anyNamed('defaultValue'),
          ),
        ).called(1);

        // Verify normal storage was not called
        verifyNever(mockNormalStorage.setString(any, any));
        verifyNever(
          mockNormalStorage.getString(
            any,
            defaultValue: anyNamed('defaultValue'),
          ),
        );
      });

      test('should return null for invalid secure JSON', () async {
        const key = 'invalid_secure_json';
        const invalidJson = 'invalid{json}';

        when(
          mockSecureStorage.getString(
            key,
            defaultValue: anyNamed('defaultValue'),
          ),
        ).thenAnswer((_) async => invalidJson);

        expect(await storageService.getSecureJson(key), null);
      });
    });

    group('String List Operations - Normal Storage', () {
      test('should store and retrieve string lists', () async {
        const key = 'list_key';
        const list = ['apple', 'banana', 'cherry'];
        const listJson = '["apple","banana","cherry"]';

        when(
          mockNormalStorage.setString(key, listJson),
        ).thenAnswer((_) async => true);
        when(
          mockNormalStorage.getString(
            key,
            defaultValue: anyNamed('defaultValue'),
          ),
        ).thenAnswer((_) async => listJson);

        expect(await storageService.setStringList(key, list), true);
        expect(await storageService.getStringList(key), list);

        verify(mockNormalStorage.setString(key, listJson)).called(1);
        verify(
          mockNormalStorage.getString(
            key,
            defaultValue: anyNamed('defaultValue'),
          ),
        ).called(1);
      });

      test('should return null for invalid list JSON', () async {
        const key = 'invalid_list';
        const invalidJson = 'not-a-list';

        when(
          mockNormalStorage.getString(
            key,
            defaultValue: anyNamed('defaultValue'),
          ),
        ).thenAnswer((_) async => invalidJson);

        expect(await storageService.getStringList(key), null);
      });

      test('should handle empty string list', () async {
        const key = 'empty_list';
        const emptyList = <String>[];
        const emptyListJson = '[]';

        when(
          mockNormalStorage.setString(key, emptyListJson),
        ).thenAnswer((_) async => true);
        when(
          mockNormalStorage.getString(
            key,
            defaultValue: anyNamed('defaultValue'),
          ),
        ).thenAnswer((_) async => emptyListJson);

        expect(await storageService.setStringList(key, emptyList), true);
        expect(await storageService.getStringList(key), emptyList);
      });
    });

    group('String List Operations - Secure Storage', () {
      test('should store and retrieve secure string lists', () async {
        const key = 'secure_list_key';
        const list = ['secret1', 'secret2', 'secret3'];
        const listJson = '["secret1","secret2","secret3"]';

        when(
          mockSecureStorage.setString(key, listJson),
        ).thenAnswer((_) async => true);
        when(
          mockSecureStorage.getString(
            key,
            defaultValue: anyNamed('defaultValue'),
          ),
        ).thenAnswer((_) async => listJson);

        expect(await storageService.setSecureStringList(key, list), true);
        expect(await storageService.getSecureStringList(key), list);

        verify(mockSecureStorage.setString(key, listJson)).called(1);
        verify(
          mockSecureStorage.getString(
            key,
            defaultValue: anyNamed('defaultValue'),
          ),
        ).called(1);

        // Verify normal storage was not called
        verifyNever(mockNormalStorage.setString(any, any));
        verifyNever(
          mockNormalStorage.getString(
            any,
            defaultValue: anyNamed('defaultValue'),
          ),
        );
      });
    });

    group('DateTime Operations - Normal Storage', () {
      test('should store and retrieve DateTime objects', () async {
        const key = 'datetime_key';
        final dateTime = DateTime(2024, 1, 15, 10, 30, 45);
        final isoString = dateTime.toIso8601String();

        when(
          mockNormalStorage.setString(key, isoString),
        ).thenAnswer((_) async => true);
        when(
          mockNormalStorage.getString(
            key,
            defaultValue: anyNamed('defaultValue'),
          ),
        ).thenAnswer((_) async => isoString);

        expect(await storageService.setDateTime(key, dateTime), true);
        expect(await storageService.getDateTime(key), dateTime);

        verify(mockNormalStorage.setString(key, isoString)).called(1);
        verify(
          mockNormalStorage.getString(
            key,
            defaultValue: anyNamed('defaultValue'),
          ),
        ).called(1);
      });

      test('should return null for invalid date string', () async {
        const key = 'invalid_date';
        const invalidDate = 'not-a-date';

        when(
          mockNormalStorage.getString(
            key,
            defaultValue: anyNamed('defaultValue'),
          ),
        ).thenAnswer((_) async => invalidDate);

        expect(await storageService.getDateTime(key), null);
      });

      test('should return null for non-existent date key', () async {
        const key = 'non_existent_date';

        when(
          mockNormalStorage.getString(
            key,
            defaultValue: anyNamed('defaultValue'),
          ),
        ).thenAnswer((_) async => null);

        expect(await storageService.getDateTime(key), null);
      });

      test('should handle UTC and local DateTime correctly', () async {
        const key1 = 'utc_datetime';
        const key2 = 'local_datetime';

        final utcDateTime = DateTime.utc(2024, 1, 15, 10, 30, 45);
        final localDateTime = DateTime(2024, 1, 15, 10, 30, 45);

        when(
          mockNormalStorage.setString(key1, utcDateTime.toIso8601String()),
        ).thenAnswer((_) async => true);
        when(
          mockNormalStorage.setString(key2, localDateTime.toIso8601String()),
        ).thenAnswer((_) async => true);
        when(
          mockNormalStorage.getString(
            key1,
            defaultValue: anyNamed('defaultValue'),
          ),
        ).thenAnswer((_) async => utcDateTime.toIso8601String());
        when(
          mockNormalStorage.getString(
            key2,
            defaultValue: anyNamed('defaultValue'),
          ),
        ).thenAnswer((_) async => localDateTime.toIso8601String());

        await storageService.setDateTime(key1, utcDateTime);
        await storageService.setDateTime(key2, localDateTime);

        final retrievedUtc = await storageService.getDateTime(key1);
        final retrievedLocal = await storageService.getDateTime(key2);

        expect(retrievedUtc, utcDateTime);
        expect(retrievedLocal, localDateTime);
        expect(retrievedUtc!.isUtc, true);
        expect(retrievedLocal!.isUtc, false);
      });
    });

    group('DateTime Operations - Secure Storage', () {
      test('should store and retrieve secure DateTime objects', () async {
        const key = 'secure_datetime_key';
        final dateTime = DateTime(2024, 1, 15, 10, 30, 45);
        final isoString = dateTime.toIso8601String();

        when(
          mockSecureStorage.setString(key, isoString),
        ).thenAnswer((_) async => true);
        when(
          mockSecureStorage.getString(
            key,
            defaultValue: anyNamed('defaultValue'),
          ),
        ).thenAnswer((_) async => isoString);

        expect(await storageService.setSecureDateTime(key, dateTime), true);
        expect(await storageService.getSecureDateTime(key), dateTime);

        verify(mockSecureStorage.setString(key, isoString)).called(1);
        verify(
          mockSecureStorage.getString(
            key,
            defaultValue: anyNamed('defaultValue'),
          ),
        ).called(1);

        // Verify normal storage was not called
        verifyNever(mockNormalStorage.setString(any, any));
        verifyNever(
          mockNormalStorage.getString(
            any,
            defaultValue: anyNamed('defaultValue'),
          ),
        );
      });

      test('should return null for invalid secure date string', () async {
        const key = 'invalid_secure_date';
        const invalidDate = 'not-a-date';

        when(
          mockSecureStorage.getString(
            key,
            defaultValue: anyNamed('defaultValue'),
          ),
        ).thenAnswer((_) async => invalidDate);

        expect(await storageService.getSecureDateTime(key), null);
      });
    });

    group('Mixed Typed Operations', () {
      test('should handle mixed normal and secure typed operations', () async {
        // Setup different data types for both normal and secure storage
        final userData = {'name': 'John', 'age': 30};
        final secureData = {'token': 'secret123', 'key': 'private'};
        const userTags = ['developer', 'flutter'];
        const secureTags = ['admin', 'privileged'];
        final loginTime = DateTime.now();
        final secretTime = DateTime.now().add(const Duration(hours: 1));

        // Setup mocks for normal storage
        when(
          mockNormalStorage.setString('user', any),
        ).thenAnswer((_) async => true);
        when(
          mockNormalStorage.setString('tags', any),
        ).thenAnswer((_) async => true);
        when(
          mockNormalStorage.setString('login_time', any),
        ).thenAnswer((_) async => true);
        when(
          mockNormalStorage.getString(
            'user',
            defaultValue: anyNamed('defaultValue'),
          ),
        ).thenAnswer((_) async => '{"name":"John","age":30}');
        when(
          mockNormalStorage.getString(
            'tags',
            defaultValue: anyNamed('defaultValue'),
          ),
        ).thenAnswer((_) async => '["developer","flutter"]');
        when(
          mockNormalStorage.getString(
            'login_time',
            defaultValue: anyNamed('defaultValue'),
          ),
        ).thenAnswer((_) async => loginTime.toIso8601String());

        // Setup mocks for secure storage
        when(
          mockSecureStorage.setString('secure_data', any),
        ).thenAnswer((_) async => true);
        when(
          mockSecureStorage.setString('secure_tags', any),
        ).thenAnswer((_) async => true);
        when(
          mockSecureStorage.setString('secret_time', any),
        ).thenAnswer((_) async => true);
        when(
          mockSecureStorage.getString(
            'secure_data',
            defaultValue: anyNamed('defaultValue'),
          ),
        ).thenAnswer((_) async => '{"token":"secret123","key":"private"}');
        when(
          mockSecureStorage.getString(
            'secure_tags',
            defaultValue: anyNamed('defaultValue'),
          ),
        ).thenAnswer((_) async => '["admin","privileged"]');
        when(
          mockSecureStorage.getString(
            'secret_time',
            defaultValue: anyNamed('defaultValue'),
          ),
        ).thenAnswer((_) async => secretTime.toIso8601String());

        // Perform mixed operations
        await storageService.setJson('user', userData);
        await storageService.setSecureJson('secure_data', secureData);
        await storageService.setStringList('tags', userTags);
        await storageService.setSecureStringList('secure_tags', secureTags);
        await storageService.setDateTime('login_time', loginTime);
        await storageService.setSecureDateTime('secret_time', secretTime);

        // Retrieve and verify
        expect(await storageService.getJson('user'), userData);
        expect(await storageService.getSecureJson('secure_data'), secureData);
        expect(await storageService.getStringList('tags'), userTags);
        expect(
          await storageService.getSecureStringList('secure_tags'),
          secureTags,
        );
        expect(await storageService.getDateTime('login_time'), loginTime);
        expect(
          await storageService.getSecureDateTime('secret_time'),
          secretTime,
        );

        // Verify proper delegation
        verify(mockNormalStorage.setString('user', any)).called(1);
        verify(mockNormalStorage.setString('tags', any)).called(1);
        verify(mockNormalStorage.setString('login_time', any)).called(1);
        verify(mockSecureStorage.setString('secure_data', any)).called(1);
        verify(mockSecureStorage.setString('secure_tags', any)).called(1);
        verify(mockSecureStorage.setString('secret_time', any)).called(1);

        // Verify no cross-calls
        verifyNever(mockNormalStorage.setString('secure_data', any));
        verifyNever(mockSecureStorage.setString('user', any));
      });
    });

    group('Error Handling', () {
      test('should handle storage errors gracefully', () async {
        const key = 'error_key';
        final data = {'test': 'data'};

        when(
          mockNormalStorage.setString(key, any),
        ).thenAnswer((_) async => false);
        when(
          mockSecureStorage.setString(key, any),
        ).thenAnswer((_) async => false);

        expect(await storageService.setJson(key, data), false);
        expect(await storageService.setSecureJson(key, data), false);
        expect(await storageService.setStringList(key, ['test']), false);
        expect(await storageService.setSecureStringList(key, ['test']), false);
        expect(await storageService.setDateTime(key, DateTime.now()), false);
        expect(
          await storageService.setSecureDateTime(key, DateTime.now()),
          false,
        );
      });
    });
  });
}
