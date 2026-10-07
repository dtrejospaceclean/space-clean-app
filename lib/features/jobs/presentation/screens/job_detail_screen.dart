import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../core/widgets/adaptive.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../access/domain/entities/account_access.dart';
import '../../../access/presentation/controllers/account_access_provider.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../clients/presentation/screens/accounts_screen.dart';
import '../../../scopes/presentation/screens/scopes_screen.dart';
import '../../di/jobs_providers.dart';
import '../../domain/entities/job.dart';
import '../../domain/usecases/job_usecases.dart';
import '../controllers/jobs_providers.dart';
import '../widgets/job_status_label.dart';
import 'job_checklist_screen.dart';
import 'job_crew_screen.dart';
import 'today_screen.dart';

/// One job: when and where, its checklist, crew and instructions. While
/// it's open (scheduled or in progress), `jobs.edit` edits it and its
/// checklist and cancels it, and `jobs.assign` changes the crew; until it
/// starts, `jobs.edit` can delete it. While it's open, its crew and
/// `jobs.edit` tick checklist items off (and reopen them). The other field
/// actions (check-in, start, complete) come with the crew job flow.
class JobDetailScreen extends ConsumerStatefulWidget {
  const JobDetailScreen({
    super.key,
    required this.clientId,
    required this.jobId,
  });

  final String clientId;
  final String jobId;

  @override
  ConsumerState<JobDetailScreen> createState() => _JobDetailScreenState();
}

/// What's in flight: nothing else on the page starts until it settles.
enum _Busy { delete, cancel }

class _JobDetailScreenState extends ConsumerState<JobDetailScreen> {
  _Busy? _busy;

  /// The checklist items being ticked or reopened.
  final _ticking = <String>{};

  JobRef get _ref => JobRef(clientId: widget.clientId, jobId: widget.jobId);

  Future<bool> _confirm(String title, String body, String action) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(title),
        content: Text(body),
        actions: [
          adaptiveAction(
            context,
            label: l10n.keepJob,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          adaptiveAction(
            context,
            label: action,
            destructive: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    return confirmed == true && mounted;
  }

  Future<void> _showFailure(Failure f) {
    final l10n = AppLocalizations.of(context);
    return showAdaptiveDialog<void>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        content: Text(l10n.failureMessage(f)),
        actions: [
          adaptiveAction(
            context,
            label: l10n.doneButton,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  /// Asks first, then deletes the job and goes back to [list].
  Future<void> _delete(String list) async {
    final l10n = AppLocalizations.of(context);
    if (!await _confirm(
      l10n.deleteJobConfirmTitle,
      l10n.deleteJobConfirmBody,
      l10n.deleteButton,
    )) {
      return;
    }
    setState(() => _busy = _Busy.delete);
    try {
      await ref.read(deleteJobProvider)(_ref);
      if (!mounted) return;
      // Leave before the lists reload, so this page doesn't flash "not
      // found" on its way out.
      context.go(list);
      invalidateJobs(ref);
    } on Failure catch (f) {
      if (!mounted) return;
      setState(() => _busy = null);
      await _showFailure(f);
    }
  }

  Future<void> _cancel() async {
    final l10n = AppLocalizations.of(context);
    if (!await _confirm(
      l10n.cancelJobConfirmTitle,
      l10n.cancelJobConfirmBody,
      l10n.cancelJob,
    )) {
      return;
    }
    setState(() => _busy = _Busy.cancel);
    try {
      await ref.read(cancelJobProvider)(_ref);
      invalidateJobs(ref);
    } on Failure catch (f) {
      if (mounted) await _showFailure(f);
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  /// Ticks [item] off, or reopens it, then shows the job as saved.
  Future<void> _tick(ChecklistItem item) async {
    setState(() => _ticking.add(item.id));
    try {
      await ref.read(tickChecklistItemProvider)(
        TickChecklistItemParams(
          clientId: widget.clientId,
          jobId: widget.jobId,
          itemId: item.id,
          done: !item.isCompleted,
        ),
      );
      invalidateJobs(ref);
      // Keep the spinner until the row shows the change.
      await ref.read(jobProvider((widget.clientId, widget.jobId)).future);
    } on Failure catch (f) {
      if (mounted) await _showFailure(f);
    } finally {
      if (mounted) setState(() => _ticking.remove(item.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final key = (widget.clientId, widget.jobId);
    final job = ref.watch(jobProvider(key));
    final access = ref.watch(accountAccessProvider(widget.clientId)).value;
    final canEdit = access?.can(Permissions.jobsEdit) ?? false;
    final canAssign = access?.can(Permissions.jobsAssign) ?? false;
    final canViewScopes = access?.can(Permissions.scopeView) ?? false;
    final me = switch (ref.watch(authControllerProvider).value) {
      Authenticated(:final user) => user.id,
      _ => null,
    };
    final j = job.value;
    final open = j?.isOpen ?? false;
    final here = GoRouterState.of(context).matchedLocation;
    // Opened from Today or from the account's jobs.
    final fromAccount = here.startsWith(AccountsScreen.path);
    final list = fromAccount
        ? here.substring(0, here.lastIndexOf('/'))
        : TodayScreen.path;
    final busy = _busy != null;
    Future<void> refresh() => ref.refresh(jobProvider(key).future);

    return PopScope(
      canPop: !busy,
      child: AbsorbPointer(
        absorbing: busy,
        child: SpacePage(
          heading: switch (j) {
            final job? => HeroHeadline(
              primary: job.title,
              secondary: job.location?.name,
            ),
            null => null,
          },
          onRefresh: busy ? null : refresh,
          actions: [
            if (canEdit && (j?.canDelete ?? false))
              CircleButton.light(
                icon: Icons.delete_outline_rounded,
                tooltip: l10n.deleteJob,
                busy: _busy == _Busy.delete,
                onPressed: () => _delete(list),
              ),
            if (canEdit && open)
              CircleButton.dark(
                icon: Icons.edit_outlined,
                tooltip: l10n.editJob,
                onPressed: busy ? null : () => context.push('$here/edit'),
              ),
          ],
          slivers: [
            AsyncSlivers(
              value: job,
              onRetry: refresh,
              builder: (job) => SliverMainAxisGroup(
                slivers: [
                  PageBox(top: 8, child: _WhenCard(job: job)),
                  if (job.status == JobStatus.cancelled)
                    PageBox(
                      child: Notice(
                        message: l10n.jobCancelledNotice,
                        tone: NoticeTone.info,
                      ),
                    ),
                  if (job.checklistTotal > 0)
                    PageBox(
                      top: SpaceSpace.gap,
                      child: _ChecklistCard(job: job),
                    ),
                  PageBox(
                    top: SpaceSpace.gap,
                    child: _Facts(
                      job: job,
                      onScope: switch (job.scopeId) {
                        final scopeId? when canViewScopes && fromAccount =>
                          () => context.push(
                            '${AccountsScreen.path}/${widget.clientId}/'
                            '${ScopesScreen.route}/$scopeId',
                          ),
                        _ => null,
                      },
                    ),
                  ),
                  if (job.status == JobStatus.completed)
                    PageBox(
                      top: SpaceSpace.gap,
                      child: _CompletionCard(job: job),
                    ),
                  PageBox(
                    top: 12,
                    child: SectionHeader(
                      title: l10n.jobChecklist,
                      actionLabel: canEdit && job.isOpen
                          ? l10n.editButton
                          : null,
                      onAction: busy
                          ? null
                          : () => context.push(
                              '$here/${JobChecklistScreen.route}',
                            ),
                    ),
                  ),
                  PageBox(
                    top: 0,
                    child: ListCard(
                      children: [
                        if (job.checklist.isEmpty)
                          ListRow(title: l10n.noChecklistItems, muted: true)
                        else
                          for (final item in job.checklist)
                            _ChecklistRow(
                              item: item,
                              busy: _ticking.contains(item.id),
                              // The crew on site, or whoever runs the job.
                              onTap:
                                  job.isOpen &&
                                      !busy &&
                                      (canEdit ||
                                          (me != null && job.hasCrewMember(me)))
                                  ? () => _tick(item)
                                  : null,
                            ),
                      ],
                    ),
                  ),
                  PageBox(
                    top: 12,
                    child: SectionHeader(
                      title: l10n.jobCrew,
                      actionLabel: canAssign && job.isOpen
                          ? l10n.editButton
                          : null,
                      onAction: busy
                          ? null
                          : () => context.push('$here/${JobCrewScreen.route}'),
                    ),
                  ),
                  PageBox(
                    top: 0,
                    child: ListCard(
                      children: [
                        if (job.assignees.isEmpty)
                          ListRow(title: l10n.noCrewAssigned, muted: true)
                        else
                          for (final person in job.assignees)
                            ListRow(
                              leading: InitialsAvatar(name: person.name),
                              title: person.name,
                              subtitle: _crewDetails(context, person),
                            ),
                      ],
                    ),
                  ),
                  if (job.instructions case final text?
                      when text.trim().isNotEmpty) ...[
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
                  if (canEdit && job.canCancel)
                    PageBox(
                      top: 24,
                      child: SecondaryButton(
                        label: l10n.cancelJob,
                        icon: Icons.block_rounded,
                        destructive: true,
                        onPressed: busy ? null : _cancel,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// "Lead · In 7:02 AM · Out 9:15 AM", or null when there's nothing to say.
  String? _crewDetails(BuildContext context, JobAssignee person) {
    final l10n = AppLocalizations.of(context);
    final parts = [
      if (person.roleOnJob case final role? when role.trim().isNotEmpty)
        role.trim(),
      if (person.checkInTime case final t?)
        l10n.checkedInAt(context.formatTime(t)),
      if (person.checkOutTime case final t?)
        l10n.checkedOutAt(context.formatTime(t)),
    ];
    return parts.isEmpty ? null : parts.join(' · ');
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

/// Where, from which scope, and what kind of job.
class _Facts extends StatelessWidget {
  const _Facts({required this.job, this.onScope});

  final Job job;
  final VoidCallback? onScope;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final place = [
      job.location?.address,
      job.location?.city,
    ].whereType<String>().join(', ');
    return ListCard(
      children: [
        ListRow(
          leading: const IconBadge(icon: Icons.place_outlined),
          title: job.location?.name ?? l10n.notSet,
          subtitle: place.isEmpty ? l10n.locationLabel : place,
          muted: job.location == null,
        ),
        if (job.scopeId != null)
          ListRow(
            leading: const IconBadge(icon: Icons.checklist_rtl_rounded),
            title: job.scopeArea ?? l10n.scopeWholeSite,
            subtitle: l10n.scopeTitle,
            onTap: onScope,
          ),
        ListRow(
          leading: IconBadge(
            icon: job.jobType == JobType.recurring
                ? Icons.repeat_rounded
                : Icons.looks_one_outlined,
          ),
          title: job.jobType == JobType.recurring
              ? l10n.jobTypeRecurring
              : l10n.jobTypeSpecial,
          subtitle: l10n.jobTypeLabel,
        ),
      ],
    );
  }
}

/// Who started and finished it, the score, the crew's notes and the
/// client's sign-off.
class _CompletionCard extends StatelessWidget {
  const _CompletionCard({required this.job});

  final Job job;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String? at(DateTime? time, String? name) => switch ((time, name)) {
      (final t?, final n?) => l10n.doneAtBy(context.formatTime(t), n),
      (final t?, null) => context.formatTime(t),
      (null, final n?) => n,
      _ => null,
    };
    final rows = [
      if (at(job.actualStart, job.startedByName) case final v?)
        ListRow(
          leading: const IconBadge(icon: Icons.play_arrow_rounded),
          title: v,
          subtitle: l10n.jobStartedLabel,
        ),
      if (at(job.actualEnd, job.completedByName) case final v?)
        ListRow(
          leading: const IconBadge(icon: Icons.check_rounded),
          title: v,
          subtitle: l10n.jobCompletedLabel,
        ),
      if (job.qualityScore case final score?)
        ListRow(
          leading: const IconBadge(icon: Icons.star_outline_rounded),
          title: l10n.qualityScoreValue(context.formatNumber('$score')),
          subtitle: l10n.qualityScoreLabel,
        ),
      if (job.clientSignoffName case final name? when name.trim().isNotEmpty)
        ListRow(
          leading: const IconBadge(icon: Icons.draw_outlined),
          title: name,
          subtitle: l10n.clientSignoffLabel,
        ),
      if (job.cleanerNotes case final notes? when notes.trim().isNotEmpty)
        ListRow(
          leading: const IconBadge(icon: Icons.sticky_note_2_outlined),
          title: notes.trim(),
          subtitle: l10n.cleanerNotesLabel,
        ),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();
    return ListCard(children: rows);
  }
}

/// A checklist item with a check when it's done, and who ticked it. With
/// [onTap], tapping it ticks it off or reopens it.
class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({required this.item, this.onTap, this.busy = false});

  final ChecklistItem item;
  final VoidCallback? onTap;

  /// Its tick is being saved.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return Semantics(
      checked: item.isCompleted,
      onTapHint: onTap == null
          ? null
          : item.isCompleted
          ? l10n.reopenChecklistItem
          : l10n.tickChecklistItem,
      child: ListRow(
        leading: SizedBox.square(
          dimension: 24,
          child: busy
              ? const Padding(
                  padding: EdgeInsets.all(3),
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2.5),
                )
              : Icon(
                  item.isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: item.isCompleted ? colors.successInk : colors.inkMuted,
                  semanticLabel: item.isCompleted
                      ? l10n.checklistItemDone
                      : l10n.checklistItemOpen,
                ),
        ),
        title: item.description,
        subtitle: switch ((item.completedAt, item.completedByName)) {
          (final t?, final n?) => l10n.doneAtBy(context.formatTime(t), n),
          (null, final n?) => n,
          (final t?, null) => context.formatTime(t),
          _ => null,
        },
        // Acts in place: no chevron.
        chevron: false,
        onTap: busy ? null : onTap,
      ),
    );
  }
}
