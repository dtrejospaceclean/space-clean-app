import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/core/error/failures.dart';
import 'package:sp_cln_app/core/usecase/usecase.dart';
import 'package:sp_cln_app/features/auth/domain/entities/user.dart';
import 'package:sp_cln_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:sp_cln_app/features/auth/domain/usecases/login.dart';
import 'package:sp_cln_app/features/auth/domain/usecases/restore_session.dart';

const _user = User(
  id: 'u1',
  email: 'ana@example.com',
  name: 'Ana',
  userType: UserType.internal,
  isActive: true,
  roles: [],
);

class FakeAuthRepository implements AuthRepository {
  bool session = true;
  Failure? meFailure;
  String? loginEmail;
  bool loggedOut = false;

  @override
  Future<bool> hasSession() async => session;

  @override
  Future<User> getCurrentUser() async {
    if (meFailure case final failure?) throw failure;
    return _user;
  }

  @override
  Future<User> login({required String email, required String password}) async {
    loginEmail = email;
    return _user;
  }

  @override
  Future<void> logout() async => loggedOut = true;

  @override
  String? get rememberedEmail => null;

  @override
  Future<void> forgetRememberedEmail() async {}

  @override
  Stream<void> get sessionExpired => const Stream.empty();
}

void main() {
  late FakeAuthRepository repository;

  setUp(() => repository = FakeAuthRepository());

  group('Login', () {
    test('normalizes the email', () async {
      await Login(repository)(
        const LoginParams(email: '  Ana@Example.COM ', password: 'secret'),
      );

      expect(repository.loginEmail, 'ana@example.com');
    });
  });

  group('RestoreSession', () {
    test('returns null without a stored session', () async {
      repository.session = false;

      expect((await RestoreSession(repository)(const NoParams())).user, isNull);
    });

    test('returns the user of a valid session', () async {
      expect((await RestoreSession(repository)(const NoParams())).user, _user);
    });

    test('drops a session the server rejects', () async {
      repository.meFailure = const UnauthorizedFailure(
        'auth.invalid_refresh_token',
      );

      expect((await RestoreSession(repository)(const NoParams())).user, isNull);
      expect(repository.loggedOut, isTrue);
    });

    test('drops a session whose user no longer exists', () async {
      repository.meFailure = const ServerFailure(
        'users.not_found',
        statusCode: 404,
      );

      final restored = await RestoreSession(repository)(const NoParams());

      expect(restored.user, isNull);
      expect(restored.ended, isTrue);
      expect(repository.loggedOut, isTrue);
    });

    test('keeps the session on other server errors', () async {
      repository.meFailure = const ServerFailure(
        'errors.internal',
        statusCode: 500,
      );

      await expectLater(
        RestoreSession(repository)(const NoParams()),
        throwsA(isA<ServerFailure>()),
      );
      expect(repository.loggedOut, isFalse);
    });

    test('keeps the session and rethrows other failures', () async {
      repository.meFailure = const NetworkFailure();

      await expectLater(
        RestoreSession(repository)(const NoParams()),
        throwsA(isA<NetworkFailure>()),
      );
      expect(repository.loggedOut, isFalse);
    });
  });
}
