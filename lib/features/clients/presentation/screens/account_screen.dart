import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/role_names.dart';
import '../../../../core/widgets/adaptive.dart';
import '../../../../core/widgets/app/app_list.dart';
import '../../../../core/widgets/app/app_page.dart';
import '../../../../core/widgets/app/async_slivers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../access/domain/entities/account_access.dart';
import '../../../access/presentation/controllers/account_access_provider.dart';
import '../controllers/clients_providers.dart';

/// One client account: what the user may open here, driven by their
/// effective permissions (nothing they can't use is shown).
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cupertino = useCupertino(context);
    final client = ref.watch(clientByIdProvider(clientId)).value;
    final access = ref.watch(accountAccessProvider(clientId));
    final here = GoRouterState.of(context).matchedLocation;
    Future<void> refresh() =>
        ref.refresh(accountAccessProvider(clientId).future);

    // Built modules navigate; the rest are listed as coming soon.
    final modules = <(String, IconData, String, String?)>[
      (
        Permissions.jobsView,
        cupertino ? CupertinoIcons.briefcase : Icons.work_outline,
        l10n.moduleJobs,
        '$here/jobs',
      ),
      (
        Permissions.calendarView,
        cupertino ? CupertinoIcons.calendar : Icons.calendar_month_outlined,
        l10n.moduleCalendar,
        null,
      ),
      (
        Permissions.complaintsView,
        cupertino
            ? CupertinoIcons.exclamationmark_bubble
            : Icons.report_outlined,
        l10n.moduleComplaints,
        null,
      ),
      (
        Permissions.tasksView,
        cupertino ? CupertinoIcons.checkmark_square : Icons.task_alt,
        l10n.moduleTasks,
        null,
      ),
      (
        Permissions.filesView,
        cupertino ? CupertinoIcons.folder : Icons.folder_outlined,
        l10n.moduleFiles,
        null,
      ),
    ];
    final accountModules = <(String, IconData, String, String?)>[
      (
        Permissions.infoView,
        cupertino ? CupertinoIcons.info : Icons.info_outline,
        l10n.moduleInfo,
        null,
      ),
      (
        Permissions.proposalView,
        cupertino ? CupertinoIcons.doc_text : Icons.request_quote_outlined,
        l10n.moduleProposals,
        null,
      ),
      (
        Permissions.contractView,
        cupertino ? CupertinoIcons.doc_checkmark : Icons.description_outlined,
        l10n.moduleContracts,
        null,
      ),
      (
        Permissions.scopeView,
        cupertino ? CupertinoIcons.square_list : Icons.fact_check_outlined,
        l10n.moduleScope,
        null,
      ),
      (
        Permissions.teamView,
        cupertino ? CupertinoIcons.person_2 : Icons.groups_outlined,
        l10n.moduleTeam,
        null,
      ),
    ];

    List<Widget> rows(
      AccountAccess access,
      List<(String, IconData, String, String?)> list,
    ) => [
      for (final (permission, icon, label, route) in list)
        if (access.can(permission))
          AppListRow(
            leading: icon,
            title: label,
            trailing: route == null ? Text(l10n.comingSoon) : null,
            onTap: route == null ? null : () => context.push(route),
          ),
    ];

    return AppPage(
      grouped: true,
      title: client?.displayName ?? l10n.accountsTitle,
      onRefresh: refresh,
      slivers: [
        AsyncSlivers(
          value: access,
          onRetry: refresh,
          builder: (access) {
            final work = rows(access, modules);
            final account = rows(access, accountModules);
            if (work.isEmpty && account.isEmpty) {
              return MessageSliver(
                icon: cupertino ? CupertinoIcons.lock : Icons.lock_outline,
                title: l10n.noModules,
              );
            }
            return SliverList.list(
              children: [
                if (access.baseRole case final role?)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Text(
                      l10n.yourRole(l10n.roleName(role)),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                if (work.isNotEmpty)
                  AppListSection(title: l10n.sectionWork, children: work),
                if (account.isNotEmpty)
                  AppListSection(title: l10n.sectionAccount, children: account),
              ],
            );
          },
        ),
      ],
    );
  }
}
