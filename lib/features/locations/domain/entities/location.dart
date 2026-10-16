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
    this.latitude,
    this.longitude,
    this.geocodedAt,
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

  /// Where the address is on the map, worked out by the server when the
  /// address is saved. Null when it couldn't be placed, or for a location
  /// saved before addresses were geocoded.
  final double? latitude;
  final double? longitude;
  final DateTime? geocodedAt;

  bool get hasCoordinates => latitude != null && longitude != null;

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

/// A US street address offered while the address is typed in the location
/// form. Picking it fills the address fields; [city], [state] and
/// [zipCode] may be missing, and are then left to the user. It carries no
/// coordinates: the server places the address when it's saved.
class AddressSuggestion {
  const AddressSuggestion({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    this.city,
    this.state,
    this.zipCode,
  });

  final String id;

  /// "1980 Post Oak Boulevard".
  final String name;

  /// "Houston, Texas 77056".
  final String description;
  final String address;
  final String? city;

  /// Two letters, e.g. "TX".
  final String? state;
  final String? zipCode;
}
