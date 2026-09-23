import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/formatting.dart';
import '../../../../core/widgets/adaptive.dart';
import '../../../../core/widgets/app/app_list.dart';
import '../../../../core/widgets/app/app_page.dart';
import '../../../../core/widgets/app/async_slivers.dart';
import '../../../../l10n/app_localizations.dart';
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
    final cupertino = useCupertino(context);
    Future<void> refresh() => ref.refresh(jobProvider(key).future);

    return AppPage(
      grouped: true,
      title: job.value?.title ?? l10n.moduleJobs,
      onRefresh: refresh,
      slivers: [
        AsyncSlivers(
          value: job,
          onRetry: refresh,
          builder: (job) {
            final location = job.location;
            return SliverList.list(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: JobStatusLabel(status: job.status),
                ),
                AppListSection(
                  title: l10n.jobWhen,
                  children: [
                    AppListRow(
                      leading: cupertino
                          ? CupertinoIcons.calendar
                          : Icons.event,
                      title: context.formatDayLong(job.scheduledStart),
                      subtitle: context.formatTimeRange(
                        job.scheduledStart,
                        job.scheduledEnd,
                      ),
                    ),
                  ],
                ),
                if (location != null)
                  AppListSection(
                    title: l10n.jobWhere,
                    children: [
                      AppListRow(
                        leading: cupertino
                            ? CupertinoIcons.location
                            : Icons.place_outlined,
                        title: location.name,
                        subtitle: [
                          location.address,
                          location.city,
                        ].whereType<String>().join(', '),
                      ),
                    ],
                  ),
                AppListSection(
                  title: l10n.jobCrew,
                  children: [
                    if (job.assignees.isEmpty)
                      AppListRow(title: l10n.noCrewAssigned)
                    else
                      for (final person in job.assignees)
                        AppListRow(
                          leading: cupertino
                              ? CupertinoIcons.person
                              : Icons.person_outline,
                          title: person.name,
                        ),
                  ],
                ),
                AppListSection(
                  title: l10n.jobChecklist,
                  children: [
                    AppListRow(
                      leading: cupertino
                          ? CupertinoIcons.checkmark_square
                          : Icons.checklist,
                      title: job.checklistTotal == 0
                          ? l10n.noChecklist
                          : l10n.checklistProgress(
                              job.checklistDone,
                              job.checklistTotal,
                            ),
                    ),
                  ],
                ),
                if (job.instructions case final text? when text.isNotEmpty)
                  AppListSection(
                    title: l10n.jobInstructions,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          text,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
