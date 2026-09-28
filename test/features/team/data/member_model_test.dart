import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/team/data/models/member_model.dart';

void main() {
  test('reads a member with effective permissions and overrides', () {
    final member = MemberModel.fromJson({
      'userId': 'u1',
      'clientAccountId': 'c1',
      'baseRole': 'account_manager',
      'user': {
        'id': 'u1',
        'name': 'Carlos Medina',
        'email': 'carlos@example.com',
        'isActive': true,
      },
      'permissions': {
        'info.view': true,
        'contract.view': true,
        'contract.download': true,
        'scope.edit': false,
      },
      'overrides': {'contract.download': true},
    });

    expect(member.name, 'Carlos Medina');
    expect(member.baseRole, 'account_manager');
    expect(member.permissions, {
      'info.view',
      'contract.view',
      'contract.download',
    });
    expect(member.overrides, {'contract.download': true});
    expect(member.hasCustomAccess, isTrue);
  });

  test('reads the permission catalog', () {
    final catalog = PermissionCatalogModel.fromJson({
      'permissions': ['info.view', 'info.edit', 'jobs.view'],
      'defaultsByRole': {
        'owner': {'info.view': true, 'info.edit': true, 'jobs.view': true},
        'crew': {'jobs.view': true},
      },
    });

    expect(catalog.roles, ['owner', 'crew']);
    expect(catalog.defaultsFor('crew'), {'jobs.view'});
    expect(catalog.defaultsFor('unknown'), isEmpty);
  });
}
