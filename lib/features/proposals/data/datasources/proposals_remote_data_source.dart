import '../../../../core/network/api_client.dart';
import '../../../../core/network/paginated.dart';
import '../../domain/entities/proposal.dart';
import '../models/proposal_model.dart';

/// Talks to `/clients/:clientId/proposals`. Throws `ApiException`.
class ProposalsRemoteDataSource {
  const ProposalsRemoteDataSource(this._api);

  final ApiClient _api;

  static String _path(String clientId) => '/clients/$clientId/proposals';

  static Proposal _one(Object? data) =>
      ProposalModel.fromJson((data! as Map).cast<String, dynamic>());

  Future<List<Proposal>> getProposals(String clientId) async =>
      (await fetchAllPages(
        _api,
        _path(clientId),
      )).map(ProposalModel.fromJson).toList();

  Future<Proposal> getProposal(String clientId, String proposalId) async =>
      _one(await _api.get('${_path(clientId)}/$proposalId'));

  /// Not paginated.
  Future<List<Proposal>> getVersions(String clientId, String proposalId) async {
    final data = await _api.get('${_path(clientId)}/$proposalId/versions');
    return [
      for (final item in data! as List)
        ProposalModel.fromJson((item as Map).cast<String, dynamic>()),
    ];
  }

  Future<Proposal> createProposal(String clientId, ProposalDraft draft) async =>
      _one(
        await _api.post(
          _path(clientId),
          body: ProposalDraftModel.toJson(draft, target: DraftTarget.create),
        ),
      );

  Future<Proposal> updateProposal(
    String clientId,
    String proposalId,
    ProposalDraft draft,
  ) async => _one(
    await _api.patch(
      '${_path(clientId)}/$proposalId',
      body: ProposalDraftModel.toJson(draft, target: DraftTarget.update),
    ),
  );

  Future<Proposal> addVersion(
    String clientId,
    String proposalId,
    ProposalDraft draft,
  ) async => _one(
    await _api.post(
      '${_path(clientId)}/$proposalId/versions',
      body: ProposalDraftModel.toJson(draft, target: DraftTarget.version),
    ),
  );

  Future<Proposal> approveProposal(
    String clientId,
    String proposalId, {
    String? agreedPrice,
  }) async => _one(
    await _api.post(
      '${_path(clientId)}/$proposalId/approve',
      body: {'agreedPrice': ?num.tryParse(agreedPrice?.trim() ?? '')},
    ),
  );
}
