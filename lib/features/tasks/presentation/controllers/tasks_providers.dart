import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/tasks_providers.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/task_usecases.dart';

/// An account's tasks, soonest due first.
final tasksProvider = FutureProvider.autoDispose.family<List<Task>, String>(
  (ref, clientId) => ref.watch(getTasksProvider)(clientId),
);

/// One task: `(clientId, taskId)`.
final taskProvider = FutureProvider.autoDispose.family<Task, (String, String)>(
  (ref, key) =>
      ref.watch(getTaskProvider)(TaskRef(clientId: key.$1, taskId: key.$2)),
);

/// Drops an account's cached tasks after any write.
void invalidateTasks(WidgetRef ref, String clientId) => ref
  ..invalidate(tasksProvider(clientId))
  ..invalidate(taskProvider);
