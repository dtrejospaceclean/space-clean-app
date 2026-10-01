import '../entities/proposal.dart';

/// Every method throws a `Failure` on error.
abstract interface class ProposalsRepository {
  /// An account's negotiations, one row each (its current version), newest
  /// first. Needs `proposal.view`.
  Future<List<Proposal>> getProposals(String clientId);

  /// Any version, current or not. Needs `proposal.view`.
  Future<Proposal> getProposal(String clientId, String proposalId);

  /// Every version of [proposalId]'s negotiation, newest first. Needs
  /// `proposal.view`.
  Future<List<Proposal>> getVersions(String clientId, String proposalId);

  /// Starts a negotiation at version 1. Needs `proposal.edit`.
  Future<Proposal> createProposal(String clientId, ProposalDraft draft);

  /// Changes the current, unapproved version in place. Needs
  /// `proposal.edit` (`proposals.not_current_version` /
  /// `proposals.already_approved` otherwise).
  Future<Proposal> updateProposal(
    String clientId,
    String proposalId,
    ProposalDraft draft,
  );

  /// Adds a version on top of the current one, which is kept as history.
  /// Needs `proposal.edit`.
  Future<Proposal> addVersion(
    String clientId,
    String proposalId,
    ProposalDraft draft,
  );

  /// Approves the current version at [agreedPrice] (a decimal string), or
  /// at the price it already carries when null. Needs `proposal.edit`.
  Future<Proposal> approveProposal(
    String clientId,
    String proposalId, {
    String? agreedPrice,
  });
}
