import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/app.dart';
import 'package:sp_cln_app/core/error/failures.dart';
import 'package:sp_cln_app/features/auth/di/auth_providers.dart';
import 'package:sp_cln_app/features/auth/domain/entities/user.dart';
import 'package:sp_cln_app/features/auth/domain/repositories/auth_repository.dart';

const _ana = User(
  id: 'u1',
  email: 'ana@example.com',
  name: 'Ana Pérez',
  userType: UserType.internal,
  isActive: true,
  roles: [Role(id: 'r1', name: 'supervisor')],
);

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.sessionUser, this.loginError});

  User? sessionUser;
  Failure? loginError;

  @override
  Future<bool> hasSession() async => sessionUser != null;

  @override
  Future<User> getCurrentUser() async => sessionUser!;

  @override
  Future<User> login({required String email, required String password}) async {
    if (loginError case final error?) throw error;
    return sessionUser = _ana;
  }

  @override
  Future<void> logout() async => sessionUser = null;

  @override
  Stream<void> get sessionExpired => const Stream.empty();
}

Future<void> pumpApp(WidgetTester tester, FakeAuthRepository repository) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
      child: const App(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> fillAndSubmit(WidgetTester tester) async {
  await tester.enterText(find.byType(TextFormField).at(0), 'ana@example.com');
  await tester.enterText(
    find.byType(TextFormField).at(1),
    'correct-horse-battery',
  );
  await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('without a stored session the login screen is shown', (
    tester,
  ) async {
    await pumpApp(tester, FakeAuthRepository());

    expect(find.text('Use your work email and password.'), findsOneWidget);
  });

  testWidgets('a stored session goes straight home', (tester) async {
    await pumpApp(tester, FakeAuthRepository(sessionUser: _ana));

    expect(find.text('Welcome, Ana Pérez'), findsOneWidget);
  });

  testWidgets('validates the form before calling the API', (tester) async {
    await pumpApp(tester, FakeAuthRepository());

    await tester.enterText(find.byType(TextFormField).at(0), 'not-an-email');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(find.text('This field is required.'), findsOneWidget);
  });

  testWidgets('translates invalid credentials', (tester) async {
    await pumpApp(
      tester,
      FakeAuthRepository(
        loginError: const UnauthorizedFailure('auth.invalid_credentials'),
      ),
    );

    await fillAndSubmit(tester);

    expect(find.text('Incorrect email or password.'), findsOneWidget);
  });

  testWidgets('shows server field errors on the field', (tester) async {
    await pumpApp(
      tester,
      FakeAuthRepository(
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
    await pumpApp(tester, FakeAuthRepository());

    await fillAndSubmit(tester);
    expect(find.text('Welcome, Ana Pérez'), findsOneWidget);

    await tester.tap(find.byTooltip('Sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Use your work email and password.'), findsOneWidget);
  });
}
