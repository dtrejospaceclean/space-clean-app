import '../../domain/entities/complaint.dart';

abstract final class ComplaintModel {
  /// An instant in local time, or null.
  static DateTime? _instant(Object? value) => switch (value) {
    final String s => DateTime.tryParse(s)?.toLocal(),
    _ => null,
  };

  /// The `name` of a small `{ id, name }` object.
  static String? _name(Object? value) => switch (value) {
    {'name': final String name} => name,
    _ => null,
  };

  static Complaint fromJson(Map<String, dynamic> json) => Complaint(
    id: json['id'] as String,
    clientId: json['clientAccountId'] as String? ?? '',
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    priority: ComplaintPriority.fromWire(json['priority'] as String?),
    status: ComplaintStatus.fromWire(json['status'] as String?),
    reportedDate: _instant(json['reportedDate']) ?? DateTime(1970),
    locationId: json['locationId'] as String?,
    locationName: _name(json['location']),
    area: json['area'] as String?,
    jobId: json['jobId'] as String?,
    jobTitle: switch (json['job']) {
      {'title': final String title} => title,
      _ => null,
    },
    jobStart: switch (json['job']) {
      {'scheduledStart': final Object start} => _instant(start),
      _ => null,
    },
    assignedToId: json['assignedToUserId'] as String?,
    assignedToName: _name(json['assignedTo']),
    reportedByName: _name(json['reportedBy']),
    resolvedByName: _name(json['resolvedBy']),
    resolutionTime: _instant(json['resolutionTime']),
    resolutionNotes: json['resolutionNotes'] as String?,
    resolutionHours: (json['resolutionHours'] as num?)?.toDouble(),
  );
}

abstract final class ComplaintDraftModel {
  /// Body for a create or an update (`PATCH`). Text is trimmed. An update
  /// sends empty optional fields as null so they're cleared, and never the
  /// assignee (that's `POST …/assign`); a create leaves them out.
  static Map<String, dynamic> toJson(ComplaintDraft d, {required bool create}) {
    String? text(String? v) => v == null || v.trim().isEmpty ? null : v.trim();
    final optional = <String, dynamic>{
      'locationId': d.locationId,
      'area': text(d.area),
      'jobId': d.jobId,
      if (create) 'assignedToUserId': d.assignedToId,
    };
    if (create) optional.removeWhere((_, v) => v == null);
    return {
      'title': d.title.trim(),
      'description': d.description.trim(),
      if (d.priority != ComplaintPriority.unknown) 'priority': d.priority.wire,
      ...optional,
    };
  }
}
