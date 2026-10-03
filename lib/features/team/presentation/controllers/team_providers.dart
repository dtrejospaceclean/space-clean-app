import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../users/di/users_providers.dart';
import '../../../users/domain/entities/managed_user.dart';
import '../../di/team_providers.dart';
import '../../domain/entities/member.dart';
import '../../domain/usecases/team_usecases.dart';

/// An account's members by name. Later pickers (jobs, complaints, tasks)
/// read this too. Refresh with `ref.invalidate` after any change.
final membersProvider = FutureProvider.family<List<Member>, String>(
  (ref, clientId) => ref.watch(getMembersProvider)(clientId),
);

/// One member, read from the account's list: `(clientId, userId)`.
final memberProvider = FutureProvider.family<Member, (String, String)>((
  ref,
  key,
) async {
  final (clientId, userId) = key;
  final members = await ref.watch(membersProvider(clientId).future);
  for (final member in members) {
    if (member.userId == userId) return member;
  }
  throw const ServerFailure('members.not_found', statusCode: 404);
});

/// Every permission and each role's defaults. Static on the server.
final permissionCatalogProvider = FutureProvider<PermissionCatalog>(
  (ref) => ref.watch(getPermissionCatalogProvider)(const NoParams()),
);

/// Whether the signed-in user may change teams (global owners).
final canManageTeamProvider = Provider<bool>(
  (ref) => switch (ref.watch(authControllerProvider).value) {
    Authenticated(:final user) => TeamPolicy.canManage(user),
    _ => false,
  },
);

/// Active users to add to a team. Only owners manage teams, and owners can
/// list users.
final activeUsersProvider = FutureProvider.autoDispose<List<ManagedUser>>(
  (ref) => ref.watch(getUsersProvider)(const UserQuery()),
);

/// Both values once both have loaded; the first error otherwise.
AsyncValue<(A, B)> bothLoaded<A, B>(AsyncValue<A> a, AsyncValue<B> b) {
  if (a.hasValue && b.hasValue) {
    return AsyncData((a.requireValue, b.requireValue));
  }
  if (a.hasError) return AsyncError(a.error!, a.stackTrace!);
  if (b.hasError) return AsyncError(b.error!, b.stackTrace!);
  return const AsyncLoading();
}
