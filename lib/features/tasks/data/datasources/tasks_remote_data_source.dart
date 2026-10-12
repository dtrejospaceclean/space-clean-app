import '../../../../core/network/api_client.dart';
import '../../../../core/network/paginated.dart';
import '../../domain/entities/task.dart';
import '../models/task_model.dart';

/// Talks to `/clients/:clientId/tasks`. Throws `ApiException`.
class TasksRemoteDataSource {
  const TasksRemoteDataSource(this._api);

  final ApiClient _api;

  static String _path(String clientId) => '/clients/$clientId/tasks';

  static Task _one(Object? data) =>
      TaskModel.fromJson((data! as Map).cast<String, dynamic>());

  Future<List<Task>> getTasks(String clientId) async => (await fetchAllPages(
    _api,
    _path(clientId),
  )).map(TaskModel.fromJson).toList();

  /// `GET /me/tasks?overdue=true`: each row names its account.
  Future<List<Task>> getMyOverdueTasks() async => (await fetchAllPages(
    _api,
    '/me/tasks',
    query: {'overdue': 'true'},
  )).map(TaskModel.fromJson).toList();

  Future<Task> getTask(String clientId, String taskId) async =>
      _one(await _api.get('${_path(clientId)}/$taskId'));

  Future<Task> createTask(String clientId, TaskDraft draft) async => _one(
    await _api.post(
      _path(clientId),
      body: TaskDraftModel.toJson(draft, create: true),
    ),
  );

  Future<Task> updateTask(
    String clientId,
    String taskId,
    TaskDraft draft,
  ) async => _one(
    await _api.patch(
      '${_path(clientId)}/$taskId',
      body: TaskDraftModel.toJson(draft, create: false),
    ),
  );

  /// Sends only the status, so nothing else changes.
  Future<Task> setTaskStatus(
    String clientId,
    String taskId,
    TaskStatus status,
  ) async => _one(
    await _api.patch(
      '${_path(clientId)}/$taskId',
      body: {'status': status.wire},
    ),
  );

  /// Takes no body.
  Future<Task> completeTask(String clientId, String taskId) async =>
      _one(await _api.post('${_path(clientId)}/$taskId/complete'));

  /// Takes no body.
  Future<Task> reopenTask(String clientId, String taskId) async =>
      _one(await _api.post('${_path(clientId)}/$taskId/reopen'));

  /// Returns no data.
  Future<void> deleteTask(String clientId, String taskId) =>
      _api.delete('${_path(clientId)}/$taskId');
}
