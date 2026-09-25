/// Light or dark appearance, or [system] to follow the phone.
enum AppThemeMode {
  system,
  light,
  dark;

  static AppThemeMode? tryParse(String? name) => switch (name) {
    'system' => system,
    'light' => light,
    'dark' => dark,
    _ => null,
  };
}
