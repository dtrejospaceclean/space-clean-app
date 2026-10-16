import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../contacts/domain/entities/contact.dart';
import '../../../contacts/presentation/widgets/send_by_email_page.dart';
import '../../di/proposals_providers.dart';
import '../../domain/entities/proposal.dart';
import '../../domain/usecases/proposal_usecases.dart';
import '../controllers/proposals_providers.dart';
import 'proposals_screen.dart';

/// Emails the proposal's PDF ([SendByEmailPage]). The primary contacts start
/// picked, like the server's default. Needs `proposal.edit`, for the current
/// version at any stage. Hands back who it went to.
class SendProposalScreen extends ConsumerWidget {
  const SendProposalScreen({
    super.key,
    required this.clientId,
    required this.proposalId,
  });

  /// Path segment under a proposal's page.
  static const route = 'send';

  final String clientId;
  final String proposalId;

  /// Primary contacts with an email: what the server would pick on its own.
  static Set<String> _defaults(List<Contact> contacts) => {
    for (final c in contacts)
      if (c.isPrimary)
        if (c.email case final e? when e.trim().isNotEmpty)
          e.trim().toLowerCase(),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final key = (clientId, proposalId);
    return switch (ref.watch(proposalProvider(key))) {
      AsyncValue(value: final proposal?) => SendByEmailPage(
        key: ValueKey(proposalId),
        clientId: clientId,
        summary: ListCard(children: [ProposalRow(proposal: proposal)]),
        defaults: _defaults,
        send: (to, language) => ref.read(sendProposalProvider)(
          SendProposalParams(
            clientId: clientId,
            proposalId: proposalId,
            to: to,
            language: language,
          ),
        ),
      ),
      final other => SpacePage(
        title: l10n.sendByEmail,
        slivers: [
          AsyncSlivers<Proposal>(
            value: other,
            skeleton: SkeletonLayout.form,
            onRetry: () => ref.invalidate(proposalProvider(key)),
            builder: (_) => const SliverToBoxAdapter(),
          ),
        ],
      ),
    };
  }
}
