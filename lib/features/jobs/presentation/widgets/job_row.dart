import 'package:flutter/material.dart';

import '../../../../core/l10n/formatting.dart';
import '../../domain/entities/job.dart';
import 'job_status_label.dart';

/// One job in a list: the time big on the left (what crew scan for), then
/// title, place and status. The whole row is one large tap target.
class JobRow extends StatelessWidget {
  const JobRow({
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
    final muted = theme.colorScheme.onSurfaceVariant;
    final dimmed =
        job.status == JobStatus.cancelled || job.status == JobStatus.completed;
    final place = [
      ?accountName,
      if (job.location?.name case final name? when name.isNotEmpty) name,
    ].join(' · ');

    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 84,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.formatTime(job.scheduledStart),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: dimmed ? muted : null,
                      ),
                    ),
                    if (job.scheduledEnd case final end?)
                      Text(
                        context.formatTime(end),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: muted,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: dimmed ? muted : null,
                      ),
                    ),
                    if (place.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        place,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: muted,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    JobStatusLabel(status: job.status),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
