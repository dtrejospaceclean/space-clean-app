import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../users/di/users_providers.dart';
import '../../../users/domain/entities/managed_user.dart';
import '../../../users/domain/usecases/user_usecases.dart';
import '../../di/clients_providers.dart';
import '../../domain/entities/client.dart';
import '../../domain/usecases/manage_clients.dart';

/// The signed-in user's accounts. Refresh with `ref.invalidate`.
final myClientsProvider = FutureProvider<List<Client>>((ref) {
  // Reload when the session changes (sign-out, another user signs in).
  ref.watch(authControllerProvider.select((s) => s.value));
  return ref.watch(getMyClientsProvider)(const NoParams());
});

/// The Accounts tab's search text, as last applied (already debounced).
/// Cleared when the session changes.
final accountSearchProvider = NotifierProvider<AccountSearchController, String>(
  AccountSearchController.new,
);

class AccountSearchController extends Notifier<String> {
  @override
  String build() {
    ref.watch(authControllerProvider.select((s) => s.value));
    return '';
  }

  void search(String text) => state = text.trim();
}

/// What the Accounts tab lists: every account, or the server's matches for
/// the search text.
final accountsListProvider = FutureProvider<List<Client>>((ref) async {
  final search = ref.watch(accountSearchProvider);
  // Also re-runs the search whenever the full list reloads (pull to
  // refresh, an account created, edited or deleted).
  final all = await ref.watch(myClientsProvider.future);
  if (search.isEmpty) return all;
  return ref.watch(searchMyClientsProvider)(search);
});

/// One account from the list, by id.
final clientByIdProvider = FutureProvider.family<Client?, String>((
  ref,
  clientId,
) async {
  final clients = await ref.watch(myClientsProvider.future);
  for (final client in clients) {
    if (client.id == clientId) return client;
  }
  return null;
});

/// One account with all its details (`GET /clients/:id`, needs `info.view`).
final clientDetailProvider = FutureProvider.family<Client, String>(
  (ref, clientId) => ref.watch(getClientProvider)(clientId),
);

User? _signedIn(Ref ref) => switch (ref.watch(authControllerProvider).value) {
  Authenticated(:final user) => user,
  _ => null,
};

/// Whether they may delete accounts (owners).
final canDeleteAccountsProvider = Provider<bool>((ref) {
  final user = _signedIn(ref);
  return user != null && AccountAdminPolicy.canDelete(user);
});

/// Whether a new account can be opened right away (owners see them all).
final seesAllAccountsProvider = Provider<bool>((ref) {
  final user = _signedIn(ref);
  return user != null && AccountAdminPolicy.seesAllAccounts(user);
});

/// Active users to pick an account's manager, supervisor and salesperson
/// from. `null` when the signed-in user can't list users.
final assignableUsersProvider = FutureProvider.autoDispose<List<ManagedUser>?>((
  ref,
) {
  final user = _signedIn(ref);
  if (user == null || !UserAdminPolicy.canView(user)) return null;
  return ref.watch(getUsersProvider)(const UserQuery());
});
