abstract final class AppConfig {
  static const _defaultApiBaseUrl =
      'https://space-clean-be-production.up.railway.app';

  /// Override with `--dart-define=API_BASE_URL=http://localhost:3000` for a
  /// local backend (use `http://10.0.2.2:3000` from the Android emulator).
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultApiBaseUrl,
  );
}
