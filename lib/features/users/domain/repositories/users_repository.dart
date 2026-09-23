import '../entities/managed_user.dart';
import '../entities/role_info.dart';

/// Every method throws a `Failure`. Reads need the global `owner` or
/// `account_manager` role; writes need `owner`.
abstract interface class UsersRepository {
  Future<List<ManagedUser>> getUsers(UserQuery query);

  Future<ManagedUser> getUser(String id);

  Future<ManagedUser> createUser(UserDraft draft);

  Future<ManagedUser> updateUser(String id, UserDraft draft);

  /// Deactivating keeps the user and their history; they can't sign in.
  Future<ManagedUser> setActive(String id, {required bool active});

  /// Replaces the user's roles.
  Future<ManagedUser> setRoles(String id, List<String> roleIds);
}

/// Every method throws a `Failure`.
abstract interface class RolesRepository {
  Future<List<RoleInfo>> getRoles();

  Future<RoleInfo> createRole({required String name, String? description});

  Future<RoleInfo> updateRole(String id, {String? name, String? description});

  Future<void> deleteRole(String id);
}
