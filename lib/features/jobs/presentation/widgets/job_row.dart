import 'package:flutter/material.dart';

import '../../../../core/design/design.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/job.dart';
import 'job_status_label.dart';

/// One job as a white card: the time big (what crew scan for), then title,
/// account and place, status, and checklist progress when there is one.
class JobCard extends StatelessWidget {
  const JobCard({
    super.key,
    required this.job,
    this.accountName,
    required this.onTap,
  });

  final Job job;

  /// Shown when the list mixes accounts.
  final String? accountName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final done =
        job.status == JobStatus.cancelled || job.status == JobStatus.completed;
    final place = [
      ?accountName,
      if (job.location?.name case final name? when name.isNotEmpty) name,
    ].join(' · ');

    return Semantics(
      button: true,
      child: SpaceCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.formatTimeRange(job.scheduledStart, job.scheduledEnd),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: 22,
                color: done ? SpaceColors.inkSoft : SpaceColors.ink,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              job.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: done ? SpaceColors.inkMuted : SpaceColors.ink,
              ),
            ),
            if (place.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(place, style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: JobStatusLabel(status: job.status),
            ),
            if (job.checklistTotal > 0 &&
                job.status != JobStatus.cancelled) ...[
              const SizedBox(height: 16),
              SpaceProgressBar(
                value: job.checklistDone / job.checklistTotal,
                height: 8,
                semanticsLabel: l10n.jobChecklist,
              ),
              const SizedBox(height: 6),
              Text(
                l10n.checklistProgress(job.checklistDone, job.checklistTotal),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: SpaceColors.inkMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
