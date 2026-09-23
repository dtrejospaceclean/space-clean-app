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
import 'package:sp_cln_app/features/users/di/users_providers.dart';
import 'package:sp_cln_app/features/users/domain/entities/managed_user.dart';
import 'package:sp_cln_app/features/users/domain/entities/role_info.dart';
import 'package:sp_cln_app/features/users/domain/repositories/users_repository.dart';

const ana = User(
  id: 'u1',
  email: 'ana@example.com',
  name: 'Ana Pérez',
  userType: UserType.internal,
  isActive: true,
  roles: [Role(id: 'r1', name: 'supervisor')],
);

const owner = User(
  id: 'o1',
  email: 'olga@example.com',
  name: 'Olga Ruiz',
  userType: UserType.internal,
  isActive: true,
  roles: [Role(id: 'r-owner', name: 'owner')],
);

const accountManager = User(
  id: 'm1',
  email: 'marco@example.com',
  name: 'Marco Díaz',
  userType: UserType.internal,
  isActive: true,
  roles: [Role(id: 'r-am', name: 'account_manager')],
);

const testRoles = [
  RoleInfo(id: 'r-owner', name: 'owner', userCount: 1),
  RoleInfo(id: 'r-am', name: 'account_manager', userCount: 1),
  RoleInfo(id: 'r-sup', name: 'supervisor', userCount: 1),
  RoleInfo(id: 'r-crew', name: 'crew', userCount: 3),
  RoleInfo(id: 'r-client', name: 'client'),
  RoleInfo(id: 'r-lead', name: 'floor_lead', description: 'Leads a floor'),
];

/// In-memory users behind the users screens; records every write.
class FakeUsersRepository implements UsersRepository {
  FakeUsersRepository([List<ManagedUser>? users]) : users = [...users ?? _seed];

  static const _seed = [
    ManagedUser(
      id: 'u1',
      email: 'ana@example.com',
      name: 'Ana Pérez',
      userType: UserType.internal,
      isActive: true,
      roles: [Role(id: 'r-sup', name: 'supervisor')],
      employmentType: 'part_time',
      payRate: '18.5',
    ),
    ManagedUser(
      id: 'u2',
      email: 'luis@example.com',
      name: 'Luis Gómez',
      userType: UserType.internal,
      isActive: false,
      roles: [Role(id: 'r-crew', name: 'crew')],
    ),
  ];

  final List<ManagedUser> users;
  final writes = <String>[];
  Failure? createError;

  @override
  Future<List<ManagedUser>> getUsers(UserQuery query) async => users
      .where((u) => query.isActive == null || u.isActive == query.isActive)
      .where((u) => u.name.toLowerCase().contains(query.search.toLowerCase()))
      .toList();

  @override
  Future<ManagedUser> getUser(String id) async =>
      users.firstWhere((u) => u.id == id);

  @override
  Future<ManagedUser> createUser(UserDraft draft) async {
    if (createError case final error?) throw error;
    writes.add('create:${draft.email}:${draft.roleIds}');
    final user = ManagedUser(
      id: 'u${users.length + 1}',
      email: draft.email!,
      name: draft.name!,
      userType: UserType.internal,
      isActive: true,
      roles: [
        for (final id in draft.roleIds ?? const <String>[])
          Role(id: id, name: testRoles.firstWhere((r) => r.id == id).name),
      ],
    );
    users.add(user);
    return user;
  }

  @override
  Future<ManagedUser> updateUser(String id, UserDraft draft) async {
    writes.add('update:$id');
    return getUser(id);
  }

  @override
  Future<ManagedUser> setActive(String id, {required bool active}) async {
    writes.add('active:$id:$active');
    final i = users.indexWhere((u) => u.id == id);
    final u = users[i];
    return users[i] = ManagedUser(
      id: u.id,
      email: u.email,
      name: u.name,
      userType: u.userType,
      isActive: active,
      roles: u.roles,
    );
  }

  @override
  Future<ManagedUser> setRoles(String id, List<String> roleIds) async {
    writes.add('roles:$id:$roleIds');
    return getUser(id);
  }
}

class FakeRolesRepository implements RolesRepository {
  List<RoleInfo> roles = [...testRoles];
  final writes = <String>[];

  @override
  Future<List<RoleInfo>> getRoles() async => roles;

  @override
  Future<RoleInfo> createRole({
    required String name,
    String? description,
  }) async {
    writes.add('create:$name');
    final role = RoleInfo(id: 'r-$name', name: name, description: description);
    roles = [...roles, role];
    return role;
  }

  @override
  Future<RoleInfo> updateRole(
    String id, {
    String? name,
    String? description,
  }) async {
    writes.add('update:$id:$name');
    return roles.firstWhere((r) => r.id == id);
  }

  @override
  Future<void> deleteRole(String id) async {
    writes.add('delete:$id');
    roles = roles.where((r) => r.id != id).toList();
  }
}

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
  UsersRepository? users,
  RolesRepository? roles,
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
        usersRepositoryProvider.overrideWithValue(
          users ?? FakeUsersRepository(),
        ),
        rolesRepositoryProvider.overrideWithValue(
          roles ?? FakeRolesRepository(),
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
