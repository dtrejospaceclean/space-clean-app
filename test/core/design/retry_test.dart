import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/core/error/failures.dart';
import 'package:sp_cln_app/features/users/domain/entities/managed_user.dart';

import '../../helpers/test_app.dart';

/// Counts loads of one user; [gate] holds them like a slow server.
class _SlowUsers extends FakeUsersRepository {
  int loads = 0;
  Completer<void>? gate;

  @override
  Future<ManagedUser> getUser(String id) async {
    loads++;
    await gate?.future;
    return super.getUser(id);
  }
}

Finder get _retry => find.text('Try again');
Finder get _busy => find.byType(CircularProgressIndicator);

void main() {
  testWidgets('Try again shows it is working, even when it fails again', (
    tester,
  ) async {
    final users = _SlowUsers()..getUserError = const NetworkFailure();
    await pumpApp(
      tester,
      auth: FakeAuthRepository(sessionUser: owner),
      users: users,
    );
    await tester.tap(find.byTooltip('Me'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Users'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ana Pérez'));
    await tester.pumpAndSettle();
    expect(_retry, findsOneWidget);

    // Fails again at once (offline): the button is busy for a moment.
    await tester.tap(_retry);
    await tester.pump();
    expect(users.loads, 2);
    expect(_retry, findsNothing);
    expect(_busy, findsOneWidget);
    await tester.pumpAndSettle();
    expect(_retry, findsOneWidget);

    // A slow retry keeps the message up, busy, until it loads.
    users
      ..gate = Completer()
      ..getUserError = null;
    await tester.tap(_retry);
    await tester.pump(const Duration(seconds: 2));
    expect(find.textContaining("Can't reach"), findsOneWidget);
    expect(_busy, findsOneWidget);
    users.gate!.complete();
    await tester.pumpAndSettle();
    expect(find.text('ana@example.com'), findsWidgets);
  });

  testWidgets('the splash retries a failed session restore', (tester) async {
    final auth = FakeAuthRepository(sessionUser: ana)
      ..meFailure = const NetworkFailure();
    await pumpApp(tester, auth: auth);
    expect(_retry, findsOneWidget);

    await tester.tap(_retry);
    await tester.pump();
    expect(_busy, findsOneWidget);
    await tester.pumpAndSettle();
    expect(_retry, findsOneWidget);

    auth.meFailure = null;
    await tester.tap(_retry);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Me'), findsOneWidget);
  });
}
