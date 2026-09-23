import 'package:flutter/material.dart';

import '../../../../core/design/design.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/job.dart';

/// Status as a tinted pill with an icon, so it never depends on color alone.
class JobStatusLabel extends StatelessWidget {
  const JobStatusLabel({super.key, required this.status});

  final JobStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (
      IconData icon,
      Color color,
      Color background,
      String label,
    ) = switch (status) {
      JobStatus.scheduled => (
        Icons.schedule_rounded,
        SpaceColors.accent,
        SpaceColors.accentSoft,
        l10n.jobStatusScheduled,
      ),
      JobStatus.inProgress => (
        Icons.play_arrow_rounded,
        SpaceColors.highlightInk,
        SpaceColors.highlightSoft,
        l10n.jobStatusInProgress,
      ),
      JobStatus.completed => (
        Icons.check_rounded,
        SpaceColors.successInk,
        SpaceColors.successSoft,
        l10n.jobStatusCompleted,
      ),
      JobStatus.cancelled => (
        Icons.close_rounded,
        SpaceColors.inkMuted,
        SpaceColors.sunken,
        l10n.jobStatusCancelled,
      ),
      JobStatus.unknown => (
        Icons.help_outline_rounded,
        SpaceColors.inkMuted,
        SpaceColors.sunken,
        l10n.jobStatusUnknown,
      ),
    };

    return StatusPill(
      label: label,
      icon: icon,
      color: color,
      background: background,
    );
  }
}
