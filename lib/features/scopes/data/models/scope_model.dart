import '../../domain/entities/scope.dart';

abstract final class ScopeModel {
  /// A date-only column: keep the calendar day, ignore the UTC time.
  static DateTime? _day(Object? value) => switch (value) {
    final String s when s.length >= 10 => DateTime.tryParse(s.substring(0, 10)),
    _ => null,
  };

  static Scope fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map?;
    final service = json['serviceCatalog'] as Map?;
    final contract = json['contract'] as Map?;
    final schedules = [
      for (final item in (json['schedules'] as List? ?? const []))
        ?_schedule((item as Map).cast<String, dynamic>()),
    ]..sort((a, b) => a.startTime.compareTo(b.startTime));
    return Scope(
      id: json['id'] as String,
      contractId: json['contractId'] as String? ?? '',
      contractStart: _day(contract?['startDate']),
      contractEnd: _day(contract?['expirationDate']),
      locationId: json['locationId'] as String? ?? '',
      locationName: location?['name'] as String?,
      locationCity: location?['city'] as String?,
      serviceId: json['serviceCatalogId'] as String?,
      serviceName: service?['name'] as String?,
      areaName: json['areaName'] as String?,
      frequency: ScopeFrequency.fromWire(json['frequency'] as String?),
      instructions: json['instructions'] as String?,
      exclusions: json['exclusions'] as String?,
      estimatedDurationMinutes: (json['estimatedDurationMinutes'] as num?)
          ?.toInt(),
      requiredSupplies: json['requiredSupplies'] as String?,
      jobCount: (json['jobCount'] as num?)?.toInt() ?? 0,
      schedules: schedules,
    );
  }

  /// Null for a window without a readable start time.
  static ScopeSchedule? _schedule(Map<String, dynamic> json) {
    final start = ClockTime.tryParse(json['startTime'] as String?);
    if (start == null) return null;
    return ScopeSchedule(
      daysOfWeek: [
        for (final d in (json['daysOfWeek'] as List? ?? const []))
          (d as num).toInt(),
      ]..sort(),
      startTime: start,
      endTime: ClockTime.tryParse(json['endTime'] as String?),
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

abstract final class ScopeDraftModel {
  /// Body for a create or an update (`PATCH`). An update sends empty
  /// optional fields as null so they're cleared, but never `contractId`
  /// (fixed); a create leaves them out. `schedules` goes only when the
  /// draft has them, since sending it replaces every window.
  static Map<String, dynamic> toJson(ScopeDraft d, {required bool create}) {
    String? text(String? v) => v == null || v.trim().isEmpty ? null : v.trim();
    final optional = <String, dynamic>{
      'serviceCatalogId': text(d.serviceId),
      'areaName': text(d.areaName),
      'instructions': text(d.instructions),
      'exclusions': text(d.exclusions),
      'estimatedDurationMinutes': int.tryParse(
        text(d.estimatedDurationMinutes) ?? '',
      ),
      'requiredSupplies': text(d.requiredSupplies),
    };
    if (create) optional.removeWhere((_, v) => v == null);
    return {
      if (create) 'contractId': d.contractId,
      'locationId': d.locationId,
      'frequency': d.frequency.wire,
      ...optional,
      if (d.schedules case final schedules?)
        'schedules': [
          for (final s in schedules)
            {
              // Only weekly and biweekly work names its days.
              'daysOfWeek': d.frequency.needsDays ? s.daysOfWeek : <int>[],
              'startTime': s.startTime.wire,
              'endTime': ?s.endTime?.wire,
              'isActive': s.isActive,
            },
        ],
    };
  }
}
