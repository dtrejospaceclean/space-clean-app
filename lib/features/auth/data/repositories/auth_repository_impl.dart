import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._tokenStorage);

  final AuthRemoteDataSource _remote;
  final TokenStorage _tokenStorage;

  @override
  Future<bool> hasSession() async => await _tokenStorage.read() != null;

  @override
  Future<User> login({required String email, required String password}) =>
      _guard(() async {
        final tokens = await _remote.login(email: email, password: password);
        await _tokenStorage.save(tokens);
        return _remote.me();
      });

  @override
  Future<User> getCurrentUser() => _guard(_remote.me);

  @override
  Future<void> logout() => _tokenStorage.clear();

  @override
  Stream<void> get sessionExpired => _tokenStorage.sessionExpired;

  /// Translates transport errors into domain failures.
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException catch (e) {
      throw e.toFailure();
    }
  }
}
