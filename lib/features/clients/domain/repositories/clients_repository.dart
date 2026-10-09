import '../entities/client.dart';

/// Every method throws a `Failure` on error.
abstract interface class ClientsRepository {
  /// The accounts the signed-in user belongs to (all of them for a global
  /// owner). The server does the filtering. A non-empty [search] matches the
  /// legal name, trade name or tax ID.
  Future<List<Client>> getMyClients({String search = ''});

  /// One account with its full details. Needs `info.view` on it.
  Future<Client> getClient(String id);

  /// Global `owner` or `account_manager` only.
  Future<Client> createClient(ClientDraft draft);

  /// Needs `info.edit` on the account.
  Future<Client> updateClient(String id, ClientDraft draft);

  /// Global `owner` only, and only for accounts without history
  /// (`clients.has_related_records` otherwise).
  Future<void> deleteClient(String id);

  /// Deletes the account with all of its history (proposals, contracts,
  /// scopes, calendar, locations, jobs, invoices, contacts, memberships) and
  /// deactivates its client logins. Global `owner` only; can't be undone.
  Future<void> purgeClient(String id);
}
