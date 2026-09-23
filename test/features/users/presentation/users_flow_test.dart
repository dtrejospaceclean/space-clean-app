import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/core/error/failures.dart';
import 'package:sp_cln_app/features/auth/domain/entities/user.dart';

import '../../../helpers/test_app.dart';

Future<void> openUsers(
  WidgetTester tester,
  User user, {
  FakeUsersRepository? users,
}) async {
  await pumpApp(
    tester,
    auth: FakeAuthRepository(sessionUser: user),
    users: users,
  );
  await tester.tap(find.text('Me'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Users'));
  await tester.pumpAndSettle();
}

/// The Material text field labeled [label].
Finder formField(String label) =>
    find.widgetWithText(TextFormField, label).first;

void main() {
  testWidgets('people without an admin role see no Administration', (
    tester,
  ) async {
    await pumpApp(tester, auth: FakeAuthRepository(sessionUser: ana));
    await tester.tap(find.text('Me'));
    await tester.pumpAndSettle();

    expect(find.text('Administration'), findsNothing);
    expect(find.text('Users'), findsNothing);
  });

  testWidgets('owners list active users and can filter to inactive', (
    tester,
  ) async {
    await openUsers(tester, owner);

    expect(find.text('Ana Pérez'), findsOneWidget);
    expect(find.text('Luis Gómez'), findsNothing);
    expect(find.byTooltip('Add user'), findsOneWidget);

    await tester.tap(find.text('Inactive'));
    await tester.pumpAndSettle();

    expect(find.text('Luis Gómez'), findsOneWidget);
    expect(find.text('Ana Pérez'), findsNothing);
  });

  testWidgets('account managers can look but not change', (tester) async {
    await openUsers(tester, accountManager);

    expect(find.byTooltip('Add user'), findsNothing);
    await tester.tap(find.text('Ana Pérez'));
    await tester.pumpAndSettle();

    expect(
      find.text('Only owners can change users and roles.'),
      findsOneWidget,
    );
    expect(find.text('Part-time'), findsOneWidget);
    expect(find.text('\$18.5'), findsOneWidget);
    expect(find.text('Deactivate user'), findsNothing);
    expect(find.byTooltip('Edit user'), findsNothing);
  });

  testWidgets('an owner creates a user with a role', (tester) async {
    final users = FakeUsersRepository();
    await openUsers(tester, owner, users: users);

    await tester.tap(find.byTooltip('Add user'));
    await tester.pumpAndSettle();
    await tester.enterText(formField('Full name'), 'Rosa Vega');
    await tester.enterText(formField('Email'), 'rosa@example.com');
    await tester.enterText(formField('Password'), 'short');
    await tester.tap(find.text('Crew'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Too-short password is caught before calling the API.
    expect(find.text('Must be at least 12 characters.'), findsOneWidget);
    expect(users.writes, isEmpty);

    await tester.enterText(formField('Password'), 'a-long-first-password');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(users.writes, ['create:rosa@example.com:[r-crew]']);
    // Lands on the new user's page.
    expect(find.text('rosa@example.com'), findsOneWidget);
  });

  testWidgets('a taken email is shown on the email field', (tester) async {
    final users = FakeUsersRepository()
      ..createError = const ServerFailure('users.email_taken', statusCode: 409);
    await openUsers(tester, owner, users: users);

    await tester.tap(find.byTooltip('Add user'));
    await tester.pumpAndSettle();
    await tester.enterText(formField('Full name'), 'Rosa Vega');
    await tester.enterText(formField('Email'), 'ana@example.com');
    await tester.enterText(formField('Password'), 'a-long-first-password');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Another user already has this email.'), findsOneWidget);
  });

  testWidgets('an owner deactivates a user after confirming', (tester) async {
    final users = FakeUsersRepository();
    await openUsers(tester, owner, users: users);

    await tester.tap(find.text('Ana Pérez'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Deactivate user'), 200);
    await tester.tap(find.text('Deactivate user'));
    await tester.pumpAndSettle();
    expect(find.text('Deactivate Ana Pérez?'), findsOneWidget);

    await tester.tap(find.text('Deactivate'));
    await tester.pumpAndSettle();

    expect(users.writes, ['active:u1:false']);
    expect(
      find.text("This user is deactivated and can't sign in."),
      findsOneWidget,
    );
  });

  testWidgets('roles show counts and lock the built-in ones', (tester) async {
    final roles = FakeRolesRepository();
    await pumpApp(
      tester,
      auth: FakeAuthRepository(sessionUser: owner),
      roles: roles,
    );
    await tester.tap(find.text('Me'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Roles'));
    await tester.pumpAndSettle();

    expect(find.text('3 users'), findsOneWidget);
    expect(find.textContaining('Built-in'), findsNWidgets(5));

    // Built-in roles don't open an editor; custom ones do.
    await tester.tap(find.text('Crew'));
    await tester.pumpAndSettle();
    expect(find.text('Edit role'), findsNothing);

    await tester.tap(find.text('floor_lead'));
    await tester.pumpAndSettle();
    expect(find.text('Edit role'), findsOneWidget);
    await tester.tap(find.text('Delete role'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(roles.writes, ['delete:r-lead']);
    expect(find.text('floor_lead'), findsNothing);
  });
}
