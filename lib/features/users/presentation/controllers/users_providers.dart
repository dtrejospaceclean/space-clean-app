import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../di/users_providers.dart';
import '../../domain/entities/managed_user.dart';
import '../../domain/entities/role_info.dart';
import '../../domain/usecases/user_usecases.dart';

/// Whether the signed-in user may open user administration at all.
final canViewUsersProvider = Provider<bool>((ref) {
  final auth = ref.watch(authControllerProvider).value;
  return auth is Authenticated && UserAdminPolicy.canView(auth.user);
});

/// Whether they may change users and roles (owners only).
final canEditUsersProvider = Provider<bool>((ref) {
  final auth = ref.watch(authControllerProvider).value;
  return auth is Authenticated && UserAdminPolicy.canEdit(auth.user);
});

/// The list's search.
final userQueryProvider = NotifierProvider<UserQueryController, UserQuery>(
  UserQueryController.new,
);

class UserQueryController extends Notifier<UserQuery> {
  /// Active and inactive together (active first), each marked.
  @override
  UserQuery build() => const UserQuery(isActive: null);

  void search(String text) => state = state.copyWith(search: text);
}

final usersProvider = FutureProvider.autoDispose<List<ManagedUser>>(
  (ref) => ref.watch(getUsersProvider)(ref.watch(userQueryProvider)),
);

final userProvider = FutureProvider.autoDispose.family<ManagedUser, String>(
  (ref, id) => ref.watch(getUserProvider)(id),
);

final rolesProvider = FutureProvider.autoDispose<List<RoleInfo>>(
  (ref) => ref.watch(getRolesProvider)(const NoParams()),
);
