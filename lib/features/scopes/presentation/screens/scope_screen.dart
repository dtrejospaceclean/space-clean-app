import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../core/widgets/adaptive.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../access/domain/entities/account_access.dart';
import '../../../access/presentation/controllers/account_access_provider.dart';
import '../../../contracts/presentation/controllers/contracts_providers.dart';
import '../../../contracts/presentation/screens/contracts_screen.dart';
import '../../../proposals/presentation/widgets/line_item_row.dart';
import '../../di/scopes_providers.dart';
import '../../domain/entities/scope.dart';
import '../../domain/usecases/scope_usecases.dart';
import '../controllers/scopes_providers.dart';
import '../widgets/scope_labels.dart';

/// One scope of work: where, what and how often, its time windows, and
/// the contract it falls under. With `scope.edit` it can be edited, and
/// deleted until it produces jobs.
class ScopeScreen extends ConsumerStatefulWidget {
  const ScopeScreen({super.key, required this.clientId, required this.scopeId});

  final String clientId;
  final String scopeId;

  @override
  ConsumerState<ScopeScreen> createState() => _ScopeScreenState();
}

class _ScopeScreenState extends ConsumerState<ScopeScreen> {
  /// While the delete is in flight, nothing else on the page starts.
  bool _deleting = false;

  /// Asks first, then deletes the scope and goes back to [list].
  Future<void> _delete(String list) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(l10n.deleteScopeConfirmTitle),
        content: Text(l10n.deleteScopeConfirmBody),
        actions: [
          adaptiveAction(
            context,
            label: l10n.cancelButton,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          adaptiveAction(
            context,
            label: l10n.deleteButton,
            destructive: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _deleting = true);
    try {
      await ref.read(deleteScopeProvider)(
        ScopeRef(clientId: widget.clientId, scopeId: widget.scopeId),
      );
      if (!mounted) return;
      // Leave before the lists reload, so this page doesn't flash "not
      // found" on its way out.
      context.go(list);
      invalidateScopes(ref);
      invalidateContracts(ref, widget.clientId);
    } on Failure catch (f) {
      if (!mounted) return;
      setState(() => _deleting = false);
      await showAdaptiveDialog<void>(
        context: context,
        builder: (context) => AlertDialog.adaptive(
          content: Text(l10n.failureMessage(f)),
          actions: [
            adaptiveAction(
              context,
              label: l10n.doneButton,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final key = (widget.clientId, widget.scopeId);
    final scope = ref.watch(scopeProvider(key));
    final access = ref.watch(accountAccessProvider(widget.clientId)).value;
    final canEdit = access?.can(Permissions.scopeEdit) ?? false;
    final canViewContracts = access?.can(Permissions.contractView) ?? false;
    final here = GoRouterState.of(context).matchedLocation;
    final list = here.substring(0, here.lastIndexOf('/'));
    final account = list.substring(0, list.lastIndexOf('/'));
    Future<void> refresh() => ref.refresh(scopeProvider(key).future);

    return PopScope(
      canPop: !_deleting,
      child: AbsorbPointer(
        absorbing: _deleting,
        child: SpacePage(
          title: l10n.scopeTitle,
          onRefresh: _deleting ? null : refresh,
          actions: [
            if (canEdit && (scope.value?.canDelete ?? false))
              CircleButton.light(
                icon: Icons.delete_outline_rounded,
                tooltip: l10n.deleteScope,
                busy: _deleting,
                onPressed: () => _delete(list),
              ),
            if (canEdit && scope.hasValue)
              CircleButton.dark(
                icon: Icons.edit_outlined,
                tooltip: l10n.editScope,
                onPressed: _deleting ? null : () => context.push('$here/edit'),
              ),
          ],
          slivers: [
            AsyncSlivers(
              value: scope,
              onRetry: refresh,
              builder: (s) {
                ListRow fact(
                  IconData icon,
                  String label,
                  String? value, {
                  VoidCallback? onTap,
                }) => ListRow(
                  leading: IconBadge(icon: icon),
                  title: value ?? l10n.notSet,
                  subtitle: label,
                  muted: value == null,
                  onTap: onTap,
                );
                String? text(String? v) =>
                    v == null || v.trim().isEmpty ? null : v.trim();
                final contractTerm = switch ((s.contractStart, s.contractEnd)) {
                  (final start?, final end?) =>
                    '${context.formatDate(start)} – ${context.formatDate(end)}',
                  (final start?, null) => l10n.contractFrom(
                    context.formatDate(start),
                  ),
                  _ => l10n.contractTitle,
                };

                return SliverMainAxisGroup(
                  slivers: [
                    PageBox(top: 4, child: _HeadCard(scope: s)),
                    PageBox(
                      child: SectionHeader(title: l10n.sectionTimeWindows),
                    ),
                    PageBox(
                      top: 0,
                      child: ListCard(
                        children: [
                          if (s.schedules.isEmpty)
                            ListRow(title: l10n.noTimeWindows, muted: true),
                          for (final w in s.schedules)
                            ListRow(
                              leading: const IconBadge(
                                icon: Icons.schedule_rounded,
                              ),
                              title: scheduleTimes(context, w),
                              subtitle:
                                  s.frequency.needsDays &&
                                      w.daysOfWeek.isNotEmpty
                                  ? scheduleDays(context, w)
                                  : null,
                              muted: !w.isActive,
                              trailing: w.isActive
                                  ? null
                                  : Text(l10n.timeWindowPaused),
                            ),
                        ],
                      ),
                    ),
                    PageBox(
                      top: 24,
                      child: ListCard(
                        children: [
                          fact(
                            Icons.timer_outlined,
                            l10n.estimatedDurationLabel,
                            switch (s.estimatedDurationMinutes) {
                              final m? => l10n.minutesCount(m),
                              null => null,
                            },
                          ),
                          fact(
                            Icons.assignment_outlined,
                            l10n.instructionsLabel,
                            text(s.instructions),
                          ),
                          fact(
                            Icons.do_not_disturb_on_outlined,
                            l10n.exclusionsLabel,
                            text(s.exclusions),
                          ),
                          fact(
                            Icons.inventory_2_outlined,
                            l10n.requiredSuppliesLabel,
                            text(s.requiredSupplies),
                          ),
                          fact(
                            Icons.history_edu_outlined,
                            l10n.contractTitle,
                            contractTerm,
                            onTap: canViewContracts
                                ? () => context.push(
                                    '$account/${ContractsScreen.route}/'
                                    '${s.contractId}',
                                  )
                                : null,
                          ),
                          fact(
                            Icons.cleaning_services_outlined,
                            l10n.moduleJobs,
                            l10n.jobCount(s.jobCount),
                          ),
                        ],
                      ),
                    ),
                    if (canEdit && !s.canDelete)
                      PageBox(
                        top: 16,
                        child: Text(
                          l10n.scopeHasJobsNote,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// The head of the page: the area beside the frequency, then the location
/// and the service. At large text the pill moves above the title.
class _HeadCard extends StatelessWidget {
  const _HeadCard({required this.scope});

  final Scope scope;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = scope;
    final title = Text(
      scopeTitle(l10n, s),
      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
    );
    final pill = FrequencyLabel(frequency: s.frequency);
    final large = isLargeText(context);
    Widget line(IconData icon, String value) => Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 16, color: context.colors.inkMuted),
          ),
          const SizedBox(width: 6),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );

    return SpaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (large) ...[
            Align(alignment: Alignment.centerLeft, child: pill),
            const SizedBox(height: 10),
            title,
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: title),
                const SizedBox(width: 12),
                pill,
              ],
            ),
          line(
            Icons.location_on_outlined,
            [
              s.locationName ?? l10n.notSet,
              if (s.locationCity case final city? when city.isNotEmpty) city,
            ].join(' · '),
          ),
          if (s.serviceName case final service?)
            line(Icons.design_services_outlined, service),
        ],
      ),
    );
  }
}
