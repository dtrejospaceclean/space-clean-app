import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sp_cln_app/app.dart';
import 'package:sp_cln_app/core/error/failures.dart';
import 'package:sp_cln_app/core/refresh/live_data.dart';
import 'package:sp_cln_app/core/storage/preferences.dart';
import 'package:sp_cln_app/features/notifications/di/notifications_providers.dart';
import 'package:sp_cln_app/features/notifications/domain/entities/app_notification.dart';
import 'package:sp_cln_app/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:sp_cln_app/features/access/di/access_providers.dart';
import 'package:sp_cln_app/features/access/domain/entities/account_access.dart';
import 'package:sp_cln_app/features/access/domain/repositories/access_repository.dart';
import 'package:sp_cln_app/features/auth/di/auth_providers.dart';
import 'package:sp_cln_app/features/auth/domain/entities/user.dart';
import 'package:sp_cln_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:sp_cln_app/features/calendar/di/calendar_providers.dart';
import 'package:sp_cln_app/features/calendar/domain/entities/calendar_event.dart';
import 'package:sp_cln_app/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:sp_cln_app/features/clients/di/clients_providers.dart';
import 'package:sp_cln_app/features/clients/domain/entities/client.dart';
import 'package:sp_cln_app/features/clients/domain/repositories/clients_repository.dart';
import 'package:sp_cln_app/features/contacts/di/contacts_providers.dart';
import 'package:sp_cln_app/features/contacts/domain/entities/contact.dart';
import 'package:sp_cln_app/features/contacts/domain/repositories/contacts_repository.dart';
import 'package:sp_cln_app/features/complaints/di/complaints_providers.dart';
import 'package:sp_cln_app/features/complaints/domain/entities/complaint.dart';
import 'package:sp_cln_app/features/complaints/domain/repositories/complaints_repository.dart';
import 'package:sp_cln_app/features/contracts/di/contracts_providers.dart';
import 'package:sp_cln_app/features/tasks/di/tasks_providers.dart';
import 'package:sp_cln_app/features/tasks/domain/entities/task.dart';
import 'package:sp_cln_app/features/tasks/domain/repositories/tasks_repository.dart';
import 'package:sp_cln_app/features/contracts/domain/entities/contract.dart';
import 'package:sp_cln_app/features/contracts/domain/repositories/contracts_repository.dart';
import 'package:sp_cln_app/features/invoices/di/invoices_providers.dart';
import 'package:sp_cln_app/features/invoices/domain/entities/invoice.dart';
import 'package:sp_cln_app/features/invoices/domain/entities/job_billing_suggestion.dart';
import 'package:sp_cln_app/features/invoices/domain/repositories/invoices_repository.dart';
import 'package:sp_cln_app/core/widgets/pdf_view.dart';
import 'package:sp_cln_app/features/jobs/di/jobs_providers.dart';
import 'package:sp_cln_app/features/jobs/domain/entities/job.dart';
import 'package:sp_cln_app/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:sp_cln_app/features/jobs/presentation/controllers/jobs_providers.dart';
import 'package:sp_cln_app/features/locations/di/locations_providers.dart';
import 'package:sp_cln_app/features/locations/domain/entities/location.dart';
import 'package:sp_cln_app/features/locations/domain/repositories/locations_repository.dart';
import 'package:sp_cln_app/features/password_reset/di/password_reset_providers.dart';
import 'package:sp_cln_app/features/password_reset/domain/entities/password_policy.dart';
import 'package:sp_cln_app/features/password_reset/domain/repositories/password_reset_repository.dart';
import 'package:sp_cln_app/features/profile/di/profile_providers.dart';
import 'package:sp_cln_app/features/profile/domain/entities/profile_draft.dart';
import 'package:sp_cln_app/core/domain/picked_photo.dart';
import 'package:sp_cln_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:sp_cln_app/core/media/photo_picker.dart';
import 'package:sp_cln_app/features/proposals/di/proposals_providers.dart';
import 'package:sp_cln_app/features/proposals/domain/entities/proposal.dart';
import 'package:sp_cln_app/features/proposals/domain/repositories/proposals_repository.dart';
import 'package:sp_cln_app/features/scopes/di/scopes_providers.dart';
import 'package:sp_cln_app/features/scopes/domain/entities/scope.dart';
import 'package:sp_cln_app/features/scopes/domain/repositories/scopes_repository.dart';
import 'package:sp_cln_app/features/service_catalog/di/service_catalog_providers.dart';
import 'package:sp_cln_app/features/settings/di/settings_providers.dart';
import 'package:sp_cln_app/features/settings/domain/entities/app_version.dart';
import 'package:sp_cln_app/features/settings/domain/repositories/app_info_repository.dart';
import 'package:sp_cln_app/features/team/di/team_providers.dart';
import 'package:sp_cln_app/features/team/domain/entities/member.dart';
import 'package:sp_cln_app/features/team/domain/repositories/team_repository.dart';
import 'package:sp_cln_app/features/service_catalog/domain/entities/service_item.dart';
import 'package:sp_cln_app/features/service_catalog/domain/repositories/service_catalog_repository.dart';
import 'package:sp_cln_app/features/notifications/domain/entities/push_message.dart';
import 'package:sp_cln_app/features/notifications/domain/repositories/push_repository.dart';
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
  Future<List<ManagedUser>> getUsers(UserQuery query) async {
    if (query.search.isNotEmpty) await searchGate?.future;
    return users
        .where((u) => query.isActive == null || u.isActive == query.isActive)
        .where((u) => u.name.toLowerCase().contains(query.search.toLowerCase()))
        .toList();
  }

  /// When set, searches wait for it (a slow server).
  Completer<void>? searchGate;

  /// When set, loading one user fails with it.
  Failure? getUserError;

  @override
  Future<ManagedUser> getUser(String id) async {
    if (getUserError case final error?) throw error;
    return users.firstWhere((u) => u.id == id);
  }

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

  /// When set, the session check finds a session but `/auth/me` fails.
  Failure? meFailure;

  @override
  Future<User> getCurrentUser() async {
    if (meFailure case final failure?) throw failure;
    return sessionUser!;
  }

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

/// The reset endpoints: every code is accepted (unless [verifyError]) and
/// buys token `t-<code>`, valid 15 minutes from [testNow].
class FakePasswordResetRepository implements PasswordResetRepository {
  final calls = <String>[];
  Failure? verifyError;
  Failure? resetError;

  @override
  Future<void> requestCode(String email, {required String language}) async {
    languages.add(language);
    calls.add('request:$email');
  }

  /// The language of each code email asked for.
  final languages = <String>[];

  @override
  Future<ResetToken> verifyCode({
    required String email,
    required String code,
  }) async {
    calls.add('verify:$code');
    if (verifyError case final error?) throw error;
    return ResetToken(
      token: 't-$code',
      expiresAt: testNow.add(const Duration(minutes: 15)),
    );
  }

  @override
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    calls.add('reset:$resetToken');
    if (resetError case final error?) throw error;
  }
}

/// A fixed installed version, in place of the platform's.
class FakeAppInfoRepository implements AppInfoRepository {
  const FakeAppInfoRepository([
    this.version = const AppVersion(version: '1.4.0', build: '27'),
  ]);

  final AppVersion version;

  @override
  Future<AppVersion> getVersion() async => version;
}

/// In-memory accounts; records every write.
class FakeClientsRepository implements ClientsRepository {
  FakeClientsRepository([List<Client> clients = const []])
    : clients = [...clients];

  List<Client> clients;
  Failure? error;
  Failure? deleteError;
  final writes = <String>[];

  /// Every non-empty search the server received.
  final searches = <String>[];

  /// When set, searches wait for it (a slow server).
  Completer<void>? searchGate;
  final drafts = <ClientDraft>[];

  @override
  Future<List<Client>> getMyClients({String search = ''}) async {
    if (error case final error?) throw error;
    if (search.isEmpty) return clients;
    searches.add(search);
    await searchGate?.future;
    final text = search.toLowerCase();
    return clients
        .where(
          (c) => [
            c.legalName,
            ?c.dba,
            ?c.taxId,
          ].any((v) => v.toLowerCase().contains(text)),
        )
        .toList();
  }

  @override
  Future<Client> getClient(String id) async =>
      clients.firstWhere((c) => c.id == id);

  @override
  Future<Client> createClient(ClientDraft draft) async {
    writes.add('create:${draft.legalName}');
    drafts.add(draft);
    final client = Client(
      id: 'c${clients.length + 1}',
      legalName: draft.legalName!,
      dba: draft.dba,
      status: draft.status ?? ClientStatus.prospect,
    );
    clients = [...clients, client];
    return client;
  }

  @override
  Future<Client> updateClient(String id, ClientDraft draft) async {
    writes.add('update:$id');
    drafts.add(draft);
    final i = clients.indexWhere((c) => c.id == id);
    final c = clients[i];
    final updated = Client(
      id: c.id,
      legalName: draft.legalName ?? c.legalName,
      dba: draft.dba ?? c.dba,
      status: draft.status ?? c.status,
      industry: draft.industry ?? c.industry,
    );
    clients = [...clients]..[i] = updated;
    return updated;
  }

  @override
  Future<void> deleteClient(String id) async {
    if (deleteError case final error?) throw error;
    writes.add('delete:$id');
    clients = clients.where((c) => c.id != id).toList();
  }

  @override
  Future<void> purgeClient(String id) async {
    writes.add('purge:$id');
    clients = clients.where((c) => c.id != id).toList();
  }
}

/// In-memory contacts, kept like the API: primary first, at most one
/// primary and one billing contact per account. Records every write.
class FakeContactsRepository implements ContactsRepository {
  FakeContactsRepository([List<Contact> contacts = const []])
    : contacts = [...contacts];

  List<Contact> contacts;
  final writes = <String>[];
  final drafts = <ContactDraft>[];

  /// Contact ids whose login would clash with an existing user's email.
  final emailTaken = <String>{};

  @override
  Future<List<Contact>> getContacts(String clientId) async =>
      contacts.where((c) => c.clientId == clientId).toList()..sort(
        (a, b) => a.isPrimary == b.isPrimary
            ? a.lastName.compareTo(b.lastName)
            : (a.isPrimary ? -1 : 1),
      );

  Contact _fromDraft(
    String id,
    String clientId,
    ContactDraft d, {
    String? userId,
  }) {
    String? text(String? v) => (v ?? '').trim().isEmpty ? null : v!.trim();
    return Contact(
      id: id,
      clientId: clientId,
      firstName: d.firstName.trim(),
      lastName: d.lastName.trim(),
      title: text(d.title),
      email: text(d.email),
      phone: text(d.phone),
      notes: text(d.notes),
      isPrimary: d.isPrimary,
      isBillingContact: d.isBillingContact,
      userId: userId,
    );
  }

  /// Setting a flag clears it on the account's other contacts.
  void _clearFlags(String clientId, ContactDraft d, String exceptId) {
    contacts = [
      for (final c in contacts)
        if (c.clientId != clientId || c.id == exceptId)
          c
        else
          Contact(
            id: c.id,
            clientId: c.clientId,
            firstName: c.firstName,
            lastName: c.lastName,
            title: c.title,
            email: c.email,
            phone: c.phone,
            notes: c.notes,
            isPrimary: c.isPrimary && !d.isPrimary,
            isBillingContact: c.isBillingContact && !d.isBillingContact,
            userId: c.userId,
          ),
    ];
  }

  @override
  Future<Contact> createContact(String clientId, ContactDraft draft) async {
    writes.add('create:${draft.firstName}');
    drafts.add(draft);
    final contact = _fromDraft('k${contacts.length + 1}', clientId, draft);
    _clearFlags(clientId, draft, contact.id);
    contacts = [...contacts, contact];
    return contact;
  }

  @override
  Future<Contact> updateContact(
    String clientId,
    String contactId,
    ContactDraft draft,
  ) async {
    writes.add('update:$contactId');
    drafts.add(draft);
    final i = contacts.indexWhere((c) => c.id == contactId);
    final contact = _fromDraft(
      contactId,
      clientId,
      draft,
      userId: contacts[i].userId,
    );
    contacts = [...contacts]..[i] = contact;
    _clearFlags(clientId, draft, contactId);
    return contact;
  }

  @override
  Future<void> deleteContact(String clientId, String contactId) async {
    writes.add('delete:$contactId');
    contacts = contacts.where((c) => c.id != contactId).toList();
  }

  @override
  Future<ContactLogin> createLogin(
    String clientId,
    String contactId,
    String password,
  ) async {
    if (emailTaken.contains(contactId)) {
      throw const ServerFailure('users.email_taken', statusCode: 409);
    }
    writes.add('login:$contactId');
    final i = contacts.indexWhere((c) => c.id == contactId);
    final c = contacts[i];
    contacts = [...contacts]
      ..[i] = Contact(
        id: c.id,
        clientId: c.clientId,
        firstName: c.firstName,
        lastName: c.lastName,
        title: c.title,
        email: c.email,
        phone: c.phone,
        notes: c.notes,
        isPrimary: c.isPrimary,
        isBillingContact: c.isBillingContact,
        userId: 'u-$contactId',
      );
    return ContactLogin(userId: 'u-$contactId', email: c.email!);
  }
}

/// In-memory locations, searched and ordered like the API. Deleting one
/// that scopes or jobs use fails like the API does. Records every write.
class FakeLocationsRepository implements LocationsRepository {
  FakeLocationsRepository([List<Location> locations = const []])
    : locations = [...locations];

  List<Location> locations;
  final writes = <String>[];
  final drafts = <LocationDraft>[];

  /// Every non-empty search the server received.
  final searches = <String>[];

  /// What address search offers, for any query; [suggestFailure] instead
  /// fails it. [suggestQueries] records `query/language`.
  List<AddressSuggestion> suggestions = const [];
  Failure? suggestFailure;
  final suggestQueries = <String>[];

  @override
  Future<List<AddressSuggestion>> suggestAddresses(
    String clientId,
    String query, {
    required String language,
  }) async {
    suggestQueries.add('$query/$language');
    if (suggestFailure case final f?) throw f;
    return suggestions;
  }

  @override
  Future<List<Location>> getLocations(
    String clientId, {
    String search = '',
  }) async {
    if (search.isNotEmpty) searches.add(search);
    final text = search.toLowerCase();
    return locations
        .where((l) => l.clientId == clientId)
        .where(
          (l) => [
            l.name,
            l.address,
            l.city,
          ].any((v) => v.toLowerCase().contains(text)),
        )
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Future<Location> getLocation(String clientId, String locationId) async {
    for (final l in locations) {
      if (l.id == locationId) return l;
    }
    throw const ServerFailure('locations.not_found', statusCode: 404);
  }

  Location _fromDraft(
    String id,
    String clientId,
    LocationDraft d, [
    Location? was,
  ]) {
    String? text(String? v) => (v ?? '').trim().isEmpty ? null : v!.trim();
    return Location(
      id: id,
      clientId: clientId,
      name: d.name.trim(),
      address: d.address.trim(),
      city: d.city.trim(),
      state: d.state.trim(),
      zipCode: d.zipCode.trim(),
      accessCodes: text(d.accessCodes),
      squareFootage: text(d.squareFootage),
      floorCount: int.tryParse(d.floorCount ?? ''),
      specialInstructions: text(d.specialInstructions),
      scopeOfWorkCount: was?.scopeOfWorkCount ?? 0,
      jobCount: was?.jobCount ?? 0,
    );
  }

  @override
  Future<void> createLocation(String clientId, LocationDraft draft) async {
    writes.add('create:${draft.name}');
    drafts.add(draft);
    locations = [
      ...locations,
      _fromDraft('l${locations.length + 1}', clientId, draft),
    ];
  }

  @override
  Future<void> updateLocation(
    String clientId,
    String locationId,
    LocationDraft draft,
  ) async {
    writes.add('update:$locationId');
    drafts.add(draft);
    final i = locations.indexWhere((l) => l.id == locationId);
    locations = [...locations]
      ..[i] = _fromDraft(locationId, clientId, draft, locations[i]);
  }

  @override
  Future<void> deleteLocation(String clientId, String locationId) async {
    final location = await getLocation(clientId, locationId);
    if (location.isInUse) {
      throw const ServerFailure(
        'locations.has_related_records',
        statusCode: 409,
      );
    }
    writes.add('delete:$locationId');
    locations = locations.where((l) => l.id != locationId).toList();
  }
}

/// In-memory calendar with the API's rules: cancelled events and those
/// turned into jobs don't change, moves keep a history entry. Records every
/// write, each month generated, and every draft.
class FakeCalendarRepository implements CalendarRepository {
  FakeCalendarRepository([List<CalendarEvent> events = const []])
    : events = [...events];

  List<CalendarEvent> events;
  final writes = <String>[];
  final generated = <String>[];
  final drafts = <EventDraft>[];
  final moves = <String, List<EventReschedule>>{};

  static String _ymd(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  @override
  Future<List<CalendarEvent>> getEvents(
    String clientId, {
    required DateTime from,
    required DateTime to,
  }) async =>
      events
          .where((e) => !e.date.isBefore(from) && !e.date.isAfter(to))
          .toList()
        ..sort((a, b) {
          final byDay = a.date.compareTo(b.date);
          return byDay != 0 ? byDay : a.startTime.compareTo(b.startTime);
        });

  @override
  Future<int> generate(
    String clientId, {
    required DateTime from,
    required DateTime to,
  }) async {
    generated.add('${_ymd(from)}..${_ymd(to)}');
    return 0;
  }

  @override
  Future<CalendarEvent> getEvent(String clientId, String eventId) async {
    for (final e in events) {
      if (e.id == eventId) return e;
    }
    throw const ServerFailure('calendar.not_found', statusCode: 404);
  }

  @override
  Future<List<EventReschedule>> getReschedules(
    String clientId,
    String eventId,
  ) async => moves[eventId] ?? const [];

  Future<CalendarEvent> _editable(String clientId, String eventId) async {
    final e = await getEvent(clientId, eventId);
    if (e.isCancelled) {
      throw const ServerFailure('calendar.cancelled', statusCode: 409);
    }
    if (e.isConverted) {
      throw const ServerFailure('calendar.already_converted', statusCode: 409);
    }
    return e;
  }

  CalendarEvent _copy(
    CalendarEvent e, {
    EventDraft? draft,
    DateTime? date,
    ClockTime? start,
    bool clearEnd = false,
    ClockTime? end,
    CalendarEventStatus? status,
  }) {
    String? text(String? v) => v == null || v.trim().isEmpty ? null : v.trim();
    return CalendarEvent(
      id: e.id,
      title: draft?.title.trim() ?? e.title,
      date: date ?? e.date,
      startTime: start ?? e.startTime,
      endTime: clearEnd ? end : (draft != null ? draft.endTime : e.endTime),
      status: status ?? e.status,
      notes: draft == null ? e.notes : text(draft.notes),
      locationId: draft == null ? e.locationId : draft.locationId,
      locationName: draft == null || draft.locationId == e.locationId
          ? e.locationName
          : 'Location ${draft.locationId}',
      scopeId: draft == null ? e.scopeId : draft.scopeId,
      scopeArea: e.scopeArea,
      assignedToId: draft == null ? e.assignedToId : draft.assignedToId,
      assignedToName: e.assignedToName,
      jobId: e.jobId,
      scheduleId: e.scheduleId,
    );
  }

  void _replace(CalendarEvent next) =>
      events = [for (final e in events) e.id == next.id ? next : e];

  @override
  Future<CalendarEvent> createEvent(String clientId, EventDraft draft) async {
    writes.add('create:${_ymd(draft.date!)} ${draft.startTime!.wire}');
    drafts.add(draft);
    final created = _copy(
      CalendarEvent(
        id: 'e${events.length + 1}',
        title: '',
        date: draft.date!,
        startTime: draft.startTime!,
        status: CalendarEventStatus.scheduled,
      ),
      draft: draft,
    );
    events = [...events, created];
    return created;
  }

  @override
  Future<CalendarEvent> updateEvent(
    String clientId,
    String eventId,
    EventDraft draft,
  ) async {
    final e = await _editable(clientId, eventId);
    writes.add('update:$eventId');
    drafts.add(draft);
    final next = _copy(e, draft: draft);
    _replace(next);
    return next;
  }

  @override
  Future<CalendarEvent> rescheduleEvent(
    String clientId,
    String eventId,
    RescheduleDraft draft,
  ) async {
    final e = await _editable(clientId, eventId);
    writes.add(
      'reschedule:$eventId:${_ymd(draft.date)} ${draft.startTime.wire}'
      '-${draft.endTime?.wire}:${draft.reason}',
    );
    moves[eventId] = [
      EventReschedule(
        previousDate: e.date,
        previousStart: e.startTime,
        newDate: draft.date,
        newStart: draft.startTime,
        reason: draft.reason,
        byName: 'Ana Pérez',
      ),
      ...?moves[eventId],
    ];
    final next = _copy(
      e,
      date: draft.date,
      start: draft.startTime,
      clearEnd: true,
      end: draft.endTime,
      status: CalendarEventStatus.rescheduled,
    );
    _replace(next);
    return next;
  }

  @override
  Future<CalendarEvent> cancelEvent(String clientId, String eventId) async {
    final e = await _editable(clientId, eventId);
    writes.add('cancel:$eventId');
    final next = _copy(e, status: CalendarEventStatus.cancelled);
    _replace(next);
    return next;
  }

  @override
  Future<void> deleteEvent(String clientId, String eventId) async {
    final e = await getEvent(clientId, eventId);
    if (e.isConverted) {
      throw const ServerFailure('calendar.already_converted', statusCode: 409);
    }
    writes.add('delete:$eventId');
    events = events.where((x) => x.id != eventId).toList();
  }
}

/// In-memory scopes with the API's rules: weekly and biweekly windows need
/// weekdays, a scope with jobs isn't deleted, and an update without
/// `schedules` keeps the windows. Records every write and draft.
class FakeScopesRepository implements ScopesRepository {
  FakeScopesRepository([List<Scope> scopes = const []]) : scopes = [...scopes];

  List<Scope> scopes;
  final writes = <String>[];
  final drafts = <ScopeDraft>[];

  @override
  Future<List<Scope>> getScopes(String clientId, {String? contractId}) async =>
      [
        for (final s in scopes)
          if (contractId == null || s.contractId == contractId) s,
      ];

  @override
  Future<Scope> getScope(String clientId, String scopeId) async {
    for (final s in scopes) {
      if (s.id == scopeId) return s;
    }
    throw const ServerFailure('scopes.not_found', statusCode: 404);
  }

  static void _checkDays(ScopeDraft d) {
    if (d.frequency.needsDays &&
        (d.schedules ?? const []).any((w) => w.daysOfWeek.isEmpty)) {
      throw const ServerFailure(
        'scopes.days_of_week_required',
        statusCode: 400,
      );
    }
  }

  Scope _from(ScopeDraft d, {required String id, Scope? base}) {
    String? text(String? v) => v == null || v.trim().isEmpty ? null : v.trim();
    return Scope(
      id: id,
      contractId: base?.contractId ?? d.contractId!,
      contractStart: base?.contractStart,
      contractEnd: base?.contractEnd,
      locationId: d.locationId,
      locationName: base?.locationId == d.locationId
          ? base?.locationName
          : 'Location ${d.locationId}',
      serviceId: d.serviceId,
      areaName: text(d.areaName),
      frequency: d.frequency,
      instructions: text(d.instructions),
      exclusions: text(d.exclusions),
      estimatedDurationMinutes: int.tryParse(d.estimatedDurationMinutes ?? ''),
      requiredSupplies: text(d.requiredSupplies),
      jobCount: base?.jobCount ?? 0,
      schedules: d.schedules ?? base?.schedules ?? const [],
    );
  }

  @override
  Future<Scope> createScope(String clientId, ScopeDraft draft) async {
    _checkDays(draft);
    writes.add('create:${draft.contractId}');
    drafts.add(draft);
    final created = _from(draft, id: 's${scopes.length + 1}');
    scopes = [...scopes, created];
    return created;
  }

  @override
  Future<Scope> updateScope(
    String clientId,
    String scopeId,
    ScopeDraft draft,
  ) async {
    final current = await getScope(clientId, scopeId);
    _checkDays(draft);
    writes.add('update:$scopeId');
    drafts.add(draft);
    final next = _from(draft, id: scopeId, base: current);
    scopes = [for (final s in scopes) s.id == scopeId ? next : s];
    return next;
  }

  @override
  Future<void> deleteScope(String clientId, String scopeId) async {
    final s = await getScope(clientId, scopeId);
    if (s.jobCount > 0) {
      throw const ServerFailure('scopes.has_jobs', statusCode: 409);
    }
    writes.add('delete:$scopeId');
    scopes = scopes.where((x) => x.id != scopeId).toList();
  }
}

/// In-memory tasks with the API's rules: a completed task can't change,
/// only a completed or cancelled one reopens (to pending), and the due-date
/// fields are worked out from [testNow]. Records every write and draft;
/// [members] names assignees, and [inactive] users are refused.
class FakeTasksRepository implements TasksRepository {
  FakeTasksRepository([List<Task> tasks = const []]) : tasks = [...tasks];

  List<Task> tasks;
  final writes = <String>[];
  final drafts = <TaskDraft>[];

  /// User ids to names, for who's assigned.
  Map<String, String> members = const {'u-ana': 'Ana Pérez'};

  /// User ids refused as assignees.
  final inactive = <String>{};

  /// Who `GET /me/tasks` answers for: [ana] unless a test says otherwise.
  String me = 'u1';

  /// The open, late tasks assigned to [me], soonest due first.
  @override
  Future<List<Task>> getMyOverdueTasks() async => [
    for (final t in tasks)
      if (t.assignedToId == me && t.isOverdue) t,
  ]..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

  @override
  Future<List<Task>> getTasks(String clientId) async =>
      tasks.where((t) => t.clientId == clientId).toList();

  @override
  Future<Task> getTask(String clientId, String taskId) async {
    for (final t in tasks) {
      if (t.id == taskId) return t;
    }
    throw const ServerFailure('tasks.not_found', statusCode: 404);
  }

  /// [t] with the server's derived fields worked out again.
  Task _derive(Task t) {
    final today = DateTime(testNow.year, testNow.month, testNow.day);
    final days = t.dueDate?.difference(today).inDays;
    return Task(
      id: t.id,
      clientId: t.clientId,
      title: t.title,
      description: t.description,
      priority: t.priority,
      status: t.status,
      assignedToId: t.assignedToId,
      assignedToName: members[t.assignedToId] ?? t.assignedToName,
      dueDate: t.dueDate,
      daysUntilDue: days,
      isOverdue: t.isOpen && days != null && days < 0,
    );
  }

  Task _with(Task t, {TaskDraft? draft, TaskStatus? status}) {
    String? text(String? v) => v == null || v.trim().isEmpty ? null : v.trim();
    return _derive(
      Task(
        id: t.id,
        clientId: t.clientId,
        title: draft?.title.trim() ?? t.title,
        description: draft == null ? t.description : text(draft.description),
        priority: draft?.priority ?? t.priority,
        status: status ?? t.status,
        assignedToId: draft == null ? t.assignedToId : draft.assignedToId,
        assignedToName: draft == null ? t.assignedToName : null,
        dueDate: draft == null ? t.dueDate : draft.dueDate,
      ),
    );
  }

  void _replace(Task next) =>
      tasks = [for (final t in tasks) t.id == next.id ? next : t];

  void _checkActive(String? userId) {
    if (userId != null && inactive.contains(userId)) {
      throw const ServerFailure('tasks.assignee_not_active', statusCode: 400);
    }
  }

  Future<Task> _notCompleted(String clientId, String taskId) async {
    final t = await getTask(clientId, taskId);
    if (t.status == TaskStatus.completed) {
      throw const ServerFailure('tasks.already_completed', statusCode: 409);
    }
    return t;
  }

  @override
  Future<Task> createTask(String clientId, TaskDraft draft) async {
    _checkActive(draft.assignedToId);
    writes.add('create:${draft.title.trim()}');
    drafts.add(draft);
    final created = _with(
      Task(
        id: 't${tasks.length + 1}',
        clientId: clientId,
        title: draft.title,
        priority: draft.priority,
        status: TaskStatus.pending,
      ),
      draft: draft,
    );
    tasks = [...tasks, created];
    return created;
  }

  @override
  Future<Task> updateTask(
    String clientId,
    String taskId,
    TaskDraft draft,
  ) async {
    final t = await _notCompleted(clientId, taskId);
    _checkActive(draft.assignedToId);
    writes.add('update:$taskId');
    drafts.add(draft);
    final next = _with(t, draft: draft);
    _replace(next);
    return next;
  }

  @override
  Future<Task> setTaskStatus(
    String clientId,
    String taskId,
    TaskStatus status,
  ) async {
    final t = await _notCompleted(clientId, taskId);
    writes.add('status:$taskId:${status.wire}');
    final next = _with(t, status: status);
    _replace(next);
    return next;
  }

  @override
  Future<Task> completeTask(String clientId, String taskId) async {
    final t = await _notCompleted(clientId, taskId);
    writes.add('complete:$taskId');
    final next = _with(t, status: TaskStatus.completed);
    _replace(next);
    return next;
  }

  @override
  Future<Task> reopenTask(String clientId, String taskId) async {
    final t = await getTask(clientId, taskId);
    if (t.isOpen) {
      throw const ServerFailure('tasks.already_open', statusCode: 409);
    }
    writes.add('reopen:$taskId');
    final next = _with(t, status: TaskStatus.pending);
    _replace(next);
    return next;
  }

  @override
  Future<void> deleteTask(String clientId, String taskId) async {
    await getTask(clientId, taskId);
    writes.add('delete:$taskId');
    tasks = tasks.where((t) => t.id != taskId).toList();
  }
}

/// In-memory complaints with the API's rules: a resolved complaint is
/// read-only until reopened, assigning moves an open one to in progress, and
/// reopening goes back to in progress or open. Records every write and
/// draft; [members] names assignees, and [inactive] users are refused.
class FakeComplaintsRepository implements ComplaintsRepository {
  FakeComplaintsRepository([List<Complaint> complaints = const []])
    : complaints = [...complaints];

  List<Complaint> complaints;
  final writes = <String>[];
  final drafts = <ComplaintDraft>[];

  /// User ids to names, for who's assigned.
  Map<String, String> members = const {'u-ana': 'Ana Pérez'};

  /// User ids refused as assignees.
  final inactive = <String>{};

  @override
  Future<List<Complaint>> getComplaints(
    String clientId, {
    String? jobId,
  }) async => complaints
      .where(
        (c) => c.clientId == clientId && (jobId == null || c.jobId == jobId),
      )
      .toList();

  @override
  Future<Complaint> getComplaint(String clientId, String complaintId) async {
    for (final c in complaints) {
      if (c.id == complaintId) return c;
    }
    throw const ServerFailure('complaints.not_found', statusCode: 404);
  }

  Complaint _with(
    Complaint c, {
    ComplaintDraft? draft,
    ComplaintStatus? status,
    String? assignedToId,
    String? resolutionNotes,
    bool resolved = false,
    bool reopened = false,
    List<ComplaintPhoto>? photos,
  }) {
    String? text(String? v) => v == null || v.trim().isEmpty ? null : v.trim();
    final assignee = assignedToId ?? c.assignedToId;
    return Complaint(
      id: c.id,
      clientId: c.clientId,
      title: draft?.title.trim() ?? c.title,
      description: draft?.description.trim() ?? c.description,
      priority: draft?.priority ?? c.priority,
      status: status ?? c.status,
      reportedDate: c.reportedDate,
      locationId: draft == null ? c.locationId : draft.locationId,
      locationName: draft == null || draft.locationId == c.locationId
          ? c.locationName
          : null,
      area: draft == null ? c.area : text(draft.area),
      jobId: draft == null ? c.jobId : draft.jobId,
      jobTitle: draft == null || draft.jobId == c.jobId ? c.jobTitle : null,
      jobStart: draft == null || draft.jobId == c.jobId ? c.jobStart : null,
      assignedToId: assignee,
      assignedToName: members[assignee] ?? c.assignedToName,
      reportedByName: c.reportedByName,
      resolvedByName: resolved
          ? 'Ana Pérez'
          : reopened
          ? null
          : c.resolvedByName,
      resolutionTime: resolved
          ? testNow
          : reopened
          ? null
          : c.resolutionTime,
      resolutionNotes: resolutionNotes ?? c.resolutionNotes,
      resolutionHours: resolved
          ? 2
          : reopened
          ? null
          : c.resolutionHours,
      photos: photos ?? c.photos,
    );
  }

  void _replace(Complaint next) =>
      complaints = [for (final c in complaints) c.id == next.id ? next : c];

  Future<Complaint> _open(String clientId, String complaintId) async {
    final c = await getComplaint(clientId, complaintId);
    if (c.isResolved) {
      throw const ServerFailure('complaints.already_resolved', statusCode: 409);
    }
    return c;
  }

  void _checkActive(String? userId) {
    if (userId != null && inactive.contains(userId)) {
      throw const ServerFailure(
        'complaints.assignee_not_active',
        statusCode: 400,
      );
    }
  }

  @override
  Future<Complaint> createComplaint(
    String clientId,
    ComplaintDraft draft,
  ) async {
    _checkActive(draft.assignedToId);
    writes.add('create:${draft.title.trim()}');
    drafts.add(draft);
    final created = _with(
      Complaint(
        id: 'q${complaints.length + 1}',
        clientId: clientId,
        title: draft.title,
        description: draft.description,
        priority: draft.priority,
        status: draft.assignedToId == null
            ? ComplaintStatus.open
            : ComplaintStatus.inProgress,
        reportedDate: testNow,
        reportedByName: 'Ana Pérez',
      ),
      draft: draft,
      assignedToId: draft.assignedToId,
    );
    complaints = [created, ...complaints];
    return created;
  }

  @override
  Future<Complaint> updateComplaint(
    String clientId,
    String complaintId,
    ComplaintDraft draft,
  ) async {
    final c = await _open(clientId, complaintId);
    writes.add('update:$complaintId');
    drafts.add(draft);
    final next = _with(c, draft: draft);
    _replace(next);
    return next;
  }

  @override
  Future<Complaint> assignComplaint(
    String clientId,
    String complaintId,
    String userId,
  ) async {
    final c = await _open(clientId, complaintId);
    _checkActive(userId);
    writes.add('assign:$complaintId:$userId');
    final next = _with(
      c,
      assignedToId: userId,
      status: c.status == ComplaintStatus.open
          ? ComplaintStatus.inProgress
          : c.status,
    );
    _replace(next);
    return next;
  }

  @override
  Future<Complaint> resolveComplaint(
    String clientId,
    String complaintId,
    String notes,
  ) async {
    final c = await _open(clientId, complaintId);
    writes.add('resolve:$complaintId');
    final next = _with(
      c,
      status: ComplaintStatus.resolved,
      resolutionNotes: notes,
      resolved: true,
    );
    _replace(next);
    return next;
  }

  @override
  Future<Complaint> reopenComplaint(String clientId, String complaintId) async {
    final c = await getComplaint(clientId, complaintId);
    if (!c.isResolved) {
      throw const ServerFailure('complaints.not_resolved', statusCode: 409);
    }
    writes.add('reopen:$complaintId');
    final next = _with(
      c,
      status: c.assignedToId == null
          ? ComplaintStatus.open
          : ComplaintStatus.inProgress,
      reopened: true,
    );
    _replace(next);
    return next;
  }

  /// Upload failures, by the picked file's path.
  final photoFailures = <String, Failure>{};

  @override
  Future<ComplaintPhoto> addPhoto(
    String clientId,
    String complaintId,
    PickedPhoto photo,
  ) async {
    final c = await _open(clientId, complaintId);
    if (photoFailures[photo.path] case final f?) throw f;
    if (c.photos.length >= Complaint.maxPhotos) {
      throw const ServerFailure('complaints.photo_limit', statusCode: 400);
    }
    writes.add('photo:$complaintId:${photo.path}');
    final added = ComplaintPhoto(
      id: 'ph${c.photos.length + 1}',
      url: 'https://cdn.test/${photo.path.split('/').last}',
      createdAt: testNow,
    );
    _replace(_with(c, photos: [...c.photos, added]));
    return added;
  }

  @override
  Future<void> removePhoto(
    String clientId,
    String complaintId,
    String photoId,
  ) async {
    final c = await _open(clientId, complaintId);
    writes.add('unphoto:$complaintId:$photoId');
    _replace(
      _with(
        c,
        photos: [
          for (final p in c.photos)
            if (p.id != photoId) p,
        ],
      ),
    );
  }
}

/// In-memory invoices with the API's rules: only a draft changes, is
/// issued (with lines above zero) or deleted; payments go on issued or
/// partly paid ones up to the balance and move the status; voiding needs
/// nothing paid. Numbers come as `INV-2026-0000n`; an empty due date takes
/// 30 days. Records each write in [writes].
class FakeInvoicesRepository implements InvoicesRepository {
  FakeInvoicesRepository([List<Invoice> invoices = const []])
    : invoices = [...invoices];

  List<Invoice> invoices;
  final writes = <String>[];
  final drafts = <InvoiceDraft>[];
  final payments = <PaymentDraft>[];

  /// Each PDF asked for, as `<invoiceId>:<language>`.
  final pdfs = <String>[];

  /// What each job's service suggests for a line; jobs not listed suggest
  /// nothing.
  Map<String, JobBillingSuggestion> billing = {};

  /// When set, lookups wait on it, so a test can see the fields loading.
  Completer<void>? billingGate;

  @override
  Future<JobBillingSuggestion> getJobBillingSuggestion(
    String clientId,
    String jobId,
  ) async {
    await billingGate?.future;
    return billing[jobId] ?? JobBillingSuggestion.none;
  }

  /// Who each send went to, and in which language.
  final sends = <(List<String>, String)>[];

  /// Thrown by [sendInvoice] when set (a mail provider failure).
  Failure? sendError;

  @override
  Future<Uint8List> getInvoicePdf(
    String clientId,
    String invoiceId, {
    required String language,
  }) async {
    await getInvoice(clientId, invoiceId);
    pdfs.add('$invoiceId:$language');
    return Uint8List.fromList(utf8.encode('%PDF-1.7 $invoiceId'));
  }

  @override
  Future<List<String>> sendInvoice(
    String clientId,
    String invoiceId, {
    required List<String> to,
    required String language,
  }) async {
    final i = await getInvoice(clientId, invoiceId);
    if (!i.canSend) {
      throw const ServerFailure('invoices.not_sendable', statusCode: 409);
    }
    if (sendError case final error?) throw error;
    sends.add((to, language));
    return to;
  }

  @override
  Future<List<Invoice>> getInvoices(
    String clientId, {
    String? contractId,
  }) async => [
    for (final i in invoices)
      if (i.clientId == clientId &&
          (contractId == null || i.contractId == contractId))
        i,
  ];

  @override
  Future<Invoice> getInvoice(String clientId, String invoiceId) async {
    for (final i in invoices) {
      if (i.id == invoiceId) return i;
    }
    throw const ServerFailure('invoices.not_found', statusCode: 404);
  }

  /// [i] with its total, what's paid and (when [payments] change) its
  /// status worked out again.
  static Invoice rebuild(
    Invoice i, {
    String? contractId,
    String? invoiceNumber,
    DateTime? issueDate,
    DateTime? dueDate,
    List<InvoiceLine>? lineItems,
    List<Payment>? payments,
    InvoiceStatus? status,
  }) {
    final lines = lineItems ?? i.lineItems;
    final pays = payments ?? i.payments;
    final total = lines.fold(0, (sum, l) => sum + toCents(l.lineTotal));
    final paid = pays
        .where((p) => !p.isVoided)
        .fold(0, (sum, p) => sum + toCents(p.amount));
    var next = status ?? i.status;
    if (payments != null &&
        next != InvoiceStatus.draft &&
        next != InvoiceStatus.voided) {
      next = paid <= 0
          ? InvoiceStatus.issued
          : paid >= total
          ? InvoiceStatus.paid
          : InvoiceStatus.partiallyPaid;
    }
    final open =
        next == InvoiceStatus.issued || next == InvoiceStatus.partiallyPaid;
    return Invoice(
      id: i.id,
      clientId: i.clientId,
      contractId: contractId ?? i.contractId,
      contractPaymentTerms: i.contractPaymentTerms,
      invoiceNumber: invoiceNumber ?? i.invoiceNumber,
      issueDate: issueDate ?? i.issueDate,
      dueDate: dueDate ?? i.dueDate,
      totalAmount: centsToDecimal(total),
      status: next,
      lineItems: lines,
      payments: pays,
      amountPaid: centsToDecimal(paid),
      balanceDue: centsToDecimal(total - paid),
      isOverdue: open && i.isOverdue,
      daysOverdue: open ? i.daysOverdue : null,
    );
  }

  static List<InvoiceLine> _lines(List<InvoiceLineDraft> drafts) => [
    for (final (n, d) in drafts.indexed)
      InvoiceLine(
        id: 'line-$n',
        jobId: d.jobId,
        jobTitle: d.jobTitle,
        description: d.description,
        quantity: d.quantity,
        unitPrice: d.unitPrice,
        lineTotal: centsToDecimal(lineTotalCents(d.quantity, d.unitPrice)),
      ),
  ];

  void _replace(Invoice next) =>
      invoices = [for (final i in invoices) i.id == next.id ? next : i];

  @override
  Future<Invoice> createInvoice(String clientId, InvoiceDraft draft) async {
    final number = switch (draft.invoiceNumber?.trim()) {
      '' ||
      null => 'INV-2026-${(invoices.length + 1).toString().padLeft(5, '0')}',
      final n => n,
    };
    if (invoices.any((i) => i.invoiceNumber == number)) {
      throw const ServerFailure('errors.unique_violation', statusCode: 409);
    }
    writes.add('create');
    drafts.add(draft);
    final created = rebuild(
      Invoice(
        id: 'inv-${invoices.length + 1}',
        clientId: clientId,
        contractId: draft.contractId,
        invoiceNumber: number,
        issueDate: draft.issueDate,
        dueDate: draft.dueDate ?? draft.issueDate.add(const Duration(days: 30)),
        totalAmount: '0',
        status: InvoiceStatus.draft,
      ),
      lineItems: _lines(draft.lineItems),
    );
    invoices = [...invoices, created];
    return created;
  }

  Future<Invoice> _draft(String clientId, String invoiceId) async {
    final i = await getInvoice(clientId, invoiceId);
    if (!i.isDraft) {
      throw const ServerFailure('invoices.not_draft', statusCode: 409);
    }
    return i;
  }

  @override
  Future<Invoice> updateInvoice(
    String clientId,
    String invoiceId,
    InvoiceDraft draft,
  ) async {
    final i = await _draft(clientId, invoiceId);
    writes.add('update:$invoiceId');
    drafts.add(draft);
    final next = rebuild(
      i,
      contractId: draft.contractId,
      invoiceNumber: draft.invoiceNumber,
      issueDate: draft.issueDate,
      dueDate: draft.dueDate,
      lineItems: _lines(draft.lineItems),
    );
    _replace(next);
    return next;
  }

  @override
  Future<Invoice> issueInvoice(String clientId, String invoiceId) async {
    final i = await _draft(clientId, invoiceId);
    if (!i.canIssue) {
      throw const ServerFailure('invoices.empty', statusCode: 400);
    }
    writes.add('issue:$invoiceId');
    final next = rebuild(i, status: InvoiceStatus.issued);
    _replace(next);
    return next;
  }

  @override
  Future<Invoice> voidInvoice(String clientId, String invoiceId) async {
    final i = await getInvoice(clientId, invoiceId);
    if (i.isVoided) {
      throw const ServerFailure('invoices.void', statusCode: 409);
    }
    if (i.hasPayments) {
      throw const ServerFailure('invoices.has_payments', statusCode: 409);
    }
    writes.add('void:$invoiceId');
    final next = rebuild(i, status: InvoiceStatus.voided);
    _replace(next);
    return next;
  }

  @override
  Future<void> deleteInvoice(String clientId, String invoiceId) async {
    final i = await getInvoice(clientId, invoiceId);
    if (!i.isDraft) {
      throw const ServerFailure(
        'invoices.only_drafts_deletable',
        statusCode: 409,
      );
    }
    writes.add('delete:$invoiceId');
    invoices = [
      for (final other in invoices)
        if (other.id != invoiceId) other,
    ];
  }

  @override
  Future<Invoice> recordPayment(
    String clientId,
    String invoiceId,
    PaymentDraft payment,
  ) async {
    final i = await getInvoice(clientId, invoiceId);
    if (!i.canPay) {
      throw const ServerFailure('invoices.not_payable', statusCode: 409);
    }
    if (toCents(payment.amount) > toCents(i.balanceDue)) {
      throw const ServerFailure('invoices.overpayment', statusCode: 400);
    }
    writes.add('pay:$invoiceId');
    payments.add(payment);
    final next = rebuild(
      i,
      payments: [
        ...i.payments,
        Payment(
          id: 'pay-${i.payments.length + 1}',
          amount: centsToDecimal(toCents(payment.amount)),
          method: payment.method,
          paymentDate: payment.paymentDate ?? testNow,
          reference: switch (payment.reference?.trim()) {
            '' || null => null,
            final r => r,
          },
        ),
      ],
    );
    _replace(next);
    return next;
  }

  @override
  Future<Invoice> voidPayment(
    String clientId,
    String invoiceId,
    String paymentId,
  ) async {
    final i = await getInvoice(clientId, invoiceId);
    final payment = i.payments.where((p) => p.id == paymentId).firstOrNull;
    if (payment == null) {
      throw const ServerFailure('invoices.payment_not_found', statusCode: 404);
    }
    if (payment.isVoided) {
      throw const ServerFailure(
        'invoices.payment_already_voided',
        statusCode: 409,
      );
    }
    writes.add('void-payment:$paymentId');
    final next = rebuild(
      i,
      payments: [
        for (final p in i.payments)
          p.id == paymentId
              ? Payment(
                  id: p.id,
                  amount: p.amount,
                  method: p.method,
                  paymentDate: p.paymentDate,
                  reference: p.reference,
                  isVoided: true,
                )
              : p,
      ],
    );
    _replace(next);
    return next;
  }
}

/// In-memory contracts with the API's rules: a cancelled contract is
/// read-only, signing happens once and activates, only an untouched draft
/// is deleted. Records every write and draft.
class FakeContractsRepository implements ContractsRepository {
  FakeContractsRepository([List<Contract> contracts = const []])
    : contracts = [...contracts];

  List<Contract> contracts;
  final writes = <String>[];
  final drafts = <ContractDraft>[];

  @override
  Future<List<Contract>> getContracts(String clientId) async =>
      contracts.where((c) => c.clientId == clientId).toList();

  @override
  Future<Contract> getContract(String clientId, String contractId) async {
    for (final c in contracts) {
      if (c.id == contractId) return c;
    }
    throw const ServerFailure('contracts.not_found', statusCode: 404);
  }

  Contract _with(
    Contract c, {
    ContractDraft? draft,
    ContractStatus? status,
    DateTime? signedDate,
    String? signedByName,
  }) => Contract(
    id: c.id,
    clientId: c.clientId,
    proposalId: c.proposalId,
    proposalVersion: c.proposalVersion,
    contractValue: draft?.contractValue ?? c.contractValue,
    startDate: draft?.startDate ?? c.startDate,
    expirationDate: draft == null ? c.expirationDate : draft.expirationDate,
    paymentTerms: draft == null
        ? c.paymentTerms
        : switch (draft.paymentTerms?.trim()) {
            '' || null => null,
            final t => t,
          },
    status: status ?? c.status,
    autoRenew: draft?.autoRenew ?? c.autoRenew,
    cancellationNoticeDays: draft == null
        ? c.cancellationNoticeDays
        : int.tryParse(draft.cancellationNoticeDays ?? ''),
    signedByName: signedByName ?? c.signedByName,
    signedDate: signedDate ?? c.signedDate,
    scopeOfWorkCount: c.scopeOfWorkCount,
    invoiceCount: c.invoiceCount,
    daysUntilExpiration: c.daysUntilExpiration,
    isExpiringSoon: c.isExpiringSoon,
  );

  void _replace(Contract next) =>
      contracts = [for (final c in contracts) c.id == next.id ? next : c];

  Future<Contract> _open(String clientId, String contractId) async {
    final c = await getContract(clientId, contractId);
    if (c.isCancelled) {
      throw const ServerFailure('contracts.cancelled', statusCode: 409);
    }
    return c;
  }

  @override
  Future<Contract> createContract(String clientId, ContractDraft draft) async {
    writes.add('create:${draft.proposalId}');
    drafts.add(draft);
    final created = _with(
      Contract(
        id: 'k${contracts.length + 1}',
        clientId: clientId,
        proposalId: draft.proposalId,
        contractValue: '0',
        startDate: draft.startDate,
        status: ContractStatus.draft,
      ),
      draft: draft,
    );
    contracts = [created, ...contracts];
    return created;
  }

  @override
  Future<Contract> updateContract(
    String clientId,
    String contractId,
    ContractDraft draft,
  ) async {
    final c = await _open(clientId, contractId);
    writes.add('update:$contractId');
    drafts.add(draft);
    final next = _with(c, draft: draft);
    _replace(next);
    return next;
  }

  @override
  Future<Contract> signContract(
    String clientId,
    String contractId, {
    DateTime? signedDate,
  }) async {
    final c = await _open(clientId, contractId);
    if (c.isSigned) {
      throw const ServerFailure('contracts.already_signed', statusCode: 409);
    }
    writes.add('sign:$contractId:${signedDate?.toIso8601String()}');
    final next = _with(
      c,
      status: ContractStatus.active,
      signedDate: signedDate ?? DateTime(2026, 9, 23),
      signedByName: 'Ana Pérez',
    );
    _replace(next);
    return next;
  }

  @override
  Future<Contract> markExpired(String clientId, String contractId) async {
    final c = await _open(clientId, contractId);
    writes.add('expire:$contractId');
    final next = _with(c, status: ContractStatus.expired);
    _replace(next);
    return next;
  }

  @override
  Future<Contract> cancelContract(String clientId, String contractId) async {
    final c = await _open(clientId, contractId);
    writes.add('cancel:$contractId');
    final next = _with(c, status: ContractStatus.cancelled);
    _replace(next);
    return next;
  }

  @override
  Future<void> deleteContract(String clientId, String contractId) async {
    final c = await getContract(clientId, contractId);
    if (c.status != ContractStatus.draft) {
      throw const ServerFailure(
        'contracts.only_drafts_deletable',
        statusCode: 409,
      );
    }
    writes.add('delete:$contractId');
    contracts = contracts.where((k) => k.id != contractId).toList();
  }
}

/// In-memory proposals with the API's version rules: only the current,
/// unapproved version changes; a new version retires the current one.
/// Records every write and draft.
class FakeProposalsRepository implements ProposalsRepository {
  FakeProposalsRepository([List<Proposal> proposals = const []])
    : proposals = [...proposals];

  /// Every version of every negotiation.
  List<Proposal> proposals;
  final writes = <String>[];
  final drafts = <ProposalDraft>[];

  /// Each PDF asked for, as `<proposalId>:<language>`.
  final pdfs = <String>[];

  /// Who each send went to, and in which language.
  final sends = <(List<String>, String)>[];

  /// Thrown by [sendProposal] when set (a mail provider failure).
  Failure? sendError;

  @override
  Future<Uint8List> getProposalPdf(
    String clientId,
    String proposalId, {
    required String language,
  }) async {
    await getProposal(clientId, proposalId);
    pdfs.add('$proposalId:$language');
    return Uint8List.fromList(utf8.encode('%PDF-1.7 $proposalId'));
  }

  @override
  Future<List<String>> sendProposal(
    String clientId,
    String proposalId, {
    required List<String> to,
    required String language,
  }) async {
    final p = await getProposal(clientId, proposalId);
    if (!p.isCurrent) {
      throw const ServerFailure(
        'proposals.not_current_version',
        statusCode: 409,
      );
    }
    if (sendError case final error?) throw error;
    sends.add((to, language));
    return to;
  }

  @override
  Future<List<Proposal>> getProposals(String clientId) async => proposals
      .where((p) => p.clientId == clientId && p.isCurrent)
      .toList()
      .reversed
      .toList();

  @override
  Future<Proposal> getProposal(String clientId, String proposalId) async {
    for (final p in proposals) {
      if (p.id == proposalId) return p;
    }
    throw const ServerFailure('proposals.not_found', statusCode: 404);
  }

  @override
  Future<List<Proposal>> getVersions(String clientId, String proposalId) async {
    final p = await getProposal(clientId, proposalId);
    return proposals.where((v) => v.groupId == p.groupId).toList()
      ..sort((a, b) => b.versionNumber.compareTo(a.versionNumber));
  }

  Proposal _fromDraft(
    ProposalDraft d, {
    required String id,
    required String clientId,
    required String groupId,
    required int version,
  }) {
    String? text(String? v) => (v ?? '').trim().isEmpty ? null : v!.trim();
    return Proposal(
      id: id,
      clientId: clientId,
      groupId: groupId,
      stage: d.stage,
      versionNumber: version,
      isCurrent: true,
      versionNote: text(d.versionNote),
      agreedPrice: text(d.agreedPrice),
      validUntil: d.validUntil,
      preparedByName: 'Ana Pérez',
      lineItems: [
        for (final (i, item) in d.lineItems.indexed)
          ProposalLineItem(
            id: '$id-$i',
            serviceId: item.serviceId,
            description: item.description.trim(),
            quantity: item.quantity.trim(),
            unitPrice: item.unitPrice.trim(),
            lineTotal: centsToDecimal(
              lineTotalCents(item.quantity, item.unitPrice),
            ),
          ),
      ],
    );
  }

  Future<Proposal> _editable(String clientId, String proposalId) async {
    final p = await getProposal(clientId, proposalId);
    if (!p.isCurrent) {
      throw const ServerFailure(
        'proposals.not_current_version',
        statusCode: 409,
      );
    }
    if (p.isApproved) {
      throw const ServerFailure('proposals.already_approved', statusCode: 409);
    }
    return p;
  }

  /// When set, deletes wait on it, so a test can see the page mid-delete.
  Completer<void>? deleteGate;

  @override
  Future<void> deleteProposal(String clientId, String proposalId) async {
    writes.add('delete:$proposalId');
    await deleteGate?.future;
    final group = await getVersions(clientId, proposalId);
    if (group.any((v) => v.isApproved)) {
      throw const ServerFailure('proposals.already_approved', statusCode: 409);
    }
    final ids = {for (final v in group) v.id};
    proposals = [
      for (final p in proposals)
        if (!ids.contains(p.id)) p,
    ];
  }

  void _replace(Proposal next) =>
      proposals = [for (final p in proposals) p.id == next.id ? next : p];

  @override
  Future<Proposal> createProposal(String clientId, ProposalDraft draft) async {
    writes.add('create');
    drafts.add(draft);
    final id = 'p${proposals.length + 1}';
    final created = _fromDraft(
      draft,
      id: id,
      clientId: clientId,
      groupId: 'g-$id',
      version: 1,
    );
    proposals = [...proposals, created];
    return created;
  }

  @override
  Future<Proposal> updateProposal(
    String clientId,
    String proposalId,
    ProposalDraft draft,
  ) async {
    final p = await _editable(clientId, proposalId);
    writes.add('update:$proposalId');
    drafts.add(draft);
    final updated = _fromDraft(
      draft,
      id: p.id,
      clientId: clientId,
      groupId: p.groupId,
      version: p.versionNumber,
    );
    _replace(updated);
    return updated;
  }

  @override
  Future<Proposal> addVersion(
    String clientId,
    String proposalId,
    ProposalDraft draft,
  ) async {
    final source = await getProposal(clientId, proposalId);
    writes.add('version:$proposalId');
    drafts.add(draft);
    final versions = await getVersions(clientId, proposalId);
    proposals = [
      for (final p in proposals)
        p.groupId == source.groupId && p.isCurrent ? _retired(p) : p,
    ];
    final created = _fromDraft(
      draft,
      id: 'p${proposals.length + 1}',
      clientId: clientId,
      groupId: source.groupId,
      version: versions.first.versionNumber + 1,
    );
    proposals = [...proposals, created];
    return created;
  }

  static Proposal _retired(Proposal p) => Proposal(
    id: p.id,
    clientId: p.clientId,
    groupId: p.groupId,
    stage: p.stage,
    versionNumber: p.versionNumber,
    isCurrent: false,
    versionNote: p.versionNote,
    agreedPrice: p.agreedPrice,
    validUntil: p.validUntil,
    preparedByName: p.preparedByName,
    lineItems: p.lineItems,
  );

  @override
  Future<Proposal> approveProposal(
    String clientId,
    String proposalId, {
    String? agreedPrice,
  }) async {
    final p = await _editable(clientId, proposalId);
    final price = agreedPrice ?? p.agreedPrice;
    if (price == null) {
      throw const ServerFailure(
        'proposals.agreed_price_required',
        statusCode: 400,
      );
    }
    writes.add('approve:$proposalId:$price');
    final approved = Proposal(
      id: p.id,
      clientId: p.clientId,
      groupId: p.groupId,
      stage: ProposalStage.approved,
      versionNumber: p.versionNumber,
      isCurrent: true,
      versionNote: p.versionNote,
      agreedPrice: price,
      validUntil: p.validUntil,
      preparedByName: p.preparedByName,
      approvedByName: 'Olga Ruiz',
      approvedDate: testNow,
      lineItems: p.lineItems,
    );
    _replace(approved);
    return approved;
  }
}

/// A trimmed permission catalog: two areas plus team, with defaults per
/// base role like the API's.
const testCatalog = PermissionCatalog(
  permissions: [
    'info.view',
    'info.edit',
    'jobs.view',
    'jobs.edit',
    'jobs.assign',
    'team.view',
  ],
  defaultsByRole: {
    'owner': {
      'info.view',
      'info.edit',
      'jobs.view',
      'jobs.edit',
      'jobs.assign',
      'team.view',
    },
    'account_manager': {
      'info.view',
      'info.edit',
      'jobs.view',
      'jobs.edit',
      'jobs.assign',
      'team.view',
    },
    'supervisor': {
      'info.view',
      'jobs.view',
      'jobs.edit',
      'jobs.assign',
      'team.view',
    },
    'crew': {'jobs.view'},
    'client': {'info.view', 'jobs.view'},
  },
);

/// In-memory teams per account, with effective permissions worked out from
/// [testCatalog] like the API does. Records every write.
class FakeTeamRepository implements TeamRepository {
  FakeTeamRepository([List<Member> members = const []])
    : members = [...members];

  List<Member> members;
  final writes = <String>[];

  /// The user ids [setMember] refuses as inactive.
  final inactive = <String>{};

  Member _with(Member m, {String? baseRole, Map<String, bool>? overrides}) {
    final role = baseRole ?? m.baseRole;
    final flags = overrides ?? m.overrides;
    return Member(
      userId: m.userId,
      clientId: m.clientId,
      name: m.name,
      email: m.email,
      isActive: m.isActive,
      baseRole: role,
      overrides: flags,
      permissions:
          {
            ...testCatalog.defaultsFor(role),
            for (final MapEntry(:key, :value) in flags.entries)
              if (value) key,
          }..removeAll([
            for (final MapEntry(:key, :value) in flags.entries)
              if (!value) key,
          ]),
    );
  }

  @override
  Future<List<Member>> getMembers(String clientId) async =>
      members.where((m) => m.clientId == clientId).toList()
        ..sort((a, b) => a.name.compareTo(b.name));

  @override
  Future<PermissionCatalog> getCatalog() async => testCatalog;

  @override
  Future<Member> setMember(
    String clientId, {
    required String userId,
    required String baseRole,
  }) async {
    if (inactive.contains(userId)) {
      throw const ServerFailure('members.user_not_active', statusCode: 400);
    }
    writes.add('member:$userId:$baseRole');
    final i = members.indexWhere(
      (m) => m.userId == userId && m.clientId == clientId,
    );
    // Changing the role keeps the overrides, like the API.
    final member = i >= 0
        ? _with(members[i], baseRole: baseRole)
        : _with(
            Member(
              userId: userId,
              clientId: clientId,
              name: 'User $userId',
              email: '$userId@example.com',
              baseRole: baseRole,
            ),
          );
    members = [
      for (final m in members)
        if (m.userId != userId || m.clientId != clientId) m,
      member,
    ];
    return member;
  }

  @override
  Future<Member> setOverrides(
    String clientId,
    String userId,
    Map<String, bool> overrides,
  ) async {
    writes.add('overrides:$userId:$overrides');
    final i = members.indexWhere(
      (m) => m.userId == userId && m.clientId == clientId,
    );
    final member = _with(members[i], overrides: overrides);
    members = [...members]..[i] = member;
    return member;
  }

  @override
  Future<void> removeMember(String clientId, String userId) async {
    writes.add('remove:$userId');
    members = members
        .where((m) => m.userId != userId || m.clientId != clientId)
        .toList();
  }
}

/// Jobs per client id; a [Failure] value makes that account fail. Writes
/// follow the API's rules (completed and cancelled jobs don't change, only
/// a scheduled job is deleted) and are recorded, with every draft, crew and
/// checklist sent.
class FakeJobsRepository implements JobsRepository {
  FakeJobsRepository([Map<String, Object> byClient = const {}])
    : byClient = {...byClient};

  Map<String, Object> byClient;
  final writes = <String>[];
  final drafts = <JobDraft>[];
  final crews = <List<CrewMember>>[];

  /// Accounts by id, to name them on the user's own jobs; [pumpApp] fills
  /// it from the clients fake.
  Map<String, Client> accounts = {};
  final checklists = <List<String>>[];

  List<Job> _jobs(String clientId) => switch (byClient[clientId]) {
    final Failure failure => throw failure,
    final List<Job> jobs => jobs,
    _ => const [],
  };

  void _replace(String clientId, Job next) => byClient[clientId] = [
    for (final j in _jobs(clientId)) j.id == next.id ? next : j,
  ];

  /// The accounts whose jobs were listed, in order (one per request).
  final listed = <String>[];

  @override
  Future<List<Job>> getJobs({
    required String clientId,
    required DateTime from,
    DateTime? to,
  }) async {
    listed.add(clientId);
    return [
      for (final j in _jobs(clientId))
        if (!j.scheduledStart.isBefore(from) &&
            (to == null || !j.scheduledStart.isAfter(to)))
          j,
    ];
  }

  /// The jobs [me] is on the crew of, in every account that loads (an
  /// account set to fail is left out, as one the user can't view would be).
  @override
  Future<List<AccountJob>> getMyJobs({
    required DateTime from,
    DateTime? to,
  }) async => [
    for (final MapEntry(key: clientId, value: jobs) in byClient.entries)
      if (jobs is List<Job>)
        for (final j in jobs)
          if (j.assignees.any((a) => a.userId == me) &&
              !j.scheduledStart.isBefore(from) &&
              (to == null || !j.scheduledStart.isAfter(to)))
            AccountJob(
              job: j,
              client:
                  accounts[clientId] ??
                  Client(id: clientId, legalName: clientId),
            ),
  ]..sort((a, b) => a.job.scheduledStart.compareTo(b.job.scheduledStart));

  @override
  Future<Job> getJob({required String clientId, required String jobId}) async {
    for (final j in _jobs(clientId)) {
      if (j.id == jobId) return j;
    }
    throw const ServerFailure('jobs.not_found', statusCode: 404);
  }

  Future<Job> _open(String clientId, String jobId) async {
    final j = await getJob(clientId: clientId, jobId: jobId);
    if (!j.isOpen) throw const ServerFailure('jobs.closed', statusCode: 409);
    return j;
  }

  /// People who stay keep what they had (check-in times).
  static List<JobAssignee> _assignees(List<CrewMember> crew, Job? before) => [
    for (final c in crew)
      before?.assignees.where((a) => a.userId == c.userId).firstOrNull ??
          JobAssignee(
            userId: c.userId,
            name: 'User ${c.userId}',
            roleOnJob: c.roleOnJob,
          ),
  ];

  static Job _copy(
    Job j, {
    JobDraft? draft,
    JobStatus? status,
    List<JobAssignee>? assignees,
    List<ChecklistItem>? checklist,
    DateTime? actualStart,
    String? startedByName,
    DateTime? actualEnd,
    String? completedByName,
    JobCompletion? completion,
  }) {
    String? text(String? v) => v == null || v.trim().isEmpty ? null : v.trim();
    return Job(
      actualStart: actualStart ?? j.actualStart,
      startedByName: startedByName ?? j.startedByName,
      actualEnd: actualEnd ?? j.actualEnd,
      completedByName: completedByName ?? j.completedByName,
      qualityScore: completion?.qualityScore ?? j.qualityScore,
      cleanerNotes: text(completion?.cleanerNotes) ?? j.cleanerNotes,
      clientSignoffName:
          text(completion?.clientSignoffName) ?? j.clientSignoffName,
      id: j.id,
      clientId: j.clientId,
      title: draft?.title.trim() ?? j.title,
      status: status ?? j.status,
      jobType: j.jobType,
      scheduledStart: draft?.scheduledStart ?? j.scheduledStart,
      scheduledEnd: draft == null ? j.scheduledEnd : draft.scheduledEnd,
      locationId: draft?.locationId ?? j.locationId,
      location: draft == null || draft.locationId == j.locationId
          ? j.location
          : JobLocation(name: 'Location ${draft.locationId}'),
      scopeId: draft == null ? j.scopeId : draft.scopeId,
      scopeArea: j.scopeArea,
      assignees: assignees ?? j.assignees,
      instructions: draft == null ? j.instructions : text(draft.instructions),
      checklist: checklist ?? j.checklist,
    );
  }

  @override
  Future<Job> createJob({
    required String clientId,
    required JobDraft draft,
    List<CrewMember> crew = const [],
    List<String> checklist = const [],
  }) async {
    writes.add('create:${draft.title.trim()}');
    drafts.add(draft);
    final jobs = _jobs(clientId);
    final created = _copy(
      Job(
        id: 'j${jobs.length + 1}',
        clientId: clientId,
        title: '',
        status: JobStatus.scheduled,
        scheduledStart: draft.scheduledStart,
      ),
      draft: draft,
      assignees: _assignees(crew, null),
    );
    byClient[clientId] = [...jobs, created];
    return created;
  }

  @override
  Future<Job> updateJob({
    required String clientId,
    required String jobId,
    required JobDraft draft,
  }) async {
    final j = await _open(clientId, jobId);
    writes.add('update:$jobId');
    drafts.add(draft);
    final next = _copy(j, draft: draft);
    _replace(clientId, next);
    return next;
  }

  @override
  Future<Job> createFromEvent({
    required String clientId,
    required String eventId,
    List<CrewMember> crew = const [],
  }) async {
    writes.add('convert:$eventId');
    crews.add(crew);
    final created = Job(
      id: 'j-$eventId',
      clientId: clientId,
      title: 'Job from $eventId',
      status: JobStatus.scheduled,
      scheduledStart: testNow,
      assignees: _assignees(crew, null),
    );
    byClient[clientId] = [..._jobs(clientId), created];
    return created;
  }

  @override
  Future<Job> setCrew({
    required String clientId,
    required String jobId,
    required List<CrewMember> crew,
  }) async {
    final j = await getJob(clientId: clientId, jobId: jobId);
    writes.add('crew:$jobId');
    crews.add(crew);
    final next = _copy(j, assignees: _assignees(crew, j));
    _replace(clientId, next);
    return next;
  }

  @override
  Future<Job> setChecklist({
    required String clientId,
    required String jobId,
    required List<String> items,
  }) async {
    final j = await _open(clientId, jobId);
    writes.add('checklist:$jobId');
    checklists.add(items);
    final next = _copy(
      j,
      checklist: [
        for (final (i, text) in items.indexed)
          ChecklistItem(id: '$jobId-i$i', description: text),
      ],
    );
    _replace(clientId, next);
    return next;
  }

  @override
  Future<Job> setChecklistItemDone({
    required String clientId,
    required String jobId,
    required String itemId,
    required bool done,
  }) async {
    final j = await getJob(clientId: clientId, jobId: jobId);
    if (!j.checklist.any((i) => i.id == itemId)) {
      throw const ServerFailure(
        'jobs.checklist_item_not_found',
        statusCode: 404,
      );
    }
    writes.add('${done ? 'tick' : 'reopen'}:$itemId');
    final next = _copy(
      j,
      checklist: [
        for (final i in j.checklist)
          i.id != itemId
              ? i
              : ChecklistItem(
                  id: i.id,
                  description: i.description,
                  isCompleted: done,
                  completedByName: done ? 'Ana Pérez' : null,
                ),
      ],
    );
    _replace(clientId, next);
    return next;
  }

  /// The signed-in user the field actions and `GET /me/jobs` act for
  /// ([ana]).
  String me = 'u1';

  JobAssignee _mine(Job j) =>
      j.crewMember(me) ??
      (throw const ServerFailure('jobs.not_assigned', statusCode: 403));

  Job _withMine(Job j, JobAssignee mine) => _copy(
    j,
    assignees: [for (final a in j.assignees) a.userId == me ? mine : a],
  );

  @override
  Future<Job> checkIn({required String clientId, required String jobId}) async {
    final j = await getJob(clientId: clientId, jobId: jobId);
    final mine = _mine(j);
    if (mine.checkInTime != null) {
      throw const ServerFailure('jobs.already_checked_in', statusCode: 409);
    }
    writes.add('check-in:$jobId');
    final next = _withMine(
      j,
      JobAssignee(
        userId: mine.userId,
        name: mine.name,
        roleOnJob: mine.roleOnJob,
        checkInTime: testNow,
      ),
    );
    _replace(clientId, next);
    return next;
  }

  @override
  Future<Job> checkOut({
    required String clientId,
    required String jobId,
  }) async {
    final j = await getJob(clientId: clientId, jobId: jobId);
    final mine = _mine(j);
    if (mine.checkInTime == null) {
      throw const ServerFailure('jobs.not_checked_in', statusCode: 409);
    }
    writes.add('check-out:$jobId');
    final next = _withMine(
      j,
      JobAssignee(
        userId: mine.userId,
        name: mine.name,
        roleOnJob: mine.roleOnJob,
        checkInTime: mine.checkInTime,
        checkOutTime: testNow.add(const Duration(hours: 2)),
      ),
    );
    _replace(clientId, next);
    return next;
  }

  @override
  Future<Job> startJob({
    required String clientId,
    required String jobId,
  }) async {
    final j = await getJob(clientId: clientId, jobId: jobId);
    if (j.status != JobStatus.scheduled) {
      throw const ServerFailure('jobs.not_scheduled', statusCode: 409);
    }
    writes.add('start:$jobId');
    final next = _copy(
      j,
      status: JobStatus.inProgress,
      actualStart: testNow,
      startedByName: 'Ana Pérez',
    );
    _replace(clientId, next);
    return next;
  }

  /// Every completion sent.
  final completions = <JobCompletion>[];

  @override
  Future<Job> completeJob({
    required String clientId,
    required String jobId,
    required JobCompletion completion,
  }) async {
    final j = await getJob(clientId: clientId, jobId: jobId);
    if (j.status != JobStatus.inProgress) {
      throw const ServerFailure('jobs.not_in_progress', statusCode: 409);
    }
    writes.add('complete:$jobId');
    completions.add(completion);
    final next = _copy(
      j,
      status: JobStatus.completed,
      actualEnd: testNow.add(const Duration(hours: 1)),
      completedByName: 'Ana Pérez',
      completion: completion,
    );
    _replace(clientId, next);
    return next;
  }

  @override
  Future<Job> cancelJob({
    required String clientId,
    required String jobId,
  }) async {
    final j = await getJob(clientId: clientId, jobId: jobId);
    if (j.status == JobStatus.completed) {
      throw const ServerFailure('jobs.already_completed', statusCode: 409);
    }
    writes.add('cancel:$jobId');
    final next = _copy(j, status: JobStatus.cancelled);
    _replace(clientId, next);
    return next;
  }

  @override
  Future<void> deleteJob({
    required String clientId,
    required String jobId,
  }) async {
    final j = await getJob(clientId: clientId, jobId: jobId);
    if (!j.canDelete) {
      throw const ServerFailure(
        'jobs.only_scheduled_deletable',
        statusCode: 409,
      );
    }
    writes.add('delete:$jobId');
    byClient[clientId] = [
      for (final x in _jobs(clientId))
        if (x.id != jobId) x,
    ];
  }
}

/// Memberships per client id (absent means not a member).
class FakeAccessRepository implements AccessRepository {
  FakeAccessRepository([this.byClient = const {}]);

  Map<String, AccountAccess> byClient;

  @override
  Future<AccountAccess?> getMyMembership(String clientId) async =>
      byClient[clientId];
}

/// Saves the profile onto [auth]'s session user, as `PATCH /auth/me` would.
class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository(this.auth);

  final FakeAuthRepository auth;
  String password = 'correct horse battery';
  final writes = <String>[];

  @override
  Future<User> updateProfile(ProfileDraft draft) async {
    writes.add('profile');
    String? text(String? v) => (v ?? '').trim().isEmpty ? null : v!.trim();
    final user = auth.sessionUser!;
    return auth.sessionUser = User(
      id: user.id,
      email: user.email,
      name: draft.name.trim(),
      userType: user.userType,
      isActive: user.isActive,
      roles: user.roles,
      phoneNumber: text(draft.phoneNumber),
      emergencyContactName: text(draft.emergencyContactName),
      emergencyContactPhone: text(draft.emergencyContactPhone),
      photoUrl: user.photoUrl,
    );
  }

  @override
  Future<User> setPhoto(PickedPhoto photo) async {
    writes.add('photo ${photo.path}');
    return auth.sessionUser = _withPhoto(
      'https://cdn.example.com/profile_photos/${auth.sessionUser!.id}/'
      '${writes.length}.webp',
    );
  }

  @override
  Future<User> removePhoto() async {
    writes.add('remove photo');
    return auth.sessionUser = _withPhoto(null);
  }

  User _withPhoto(String? url) {
    final user = auth.sessionUser!;
    return User(
      id: user.id,
      email: user.email,
      name: user.name,
      userType: user.userType,
      isActive: user.isActive,
      roles: user.roles,
      phoneNumber: user.phoneNumber,
      emergencyContactName: user.emergencyContactName,
      emergencyContactPhone: user.emergencyContactPhone,
      photoUrl: url,
    );
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (currentPassword != password) {
      throw const ServerFailure('auth.wrong_current_password', statusCode: 400);
    }
    writes.add('password');
    password = newPassword;
  }
}

/// Hands back [next] (or nothing, as when the user backs out) instead of
/// opening the camera or the library; [sources] records what was asked.
class FakePhotoPicker implements PhotoPicker {
  FakePhotoPicker([this.next]);

  PickedPhoto? next;
  Object? error;
  final sources = <PhotoSource>[];

  @override
  Future<PickedPhoto?> pick(PhotoSource source, {bool selfie = false}) async {
    sources.add(source);
    if (error case final e?) throw e;
    return next;
  }
}

/// An in-memory catalog, filtered like the API. Categories and units carry
/// live service counts, and deleting a used one fails like the API does.
class FakeServiceCatalogRepository implements ServiceCatalogRepository {
  FakeServiceCatalogRepository({
    List<ServiceItem>? services,
    List<ServiceCategory>? categories,
    List<UnitOfMeasure>? units,
  }) : services = [...services ?? _services],
       categories = [...categories ?? _categories],
       units = [...units ?? _units];

  static const janitorial = ServiceCategory(id: 'c1', name: 'Janitorial');
  static const floorCare = ServiceCategory(
    id: 'c2',
    name: 'Floor care',
    description: 'Carpets and hard floors',
  );
  static const sqft = UnitOfMeasure(
    id: 'm1',
    name: 'Square foot',
    abbreviation: 'sq ft',
  );
  static const visit = UnitOfMeasure(id: 'm2', name: 'Visit');
  static const hour = UnitOfMeasure(id: 'm3', name: 'Hour', abbreviation: 'hr');

  static const _categories = [janitorial, floorCare];
  static const _units = [sqft, visit, hour];
  static const _services = [
    ServiceItem(
      id: 's1',
      name: 'Office cleaning',
      category: janitorial,
      unit: sqft,
      defaultPrice: '0.12',
    ),
    ServiceItem(id: 's2', name: 'Window washing', unit: visit, isActive: false),
  ];

  final List<ServiceItem> services;
  final List<ServiceCategory> categories;
  final List<UnitOfMeasure> units;
  final writes = <String>[];

  bool _matches(String text, CatalogQuery q) =>
      text.toLowerCase().contains(q.search.trim().toLowerCase());

  @override
  Future<List<ServiceItem>> getServices(CatalogQuery query) async => services
      .where((s) => query.isActive == null || s.isActive == query.isActive)
      .where(
        (s) => query.categoryId == null || s.category?.id == query.categoryId,
      )
      .where(
        (s) =>
            _matches(s.name, query) || _matches(s.category?.name ?? '', query),
      )
      .toList();

  @override
  Future<ServiceItem> getService(String id) async =>
      services.firstWhere((s) => s.id == id);

  @override
  Future<ServiceItem> createService(ServiceDraft draft) async {
    writes.add('create');
    final service = _fromDraft('s${services.length + 1}', draft);
    services.add(service);
    return service;
  }

  @override
  Future<ServiceItem> updateService(String id, ServiceDraft draft) async {
    writes.add('update:$id');
    final service = _fromDraft(id, draft);
    services[services.indexWhere((s) => s.id == id)] = service;
    return service;
  }

  ServiceItem _fromDraft(String id, ServiceDraft d) {
    String? text(String? v) => (v ?? '').trim().isEmpty ? null : v!.trim();
    return ServiceItem(
      id: id,
      name: d.name.trim(),
      unit: units.firstWhere((u) => u.id == d.unitOfMeasureId),
      category: categories.where((c) => c.id == d.categoryId).firstOrNull,
      defaultPrice: text(d.defaultPrice),
      isActive: d.isActive,
    );
  }

  int _usingCategory(String id) =>
      services.where((s) => s.category?.id == id).length;

  int _usingUnit(String id) => services.where((s) => s.unit.id == id).length;

  ServiceCategory _countedCategory(ServiceCategory c) => ServiceCategory(
    id: c.id,
    name: c.name,
    description: c.description,
    isActive: c.isActive,
    serviceCount: _usingCategory(c.id),
  );

  UnitOfMeasure _countedUnit(UnitOfMeasure u) => UnitOfMeasure(
    id: u.id,
    name: u.name,
    abbreviation: u.abbreviation,
    isActive: u.isActive,
    serviceCount: _usingUnit(u.id),
  );

  @override
  Future<List<ServiceCategory>> getCategories(CatalogQuery query) async =>
      categories
          .where((c) => query.isActive == null || c.isActive == query.isActive)
          .where((c) => _matches(c.name, query))
          .map(_countedCategory)
          .toList();

  @override
  Future<ServiceCategory> getCategory(String id) async =>
      _countedCategory(categories.firstWhere((c) => c.id == id));

  @override
  Future<ServiceCategory> saveCategory(String? id, LookupDraft draft) async {
    writes.add(id == null ? 'create category' : 'update category:$id');
    final detail = (draft.detail ?? '').trim();
    final category = ServiceCategory(
      id: id ?? 'c${categories.length + 1}',
      name: draft.name.trim(),
      description: detail.isEmpty ? null : detail,
      isActive: draft.isActive,
    );
    final index = categories.indexWhere((c) => c.id == id);
    index < 0 ? categories.add(category) : categories[index] = category;
    return _countedCategory(category);
  }

  @override
  Future<void> deleteCategory(String id) async {
    if (_usingCategory(id) > 0) {
      throw const ServerFailure('service_categories.in_use', statusCode: 409);
    }
    writes.add('delete category:$id');
    categories.removeWhere((c) => c.id == id);
  }

  @override
  Future<List<UnitOfMeasure>> getUnits(CatalogQuery query) async => units
      .where((u) => query.isActive == null || u.isActive == query.isActive)
      .where((u) => _matches(u.name, query) || _matches(u.short, query))
      .map(_countedUnit)
      .toList();

  @override
  Future<UnitOfMeasure> getUnit(String id) async =>
      _countedUnit(units.firstWhere((u) => u.id == id));

  @override
  Future<UnitOfMeasure> saveUnit(String? id, LookupDraft draft) async {
    writes.add(id == null ? 'create unit' : 'update unit:$id');
    final detail = (draft.detail ?? '').trim();
    final unit = UnitOfMeasure(
      id: id ?? 'm${units.length + 1}',
      name: draft.name.trim(),
      abbreviation: detail.isEmpty ? null : detail,
      isActive: draft.isActive,
    );
    final index = units.indexWhere((u) => u.id == id);
    index < 0 ? units.add(unit) : units[index] = unit;
    return _countedUnit(unit);
  }

  @override
  Future<void> deleteUnit(String id) async {
    if (_usingUnit(id) > 0) {
      throw const ServerFailure('units_of_measure.in_use', statusCode: 409);
    }
    writes.add('delete unit:$id');
    units.removeWhere((u) => u.id == id);
  }
}

/// A fixed "now" for screens that show today: Wednesday Sep 23 2026, 08:00.
final testNow = DateTime(2026, 9, 23, 8);

Job job(
  String id,
  String clientId, {
  String? title,
  int hour = 9,
  int day = 23,
  JobStatus status = JobStatus.scheduled,
  List<JobAssignee> assignees = const [],
  List<ChecklistItem> checklist = const [],
}) => Job(
  id: id,
  clientId: clientId,
  title: title ?? 'Job $id',
  status: status,
  scheduledStart: DateTime(2026, 9, day, hour),
  scheduledEnd: DateTime(2026, 9, day, hour + 2),
  locationId: 'l1',
  location: const JobLocation(name: 'Main office'),
  assignees: assignees,
  checklist: checklist,
);

extension on JobsRepository {
  /// Lets a jobs fake name the accounts from a clients fake.
  void nameAccounts(ClientsRepository? clients) {
    if (this case final FakeJobsRepository jobs) {
      if (clients case final FakeClientsRepository fake) {
        jobs.accounts = {for (final c in fake.clients) c.id: c};
      }
    }
  }
}

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
  ProfileRepository? profile,
  PhotoPicker? photoPicker,
  ServiceCatalogRepository? services,
  ContactsRepository? contacts,
  LocationsRepository? locations,
  TeamRepository? team,
  ProposalsRepository? proposals,
  ContractsRepository? contracts,
  InvoicesRepository? invoices,
  ComplaintsRepository? complaints,
  TasksRepository? tasks,
  ScopesRepository? scopes,
  CalendarRepository? calendar,
  NotificationsRepository? notifications,
  PushRepository? push,
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
        passwordResetRepositoryProvider.overrideWithValue(
          passwordReset ?? FakePasswordResetRepository(),
        ),
        appInfoRepositoryProvider.overrideWithValue(
          const FakeAppInfoRepository(),
        ),
        clientsRepositoryProvider.overrideWithValue(
          clients ?? FakeClientsRepository(),
        ),
        jobsRepositoryProvider.overrideWithValue(
          (jobs ?? FakeJobsRepository())..nameAccounts(clients),
        ),
        accessRepositoryProvider.overrideWithValue(
          access ?? FakeAccessRepository(),
        ),
        usersRepositoryProvider.overrideWithValue(
          users ?? FakeUsersRepository(),
        ),
        rolesRepositoryProvider.overrideWithValue(
          roles ?? FakeRolesRepository(),
        ),
        profileRepositoryProvider.overrideWithValue(
          profile ?? FakeProfileRepository(auth),
        ),
        photoPickerProvider.overrideWithValue(photoPicker ?? FakePhotoPicker()),
        serviceCatalogRepositoryProvider.overrideWithValue(
          services ?? FakeServiceCatalogRepository(),
        ),
        contactsRepositoryProvider.overrideWithValue(
          contacts ?? FakeContactsRepository(),
        ),
        locationsRepositoryProvider.overrideWithValue(
          locations ?? FakeLocationsRepository(),
        ),
        teamRepositoryProvider.overrideWithValue(team ?? FakeTeamRepository()),
        proposalsRepositoryProvider.overrideWithValue(
          proposals ?? FakeProposalsRepository(),
        ),
        contractsRepositoryProvider.overrideWithValue(
          contracts ?? FakeContractsRepository(),
        ),
        complaintsRepositoryProvider.overrideWithValue(
          complaints ?? FakeComplaintsRepository(),
        ),
        tasksRepositoryProvider.overrideWithValue(
          tasks ?? FakeTasksRepository(),
        ),
        invoicesRepositoryProvider.overrideWithValue(
          invoices ?? FakeInvoicesRepository(),
        ),
        // The real viewer renders natively; this shows what it was given.
        pdfViewProvider.overrideWithValue(
          (bytes, name) =>
              Center(child: Text('PDF $name (${bytes.length} bytes)')),
        ),
        scopesRepositoryProvider.overrideWithValue(
          scopes ?? FakeScopesRepository(),
        ),
        calendarRepositoryProvider.overrideWithValue(
          calendar ?? FakeCalendarRepository(),
        ),
        // None unread unless a test says so (the real one is a placeholder
        // count until the API has notifications).
        notificationsRepositoryProvider.overrideWithValue(
          notifications ?? FakeNotificationsRepository(0),
        ),
        pushRepositoryProvider.overrideWithValue(push ?? FakePushRepository()),
        clockProvider.overrideWithValue(() => testNow),
      ],
      retry: (_, _) => null,
      observers: const [LiveDataObserver()],
      child: const App(),
    ),
  );
  await tester.pumpAndSettle();
  return prefs;
}

/// A phone that allows notifications and has [token], with pushes the test
/// sends: [receive] while the app is open, [tap] on one, [launch] as the
/// push that started the app.
class FakePushRepository implements PushRepository {
  FakePushRepository({this.allowed = true, this.launch});

  bool allowed;
  String? currentToken = 'token-1';
  PushMessage? launch;

  /// What the server was told, in order: (token, language).
  final registered = <(String, String)>[];
  final unregistered = <String>[];
  final shown = <PushMessage>[];
  int forgets = 0;
  String? channelName;

  final _received = StreamController<PushMessage>.broadcast();
  final _opened = StreamController<PushMessage>.broadcast();
  final _refreshes = StreamController<String>.broadcast();

  void receive(PushMessage message) => _received.add(message);
  void tap(PushMessage message) => _opened.add(message);
  void refreshToken(String token) {
    currentToken = token;
    _refreshes.add(token);
  }

  @override
  Future<bool> requestPermission() async => allowed;

  @override
  Future<void> prepareChannel(String channelName) async =>
      this.channelName = channelName;

  @override
  Future<String?> token() async => currentToken;

  @override
  Stream<String> get tokenRefreshes => _refreshes.stream;

  @override
  Stream<PushMessage> get received => _received.stream;

  @override
  Stream<PushMessage> get opened => _opened.stream;

  @override
  Future<PushMessage?> launchMessage() async => launch;

  @override
  Future<void> show(PushMessage message) async => shown.add(message);

  @override
  Future<void> registerDevice({
    required String token,
    required String language,
  }) async => registered.add((token, language));

  @override
  Future<void> unregisterDevice(String token) async => unregistered.add(token);

  @override
  Future<void> forgetToken() async {
    forgets++;
    currentToken = null;
  }
}

/// An inbox of [items]. [unread] is the badge's count: set on its own,
/// or worked out from [items] when they're given.
class FakeNotificationsRepository implements NotificationsRepository {
  FakeNotificationsRepository(this.unread, {List<AppNotification>? items})
    : items = [...?items];

  int unread;
  final List<AppNotification> items;

  /// Ids marked read one at a time, in order.
  final reads = <String>[];
  int readAlls = 0;
  Failure? readAllError;

  @override
  Future<int> unreadCount() async => unread;

  @override
  Future<NotificationPage> getNotifications() async =>
      NotificationPage(items: [...items]);

  AppNotification _read(AppNotification n) => AppNotification(
    id: n.id,
    type: n.type,
    createdAt: n.createdAt,
    params: n.params,
    clientId: n.clientId,
    accountName: n.accountName,
    entity: n.entity,
    entityId: n.entityId,
    isRead: true,
  );

  @override
  Future<AppNotification> markRead(String id) async {
    reads.add(id);
    final i = items.indexWhere((n) => n.id == id);
    if (!items[i].isRead && unread > 0) unread--;
    return items[i] = _read(items[i]);
  }

  @override
  Future<int> markAllRead() async {
    if (readAllError case final error?) throw error;
    readAlls++;
    final count = items.where((n) => !n.isRead).length;
    items.setAll(0, items.map(_read));
    unread = 0;
    return count;
  }
}

/// Scrolls the current page until [finder] is built and clear of the
/// bottom bar.
Future<void> revealBelow(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).last,
  );
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

Finder button(String label) => find.widgetWithText(FilledButton, label);

/// The text field under the visible label [label].
Finder field(String label) => find.descendant(
  of: find.ancestor(of: find.text(label), matching: find.byType(Column)).first,
  matching: find.byType(TextFormField),
);
