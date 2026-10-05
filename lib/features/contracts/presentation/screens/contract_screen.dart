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
import '../../di/contracts_providers.dart';
import '../../domain/entities/contract.dart';
import '../../domain/usecases/contract_usecases.dart';
import '../controllers/contracts_providers.dart';
import '../widgets/contract_status_label.dart';
import 'contracts_screen.dart';

/// One contract: its value, term and terms, who signed it, and the
/// proposal it came from. With `contract.edit` it can be edited, signed
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
enum _Busy { delete, cancel }

class _ContractScreenState extends ConsumerState<ContractScreen> {
  _Busy? _busy;

  ContractRef get _ref =>
      ContractRef(clientId: widget.clientId, contractId: widget.contractId);

  Future<bool> _confirm({
    required String title,
    required String body,
    required String action,
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
            destructive: true,
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

  Future<void> _cancel() async {
    final l10n = AppLocalizations.of(context);
    if (!await _confirm(
      title: l10n.cancelContractConfirmTitle,
      body: l10n.cancelContractConfirmBody,
      action: l10n.cancelContract,
    )) {
      return;
    }
    setState(() => _busy = _Busy.cancel);
    try {
      await ref.read(cancelContractProvider)(_ref);
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
    final c = contract.value;
    final editable = canEdit && (c?.isEditable ?? false);
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
          actions: [
            if (canEdit && (c?.canDelete ?? false))
              CircleButton.light(
                icon: Icons.delete_outline_rounded,
                tooltip: l10n.deleteContract,
                busy: _busy == _Busy.delete,
                onPressed: () => _delete(list),
              ),
            if (editable)
              CircleButton.dark(
                icon: Icons.edit_outlined,
                tooltip: l10n.editContract,
                onPressed: busy ? null : () => context.push('$here/edit'),
              ),
          ],
          slivers: [
            AsyncSlivers(
              value: contract,
              onRetry: refresh,
              builder: (c) {
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

                return SliverMainAxisGroup(
                  slivers: [
                    PageBox(top: 4, child: _ValueCard(contract: c)),
                    if (c.isCancelled)
                      PageBox(
                        child: Notice(
                          message: l10n.cancelledContractNotice,
                          tone: NoticeTone.info,
                        ),
                      ),
                    PageBox(
                      child: ListCard(
                        children: [
                          fact(
                            Icons.event_outlined,
                            l10n.contractStartLabel,
                            context.formatDate(c.startDate),
                          ),
                          fact(
                            Icons.event_busy_outlined,
                            l10n.contractExpirationLabel,
                            switch (c.expirationDate) {
                              final day? => context.formatDate(day),
                              null => null,
                            },
                          ),
                          fact(
                            Icons.payments_outlined,
                            l10n.paymentTermsLabel,
                            c.paymentTerms,
                          ),
                          fact(
                            Icons.autorenew_rounded,
                            l10n.autoRenewLabel,
                            c.autoRenew ? l10n.autoRenewOn : l10n.autoRenewOff,
                          ),
                          fact(
                            Icons.notifications_none_rounded,
                            l10n.cancellationNoticeLabel,
                            switch (c.cancellationNoticeDays) {
                              final days? => l10n.daysCount(days),
                              null => null,
                            },
                          ),
                          fact(
                            Icons.draw_outlined,
                            l10n.signatureLabel,
                            switch ((c.signedByName, c.signedDate)) {
                              (final name?, final date?) =>
                                l10n.contractSignedBy(
                                  name,
                                  context.formatDate(date),
                                ),
                              (_, final date?) => l10n.contractSignedOn(
                                context.formatDate(date),
                              ),
                              _ => l10n.contractNotSigned,
                            },
                          ),
                          if (c.proposalId case final proposalId?)
                            fact(
                              Icons.request_quote_outlined,
                              l10n.contractProposalLabel,
                              switch (c.proposalVersion) {
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
                    if (editable)
                      PageBox(
                        top: canEdit && c.canSign ? 12 : 24,
                        child: SecondaryButton(
                          label: l10n.cancelContract,
                          icon: Icons.block_rounded,
                          destructive: true,
                          onPressed: busy ? null : _cancel,
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

/// The head of the page: the value beside the status, then the term and
/// how long is left. At large text everything stacks.
class _ValueCard extends StatelessWidget {
  const _ValueCard({required this.contract});

  final Contract contract;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final c = contract;
    final amount = Text(
      context.formatMoney(c.contractValue),
      style: theme.textTheme.headlineSmall
          ?.copyWith(fontSize: 28, fontWeight: FontWeight.w800)
          .merge(moneyStyle),
    );
    final status = ContractStatusLabel(contract: c);
    // How long is left, while it still runs. Soon turns orange, with an
    // icon so it isn't color alone.
    final remaining = switch (c.daysUntilExpiration) {
      final days? when c.status == ContractStatus.active && days >= 0 => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            c.isExpiringSoon
                ? Icons.schedule_rounded
                : Icons.hourglass_empty_rounded,
            size: 16,
            color: c.isExpiringSoon
                ? context.colors.highlightInk
                : context.colors.inkMuted,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              l10n.contractDaysLeft(days),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: c.isExpiringSoon ? context.colors.highlightInk : null,
                fontWeight: c.isExpiringSoon ? FontWeight.w600 : null,
              ),
            ),
          ),
        ],
      ),
      _ => null,
    };

    return SpaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isLargeText(context)) ...[
            Align(alignment: Alignment.centerLeft, child: status),
            const SizedBox(height: 12),
            amount,
          ] else
            Row(
              children: [
                Expanded(child: amount),
                const SizedBox(width: 12),
                status,
              ],
            ),
          Text(l10n.contractValueLabel, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 14),
          Text(contractTerm(context, c), style: theme.textTheme.bodySmall),
          if (remaining != null) ...[const SizedBox(height: 6), remaining],
        ],
      ),
    );
  }
}
