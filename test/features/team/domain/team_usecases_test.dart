import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/team/domain/entities/member.dart';
import 'package:sp_cln_app/features/team/domain/usecases/team_usecases.dart';

import '../../../helpers/test_app.dart';

const _marco = Member(
  userId: 'm1',
  clientId: 'c1',
  name: 'Marco Díaz',
  email: 'marco@example.com',
  baseRole: 'supervisor',
  permissions: {'info.view', 'jobs.view', 'jobs.edit', 'team.view'},
  overrides: {'jobs.assign': false},
);

void main() {
  group('PermissionCatalog', () {
    test('groups permissions by area, in order', () {
      expect(testCatalog.byModule, {
        'info': ['info.view', 'info.edit'],
        'jobs': ['jobs.view', 'jobs.edit', 'jobs.assign'],
        'team': ['team.view'],
      });
    });

    test('overrides are only what differs from the role', () {
      expect(testCatalog.overridesFor('crew', {'jobs.view', 'jobs.edit'}), {
        'jobs.edit': true,
      });
      expect(testCatalog.overridesFor('crew', {'info.view'}), {
        'info.view': true,
        'jobs.view': false,
      });
      expect(testCatalog.overridesFor('crew', {'jobs.view'}), isEmpty);
    });

    test('turning an action on also turns on its view', () {
      expect(testCatalog.toggled({}, 'jobs.assign'), {
        'jobs.assign',
        'jobs.view',
      });
    });

    test('turning view off turns off the whole area', () {
      expect(
        testCatalog.toggled({
          'info.view',
          'jobs.view',
          'jobs.edit',
        }, 'jobs.view'),
        {'info.view'},
      );
      expect(testCatalog.toggled({'jobs.view', 'jobs.edit'}, 'jobs.edit'), {
        'jobs.view',
      });
    });
  });

  test('suggests the most senior base role a user already has', () {
    final roles = testCatalog.roles;
    expect(
      TeamPolicy.suggestedRole(['crew', 'supervisor'], roles, external: false),
      'supervisor',
    );
    expect(
      TeamPolicy.suggestedRole(['floor_lead'], roles, external: false),
      'crew',
    );
    expect(TeamPolicy.suggestedRole([], roles, external: true), 'client');
  });

  group('UpdateMemberAccess', () {
    late FakeTeamRepository repo;
    setUp(() => repo = FakeTeamRepository([_marco]));

    Future<Member> update(String role, Set<String> permissions) =>
        UpdateMemberAccess(repo)(
          UpdateAccessParams(
            member: _marco,
            catalog: testCatalog,
            baseRole: role,
            permissions: permissions,
          ),
        );

    test('saves nothing when nothing changed', () async {
      await update('supervisor', _marco.permissions);
      expect(repo.writes, isEmpty);
    });

    test('sends only the new overrides for the same role', () async {
      final saved = await update('supervisor', {
        ...testCatalog.defaultsFor('supervisor'),
      });
      expect(repo.writes, ['overrides:m1:{}']);
      expect(saved.hasCustomAccess, isFalse);
    });

    test('a new role goes first, then clears the old overrides', () async {
      final saved = await update('crew', testCatalog.defaultsFor('crew'));
      expect(repo.writes, ['member:m1:crew', 'overrides:m1:{}']);
      expect(saved.baseRole, 'crew');
      expect(saved.permissions, {'jobs.view'});
    });
  });
}
