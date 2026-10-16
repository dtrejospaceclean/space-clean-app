import 'dart:typed_data';

import '../../../../core/usecase/usecase.dart';
import '../entities/proposal.dart';
import '../repositories/proposals_repository.dart';

class GetProposals implements UseCase<List<Proposal>, String> {
  const GetProposals(this._repository);

  final ProposalsRepository _repository;

  /// [clientId]'s negotiations.
  @override
  Future<List<Proposal>> call(String clientId) =>
      _repository.getProposals(clientId);
}

class ProposalRef {
  const ProposalRef({required this.clientId, required this.proposalId});

  final String clientId;
  final String proposalId;
}

class GetProposal implements UseCase<Proposal, ProposalRef> {
  const GetProposal(this._repository);

  final ProposalsRepository _repository;

  @override
  Future<Proposal> call(ProposalRef params) =>
      _repository.getProposal(params.clientId, params.proposalId);
}

class GetProposalVersions implements UseCase<List<Proposal>, ProposalRef> {
  const GetProposalVersions(this._repository);

  final ProposalsRepository _repository;

  @override
  Future<List<Proposal>> call(ProposalRef params) =>
      _repository.getVersions(params.clientId, params.proposalId);
}

/// How a save lands: a new negotiation, an edit of the current version, or
/// a new version on top of it.
enum ProposalSave { create, edit, newVersion }

class SaveProposalParams {
  const SaveProposalParams({
    required this.clientId,
    required this.mode,
    required this.draft,
    this.proposalId,
  });

  final String clientId;
  final ProposalSave mode;

  /// The version edited or built on; null to create.
  final String? proposalId;
  final ProposalDraft draft;
}

/// Returns the saved version (a new id for a create or a new version).
class SaveProposal implements UseCase<Proposal, SaveProposalParams> {
  const SaveProposal(this._repository);

  final ProposalsRepository _repository;

  @override
  Future<Proposal> call(SaveProposalParams p) => switch (p.mode) {
    ProposalSave.create => _repository.createProposal(p.clientId, p.draft),
    ProposalSave.edit => _repository.updateProposal(
      p.clientId,
      p.proposalId!,
      p.draft,
    ),
    ProposalSave.newVersion => _repository.addVersion(
      p.clientId,
      p.proposalId!,
      p.draft,
    ),
  };
}

/// Deletes every version of the referenced proposal's negotiation.
class DeleteProposal implements UseCase<void, ProposalRef> {
  const DeleteProposal(this._repository);

  final ProposalsRepository _repository;

  @override
  Future<void> call(ProposalRef params) =>
      _repository.deleteProposal(params.clientId, params.proposalId);
}

class ApproveProposalParams {
  const ApproveProposalParams({
    required this.clientId,
    required this.proposalId,
    this.agreedPrice,
  });

  final String clientId;
  final String proposalId;

  /// A decimal string; null keeps the version's own price.
  final String? agreedPrice;
}

class ApproveProposal implements UseCase<Proposal, ApproveProposalParams> {
  const ApproveProposal(this._repository);

  final ProposalsRepository _repository;

  @override
  Future<Proposal> call(ApproveProposalParams p) => _repository.approveProposal(
    p.clientId,
    p.proposalId,
    agreedPrice: p.agreedPrice,
  );
}

class ProposalPdfParams {
  const ProposalPdfParams({
    required this.clientId,
    required this.proposalId,
    required this.language,
  });

  final String clientId;
  final String proposalId;

  /// `en` or `es`: the app's current language.
  final String language;

  @override
  bool operator ==(Object other) =>
      other is ProposalPdfParams &&
      other.clientId == clientId &&
      other.proposalId == proposalId &&
      other.language == language;

  @override
  int get hashCode => Object.hash(clientId, proposalId, language);
}

class GetProposalPdf implements UseCase<Uint8List, ProposalPdfParams> {
  const GetProposalPdf(this._repository);

  final ProposalsRepository _repository;

  @override
  Future<Uint8List> call(ProposalPdfParams p) => _repository.getProposalPdf(
    p.clientId,
    p.proposalId,
    language: p.language,
  );
}

class SendProposalParams {
  const SendProposalParams({
    required this.clientId,
    required this.proposalId,
    required this.to,
    required this.language,
  });

  final String clientId;
  final String proposalId;
  final List<String> to;
  final String language;
}

/// Emails the proposal to each address once (trimmed, lowercased); returns
/// who it went to.
class SendProposal implements UseCase<List<String>, SendProposalParams> {
  const SendProposal(this._repository);

  final ProposalsRepository _repository;

  @override
  Future<List<String>> call(SendProposalParams p) => _repository.sendProposal(
    p.clientId,
    p.proposalId,
    to: {for (final email in p.to) email.trim().toLowerCase()}.toList(),
    language: p.language,
  );
}
