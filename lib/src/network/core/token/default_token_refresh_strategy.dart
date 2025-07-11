import 'package:flutter_infra/flutter_infra.dart';
class DefaultTokenRefreshStrategy implements TokenRefreshStrategy {
  final NetworkService _networkService;
  final TokenManager _tokenManager;

  DefaultTokenRefreshStrategy({
    required NetworkService networkService,
    required TokenManager tokenManager,
  }) : _networkService = networkService,
       _tokenManager = tokenManager;

  @override
  Future<bool> refreshToken() async {
    final config = _tokenManager.config;
    try {
      final response = await _networkService.post(config.refreshTokenEndPoint);

      if (response.isSuccess &&
          response.data is Map &&
          (response.data as Map).containsKey(config.tokenResponseField)) {
        final data = response.data as Map;
        final token = data[config.tokenResponseField];
        final refreshToken =
            data.containsKey(config.refreshTokenResponseField)
                ? data[config.refreshTokenResponseField]
                : null;
        if (token is String) {
          await _tokenManager.saveToken(token);
          if (refreshToken != null) {
            await _tokenManager.saveRefreshToken(refreshToken);
          }
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}
