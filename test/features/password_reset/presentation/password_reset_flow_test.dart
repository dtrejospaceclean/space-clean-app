import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/core/error/failures.dart';

import '../../../helpers/test_app.dart';

Future<void> openCodeStep(
  WidgetTester tester,
  FakePasswordResetRepository reset,
) async {
  await pumpApp(
    tester,
    auth: FakeAuthRepository(rememberedEmail: 'ana@example.com'),
    passwordReset: reset,
  );
  await tester.tap(find.text('Forgot password?'));
  await tester.pumpAndSettle();
  await tester.tap(button('Send code'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('resets the password with a code and returns to sign-in', (
    tester,
  ) async {
    final reset = FakePasswordResetRepository();
    await openCodeStep(tester, reset);

    expect(
      find.textContaining('We sent a 6-digit code to ana@example.com'),
      findsOneWidget,
    );
    expect(find.textContaining('works for 10 minutes'), findsOneWidget);
    expect(find.text('New code in 60 s'), findsOneWidget);

    // Completing the sixth digit submits on its own.
    await tester.enterText(find.byType(TextField), '482913');
    await tester.pumpAndSettle();

    expect(find.text('Choose a new password'), findsOneWidget);
    await tester.enterText(field('New password'), 'a-long-new-secret');
    await tester.enterText(field('Repeat new password'), 'a-long-new-secret');
    await tester.pump();
    expect(
      find.bySemanticsLabel('At least 12 characters: Done'),
      findsOneWidget,
    );
    await tester.tap(button('Save password'));
    await tester.pumpAndSettle();

    expect(find.text('Password updated'), findsOneWidget);
    await tester.tap(button('Back to sign in'));
    await tester.pumpAndSettle();

    expect(find.text('ana@example.com'), findsOneWidget);
    // The code email is in the app's language.
    expect(reset.languages, ['en']);
    // The code buys a token, and the token sets the password.
    expect(reset.calls, [
      'request:ana@example.com',
      'verify:482913',
      'reset:t-482913',
    ]);
  });

  testWidgets('checks the new password before sending it', (tester) async {
    final reset = FakePasswordResetRepository();
    await openCodeStep(tester, reset);
    await tester.enterText(find.byType(TextField), '482913');
    await tester.pumpAndSettle();

    await tester.enterText(field('New password'), 'short');
    await tester.enterText(field('Repeat new password'), 'different');
    await tester.tap(button('Save password'));
    await tester.pumpAndSettle();

    expect(find.text('Must be at least 12 characters.'), findsOneWidget);
    expect(find.text('The passwords don\'t match.'), findsOneWidget);
    expect(reset.calls.where((c) => c.startsWith('reset')), isEmpty);
  });

  testWidgets('a refused code shows under the boxes, which empty', (
    tester,
  ) async {
    final reset = FakePasswordResetRepository()
      ..verifyError = const ServerFailure('auth.invalid_pin', statusCode: 400);
    await openCodeStep(tester, reset);

    await tester.enterText(find.byType(TextField), '000000');
    await tester.pumpAndSettle();

    expect(
      find.text(
        'That code is wrong or has expired. After 5 tries, send a new code.',
      ),
      findsOneWidget,
    );
    expect(find.text('Enter the code'), findsOneWidget);
    final input = tester.widget<TextField>(find.byType(TextField));
    expect(input.controller!.text, isEmpty);
  });

  testWidgets('a spent reset sends a new code and goes back to enter it', (
    tester,
  ) async {
    final reset = FakePasswordResetRepository()
      ..resetError = const ServerFailure(
        'auth.invalid_reset_token',
        statusCode: 400,
      );
    await openCodeStep(tester, reset);
    await tester.enterText(find.byType(TextField), '482913');
    await tester.pumpAndSettle();
    await tester.enterText(field('New password'), 'a-long-new-secret');
    await tester.enterText(field('Repeat new password'), 'a-long-new-secret');
    await tester.tap(button('Save password'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'This reset took too long or was already used. '
        'Send a new code to start again.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Send a new code'));
    await tester.pumpAndSettle();

    expect(find.text('Enter the code'), findsOneWidget);
    expect(find.text('We sent a new code.'), findsOneWidget);
    expect(reset.calls, [
      'request:ana@example.com',
      'verify:482913',
      'reset:t-482913',
      'request:ana@example.com',
    ]);
  });
}
