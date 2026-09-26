import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/clients/presentation/screens/account_form_screen.dart';
import '../../features/clients/presentation/screens/account_info_screen.dart';
import '../../features/clients/presentation/screens/account_screen.dart';
import '../../features/clients/presentation/screens/accounts_screen.dart';
import '../../features/jobs/presentation/screens/account_jobs_screen.dart';
import '../../features/jobs/presentation/screens/job_detail_screen.dart';
import '../../features/jobs/presentation/screens/today_screen.dart';
import '../../features/password_reset/presentation/screens/forgot_password_screen.dart';
import '../../features/password_reset/presentation/screens/new_password_screen.dart';
import '../../features/password_reset/presentation/screens/reset_code_screen.dart';
import '../../features/password_reset/presentation/screens/reset_done_screen.dart';
import '../../features/profile/presentation/screens/change_password_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/service_catalog/presentation/screens/lookup_form_screen.dart';
import '../../features/service_catalog/presentation/screens/service_form_screen.dart';
import '../../features/service_catalog/presentation/screens/services_screen.dart';
import '../../features/shell/presentation/app_shell.dart';
import '../../features/shell/presentation/branch_container.dart';
import '../../features/users/presentation/screens/roles_screen.dart';
import '../../features/users/presentation/screens/user_detail_screen.dart';
import '../../features/users/presentation/screens/user_form_screen.dart';
import '../../features/users/presentation/screens/users_screen.dart';
import 'transitions.dart';

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
          isPublic(location) || location == SplashScreen.path || location == '/'
              ? TodayScreen.path
              : null,
      };
    },
    routes: [
      GoRoute(
        path: SplashScreen.path,
        pageBuilder: (_, state) => fadePage(state, const SplashScreen()),
      ),
      GoRoute(
        path: LoginScreen.path,
        pageBuilder: (_, state) => fadePage(
          state,
          LoginScreen(prefillEmail: state.uri.queryParameters['email']),
        ),
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
      // Signed-in app: one navigation stack per tab.
      StatefulShellRoute(
        pageBuilder: (_, state, shell) =>
            fadePage(state, AppShell(navigationShell: shell)),
        navigatorContainerBuilder: (_, shell, children) => FadeBranchContainer(
          currentIndex: shell.currentIndex,
          children: children,
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: TodayScreen.path,
                builder: (_, _) => const TodayScreen(),
                routes: [
                  GoRoute(
                    path: 'job/:clientId/:jobId',
                    builder: (_, state) => JobDetailScreen(
                      clientId: state.pathParameters['clientId']!,
                      jobId: state.pathParameters['jobId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AccountsScreen.path,
                builder: (_, _) => const AccountsScreen(),
                routes: [
                  // Before ':clientId' so "new" isn't read as an id.
                  GoRoute(
                    path: 'new',
                    builder: (_, _) => const AccountFormScreen(),
                  ),
                  GoRoute(
                    path: ':clientId',
                    builder: (_, state) => AccountScreen(
                      clientId: state.pathParameters['clientId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'info',
                        builder: (_, state) => AccountInfoScreen(
                          clientId: state.pathParameters['clientId']!,
                        ),
                        routes: [
                          GoRoute(
                            path: 'edit',
                            builder: (_, state) => AccountFormScreen(
                              clientId: state.pathParameters['clientId'],
                            ),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'jobs',
                        builder: (_, state) => AccountJobsScreen(
                          clientId: state.pathParameters['clientId']!,
                        ),
                        routes: [
                          GoRoute(
                            path: ':jobId',
                            builder: (_, state) => JobDetailScreen(
                              clientId: state.pathParameters['clientId']!,
                              jobId: state.pathParameters['jobId']!,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: ProfileScreen.path,
                builder: (_, _) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (_, _) => const EditProfileScreen(),
                  ),
                  GoRoute(
                    path: 'users',
                    builder: (_, _) => const UsersScreen(),
                    routes: [
                      // Before ':userId' so "new" isn't read as an id.
                      GoRoute(
                        path: 'new',
                        builder: (_, _) => const UserFormScreen(),
                      ),
                      GoRoute(
                        path: ':userId',
                        builder: (_, state) => UserDetailScreen(
                          userId: state.pathParameters['userId']!,
                        ),
                        routes: [
                          GoRoute(
                            path: 'edit',
                            builder: (_, state) => UserFormScreen(
                              userId: state.pathParameters['userId'],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'roles',
                    builder: (_, _) => const RolesScreen(),
                  ),
                  GoRoute(
                    path: 'password',
                    builder: (_, _) => const ChangePasswordScreen(),
                  ),
                  GoRoute(
                    path: 'services',
                    builder: (_, _) => const ServicesScreen(),
                    routes: [
                      // Before ':serviceId' so these aren't read as an id.
                      GoRoute(
                        path: 'new',
                        builder: (_, _) => const ServiceFormScreen(),
                      ),
                      GoRoute(
                        path: 'categories',
                        builder: (_, _) => const CategoriesScreen(),
                        routes: [
                          GoRoute(
                            path: 'new',
                            builder: (_, _) => const LookupFormScreen(
                              kind: LookupKind.category,
                            ),
                          ),
                          GoRoute(
                            path: ':id',
                            builder: (_, state) => LookupFormScreen(
                              kind: LookupKind.category,
                              id: state.pathParameters['id'],
                            ),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'units',
                        builder: (_, _) => const UnitsScreen(),
                        routes: [
                          GoRoute(
                            path: 'new',
                            builder: (_, _) =>
                                const LookupFormScreen(kind: LookupKind.unit),
                          ),
                          GoRoute(
                            path: ':id',
                            builder: (_, state) => LookupFormScreen(
                              kind: LookupKind.unit,
                              id: state.pathParameters['id'],
                            ),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: ':serviceId',
                        builder: (_, state) => ServiceFormScreen(
                          serviceId: state.pathParameters['serviceId'],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    authState.dispose();
  });
  return router;
});
