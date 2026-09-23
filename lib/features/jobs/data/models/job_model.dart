import '../../domain/entities/job.dart';

abstract final class JobModel {
  static Job fromJson(Map<String, dynamic> json, {required String clientId}) {
    final location = json['location'] as Map?;
    final checklist = json['checklistItems'] as List? ?? const [];
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
      scheduledStart: DateTime.parse(json['scheduledStart'] as String)
          .toLocal(),
      scheduledEnd: switch (json['scheduledEnd']) {
        final String s => DateTime.parse(s).toLocal(),
        _ => null,
      },
      location: location == null
          ? null
          : JobLocation(
              name: location['name'] as String? ?? '',
              address: location['address'] as String?,
              city: location['city'] as String?,
            ),
      assignees: [
        for (final a in json['assignments'] as List? ?? const [])
          if ((a as Map)['user'] case final Map user)
            JobAssignee(
              userId: user['id'] as String? ?? a['userId'] as String? ?? '',
              name: user['name'] as String? ?? '',
            ),
      ],
      instructions: json['instructions'] as String?,
      checklistTotal: checklist.length,
      checklistDone: checklist
          .where((item) => (item as Map)['isCompleted'] == true)
          .length,
    );
  }
}
