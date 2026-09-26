/// One entry of the company-wide service catalog, which proposal line items
/// and scopes of work pick from. Never deleted, only retired (inactive).
class ServiceItem {
  const ServiceItem({
    required this.id,
    required this.name,
    required this.unitOfMeasure,
    this.category,
    this.defaultPrice,
    this.isActive = true,
  });

  final String id;
  final String name;

  /// Free text such as "sq ft", "hour" or "visit".
  final String unitOfMeasure;
  final String? category;

  /// A decimal string as the API sends it ("0.12"), or null when unpriced.
  final String? defaultPrice;
  final bool isActive;
}

/// The catalog list's search and status filter.
class ServiceQuery {
  const ServiceQuery({this.search = '', this.isActive = true});

  final String search;

  /// `null` shows active and retired services.
  final bool? isActive;

  ServiceQuery copyWith({String? search, bool? Function()? isActive}) =>
      ServiceQuery(
        search: search ?? this.search,
        isActive: isActive == null ? this.isActive : isActive(),
      );

  @override
  bool operator ==(Object other) =>
      other is ServiceQuery &&
      other.search == search &&
      other.isActive == isActive;

  @override
  int get hashCode => Object.hash(search, isActive);
}

/// The editable fields of a service. Empty optional fields clear them.
class ServiceDraft {
  const ServiceDraft({
    required this.name,
    required this.unitOfMeasure,
    this.category,
    this.defaultPrice,
    this.isActive = true,
  });

  final String name;
  final String unitOfMeasure;
  final String? category;

  /// A decimal with up to two places ("0.12").
  final String? defaultPrice;
  final bool isActive;
}
