class TokenConfig {
  final String tokenHeaderKey;
  final String tokenStorageKey;
  final String tokenResponseField;
  final String tokenPrefix;
  final String refreshTokenStorageKey;
  final String refreshTokenResponseField;
  final String refreshTokenEndPoint;
  TokenConfig({
    this.tokenHeaderKey = 'Authorization',
    this.tokenStorageKey = 'pref_token',
    this.tokenResponseField = 'token',
    this.tokenPrefix = 'Bearer',
    this.refreshTokenStorageKey = 'pref_refresh_token',
    this.refreshTokenResponseField = 'refresh_token',
    this.refreshTokenEndPoint = '/auth/refresh',
  });
}
