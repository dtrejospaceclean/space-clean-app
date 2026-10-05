import '../../../../core/network/api_client.dart';
import '../../../../core/network/paginated.dart';
import '../../domain/entities/contract.dart';
import '../models/contract_model.dart';

/// Talks to `/clients/:clientId/contracts`. Throws `ApiException`.
class ContractsRemoteDataSource {
  const ContractsRemoteDataSource(this._api);

  final ApiClient _api;

  static String _path(String clientId) => '/clients/$clientId/contracts';

  static Contract _one(Object? data) =>
      ContractModel.fromJson((data! as Map).cast<String, dynamic>());

  Future<List<Contract>> getContracts(String clientId) async =>
      (await fetchAllPages(
        _api,
        _path(clientId),
      )).map(ContractModel.fromJson).toList();

  Future<Contract> getContract(String clientId, String contractId) async =>
      _one(await _api.get('${_path(clientId)}/$contractId'));

  Future<Contract> createContract(String clientId, ContractDraft draft) async =>
      _one(
        await _api.post(
          _path(clientId),
          body: ContractDraftModel.toJson(draft, create: true),
        ),
      );

  Future<Contract> updateContract(
    String clientId,
    String contractId,
    ContractDraft draft,
  ) async => _one(
    await _api.patch(
      '${_path(clientId)}/$contractId',
      body: ContractDraftModel.toJson(draft, create: false),
    ),
  );

  Future<Contract> signContract(
    String clientId,
    String contractId, {
    DateTime? signedDate,
  }) async => _one(
    await _api.post(
      '${_path(clientId)}/$contractId/sign',
      body: {
        if (signedDate != null)
          'signedDate': ContractDraftModel.ymd(signedDate),
      },
    ),
  );

  /// Sends only the status, so nothing else changes.
  Future<Contract> markExpired(String clientId, String contractId) async =>
      _one(
        await _api.patch(
          '${_path(clientId)}/$contractId',
          body: {'status': ContractStatus.expired.wire},
        ),
      );

  /// Takes no body.
  Future<Contract> cancelContract(String clientId, String contractId) async =>
      _one(await _api.post('${_path(clientId)}/$contractId/cancel'));

  /// Returns no data.
  Future<void> deleteContract(String clientId, String contractId) =>
      _api.delete('${_path(clientId)}/$contractId');
}
