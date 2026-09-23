import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/entities/user.dart';
import '../entities/managed_user.dart';
import '../entities/role_info.dart';
import '../repositories/users_repository.dart';

/// Who may open user administration, and who may change it.
abstract final class UserAdminPolicy {
  static bool canView(User user) =>
      user.hasAnyRole(const [GlobalRole.owner, GlobalRole.accountManager]);

  static bool canEdit(User user) => user.hasRole(GlobalRole.owner);
}

class GetUsers implements UseCase<List<ManagedUser>, UserQuery> {
  const GetUsers(this._repository);

  final UsersRepository _repository;

  /// Active users first, then by name.
  @override
  Future<List<ManagedUser>> call(UserQuery query) async {
    final users = await _repository.getUsers(query);
    return [...users]..sort((a, b) {
      if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
  }
}

class GetUser implements UseCase<ManagedUser, String> {
  const GetUser(this._repository);

  final UsersRepository _repository;

  @override
  Future<ManagedUser> call(String id) => _repository.getUser(id);
}

class CreateUser implements UseCase<ManagedUser, UserDraft> {
  const CreateUser(this._repository);

  final UsersRepository _repository;

  @override
  Future<ManagedUser> call(UserDraft draft) => _repository.createUser(draft);
}

class UpdateUserParams {
  const UpdateUserParams({required this.id, required this.draft, this.roleIds});

  final String id;
  final UserDraft draft;

  /// When set and different from the current roles, they are replaced too.
  final List<String>? roleIds;
}

/// Saves the profile, then the roles if they changed (separate endpoint).
class UpdateUser implements UseCase<ManagedUser, UpdateUserParams> {
  const UpdateUser(this._repository);

  final UsersRepository _repository;

  @override
  Future<ManagedUser> call(UpdateUserParams params) async {
    var user = await _repository.updateUser(params.id, params.draft);
    final wanted = params.roleIds;
    if (wanted != null &&
        !_sameIds(wanted, user.roles.map((r) => r.id).toList())) {
      user = await _repository.setRoles(params.id, wanted);
    }
    return user;
  }

  static bool _sameIds(List<String> a, List<String> b) =>
      a.length == b.length && a.toSet().containsAll(b);
}

class SetUserActiveParams {
  const SetUserActiveParams({required this.id, required this.active});

  final String id;
  final bool active;
}

class SetUserActive implements UseCase<ManagedUser, SetUserActiveParams> {
  const SetUserActive(this._repository);

  final UsersRepository _repository;

  @override
  Future<ManagedUser> call(SetUserActiveParams params) =>
      _repository.setActive(params.id, active: params.active);
}

/// Roles for pickers and the roles screen: base roles first, then custom.
class GetRoles implements UseCase<List<RoleInfo>, NoParams> {
  const GetRoles(this._repository);

  final RolesRepository _repository;

  static const _order = [
    'owner',
    'account_manager',
    'supervisor',
    'crew',
    'client',
  ];

  @override
  Future<List<RoleInfo>> call(NoParams params) async {
    final roles = await _repository.getRoles();
    int rank(RoleInfo r) {
      final i = _order.indexOf(r.name);
      return i < 0 ? _order.length : i;
    }

    return [...roles]..sort((a, b) {
      final byRank = rank(a).compareTo(rank(b));
      return byRank != 0 ? byRank : a.name.compareTo(b.name);
    });
  }
}

class SaveRoleParams {
  const SaveRoleParams({this.id, required this.name, this.description});

  /// `null` creates a new role.
  final String? id;
  final String name;
  final String? description;
}

class SaveRole implements UseCase<RoleInfo, SaveRoleParams> {
  const SaveRole(this._repository);

  final RolesRepository _repository;

  @override
  Future<RoleInfo> call(SaveRoleParams params) {
    final name = params.name.trim().toLowerCase();
    final description = params.description?.trim();
    final id = params.id;
    return id == null
        ? _repository.createRole(name: name, description: description)
        : _repository.updateRole(id, name: name, description: description);
  }
}

class DeleteRole implements UseCase<void, String> {
  const DeleteRole(this._repository);

  final RolesRepository _repository;

  @override
  Future<void> call(String id) => _repository.deleteRole(id);
}
