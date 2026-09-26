import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/profile/presentation/admin_modules.dart';

import '../../../helpers/test_app.dart';

void main() {
  test('owners and account managers get users, roles and services', () {
    for (final user in [owner, accountManager]) {
      expect(visibleAdminModules(user).map((m) => m.path), [
        '/me/users',
        '/me/roles',
        '/me/services',
      ]);
    }
  });

  test('everyone else gets no administration', () {
    expect(visibleAdminModules(ana), isEmpty);
  });
}
