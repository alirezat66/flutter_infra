class StorageConfig {
  final bool enableLogging;
  final String? encryptionKey;
  final Duration cacheTimeout;
  final bool enableCache;
  final Map<String, dynamic> customSettings;

  const StorageConfig({
    this.enableLogging = false,
    this.encryptionKey,
    this.cacheTimeout = const Duration(minutes: 30),
    this.enableCache = true,
    this.customSettings = const {},
  });

  StorageConfig copyWith({
    bool? enableLogging,
    String? encryptionKey,
    Duration? cacheTimeout,
    bool? enableCache,
    Map<String, dynamic>? customSettings,
  }) {
    return StorageConfig(
      enableLogging: enableLogging ?? this.enableLogging,
      encryptionKey: encryptionKey ?? this.encryptionKey,
      cacheTimeout: cacheTimeout ?? this.cacheTimeout,
      enableCache: enableCache ?? this.enableCache,
      customSettings: customSettings ?? this.customSettings,
    );
  }
}