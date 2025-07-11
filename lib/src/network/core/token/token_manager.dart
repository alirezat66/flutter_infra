import 'package:flutter_infra/src/network/core/token/token_config.dart';

abstract class TokenManager {
  Future<String?> getToken();
  Future<void> saveToken(String token);
  Future<void> deleteToken();
  TokenConfig get config;
}
