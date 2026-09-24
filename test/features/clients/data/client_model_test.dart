import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/clients/data/models/client_model.dart';
import 'package:sp_cln_app/features/clients/domain/entities/client.dart';

void main() {
  test('reads a single account with its people in charge', () {
    final client = ClientModel.fromJson({
      'id': 'c1',
      'legalName': 'Torre Norte S.A.',
      'dba': 'Torre Norte',
      'status': 'active',
      'industry': 'Offices',
      'billingCity': 'Monterrey',
      'accountManager': {'id': 'm1', 'name': 'Marco Díaz', 'email': 'm@x.com'},
      'supervisor': null,
      'contacts': [{}, {}],
    });

    expect(client.status, ClientStatus.active);
    expect(client.displayName, 'Torre Norte');
    expect(client.accountManager?.name, 'Marco Díaz');
    expect(client.supervisor, isNull);
    expect(client.contactCount, 2);
    expect(client.billingCity, 'Monterrey');
  });

  test('a new account sends only the fields that were filled in', () {
    final body = ClientDraftModel.toJson(
      const ClientDraft(
        legalName: '  Torre Norte S.A. ',
        dba: '',
        status: ClientStatus.prospect,
        billingZip: '64000',
        cleared: {'dba'},
      ),
      create: true,
    );

    expect(body, {
      'legalName': 'Torre Norte S.A.',
      'status': 'prospect',
      'billingZip': '64000',
    });
  });

  test('an update sends emptied fields as null to clear them', () {
    final body = ClientDraftModel.toJson(
      const ClientDraft(
        legalName: 'Torre Norte S.A.',
        supervisorUserId: 's1',
        cleared: {'dba', 'accountManagerUserId'},
      ),
      create: false,
    );

    expect(body, {
      'legalName': 'Torre Norte S.A.',
      'supervisorUserId': 's1',
      'dba': null,
      'accountManagerUserId': null,
    });
  });
}
