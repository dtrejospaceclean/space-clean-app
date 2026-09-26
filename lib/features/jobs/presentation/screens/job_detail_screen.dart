import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/job.dart';
import '../controllers/jobs_providers.dart';
import '../widgets/job_status_label.dart';

/// Read-only job details. Field actions (check-in, checklist, complete) come
/// with the crew job flow.
class JobDetailScreen extends ConsumerWidget {
  const JobDetailScreen({
    super.key,
    required this.clientId,
    required this.jobId,
  });

  final String clientId;
  final String jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final key = (clientId: clientId, jobId: jobId);
    final job = ref.watch(jobProvider(key));
    Future<void> refresh() => ref.refresh(jobProvider(key).future);

    return SpacePage(
      onRefresh: refresh,
      slivers: [
        AsyncSlivers(
          value: job,
          onRetry: refresh,
          builder: (job) => SliverMainAxisGroup(
            slivers: [
              PageBox(
                top: 16,
                child: HeroHeadline(
                  primary: job.title,
                  secondary: job.location?.name,
                ),
              ),
              PageBox(top: 20, child: _WhenCard(job: job)),
              if (job.checklistTotal > 0)
                PageBox(
                  top: SpaceSpace.gap,
                  child: _ChecklistCard(job: job),
                ),
              if (job.location case final location?)
                PageBox(
                  top: SpaceSpace.gap,
                  child: ListCard(
                    children: [
                      ListRow(
                        leading: const IconBadge(icon: Icons.place_outlined),
                        title: location.name,
                        subtitle: [
                          location.address,
                          location.city,
                        ].whereType<String>().join(', '),
                      ),
                    ],
                  ),
                ),
              PageBox(top: 12, child: SectionHeader(title: l10n.jobCrew)),
              PageBox(
                top: 0,
                child: ListCard(
                  children: [
                    if (job.assignees.isEmpty)
                      ListRow(title: l10n.noCrewAssigned)
                    else
                      for (final person in job.assignees)
                        ListRow(
                          leading: InitialsAvatar(name: person.name),
                          title: person.name,
                        ),
                  ],
                ),
              ),
              if (job.instructions case final text? when text.isNotEmpty) ...[
                PageBox(
                  top: 12,
                  child: SectionHeader(title: l10n.jobInstructions),
                ),
                PageBox(
                  top: 0,
                  child: SpaceCard(
                    child: Text(
                      text,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// The time big, the day under it, status on the right.
class _WhenCard extends StatelessWidget {
  const _WhenCard({required this.job});

  final Job job;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return SpaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l10n.jobWhen, style: theme.textTheme.bodyMedium),
              ),
              JobStatusLabel(status: job.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            context.formatTimeRange(job.scheduledStart, job.scheduledEnd),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            context.formatDayLong(job.scheduledStart),
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// Checklist progress with a navy banner, like a savings goal.
class _ChecklistCard extends StatelessWidget {
  const _ChecklistCard({required this.job});

  final Job job;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return SpaceCard(
      footer: AccentBanner(
        text: l10n.checklistProgress(job.checklistDone, job.checklistTotal),
        trailing: Icon(
          Icons.checklist_rounded,
          color: context.colors.onAccent,
          size: 20,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.jobChecklist, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 6),
          Text(
            '${job.checklistDone}/${job.checklistTotal}',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          SpaceProgressBar(
            value: job.checklistDone / job.checklistTotal,
            semanticsLabel: l10n.jobChecklist,
          ),
        ],
      ),
    );
  }
}
