import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/network_providers.dart';
import '../data/datasources/auth_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/login.dart';
import '../domain/usecases/logout.dart';
import '../domain/usecases/restore_session.dart';
import '../domain/usecases/watch_session_expired.dart';

// Composition root for the auth feature: the only place that knows the
// concrete data classes. Tests override `authRepositoryProvider`.

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSource(ref.watch(apiClientProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(tokenStorageProvider),
  ),
);

final loginProvider = Provider<Login>(
  (ref) => Login(ref.watch(authRepositoryProvider)),
);

final logoutProvider = Provider<Logout>(
  (ref) => Logout(ref.watch(authRepositoryProvider)),
);

final restoreSessionProvider = Provider<RestoreSession>(
  (ref) => RestoreSession(ref.watch(authRepositoryProvider)),
);

final watchSessionExpiredProvider = Provider<WatchSessionExpired>(
  (ref) => WatchSessionExpired(ref.watch(authRepositoryProvider)),
);
