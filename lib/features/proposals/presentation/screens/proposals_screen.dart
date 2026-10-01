import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../access/domain/entities/account_access.dart';
import '../../../access/presentation/controllers/account_access_provider.dart';
import '../../domain/entities/proposal.dart';
import '../controllers/proposals_providers.dart';
import '../widgets/line_item_row.dart';
import '../widgets/proposal_stage_label.dart';

/// One client account's sales pipeline: each negotiation once (its current
/// version), newest first, with its stage on the row and a search. New ones
/// come from the dock's "+" (`proposal.edit`).
class ProposalsScreen extends ConsumerStatefulWidget {
  const ProposalsScreen({super.key, required this.clientId});

  /// Path segment under `/accounts/:clientId`.
  static const route = 'proposals';

  final String clientId;

  @override
  ConsumerState<ProposalsScreen> createState() => _ProposalsScreenState();
}

class _ProposalsScreenState extends ConsumerState<ProposalsScreen> {
  final _search = TextEditingController();

  /// The API can't search proposals, but the whole list is already here,
  /// so the search runs on the phone, as you type.
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
    final proposals = ref.watch(proposalsProvider(clientId));
    final canEdit =
        ref
            .watch(accountAccessProvider(clientId))
            .value
            ?.can(Permissions.proposalEdit) ??
        false;
    final here = GoRouterState.of(context).matchedLocation;
    Future<void> refresh() => ref.refresh(proposalsProvider(clientId).future);

    return SpacePage(
      title: l10n.moduleProposals,
      onRefresh: refresh,
      slivers: [
        PageBox(
          top: 4,
          child: SearchField(
            controller: _search,
            hint: l10n.searchProposalsHint,
            onChanged: (text) => setState(() => _query = text),
          ),
        ),
        AsyncSlivers(
          value: proposals,
          onRetry: refresh,
          builder: (list) {
            if (list.isEmpty) {
              return MessageSliver(
                icon: Icons.request_quote_outlined,
                title: l10n.noProposalsYet,
                hint: canEdit ? l10n.noProposalsYetHint : null,
              );
            }
            final found = list
                .where((p) => matchesProposal(l10n, p, _query))
                .toList();
            if (found.isEmpty) {
              return MessageSliver(
                icon: Icons.request_quote_outlined,
                title: l10n.noMatchesFound,
                hint: l10n.noMatchesHint,
              );
            }
            return PageBox(
              child: ListCard(
                children: [
                  for (final p in found)
                    ProposalRow(
                      proposal: p,
                      onTap: () => context.push('$here/${p.id}'),
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

/// A proposal as a list row: what's being sold, its version, its stage as a
/// pill, and the price.
class ProposalRow extends StatelessWidget {
  const ProposalRow({super.key, required this.proposal, this.onTap});

  final Proposal proposal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = proposal;
    final largeText = isLargeText(context);
    return ListRow(
      leading: const IconBadge(icon: Icons.request_quote_outlined),
      title: proposalSummary(l10n, p),
      muted: p.lineItems.isEmpty,
      // The figure people scan a pipeline for, trailing like every list's
      // figures. At large text it moves under the title, so the title keeps
      // the width to wrap between words.
      subtitle: [
        if (p.hasPrice && largeText) context.formatMoney(p.price),
        l10n.proposalVersion(p.versionNumber),
      ].join(' · '),
      tag: ProposalStageLabel(stage: p.stage),
      trailing: p.hasPrice && !largeText
          ? Text(context.formatMoney(p.price), style: moneyStyle)
          : null,
      onTap: onTap,
    );
  }
}

/// What a proposal sells, in a few words: its first line item and how many
/// more follow.
String proposalSummary(AppLocalizations l10n, Proposal p) =>
    switch (p.lineItems) {
      [] => l10n.proposalNoLineItems,
      [final only] => only.description,
      [final first, ...final rest] => l10n.proposalMoreItems(
        rest.length,
        first.description,
      ),
    };

/// Whether [query] appears in what [p] sells (any line item), its version
/// note, its stage's name or who prepared it. Case and accents don't
/// matter, so "negociacion" finds "Negociación".
bool matchesProposal(AppLocalizations l10n, Proposal p, String query) {
  final words = _fold(query).split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  if (words.isEmpty) return true;
  final haystack = _fold(
    [
      for (final item in p.lineItems) item.description,
      ?p.versionNote,
      l10n.proposalStage(p.stage),
      ?p.preparedByName,
    ].join(' '),
  );
  // Every word must appear somewhere, so "office nego" narrows down.
  return words.every(haystack.contains);
}

const _accents = {
  'á': 'a',
  'é': 'e',
  'í': 'i',
  'ó': 'o',
  'ú': 'u',
  'ü': 'u',
  'ñ': 'n',
};

String _fold(String text) =>
    text.toLowerCase().split('').map((c) => _accents[c] ?? c).join();
