import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/l10n/role_names.dart';
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
    final client = ref.watch(clientByIdProvider(clientId)).value;
    final access = ref.watch(accountAccessProvider(clientId));
    final here = GoRouterState.of(context).matchedLocation;
    Future<void> refresh() =>
        ref.refresh(accountAccessProvider(clientId).future);

    // Built modules navigate; the rest are shown as coming soon.
    final work = <(String, IconData, String, String?)>[
      (
        Permissions.jobsView,
        Icons.cleaning_services_outlined,
        l10n.moduleJobs,
        '$here/jobs',
      ),
      (
        Permissions.calendarView,
        Icons.calendar_month_outlined,
        l10n.moduleCalendar,
        null,
      ),
      (
        Permissions.complaintsView,
        Icons.report_outlined,
        l10n.moduleComplaints,
        null,
      ),
      (Permissions.tasksView, Icons.task_alt_rounded, l10n.moduleTasks, null),
      (Permissions.filesView, Icons.folder_outlined, l10n.moduleFiles, null),
    ];
    final account = <(String, IconData, String, String?)>[
      (
        Permissions.infoView,
        Icons.info_outline_rounded,
        l10n.moduleInfo,
        '$here/info',
      ),
      (
        Permissions.proposalView,
        Icons.request_quote_outlined,
        l10n.moduleProposals,
        null,
      ),
      (
        Permissions.contractView,
        Icons.description_outlined,
        l10n.moduleContracts,
        null,
      ),
      (
        Permissions.scopeView,
        Icons.fact_check_outlined,
        l10n.moduleScope,
        null,
      ),
      (Permissions.teamView, Icons.groups_outlined, l10n.moduleTeam, null),
    ];

    List<Widget> tiles(
      AccountAccess access,
      List<(String, IconData, String, String?)> list,
    ) => [
      for (final (permission, icon, label, route) in list)
        if (access.can(permission))
          TileCard(
            icon: route == null
                ? IconBadge(
                    icon: icon,
                    color: SpaceColors.inkMuted,
                    background: SpaceColors.sunken,
                  )
                : IconBadge.strong(icon: icon),
            title: label,
            subtitle: route == null ? l10n.comingSoonLong : l10n.openSection,
            onTap: route == null ? null : () => context.push(route),
          ),
    ];

    return SpacePage(
      onRefresh: refresh,
      slivers: [
        AsyncSlivers(
          value: access,
          onRetry: refresh,
          builder: (access) {
            final workTiles = tiles(access, work);
            final accountTiles = tiles(access, account);
            return SliverMainAxisGroup(
              slivers: [
                PageBox(
                  top: 16,
                  child: HeroHeadline(
                    primary: client?.displayName ?? l10n.accountsTitle,
                    secondary: switch (access.baseRole) {
                      final role? => l10n.yourRole(l10n.roleName(role)),
                      null => null,
                    },
                  ),
                ),
                if (workTiles.isEmpty && accountTiles.isEmpty)
                  MessageSliver(
                    icon: Icons.lock_outline_rounded,
                    title: l10n.noModules,
                  ),
                if (workTiles.isNotEmpty) ...[
                  PageBox(
                    top: 16,
                    child: SectionHeader(title: l10n.sectionWork),
                  ),
                  PageBox(top: 0, child: CardGrid(children: workTiles)),
                ],
                if (accountTiles.isNotEmpty) ...[
                  PageBox(
                    top: 16,
                    child: SectionHeader(title: l10n.sectionAccount),
                  ),
                  PageBox(top: 0, child: CardGrid(children: accountTiles)),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
