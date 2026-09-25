import '../entities/app_theme_mode.dart';

abstract interface class ThemeModeRepository {
  /// The appearance the user picked, or `null` if they never chose.
  AppThemeMode? get savedThemeMode;

  Future<void> saveThemeMode(AppThemeMode mode);
}
