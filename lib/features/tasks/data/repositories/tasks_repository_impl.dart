import '../../../../core/network/api_exception.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/tasks_repository.dart';
import '../datasources/tasks_remote_data_source.dart';

class TasksRepositoryImpl implements TasksRepository {
  const TasksRepositoryImpl(this._remote);

  final TasksRemoteDataSource _remote;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException catch (e) {
      throw e.toFailure();
    }
  }

  @override
  Future<List<Task>> getTasks(String clientId) =>
      _guard(() => _remote.getTasks(clientId));

  @override
  Future<List<Task>> getMyOverdueTasks() =>
      _guard(() => _remote.getMyOverdueTasks());

  @override
  Future<Task> getTask(String clientId, String taskId) =>
      _guard(() => _remote.getTask(clientId, taskId));

  @override
  Future<Task> createTask(String clientId, TaskDraft draft) =>
      _guard(() => _remote.createTask(clientId, draft));

  @override
  Future<Task> updateTask(String clientId, String taskId, TaskDraft draft) =>
      _guard(() => _remote.updateTask(clientId, taskId, draft));

  @override
  Future<Task> setTaskStatus(
    String clientId,
    String taskId,
    TaskStatus status,
  ) => _guard(() => _remote.setTaskStatus(clientId, taskId, status));

  @override
  Future<Task> completeTask(String clientId, String taskId) =>
      _guard(() => _remote.completeTask(clientId, taskId));

  @override
  Future<Task> reopenTask(String clientId, String taskId) =>
      _guard(() => _remote.reopenTask(clientId, taskId));

  @override
  Future<void> deleteTask(String clientId, String taskId) =>
      _guard(() => _remote.deleteTask(clientId, taskId));
}
