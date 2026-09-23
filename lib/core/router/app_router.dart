import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/password_reset/presentation/screens/forgot_password_screen.dart';
import '../../features/password_reset/presentation/screens/new_password_screen.dart';
import '../../features/password_reset/presentation/screens/reset_code_screen.dart';
import '../../features/password_reset/presentation/screens/reset_done_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  // Bridges auth state into go_router so redirects re-run on login/logout.
  final authState = ValueNotifier<AsyncValue<AuthState>>(
    ref.read(authControllerProvider),
  );
  ref.listen(authControllerProvider, (_, next) => authState.value = next);

  // Sign-in and the password reset under it.
  bool isPublic(String location) =>
      location == LoginScreen.path ||
      location.startsWith('${LoginScreen.path}/');

  final router = GoRouter(
    initialLocation: SplashScreen.path,
    refreshListenable: authState,
    redirect: (context, state) {
      final location = state.matchedLocation;
      return switch (authState.value.value) {
        // Restoring the session, or it failed and the splash offers a retry.
        null => location == SplashScreen.path ? null : SplashScreen.path,
        Unauthenticated() => isPublic(location) ? null : LoginScreen.path,
        Authenticated() =>
          isPublic(location) || location == SplashScreen.path
              ? HomeScreen.path
              : null,
      };
    },
    routes: [
      GoRoute(path: SplashScreen.path, builder: (_, _) => const SplashScreen()),
      GoRoute(
        path: LoginScreen.path,
        builder: (_, state) =>
            LoginScreen(prefillEmail: state.uri.queryParameters['email']),
        routes: [
          GoRoute(
            path: 'forgot',
            builder: (_, state) => ForgotPasswordScreen(
              prefillEmail: state.uri.queryParameters['email'],
            ),
            routes: [
              GoRoute(path: 'code', builder: (_, _) => const ResetCodeScreen()),
              GoRoute(
                path: 'password',
                builder: (_, _) => const NewPasswordScreen(),
              ),
              GoRoute(path: 'done', builder: (_, _) => const ResetDoneScreen()),
            ],
          ),
        ],
      ),
      GoRoute(path: HomeScreen.path, builder: (_, _) => const HomeScreen()),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    authState.dispose();
  });
  return router;
});
