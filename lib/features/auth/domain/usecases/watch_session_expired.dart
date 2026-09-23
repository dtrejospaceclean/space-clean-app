import '../repositories/auth_repository.dart';

/// Stream use case, so it doesn't fit the `Future`-based `UseCase` contract.
class WatchSessionExpired {
  const WatchSessionExpired(this._repository);

  final AuthRepository _repository;

  Stream<void> call() => _repository.sessionExpired;
}
