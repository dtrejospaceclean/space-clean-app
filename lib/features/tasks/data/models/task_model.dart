import '../../domain/entities/task.dart';

abstract final class TaskModel {
  /// A date-only column: keep the calendar day, ignore the UTC time.
  static DateTime? _day(Object? value) => switch (value) {
    final String s when s.length >= 10 => DateTime.tryParse(s.substring(0, 10)),
    _ => null,
  };

  static Task fromJson(Map<String, dynamic> json) => Task(
    id: json['id'] as String,
    clientId: json['clientAccountId'] as String? ?? '',
    title: json['title'] as String? ?? '',
    description: json['description'] as String?,
    priority: Priority.fromWire(json['priority'] as String?),
    status: TaskStatus.fromWire(json['status'] as String?),
    assignedToId: json['assignedToUserId'] as String?,
    assignedToName: switch (json['assignedTo']) {
      {'name': final String name} => name,
      _ => null,
    },
    dueDate: _day(json['dueDate']),
    isOverdue: json['isOverdue'] as bool? ?? false,
    daysUntilDue: (json['daysUntilDue'] as num?)?.toInt(),
    accountName: switch (json['clientAccount']) {
      {'dba': final String dba} when dba.trim().isNotEmpty => dba,
      {'legalName': final String legalName} => legalName,
      _ => null,
    },
  );
}

abstract final class TaskDraftModel {
  static String ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Body for a create or an update (`PATCH`). Text is trimmed. An update
  /// sends empty optional fields as null so they're cleared; a create
  /// leaves them out.
  static Map<String, dynamic> toJson(TaskDraft d, {required bool create}) {
    String? text(String? v) => v == null || v.trim().isEmpty ? null : v.trim();
    final optional = <String, dynamic>{
      'description': text(d.description),
      'assignedToUserId': d.assignedToId,
      'dueDate': switch (d.dueDate) {
        final DateTime day => ymd(day),
        null => null,
      },
    };
    if (create) optional.removeWhere((_, v) => v == null);
    return {
      'title': d.title.trim(),
      if (d.priority != Priority.unknown) 'priority': d.priority.wire,
      ...optional,
    };
  }
}
