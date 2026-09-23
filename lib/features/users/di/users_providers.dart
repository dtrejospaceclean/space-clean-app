import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/network_providers.dart';
import '../data/repositories/users_repository_impl.dart';
import '../domain/repositories/users_repository.dart';
import '../domain/usecases/user_usecases.dart';

final usersRepositoryProvider = Provider<UsersRepository>(
  (ref) => UsersRepositoryImpl(ref.watch(apiClientProvider)),
);

final rolesRepositoryProvider = Provider<RolesRepository>(
  (ref) => RolesRepositoryImpl(ref.watch(apiClientProvider)),
);

final getUsersProvider = Provider(
  (ref) => GetUsers(ref.watch(usersRepositoryProvider)),
);
final getUserProvider = Provider(
  (ref) => GetUser(ref.watch(usersRepositoryProvider)),
);
final createUserProvider = Provider(
  (ref) => CreateUser(ref.watch(usersRepositoryProvider)),
);
final updateUserProvider = Provider(
  (ref) => UpdateUser(ref.watch(usersRepositoryProvider)),
);
final setUserActiveProvider = Provider(
  (ref) => SetUserActive(ref.watch(usersRepositoryProvider)),
);
final getRolesProvider = Provider(
  (ref) => GetRoles(ref.watch(rolesRepositoryProvider)),
);
final saveRoleProvider = Provider(
  (ref) => SaveRole(ref.watch(rolesRepositoryProvider)),
);
final deleteRoleProvider = Provider(
  (ref) => DeleteRole(ref.watch(rolesRepositoryProvider)),
);
