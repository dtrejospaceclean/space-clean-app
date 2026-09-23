enum ClientStatus { prospect, active, inactive, unknown }

/// A client account (a cleaning company's customer).
class Client {
  const Client({
    required this.id,
    required this.legalName,
    this.dba,
    this.status = ClientStatus.unknown,
    this.locationCount,
  });

  final String id;
  final String legalName;

  /// "Doing business as" name, when different from the legal name.
  final String? dba;
  final ClientStatus status;
  final int? locationCount;

  /// The name people use day to day.
  String get displayName =>
      (dba != null && dba!.trim().isNotEmpty) ? dba! : legalName;
}
