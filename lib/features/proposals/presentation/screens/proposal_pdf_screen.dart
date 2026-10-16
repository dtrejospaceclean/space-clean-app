import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/l10n/document_language.dart';
import '../../../../core/widgets/pdf_view.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../access/domain/entities/account_access.dart';
import '../../../access/presentation/controllers/account_access_provider.dart';
import '../../domain/usecases/proposal_usecases.dart';
import '../controllers/proposals_providers.dart';
import 'send_proposal_screen.dart';

/// The proposal as the client gets it: the server's PDF, in the app's
/// language, to scroll and zoom. Any version opens (an earlier one says it
/// was superseded); needs `proposal.view`. With `proposal.edit`, the current
/// version can be emailed from here too.
class ProposalPdfScreen extends ConsumerWidget {
  const ProposalPdfScreen({
    super.key,
    required this.clientId,
    required this.proposalId,
  });

  /// Path segment under a proposal's page.
  static const route = 'pdf';

  final String clientId;
  final String proposalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final params = ProposalPdfParams(
      clientId: clientId,
      proposalId: proposalId,
      language: documentLanguage(context),
    );
    final pdf = ref.watch(proposalPdfProvider(params));
    final proposal = ref.watch(proposalProvider((clientId, proposalId))).value;
    final canEdit =
        ref
            .watch(accountAccessProvider(clientId))
            .value
            ?.can(Permissions.proposalEdit) ??
        false;
    final here = GoRouterState.of(context).matchedLocation;
    final proposalPage = here.substring(0, here.lastIndexOf('/'));
    Future<void> refresh() => ref.refresh(proposalPdfProvider(params).future);

    return SpacePage(
      title: switch (proposal) {
        final p? => l10n.proposalVersion(p.versionNumber),
        null => l10n.proposalPdfTitle,
      },
      actions: [
        if (canEdit && (proposal?.isCurrent ?? false))
          CircleButton.light(
            icon: Icons.send_outlined,
            tooltip: l10n.sendByEmail,
            onPressed: () =>
                context.push('$proposalPage/${SendProposalScreen.route}'),
          ),
      ],
      slivers: [
        AsyncSlivers(
          value: pdf,
          skeleton: SkeletonLayout.detail,
          onRetry: refresh,
          builder: (bytes) => SliverFillRemaining(
            hasScrollBody: true,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              // The viewer scrolls and zooms on its own.
              child: ref.read(pdfViewProvider)(
                bytes,
                'proposal-v${proposal?.versionNumber ?? proposalId}'
                '-${params.language}.pdf',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
