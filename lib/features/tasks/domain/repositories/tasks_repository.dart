import '../entities/task.dart';

/// Every method throws a `Failure` on error.
abstract interface class TasksRepository {
  /// An account's tasks, soonest due first and undated ones last. Needs
  /// `tasks.view`.
  Future<List<Task>> getTasks(String clientId);

  /// The signed-in user's open tasks past their due date, across every
  /// account where they have `tasks.view`, each with its account's name.
  Future<List<Task>> getMyOverdueTasks();

  /// Needs `tasks.view`.
  Future<Task> getTask(String clientId, String taskId);

  /// A new pending task. Needs `tasks.edit`; the assignee must be active
  /// (`tasks.assignee_not_active`).
  Future<Task> createTask(String clientId, TaskDraft draft);

  /// Needs `tasks.edit`; refused once completed (`tasks.already_completed`).
  Future<Task> updateTask(String clientId, String taskId, TaskDraft draft);

  /// Moves it to [status] alone (a `PATCH` with only the status): starting
  /// it, or cancelling it. Needs `tasks.edit`.
  Future<Task> setTaskStatus(String clientId, String taskId, TaskStatus status);

  /// Needs `tasks.edit`; once only (`tasks.already_completed`).
  Future<Task> completeTask(String clientId, String taskId);

  /// Back to pending, from completed or cancelled (`tasks.already_open`
  /// otherwise). Needs `tasks.edit`.
  Future<Task> reopenTask(String clientId, String taskId);

  /// Needs `tasks.edit`. Gone for good.
  Future<void> deleteTask(String clientId, String taskId);
}
