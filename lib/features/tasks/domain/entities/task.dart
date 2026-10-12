import '../../../../core/domain/priority.dart';

export '../../../../core/domain/priority.dart';

/// Where a task stands. [pending] and [inProgress] still need someone;
/// [completed] and [cancelled] are done with, until reopened.
enum TaskStatus {
  pending('pending'),
  inProgress('in_progress'),
  completed('completed'),
  cancelled('cancelled'),

  /// A status this app doesn't know yet.
  unknown('');

  const TaskStatus(this.wire);

  /// The API's name for it.
  final String wire;

  static TaskStatus fromWire(String? value) => values.firstWhere(
    (s) => s != unknown && s.wire == value,
    orElse: () => unknown,
  );
}

/// A to-do at one account: what, for whom and by when. Unlike complaints,
/// tasks can be deleted.
class Task {
  const Task({
    required this.id,
    required this.clientId,
    required this.title,
    required this.priority,
    required this.status,
    this.description,
    this.assignedToId,
    this.assignedToName,
    this.dueDate,
    this.isOverdue = false,
    this.daysUntilDue,
  });

  final String id;
  final String clientId;
  final String title;
  final String? description;
  final Priority priority;
  final TaskStatus status;
  final String? assignedToId;
  final String? assignedToName;

  /// A calendar day (no time).
  final DateTime? dueDate;

  /// Open and past its due date. Worked out by the server, so finishing a
  /// late task clears it.
  final bool isOverdue;

  /// Days from today to [dueDate] (negative once past); null without one.
  final int? daysUntilDue;

  /// Still needs someone: pending or in progress.
  bool get isOpen =>
      status == TaskStatus.pending || status == TaskStatus.inProgress;

  /// Pending: can be started.
  bool get canStart => status == TaskStatus.pending;

  /// Completed or cancelled: read-only until reopened.
  bool get canReopen =>
      status == TaskStatus.completed || status == TaskStatus.cancelled;
}

/// What's typed in the form. An edit sends empty optional fields as null,
/// so they're cleared.
class TaskDraft {
  const TaskDraft({
    required this.title,
    required this.priority,
    this.description,
    this.assignedToId,
    this.dueDate,
  });

  final String title;
  final String? description;
  final Priority priority;
  final String? assignedToId;
  final DateTime? dueDate;
}

/// Open tasks, keeping the server's order (soonest due first, undated
/// last).
List<Task> openTasks(List<Task> all) => [
  for (final t in all)
    if (t.isOpen) t,
];

/// Completed and cancelled tasks, in the server's order.
List<Task> closedTasks(List<Task> all) => [
  for (final t in all)
    if (!t.isOpen) t,
];
