import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/formatting.dart';
import '../../../../core/widgets/adaptive.dart';
import '../../../../core/widgets/app/app_page.dart';
import '../../../../core/widgets/app/async_slivers.dart';
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
    Future<void> refresh() => ref.refresh(accountJobsProvider(clientId).future);

    return AppPage(
      title: l10n.moduleJobs,
      onRefresh: refresh,
      slivers: [
        AsyncSlivers(
          value: jobs,
          onRetry: refresh,
          builder: (list) {
            if (list.isEmpty) {
              return MessageSliver(
                icon: useCupertino(context)
                    ? CupertinoIcons.calendar
                    : Icons.event_available_outlined,
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
                for (final MapEntry(key: day, value: dayJobs) in days.entries)
                  SliverMainAxisGroup(
                    slivers: [
                      SliverToBoxAdapter(
                        child: _DayHeader(label: context.formatDayLong(day)),
                      ),
                      SliverList.separated(
                        itemCount: dayJobs.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, i) => JobRow(
                          job: dayJobs[i],
                          onTap: () => context.push(
                            '${GoRouterState.of(context).matchedLocation}/${dayJobs[i].id}',
                          ),
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

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
        child: Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
