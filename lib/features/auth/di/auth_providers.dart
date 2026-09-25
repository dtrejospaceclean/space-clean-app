import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/network_providers.dart';
import '../../../core/storage/preferences.dart';
import '../data/datasources/auth_local_data_source.dart';
import '../data/datasources/auth_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/login.dart';
import '../domain/usecases/logout.dart';
import '../domain/usecases/refresh_current_user.dart';
import '../domain/usecases/remembered_email.dart';
import '../domain/usecases/restore_session.dart';
import '../domain/usecases/watch_session_expired.dart';

// Composition root for the auth feature: the only place that knows the
// concrete data classes. Tests override `authRepositoryProvider`.

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSource(ref.watch(apiClientProvider)),
);

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>(
  (ref) => AuthLocalDataSource(ref.watch(sharedPreferencesProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(authLocalDataSourceProvider),
    ref.watch(tokenStorageProvider),
  ),
);

final loginProvider = Provider<Login>(
  (ref) => Login(ref.watch(authRepositoryProvider)),
);

final logoutProvider = Provider<Logout>(
  (ref) => Logout(ref.watch(authRepositoryProvider)),
);

final refreshCurrentUserProvider = Provider<RefreshCurrentUser>(
  (ref) => RefreshCurrentUser(ref.watch(authRepositoryProvider)),
);

final restoreSessionProvider = Provider<RestoreSession>(
  (ref) => RestoreSession(ref.watch(authRepositoryProvider)),
);

final watchSessionExpiredProvider = Provider<WatchSessionExpired>(
  (ref) => WatchSessionExpired(ref.watch(authRepositoryProvider)),
);

final getRememberedEmailProvider = Provider<GetRememberedEmail>(
  (ref) => GetRememberedEmail(ref.watch(authRepositoryProvider)),
);

final forgetRememberedEmailProvider = Provider<ForgetRememberedEmail>(
  (ref) => ForgetRememberedEmail(ref.watch(authRepositoryProvider)),
);
