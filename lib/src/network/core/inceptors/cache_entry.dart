import '../network_response.dart';

/// Represents a cached network response with expiration information
class CacheEntry {
  /// The cached network response
  final NetworkResponse response;

  /// When this cache entry was created
  final DateTime createdAt;

  /// When this cache entry expires
  final DateTime expiresAt;

  /// The cache key for this entry
  final String cacheKey;

  /// Optional tags for cache management
  final Set<String> tags;

  CacheEntry({
    required this.response,
    required this.createdAt,
    required this.expiresAt,
    required this.cacheKey,
    this.tags = const {},
  });

  /// Creates a cache entry with a specific duration from now
  factory CacheEntry.withDuration({
    required NetworkResponse response,
    required Duration duration,
    required String cacheKey,
    Set<String> tags = const {},
  }) {
    final now = DateTime.now();
    return CacheEntry(
      response: response,
      createdAt: now,
      expiresAt: now.add(duration),
      cacheKey: cacheKey,
      tags: tags,
    );
  }

  /// Checks if this cache entry is still valid
  bool get isValid => DateTime.now().isBefore(expiresAt);

  /// Checks if this cache entry is expired
  bool get isExpired => !isValid;

  /// Gets the age of this cache entry
  Duration get age => DateTime.now().difference(createdAt);

  /// Gets the time remaining before expiration
  Duration get timeToExpire => expiresAt.difference(DateTime.now());

  /// Creates a copy of this cache entry with updated properties
  CacheEntry copyWith({
    NetworkResponse? response,
    DateTime? createdAt,
    DateTime? expiresAt,
    String? cacheKey,
    Set<String>? tags,
  }) {
    return CacheEntry(
      response: response ?? this.response,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      cacheKey: cacheKey ?? this.cacheKey,
      tags: tags ?? this.tags,
    );
  }

  @override
  String toString() {
    return 'CacheEntry(cacheKey: $cacheKey, createdAt: $createdAt, expiresAt: $expiresAt, isValid: $isValid)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CacheEntry && other.cacheKey == cacheKey;
  }

  @override
  int get hashCode => cacheKey.hashCode;
}
