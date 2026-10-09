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
import '../../../proposals/presentation/screens/proposals_screen.dart';
import '../../../proposals/presentation/widgets/line_item_row.dart';
import '../../../scopes/presentation/screens/scopes_screen.dart';
import '../../di/contracts_providers.dart';
import '../../domain/entities/contract.dart';
import '../../domain/usecases/contract_usecases.dart';
import '../controllers/contracts_providers.dart';
import '../widgets/contract_status_label.dart';
import 'contracts_screen.dart';

/// One contract: a value card (status, term, Edit), its schedule and terms,
/// then who signed it, its scopes and the proposal it came from. With `contract.edit` it can be edited, signed
/// (once) and cancelled until it's cancelled; an untouched draft can be
/// deleted.
class ContractScreen extends ConsumerStatefulWidget {
  const ContractScreen({
    super.key,
    required this.clientId,
    required this.contractId,
  });

  final String clientId;
  final String contractId;

  @override
  ConsumerState<ContractScreen> createState() => _ContractScreenState();
}

/// What's in flight: nothing else on the page starts until it settles.
enum _Busy { delete, expire, cancel }

class _ContractScreenState extends ConsumerState<ContractScreen> {
  _Busy? _busy;

  ContractRef get _ref =>
      ContractRef(clientId: widget.clientId, contractId: widget.contractId);

  Future<bool> _confirm({
    required String title,
    required String body,
    required String action,
    bool destructive = true,
  }) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(title),
        content: Text(body),
        actions: [
          adaptiveAction(
            context,
            label: l10n.keepContract,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          adaptiveAction(
            context,
            label: action,
            destructive: destructive,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    return confirmed == true && mounted;
  }

  Future<void> _showFailure(Failure f) {
    final l10n = AppLocalizations.of(context);
    return showAdaptiveDialog<void>(
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

  /// Asks first, then deletes the draft and goes back to [list].
  Future<void> _delete(String list) async {
    final l10n = AppLocalizations.of(context);
    if (!await _confirm(
      title: l10n.deleteContractConfirmTitle,
      body: l10n.deleteContractConfirmBody,
      action: l10n.deleteButton,
    )) {
      return;
    }
    setState(() => _busy = _Busy.delete);
    try {
      await ref.read(deleteContractProvider)(_ref);
      if (!mounted) return;
      // Leave before the lists reload, so this page doesn't flash "not
      // found" on its way out.
      context.go(list);
      invalidateContracts(ref, widget.clientId);
    } on Failure catch (f) {
      if (!mounted) return;
      setState(() => _busy = null);
      await _showFailure(f);
    }
  }

  /// Asks first, then runs a status change ([kind]) and reloads.
  Future<void> _changeStatus(
    _Busy kind, {
    required String title,
    required String body,
    required String action,
    required Future<Contract> Function() run,
    bool destructive = true,
  }) async {
    if (!await _confirm(
      title: title,
      body: body,
      action: action,
      destructive: destructive,
    )) {
      return;
    }
    setState(() => _busy = kind);
    try {
      await run();
      invalidateContracts(ref, widget.clientId);
    } on Failure catch (f) {
      if (mounted) await _showFailure(f);
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final key = (widget.clientId, widget.contractId);
    final contract = ref.watch(contractProvider(key));
    final access = ref.watch(accountAccessProvider(widget.clientId)).value;
    final canEdit = access?.can(Permissions.contractEdit) ?? false;
    final canViewProposals = access?.can(Permissions.proposalView) ?? false;
    final canViewScopes = access?.can(Permissions.scopeView) ?? false;
    final here = GoRouterState.of(context).matchedLocation;
    final list = here.substring(0, here.lastIndexOf('/'));
    final account = list.substring(0, list.lastIndexOf('/'));
    final busy = _busy != null;
    Future<void> refresh() => ref.refresh(contractProvider(key).future);

    return PopScope(
      canPop: !busy,
      child: AbsorbPointer(
        absorbing: busy,
        child: SpacePage(
          title: l10n.contractTitle,
          onRefresh: busy ? null : refresh,
          slivers: [
            AsyncSlivers(
              value: contract,
              onRetry: refresh,
              builder: (c) {
                final editable = canEdit && c.isEditable;
                final signature = switch ((c.signedByName, c.signedDate)) {
                  (final name?, final date?) => l10n.contractSignedBy(
                    name,
                    context.formatDate(date),
                  ),
                  (_, final date?) => l10n.contractSignedOn(
                    context.formatDate(date),
                  ),
                  _ => null,
                };

                return SliverMainAxisGroup(
                  slivers: [
                    PageBox(
                      top: 4,
                      child: _ValueCard(
                        contract: c,
                        onEdit: editable
                            ? () => context.push('$here/edit')
                            : null,
                      ),
                    ),
                    if (c.isCancelled)
                      PageBox(
                        child: Notice(
                          message: l10n.cancelledContractNotice,
                          tone: NoticeTone.info,
                        ),
                      ),
                    PageBox(
                      top: 16,
                      child: CapsHeader(l10n.contractScheduleSection),
                    ),
                    PageBox(
                      top: 0,
                      child: FactCard(
                        rows: [
                          [
                            (
                              l10n.contractStartLabel,
                              context.formatDate(c.startDate),
                            ),
                            (
                              l10n.contractExpirationLabel,
                              switch (c.expirationDate) {
                                final day? => context.formatDate(day),
                                null => null,
                              },
                            ),
                          ],
                          [
                            (l10n.paymentTermsLabel, c.paymentTerms),
                            (
                              l10n.cancellationNoticeLabel,
                              switch (c.cancellationNoticeDays) {
                                final days? => l10n.daysCount(days),
                                null => null,
                              },
                            ),
                          ],
                          [
                            (
                              l10n.autoRenewLabel,
                              c.autoRenew
                                  ? l10n.autoRenewOn
                                  : l10n.autoRenewOff,
                            ),
                          ],
                        ],
                      ),
                    ),
                    PageBox(
                      top: 16,
                      child: CapsHeader(l10n.contractExecutionSection),
                    ),
                    PageBox(
                      top: 0,
                      child: ListCard(
                        children: [
                          _Signature(text: signature),
                          // The work agreed under it, area by area.
                          if (canViewScopes)
                            FactRow(
                              label: l10n.moduleScope,
                              value: l10n.scopeOfWorkCount(c.scopeOfWorkCount),
                              onTap: () => context.push(
                                '$account/${ScopesScreen.route}'
                                '?contract=${c.id}',
                              ),
                            ),
                          if (c.proposalId case final proposalId?)
                            FactRow(
                              label: l10n.contractProposalLabel,
                              value: switch (c.proposalVersion) {
                                final v? => l10n.contractFromProposal(v),
                                null => l10n.proposalTitle,
                              },
                              onTap: canViewProposals
                                  ? () => context.push(
                                      '$account/${ProposalsScreen.route}/'
                                      '$proposalId',
                                    )
                                  : null,
                            ),
                        ],
                      ),
                    ),
                    if (canEdit && c.canSign)
                      PageBox(
                        top: 24,
                        child: PrimaryButton(
                          label: l10n.signContract,
                          icon: Icons.draw_outlined,
                          onPressed: busy
                              ? null
                              : () => context.push('$here/sign'),
                        ),
                      ),
                    // Quiet actions at the foot: closing out a contract that
                    // ran its course, cancelling, and deleting a draft.
                    if ((canEdit && c.canMarkExpired) ||
                        editable ||
                        (canEdit && c.canDelete))
                      PageBox(
                        top: c.canSign && canEdit ? 12 : 20,
                        child: Column(
                          children: [
                            if (canEdit && c.canMarkExpired)
                              LinkButton(
                                label: l10n.markExpired,
                                icon: Icons.event_busy_outlined,
                                onPressed: busy
                                    ? null
                                    : () => _changeStatus(
                                        _Busy.expire,
                                        title: l10n.markExpiredConfirmTitle,
                                        body: l10n.markExpiredConfirmBody,
                                        action: l10n.markExpired,
                                        destructive: false,
                                        run: () => ref.read(
                                          markContractExpiredProvider,
                                        )(_ref),
                                      ),
                              ),
                            if (editable)
                              LinkButton(
                                label: l10n.cancelContract,
                                icon: Icons.block_rounded,
                                destructive: true,
                                onPressed: busy
                                    ? null
                                    : () => _changeStatus(
                                        _Busy.cancel,
                                        title: l10n.cancelContractConfirmTitle,
                                        body: l10n.cancelContractConfirmBody,
                                        action: l10n.cancelContract,
                                        run: () => ref.read(
                                          cancelContractProvider,
                                        )(_ref),
                                      ),
                              ),
                            if (canEdit && c.canDelete)
                              LinkButton(
                                label: l10n.deleteContract,
                                icon: Icons.delete_outline_rounded,
                                destructive: true,
                                onPressed: busy ? null : () => _delete(list),
                              ),
                          ],
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

/// The head of the page: the value with the status under it and Edit at
/// the corner, then the term ("Oct 4 – Oct 5, 2026 · Term: 1 day") and how
/// long is left.
class _ValueCard extends StatelessWidget {
  const _ValueCard({required this.contract, required this.onEdit});

  final Contract contract;

  /// Null hides Edit.
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final c = contract;
    final large = isLargeText(context);
    final amount = Text(
      context.formatMoney(c.contractValue),
      style: theme.textTheme.headlineSmall
          ?.copyWith(fontSize: 32, fontWeight: FontWeight.w800)
          .merge(moneyStyle),
    );
    final edit = switch (onEdit) {
      final onEdit? => PillButton(
        label: l10n.editButton,
        icon: Icons.edit_outlined,
        tooltip: l10n.editContract,
        onPressed: onEdit,
      ),
      null => null,
    };
    final term = switch (c.term) {
      final t? => l10n.contractTermLength(switch (t.unit) {
        TermUnit.days => l10n.daysCount(t.count),
        TermUnit.months => l10n.monthsCount(t.count),
        TermUnit.years => l10n.yearsCount(t.count),
      }),
      null => null,
    };
    final range = Row(
      children: [
        // A bullet beside one line; at large text the range wraps, so it
        // would float beside two.
        if (!large) ...[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: context.colors.inkFaint,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Text(
            contractTerm(context, c),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: context.colors.ink,
            ),
          ),
        ),
      ],
    );
    final termText = term == null
        ? null
        : Text(
            term,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: context.colors.inkMuted,
            ),
          );
    // How long is left while it runs: orange when soon, red once past the
    // end while still active, each with an icon so it isn't color alone.
    final remaining = switch ((c.daysUntilExpiration, c.expirationDate)) {
      (final days?, final end?) when c.status == ContractStatus.active =>
        switch (days) {
          < 0 => _Remaining(
            icon: Icons.error_outline_rounded,
            label: l10n.contractEndedOn(context.formatDate(end)),
            color: context.colors.danger,
            strong: true,
          ),
          _ => _Remaining(
            icon: c.isExpiringSoon
                ? Icons.schedule_rounded
                : Icons.hourglass_empty_rounded,
            label: l10n.contractDaysLeft(days),
            color: c.isExpiringSoon
                ? context.colors.highlightInk
                : context.colors.inkMuted,
            strong: c.isExpiringSoon,
          ),
        },
      _ => null,
    };

    return SpaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: amount),
              if (edit != null && !large) ...[const SizedBox(width: 12), edit],
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: ContractStatusLabel(contract: c),
          ),
          const SizedBox(height: 12),
          CapsHeader(l10n.contractValueLabel, header: false),
          if (edit != null && large) ...[
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerLeft, child: edit),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(),
          ),
          if (termText == null)
            range
          else if (large) ...[
            range,
            const SizedBox(height: 4),
            termText,
          ] else
            Row(
              children: [
                Expanded(child: range),
                const SizedBox(width: 12),
                termText,
              ],
            ),
          if (remaining != null) ...[const SizedBox(height: 8), remaining],
        ],
      ),
    );
  }
}

/// Who signed and when, with a green check; "Not signed yet", muted,
/// before.
class _Signature extends StatelessWidget {
  const _Signature({required this.text});

  /// Null until signed.
  final String? text;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final text = this.text;
    return MergeSemantics(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 60,
          minWidth: double.infinity,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpaceSpace.card,
            vertical: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text ?? l10n.contractNotSigned,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: text == null ? FontWeight.w500 : FontWeight.w700,
                  color: text == null ? context.colors.inkMuted : null,
                ),
              ),
              if (text != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: context.colors.successInk,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        l10n.contractSignedMark,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: context.colors.successInk,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A line with an icon about how long the contract has left.
class _Remaining extends StatelessWidget {
  const _Remaining({
    required this.icon,
    required this.label,
    required this.color,
    this.strong = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool strong;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: strong ? color : null,
            fontWeight: strong ? FontWeight.w600 : null,
          ),
        ),
      ),
    ],
  );
}
