import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/l10n/role_names.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/member.dart';
import '../controllers/team_providers.dart';

/// "Supervisor · Custom access · Inactive": a member's role on the account
/// and anything unusual about them.
String memberSummary(AppLocalizations l10n, Member m) => [
  l10n.roleName(m.baseRole),
  if (m.hasCustomAccess) l10n.customAccessTag,
  if (!m.isActive) l10n.inactiveTag,
].join(' · ');

/// Who works on one client account (`team.view`). Owners add people from
/// the dock's "+".
class TeamScreen extends ConsumerWidget {
  const TeamScreen({super.key, required this.clientId});

  /// Path segment under `/accounts/:clientId`.
  static const route = 'team';

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final members = ref.watch(membersProvider(clientId));
    final canManage = ref.watch(canManageTeamProvider);
    final here = GoRouterState.of(context).matchedLocation;
    Future<void> refresh() => ref.refresh(membersProvider(clientId).future);

    return SpacePage(
      title: l10n.moduleTeam,
      onRefresh: refresh,
      slivers: [
        AsyncSlivers(
          value: members,
          onRetry: refresh,
          builder: (list) {
            if (list.isEmpty) {
              return MessageSliver(
                icon: Icons.groups_outlined,
                title: l10n.noTeamYet,
                hint: canManage ? l10n.noTeamYetHint : null,
              );
            }
            return PageBox(
              top: 4,
              child: ListCard(
                children: [
                  for (final member in list)
                    ListRow(
                      leading: InitialsAvatar(name: member.name),
                      title: member.name,
                      // Deactivated people recede, like the users list.
                      muted: !member.isActive,
                      subtitle: memberSummary(l10n, member),
                      onTap: () => context.push('$here/${member.userId}'),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
