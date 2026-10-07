import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../access/domain/entities/account_access.dart';
import '../../../access/presentation/controllers/account_access_provider.dart';
import '../../domain/entities/job.dart';
import '../../domain/usecases/job_usecases.dart';
import '../controllers/jobs_providers.dart';
import '../widgets/job_row.dart';

/// One account's jobs grouped by day: upcoming (from today on) or the past
/// 30 days, latest first. New ones come from the dock's "+" (`jobs.edit`)
/// or from a calendar event.
class AccountJobsScreen extends ConsumerStatefulWidget {
  const AccountJobsScreen({super.key, required this.clientId});

  /// Path segment under `/accounts/:clientId`.
  static const route = 'jobs';

  final String clientId;

  @override
  ConsumerState<AccountJobsScreen> createState() => _AccountJobsScreenState();
}

class _AccountJobsScreenState extends ConsumerState<AccountJobsScreen> {
  JobPeriod _period = JobPeriod.upcoming;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = JobQuery(
      clientId: widget.clientId,
      period: _period,
      today: ref.watch(clockProvider)(),
    );
    final jobs = ref.watch(accountJobsProvider(query));
    final canEdit =
        ref
            .watch(accountAccessProvider(widget.clientId))
            .value
            ?.can(Permissions.jobsEdit) ??
        false;
    final here = GoRouterState.of(context).matchedLocation;
    Future<void> refresh() => ref.refresh(accountJobsProvider(query).future);

    return SpacePage(
      title: l10n.moduleJobs,
      onRefresh: refresh,
      slivers: [
        PageBox(
          top: 4,
          child: PillToggle<JobPeriod>(
            semanticLabel: l10n.jobsPeriodLabel,
            options: {
              JobPeriod.upcoming: l10n.jobsUpcoming,
              JobPeriod.past: l10n.jobsPast,
            },
            selected: _period,
            onChanged: (v) => setState(() => _period = v),
          ),
        ),
        AsyncSlivers(
          value: jobs,
          onRetry: refresh,
          builder: (list) {
            if (list.isEmpty) {
              return switch (_period) {
                JobPeriod.upcoming => MessageSliver(
                  icon: Icons.event_available_outlined,
                  title: l10n.noJobsAhead,
                  hint: canEdit ? l10n.noJobsAheadHint : null,
                ),
                JobPeriod.past => MessageSliver(
                  icon: Icons.history_rounded,
                  title: l10n.noPastJobs,
                ),
              };
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
