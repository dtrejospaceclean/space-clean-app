import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/profile/presentation/admin_modules.dart';

import '../../../helpers/test_app.dart';

void main() {
  test('owners and account managers get users, roles and services', () {
    expect(visibleAdminModules(accountManager).map((m) => m.path), [
      '/me/users',
      '/me/roles',
      '/me/services',
    ]);
  });

  test('owners also get the WhatsApp tickets', () {
    expect(visibleAdminModules(owner).map((m) => m.path), [
      '/me/users',
      '/me/roles',
      '/me/services',
      '/me/whatsapp',
    ]);
  });

  test('everyone else gets no administration', () {
    expect(visibleAdminModules(ana), isEmpty);
  });
}
