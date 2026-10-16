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
import '../../../contracts/presentation/screens/contracts_screen.dart';
import '../../../jobs/presentation/controllers/jobs_providers.dart';
import '../../di/proposals_providers.dart';
import '../../domain/entities/proposal.dart';
import '../../domain/usecases/proposal_usecases.dart';
import '../controllers/proposals_providers.dart';
import '../widgets/line_item_row.dart';
import '../widgets/proposal_stage_label.dart';
import 'proposal_pdf_screen.dart';
import 'send_proposal_screen.dart';

/// One version of a negotiation: its stage and price, the line items, and
/// every version of it. With `proposal.edit`, the current version can be
/// edited, built on with a new version, approved, or deleted (every
/// version) until it's approved; earlier versions are read-only history.
class ProposalScreen extends ConsumerStatefulWidget {
  const ProposalScreen({
    super.key,
    required this.clientId,
    required this.proposalId,
  });

  final String clientId;
  final String proposalId;

  @override
  ConsumerState<ProposalScreen> createState() => _ProposalScreenState();
}

class _ProposalScreenState extends ConsumerState<ProposalScreen> {
  /// While the delete is in flight: the trash button spins, and nothing
  /// else on the page (edit, back) can start.
  bool _deleting = false;

  /// Who the last send went to, shown until the page is left.
  List<String>? _sentTo;

  /// Opens the send page, and says who it went to once it's back.
  Future<void> _openSend(String here) async {
    final sentTo = await context.push<List<String>>(
      '$here/${SendProposalScreen.route}',
    );
    if (sentTo != null && mounted) setState(() => _sentTo = sentTo);
  }

  /// Asks first, then deletes the whole negotiation and goes back to [list].
  Future<void> _delete(String list) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(l10n.deleteProposalConfirmTitle),
        content: Text(l10n.deleteProposalConfirmBody),
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
      await ref.read(deleteProposalProvider)(
        ProposalRef(clientId: widget.clientId, proposalId: widget.proposalId),
      );
      if (!mounted) return;
      // Leave before the lists reload, so this page doesn't flash "not
      // found" on its way out.
      context.go(list);
      invalidateProposals(ref, widget.clientId);
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
    final key = (widget.clientId, widget.proposalId);
    final proposal = ref.watch(proposalProvider(key));
    final versions = ref.watch(proposalVersionsProvider(key)).value ?? [];
    final access = ref.watch(accountAccessProvider(widget.clientId)).value;
    final canEdit = access?.can(Permissions.proposalEdit) ?? false;
    final canContract = access?.can(Permissions.contractEdit) ?? false;
    final open = canEdit && (proposal.value?.isOpen ?? false);
    final now = ref.watch(clockProvider)();
    final today = DateTime(now.year, now.month, now.day);
    final here = GoRouterState.of(context).matchedLocation;
    // The list this version sits under, for its sibling versions.
    final list = here.substring(0, here.lastIndexOf('/'));
    final account = list.substring(0, list.lastIndexOf('/'));
    Future<void> refresh() {
      ref.invalidate(proposalVersionsProvider(key));
      return ref.refresh(proposalProvider(key).future);
    }

    // Nothing else starts (back, edit, the page's buttons) until the
    // delete settles.
    return PopScope(
      canPop: !_deleting,
      child: AbsorbPointer(
        absorbing: _deleting,
        child: SpacePage(
          title: l10n.proposalTitle,
          onRefresh: _deleting ? null : refresh,
          actions: [
            // Deleting takes every version, so only while none is approved.
            if (open && !versions.any((v) => v.isApproved))
              CircleButton.light(
                icon: Icons.delete_outline_rounded,
                tooltip: l10n.deleteProposal,
                busy: _deleting,
                onPressed: () => _delete(list),
              ),
            if (open)
              CircleButton.dark(
                icon: Icons.edit_outlined,
                tooltip: l10n.editProposal,
                onPressed: _deleting ? null : () => context.push('$here/edit'),
              ),
          ],
          slivers: [
            AsyncSlivers(
              value: proposal,
              skeleton: SkeletonLayout.detail,
              onRetry: refresh,
              builder: (p) {
                ListRow fact(IconData icon, String label, String? value) =>
                    ListRow(
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
                      child: _PriceCard(
                        proposal: p,
                        expired: expired,
                        onViewPdf: () =>
                            context.push('$here/${ProposalPdfScreen.route}'),
                        // Only the current version is emailed.
                        onSend: canEdit && p.isCurrent
                            ? () => _openSend(here)
                            : null,
                      ),
                    ),
                    // Right under the card whose button sent it.
                    if (_sentTo case final sentTo?)
                      PageBox(
                        child: Notice(
                          message: l10n.proposalSentTo(sentTo.join(', ')),
                          tone: NoticeTone.success,
                        ),
                      ),
                    if (!p.isCurrent)
                      PageBox(
                        child: Notice(
                          message: l10n.olderVersionNotice,
                          tone: NoticeTone.info,
                        ),
                      ),
                    if (p.agreedPrice == null ||
                        (p.versionNote?.trim().isNotEmpty ?? false) ||
                        p.isApproved)
                      PageBox(
                        child: ListCard(
                          children: [
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
                                title: switch ((
                                  p.approvedByName,
                                  p.approvedDate,
                                )) {
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
                              style: theme.textTheme.titleMedium?.merge(
                                moneyStyle,
                              ),
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
                    // What an approved proposal leads to.
                    if (canContract && p.isApproved)
                      PageBox(
                        top: 24,
                        child: PrimaryButton(
                          label: l10n.createContract,
                          icon: Icons.history_edu_outlined,
                          onPressed: () => context.push(
                            '$account/${ContractsScreen.route}/new'
                            '?proposal=${p.id}',
                          ),
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
        ),
      ),
    );
  }
}

/// The head of the page: the price on the left; the stage and how long
/// the price holds on the right; then the version and who prepared it, with
/// the PDF and email buttons at its end. At large text everything stacks,
/// so neither side is squeezed.
class _PriceCard extends StatelessWidget {
  const _PriceCard({
    required this.proposal,
    required this.expired,
    required this.onViewPdf,
    this.onSend,
  });

  final Proposal proposal;

  /// Past its valid-until date while still open.
  final bool expired;

  final VoidCallback onViewPdf;

  /// Null hides the email button.
  final VoidCallback? onSend;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final p = proposal;
    final large = isLargeText(context);

    final amount = p.hasPrice
        ? Text(
            context.formatMoney(p.price),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          )
        : Text(
            l10n.noPriceYet,
            style: theme.textTheme.titleLarge?.copyWith(
              color: context.colors.inkMuted,
            ),
          );
    final caption = p.hasPrice
        ? Text(
            p.agreedPrice == null
                ? l10n.lineItemsTotalLabel
                : l10n.agreedPriceLabel,
            style: theme.textTheme.bodyMedium,
          )
        : null;
    // How long the price holds. Past the date on an open proposal it turns
    // red, with an alert icon so it isn't color alone.
    final validUntil = switch (p.validUntil) {
      final day? => _ValidUntil(
        label: expired
            ? l10n.proposalExpiredOn(context.formatDate(day))
            : l10n.proposalValidUntil(context.formatDate(day)),
        expired: expired,
        alignEnd: !large,
      ),
      null => null,
    };
    final stage = ProposalStageLabel(stage: p.stage);
    final small = theme.textTheme.bodySmall;

    return SpaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (large) ...[
            Align(alignment: Alignment.centerLeft, child: stage),
            const SizedBox(height: 12),
            amount,
            ?caption,
            if (validUntil != null) ...[const SizedBox(height: 10), validUntil],
          ] else ...[
            // Two rows, so each side lines up with the other: the price
            // beside the stage, then its label beside the date.
            Row(
              children: [
                Expanded(child: amount),
                const SizedBox(width: 12),
                stage,
              ],
            ),
            if (caption != null || validUntil != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: caption ?? const SizedBox.shrink()),
                  const SizedBox(width: 12),
                  // At most half the card, so a long date wraps instead of
                  // pushing the label.
                  Flexible(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: validUntil ?? const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
          ],
          const SizedBox(height: 14),
          // Which version and when, then who. Each phrase stays whole and
          // drops to the next line when there's no room; the document's
          // buttons keep the end of the row.
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 2,
                  children: [
                    Text(
                      [
                        l10n.proposalVersion(p.versionNumber),
                        if (p.createdAt case final at?) context.formatDate(at),
                      ].join(' · '),
                      style: small,
                    ),
                    if (p.preparedByName case final name?)
                      Text(l10n.proposalPreparedBy(name), style: small),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              CircleButton.flat(
                icon: Icons.picture_as_pdf_outlined,
                tooltip: l10n.viewPdf,
                onPressed: onViewPdf,
              ),
              if (onSend case final send?) ...[
                CircleButton.flat(
                  icon: Icons.send_outlined,
                  tooltip: l10n.sendByEmail,
                  onPressed: send,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// "Valid until Oct 31, 2026", or "Expired …" in red.
class _ValidUntil extends StatelessWidget {
  const _ValidUntil({
    required this.label,
    required this.expired,
    this.alignEnd = false,
  });

  final String label;
  final bool expired;

  /// Right-aligned, for the right side of the card.
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final color = expired ? context.colors.danger : context.colors.inkMuted;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(
            expired ? Icons.error_outline_rounded : Icons.event_outlined,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            textAlign: alignEnd ? TextAlign.end : TextAlign.start,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: expired ? FontWeight.w600 : null,
            ),
          ),
        ),
      ],
    );
  }
}
