import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../access/domain/entities/account_access.dart';
import '../../../access/presentation/controllers/account_access_provider.dart';
import '../../domain/entities/complaint.dart';
import '../controllers/complaints_providers.dart';
import '../widgets/complaint_labels.dart';

/// One client account's complaints: a toggle between the ones still being
/// worked on (most urgent first) and the resolved ones (latest first). New
/// ones come from the dock's "+" (`complaints.edit`).
class ComplaintsScreen extends ConsumerStatefulWidget {
  const ComplaintsScreen({super.key, required this.clientId});

  /// Path segment under `/accounts/:clientId`.
  static const route = 'complaints';

  final String clientId;

  @override
  ConsumerState<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends ConsumerState<ComplaintsScreen> {
  /// The resolved ones instead of the open ones. The whole list is already
  /// here, so this splits it on the phone.
  bool _resolved = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final clientId = widget.clientId;
    final complaints = ref.watch(complaintsProvider(clientId));
    final canEdit =
        ref
            .watch(accountAccessProvider(clientId))
            .value
            ?.can(Permissions.complaintsEdit) ??
        false;
    final here = GoRouterState.of(context).matchedLocation;
    Future<void> refresh() => ref.refresh(complaintsProvider(clientId).future);

    return SpacePage(
      title: l10n.moduleComplaints,
      onRefresh: refresh,
      slivers: [
        AsyncSlivers(
          value: complaints,
          onRetry: refresh,
          builder: (list) {
            if (list.isEmpty) {
              return MessageSliver(
                icon: Icons.report_outlined,
                title: l10n.noComplaintsYet,
                hint: canEdit ? l10n.noComplaintsYetHint : null,
              );
            }
            final open = openByUrgency(list);
            final shown = _resolved ? resolvedLatestFirst(list) : open;
            return SliverMainAxisGroup(
              slivers: [
                PageBox(
                  top: 4,
                  child: PillToggle<bool>(
                    semanticLabel: l10n.contractsFilterLabel,
                    options: {
                      false: l10n.complaintsFilterOpen(open.length),
                      true: l10n.complaintsFilterResolved,
                    },
                    selected: _resolved,
                    onChanged: (v) => setState(() => _resolved = v),
                  ),
                ),
                if (shown.isEmpty)
                  _resolved
                      ? MessageSliver(
                          icon: Icons.task_alt_rounded,
                          title: l10n.noResolvedComplaints,
                        )
                      : MessageSliver(
                          icon: Icons.task_alt_rounded,
                          title: l10n.noOpenComplaints,
                          hint: l10n.noOpenComplaintsHint,
                        )
                else
                  PageBox(
                    child: ListCard(
                      children: [
                        for (final c in shown)
                          ComplaintRow(
                            complaint: c,
                            onTap: () => context.push('$here/${c.id}'),
                          ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
