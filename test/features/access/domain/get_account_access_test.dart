import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/access/domain/entities/account_access.dart';
import 'package:sp_cln_app/features/access/domain/usecases/get_account_access.dart';
import 'package:sp_cln_app/features/auth/domain/entities/user.dart';

import '../../../helpers/test_app.dart';

const _owner = User(
  id: 'o1',
  email: 'owner@example.com',
  name: 'Olga',
  userType: UserType.internal,
  isActive: true,
  roles: [Role(id: 'r0', name: GlobalRole.owner)],
);

void main() {
  test('a global owner may do everything without a membership', () async {
    final access = await GetAccountAccess(FakeAccessRepository())(
      const AccountAccessParams(clientId: 'c1', user: _owner),
    );

    expect(access.can(Permissions.teamView), isTrue);
    expect(access.can('anything.else'), isTrue);
  });

  test('a member gets exactly their effective permissions', () async {
    final access = await GetAccountAccess(
      FakeAccessRepository({
        'c1': const AccountAccess(
          clientId: 'c1',
          baseRole: 'crew',
          permissions: {Permissions.jobsView, Permissions.calendarView},
        ),
      }),
    )(const AccountAccessParams(clientId: 'c1', user: ana));

    expect(access.baseRole, 'crew');
    expect(access.can(Permissions.jobsView), isTrue);
    expect(access.can(Permissions.teamView), isFalse);
  });

  test('a non-member gets nothing', () async {
    final access = await GetAccountAccess(FakeAccessRepository())(
      const AccountAccessParams(clientId: 'c1', user: ana),
    );

    expect(access.can(Permissions.jobsView), isFalse);
  });

  test('crew who cannot read the team get their role defaults', () async {
    const crew = User(
      id: 'u9',
      email: 'luis@example.com',
      name: 'Luis',
      userType: UserType.internal,
      isActive: true,
      roles: [Role(id: 'r4', name: GlobalRole.crew)],
    );
    final access = await GetAccountAccess(
      FakeAccessRepository()..forbidden = {'c1'},
    )(const AccountAccessParams(clientId: 'c1', user: crew));

    expect(access.estimated, isTrue);
    expect(access.baseRole, 'crew');
    expect(access.can(Permissions.jobsView), isTrue);
    expect(access.can(Permissions.teamView), isFalse);
    expect(access.can(Permissions.infoView), isFalse);
  });
}
