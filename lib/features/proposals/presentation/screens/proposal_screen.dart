import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../access/domain/entities/account_access.dart';
import '../../../access/presentation/controllers/account_access_provider.dart';
import '../../../jobs/presentation/controllers/jobs_providers.dart';
import '../controllers/proposals_providers.dart';
import '../widgets/line_item_row.dart';
import '../widgets/proposal_stage_label.dart';

/// One version of a negotiation: its stage and price, the line items, and
/// every version of it. With `proposal.edit`, the current version can be
/// edited, built on with a new version, or approved until it's approved;
/// earlier versions are read-only history.
class ProposalScreen extends ConsumerWidget {
  const ProposalScreen({
    super.key,
    required this.clientId,
    required this.proposalId,
  });

  final String clientId;
  final String proposalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final key = (clientId, proposalId);
    final proposal = ref.watch(proposalProvider(key));
    final versions = ref.watch(proposalVersionsProvider(key)).value ?? [];
    final canEdit =
        ref
            .watch(accountAccessProvider(clientId))
            .value
            ?.can(Permissions.proposalEdit) ??
        false;
    final open = canEdit && (proposal.value?.isOpen ?? false);
    final now = ref.watch(clockProvider)();
    final today = DateTime(now.year, now.month, now.day);
    final here = GoRouterState.of(context).matchedLocation;
    // The list this version sits under, for its sibling versions.
    final list = here.substring(0, here.lastIndexOf('/'));
    Future<void> refresh() {
      ref.invalidate(proposalVersionsProvider(key));
      return ref.refresh(proposalProvider(key).future);
    }

    return SpacePage(
      title: l10n.proposalTitle,
      onRefresh: refresh,
      actions: [
        if (open)
          CircleButton.dark(
            icon: Icons.edit_outlined,
            tooltip: l10n.editProposal,
            onPressed: () => context.push('$here/edit'),
          ),
      ],
      slivers: [
        AsyncSlivers(
          value: proposal,
          onRetry: refresh,
          builder: (p) {
            ListRow fact(IconData icon, String label, String? value) => ListRow(
              leading: IconBadge(icon: icon),
              title: value ?? l10n.notSet,
              subtitle: label,
              muted: value == null,
            );
            final expired =
                p.isOpen &&
                p.validUntil != null &&
                p.validUntil!.isBefore(today);

            return SliverMainAxisGroup(
              slivers: [
                PageBox(
                  top: 4,
                  child: SpaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProposalStageLabel(stage: p.stage),
                        const SizedBox(height: 12),
                        if (p.hasPrice) ...[
                          Text(
                            context.formatMoney(p.price),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                          Text(
                            p.agreedPrice == null
                                ? l10n.lineItemsTotalLabel
                                : l10n.agreedPriceLabel,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ] else
                          Text(
                            l10n.noPriceYet,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: context.colors.inkMuted,
                            ),
                          ),
                        const SizedBox(height: 12),
                        // Which version and when, then who: two short lines
                        // that never break mid-phrase.
                        Text(
                          [
                            l10n.proposalVersion(p.versionNumber),
                            if (p.createdAt case final at?)
                              context.formatDate(at),
                          ].join(' · '),
                          style: theme.textTheme.bodySmall,
                        ),
                        if (p.preparedByName case final name?)
                          Text(
                            l10n.proposalPreparedBy(name),
                            style: theme.textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                ),
                if (!p.isCurrent)
                  PageBox(
                    child: Notice(
                      message: l10n.olderVersionNotice,
                      tone: NoticeTone.info,
                    ),
                  ),
                PageBox(
                  child: ListCard(
                    children: [
                      fact(
                        Icons.event_outlined,
                        expired ? l10n.proposalExpired : l10n.validUntilLabel,
                        switch (p.validUntil) {
                          final day? => context.formatDate(day),
                          null => null,
                        },
                      ),
                      // Once agreed, the price heads the page already.
                      if (p.agreedPrice == null)
                        fact(
                          Icons.handshake_outlined,
                          l10n.agreedPriceLabel,
                          null,
                        ),
                      if (p.versionNote case final note?
                          when note.trim().isNotEmpty)
                        fact(
                          Icons.sticky_note_2_outlined,
                          l10n.versionNoteLabel,
                          note,
                        ),
                      if (p.isApproved)
                        ListRow(
                          leading: const IconBadge(
                            icon: Icons.verified_outlined,
                          ),
                          title: switch ((p.approvedByName, p.approvedDate)) {
                            (final name?, final date?) =>
                              l10n.proposalApprovedBy(
                                name,
                                context.formatDate(date),
                              ),
                            (_, final date?) => l10n.proposalApprovedOn(
                              context.formatDate(date),
                            ),
                            _ => l10n.proposalStageApproved,
                          },
                        ),
                    ],
                  ),
                ),
                PageBox(child: SectionHeader(title: l10n.sectionLineItems)),
                PageBox(
                  top: 0,
                  child: ListCard(
                    children: [
                      for (final item in p.lineItems) item.row(),
                      ListRow(
                        title: l10n.lineItemsTotalLabel,
                        muted: p.lineItems.isEmpty,
                        trailing: Text(
                          context.formatMoney(p.lineItemsTotal),
                          style: theme.textTheme.titleMedium?.merge(moneyStyle),
                        ),
                      ),
                    ],
                  ),
                ),
                if (open) ...[
                  PageBox(
                    top: 24,
                    child: PrimaryButton(
                      label: l10n.approveButton,
                      icon: Icons.check_rounded,
                      onPressed: () => context.push('$here/approve'),
                    ),
                  ),
                  PageBox(
                    child: SecondaryButton(
                      label: l10n.newVersionTitle,
                      icon: Icons.add_rounded,
                      onPressed: () => context.push('$here/version'),
                    ),
                  ),
                ] else if (canEdit && p.isApproved)
                  PageBox(
                    top: 16,
                    child: Text(
                      l10n.approvedProposalNote,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                // History, once there's more than this version.
                if (versions.length > 1) ...[
                  PageBox(
                    top: 24,
                    child: SectionHeader(title: l10n.sectionVersions),
                  ),
                  PageBox(
                    top: 0,
                    child: ListCard(
                      children: [
                        for (final v in versions)
                          ListRow(
                            leading: IconBadge(
                              icon: v.id == p.id
                                  ? Icons.visibility_outlined
                                  : Icons.history_rounded,
                            ),
                            title: l10n.proposalVersion(v.versionNumber),
                            subtitle: [
                              context.formatMoney(v.price),
                              if (v.versionNote case final note?
                                  when note.trim().isNotEmpty)
                                note,
                            ].join(' · '),
                            trailing: v.isCurrent
                                ? Text(l10n.currentVersionTag)
                                : null,
                            onTap: v.id == p.id
                                ? null
                                : () => context.push('$list/${v.id}'),
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
