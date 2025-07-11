import 'package:flutter_infra/src/network/core/network_error.dart';
import 'package:flutter_infra/src/network/core/network_interceptor.dart';
import 'package:flutter_infra/src/network/core/network_request.dart';
import 'package:flutter_infra/src/network/core/network_response.dart';
import 'package:flutter_infra/src/network/core/token/default_token_manager.dart';
import 'package:flutter_infra/src/network/core/token/token_manager.dart';

class TokenInterceptor implements NetworkInterceptor {
  final TokenManager _tokenManager;

  TokenInterceptor({TokenManager? tokenManager})
    : _tokenManager = tokenManager ?? DefaultTokenManager();

  @override
  Future<void> onRequest(NetworkRequest request) async {
    final token = await _tokenManager.getToken();
    if (token != null) {
      final prefix = _tokenManager.config.tokenPrefix;
      request.headers[_tokenManager.config.tokenHeaderKey] =
          prefix.isEmpty ? token : '$prefix $token';
    }
  }

  @override
  Future<void> onResponse(NetworkResponse response) async {
    if (response.isSuccess && response.data is Map) {
      final map = response.data as Map;
      final token = map[_tokenManager.config.tokenResponseField];
      if (token is String) {
        await _tokenManager.saveToken(token);
      }
    }
  }

  @override
  Future<void> onError(NetworkError error) async {
    if (error.code == 401) {
      await _tokenManager.deleteToken();
    }
  }
}
