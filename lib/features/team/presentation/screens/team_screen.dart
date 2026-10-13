import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/l10n/role_names.dart';
import '../../../../core/search/text_search.dart';
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

/// Whether [query] appears in [m]'s name, email or role on the account.
bool matchesMember(AppLocalizations l10n, Member m, String query) =>
    matchesSearch(query, [m.name, m.email, memberSummary(l10n, m)]);

/// Who works on one client account (`team.view`), with a search. Owners
/// add people from the dock's "+".
class TeamScreen extends ConsumerStatefulWidget {
  const TeamScreen({super.key, required this.clientId});

  /// Path segment under `/accounts/:clientId`.
  static const route = 'team';

  final String clientId;

  @override
  ConsumerState<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends ConsumerState<TeamScreen> {
  final _search = TextEditingController();

  /// The API can't search members, but the whole list is already here.
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final clientId = widget.clientId;
    final members = ref.watch(membersProvider(clientId));
    final canManage = ref.watch(canManageTeamProvider);
    final here = GoRouterState.of(context).matchedLocation;
    Future<void> refresh() => ref.refresh(membersProvider(clientId).future);

    return SpacePage(
      title: l10n.moduleTeam,
      onRefresh: refresh,
      slivers: [
        PageBox(
          top: 4,
          child: SearchField(
            controller: _search,
            hint: l10n.searchTeamHint,
            onChanged: (text) => setState(() => _query = text),
          ),
        ),
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
            final found = list
                .where((m) => matchesMember(l10n, m, _query))
                .toList();
            if (found.isEmpty) {
              return MessageSliver(
                icon: Icons.groups_outlined,
                title: l10n.noMatchesFound,
                hint: l10n.noMatchesHint,
              );
            }
            return PageBox(
              child: ListCard(
                children: [
                  for (final member in found)
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
