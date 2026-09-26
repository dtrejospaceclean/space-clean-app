import '../../domain/entities/service_item.dart';

abstract final class ServiceItemModel {
  static ServiceItem fromJson(Map<String, dynamic> json) => ServiceItem(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    unitOfMeasure: json['unitOfMeasure'] as String? ?? '',
    category: json['category'] as String?,
    // Decimals arrive as strings; tolerate numbers too.
    defaultPrice: switch (json['defaultPrice']) {
      final String s => s,
      final num n => n.toString(),
      _ => null,
    },
    isActive: json['isActive'] as bool? ?? true,
  );
}

abstract final class ServiceDraftModel {
  /// Body for `POST /service-catalog` and `PATCH /service-catalog/:id`. Every
  /// field is sent, so an emptied optional one is cleared with null.
  static Map<String, dynamic> toJson(ServiceDraft d) {
    String? text(String? v) => v == null || v.trim().isEmpty ? null : v.trim();
    return {
      'name': d.name.trim(),
      'unitOfMeasure': d.unitOfMeasure.trim(),
      'category': text(d.category),
      // The API takes decimals as numbers on input.
      'defaultPrice': switch (text(d.defaultPrice)) {
        final String s => num.tryParse(s),
        null => null,
      },
      'isActive': d.isActive,
    };
  }
}
