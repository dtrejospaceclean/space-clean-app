import 'package:flutter/material.dart';

import '../../../../core/design/design.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../core/widgets/priority_label.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/task.dart';

extension TaskNames on AppLocalizations {
  String taskStatus(TaskStatus status) => switch (status) {
    TaskStatus.pending => taskStatusPending,
    TaskStatus.inProgress => taskStatusInProgress,
    TaskStatus.completed => taskStatusCompleted,
    TaskStatus.cancelled => taskStatusCancelled,
    TaskStatus.unknown => taskStatusUnknown,
  };
}

/// The status as a tinted pill with an icon, so it never depends on color
/// alone: pending in navy, in progress in orange, completed in green,
/// cancelled muted.
class TaskStatusLabel extends StatelessWidget {
  const TaskStatusLabel({super.key, required this.status});

  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (IconData icon, Color color, Color background) = switch (status) {
      TaskStatus.pending => (
        Icons.radio_button_unchecked_rounded,
        c.accent,
        c.accentSoft,
      ),
      TaskStatus.inProgress => (
        Icons.timelapse_rounded,
        c.highlightInk,
        c.highlightSoft,
      ),
      TaskStatus.completed => (
        Icons.check_rounded,
        c.successInk,
        c.successSoft,
      ),
      TaskStatus.cancelled => (Icons.block_rounded, c.inkMuted, c.sunken),
      TaskStatus.unknown => (Icons.help_outline_rounded, c.inkMuted, c.sunken),
    };
    return StatusPill(
      label: AppLocalizations.of(context).taskStatus(status),
      icon: icon,
      color: color,
      background: background,
    );
  }
}

/// When an open task is due, as a pill: red once overdue, orange today or
/// tomorrow, muted later. Null for a task with no due date or no longer
/// open.
Widget? taskDueLabel(BuildContext context, Task t) {
  final days = t.daysUntilDue;
  if (!t.isOpen || days == null) return null;
  final l10n = AppLocalizations.of(context);
  final c = context.colors;
  final (
    String label,
    IconData icon,
    Color color,
    Color background,
  ) = switch (days) {
    _ when t.isOverdue || days < 0 => (
      l10n.taskOverdue(-days),
      Icons.error_outline_rounded,
      c.danger,
      c.dangerSoft,
    ),
    0 || 1 => (
      l10n.taskDueIn(days),
      Icons.schedule_rounded,
      c.highlightInk,
      c.highlightSoft,
    ),
    _ => (l10n.taskDueIn(days), Icons.event_outlined, c.inkMuted, c.sunken),
  };
  return StatusPill(
    label: label,
    icon: icon,
    color: color,
    background: background,
  );
}

/// A task as a list row: its title, who has it (or, across accounts, which
/// account) and the due day, then pills
/// for status, priority and how soon it's due. Done ones are muted and keep
/// only their status.
class TaskRow extends StatelessWidget {
  const TaskRow({super.key, required this.task, this.onTap});

  final Task task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = task;
    final due = taskDueLabel(context, t);
    return ListRow(
      leading: const IconBadge(icon: Icons.task_alt_rounded),
      title: t.title,
      subtitle: [
        // On the user's own list, which account; else who has it.
        t.accountName ?? t.assignedToName ?? l10n.unassigned,
        if (t.dueDate case final day?) context.formatDate(day),
      ].join(' · '),
      muted: !t.isOpen,
      tag: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          // A pending task needs no status pill; its due date says more.
          if (t.status != TaskStatus.pending) TaskStatusLabel(status: t.status),
          if (t.isOpen) PriorityLabel(priority: t.priority),
          ?due,
        ],
      ),
      onTap: onTap,
    );
  }
}
