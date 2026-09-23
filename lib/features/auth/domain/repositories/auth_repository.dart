import '../entities/user.dart';

/// Every method throws a `Failure` on error.
abstract interface class AuthRepository {
  Future<bool> hasSession();

  /// Signs in and keeps the session. Returns the signed-in user.
  Future<User> login({required String email, required String password});

  Future<User> getCurrentUser();

  /// Ends the session locally. The API has no logout endpoint.
  Future<void> logout();

  /// Emits when the session ends on its own (the refresh token was rejected).
  Stream<void> get sessionExpired;
}
