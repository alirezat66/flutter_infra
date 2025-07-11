class TokenConfig {
  final String tokenHeaderKey;
  final String tokenStorageKey;
  final String tokenResponseField;
  final String tokenPrefix;

  TokenConfig({
    this.tokenHeaderKey = 'Authorization',
    this.tokenStorageKey = 'pref_token',
    this.tokenResponseField = 'token',
    this.tokenPrefix = 'Bearer',
  });
}
