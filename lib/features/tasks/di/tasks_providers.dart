import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/network_providers.dart';
import '../data/datasources/tasks_remote_data_source.dart';
import '../data/repositories/tasks_repository_impl.dart';
import '../domain/repositories/tasks_repository.dart';
import '../domain/usecases/task_usecases.dart';

final tasksRepositoryProvider = Provider<TasksRepository>(
  (ref) =>
      TasksRepositoryImpl(TasksRemoteDataSource(ref.watch(apiClientProvider))),
);

final getTasksProvider = Provider(
  (ref) => GetTasks(ref.watch(tasksRepositoryProvider)),
);
final getTaskProvider = Provider(
  (ref) => GetTask(ref.watch(tasksRepositoryProvider)),
);
final saveTaskProvider = Provider(
  (ref) => SaveTask(ref.watch(tasksRepositoryProvider)),
);
final startTaskProvider = Provider(
  (ref) => StartTask(ref.watch(tasksRepositoryProvider)),
);
final cancelTaskProvider = Provider(
  (ref) => CancelTask(ref.watch(tasksRepositoryProvider)),
);
final completeTaskProvider = Provider(
  (ref) => CompleteTask(ref.watch(tasksRepositoryProvider)),
);
final reopenTaskProvider = Provider(
  (ref) => ReopenTask(ref.watch(tasksRepositoryProvider)),
);
final deleteTaskProvider = Provider(
  (ref) => DeleteTask(ref.watch(tasksRepositoryProvider)),
);
