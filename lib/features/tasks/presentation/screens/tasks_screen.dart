import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/search/text_search.dart';
import '../../../../core/widgets/priority_label.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../access/domain/entities/account_access.dart';
import '../../../access/presentation/controllers/account_access_provider.dart';
import '../../domain/entities/task.dart';
import '../controllers/tasks_providers.dart';
import '../widgets/task_labels.dart';

/// One client account's tasks: a toggle between the open ones (soonest due
/// first, undated last, as the server orders them) and the done ones, with
/// a search. New ones come from the dock's "+" (`tasks.edit`).
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

  final _search = TextEditingController();

  /// The API can't search tasks, but the whole list is already here.
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

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
        PageBox(
          top: 4,
          child: SearchField(
            controller: _search,
            hint: l10n.searchTasksHint,
            onChanged: (text) => setState(() => _query = text),
          ),
        ),
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
            final found = list
                .where((t) => matchesTask(l10n, t, _query))
                .toList();
            final open = openTasks(found);
            final shown = _done ? closedTasks(found) : open;
            return SliverMainAxisGroup(
              slivers: [
                PageBox(
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
                if (shown.isEmpty && _query.trim().isNotEmpty)
                  MessageSliver(
                    icon: Icons.search_off_rounded,
                    title: l10n.noMatchesFound,
                    hint: l10n.noMatchesHint,
                  )
                else if (shown.isEmpty)
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

/// Whether [query] appears in [t]'s title, description, who has it, its
/// status or its priority.
bool matchesTask(AppLocalizations l10n, Task t, String query) =>
    matchesSearch(query, [
      t.title,
      t.description,
      t.assignedToName,
      l10n.taskStatus(t.status),
      l10n.priorityName(t.priority),
    ]);
