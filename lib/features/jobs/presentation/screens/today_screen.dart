import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/formatting.dart';
import '../../../../core/widgets/adaptive.dart';
import '../../../../core/widgets/app/app_page.dart';
import '../../../../core/widgets/app/async_slivers.dart';
import '../../../../core/widgets/threshold/threshold_notice.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../clients/presentation/controllers/clients_providers.dart';
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
    final theme = Theme.of(context);
    final today = ref.watch(todayJobsProvider);
    final user = switch (ref.watch(authControllerProvider).value) {
      Authenticated(:final user) => user,
      _ => null,
    };
    final firstName = user?.name.split(' ').first ?? '';

    Future<void> refresh() async {
      ref.invalidate(myClientsProvider);
      await ref.read(todayJobsProvider.future);
    }

    return AppPage(
      title: l10n.todayTitle,
      topLevel: true,
      onRefresh: refresh,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Text(
              '${l10n.greeting(firstName)} · '
              '${context.formatDayLong(ref.watch(clockProvider)())}',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        AsyncSlivers(
          value: today,
          onRetry: refresh,
          builder: (day) {
            if (day.jobs.isEmpty && day.failedClients.isEmpty) {
              return MessageSliver(
                icon: useCupertino(context)
                    ? CupertinoIcons.sun_max
                    : Icons.wb_sunny_outlined,
                title: l10n.noJobsToday,
                hint: l10n.noJobsTodayHint,
              );
            }
            return SliverMainAxisGroup(
              slivers: [
                if (day.failedClients.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    sliver: SliverToBoxAdapter(
                      child: ThresholdNotice(
                        message: l10n.someAccountsFailed(
                          day.failedClients.length,
                        ),
                      ),
                    ),
                  ),
                SliverList.separated(
                  itemCount: day.jobs.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final item = day.jobs[i];
                    return JobRow(
                      job: item.job,
                      accountName: item.client.displayName,
                      onTap: () =>
                          context.push(jobPath(item.client.id, item.job.id)),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
