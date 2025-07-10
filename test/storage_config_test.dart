import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_infra/flutter_infra.dart';

void main() {
  group('StorageConfig Tests', () {
    group('Default Values', () {
      test('should have correct default values', () {
        const config = StorageConfig();

        expect(config.enableLogging, false);
        expect(config.encryptionKey, null);
        expect(config.cacheTimeout, const Duration(minutes: 30));
        expect(config.enableCache, true);
        expect(config.customSettings, const <String, dynamic>{});
      });
    });

    group('Custom Values', () {
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

      test('should handle empty custom settings', () {
        const config = StorageConfig(customSettings: {});

        expect(config.customSettings, isEmpty);
      });

      test('should handle complex custom settings', () {
        const config = StorageConfig(
          customSettings: {
            'string_setting': 'value',
            'int_setting': 42,
            'bool_setting': true,
            'list_setting': ['a', 'b', 'c'],
            'map_setting': {'nested': 'value'},
          },
        );

        expect(config.customSettings['string_setting'], 'value');
        expect(config.customSettings['int_setting'], 42);
        expect(config.customSettings['bool_setting'], true);
        expect(config.customSettings['list_setting'], ['a', 'b', 'c']);
        expect(config.customSettings['map_setting'], {'nested': 'value'});
      });
    });

    group('copyWith Method', () {
      test('should copy with new values correctly', () {
        const original = StorageConfig(enableLogging: false, enableCache: true);
        final copy = original.copyWith(enableLogging: true);

        expect(copy.enableLogging, true);
        expect(copy.enableCache, true); // Should retain original value
        expect(copy.encryptionKey, null); // Should retain original value
        expect(
          copy.cacheTimeout,
          const Duration(minutes: 30),
        ); // Should retain original value
      });

      test('should copy with multiple new values', () {
        const original = StorageConfig(
          enableLogging: false,
          enableCache: true,
          encryptionKey: 'old-key',
        );

        final copy = original.copyWith(
          enableLogging: true,
          encryptionKey: 'new-key',
          cacheTimeout: const Duration(hours: 1),
        );

        expect(copy.enableLogging, true);
        expect(copy.encryptionKey, 'new-key');
        expect(copy.cacheTimeout, const Duration(hours: 1));
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
        expect(copy.cacheTimeout, const Duration(minutes: 30));
        expect(copy.customSettings, const <String, dynamic>{});
      });

      test('should copy custom settings correctly', () {
        const original = StorageConfig(customSettings: {'original': 'value'});

        final copy = original.copyWith(
          customSettings: {'new': 'value', 'another': 42},
        );

        expect(copy.customSettings, {'new': 'value', 'another': 42});
        expect(original.customSettings, {
          'original': 'value',
        }); // Original unchanged
      });

      test('should handle copying with empty custom settings', () {
        const original = StorageConfig(customSettings: {'original': 'value'});

        final copy = original.copyWith(customSettings: {});

        expect(copy.customSettings, isEmpty);
        expect(original.customSettings, {
          'original': 'value',
        }); // Original unchanged
      });
    });

    group('Equality and Immutability', () {
      test('should be immutable', () {
        const config = StorageConfig(customSettings: {'key': 'value'});

        // Attempting to modify should not affect the original
        // (Dart const constructors ensure immutability)
        expect(config.customSettings, {'key': 'value'});
      });

      test('should create different instances for different values', () {
        const config1 = StorageConfig(enableLogging: true);
        const config2 = StorageConfig(enableLogging: false);

        expect(config1.enableLogging, true);
        expect(config2.enableLogging, false);
      });
    });

    group('Edge Cases', () {
      test('should handle very long cache timeout', () {
        const config = StorageConfig(cacheTimeout: Duration(days: 365));

        expect(config.cacheTimeout, const Duration(days: 365));
      });

      test('should handle zero cache timeout', () {
        const config = StorageConfig(cacheTimeout: Duration.zero);

        expect(config.cacheTimeout, Duration.zero);
      });

      test('should handle very long encryption key', () {
        final longKey = 'a' * 1000;
        final config = StorageConfig(encryptionKey: longKey);

        expect(config.encryptionKey, longKey);
      });

      test('should handle empty encryption key', () {
        const config = StorageConfig(encryptionKey: '');

        expect(config.encryptionKey, '');
      });
    });

    group('Real-world Usage Patterns', () {
      test('should support development configuration', () {
        const devConfig = StorageConfig(
          enableLogging: true,
          enableCache: false, // Disable for testing
          customSettings: {'debug_mode': true, 'mock_data': true},
        );

        expect(devConfig.enableLogging, true);
        expect(devConfig.enableCache, false);
        expect(devConfig.customSettings['debug_mode'], true);
        expect(devConfig.customSettings['mock_data'], true);
      });

      test('should support production configuration', () {
        const prodConfig = StorageConfig(
          enableLogging: false,
          enableCache: true,
          cacheTimeout: Duration(hours: 24),
          encryptionKey: 'production-secret-key',
          customSettings: {'analytics_enabled': true, 'crash_reporting': true},
        );

        expect(prodConfig.enableLogging, false);
        expect(prodConfig.enableCache, true);
        expect(prodConfig.cacheTimeout, const Duration(hours: 24));
        expect(prodConfig.encryptionKey, 'production-secret-key');
        expect(prodConfig.customSettings['analytics_enabled'], true);
        expect(prodConfig.customSettings['crash_reporting'], true);
      });

      test('should support testing configuration', () {
        const testConfig = StorageConfig(
          enableLogging: false, // Quiet during tests
          enableCache: false, // Predictable behavior
          customSettings: {'use_memory_storage': true, 'fast_mode': true},
        );

        expect(testConfig.enableLogging, false);
        expect(testConfig.enableCache, false);
        expect(testConfig.customSettings['use_memory_storage'], true);
        expect(testConfig.customSettings['fast_mode'], true);
      });
    });
  });
}
