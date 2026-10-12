import 'package:flutter/material.dart';

import '../../../../core/design/design.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/complaint.dart';

extension ComplaintNames on AppLocalizations {
  String complaintStatus(ComplaintStatus status) => switch (status) {
    ComplaintStatus.open => complaintStatusOpen,
    ComplaintStatus.inProgress => complaintStatusInProgress,
    ComplaintStatus.resolved => complaintStatusResolved,
    ComplaintStatus.unknown => complaintStatusUnknown,
  };

  String complaintPriority(ComplaintPriority priority) => switch (priority) {
    ComplaintPriority.high => priorityHigh,
    ComplaintPriority.medium => priorityMedium,
    ComplaintPriority.low => priorityLow,
    ComplaintPriority.unknown => priorityUnknown,
  };
}

/// The status as a tinted pill with an icon, so it never depends on color
/// alone: open in navy, in progress in orange, resolved in green.
class ComplaintStatusLabel extends StatelessWidget {
  const ComplaintStatusLabel({super.key, required this.status});

  final ComplaintStatus status;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (IconData icon, Color color, Color background) = switch (status) {
      ComplaintStatus.open => (
        Icons.radio_button_unchecked_rounded,
        c.accent,
        c.accentSoft,
      ),
      ComplaintStatus.inProgress => (
        Icons.timelapse_rounded,
        c.highlightInk,
        c.highlightSoft,
      ),
      ComplaintStatus.resolved => (
        Icons.check_rounded,
        c.successInk,
        c.successSoft,
      ),
      ComplaintStatus.unknown => (
        Icons.help_outline_rounded,
        c.inkMuted,
        c.sunken,
      ),
    };
    return StatusPill(
      label: AppLocalizations.of(context).complaintStatus(status),
      icon: icon,
      color: color,
      background: background,
    );
  }
}

/// The priority as a pill: high in red with an up arrow, the rest muted
/// with their own arrows, so it reads without color.
class PriorityLabel extends StatelessWidget {
  const PriorityLabel({super.key, required this.priority});

  final ComplaintPriority priority;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (IconData icon, Color color, Color background) = switch (priority) {
      ComplaintPriority.high => (
        Icons.keyboard_double_arrow_up_rounded,
        c.danger,
        c.dangerSoft,
      ),
      ComplaintPriority.medium => (
        Icons.drag_handle_rounded,
        c.inkSoft,
        c.sunken,
      ),
      ComplaintPriority.low => (
        Icons.keyboard_arrow_down_rounded,
        c.inkMuted,
        c.sunken,
      ),
      ComplaintPriority.unknown => (
        Icons.help_outline_rounded,
        c.inkMuted,
        c.sunken,
      ),
    };
    return StatusPill(
      label: AppLocalizations.of(context).complaintPriority(priority),
      icon: icon,
      color: color,
      background: background,
    );
  }
}

/// "Floor 3 · Restrooms · Oct 9, 2026": where, then when it was reported.
String complaintWhereWhen(BuildContext context, Complaint c) => [
  ?c.locationName,
  if (c.area case final area? when area.trim().isNotEmpty) area.trim(),
  context.formatDate(c.reportedDate),
].join(' · ');

/// A complaint as a list row: its title, where and when, then its status
/// and priority as pills. Resolved ones are muted.
class ComplaintRow extends StatelessWidget {
  const ComplaintRow({super.key, required this.complaint, this.onTap});

  final Complaint complaint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = complaint;
    return ListRow(
      leading: const IconBadge(icon: Icons.report_outlined),
      title: c.title,
      subtitle: complaintWhereWhen(context, c),
      muted: c.isResolved,
      tag: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          ComplaintStatusLabel(status: c.status),
          // Resolved, the priority no longer matters.
          if (!c.isResolved) PriorityLabel(priority: c.priority),
        ],
      ),
      onTap: onTap,
    );
  }
}
