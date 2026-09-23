import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/brand_colors.dart';
import '../../../../core/widgets/adaptive.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/job.dart';

/// Status as icon plus word, so it never depends on color alone.
class JobStatusLabel extends StatelessWidget {
  const JobStatusLabel({super.key, required this.status});

  final JobStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cupertino = useCupertino(context);
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final (IconData icon, Color color, String label) = switch (status) {
      JobStatus.scheduled => (
        cupertino ? CupertinoIcons.clock : Icons.schedule,
        BrandColors.navy,
        l10n.jobStatusScheduled,
      ),
      JobStatus.inProgress => (
        cupertino ? CupertinoIcons.play_circle_fill : Icons.play_circle,
        BrandColors.orangeDeep,
        l10n.jobStatusInProgress,
      ),
      JobStatus.completed => (
        cupertino ? CupertinoIcons.checkmark_circle_fill : Icons.check_circle,
        const Color(0xFF15803D),
        l10n.jobStatusCompleted,
      ),
      JobStatus.cancelled => (
        cupertino ? CupertinoIcons.xmark_circle : Icons.cancel_outlined,
        muted,
        l10n.jobStatusCancelled,
      ),
      JobStatus.unknown => (
        cupertino ? CupertinoIcons.question_circle : Icons.help_outline,
        muted,
        l10n.jobStatusUnknown,
      ),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
