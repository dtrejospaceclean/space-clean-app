import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/paginated.dart';
import '../../domain/entities/managed_user.dart';
import '../../domain/entities/role_info.dart';
import '../../domain/repositories/users_repository.dart';
import '../models/user_models.dart';

Future<T> _guard<T>(Future<T> Function() action) async {
  try {
    return await action();
  } on ApiException catch (e) {
    throw e.toFailure();
  }
}

Map<String, dynamic> _map(Object? data) =>
    (data! as Map).cast<String, dynamic>();

/// `/users`.
class UsersRepositoryImpl implements UsersRepository {
  const UsersRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<List<ManagedUser>> getUsers(UserQuery query) => _guard(() async {
    final items = await fetchAllPages(
      _api,
      '/users',
      query: {
        if (query.search.trim().isNotEmpty) 'search': query.search.trim(),
        if (query.isActive case final active?) 'isActive': '$active',
        'roleId': ?query.roleId,
      },
    );
    return items.map(ManagedUserModel.fromJson).toList();
  });

  @override
  Future<ManagedUser> getUser(String id) => _guard(
    () async => ManagedUserModel.fromJson(_map(await _api.get('/users/$id'))),
  );

  @override
  Future<ManagedUser> createUser(UserDraft draft) => _guard(
    () async => ManagedUserModel.fromJson(
      _map(
        await _api.post(
          '/users',
          body: UserDraftModel.toJson(draft, create: true),
        ),
      ),
    ),
  );

  @override
  Future<ManagedUser> updateUser(String id, UserDraft draft) => _guard(
    () async => ManagedUserModel.fromJson(
      _map(
        await _api.patch(
          '/users/$id',
          body: UserDraftModel.toJson(draft, create: false),
        ),
      ),
    ),
  );

  @override
  Future<ManagedUser> setActive(String id, {required bool active}) => _guard(
    () async => ManagedUserModel.fromJson(
      _map(await _api.patch('/users/$id', body: {'isActive': active})),
    ),
  );

  @override
  Future<ManagedUser> setRoles(String id, List<String> roleIds) => _guard(
    () async => ManagedUserModel.fromJson(
      _map(await _api.put('/users/$id/roles', body: {'roleIds': roleIds})),
    ),
  );
}

/// `/roles` (not paginated).
class RolesRepositoryImpl implements RolesRepository {
  const RolesRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<List<RoleInfo>> getRoles() => _guard(() async {
    final data = await _api.get('/roles');
    final list = data is Map ? data['items'] as List : data! as List;
    return [for (final r in list) RoleInfoModel.fromJson(_map(r))];
  });

  @override
  Future<RoleInfo> createRole({required String name, String? description}) =>
      _guard(
        () async => RoleInfoModel.fromJson(
          _map(
            await _api.post(
              '/roles',
              body: {
                'name': name,
                if (description != null && description.isNotEmpty)
                  'description': description,
              },
            ),
          ),
        ),
      );

  @override
  Future<RoleInfo> updateRole(String id, {String? name, String? description}) =>
      _guard(
        () async => RoleInfoModel.fromJson(
          _map(
            await _api.patch(
              '/roles/$id',
              body: {
                'name': ?name,
                // Empty clears the description.
                if (description != null)
                  'description': description.isEmpty ? null : description,
              },
            ),
          ),
        ),
      );

  @override
  Future<void> deleteRole(String id) =>
      _guard(() async => await _api.delete('/roles/$id'));
}
