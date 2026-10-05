import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/network_providers.dart';
import '../data/datasources/scopes_remote_data_source.dart';
import '../data/repositories/scopes_repository_impl.dart';
import '../domain/repositories/scopes_repository.dart';
import '../domain/usecases/scope_usecases.dart';

final scopesRepositoryProvider = Provider<ScopesRepository>(
  (ref) => ScopesRepositoryImpl(
    ScopesRemoteDataSource(ref.watch(apiClientProvider)),
  ),
);

final getScopesProvider = Provider(
  (ref) => GetScopes(ref.watch(scopesRepositoryProvider)),
);
final getScopeProvider = Provider(
  (ref) => GetScope(ref.watch(scopesRepositoryProvider)),
);
final saveScopeProvider = Provider(
  (ref) => SaveScope(ref.watch(scopesRepositoryProvider)),
);
final deleteScopeProvider = Provider(
  (ref) => DeleteScope(ref.watch(scopesRepositoryProvider)),
);
