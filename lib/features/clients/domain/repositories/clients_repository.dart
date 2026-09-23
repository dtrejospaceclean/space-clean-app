import '../entities/client.dart';

/// Every method throws a `Failure` on error.
abstract interface class ClientsRepository {
  /// The accounts the signed-in user belongs to (all of them for a global
  /// owner). The server does the filtering.
  Future<List<Client>> getMyClients();
}
