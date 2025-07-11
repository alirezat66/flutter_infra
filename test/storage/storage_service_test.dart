import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:flutter_infra/flutter_infra.dart';

import 'storage_service_test.mocks.dart';

// Generate mocks for dependencies
@GenerateMocks([LocalStorage])
void main() {
  group('StorageService Tests', () {
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

    group('Normal Storage Operations', () {
      test('should delegate setString to normal storage', () async {
        const key = 'normal_key';
        const value = 'normal_value';

        when(
          mockNormalStorage.setString(key, value),
        ).thenAnswer((_) async => true);

        final result = await storageService.setString(key, value);
        expect(result, true);

        verify(mockNormalStorage.setString(key, value)).called(1);
        verifyNever(mockSecureStorage.setString(any, any));
      });

      test('should delegate getString to normal storage', () async {
        const key = 'normal_key';
        const value = 'normal_value';

        when(
          mockNormalStorage.getString(
            key,
            defaultValue: anyNamed('defaultValue'),
          ),
        ).thenAnswer((_) async => value);

        final result = await storageService.getString(key);
        expect(result, value);

        verify(
          mockNormalStorage.getString(
            key,
            defaultValue: anyNamed('defaultValue'),
          ),
        ).called(1);
        verifyNever(
          mockSecureStorage.getString(
            any,
            defaultValue: anyNamed('defaultValue'),
          ),
        );
      });

      test('should delegate setBool to normal storage', () async {
        const key = 'bool_key';
        const value = true;

        when(
          mockNormalStorage.setBool(key, value),
        ).thenAnswer((_) async => true);

        final result = await storageService.setBool(key, value);
        expect(result, true);

        verify(mockNormalStorage.setBool(key, value)).called(1);
        verifyNever(mockSecureStorage.setBool(any, any));
      });

      test('should delegate getBool to normal storage', () async {
        const key = 'bool_key';
        const value = true;

        when(
          mockNormalStorage.getBool(
            key,
            defaultValue: anyNamed('defaultValue'),
          ),
        ).thenAnswer((_) async => value);

        final result = await storageService.getBool(key);
        expect(result, value);

        verify(
          mockNormalStorage.getBool(
            key,
            defaultValue: anyNamed('defaultValue'),
          ),
        ).called(1);
        verifyNever(
          mockSecureStorage.getBool(
            any,
            defaultValue: anyNamed('defaultValue'),
          ),
        );
      });

      test('should delegate hasKey to normal storage', () async {
        const key = 'test_key';

        when(mockNormalStorage.hasKey(key)).thenAnswer((_) async => true);

        final result = await storageService.hasKey(key);
        expect(result, true);

        verify(mockNormalStorage.hasKey(key)).called(1);
        verifyNever(mockSecureStorage.hasKey(any));
      });

      test('should delegate deleteKey to normal storage', () async {
        const key = 'test_key';

        when(mockNormalStorage.deleteKey(key)).thenAnswer((_) async => true);

        final result = await storageService.deleteKey(key);
        expect(result, true);

        verify(mockNormalStorage.deleteKey(key)).called(1);
        verifyNever(mockSecureStorage.deleteKey(any));
      });

      test('should delegate clearAll to normal storage', () async {
        when(mockNormalStorage.clearAll()).thenAnswer((_) async => true);

        final result = await storageService.clearAll();
        expect(result, true);

        verify(mockNormalStorage.clearAll()).called(1);
        verifyNever(mockSecureStorage.clearAll());
      });
    });

    group('Secure Storage Operations', () {
      test('should delegate setSecureString to secure storage', () async {
        const key = 'secure_key';
        const value = 'secure_value';

        when(
          mockSecureStorage.setString(key, value),
        ).thenAnswer((_) async => true);

        final result = await storageService.setSecureString(key, value);
        expect(result, true);

        verify(mockSecureStorage.setString(key, value)).called(1);
        verifyNever(mockNormalStorage.setString(any, any));
      });

      test('should delegate getSecureString to secure storage', () async {
        const key = 'secure_key';
        const value = 'secure_value';

        when(
          mockSecureStorage.getString(
            key,
            defaultValue: anyNamed('defaultValue'),
          ),
        ).thenAnswer((_) async => value);

        final result = await storageService.getSecureString(key);
        expect(result, value);

        verify(
          mockSecureStorage.getString(
            key,
            defaultValue: anyNamed('defaultValue'),
          ),
        ).called(1);
        verifyNever(
          mockNormalStorage.getString(
            any,
            defaultValue: anyNamed('defaultValue'),
          ),
        );
      });

      test('should delegate setSecureBool to secure storage', () async {
        const key = 'secure_bool_key';
        const value = true;

        when(
          mockSecureStorage.setBool(key, value),
        ).thenAnswer((_) async => true);

        final result = await storageService.setSecureBool(key, value);
        expect(result, true);

        verify(mockSecureStorage.setBool(key, value)).called(1);
        verifyNever(mockNormalStorage.setBool(any, any));
      });

      test('should delegate getSecureBool to secure storage', () async {
        const key = 'secure_bool_key';
        const value = true;

        when(
          mockSecureStorage.getBool(
            key,
            defaultValue: anyNamed('defaultValue'),
          ),
        ).thenAnswer((_) async => value);

        final result = await storageService.getSecureBool(key);
        expect(result, value);

        verify(
          mockSecureStorage.getBool(
            key,
            defaultValue: anyNamed('defaultValue'),
          ),
        ).called(1);
        verifyNever(
          mockNormalStorage.getBool(
            any,
            defaultValue: anyNamed('defaultValue'),
          ),
        );
      });

      test('should delegate hasSecureKey to secure storage', () async {
        const key = 'secure_test_key';

        when(mockSecureStorage.hasKey(key)).thenAnswer((_) async => true);

        final result = await storageService.hasSecureKey(key);
        expect(result, true);

        verify(mockSecureStorage.hasKey(key)).called(1);
        verifyNever(mockNormalStorage.hasKey(any));
      });

      test('should delegate deleteSecureKey to secure storage', () async {
        const key = 'secure_test_key';

        when(mockSecureStorage.deleteKey(key)).thenAnswer((_) async => true);

        final result = await storageService.deleteSecureKey(key);
        expect(result, true);

        verify(mockSecureStorage.deleteKey(key)).called(1);
        verifyNever(mockNormalStorage.deleteKey(any));
      });

      test('should delegate clearAllSecure to secure storage', () async {
        when(mockSecureStorage.clearAll()).thenAnswer((_) async => true);

        final result = await storageService.clearAllSecure();
        expect(result, true);

        verify(mockSecureStorage.clearAll()).called(1);
        verifyNever(mockNormalStorage.clearAll());
      });
    });

    group('Mixed Operations', () {
      test(
        'should handle mixed normal and secure operations independently',
        () async {
          // Setup mocks
          when(
            mockNormalStorage.setString('normal_key', 'normal_value'),
          ).thenAnswer((_) async => true);
          when(
            mockSecureStorage.setString('secure_key', 'secure_value'),
          ).thenAnswer((_) async => true);
          when(
            mockNormalStorage.getString(
              'normal_key',
              defaultValue: anyNamed('defaultValue'),
            ),
          ).thenAnswer((_) async => 'normal_value');
          when(
            mockSecureStorage.getString(
              'secure_key',
              defaultValue: anyNamed('defaultValue'),
            ),
          ).thenAnswer((_) async => 'secure_value');

          // Perform mixed operations
          await storageService.setString('normal_key', 'normal_value');
          await storageService.setSecureString('secure_key', 'secure_value');

          final normalValue = await storageService.getString('normal_key');
          final secureValue = await storageService.getSecureString(
            'secure_key',
          );

          expect(normalValue, 'normal_value');
          expect(secureValue, 'secure_value');

          // Verify proper delegation
          verify(
            mockNormalStorage.setString('normal_key', 'normal_value'),
          ).called(1);
          verify(
            mockSecureStorage.setString('secure_key', 'secure_value'),
          ).called(1);
          verify(
            mockNormalStorage.getString(
              'normal_key',
              defaultValue: anyNamed('defaultValue'),
            ),
          ).called(1);
          verify(
            mockSecureStorage.getString(
              'secure_key',
              defaultValue: anyNamed('defaultValue'),
            ),
          ).called(1);

          // Verify no cross-calls
          verifyNever(mockNormalStorage.setString('secure_key', any));
          verifyNever(mockSecureStorage.setString('normal_key', any));
        },
      );
    });

    group('Error Handling', () {
      test('should propagate errors from normal storage', () async {
        const key = 'error_key';

        when(
          mockNormalStorage.setString(key, any),
        ).thenAnswer((_) async => false);

        final result = await storageService.setString(key, 'value');
        expect(result, false);
      });

      test('should propagate errors from secure storage', () async {
        const key = 'error_key';

        when(
          mockSecureStorage.setString(key, any),
        ).thenAnswer((_) async => false);

        final result = await storageService.setSecureString(key, 'value');
        expect(result, false);
      });
    });

    group('Default Values', () {
      test(
        'should pass default values correctly for normal operations',
        () async {
          const key = 'test_key';
          const defaultValue = 'default';

          when(
            mockNormalStorage.getString(key, defaultValue: defaultValue),
          ).thenAnswer((_) async => defaultValue);
          when(
            mockNormalStorage.getBool(key, defaultValue: true),
          ).thenAnswer((_) async => true);

          expect(
            await storageService.getString(key, defaultValue: defaultValue),
            defaultValue,
          );
          expect(await storageService.getBool(key, defaultValue: true), true);

          verify(
            mockNormalStorage.getString(key, defaultValue: defaultValue),
          ).called(1);
          verify(mockNormalStorage.getBool(key, defaultValue: true)).called(1);
        },
      );

      test(
        'should pass default values correctly for secure operations',
        () async {
          const key = 'secure_key';
          const defaultValue = 'secure_default';

          when(
            mockSecureStorage.getString(key, defaultValue: defaultValue),
          ).thenAnswer((_) async => defaultValue);
          when(
            mockSecureStorage.getBool(key, defaultValue: true),
          ).thenAnswer((_) async => true);

          expect(
            await storageService.getSecureString(
              key,
              defaultValue: defaultValue,
            ),
            defaultValue,
          );
          expect(
            await storageService.getSecureBool(key, defaultValue: true),
            true,
          );

          verify(
            mockSecureStorage.getString(key, defaultValue: defaultValue),
          ).called(1);
          verify(mockSecureStorage.getBool(key, defaultValue: true)).called(1);
        },
      );
    });
  });
}
