enum ClientStatus { prospect, active, inactive, unknown }

/// A staff member in charge of an account (account manager, supervisor or
/// salesperson).
class ClientAssignee {
  const ClientAssignee({required this.id, required this.name, this.email});

  final String id;
  final String name;
  final String? email;
}

/// A client account (a cleaning company's customer).
class Client {
  const Client({
    required this.id,
    required this.legalName,
    this.dba,
    this.status = ClientStatus.unknown,
    this.locationCount,
    this.contactCount,
    this.industry,
    this.serviceType,
    this.taxId,
    this.billingAddress,
    this.billingCity,
    this.billingState,
    this.billingZip,
    this.accountManager,
    this.supervisor,
    this.salesperson,
  });

  final String id;
  final String legalName;

  /// "Doing business as" name, when different from the legal name.
  final String? dba;
  final ClientStatus status;
  final int? locationCount;
  final int? contactCount;
  final String? industry;

  /// Kind of service sold, e.g. "Corporate cleaning". Free text.
  final String? serviceType;
  final String? taxId;
  final String? billingAddress;
  final String? billingCity;
  final String? billingState;
  final String? billingZip;
  final ClientAssignee? accountManager;
  final ClientAssignee? supervisor;
  final ClientAssignee? salesperson;

  /// The name people use day to day.
  String get displayName =>
      (dba != null && dba!.trim().isNotEmpty) ? dba! : legalName;
}

/// The editable fields of an account. On update only non-null fields are
/// sent, plus the names in [cleared], which are sent as null to empty them.
class ClientDraft {
  const ClientDraft({
    this.legalName,
    this.dba,
    this.industry,
    this.status,
    this.serviceType,
    this.taxId,
    this.billingAddress,
    this.billingCity,
    this.billingState,
    this.billingZip,
    this.accountManagerUserId,
    this.supervisorUserId,
    this.salespersonUserId,
    this.cleared = const {},
  });

  final String? legalName;
  final String? dba;
  final String? industry;

  /// Never [ClientStatus.unknown].
  final ClientStatus? status;
  final String? serviceType;
  final String? taxId;
  final String? billingAddress;
  final String? billingCity;
  final String? billingState;
  final String? billingZip;
  final String? accountManagerUserId;
  final String? supervisorUserId;
  final String? salespersonUserId;

  /// Request-body names of optional fields the user emptied.
  final Set<String> cleared;
}
