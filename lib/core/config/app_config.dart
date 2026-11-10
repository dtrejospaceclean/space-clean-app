abstract final class AppConfig {
  static const _defaultApiBaseUrl = 'https://spaceclean-be.spacecleanllc.com';

  /// Override with `--dart-define=API_BASE_URL=http://localhost:3000` for a
  /// local backend (use `http://10.0.2.2:3000` from the Android emulator).
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultApiBaseUrl,
  );

  static const _defaultBotBaseUrl = 'https://whatsapp-bot.spacecleanllc.com';

  /// The WhatsApp bot's own service (tickets handed over to people). Override
  /// with `--dart-define=BOT_API_BASE_URL=http://localhost:3001`.
  static const botBaseUrl = String.fromEnvironment(
    'BOT_API_BASE_URL',
    defaultValue: _defaultBotBaseUrl,
  );
}
