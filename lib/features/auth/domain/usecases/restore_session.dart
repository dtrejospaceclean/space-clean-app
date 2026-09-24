import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// What restoring a stored session found.
class SessionRestore {
  const SessionRestore.signedIn(User this.user) : ended = false;

  /// Nothing was stored.
  const SessionRestore.none() : user = null, ended = false;

  /// A stored session existed but is no longer valid; it was cleared.
  const SessionRestore.ended() : user = null, ended = true;

  final User? user;
  final bool ended;
}

/// Restores the stored session. A session the server no longer accepts is
/// cleared instead of failing: a rejected token (401), or a user that no
/// longer exists (404 `users.not_found`, e.g. after the database was reset).
/// Other failures (offline, server errors) are rethrown so the splash can
/// offer a retry.
class RestoreSession implements UseCase<SessionRestore, NoParams> {
  const RestoreSession(this._repository);

  final AuthRepository _repository;

  @override
  Future<SessionRestore> call(NoParams params) async {
    if (!await _repository.hasSession()) return const SessionRestore.none();
    try {
      return SessionRestore.signedIn(await _repository.getCurrentUser());
    } on UnauthorizedFailure {
      // The token refresh already failed; drop what's left of the session.
      return _end();
    } on ServerFailure catch (e) {
      if (e.messageKey != 'users.not_found') rethrow;
      return _end();
    }
  }

  Future<SessionRestore> _end() async {
    await _repository.logout();
    return const SessionRestore.ended();
  }
}
