/// Groups the catalog ("Janitorial", "Floor care").
class ServiceCategory {
  const ServiceCategory({
    required this.id,
    required this.name,
    this.description,
    this.isActive = true,
    this.serviceCount = 0,
  });

  final String id;
  final String name;
  final String? description;
  final bool isActive;

  /// Services that use it. Only an unused category can be deleted.
  final int serviceCount;
}

/// How a service is priced ("Square foot" shown as "sq ft", "Hour", "Visit").
class UnitOfMeasure {
  const UnitOfMeasure({
    required this.id,
    required this.name,
    this.abbreviation,
    this.isActive = true,
    this.serviceCount = 0,
  });

  final String id;
  final String name;

  /// What prices show next to the amount: "$0.12 / sq ft".
  final String? abbreviation;
  final bool isActive;

  /// Services that use it. Only an unused unit can be deleted.
  final int serviceCount;

  /// The short form when there is one, for prices.
  String get short => abbreviation ?? name;
}

/// One entry of the company-wide service catalog, which proposal line items
/// and scopes of work pick from. Never deleted, only retired (inactive).
class ServiceItem {
  const ServiceItem({
    required this.id,
    required this.name,
    required this.unit,
    this.category,
    this.defaultPrice,
    this.isActive = true,
  });

  final String id;
  final String name;
  final UnitOfMeasure unit;
  final ServiceCategory? category;

  /// A decimal string as the API sends it ("0.12"), or null when unpriced.
  final String? defaultPrice;
  final bool isActive;
}

/// A list's search and status filter; services also filter by category.
class CatalogQuery {
  const CatalogQuery({this.search = '', this.isActive = true, this.categoryId});

  final String search;

  /// `null` shows active and retired entries.
  final bool? isActive;

  /// Services only.
  final String? categoryId;

  CatalogQuery copyWith({
    String? search,
    bool? Function()? isActive,
    String? Function()? categoryId,
  }) => CatalogQuery(
    search: search ?? this.search,
    isActive: isActive == null ? this.isActive : isActive(),
    categoryId: categoryId == null ? this.categoryId : categoryId(),
  );

  @override
  bool operator ==(Object other) =>
      other is CatalogQuery &&
      other.search == search &&
      other.isActive == isActive &&
      other.categoryId == categoryId;

  @override
  int get hashCode => Object.hash(search, isActive, categoryId);
}

/// The editable fields of a service. Empty optional fields clear them.
class ServiceDraft {
  const ServiceDraft({
    required this.name,
    required this.unitOfMeasureId,
    this.categoryId,
    this.defaultPrice,
    this.isActive = true,
  });

  final String name;
  final String unitOfMeasureId;
  final String? categoryId;

  /// A decimal with up to two places ("0.12").
  final String? defaultPrice;
  final bool isActive;
}

/// The editable fields of a category or a unit: a name, one optional detail
/// (the category's description, the unit's abbreviation), and the status.
class LookupDraft {
  const LookupDraft({required this.name, this.detail, this.isActive = true});

  final String name;

  /// Empty clears it.
  final String? detail;
  final bool isActive;
}
