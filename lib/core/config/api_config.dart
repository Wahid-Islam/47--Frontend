/// Backend API base URL.
///
/// Override at build/run time:
///   flutter run -d chrome --dart-define=API_BASE_URL=https://your-api.vercel.app
///
/// Defaults to the local Node server started by `npm run dev` in the backend repo.
class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  static const String tokenStorageKey = 'mysihat_access_token';
}
