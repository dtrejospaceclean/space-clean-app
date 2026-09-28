/// A site of a client account where the work happens. Scopes of work, jobs,
/// calendar events and complaints all point at one.
class Location {
  const Location({
    required this.id,
    required this.clientId,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    this.accessCodes,
    this.squareFootage,
    this.floorCount,
    this.specialInstructions,
    this.scopeOfWorkCount = 0,
    this.jobCount = 0,
  });

  final String id;
  final String clientId;

  /// How the site is known, e.g. "Tower A – Floor 3".
  final String name;
  final String address;
  final String city;
  final String state;
  final String zipCode;

  /// Door or alarm codes. Only the account's members ever see them.
  final String? accessCodes;

  /// A decimal string from the API ("12000").
  final String? squareFootage;
  final int? floorCount;
  final String? specialInstructions;
  final int scopeOfWorkCount;
  final int jobCount;

  /// "Houston, TX 77056".
  String get cityLine => [
    city,
    [state, zipCode].where((v) => v.trim().isNotEmpty).join(' '),
  ].where((v) => v.trim().isNotEmpty).join(', ');

  /// Scopes of work or jobs point at it, so the API refuses to delete it.
  bool get isInUse => scopeOfWorkCount > 0 || jobCount > 0;
}

/// The editable fields of a location. Empty optional fields are cleared.
class LocationDraft {
  const LocationDraft({
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    this.accessCodes,
    this.squareFootage,
    this.floorCount,
    this.specialInstructions,
  });

  final String name;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String? accessCodes;

  /// As typed: up to 2 decimals ("12000", "850.5").
  final String? squareFootage;

  /// As typed: a whole number.
  final String? floorCount;
  final String? specialInstructions;
}
