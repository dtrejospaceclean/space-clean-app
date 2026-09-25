import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/settings_providers.dart';
import '../../domain/entities/app_theme_mode.dart';

/// The app's appearance. Follows the phone until the user picks one.
final themeModeControllerProvider =
    NotifierProvider<ThemeModeController, AppThemeMode>(
      ThemeModeController.new,
    );

class ThemeModeController extends Notifier<AppThemeMode> {
  @override
  AppThemeMode build() =>
      ref.watch(themeModeRepositoryProvider).savedThemeMode ??
      AppThemeMode.system;

  Future<void> select(AppThemeMode mode) async {
    state = mode;
    await ref.read(themeModeRepositoryProvider).saveThemeMode(mode);
  }
}

extension AppThemeModeMaterial on AppThemeMode {
  ThemeMode get material => switch (this) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };
}
