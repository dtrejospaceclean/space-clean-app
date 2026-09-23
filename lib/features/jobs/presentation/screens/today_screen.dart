import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../clients/presentation/controllers/clients_providers.dart';
import '../../domain/entities/job.dart';
import '../controllers/jobs_providers.dart';
import '../widgets/job_row.dart';

/// Home for every role: today's jobs across all the user's accounts.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  static const path = '/today';

  static String jobPath(String clientId, String jobId) =>
      '$path/job/$clientId/$jobId';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final today = ref.watch(todayJobsProvider);
    final user = switch (ref.watch(authControllerProvider).value) {
      Authenticated(:final user) => user,
      _ => null,
    };
    final firstName = user?.name.split(' ').first ?? '';
    final now = ref.watch(clockProvider)();

    Future<void> refresh() async {
      ref.invalidate(myClientsProvider);
      await ref.read(todayJobsProvider.future);
    }

    return SpacePage(
      title: l10n.todayTitle,
      onRefresh: refresh,
      actions: [
        if (user != null)
          Tooltip(
            message: user.name,
            child: InitialsAvatar(
              name: user.name,
              background: SpaceColors.surface,
            ),
          ),
      ],
      slivers: [
        PageBox(
          top: 4,
          child: Text(
            context.formatDayLong(now),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        AsyncSlivers(
          value: today,
          onRetry: refresh,
          builder: (day) {
            final jobs = day.jobs;
            int count(JobStatus status) =>
                jobs.where((j) => j.job.status == status).length;

            return SliverMainAxisGroup(
              slivers: [
                PageBox(
                  top: 20,
                  child: HeroHeadline(
                    primary: l10n.greeting(firstName),
                    secondary: l10n.jobsTodayCount(jobs.length),
                  ),
                ),
                if (jobs.isNotEmpty)
                  PageBox(
                    top: 20,
                    // One compact row so the jobs stay near the top.
                    child: CardRow(
                      children: [
                        StatCard(
                          compact: true,
                          label: l10n.statToDo,
                          value: '${count(JobStatus.scheduled)}',
                        ),
                        StatCard(
                          compact: true,
                          label: l10n.jobStatusInProgress,
                          value: '${count(JobStatus.inProgress)}',
                        ),
                        StatCard(
                          compact: true,
                          label: l10n.jobStatusCompleted,
                          value: '${count(JobStatus.completed)}',
                        ),
                      ],
                    ),
                  ),
                if (day.failedClients.isNotEmpty)
                  PageBox(
                    child: Notice(
                      message: l10n.someAccountsFailed(
                        day.failedClients.length,
                      ),
                    ),
                  ),
                if (jobs.isEmpty && day.failedClients.isEmpty)
                  MessageSliver(
                    icon: Icons.wb_sunny_outlined,
                    title: l10n.noJobsToday,
                    hint: l10n.noJobsTodayHint,
                  )
                else ...[
                  PageBox(top: 12, child: SectionHeader(title: l10n.yourJobs)),
                  PageSliver(
                    top: 0,
                    sliver: SliverList.separated(
                      itemCount: jobs.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: SpaceSpace.gap),
                      itemBuilder: (context, i) {
                        final item = jobs[i];
                        return JobCard(
                          job: item.job,
                          accountName: item.client.displayName,
                          onTap: () => context.push(
                            jobPath(item.client.id, item.job.id),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
