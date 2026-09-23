import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  // Bridges auth state into go_router so redirects re-run on login/logout.
  final authState = ValueNotifier<AsyncValue<AuthState>>(
    ref.read(authControllerProvider),
  );
  ref.listen(authControllerProvider, (_, next) => authState.value = next);

  final router = GoRouter(
    initialLocation: SplashScreen.path,
    refreshListenable: authState,
    redirect: (context, state) {
      final location = state.matchedLocation;
      return switch (authState.value.value) {
        // Restoring the session, or it failed and the splash offers a retry.
        null => location == SplashScreen.path ? null : SplashScreen.path,
        Unauthenticated() =>
          location == LoginScreen.path ? null : LoginScreen.path,
        Authenticated() =>
          location == LoginScreen.path || location == SplashScreen.path
              ? HomeScreen.path
              : null,
      };
    },
    routes: [
      GoRoute(path: SplashScreen.path, builder: (_, _) => const SplashScreen()),
      GoRoute(path: LoginScreen.path, builder: (_, _) => const LoginScreen()),
      GoRoute(path: HomeScreen.path, builder: (_, _) => const HomeScreen()),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    authState.dispose();
  });
  return router;
});
