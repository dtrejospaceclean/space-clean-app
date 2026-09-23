import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/user.dart';
import '../models/user_model.dart';

/// Talks to the `/auth` endpoints. Throws `ApiException`.
class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._api);

  final ApiClient _api;

  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    final data = await _api.post(
      '/auth/login',
      body: {'email': email, 'password': password},
      authenticated: false,
    );
    return AuthTokens.fromJson((data! as Map).cast<String, dynamic>());
  }

  Future<User> me() async {
    final data = await _api.get('/auth/me');
    return UserModel.fromJson((data! as Map).cast<String, dynamic>());
  }
}
