import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/job.dart';
import '../controllers/jobs_providers.dart';
import '../widgets/job_row.dart';

/// One account's jobs for the next 7 days, grouped by day.
class AccountJobsScreen extends ConsumerWidget {
  const AccountJobsScreen({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final jobs = ref.watch(accountJobsProvider(clientId));
    final here = GoRouterState.of(context).matchedLocation;
    Future<void> refresh() => ref.refresh(accountJobsProvider(clientId).future);

    return SpacePage(
      title: l10n.moduleJobs,
      onRefresh: refresh,
      slivers: [
        PageBox(
          top: 0,
          child: Text(
            l10n.jobsNextDays,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        AsyncSlivers(
          value: jobs,
          onRetry: refresh,
          builder: (list) {
            if (list.isEmpty) {
              return MessageSliver(
                icon: Icons.event_available_outlined,
                title: l10n.noJobsAhead,
              );
            }
            final days = <DateTime, List<Job>>{};
            for (final job in list) {
              final s = job.scheduledStart;
              days
                  .putIfAbsent(DateTime(s.year, s.month, s.day), () => [])
                  .add(job);
            }
            return SliverMainAxisGroup(
              slivers: [
                for (final MapEntry(key: day, value: dayJobs)
                    in days.entries) ...[
                  PageBox(
                    top: 12,
                    child: SectionHeader(title: context.formatDayLong(day)),
                  ),
                  PageSliver(
                    top: 0,
                    sliver: SliverList.separated(
                      itemCount: dayJobs.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: SpaceSpace.gap),
                      itemBuilder: (context, i) => JobCard(
                        job: dayJobs[i],
                        onTap: () => context.push('$here/${dayJobs[i].id}'),
                      ),
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
