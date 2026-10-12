import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/presentation/controllers/tasks_providers.dart';
import '../../../tasks/presentation/widgets/task_labels.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../clients/presentation/controllers/clients_providers.dart';
import '../../../notifications/presentation/controllers/notifications_providers.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../domain/entities/job.dart';
import '../controllers/jobs_providers.dart';
import '../widgets/job_row.dart';

/// Home for every role. Everyone sees their own work today: the jobs
/// they're on the crew of (`GET /me/jobs`, one request) and their overdue
/// tasks (`GET /me/tasks`). Office staff (a global owner, account manager
/// or supervisor) also see the other jobs today in their accounts, merged
/// from one request per account ([todayJobsProvider]).
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  static const path = '/today';

  static String jobPath(String clientId, String jobId) =>
      '$path/job/$clientId/$jobId';

  static String taskPath(String clientId, String taskId) =>
      '$path/task/$clientId/$taskId';

  /// Global roles that oversee work beyond their own crews.
  static const _staffRoles = [
    GlobalRole.owner,
    GlobalRole.accountManager,
    GlobalRole.supervisor,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = switch (ref.watch(authControllerProvider).value) {
      Authenticated(:final user) => user,
      _ => null,
    };
    final isStaff = user?.hasAnyRole(_staffRoles) ?? false;
    final mine = ref.watch(myDayJobsProvider);
    final overdue = ref.watch(myOverdueTasksProvider).value ?? const <Task>[];
    // Crew see only their own jobs anyway: no need to ask every account.
    final everyone = isStaff ? ref.watch(todayJobsProvider) : null;
    final firstName = user?.name.split(' ').first ?? '';
    final now = ref.watch(clockProvider)();

    Future<void> refresh() async {
      ref
        ..invalidate(myClientsProvider)
        ..invalidate(unreadNotificationsProvider)
        ..invalidate(myOverdueTasksProvider)
        ..invalidate(todayJobsProvider)
        ..invalidate(myDayJobsProvider);
      await ref.read(myDayJobsProvider.future);
    }

    Widget jobCards(List<AccountJob> jobs) => PageSliver(
      top: 0,
      sliver: SliverList.separated(
        itemCount: jobs.length,
        separatorBuilder: (_, _) => const SizedBox(height: SpaceSpace.gap),
        itemBuilder: (context, i) {
          final item = jobs[i];
          return JobCard(
            job: item.job,
            accountName: item.client.displayName,
            onTap: () => context.push(jobPath(item.client.id, item.job.id)),
          );
        },
      ),
    );

    return SpacePage(
      // A tab's home: nothing to go back to.
      showBack: false,
      title: l10n.todayTitle,
      onRefresh: refresh,
      actions: [
        if (user != null)
          _ProfileButton(name: user.name, photoUrl: user.photoUrl),
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
          value: mine,
          onRetry: refresh,
          builder: (mine) {
            final mineIds = {for (final j in mine) j.job.id};
            final others = [
              for (final j in everyone?.value?.jobs ?? const <AccountJob>[])
                if (!mineIds.contains(j.job.id)) j,
            ];
            final failedClients = everyone?.value?.failedClients ?? const [];
            final everyoneError = everyone?.error;
            // The day's work the user can see: their own and, for staff,
            // everyone else's.
            final all = [...mine, ...others];
            int count(JobStatus status) =>
                all.where((j) => j.job.status == status).length;
            final nothing =
                all.isEmpty &&
                overdue.isEmpty &&
                failedClients.isEmpty &&
                everyoneError == null;

            return SliverMainAxisGroup(
              slivers: [
                PageBox(
                  top: 20,
                  child: HeroHeadline(
                    primary: l10n.greeting(firstName),
                    secondary: l10n.jobsTodayCount(all.length),
                  ),
                ),
                if (all.isNotEmpty)
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
                if (nothing)
                  MessageSliver(
                    icon: Icons.wb_sunny_outlined,
                    title: l10n.noJobsToday,
                    hint: l10n.noJobsTodayHint,
                  )
                else ...[
                  // Late work first: it's what needs doing.
                  if (overdue.isNotEmpty) ...[
                    PageBox(
                      top: 12,
                      child: SectionHeader(title: l10n.overdueTasks),
                    ),
                    PageBox(
                      top: 0,
                      child: ListCard(
                        children: [
                          for (final t in overdue)
                            TaskRow(
                              task: t,
                              onTap: () =>
                                  context.push(taskPath(t.clientId, t.id)),
                            ),
                        ],
                      ),
                    ),
                  ],
                  PageBox(top: 12, child: SectionHeader(title: l10n.yourJobs)),
                  if (mine.isEmpty)
                    PageBox(
                      top: 0,
                      child: ListCard(
                        children: [
                          ListRow(title: l10n.noJobsForYouToday, muted: true),
                        ],
                      ),
                    )
                  else
                    jobCards(mine),
                  if (everyoneError is Failure)
                    PageBox(
                      child: Notice(
                        message: l10n.failureMessage(everyoneError),
                      ),
                    )
                  else if (failedClients.isNotEmpty)
                    PageBox(
                      child: Notice(
                        message: l10n.someAccountsFailed(failedClients.length),
                      ),
                    ),
                  if (others.isNotEmpty) ...[
                    PageBox(
                      top: 16,
                      child: SectionHeader(title: l10n.otherJobsToday),
                    ),
                    jobCards(others),
                  ],
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

/// The user's avatar, which opens Me (profile, administration, settings),
/// with the unread notifications counted on it.
class _ProfileButton extends ConsumerWidget {
  const _ProfileButton({required this.name, this.photoUrl});

  final String name;
  final String? photoUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final unread = ref.watch(unreadNotificationsProvider).value ?? 0;
    return Tooltip(
      message: l10n.profileTitle,
      child: Semantics(
        button: true,
        label: [
          l10n.profileTitle,
          if (unread > 0) l10n.unreadNotifications(unread),
        ].join(', '),
        excludeSemantics: true,
        child: SizedBox.square(
          dimension: 48,
          child: Center(
            child: CountBadge(
              count: unread,
              child: Material(
                type: MaterialType.transparency,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => context.go(ProfileScreen.path),
                  child: InitialsAvatar(
                    name: name,
                    photoUrl: photoUrl,
                    background: context.colors.surface,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
