import '../../domain/entities/job.dart';

abstract final class JobModel {
  static DateTime? _local(Object? value) => switch (value) {
    final String s => DateTime.tryParse(s)?.toLocal(),
    _ => null,
  };

  static String? _name(Object? user) => switch (user) {
    {'name': final String name} => name,
    _ => null,
  };

  static Job fromJson(Map<String, dynamic> json, {required String clientId}) {
    final location = json['location'] as Map?;
    final scope = json['scopeOfWork'] as Map?;
    return Job(
      id: json['id'] as String,
      clientId: json['clientAccountId'] as String? ?? clientId,
      title: json['title'] as String? ?? '',
      status: switch (json['status']) {
        'scheduled' => JobStatus.scheduled,
        'in_progress' => JobStatus.inProgress,
        'completed' => JobStatus.completed,
        'cancelled' => JobStatus.cancelled,
        _ => JobStatus.unknown,
      },
      jobType: JobType.fromWire(json['jobType'] as String?),
      scheduledStart: DateTime.parse(json['scheduledStart'] as String)
          .toLocal(),
      scheduledEnd: _local(json['scheduledEnd']),
      locationId: json['locationId'] as String? ?? location?['id'] as String?,
      location: location == null
          ? null
          : JobLocation(
              name: location['name'] as String? ?? '',
              address: location['address'] as String?,
              city: location['city'] as String?,
            ),
      scopeId: json['scopeOfWorkId'] as String? ?? scope?['id'] as String?,
      scopeArea: scope?['areaName'] as String?,
      assignees: [
        for (final a in json['assignments'] as List? ?? const [])
          if ((a as Map)['user'] case final Map user)
            JobAssignee(
              userId: user['id'] as String? ?? a['userId'] as String? ?? '',
              name: user['name'] as String? ?? '',
              roleOnJob: a['roleOnJob'] as String?,
              checkInTime: _local(a['checkInTime']),
              checkOutTime: _local(a['checkOutTime']),
            ),
      ],
      instructions: json['instructions'] as String?,
      checklist: [
        for (final item in json['checklistItems'] as List? ?? const [])
          if (item case final Map item)
            ChecklistItem(
              id: item['id'] as String? ?? '',
              description: item['description'] as String? ?? '',
              isCompleted: item['isCompleted'] == true,
              completedByName: _name(item['completedBy']),
              completedAt: _local(item['completedAt']),
            ),
      ],
      actualStart: _local(json['actualStartTime']),
      actualEnd: _local(json['actualEndTime']),
      startedByName: _name(json['startedBy']),
      completedByName: _name(json['completedBy']),
      // A decimal column: the API may send it as a string.
      qualityScore: switch (json['qualityScore']) {
        final num n => n,
        final String s => num.tryParse(s),
        _ => null,
      },
      cleanerNotes: json['cleanerNotes'] as String?,
      clientSignoffName: json['clientSignoffName'] as String?,
    );
  }

  /// Body for a create or an update (`PATCH`). A create leaves empty fields
  /// out; an update sends them as null to clear them. Times go as UTC.
  static Map<String, dynamic> draftToJson(JobDraft d, {required bool create}) {
    String? text(String? v) => v == null || v.trim().isEmpty ? null : v.trim();
    final optional = <String, dynamic>{
      'scheduledEnd': d.scheduledEnd?.toUtc().toIso8601String(),
      'scopeOfWorkId': text(d.scopeId),
      'instructions': text(d.instructions),
    };
    if (create) optional.removeWhere((_, v) => v == null);
    return {
      'title': d.title.trim(),
      'locationId': d.locationId,
      'scheduledStart': d.scheduledStart.toUtc().toIso8601String(),
      ...optional,
    };
  }

  /// The role goes only when there is one, so the server keeps what it has.
  static List<Map<String, dynamic>> crewToJson(List<CrewMember> crew) => [
    for (final c in crew)
      {
        'userId': c.userId,
        if (c.roleOnJob case final role? when role.trim().isNotEmpty)
          'roleOnJob': role.trim(),
      },
  ];

  /// Empty fields are left out.
  static Map<String, dynamic> completionToJson(JobCompletion c) => {
    'qualityScore': ?c.qualityScore,
    if (c.cleanerNotes?.trim() case final notes? when notes.isNotEmpty)
      'cleanerNotes': notes,
    if (c.clientSignoffName?.trim() case final name? when name.isNotEmpty)
      'clientSignoffName': name,
  };

  /// Ordered as given.
  static List<Map<String, dynamic>> checklistToJson(List<String> items) => [
    for (final (i, description) in items.indexed)
      {'description': description, 'sortOrder': i},
  ];
}
