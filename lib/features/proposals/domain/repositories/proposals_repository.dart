import 'dart:typed_data';

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

  /// Deletes the whole negotiation: every version of [proposalId]'s, with
  /// their line items. Needs `proposal.edit`; refused once any version is
  /// approved (`proposals.already_approved`) or a contract uses one
  /// (`proposals.has_related_records`).
  Future<void> deleteProposal(String clientId, String proposalId);

  /// Any version as a PDF, written in [language] (`en` or `es`); an earlier
  /// version says it was superseded. Needs `proposal.view`.
  Future<Uint8List> getProposalPdf(
    String clientId,
    String proposalId, {
    required String language,
  });

  /// Emails the PDF to [to] (1–10 addresses), the email and the PDF in
  /// [language]; returns who it went to. Needs `proposal.edit`; only the
  /// current version, at any stage (`proposals.not_current_version`). A mail
  /// provider failure is `mail.send_failed`.
  Future<List<String>> sendProposal(
    String clientId,
    String proposalId, {
    required List<String> to,
    required String language,
  });
}
