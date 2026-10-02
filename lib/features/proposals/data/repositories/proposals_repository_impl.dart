import '../../../../core/network/api_exception.dart';
import '../../domain/entities/proposal.dart';
import '../../domain/repositories/proposals_repository.dart';
import '../datasources/proposals_remote_data_source.dart';

class ProposalsRepositoryImpl implements ProposalsRepository {
  const ProposalsRepositoryImpl(this._remote);

  final ProposalsRemoteDataSource _remote;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException catch (e) {
      throw e.toFailure();
    }
  }

  @override
  Future<List<Proposal>> getProposals(String clientId) =>
      _guard(() => _remote.getProposals(clientId));

  @override
  Future<Proposal> getProposal(String clientId, String proposalId) =>
      _guard(() => _remote.getProposal(clientId, proposalId));

  @override
  Future<List<Proposal>> getVersions(String clientId, String proposalId) =>
      _guard(() => _remote.getVersions(clientId, proposalId));

  @override
  Future<Proposal> createProposal(String clientId, ProposalDraft draft) =>
      _guard(() => _remote.createProposal(clientId, draft));

  @override
  Future<Proposal> updateProposal(
    String clientId,
    String proposalId,
    ProposalDraft draft,
  ) => _guard(() => _remote.updateProposal(clientId, proposalId, draft));

  @override
  Future<Proposal> addVersion(
    String clientId,
    String proposalId,
    ProposalDraft draft,
  ) => _guard(() => _remote.addVersion(clientId, proposalId, draft));

  @override
  Future<Proposal> approveProposal(
    String clientId,
    String proposalId, {
    String? agreedPrice,
  }) => _guard(
    () =>
        _remote.approveProposal(clientId, proposalId, agreedPrice: agreedPrice),
  );

  @override
  Future<void> deleteProposal(String clientId, String proposalId) =>
      _guard(() => _remote.deleteProposal(clientId, proposalId));
}
