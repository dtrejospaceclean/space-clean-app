import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/core/error/failures.dart';
import 'package:sp_cln_app/core/usecase/usecase.dart';
import 'package:sp_cln_app/features/users/domain/entities/managed_user.dart';
import 'package:sp_cln_app/features/users/domain/entities/role_info.dart';
import 'package:sp_cln_app/features/users/domain/usecases/user_usecases.dart';

import '../../../helpers/test_app.dart';

void main() {
  test('only owners edit; owners and account managers view', () {
    expect(UserAdminPolicy.canEdit(owner), isTrue);
    expect(UserAdminPolicy.canView(accountManager), isTrue);
    expect(UserAdminPolicy.canEdit(accountManager), isFalse);
    expect(UserAdminPolicy.canView(ana), isFalse);
  });

  test('lists active users first, then by name', () async {
    final users = await GetUsers(FakeUsersRepository())(
      const UserQuery(isActive: null),
    );

    expect(users.map((u) => u.name), ['Ana Pérez', 'Luis Gómez']);
    expect(users.last.isActive, isFalse);
  });

  group('UpdateUser', () {
    test('replaces roles only when they changed', () async {
      final repo = FakeUsersRepository();

      await UpdateUser(repo)(
        const UpdateUserParams(
          id: 'u1',
          draft: UserDraft(name: 'Ana'),
          roleIds: ['r-sup'],
        ),
      );
      expect(repo.writes, ['update:u1']);

      await UpdateUser(repo)(
        const UpdateUserParams(
          id: 'u1',
          draft: UserDraft(name: 'Ana'),
          roleIds: ['r-sup', 'r-crew'],
        ),
      );
      expect(repo.writes.last, 'roles:u1:[r-sup, r-crew]');
    });
  });

  test('built-in roles come first, in their usual order', () async {
    final repo = FakeRolesRepository()
      ..roles = [
        const RoleInfo(id: 'x', name: 'floor_lead'),
        ...testRoles.where((r) => r.name != 'floor_lead').toList().reversed,
      ];

    final roles = await GetRoles(repo)(const NoParams());

    expect(roles.map((r) => r.name), [
      'owner',
      'account_manager',
      'supervisor',
      'crew',
      'client',
      'floor_lead',
    ]);
  });

  test('role names are normalized before saving', () async {
    final repo = FakeRolesRepository();

    await SaveRole(repo)(const SaveRoleParams(name: ' Night_Lead '));

    expect(repo.writes, ['create:night_lead']);
  });

  test('built-in and assigned roles cannot be deleted', () {
    expect(const RoleInfo(id: '1', name: 'crew').isDeletable, isFalse);
    expect(
      const RoleInfo(id: '2', name: 'floor_lead', userCount: 2).isDeletable,
      isFalse,
    );
    expect(const RoleInfo(id: '3', name: 'floor_lead').isDeletable, isTrue);
  });

  group('SetUserActive', () {
    test('refuses to deactivate the signed-in user', () async {
      final repo = FakeUsersRepository();

      await expectLater(
        SetUserActive(repo)(
          const SetUserActiveParams(id: 'o1', active: false, actor: owner),
        ),
        throwsA(
          isA<RuleFailure>().having(
            (f) => f.messageKey,
            'messageKey',
            'users.cannot_deactivate_self',
          ),
        ),
      );
      expect(repo.writes, isEmpty);
    });

    test('deactivates someone else', () async {
      final repo = FakeUsersRepository();

      await SetUserActive(repo)(
        const SetUserActiveParams(id: 'u1', active: false, actor: owner),
      );

      expect(repo.writes, ['active:u1:false']);
    });
  });
}
