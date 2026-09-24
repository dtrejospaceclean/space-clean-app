import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/usecase/usecase.dart';
import '../../di/auth_providers.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login.dart';

sealed class AuthState {
  const AuthState();
}

final class Authenticated extends AuthState {
  const Authenticated(this.user);
  final User user;
}

final class Unauthenticated extends AuthState {
  const Unauthenticated({this.sessionExpired = false});

  /// The server ended the session; sign-in explains why.
  final bool sessionExpired;
}

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(
  AuthController.new,
  // The splash screen offers a manual retry instead.
  retry: (_, _) => null,
);

/// Source of truth for the session. Loading/error only happen while restoring a
/// stored session at startup; login errors are thrown to the caller instead.
class AuthController extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final subscription = ref.watch(watchSessionExpiredProvider)().listen((_) {
      state = const AsyncData(Unauthenticated(sessionExpired: true));
    });
    ref.onDispose(subscription.cancel);

    try {
      final restored = await ref.watch(restoreSessionProvider)(
        const NoParams(),
      );
      return switch (restored.user) {
        final user? => Authenticated(user),
        // A stored session that no longer works: sign-in explains why.
        null => Unauthenticated(sessionExpired: restored.ended),
      };
    } catch (error, stack) {
      // The splash shows a short message; the console gets the real cause.
      debugPrint('Session restore failed: $error');
      debugPrintStack(stackTrace: stack);
      rethrow;
    }
  }

  /// Throws a `Failure` so the login form can show it.
  Future<void> login({required String email, required String password}) async {
    final user = await ref.read(loginProvider)(
      LoginParams(email: email, password: password),
    );
    state = AsyncData(Authenticated(user));
  }

  Future<void> logout() async {
    await ref.read(logoutProvider)(const NoParams());
    state = const AsyncData(Unauthenticated());
  }
}
