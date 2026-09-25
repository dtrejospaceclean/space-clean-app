import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/access/domain/entities/account_access.dart';
import 'package:sp_cln_app/features/clients/presentation/account_modules.dart';

void main() {
  test('lists only allowed modules, grouped in screen order', () {
    final sections = visibleModules(
      const AccountAccess(
        clientId: 'c1',
        permissions: {Permissions.infoView, Permissions.jobsView},
      ),
    );

    expect(sections.keys, [AccountSection.work, AccountSection.account]);
    expect(sections[AccountSection.work]!.map((m) => m.route), ['jobs']);
    expect(sections[AccountSection.account]!.map((m) => m.route), ['info']);
  });

  test('leaves out sections with nothing allowed', () {
    final sections = visibleModules(
      const AccountAccess(clientId: 'c1', permissions: {Permissions.jobsView}),
    );

    expect(sections.keys, [AccountSection.work]);
  });

  test('a global owner sees every module', () {
    final sections = visibleModules(const AccountAccess.owner('c1'));

    expect(sections.values.expand((m) => m).length, accountModules.length);
  });
}
