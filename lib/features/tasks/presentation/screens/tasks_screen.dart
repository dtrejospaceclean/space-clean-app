import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../access/domain/entities/account_access.dart';
import '../../../access/presentation/controllers/account_access_provider.dart';
import '../../domain/entities/task.dart';
import '../controllers/tasks_providers.dart';
import '../widgets/task_labels.dart';

/// One client account's tasks: a toggle between the open ones (soonest due
/// first, undated last, as the server orders them) and the done ones. New
/// ones come from the dock's "+" (`tasks.edit`).
class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key, required this.clientId});

  /// Path segment under `/accounts/:clientId`.
  static const route = 'tasks';

  final String clientId;

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  /// The done ones instead of the open ones. The whole list is already
  /// here, so this splits it on the phone.
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final clientId = widget.clientId;
    final tasks = ref.watch(tasksProvider(clientId));
    final canEdit =
        ref
            .watch(accountAccessProvider(clientId))
            .value
            ?.can(Permissions.tasksEdit) ??
        false;
    final here = GoRouterState.of(context).matchedLocation;
    Future<void> refresh() => ref.refresh(tasksProvider(clientId).future);

    return SpacePage(
      title: l10n.moduleTasks,
      onRefresh: refresh,
      slivers: [
        AsyncSlivers(
          value: tasks,
          onRetry: refresh,
          builder: (list) {
            if (list.isEmpty) {
              return MessageSliver(
                icon: Icons.task_alt_rounded,
                title: l10n.noTasksYet,
                hint: canEdit ? l10n.noTasksYetHint : null,
              );
            }
            final open = openTasks(list);
            final shown = _done ? closedTasks(list) : open;
            return SliverMainAxisGroup(
              slivers: [
                PageBox(
                  top: 4,
                  child: PillToggle<bool>(
                    semanticLabel: l10n.contractsFilterLabel,
                    options: {
                      false: l10n.tasksFilterOpen(open.length),
                      true: l10n.tasksFilterDone,
                    },
                    selected: _done,
                    onChanged: (v) => setState(() => _done = v),
                  ),
                ),
                if (shown.isEmpty)
                  _done
                      ? MessageSliver(
                          icon: Icons.task_alt_rounded,
                          title: l10n.noDoneTasks,
                        )
                      : MessageSliver(
                          icon: Icons.task_alt_rounded,
                          title: l10n.noOpenTasks,
                          hint: l10n.noOpenTasksHint,
                        )
                else
                  PageBox(
                    child: ListCard(
                      children: [
                        for (final t in shown)
                          TaskRow(
                            task: t,
                            onTap: () => context.push('$here/${t.id}'),
                          ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
