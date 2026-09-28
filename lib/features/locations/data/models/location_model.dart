import '../../domain/entities/location.dart';

abstract final class LocationModel {
  /// A list row or a single location. Create and update responses carry no
  /// counts; they read as 0.
  static Location fromJson(Map<String, dynamic> json) => Location(
    id: json['id'] as String,
    clientId: json['clientAccountId'] as String? ?? '',
    name: json['name'] as String? ?? '',
    address: json['address'] as String? ?? '',
    city: json['city'] as String? ?? '',
    state: json['state'] as String? ?? '',
    zipCode: json['zipCode'] as String? ?? '',
    accessCodes: json['accessCodes'] as String?,
    squareFootage: switch (json['squareFootage']) {
      final String s => s,
      final num n => '$n',
      _ => null,
    },
    floorCount: (json['floorCount'] as num?)?.toInt(),
    specialInstructions: json['specialInstructions'] as String?,
    scopeOfWorkCount: (json['scopeOfWorkCount'] as num?)?.toInt() ?? 0,
    jobCount: (json['jobCount'] as num?)?.toInt() ?? 0,
  );
}

abstract final class LocationDraftModel {
  /// Body for `POST …/locations` / `PATCH …/locations/:id`. Square footage
  /// and floors go as numbers (the API rejects strings). An update sends
  /// empty optional fields as null so they're cleared; a create leaves them
  /// out.
  static Map<String, dynamic> toJson(LocationDraft d, {required bool create}) {
    String? text(String? v) => v == null || v.trim().isEmpty ? null : v.trim();
    final optional = <String, dynamic>{
      'accessCodes': text(d.accessCodes),
      'squareFootage': num.tryParse(text(d.squareFootage) ?? ''),
      'floorCount': int.tryParse(text(d.floorCount) ?? ''),
      'specialInstructions': text(d.specialInstructions),
    };
    if (create) optional.removeWhere((_, v) => v == null);
    return {
      'name': d.name.trim(),
      'address': d.address.trim(),
      'city': d.city.trim(),
      'state': d.state.trim(),
      'zipCode': d.zipCode.trim(),
      ...optional,
    };
  }
}
