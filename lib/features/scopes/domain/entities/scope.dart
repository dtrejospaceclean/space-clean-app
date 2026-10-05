/// How often a scope's work comes around.
enum ScopeFrequency {
  daily('daily'),
  weekly('weekly'),
  biweekly('biweekly'),
  monthly('monthly'),
  quarterly('quarterly'),
  annual('annual'),
  oneTime('one_time'),

  /// A frequency this app doesn't know yet.
  unknown('');

  const ScopeFrequency(this.wire);

  /// The API's name for it.
  final String wire;

  static ScopeFrequency fromWire(String? value) => values.firstWhere(
    (f) => f != unknown && f.wire == value,
    orElse: () => unknown,
  );

  /// The ones a scope can be given, in order.
  static const known = [
    daily,
    weekly,
    biweekly,
    monthly,
    quarterly,
    annual,
    oneTime,
  ];

  /// Weekly and biweekly work names its weekdays
  /// (`scopes.days_of_week_required` otherwise).
  bool get needsDays => this == weekly || this == biweekly;
}

/// A time of day, as the API's "HH:MM".
class ClockTime implements Comparable<ClockTime> {
  const ClockTime(this.hour, this.minute);

  final int hour;
  final int minute;

  /// "07:00" → 7:00; null for anything else.
  static ClockTime? tryParse(String? value) {
    final match = RegExp(r'^(\d{2}):(\d{2})').firstMatch(value ?? '');
    if (match == null) return null;
    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    if (hour > 23 || minute > 59) return null;
    return ClockTime(hour, minute);
  }

  String get wire =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  int get minutes => hour * 60 + minute;

  @override
  int compareTo(ClockTime other) => minutes.compareTo(other.minutes);

  @override
  bool operator ==(Object other) =>
      other is ClockTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);
}

/// One time window a scope runs in. Several mean several shifts.
class ScopeSchedule {
  const ScopeSchedule({
    required this.startTime,
    this.daysOfWeek = const [],
    this.endTime,
    this.isActive = true,
  });

  /// ISO weekdays, sorted: 1 = Monday … 7 = Sunday. Empty when the
  /// frequency doesn't need them.
  final List<int> daysOfWeek;
  final ClockTime startTime;
  final ClockTime? endTime;

  /// An inactive window stays on the scope but makes no more work.
  final bool isActive;

  @override
  bool operator ==(Object other) =>
      other is ScopeSchedule &&
      other.startTime == startTime &&
      other.endTime == endTime &&
      other.isActive == isActive &&
      other.daysOfWeek.join(',') == daysOfWeek.join(',');

  @override
  int get hashCode =>
      Object.hash(startTime, endTime, isActive, Object.hashAll(daysOfWeek));
}

/// The work agreed for one area of one location under a contract: what,
/// how often, and when.
class Scope {
  const Scope({
    required this.id,
    required this.contractId,
    required this.locationId,
    required this.frequency,
    this.locationName,
    this.locationCity,
    this.contractStart,
    this.contractEnd,
    this.serviceId,
    this.serviceName,
    this.areaName,
    this.instructions,
    this.exclusions,
    this.estimatedDurationMinutes,
    this.requiredSupplies,
    this.jobCount = 0,
    this.schedules = const [],
  });

  final String id;

  /// Fixed once the scope exists.
  final String contractId;
  final DateTime? contractStart;
  final DateTime? contractEnd;
  final String locationId;
  final String? locationName;
  final String? locationCity;
  final String? serviceId;
  final String? serviceName;

  /// The part of the site it covers, e.g. "Lobby" or "Restrooms".
  final String? areaName;
  final ScopeFrequency frequency;
  final String? instructions;

  /// What's explicitly not included.
  final String? exclusions;
  final int? estimatedDurationMinutes;
  final String? requiredSupplies;

  /// Jobs it already produced; with any, it can't be deleted.
  final int jobCount;

  /// Sorted by start time.
  final List<ScopeSchedule> schedules;

  bool get canDelete => jobCount == 0;
}

/// The editable fields of a scope, as typed. Empty optional fields clear
/// them on an edit.
class ScopeDraft {
  const ScopeDraft({
    required this.locationId,
    required this.frequency,
    this.contractId,
    this.serviceId,
    this.areaName,
    this.instructions,
    this.exclusions,
    this.estimatedDurationMinutes,
    this.requiredSupplies,
    this.schedules,
  });

  /// Only on a create.
  final String? contractId;
  final String locationId;
  final String? serviceId;
  final String? areaName;
  final ScopeFrequency frequency;
  final String? instructions;
  final String? exclusions;

  /// As typed: whole minutes.
  final String? estimatedDurationMinutes;
  final String? requiredSupplies;

  /// Null keeps the scope's windows as they are; a list replaces them all.
  /// Replacing unlinks the jobs and calendar events made from the old ones,
  /// so an edit sends them only when they changed.
  final List<ScopeSchedule>? schedules;
}
