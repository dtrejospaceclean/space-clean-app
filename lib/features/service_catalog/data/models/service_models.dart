import '../../domain/entities/service_item.dart';

String? _text(String? v) => v == null || v.trim().isEmpty ? null : v.trim();

abstract final class ServiceCategoryModel {
  static ServiceCategory fromJson(Map<String, dynamic> json) => ServiceCategory(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    description: json['description'] as String?,
    isActive: json['isActive'] as bool? ?? true,
    serviceCount: json['serviceCount'] as int? ?? 0,
  );

  /// Body for `POST`/`PATCH /service-categories`.
  static Map<String, dynamic> toJson(LookupDraft d) => {
    'name': d.name.trim(),
    'description': _text(d.detail),
    'isActive': d.isActive,
  };
}

abstract final class UnitOfMeasureModel {
  static UnitOfMeasure fromJson(Map<String, dynamic> json) => UnitOfMeasure(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    abbreviation: _text(json['abbreviation'] as String?),
    isActive: json['isActive'] as bool? ?? true,
    serviceCount: json['serviceCount'] as int? ?? 0,
  );

  /// Body for `POST`/`PATCH /units-of-measure`.
  static Map<String, dynamic> toJson(LookupDraft d) => {
    'name': d.name.trim(),
    'abbreviation': _text(d.detail),
    'isActive': d.isActive,
  };
}

abstract final class ServiceItemModel {
  static ServiceItem fromJson(Map<String, dynamic> json) {
    final unit = json['unitOfMeasure'] as Map?;
    final category = json['category'] as Map?;
    return ServiceItem(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      unit: unit != null
          ? UnitOfMeasureModel.fromJson(unit.cast<String, dynamic>())
          : UnitOfMeasure(
              id: json['unitOfMeasureId'] as String? ?? '',
              name: '',
            ),
      category: category != null
          ? ServiceCategoryModel.fromJson(category.cast<String, dynamic>())
          : null,
      // Decimals arrive as strings; tolerate numbers too.
      defaultPrice: switch (json['defaultPrice']) {
        final String s => s,
        final num n => n.toString(),
        _ => null,
      },
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

abstract final class ServiceDraftModel {
  /// Body for `POST /service-catalog` and `PATCH /service-catalog/:id`. Every
  /// field is sent, so an emptied optional one is cleared with null.
  static Map<String, dynamic> toJson(ServiceDraft d) => {
    'name': d.name.trim(),
    'unitOfMeasureId': d.unitOfMeasureId,
    'categoryId': d.categoryId,
    // The API takes decimals as numbers on input.
    'defaultPrice': switch (_text(d.defaultPrice)) {
      final String s => num.tryParse(s),
      null => null,
    },
    'isActive': d.isActive,
  };
}
