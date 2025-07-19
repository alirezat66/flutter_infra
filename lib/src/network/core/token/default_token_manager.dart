import 'package:flutter_infra/flutter_infra.dart';

class DefaultTokenManager implements TokenManager {
  final StorageService _storage;
  final TokenConfig _config;
  DefaultTokenManager({StorageService? storage, TokenConfig? config})
    : _storage = storage ?? StorageService(),
      _config = config ?? TokenConfig();

  @override
  Future<String?> getToken() =>
      _storage.getSecureString(_config.tokenStorageKey);

  @override
  Future<void> saveToken(String token) =>
      _storage.setSecureString(_config.tokenStorageKey, token);

  @override
  Future<void> deleteToken() =>
      _storage.deleteSecureKey(_config.tokenStorageKey);

  @override
  TokenConfig get config => _config;

  @override
  Future<void> deleteRefreshToken() =>
      _storage.deleteSecureKey(_config.refreshTokenStorageKey);

  @override
  Future<String?> getRefreshToken() =>
      _storage.getSecureString(_config.refreshTokenStorageKey);

  @override
  Future<void> saveRefreshToken(String refreshToken) =>
      _storage.setSecureString(_config.refreshTokenStorageKey, refreshToken);
}
