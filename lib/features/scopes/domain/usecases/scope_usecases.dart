import '../../../../core/usecase/usecase.dart';
import '../entities/scope.dart';
import '../repositories/scopes_repository.dart';

class ScopeQuery {
  const ScopeQuery({required this.clientId, this.contractId});

  final String clientId;

  /// Only this contract's scopes; null for all of the account's.
  final String? contractId;

  @override
  bool operator ==(Object other) =>
      other is ScopeQuery &&
      other.clientId == clientId &&
      other.contractId == contractId;

  @override
  int get hashCode => Object.hash(clientId, contractId);
}

class GetScopes implements UseCase<List<Scope>, ScopeQuery> {
  const GetScopes(this._repository);

  final ScopesRepository _repository;

  @override
  Future<List<Scope>> call(ScopeQuery q) =>
      _repository.getScopes(q.clientId, contractId: q.contractId);
}

class ScopeRef {
  const ScopeRef({required this.clientId, required this.scopeId});

  final String clientId;
  final String scopeId;
}

class GetScope implements UseCase<Scope, ScopeRef> {
  const GetScope(this._repository);

  final ScopesRepository _repository;

  @override
  Future<Scope> call(ScopeRef params) =>
      _repository.getScope(params.clientId, params.scopeId);
}

class SaveScopeParams {
  const SaveScopeParams({
    required this.clientId,
    required this.draft,
    this.scopeId,
  });

  final String clientId;

  /// The scope edited; null to create.
  final String? scopeId;
  final ScopeDraft draft;
}

/// Creates or edits a scope; returns the saved scope.
class SaveScope implements UseCase<Scope, SaveScopeParams> {
  const SaveScope(this._repository);

  final ScopesRepository _repository;

  @override
  Future<Scope> call(SaveScopeParams p) => switch (p.scopeId) {
    null => _repository.createScope(p.clientId, p.draft),
    final id => _repository.updateScope(p.clientId, id, p.draft),
  };
}

class DeleteScope implements UseCase<void, ScopeRef> {
  const DeleteScope(this._repository);

  final ScopesRepository _repository;

  @override
  Future<void> call(ScopeRef params) =>
      _repository.deleteScope(params.clientId, params.scopeId);
}
