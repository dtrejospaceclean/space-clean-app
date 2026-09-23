import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginParams {
  const LoginParams({required this.email, required this.password});

  final String email;
  final String password;
}

class Login implements UseCase<User, LoginParams> {
  const Login(this._repository);

  final AuthRepository _repository;

  @override
  Future<User> call(LoginParams params) => _repository.login(
    // Emails are case-insensitive on the server.
    email: params.email.trim().toLowerCase(),
    password: params.password,
  );
}
