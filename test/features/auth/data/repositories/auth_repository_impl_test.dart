import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/core/error/failures.dart';
import 'package:sp_cln_app/core/network/api_exception.dart';
import 'package:sp_cln_app/core/storage/token_storage.dart';
import 'package:sp_cln_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:sp_cln_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:sp_cln_app/features/auth/domain/entities/user.dart';

class FakeRemote implements AuthRemoteDataSource {
  ApiException? loginError;

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    if (loginError case final error?) throw error;
    return const AuthTokens(accessToken: 'a', refreshToken: 'r');
  }

  @override
  Future<User> me() async => const User(
    id: 'u1',
    email: 'ana@example.com',
    name: 'Ana',
    userType: UserType.internal,
    isActive: true,
    roles: [],
  );
}

void main() {
  late FakeRemote remote;
  late TokenStorage tokenStorage;
  late AuthRepositoryImpl repository;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    remote = FakeRemote();
    tokenStorage = TokenStorage(const FlutterSecureStorage());
    repository = AuthRepositoryImpl(remote, tokenStorage);
  });

  test('login stores the tokens and returns the user', () async {
    final user = await repository.login(
      email: 'ana@example.com',
      password: 'x',
    );

    expect(user.id, 'u1');
    expect(await repository.hasSession(), isTrue);
  });

  test('logout clears the session', () async {
    await repository.login(email: 'ana@example.com', password: 'x');
    await repository.logout();

    expect(await repository.hasSession(), isFalse);
  });

  group('maps API errors to failures', () {
    Future<Failure> failureFor(ApiException error) async {
      remote.loginError = error;
      try {
        await repository.login(email: 'ana@example.com', password: 'x');
      } on Failure catch (f) {
        return f;
      }
      fail('expected a Failure');
    }

    test('no response → NetworkFailure', () async {
      expect(
        await failureFor(
          const ApiException(key: NetworkFailure.key, statusCode: 0),
        ),
        isA<NetworkFailure>(),
      );
    });

    test('401 → UnauthorizedFailure', () async {
      expect(
        await failureFor(
          const ApiException(key: 'auth.invalid_credentials', statusCode: 401),
        ),
        isA<UnauthorizedFailure>().having(
          (f) => f.messageKey,
          'key',
          'auth.invalid_credentials',
        ),
      );
    });

    test('field errors → ValidationFailure', () async {
      final failure = await failureFor(
        const ApiException(
          key: 'validation.failed',
          statusCode: 400,
          fieldErrors: {
            'email': [
              ApiFieldError(key: 'validation.is_email', message: 'bad'),
            ],
          },
        ),
      );

      expect(
        failure,
        isA<ValidationFailure>().having(
          (f) => f.fieldErrors['email']!.single.key,
          'email error',
          'validation.is_email',
        ),
      );
    });

    test('anything else → ServerFailure', () async {
      expect(
        await failureFor(
          const ApiException(key: 'errors.internal', statusCode: 500),
        ),
        isA<ServerFailure>().having((f) => f.statusCode, 'status', 500),
      );
    });
  });
}
