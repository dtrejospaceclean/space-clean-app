import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../access/domain/entities/account_access.dart';
import '../../../access/presentation/controllers/account_access_provider.dart';
import '../../../proposals/presentation/widgets/line_item_row.dart';
import '../../domain/entities/contract.dart';
import '../controllers/contracts_providers.dart';
import '../widgets/contract_status_label.dart';

/// One client account's contracts, latest start first, each with its status
/// and value. A toggle narrows them to the ones expiring within 30 days.
/// New ones come from the dock's "+" (`contract.edit`) or from an approved
/// proposal.
class ContractsScreen extends ConsumerStatefulWidget {
  const ContractsScreen({super.key, required this.clientId});

  /// Path segment under `/accounts/:clientId`.
  static const route = 'contracts';

  final String clientId;

  @override
  ConsumerState<ContractsScreen> createState() => _ContractsScreenState();
}

class _ContractsScreenState extends ConsumerState<ContractsScreen> {
  /// Only the ones expiring soon. The whole list is already here, so this
  /// filters on the phone.
  bool _expiringOnly = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final clientId = widget.clientId;
    final contracts = ref.watch(contractsProvider(clientId));
    final canEdit =
        ref
            .watch(accountAccessProvider(clientId))
            .value
            ?.can(Permissions.contractEdit) ??
        false;
    final here = GoRouterState.of(context).matchedLocation;
    Future<void> refresh() => ref.refresh(contractsProvider(clientId).future);

    return SpacePage(
      title: l10n.moduleContracts,
      onRefresh: refresh,
      slivers: [
        AsyncSlivers(
          value: contracts,
          onRetry: refresh,
          builder: (list) {
            if (list.isEmpty) {
              return MessageSliver(
                icon: Icons.history_edu_outlined,
                title: l10n.noContractsYet,
                hint: canEdit ? l10n.noContractsYetHint : null,
              );
            }
            final expiring = list.where((c) => c.isExpiringSoon).length;
            final shown = _expiringOnly
                ? list.where((c) => c.isExpiringSoon).toList()
                : list;
            return SliverMainAxisGroup(
              slivers: [
                PageBox(
                  top: 4,
                  child: PillToggle<bool>(
                    semanticLabel: l10n.contractsFilterLabel,
                    options: {
                      false: l10n.contractsFilterAll,
                      true: l10n.contractsFilterExpiring(expiring),
                    },
                    selected: _expiringOnly,
                    onChanged: (v) => setState(() => _expiringOnly = v),
                  ),
                ),
                if (shown.isEmpty)
                  MessageSliver(
                    icon: Icons.event_available_outlined,
                    title: l10n.noContractsExpiring,
                    hint: l10n.noContractsExpiringHint,
                  )
                else
                  PageBox(
                    child: ListCard(
                      children: [
                        for (final c in shown)
                          ContractRow(
                            contract: c,
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

/// A contract as a list row: its term, where it came from, its status as a
/// pill, and its value.
class ContractRow extends StatelessWidget {
  const ContractRow({super.key, required this.contract, this.onTap});

  final Contract contract;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = contract;
    final largeText = isLargeText(context);
    final value = context.formatMoney(c.contractValue);
    // Like proposals: the value trails, or moves under the title at large
    // text so the title keeps the width to wrap.
    final details = [
      if (largeText) value,
      if (c.proposalVersion case final v?)
        l10n.contractFromProposal(v)
      else
        ?c.paymentTerms,
    ];
    return ListRow(
      leading: const IconBadge(icon: Icons.history_edu_outlined),
      title: contractTerm(context, c),
      muted: c.isCancelled,
      subtitle: details.isEmpty ? null : details.join(' · '),
      tag: ContractStatusLabel(contract: c),
      trailing: largeText ? null : Text(value, style: moneyStyle),
      onTap: onTap,
    );
  }
}

/// "Mar 1, 2026 – Feb 28, 2027", or "From Mar 1, 2026" without an end.
String contractTerm(BuildContext context, Contract c) {
  final start = context.formatDate(c.startDate);
  return switch (c.expirationDate) {
    final end? => '$start – ${context.formatDate(end)}',
    null => AppLocalizations.of(context).contractFrom(start),
  };
}
