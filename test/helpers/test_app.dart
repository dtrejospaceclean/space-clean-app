import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sp_cln_app/app.dart';
import 'package:sp_cln_app/core/error/failures.dart';
import 'package:sp_cln_app/core/refresh/live_data.dart';
import 'package:sp_cln_app/core/storage/preferences.dart';
import 'package:sp_cln_app/features/notifications/di/notifications_providers.dart';
import 'package:sp_cln_app/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:sp_cln_app/features/access/di/access_providers.dart';
import 'package:sp_cln_app/features/access/domain/entities/account_access.dart';
import 'package:sp_cln_app/features/access/domain/repositories/access_repository.dart';
import 'package:sp_cln_app/features/auth/di/auth_providers.dart';
import 'package:sp_cln_app/features/auth/domain/entities/user.dart';
import 'package:sp_cln_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:sp_cln_app/features/clients/di/clients_providers.dart';
import 'package:sp_cln_app/features/clients/domain/entities/client.dart';
import 'package:sp_cln_app/features/clients/domain/repositories/clients_repository.dart';
import 'package:sp_cln_app/features/contacts/di/contacts_providers.dart';
import 'package:sp_cln_app/features/contacts/domain/entities/contact.dart';
import 'package:sp_cln_app/features/contacts/domain/repositories/contacts_repository.dart';
import 'package:sp_cln_app/features/contracts/di/contracts_providers.dart';
import 'package:sp_cln_app/features/contracts/domain/entities/contract.dart';
import 'package:sp_cln_app/features/contracts/domain/repositories/contracts_repository.dart';
import 'package:sp_cln_app/features/jobs/di/jobs_providers.dart';
import 'package:sp_cln_app/features/jobs/domain/entities/job.dart';
import 'package:sp_cln_app/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:sp_cln_app/features/jobs/presentation/controllers/jobs_providers.dart';
import 'package:sp_cln_app/features/locations/di/locations_providers.dart';
import 'package:sp_cln_app/features/locations/domain/entities/location.dart';
import 'package:sp_cln_app/features/locations/domain/repositories/locations_repository.dart';
import 'package:sp_cln_app/features/password_reset/di/password_reset_providers.dart';
import 'package:sp_cln_app/features/password_reset/domain/repositories/password_reset_repository.dart';
import 'package:sp_cln_app/features/profile/di/profile_providers.dart';
import 'package:sp_cln_app/features/profile/domain/entities/profile_draft.dart';
import 'package:sp_cln_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:sp_cln_app/features/proposals/di/proposals_providers.dart';
import 'package:sp_cln_app/features/proposals/domain/entities/proposal.dart';
import 'package:sp_cln_app/features/proposals/domain/repositories/proposals_repository.dart';
import 'package:sp_cln_app/features/service_catalog/di/service_catalog_providers.dart';
import 'package:sp_cln_app/features/team/di/team_providers.dart';
import 'package:sp_cln_app/features/team/domain/entities/member.dart';
import 'package:sp_cln_app/features/team/domain/repositories/team_repository.dart';
import 'package:sp_cln_app/features/service_catalog/domain/entities/service_item.dart';
import 'package:sp_cln_app/features/service_catalog/domain/repositories/service_catalog_repository.dart';
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
  ProfileRepository? profile,
  ServiceCatalogRepository? services,
  ContactsRepository? contacts,
  LocationsRepository? locations,
  TeamRepository? team,
  ProposalsRepository? proposals,
  ContractsRepository? contracts,
  NotificationsRepository? notifications,
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
        profileRepositoryProvider.overrideWithValue(
          profile ?? FakeProfileRepository(auth),
        ),
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
        // None unread unless a test says so (the real one is a placeholder
        // count until the API has notifications).
        notificationsRepositoryProvider.overrideWithValue(
          notifications ?? FakeNotificationsRepository(0),
        ),
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

/// A fixed unread count.
class FakeNotificationsRepository implements NotificationsRepository {
  FakeNotificationsRepository(this.unread);

  int unread;

  @override
  Future<int> unreadCount() async => unread;
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
