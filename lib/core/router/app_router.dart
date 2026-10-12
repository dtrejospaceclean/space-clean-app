import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/calendar/presentation/screens/calendar_screen.dart';
import '../../features/calendar/presentation/screens/event_form_screen.dart';
import '../../features/calendar/presentation/screens/event_screen.dart';
import '../../features/calendar/presentation/screens/reschedule_event_screen.dart';
import '../../features/clients/presentation/screens/account_form_screen.dart';
import '../../features/clients/presentation/screens/purge_account_screen.dart';
import '../../features/clients/presentation/screens/account_info_screen.dart';
import '../../features/clients/presentation/screens/account_screen.dart';
import '../../features/clients/presentation/screens/accounts_screen.dart';
import '../../features/contacts/presentation/screens/contact_form_screen.dart';
import '../../features/contacts/presentation/screens/contact_login_screen.dart';
import '../../features/contacts/presentation/screens/contact_screen.dart';
import '../../features/contacts/presentation/screens/contacts_screen.dart';
import '../../features/complaints/presentation/screens/complaint_form_screen.dart';
import '../../features/complaints/presentation/screens/complaint_screen.dart';
import '../../features/complaints/presentation/screens/complaints_screen.dart';
import '../../features/complaints/presentation/screens/resolve_complaint_screen.dart';
import '../../features/contracts/presentation/screens/contract_form_screen.dart';
import '../../features/contracts/presentation/screens/contract_screen.dart';
import '../../features/contracts/presentation/screens/contracts_screen.dart';
import '../../features/contracts/presentation/screens/sign_contract_screen.dart';
import '../../features/jobs/presentation/screens/account_jobs_screen.dart';
import '../../features/locations/presentation/screens/location_form_screen.dart';
import '../../features/locations/presentation/screens/location_screen.dart';
import '../../features/locations/presentation/screens/locations_screen.dart';
import '../../features/proposals/domain/entities/proposal.dart';
import '../../features/proposals/domain/usecases/proposal_usecases.dart';
import '../../features/proposals/presentation/screens/approve_proposal_screen.dart';
import '../../features/proposals/presentation/screens/line_item_screen.dart';
import '../../features/proposals/presentation/screens/proposal_form_screen.dart';
import '../../features/proposals/presentation/screens/proposal_screen.dart';
import '../../features/proposals/presentation/screens/proposals_screen.dart';
import '../../features/scopes/presentation/screens/scope_form_screen.dart';
import '../../features/scopes/presentation/screens/scope_screen.dart';
import '../../features/scopes/presentation/screens/scopes_screen.dart';
import '../../features/scopes/presentation/screens/time_window_screen.dart';
import '../../features/jobs/presentation/screens/job_checklist_screen.dart';
import '../../features/jobs/presentation/screens/job_complete_screen.dart';
import '../../features/jobs/presentation/screens/job_crew_screen.dart';
import '../../features/jobs/presentation/screens/job_detail_screen.dart';
import '../../features/jobs/presentation/screens/job_form_screen.dart';
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
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/shell/presentation/app_shell.dart';
import '../../features/team/presentation/screens/member_form_screen.dart';
import '../../features/team/presentation/screens/member_screen.dart';
import '../../features/team/presentation/screens/team_screen.dart';
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
          SlideRoute(
            path: 'forgot',
            builder: (_, state) => ForgotPasswordScreen(
              prefillEmail: state.uri.queryParameters['email'],
            ),
            routes: [
              SlideRoute(
                path: 'code',
                builder: (_, _) => const ResetCodeScreen(),
              ),
              SlideRoute(
                path: 'password',
                builder: (_, _) => const NewPasswordScreen(),
              ),
              SlideRoute(
                path: 'done',
                builder: (_, _) => const ResetDoneScreen(),
              ),
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
              SlideRoute(
                path: TodayScreen.path,
                builder: (_, _) => const TodayScreen(),
                routes: [
                  SlideRoute(
                    path: 'job/:clientId/:jobId',
                    builder: (_, state) => JobDetailScreen(
                      clientId: state.pathParameters['clientId']!,
                      jobId: state.pathParameters['jobId']!,
                    ),
                    routes: _jobRoutes,
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              SlideRoute(
                path: AccountsScreen.path,
                builder: (_, _) => const AccountsScreen(),
                routes: [
                  // Before ':clientId' so "new" isn't read as an id.
                  SlideRoute(
                    path: 'new',
                    builder: (_, _) => const AccountFormScreen(),
                  ),
                  SlideRoute(
                    path: ':clientId',
                    builder: (_, state) => AccountScreen(
                      clientId: state.pathParameters['clientId']!,
                    ),
                    routes: [
                      SlideRoute(
                        path: 'info',
                        builder: (_, state) => AccountInfoScreen(
                          clientId: state.pathParameters['clientId']!,
                        ),
                        routes: [
                          SlideRoute(
                            path: 'edit',
                            builder: (_, state) => AccountFormScreen(
                              clientId: state.pathParameters['clientId'],
                            ),
                          ),
                          SlideRoute(
                            path: PurgeAccountScreen.route,
                            builder: (_, state) => PurgeAccountScreen(
                              clientId: state.pathParameters['clientId']!,
                            ),
                          ),
                        ],
                      ),
                      SlideRoute(
                        path: ProposalsScreen.route,
                        builder: (_, state) => ProposalsScreen(
                          clientId: state.pathParameters['clientId']!,
                        ),
                        routes: [
                          // Before ':proposalId' so "new" isn't read as an id.
                          SlideRoute(
                            path: 'new',
                            builder: (_, state) => ProposalFormScreen(
                              clientId: state.pathParameters['clientId']!,
                              mode: ProposalSave.create,
                            ),
                            routes: [_lineItemRoute],
                          ),
                          SlideRoute(
                            path: ':proposalId',
                            builder: (_, state) => ProposalScreen(
                              clientId: state.pathParameters['clientId']!,
                              proposalId: state.pathParameters['proposalId']!,
                            ),
                            routes: [
                              SlideRoute(
                                path: 'edit',
                                builder: (_, state) => ProposalFormScreen(
                                  clientId: state.pathParameters['clientId']!,
                                  mode: ProposalSave.edit,
                                  proposalId:
                                      state.pathParameters['proposalId'],
                                ),
                                routes: [_lineItemRoute],
                              ),
                              SlideRoute(
                                path: 'version',
                                builder: (_, state) => ProposalFormScreen(
                                  clientId: state.pathParameters['clientId']!,
                                  mode: ProposalSave.newVersion,
                                  proposalId:
                                      state.pathParameters['proposalId'],
                                ),
                                routes: [_lineItemRoute],
                              ),
                              SlideRoute(
                                path: 'approve',
                                builder: (_, state) => ApproveProposalScreen(
                                  clientId: state.pathParameters['clientId']!,
                                  proposalId:
                                      state.pathParameters['proposalId']!,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SlideRoute(
                        path: ComplaintsScreen.route,
                        builder: (_, state) => ComplaintsScreen(
                          clientId: state.pathParameters['clientId']!,
                        ),
                        routes: [
                          // Before ':complaintId' so "new" isn't read as an id.
                          // `?job=` reports it about that job.
                          SlideRoute(
                            path: 'new',
                            builder: (_, state) => ComplaintFormScreen(
                              clientId: state.pathParameters['clientId']!,
                              jobId: state.uri.queryParameters['job'],
                            ),
                          ),
                          SlideRoute(
                            path: ':complaintId',
                            builder: (_, state) => ComplaintScreen(
                              clientId: state.pathParameters['clientId']!,
                              complaintId: state.pathParameters['complaintId']!,
                            ),
                            routes: [
                              SlideRoute(
                                path: 'edit',
                                builder: (_, state) => ComplaintFormScreen(
                                  clientId: state.pathParameters['clientId']!,
                                  complaintId:
                                      state.pathParameters['complaintId'],
                                ),
                              ),
                              SlideRoute(
                                path: ResolveComplaintScreen.route,
                                builder: (_, state) => ResolveComplaintScreen(
                                  clientId: state.pathParameters['clientId']!,
                                  complaintId:
                                      state.pathParameters['complaintId']!,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SlideRoute(
                        path: ContractsScreen.route,
                        builder: (_, state) => ContractsScreen(
                          clientId: state.pathParameters['clientId']!,
                        ),
                        routes: [
                          // Before ':contractId' so "new" isn't read as an id.
                          // `?proposal=` starts it from an approved proposal.
                          SlideRoute(
                            path: 'new',
                            builder: (_, state) => ContractFormScreen(
                              clientId: state.pathParameters['clientId']!,
                              proposalId: state.uri.queryParameters['proposal'],
                            ),
                          ),
                          SlideRoute(
                            path: ':contractId',
                            builder: (_, state) => ContractScreen(
                              clientId: state.pathParameters['clientId']!,
                              contractId: state.pathParameters['contractId']!,
                            ),
                            routes: [
                              SlideRoute(
                                path: 'edit',
                                builder: (_, state) => ContractFormScreen(
                                  clientId: state.pathParameters['clientId']!,
                                  contractId:
                                      state.pathParameters['contractId'],
                                ),
                              ),
                              SlideRoute(
                                path: 'sign',
                                builder: (_, state) => SignContractScreen(
                                  clientId: state.pathParameters['clientId']!,
                                  contractId:
                                      state.pathParameters['contractId']!,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SlideRoute(
                        path: ScopesScreen.route,
                        // `?contract=` lists only that contract's scopes.
                        builder: (_, state) => ScopesScreen(
                          clientId: state.pathParameters['clientId']!,
                          contractId: state.uri.queryParameters['contract'],
                        ),
                        routes: [
                          // Before ':scopeId' so "new" isn't read as an id.
                          SlideRoute(
                            path: 'new',
                            builder: (_, state) => ScopeFormScreen(
                              clientId: state.pathParameters['clientId']!,
                            ),
                            routes: [_timeWindowRoute],
                          ),
                          SlideRoute(
                            path: ':scopeId',
                            builder: (_, state) => ScopeScreen(
                              clientId: state.pathParameters['clientId']!,
                              scopeId: state.pathParameters['scopeId']!,
                            ),
                            routes: [
                              SlideRoute(
                                path: 'edit',
                                builder: (_, state) => ScopeFormScreen(
                                  clientId: state.pathParameters['clientId']!,
                                  scopeId: state.pathParameters['scopeId'],
                                ),
                                routes: [_timeWindowRoute],
                              ),
                            ],
                          ),
                        ],
                      ),
                      SlideRoute(
                        path: CalendarScreen.route,
                        builder: (_, state) => CalendarScreen(
                          clientId: state.pathParameters['clientId']!,
                        ),
                        routes: [
                          // Before ':eventId' so "new" isn't read as an id.
                          SlideRoute(
                            path: 'new',
                            builder: (_, state) => EventFormScreen(
                              clientId: state.pathParameters['clientId']!,
                            ),
                          ),
                          SlideRoute(
                            path: ':eventId',
                            builder: (_, state) => EventScreen(
                              clientId: state.pathParameters['clientId']!,
                              eventId: state.pathParameters['eventId']!,
                            ),
                            routes: [
                              SlideRoute(
                                path: 'edit',
                                builder: (_, state) => EventFormScreen(
                                  clientId: state.pathParameters['clientId']!,
                                  eventId: state.pathParameters['eventId'],
                                ),
                              ),
                              SlideRoute(
                                path: 'reschedule',
                                builder: (_, state) => RescheduleEventScreen(
                                  clientId: state.pathParameters['clientId']!,
                                  eventId: state.pathParameters['eventId']!,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SlideRoute(
                        path: ContactsScreen.route,
                        builder: (_, state) => ContactsScreen(
                          clientId: state.pathParameters['clientId']!,
                        ),
                        routes: [
                          // Before ':contactId' so "new" isn't read as an id.
                          SlideRoute(
                            path: 'new',
                            builder: (_, state) => ContactFormScreen(
                              clientId: state.pathParameters['clientId']!,
                            ),
                          ),
                          SlideRoute(
                            path: ':contactId',
                            builder: (_, state) => ContactScreen(
                              clientId: state.pathParameters['clientId']!,
                              contactId: state.pathParameters['contactId']!,
                            ),
                            routes: [
                              SlideRoute(
                                path: 'edit',
                                builder: (_, state) => ContactFormScreen(
                                  clientId: state.pathParameters['clientId']!,
                                  contactId: state.pathParameters['contactId'],
                                ),
                              ),
                              SlideRoute(
                                path: 'login',
                                builder: (_, state) => ContactLoginScreen(
                                  clientId: state.pathParameters['clientId']!,
                                  contactId: state.pathParameters['contactId']!,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SlideRoute(
                        path: LocationsScreen.route,
                        builder: (_, state) => LocationsScreen(
                          clientId: state.pathParameters['clientId']!,
                        ),
                        routes: [
                          // Before ':locationId' so "new" isn't read as an id.
                          SlideRoute(
                            path: 'new',
                            builder: (_, state) => LocationFormScreen(
                              clientId: state.pathParameters['clientId']!,
                            ),
                          ),
                          SlideRoute(
                            path: ':locationId',
                            builder: (_, state) => LocationScreen(
                              clientId: state.pathParameters['clientId']!,
                              locationId: state.pathParameters['locationId']!,
                            ),
                            routes: [
                              SlideRoute(
                                path: 'edit',
                                builder: (_, state) => LocationFormScreen(
                                  clientId: state.pathParameters['clientId']!,
                                  locationId:
                                      state.pathParameters['locationId'],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SlideRoute(
                        path: TeamScreen.route,
                        builder: (_, state) => TeamScreen(
                          clientId: state.pathParameters['clientId']!,
                        ),
                        routes: [
                          // Before ':userId' so "new" isn't read as an id.
                          SlideRoute(
                            path: 'new',
                            builder: (_, state) => AddMemberScreen(
                              clientId: state.pathParameters['clientId']!,
                            ),
                          ),
                          SlideRoute(
                            path: ':userId',
                            builder: (_, state) => MemberScreen(
                              clientId: state.pathParameters['clientId']!,
                              userId: state.pathParameters['userId']!,
                            ),
                            routes: [
                              SlideRoute(
                                path: 'edit',
                                builder: (_, state) => MemberAccessScreen(
                                  clientId: state.pathParameters['clientId']!,
                                  userId: state.pathParameters['userId']!,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SlideRoute(
                        path: AccountJobsScreen.route,
                        builder: (_, state) => AccountJobsScreen(
                          clientId: state.pathParameters['clientId']!,
                        ),
                        routes: [
                          // Before ':jobId' so "new" isn't read as an id.
                          SlideRoute(
                            path: 'new',
                            builder: (_, state) => JobFormScreen(
                              clientId: state.pathParameters['clientId']!,
                            ),
                          ),
                          SlideRoute(
                            path: ':jobId',
                            builder: (_, state) => JobDetailScreen(
                              clientId: state.pathParameters['clientId']!,
                              jobId: state.pathParameters['jobId']!,
                            ),
                            routes: _jobRoutes,
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
              SlideRoute(
                path: ProfileScreen.path,
                builder: (_, _) => const ProfileScreen(),
                routes: [
                  SlideRoute(
                    path: 'edit',
                    builder: (_, _) => const EditProfileScreen(),
                  ),
                  SlideRoute(
                    path: 'users',
                    builder: (_, _) => const UsersScreen(),
                    routes: [
                      // Before ':userId' so "new" isn't read as an id.
                      SlideRoute(
                        path: 'new',
                        builder: (_, _) => const UserFormScreen(),
                      ),
                      SlideRoute(
                        path: ':userId',
                        builder: (_, state) => UserDetailScreen(
                          userId: state.pathParameters['userId']!,
                        ),
                        routes: [
                          SlideRoute(
                            path: 'edit',
                            builder: (_, state) => UserFormScreen(
                              userId: state.pathParameters['userId'],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SlideRoute(
                    path: 'roles',
                    builder: (_, _) => const RolesScreen(),
                  ),
                  SlideRoute(
                    path: 'password',
                    builder: (_, _) => const ChangePasswordScreen(),
                  ),
                  SlideRoute(
                    path: 'settings',
                    builder: (_, _) => const SettingsScreen(),
                  ),
                  SlideRoute(
                    path: 'services',
                    builder: (_, _) => const ServicesScreen(),
                    routes: [
                      // Before ':serviceId' so these aren't read as an id.
                      SlideRoute(
                        path: 'new',
                        builder: (_, _) => const ServiceFormScreen(),
                      ),
                      SlideRoute(
                        path: 'categories',
                        builder: (_, _) => const CategoriesScreen(),
                        routes: [
                          SlideRoute(
                            path: 'new',
                            builder: (_, _) => const LookupFormScreen(
                              kind: LookupKind.category,
                            ),
                          ),
                          SlideRoute(
                            path: ':id',
                            builder: (_, state) => LookupFormScreen(
                              kind: LookupKind.category,
                              id: state.pathParameters['id'],
                            ),
                          ),
                        ],
                      ),
                      SlideRoute(
                        path: 'units',
                        builder: (_, _) => const UnitsScreen(),
                        routes: [
                          SlideRoute(
                            path: 'new',
                            builder: (_, _) =>
                                const LookupFormScreen(kind: LookupKind.unit),
                          ),
                          SlideRoute(
                            path: ':id',
                            builder: (_, state) => LookupFormScreen(
                              kind: LookupKind.unit,
                              id: state.pathParameters['id'],
                            ),
                          ),
                        ],
                      ),
                      SlideRoute(
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

/// A proposal form's line item page. The item to edit comes in `extra`;
/// a new item (or a page reopened without it) starts empty.
final _lineItemRoute = SlideRoute(
  path: LineItemScreen.route,
  builder: (_, state) => LineItemScreen(
    initial: switch (state.extra) {
      final LineItemDraft item => item,
      _ => null,
    },
  ),
);

/// A scope form's time window page. The window and whether it needs
/// weekdays come in `extra`; a page reopened without them starts a new
/// window.
/// A job's editors, under its page in the account's jobs and on Today.
final _jobRoutes = [
  SlideRoute(
    path: 'edit',
    builder: (_, state) => JobFormScreen(
      clientId: state.pathParameters['clientId']!,
      jobId: state.pathParameters['jobId'],
    ),
  ),
  SlideRoute(
    path: JobCrewScreen.route,
    builder: (_, state) => JobCrewScreen(
      clientId: state.pathParameters['clientId']!,
      jobId: state.pathParameters['jobId']!,
    ),
  ),
  SlideRoute(
    path: JobCompleteScreen.route,
    builder: (_, state) => JobCompleteScreen(
      clientId: state.pathParameters['clientId']!,
      jobId: state.pathParameters['jobId']!,
    ),
  ),
  SlideRoute(
    path: JobChecklistScreen.route,
    builder: (_, state) => JobChecklistScreen(
      clientId: state.pathParameters['clientId']!,
      jobId: state.pathParameters['jobId']!,
    ),
  ),
];

final _timeWindowRoute = SlideRoute(
  path: TimeWindowScreen.route,
  builder: (_, state) => TimeWindowScreen(
    args: switch (state.extra) {
      final TimeWindowArgs args => args,
      _ => const TimeWindowArgs(),
    },
  ),
);
