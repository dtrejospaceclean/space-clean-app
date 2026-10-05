import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/scopes_providers.dart';
import '../../domain/entities/scope.dart';
import '../../domain/usecases/scope_usecases.dart';

/// An account's scopes by location and area, or one contract's.
final scopesProvider = FutureProvider.autoDispose
    .family<List<Scope>, ScopeQuery>(
      (ref, query) => ref.watch(getScopesProvider)(query),
    );

/// One scope: `(clientId, scopeId)`.
final scopeProvider = FutureProvider.autoDispose
    .family<Scope, (String, String)>(
      (ref, key) => ref.watch(getScopeProvider)(
        ScopeRef(clientId: key.$1, scopeId: key.$2),
      ),
    );

/// Drops cached scopes after any write. A contract's scope count changes
/// too, so callers also invalidate the contracts.
void invalidateScopes(WidgetRef ref) => ref
  ..invalidate(scopesProvider)
  ..invalidate(scopeProvider);
