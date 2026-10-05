import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/access/domain/entities/account_access.dart';
import 'package:sp_cln_app/features/clients/presentation/account_modules.dart';

List<String> routes(List<AccountModule> modules) =>
    modules.map((m) => m.route).toList();

void main() {
  const infoAndJobs = AccountAccess(
    clientId: 'c1',
    permissions: {Permissions.infoView, Permissions.jobsView},
  );

  test('lists only allowed modules, work first by default', () {
    expect(routes(orderedModules(infoAndJobs, const [])), [
      'jobs',
      'info',
      'contacts',
      'locations',
    ]);
  });

  test('a global owner sees every module', () {
    expect(
      orderedModules(const AccountAccess.owner('c1'), const []).length,
      accountModules.length,
    );
  });

  test('follows the saved order; unknown routes drop, new ones go last', () {
    expect(
      routes(orderedModules(infoAndJobs, const ['locations', 'gone', 'info'])),
      ['locations', 'info', 'jobs', 'contacts'],
    );
  });

  test('reordering what is visible keeps hidden modules in place', () {
    // Proposals, contracts and team are hidden here; they keep their slots.
    final order = reorderVisible(const [], const [
      'locations',
      'jobs',
      'info',
      'contacts',
    ]);
    expect(order, [
      'locations',
      'proposals',
      'contracts',
      'jobs',
      'info',
      'contacts',
      'team',
    ]);
    expect(routes(orderedModules(infoAndJobs, order)), [
      'locations',
      'jobs',
      'info',
      'contacts',
    ]);
  });
}
