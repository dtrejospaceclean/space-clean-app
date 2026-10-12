import '../../../../core/usecase/usecase.dart';
import '../entities/task.dart';
import '../repositories/tasks_repository.dart';

class GetTasks implements UseCase<List<Task>, String> {
  const GetTasks(this._repository);

  final TasksRepository _repository;

  /// [clientId]'s tasks.
  @override
  Future<List<Task>> call(String clientId) => _repository.getTasks(clientId);
}

class TaskRef {
  const TaskRef({required this.clientId, required this.taskId});

  final String clientId;
  final String taskId;
}

class GetTask implements UseCase<Task, TaskRef> {
  const GetTask(this._repository);

  final TasksRepository _repository;

  @override
  Future<Task> call(TaskRef params) =>
      _repository.getTask(params.clientId, params.taskId);
}

class SaveTaskParams {
  const SaveTaskParams({
    required this.clientId,
    required this.draft,
    this.taskId,
  });

  final String clientId;

  /// The task edited; null to create.
  final String? taskId;
  final TaskDraft draft;
}

/// Creates a task or edits one; returns the saved task.
class SaveTask implements UseCase<Task, SaveTaskParams> {
  const SaveTask(this._repository);

  final TasksRepository _repository;

  @override
  Future<Task> call(SaveTaskParams p) => switch (p.taskId) {
    null => _repository.createTask(p.clientId, p.draft),
    final id => _repository.updateTask(p.clientId, id, p.draft),
  };
}

/// Starts a pending task: in progress.
class StartTask implements UseCase<Task, TaskRef> {
  const StartTask(this._repository);

  final TasksRepository _repository;

  @override
  Future<Task> call(TaskRef params) => _repository.setTaskStatus(
    params.clientId,
    params.taskId,
    TaskStatus.inProgress,
  );
}

/// Cancels an open task; it stays, read-only until reopened.
class CancelTask implements UseCase<Task, TaskRef> {
  const CancelTask(this._repository);

  final TasksRepository _repository;

  @override
  Future<Task> call(TaskRef params) => _repository.setTaskStatus(
    params.clientId,
    params.taskId,
    TaskStatus.cancelled,
  );
}

class CompleteTask implements UseCase<Task, TaskRef> {
  const CompleteTask(this._repository);

  final TasksRepository _repository;

  @override
  Future<Task> call(TaskRef params) =>
      _repository.completeTask(params.clientId, params.taskId);
}

class ReopenTask implements UseCase<Task, TaskRef> {
  const ReopenTask(this._repository);

  final TasksRepository _repository;

  @override
  Future<Task> call(TaskRef params) =>
      _repository.reopenTask(params.clientId, params.taskId);
}

class DeleteTask implements UseCase<void, TaskRef> {
  const DeleteTask(this._repository);

  final TasksRepository _repository;

  @override
  Future<void> call(TaskRef params) =>
      _repository.deleteTask(params.clientId, params.taskId);
}
