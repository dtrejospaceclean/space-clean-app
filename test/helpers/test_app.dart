import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sp_cln_app/app.dart';
import 'package:sp_cln_app/core/error/failures.dart';
import 'package:sp_cln_app/core/storage/preferences.dart';
import 'package:sp_cln_app/features/access/di/access_providers.dart';
import 'package:sp_cln_app/features/access/domain/entities/account_access.dart';
import 'package:sp_cln_app/features/access/domain/repositories/access_repository.dart';
import 'package:sp_cln_app/features/auth/di/auth_providers.dart';
import 'package:sp_cln_app/features/auth/domain/entities/user.dart';
import 'package:sp_cln_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:sp_cln_app/features/clients/di/clients_providers.dart';
import 'package:sp_cln_app/features/clients/domain/entities/client.dart';
import 'package:sp_cln_app/features/clients/domain/repositories/clients_repository.dart';
import 'package:sp_cln_app/features/jobs/di/jobs_providers.dart';
import 'package:sp_cln_app/features/jobs/domain/entities/job.dart';
import 'package:sp_cln_app/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:sp_cln_app/features/jobs/presentation/controllers/jobs_providers.dart';
import 'package:sp_cln_app/features/password_reset/di/password_reset_providers.dart';
import 'package:sp_cln_app/features/password_reset/domain/repositories/password_reset_repository.dart';

const ana = User(
  id: 'u1',
  email: 'ana@example.com',
  name: 'Ana Pérez',
  userType: UserType.internal,
  isActive: true,
  roles: [Role(id: 'r1', name: 'supervisor')],
);

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    this.sessionUser,
    this.loginError,
    this.rememberedEmail,
    this.sessionCheck,
  });

  User? sessionUser;

  /// When set, the startup session check waits on it (keeps the splash up).
  Future<bool>? sessionCheck;
  Failure? loginError;
  final expiry = StreamController<void>.broadcast();

  @override
  String? rememberedEmail;

  @override
  Future<bool> hasSession() =>
      sessionCheck ?? Future.value(sessionUser != null);

  @override
  Future<User> getCurrentUser() async => sessionUser!;

  @override
  Future<User> login({required String email, required String password}) async {
    if (loginError case final error?) throw error;
    rememberedEmail = email;
    return sessionUser = ana;
  }

  @override
  Future<void> logout() async => sessionUser = null;

  @override
  Future<void> forgetRememberedEmail() async => rememberedEmail = null;

  @override
  Stream<void> get sessionExpired => expiry.stream;
}

class FakePasswordResetRepository implements PasswordResetRepository {
  final calls = <String>[];
  Failure? verifyError;

  @override
  Future<void> requestCode(String email) async => calls.add('request:$email');

  @override
  Future<void> verifyCode({required String email, required String code}) async {
    calls.add('verify:$code');
    if (verifyError case final error?) throw error;
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async => calls.add('reset:$code');
}

class FakeClientsRepository implements ClientsRepository {
  FakeClientsRepository([this.clients = const []]);

  List<Client> clients;
  Failure? error;

  @override
  Future<List<Client>> getMyClients() async {
    if (error case final error?) throw error;
    return clients;
  }
}

/// Jobs per client id; a [Failure] value makes that account fail.
class FakeJobsRepository implements JobsRepository {
  FakeJobsRepository([this.byClient = const {}]);

  Map<String, Object> byClient;

  @override
  Future<List<Job>> getJobs({
    required String clientId,
    required DateTime from,
    required DateTime to,
  }) async => switch (byClient[clientId]) {
    final Failure failure => throw failure,
    final List<Job> jobs => jobs,
    _ => const [],
  };

  @override
  Future<Job> getJob({required String clientId, required String jobId}) async {
    final jobs = byClient[clientId];
    if (jobs is List<Job>) return jobs.firstWhere((j) => j.id == jobId);
    throw const ServerFailure('jobs.not_found', statusCode: 404);
  }
}

/// Memberships per client id (absent means not a member).
class FakeAccessRepository implements AccessRepository {
  FakeAccessRepository([this.byClient = const {}]);

  Map<String, AccountAccess> byClient;

  /// Accounts where reading the membership is forbidden (no team.view).
  Set<String> forbidden = {};

  @override
  Future<AccountAccess?> getMembership({
    required String clientId,
    required String userId,
  }) async {
    if (forbidden.contains(clientId)) {
      throw const ServerFailure(
        'auth.insufficient_permission',
        statusCode: 403,
      );
    }
    return byClient[clientId];
  }
}

/// A fixed "now" for screens that show today: Wednesday Sep 23 2026, 08:00.
final testNow = DateTime(2026, 9, 23, 8);

Job job(
  String id,
  String clientId, {
  String? title,
  int hour = 9,
  JobStatus status = JobStatus.scheduled,
}) => Job(
  id: id,
  clientId: clientId,
  title: title ?? 'Job $id',
  status: status,
  scheduledStart: DateTime(2026, 9, 23, hour),
  scheduledEnd: DateTime(2026, 9, 23, hour + 2),
  location: const JobLocation(name: 'Main office'),
);

/// Pumps the whole app on a phone-sized screen with fakes behind the domain.
Future<SharedPreferences> pumpApp(
  WidgetTester tester, {
  required FakeAuthRepository auth,
  PasswordResetRepository? passwordReset,
  ClientsRepository? clients,
  JobsRepository? jobs,
  AccessRepository? access,
  Map<String, Object> preferences = const {},
}) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues(preferences);
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authRepositoryProvider.overrideWithValue(auth),
        if (passwordReset != null)
          passwordResetRepositoryProvider.overrideWithValue(passwordReset),
        clientsRepositoryProvider.overrideWithValue(
          clients ?? FakeClientsRepository(),
        ),
        jobsRepositoryProvider.overrideWithValue(jobs ?? FakeJobsRepository()),
        accessRepositoryProvider.overrideWithValue(
          access ?? FakeAccessRepository(),
        ),
        clockProvider.overrideWithValue(() => testNow),
      ],
      retry: (_, _) => null,
      child: const App(),
    ),
  );
  await tester.pumpAndSettle();
  return prefs;
}

Finder button(String label) => find.widgetWithText(FilledButton, label);

/// The text field under the visible label [label].
Finder field(String label) => find.descendant(
  of: find.ancestor(of: find.text(label), matching: find.byType(Column)).first,
  matching: find.byType(TextFormField),
);
