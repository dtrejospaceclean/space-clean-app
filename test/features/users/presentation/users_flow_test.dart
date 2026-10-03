import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/core/error/failures.dart';
import 'package:sp_cln_app/features/auth/domain/entities/user.dart';
import 'package:sp_cln_app/features/users/domain/entities/managed_user.dart';

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
  await tester.tap(find.byTooltip('Me'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Users'));
  await tester.pumpAndSettle();
}

/// The app goes to the background and comes back.
void returnToApp(WidgetTester tester) {
  for (final state in [
    AppLifecycleState.inactive,
    AppLifecycleState.hidden,
    AppLifecycleState.paused,
    AppLifecycleState.hidden,
    AppLifecycleState.inactive,
    AppLifecycleState.resumed,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(state);
  }
}

void main() {
  testWidgets('people without an admin role see no Administration', (
    tester,
  ) async {
    await pumpApp(tester, auth: FakeAuthRepository(sessionUser: ana));
    await tester.tap(find.byTooltip('Me'));
    await tester.pumpAndSettle();

    expect(find.text('Administration'), findsNothing);
    expect(find.text('Users'), findsNothing);
  });

  testWidgets('owners see everyone, active first, each marked', (tester) async {
    await openUsers(tester, owner);

    // No status filter: active and deactivated in one list.
    expect(find.text('All'), findsNothing);
    expect(find.text('Ana Pérez'), findsOneWidget);
    expect(find.text('Luis Gómez'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Ana Pérez')).dy,
      lessThan(tester.getTopLeft(find.text('Luis Gómez')).dy),
    );
    expect(find.byTooltip('Active'), findsOneWidget);
    expect(find.byTooltip('Inactive'), findsOneWidget);
    expect(find.byTooltip('Create'), findsOneWidget);
    // Rows show the email only, not the roles.
    expect(find.text('ana@example.com'), findsOneWidget);
    expect(find.textContaining('Supervisor'), findsNothing);
  });

  testWidgets('the search shows a spinner until the results are in', (
    tester,
  ) async {
    final users = FakeUsersRepository()..searchGate = Completer();
    await openUsers(tester, owner, users: users);
    final spinner = find.bySemanticsLabel('Searching…');
    expect(spinner, findsNothing);

    await tester.enterText(find.byType(TextField), 'ana');
    await tester.pump();
    // Waiting out the debounce.
    expect(spinner, findsOneWidget);

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    // Sent, and the server hasn't answered.
    expect(spinner, findsOneWidget);

    users.searchGate!.complete();
    await tester.pumpAndSettle();
    expect(spinner, findsNothing);
    expect(find.text('Ana Pérez'), findsOneWidget);
  });

  testWidgets("owners can't deactivate themselves", (tester) async {
    final users = FakeUsersRepository([
      ...FakeUsersRepository().users,
      const ManagedUser(
        id: 'o1',
        email: 'olga@example.com',
        name: 'Olga Ruiz',
        userType: UserType.internal,
        isActive: true,
        roles: [Role(id: 'r-owner', name: 'owner')],
      ),
    ]);
    await openUsers(tester, owner, users: users);

    await tester.tap(find.text('Olga Ruiz'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.textContaining('This is your account'),
      200,
      scrollable: find.byType(Scrollable).last,
    );

    expect(find.text('Deactivate user'), findsNothing);
  });

  testWidgets('account managers can look but not change', (tester) async {
    await openUsers(tester, accountManager);

    expect(find.byTooltip('Create'), findsNothing);
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

    await tester.tap(find.byTooltip('Create'));
    await tester.pumpAndSettle();
    await tester.enterText(field('Full name'), 'Rosa Vega');
    await tester.enterText(field('Email'), 'rosa@example.com');
    await tester.enterText(field('Password'), 'short');
    // Roles sit further down the form.
    await tester.ensureVisible(find.text('Crew'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Crew'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Too-short password is caught before calling the API.
    expect(find.text('Must be at least 12 characters.'), findsOneWidget);
    expect(users.writes, isEmpty);

    await tester.enterText(field('Password'), 'a-long-first-password');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(users.writes, ['create:rosa@example.com:[r-crew]']);
    // Lands on the new user's page (profile card and contact list).
    expect(find.text('Rosa Vega'), findsOneWidget);
    expect(find.text('rosa@example.com'), findsWidgets);
  });

  testWidgets('a taken email is shown on the email field', (tester) async {
    final users = FakeUsersRepository()
      ..createError = const ServerFailure('users.email_taken', statusCode: 409);
    await openUsers(tester, owner, users: users);

    await tester.tap(find.byTooltip('Create'));
    await tester.pumpAndSettle();
    await tester.enterText(field('Full name'), 'Rosa Vega');
    await tester.enterText(field('Email'), 'ana@example.com');
    await tester.enterText(field('Password'), 'a-long-first-password');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Another user already has this email.'), findsOneWidget);
  });

  testWidgets(
    'back from the background, the list shows users added elsewhere',
    (tester) async {
      final users = FakeUsersRepository();
      await openUsers(tester, owner, users: users);
      expect(find.text('Rosa Lima'), findsNothing);

      users.users.add(
        const ManagedUser(
          id: 'u3',
          email: 'rosa@example.com',
          name: 'Rosa Lima',
          userType: UserType.internal,
          isActive: true,
          roles: [],
        ),
      );
      returnToApp(tester);
      await tester.pumpAndSettle();

      expect(find.text('Rosa Lima'), findsOneWidget);
    },
  );

  testWidgets('a form keeps what was typed when its reload fails', (
    tester,
  ) async {
    final users = FakeUsersRepository();
    await openUsers(tester, owner, users: users);
    await tester.tap(find.text('Ana Pérez'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit user'));
    await tester.pumpAndSettle();
    await tester.enterText(field('Name'), 'Ana María Pérez');

    users.getUserError = const NetworkFailure();
    returnToApp(tester);
    await tester.pumpAndSettle();

    expect(find.text('Ana María Pérez'), findsOneWidget);
  });

  testWidgets('an owner deactivates a user after confirming', (tester) async {
    final users = FakeUsersRepository();
    await openUsers(tester, owner, users: users);

    await tester.tap(find.text('Ana Pérez'));
    await tester.pumpAndSettle();
    await revealBelow(tester, find.text('Deactivate user'));
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
    await tester.tap(find.byTooltip('Me'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Roles'));
    await tester.pumpAndSettle();

    expect(find.text('3 users'), findsOneWidget);
    expect(find.textContaining('Built-in'), findsNWidgets(5));
    // Roles can be edited but not added.
    expect(find.byTooltip('Add role'), findsNothing);

    // Built-in roles: description only, no rename or delete.
    await tester.tap(find.text('Crew'));
    await tester.pumpAndSettle();
    expect(find.text('Edit role'), findsOneWidget);
    expect(tester.widget<TextFormField>(field('Name')).enabled, isFalse);
    expect(find.text('Delete role'), findsNothing);
    await tester.enterText(field('Description (optional)'), 'Cleaners on site');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(roles.writes, ['update:r-crew:crew']);

    await tester.tap(find.text('floor_lead'));
    await tester.pumpAndSettle();
    expect(find.text('Edit role'), findsOneWidget);
    await tester.tap(find.text('Delete role'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(roles.writes, ['update:r-crew:crew', 'delete:r-lead']);
    expect(find.text('floor_lead'), findsNothing);
  });

  testWidgets('the role editor keeps Save above the navigation bar', (
    tester,
  ) async {
    // A three-button navigation bar: 48 dp at the bottom of the screen.
    tester.view.padding = const FakeViewPadding(bottom: 48 * 3);
    tester.view.viewPadding = const FakeViewPadding(bottom: 48 * 3);
    await pumpApp(tester, auth: FakeAuthRepository(sessionUser: owner));
    await tester.tap(find.byTooltip('Me'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Roles'));
    await tester.pumpAndSettle();
    // Built-in: Save is the last thing in the sheet.
    await tester.tap(find.text('Crew'));
    await tester.pumpAndSettle();

    final screenHeight = tester.view.physicalSize.height / 3;
    expect(
      tester.getRect(find.widgetWithText(FilledButton, 'Save')).bottom,
      lessThanOrEqualTo(screenHeight - 48),
    );
  });
}
