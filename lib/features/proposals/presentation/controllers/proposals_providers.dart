import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/proposals_providers.dart';
import '../../domain/entities/proposal.dart';
import '../../domain/usecases/proposal_usecases.dart';

/// An account's negotiations (current versions), newest first.
final proposalsProvider = FutureProvider.autoDispose
    .family<List<Proposal>, String>(
      (ref, clientId) => ref.watch(getProposalsProvider)(clientId),
    );

/// One version: `(clientId, proposalId)`.
final proposalProvider = FutureProvider.autoDispose
    .family<Proposal, (String, String)>(
      (ref, key) => ref.watch(getProposalProvider)(
        ProposalRef(clientId: key.$1, proposalId: key.$2),
      ),
    );

/// Every version of a negotiation, newest first: `(clientId, proposalId)`.
final proposalVersionsProvider =
    FutureProvider.family<List<Proposal>, (String, String)>(
      (ref, key) => ref.watch(getProposalVersionsProvider)(
        ProposalRef(clientId: key.$1, proposalId: key.$2),
      ),
    );

/// Drops an account's cached proposals after any save: a new version or an
/// approval changes the list, the version history and the old version.
void invalidateProposals(WidgetRef ref, String clientId) => ref
  ..invalidate(proposalsProvider(clientId))
  ..invalidate(proposalProvider)
  ..invalidate(proposalVersionsProvider);
