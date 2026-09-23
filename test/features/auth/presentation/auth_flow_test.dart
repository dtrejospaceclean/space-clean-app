import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/core/design/tokens.dart';
import 'package:sp_cln_app/core/error/failures.dart';

import '../../../helpers/test_app.dart';

const _tagline = 'One Partner. Every Facility Solution.';

Future<void> fillAndSubmit(WidgetTester tester) async {
  await tester.enterText(field('Email'), 'ana@example.com');
  await tester.enterText(field('Password'), 'correct-horse-battery');
  await tester.tap(button('Sign in'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('without a stored session the sign-in screen is shown', (
    tester,
  ) async {
    await pumpApp(tester, auth: FakeAuthRepository());

    expect(find.textContaining(_tagline, findRichText: true), findsOneWidget);
    expect(find.text('Not you?'), findsNothing);
  });

  testWidgets('a stored session goes straight home', (tester) async {
    await pumpApp(tester, auth: FakeAuthRepository(sessionUser: ana));

    expect(find.text('No jobs today'), findsOneWidget);
  });

  testWidgets('validates the form before calling the API', (tester) async {
    await pumpApp(tester, auth: FakeAuthRepository());

    await tester.enterText(field('Email'), 'not-an-email');
    await tester.tap(button('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(find.text('This field is required.'), findsOneWidget);
  });

  testWidgets('translates invalid credentials', (tester) async {
    await pumpApp(
      tester,
      auth: FakeAuthRepository(
        loginError: const UnauthorizedFailure('auth.invalid_credentials'),
      ),
    );

    await fillAndSubmit(tester);

    expect(find.text('Incorrect email or password.'), findsOneWidget);
  });

  testWidgets('shows server field errors on the field', (tester) async {
    await pumpApp(
      tester,
      auth: FakeAuthRepository(
        loginError: const ValidationFailure('validation.failed', {
          'password': [
            FieldError(
              key: 'validation.min_length',
              fallbackMessage:
                  'password must be longer than or equal to 12 characters',
              params: {'constraint1': 12},
            ),
          ],
        }),
      ),
    );

    await fillAndSubmit(tester);

    expect(find.text('Must be at least 12 characters.'), findsOneWidget);
  });

  testWidgets('logs in and out', (tester) async {
    await pumpApp(tester, auth: FakeAuthRepository());

    await fillAndSubmit(tester);
    expect(find.text('No jobs today'), findsOneWidget);

    await tester.tap(find.text('Me'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    // Confirm in the dialog.
    await tester.tap(find.text('Sign out').last);
    await tester.pumpAndSettle();
    expect(find.textContaining(_tagline, findRichText: true), findsOneWidget);
  });

  testWidgets('prefills the remembered email, and "Not you?" clears it', (
    tester,
  ) async {
    final auth = FakeAuthRepository(rememberedEmail: 'ana@example.com');
    await pumpApp(tester, auth: auth);

    expect(find.text('ana@example.com'), findsOneWidget);

    await tester.tap(find.text('Not you?'));
    await tester.pumpAndSettle();

    expect(find.text('ana@example.com'), findsNothing);
    expect(find.text('Not you?'), findsNothing);
    expect(auth.rememberedEmail, isNull);
  });

  testWidgets('explains a session that expired on its own', (tester) async {
    final auth = FakeAuthRepository(sessionUser: ana);
    await pumpApp(tester, auth: auth);

    auth.sessionUser = null;
    auth.expiry.add(null);
    await tester.pumpAndSettle();

    expect(find.text('Your session expired. Sign in again.'), findsOneWidget);
  });

  testWidgets('keeps the light ground when the phone is in dark mode', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await pumpApp(tester, auth: FakeAuthRepository());

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, SpaceColors.ground);
  });

  testWidgets('switching language mid-animation never overflows', (
    tester,
  ) async {
    // The tagline reflows (ES wraps to two lines, EN fits one) while the
    // brand block animates. On a screen where the form fits with zero slack
    // (a 360-dp Galaxy S21 did), any lag between reported and painted height
    // overflows. Sweep heights so one of them is that tight fit.
    await pumpApp(
      tester,
      auth: FakeAuthRepository(rememberedEmail: 'ana@example.com'),
    );
    tester.view.devicePixelRatio = 1;
    var language = 'ES';
    for (var height = 560.0; height <= 900; height += 4) {
      tester.view.physicalSize = Size(360, height);
      await tester.pumpAndSettle();

      await tester.tap(find.text(language));
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'height $height');
      language = language == 'ES' ? 'EN' : 'ES';
    }
  });

  testWidgets('switches to Spanish and remembers it', (tester) async {
    final prefs = await pumpApp(tester, auth: FakeAuthRepository());

    await tester.tap(find.text('ES'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining(
        'Un Solo Aliado. Toda Solución para tu Instalación.',
        findRichText: true,
      ),
      findsOneWidget,
    );
    expect(button('Iniciar sesión'), findsOneWidget);
    expect(prefs.getString('settings.language'), 'es');
  });
}
