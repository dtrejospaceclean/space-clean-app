import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../core/widgets/adaptive.dart';
import '../../../../core/widgets/priority_label.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../access/domain/entities/account_access.dart';
import '../../../access/presentation/controllers/account_access_provider.dart';
import '../../../proposals/presentation/widgets/line_item_row.dart';
import '../../di/tasks_providers.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/task_usecases.dart';
import '../controllers/tasks_providers.dart';
import '../widgets/task_labels.dart';

/// One task: a head card (title, status, priority, how soon it's due, what
/// it is, Edit), then when it's due and who has it. With `tasks.edit` an
/// open task is completed, started or cancelled; a done one reopened; and
/// any one deleted.
class TaskScreen extends ConsumerStatefulWidget {
  const TaskScreen({
    super.key,
    required this.clientId,
    required this.taskId,
    this.leaveTo,
  });

  final String clientId;
  final String taskId;

  /// Where deleting it goes; null for the list it was opened from (its
  /// parent route).
  final String? leaveTo;

  @override
  ConsumerState<TaskScreen> createState() => _TaskScreenState();
}

/// What's in flight: nothing else on the page starts until it settles.
enum _Busy { complete, start, cancel, reopen, delete }

class _TaskScreenState extends ConsumerState<TaskScreen> {
  _Busy? _busy;

  TaskRef get _ref => TaskRef(clientId: widget.clientId, taskId: widget.taskId);

  Future<bool> _confirm({
    required String title,
    required String body,
    required String keep,
    required String action,
  }) async {
    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(title),
        content: Text(body),
        actions: [
          adaptiveAction(
            context,
            label: keep,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          adaptiveAction(
            context,
            label: action,
            destructive: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    return confirmed == true && mounted;
  }

  Future<void> _showFailure(Failure f) {
    final l10n = AppLocalizations.of(context);
    return showAdaptiveDialog<void>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        content: Text(l10n.failureMessage(f)),
        actions: [
          adaptiveAction(
            context,
            label: l10n.doneButton,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  /// Runs [action] as [kind], then reloads; failures show in a dialog.
  Future<void> _run(_Busy kind, Future<void> Function() action) async {
    setState(() => _busy = kind);
    try {
      await action();
      invalidateTasks(ref, widget.clientId);
    } on Failure catch (f) {
      if (mounted) await _showFailure(f);
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  Future<void> _cancel() async {
    final l10n = AppLocalizations.of(context);
    if (!await _confirm(
      title: l10n.cancelTaskConfirmTitle,
      body: l10n.cancelTaskConfirmBody,
      keep: l10n.keepTask,
      action: l10n.cancelTask,
    )) {
      return;
    }
    await _run(_Busy.cancel, () => ref.read(cancelTaskProvider)(_ref));
  }

  /// Asks first, then deletes the task and goes back to [list].
  Future<void> _delete(String list) async {
    final l10n = AppLocalizations.of(context);
    if (!await _confirm(
      title: l10n.deleteTaskConfirmTitle,
      body: l10n.deleteTaskConfirmBody,
      keep: l10n.keepTask,
      action: l10n.deleteButton,
    )) {
      return;
    }
    setState(() => _busy = _Busy.delete);
    try {
      await ref.read(deleteTaskProvider)(_ref);
      if (!mounted) return;
      // Leave before the list reloads, so this page doesn't flash "not
      // found" on its way out.
      context.go(list);
      invalidateTasks(ref, widget.clientId);
    } on Failure catch (f) {
      if (!mounted) return;
      setState(() => _busy = null);
      await _showFailure(f);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final key = (widget.clientId, widget.taskId);
    final task = ref.watch(taskProvider(key));
    final canEdit =
        ref
            .watch(accountAccessProvider(widget.clientId))
            .value
            ?.can(Permissions.tasksEdit) ??
        false;
    final here = GoRouterState.of(context).matchedLocation;
    final list = widget.leaveTo ?? here.substring(0, here.lastIndexOf('/'));
    final busy = _busy != null;
    Future<void> refresh() => ref.refresh(taskProvider(key).future);

    return PopScope(
      canPop: !busy,
      child: AbsorbPointer(
        absorbing: busy,
        child: SpacePage(
          title: l10n.taskTitle,
          onRefresh: busy ? null : refresh,
          slivers: [
            AsyncSlivers(
              value: task,
              onRetry: refresh,
              builder: (t) => SliverMainAxisGroup(
                slivers: [
                  PageBox(
                    top: 4,
                    child: _HeadCard(
                      task: t,
                      onEdit: canEdit && t.isOpen
                          ? () => context.push('$here/edit')
                          : null,
                    ),
                  ),
                  if (canEdit && !t.isOpen)
                    PageBox(
                      child: Notice(
                        message: l10n.closedTaskNotice,
                        tone: NoticeTone.info,
                      ),
                    ),
                  PageBox(top: 16, child: CapsHeader(l10n.sectionDetails)),
                  PageBox(
                    top: 0,
                    child: FactCard(
                      rows: [
                        [
                          (
                            l10n.taskDueDateLabel,
                            switch (t.dueDate) {
                              final day? => context.formatDate(day),
                              null => null,
                            },
                          ),
                          (l10n.assignedToLabel, t.assignedToName),
                        ],
                      ],
                    ),
                  ),
                  if (canEdit && t.isOpen) ...[
                    PageBox(
                      top: 24,
                      child: PrimaryButton(
                        label: l10n.completeTask,
                        icon: Icons.task_alt_rounded,
                        busy: _busy == _Busy.complete,
                        onPressed: busy
                            ? null
                            : () => _run(
                                _Busy.complete,
                                () => ref.read(completeTaskProvider)(_ref),
                              ),
                      ),
                    ),
                    if (t.canStart)
                      PageBox(
                        top: 12,
                        child: SecondaryButton(
                          label: l10n.startTask,
                          icon: Icons.play_arrow_rounded,
                          onPressed: busy
                              ? null
                              : () => _run(
                                  _Busy.start,
                                  () => ref.read(startTaskProvider)(_ref),
                                ),
                        ),
                      ),
                  ],
                  // Quiet actions at the foot: cancelling or reopening, and
                  // deleting.
                  if (canEdit)
                    PageBox(
                      top: 20,
                      child: Column(
                        children: [
                          if (t.isOpen)
                            LinkButton(
                              label: l10n.cancelTask,
                              icon: Icons.block_rounded,
                              destructive: true,
                              onPressed: busy ? null : _cancel,
                            ),
                          if (t.canReopen)
                            LinkButton(
                              label: l10n.reopenTask,
                              icon: Icons.replay_rounded,
                              onPressed: busy
                                  ? null
                                  : () => _run(
                                      _Busy.reopen,
                                      () => ref.read(reopenTaskProvider)(_ref),
                                    ),
                            ),
                          LinkButton(
                            label: l10n.deleteTask,
                            icon: Icons.delete_outline_rounded,
                            destructive: true,
                            onPressed: busy ? null : () => _delete(list),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The head of the page: the title with Edit at the corner, its status,
/// priority and how soon it's due, then what it is. At large text Edit
/// moves under the pills.
class _HeadCard extends StatelessWidget {
  const _HeadCard({required this.task, required this.onEdit});

  final Task task;

  /// Null hides Edit.
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = task;
    final large = isLargeText(context);
    final edit = switch (onEdit) {
      final onEdit? => PillButton(
        label: l10n.editButton,
        icon: Icons.edit_outlined,
        tooltip: l10n.editTask,
        onPressed: onEdit,
      ),
      null => null,
    };
    final description = t.description?.trim();

    return SpaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  t.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (edit != null && !large) ...[const SizedBox(width: 12), edit],
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              TaskStatusLabel(status: t.status),
              if (t.isOpen) PriorityLabel(priority: t.priority),
              ?taskDueLabel(context, t),
            ],
          ),
          if (edit != null && large) ...[
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerLeft, child: edit),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(),
          ),
          if (description != null && description.isNotEmpty)
            Text(description, style: theme.textTheme.bodyLarge)
          else
            Text(
              l10n.noDescription,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: context.colors.inkMuted,
              ),
            ),
        ],
      ),
    );
  }
}
