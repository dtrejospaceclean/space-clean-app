import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/access/domain/entities/account_access.dart';
import 'package:sp_cln_app/features/auth/domain/entities/user.dart';
import 'package:sp_cln_app/features/clients/domain/entities/client.dart';
import 'package:sp_cln_app/features/contacts/domain/entities/contact.dart';

import '../../../helpers/test_app.dart';

const _tower = Client(
  id: 'c1',
  legalName: 'Torre Norte S.A.',
  dba: 'Torre Norte',
  status: ClientStatus.active,
);

const _laura = Contact(
  id: 'k1',
  clientId: 'c1',
  firstName: 'Laura',
  lastName: 'Gómez',
  title: 'Facilities Manager',
  email: 'laura@torrenorte.com',
  isPrimary: true,
);

const _pedro = Contact(
  id: 'k2',
  clientId: 'c1',
  firstName: 'Pedro',
  lastName: 'Ibarra',
  isBillingContact: true,
);

/// Opens Torre Norte → Contacts as [user]. Owners bypass membership;
/// everyone else gets [permissions] on the account.
Future<FakeContactsRepository> openContacts(
  WidgetTester tester,
  User user, {
  Set<String> permissions = const {Permissions.infoView},
  List<Contact> contacts = const [_laura, _pedro],
  FakeContactsRepository? repository,
}) async {
  final repo = repository ?? FakeContactsRepository(contacts);
  await pumpApp(
    tester,
    auth: FakeAuthRepository(sessionUser: user),
    clients: FakeClientsRepository([_tower]),
    contacts: repo,
    access: FakeAccessRepository({
      'c1': AccountAccess(
        clientId: 'c1',
        baseRole: 'supervisor',
        permissions: permissions,
      ),
    }),
  );
  await tester.tap(find.byTooltip('Accounts'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Torre Norte'));
  await tester.pumpAndSettle();
  await revealBelow(tester, find.text('Contacts'));
  await tester.tap(find.text('Contacts'));
  await tester.pumpAndSettle();
  return repo;
}

Future<void> openContact(WidgetTester tester, String name) async {
  await tester.tap(find.text(name));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a member who can only view reads contacts', (tester) async {
    final contacts = await openContacts(tester, ana);

    // Primary first, with what each one is to the account.
    expect(find.text('Facilities Manager · Primary'), findsOneWidget);
    expect(find.text('Billing'), findsOneWidget);
    expect(find.byTooltip('Create'), findsNothing);

    await openContact(tester, 'Laura Gómez');
    expect(find.text('laura@torrenorte.com'), findsOneWidget);
    expect(find.byTooltip('Edit contact'), findsNothing);
    expect(find.text('Delete contact'), findsNothing);
    // Only owners hand out logins.
    expect(find.text('Give a login'), findsNothing);
    expect(contacts.writes, isEmpty);
  });

  testWidgets('an editor adds a contact from "+"', (tester) async {
    final contacts = await openContacts(
      tester,
      accountManager,
      permissions: {Permissions.infoView, Permissions.infoEdit},
    );

    await tester.tap(find.byTooltip('Create'));
    await tester.pumpAndSettle();
    expect(find.text('New contact'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('This field is required.'), findsNWidgets(2));

    await tester.enterText(field('First name'), 'Sofía');
    await tester.enterText(field('Last name'), 'Reyes');
    await tester.enterText(field('Email'), 'not-an-email');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(contacts.writes, isEmpty);

    await tester.enterText(field('Email'), 'sofia@torrenorte.com');
    await revealBelow(tester, find.text('Primary'));
    await tester.tap(find.text('Primary'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(contacts.writes, ['create:Sofía']);
    expect(contacts.drafts.single.isPrimary, isTrue);
    // Back on the list: Sofía took "Primary" from Laura.
    expect(find.text('Sofía Reyes'), findsOneWidget);
    expect(find.text('Primary'), findsOneWidget);
    expect(find.text('Facilities Manager'), findsOneWidget);
  });

  testWidgets('an editor edits a contact and clears a field', (tester) async {
    final contacts = await openContacts(
      tester,
      accountManager,
      permissions: {Permissions.infoView, Permissions.infoEdit},
    );
    await openContact(tester, 'Laura Gómez');

    await tester.tap(find.byTooltip('Edit contact'));
    await tester.pumpAndSettle();
    await tester.enterText(field('Job title'), '');
    await tester.enterText(field('Phone'), '+52 55 5555 5555');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(contacts.writes, ['update:k1']);
    expect(contacts.drafts.single.isPrimary, isTrue);
    expect(find.text('+52 55 5555 5555'), findsOneWidget);
    expect(find.text('Facilities Manager'), findsNothing);
  });

  testWidgets('deleting a contact with a login warns that it stays', (
    tester,
  ) async {
    const withLogin = Contact(
      id: 'k3',
      clientId: 'c1',
      firstName: 'Irma',
      lastName: 'Luna',
      email: 'irma@torrenorte.com',
      userId: 'u-k3',
    );
    final contacts = await openContacts(
      tester,
      owner,
      contacts: [_laura, withLogin],
    );
    await openContact(tester, 'Irma Luna');
    expect(find.text('Has a login'), findsOneWidget);

    await revealBelow(tester, find.text('Delete contact'));
    await tester.tap(find.text('Delete contact'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Their login stays'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(contacts.writes, ['delete:k3']);
    expect(find.text('Irma Luna'), findsNothing);
    expect(find.text('Laura Gómez'), findsOneWidget);
  });

  testWidgets('an owner gives a contact a login', (tester) async {
    final contacts = await openContacts(tester, owner);
    await openContact(tester, 'Laura Gómez');

    await revealBelow(tester, find.text('Give a login'));
    expect(find.text('Will sign in with laura@torrenorte.com'), findsOneWidget);
    await tester.tap(find.text('Give a login'));
    await tester.pumpAndSettle();

    await tester.enterText(field('Password'), 'short');
    await tester.tap(button('Give a login'));
    await tester.pumpAndSettle();
    expect(find.text('Must be at least 12 characters.'), findsOneWidget);
    expect(contacts.writes, isEmpty);

    await tester.enterText(field('Password'), 'a long enough secret');
    await tester.tap(button('Give a login'));
    await tester.pumpAndSettle();

    expect(contacts.writes, ['login:k1']);
    expect(find.text('Login created'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    await revealBelow(tester, find.text('Has a login'));
    expect(find.text('Give a login'), findsNothing);
  });

  testWidgets('a login needs the contact\'s email first', (tester) async {
    await openContacts(tester, owner);
    await openContact(tester, 'Pedro Ibarra');

    await revealBelow(tester, find.text('Add an email to this contact first'));
    await tester.tap(find.text('Give a login'));
    await tester.pumpAndSettle();
    // Not tappable: still on the contact.
    expect(find.text('Contact'), findsWidgets);
    expect(find.byType(TextFormField), findsNothing);
  });

  testWidgets('a taken email shows on the login form', (tester) async {
    final contacts = await openContacts(
      tester,
      owner,
      repository: FakeContactsRepository([_laura])..emailTaken.add('k1'),
    );
    await openContact(tester, 'Laura Gómez');
    await revealBelow(tester, find.text('Give a login'));
    await tester.tap(find.text('Give a login'));
    await tester.pumpAndSettle();

    await tester.enterText(field('Password'), 'a long enough secret');
    await tester.tap(button('Give a login'));
    await tester.pumpAndSettle();

    expect(find.text('Another user already has this email.'), findsOneWidget);
    expect(contacts.writes, isEmpty);
  });
}
