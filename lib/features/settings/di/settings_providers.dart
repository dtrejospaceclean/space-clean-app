import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/preferences.dart';
import '../data/repositories/language_repository_impl.dart';
import '../data/repositories/theme_mode_repository_impl.dart';
import '../domain/repositories/language_repository.dart';
import '../domain/repositories/theme_mode_repository.dart';

final languageRepositoryProvider = Provider<LanguageRepository>(
  (ref) => LanguageRepositoryImpl(ref.watch(sharedPreferencesProvider)),
);

final themeModeRepositoryProvider = Provider<ThemeModeRepository>(
  (ref) => ThemeModeRepositoryImpl(ref.watch(sharedPreferencesProvider)),
);
