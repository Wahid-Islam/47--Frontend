class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  static const String tokenStorageKey = 'mysihat_access_token';
}
