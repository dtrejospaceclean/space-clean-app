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
  const Unauthenticated();
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
      state = const AsyncData(Unauthenticated());
    });
    ref.onDispose(subscription.cancel);

    final user = await ref.watch(restoreSessionProvider)(const NoParams());
    return user == null ? const Unauthenticated() : Authenticated(user);
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
