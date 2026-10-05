import '../entities/scope.dart';

/// Every method throws a `Failure` on error.
abstract interface class ScopesRepository {
  /// An account's scopes by location and area, or only [contractId]'s.
  /// Needs `scope.view`.
  Future<List<Scope>> getScopes(String clientId, {String? contractId});

  /// Needs `scope.view`.
  Future<Scope> getScope(String clientId, String scopeId);

  /// Needs `scope.edit`. The contract can't be cancelled
  /// (`contracts.cancelled`); weekly and biweekly windows need weekdays
  /// (`scopes.days_of_week_required`).
  Future<Scope> createScope(String clientId, ScopeDraft draft);

  /// Needs `scope.edit`. The contract stays the same.
  Future<Scope> updateScope(String clientId, String scopeId, ScopeDraft draft);

  /// Needs `scope.edit`; refused once it produced jobs (`scopes.has_jobs`).
  Future<void> deleteScope(String clientId, String scopeId);
}
