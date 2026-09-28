import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_app.dart';

Future<FakeProfileRepository> openMe(
  WidgetTester tester,
  FakeAuthRepository auth,
) async {
  final profile = FakeProfileRepository(auth);
  await pumpApp(tester, auth: auth, profile: profile);
  await tester.tap(find.byTooltip('Me'));
  await tester.pumpAndSettle();
  return profile;
}

void main() {
  testWidgets('anyone edits their own profile from Me', (tester) async {
    final auth = FakeAuthRepository(sessionUser: ana);
    final profile = await openMe(tester, auth);

    await tester.tap(find.byTooltip('Edit profile'));
    await tester.pumpAndSettle();
    // Email isn't theirs to change; the form says who can.
    expect(find.text('Email'), findsNothing);
    expect(find.textContaining('ana@example.com'), findsOneWidget);

    await tester.enterText(field('Full name'), 'Ana M. Pérez');
    // A number without its area code is refused before saving.
    await tester.enterText(field('Phone').first, '555-0100');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a 10-digit phone number.'), findsOneWidget);
    expect(profile.writes, isEmpty);

    await tester.enterText(field('Phone').first, '713-555-0100');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(profile.writes, ['profile']);
    expect(auth.sessionUser!.phoneNumber, '(713) 555-0100');
    // Back on Me, with the new name.
    expect(find.byTooltip('Edit profile'), findsOneWidget);
    expect(find.text('Ana M. Pérez'), findsOneWidget);
  });

  testWidgets('a blank name is refused before saving', (tester) async {
    final auth = FakeAuthRepository(sessionUser: ana);
    final profile = await openMe(tester, auth);
    await tester.tap(find.byTooltip('Edit profile'));
    await tester.pumpAndSettle();

    await tester.enterText(field('Full name'), '  ');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(profile.writes, isEmpty);
    expect(find.text('This field is required.'), findsOneWidget);
  });

  group('change password', () {
    Future<FakeProfileRepository> openForm(WidgetTester tester) async {
      final profile = await openMe(
        tester,
        FakeAuthRepository(sessionUser: ana),
      );
      await tester.tap(find.text('Change password'));
      await tester.pumpAndSettle();
      return profile;
    }

    testWidgets('a wrong current password shows on its field', (tester) async {
      final profile = await openForm(tester);

      await tester.enterText(field('Current password'), 'not it');
      await tester.enterText(field('New password'), 'a brand new secret');
      await tester.enterText(
        field('Repeat new password'),
        'a brand new secret',
      );
      await tester.tap(find.text('Save password'));
      await tester.pumpAndSettle();

      expect(profile.writes, isEmpty);
      expect(find.text('Your current password is incorrect.'), findsOneWidget);
    });

    testWidgets('checks length and match before calling the server', (
      tester,
    ) async {
      final profile = await openForm(tester);

      await tester.enterText(field('Current password'), profile.password);
      await tester.enterText(field('New password'), 'short');
      await tester.enterText(field('Repeat new password'), 'other');
      await tester.tap(find.text('Save password'));
      await tester.pumpAndSettle();

      expect(profile.writes, isEmpty);
      expect(find.text("The passwords don't match."), findsOneWidget);
    });

    testWidgets('confirms the change and returns to Me', (tester) async {
      final profile = await openForm(tester);

      await tester.enterText(field('Current password'), profile.password);
      await tester.enterText(field('New password'), 'a brand new secret');
      await tester.enterText(
        field('Repeat new password'),
        'a brand new secret',
      );
      await tester.tap(find.text('Save password'));
      await tester.pumpAndSettle();

      expect(profile.writes, ['password']);
      expect(find.text('Password changed'), findsOneWidget);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      // Still signed in, back on Me.
      expect(find.byTooltip('Edit profile'), findsOneWidget);
      expect(find.text('Change password'), findsOneWidget);
    });
  });
}
