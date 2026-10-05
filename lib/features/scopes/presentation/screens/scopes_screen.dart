import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../access/domain/entities/account_access.dart';
import '../../../access/presentation/controllers/account_access_provider.dart';
import '../../domain/entities/scope.dart';
import '../../domain/usecases/scope_usecases.dart';
import '../controllers/scopes_providers.dart';
import '../widgets/scope_labels.dart';

/// One client account's scopes of work, grouped by location: each area,
/// how often, and when. With [contractId], only that contract's. New ones
/// come from the dock's "+" (`scope.edit`).
class ScopesScreen extends ConsumerWidget {
  const ScopesScreen({super.key, required this.clientId, this.contractId});

  /// Path segment under `/accounts/:clientId`.
  static const route = 'scopes';

  final String clientId;

  /// Only this contract's scopes (`?contract=`).
  final String? contractId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final query = ScopeQuery(clientId: clientId, contractId: contractId);
    final scopes = ref.watch(scopesProvider(query));
    final canEdit =
        ref
            .watch(accountAccessProvider(clientId))
            .value
            ?.can(Permissions.scopeEdit) ??
        false;
    final here = GoRouterState.of(context).matchedLocation;
    Future<void> refresh() => ref.refresh(scopesProvider(query).future);

    return SpacePage(
      title: l10n.moduleScope,
      onRefresh: refresh,
      slivers: [
        if (contractId != null)
          PageBox(
            top: 4,
            child: Notice(
              message: l10n.scopesOfOneContract,
              tone: NoticeTone.info,
            ),
          ),
        AsyncSlivers(
          value: scopes,
          onRetry: refresh,
          builder: (list) {
            if (list.isEmpty) {
              return MessageSliver(
                icon: Icons.checklist_rtl_rounded,
                title: l10n.noScopesYet,
                hint: canEdit ? l10n.noScopesYetHint : null,
              );
            }
            // By location, in the server's order (location, then area).
            final byLocation = <String, List<Scope>>{};
            for (final s in list) {
              (byLocation[s.locationId] ??= []).add(s);
            }
            return SliverMainAxisGroup(
              slivers: [
                for (final group in byLocation.values) ...[
                  PageBox(
                    child: SectionHeader(
                      title: group.first.locationName ?? l10n.notSet,
                    ),
                  ),
                  PageBox(
                    top: 0,
                    child: ListCard(
                      children: [
                        for (final s in group)
                          ScopeRow(
                            scope: s,
                            onTap: () => context.push('$here/${s.id}'),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

/// A scope as a list row: the area, its first time window (and how many
/// more), and the frequency as a pill.
class ScopeRow extends StatelessWidget {
  const ScopeRow({super.key, required this.scope, this.onTap});

  final Scope scope;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final s = scope;
    final active = s.schedules.where((w) => w.isActive).toList();
    return ListRow(
      leading: const IconBadge(icon: Icons.checklist_rtl_rounded),
      title: scopeTitle(l10n, s),
      subtitle: switch (active) {
        [] => l10n.noTimeWindows,
        [final only] => scheduleSummary(context, s.frequency, only),
        [final first, ...final rest] => l10n.scheduleAndMore(
          scheduleSummary(context, s.frequency, first),
          rest.length,
        ),
      },
      muted: active.isEmpty,
      tag: FrequencyLabel(frequency: s.frequency),
      onTap: onTap,
    );
  }
}
