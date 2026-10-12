import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/settings_providers.dart';
import '../../domain/entities/app_version.dart';

/// The installed version. It can't change while the app runs, so it's read
/// once.
final appVersionProvider = FutureProvider<AppVersion>(
  (ref) => ref.watch(appInfoRepositoryProvider).getVersion(),
);
