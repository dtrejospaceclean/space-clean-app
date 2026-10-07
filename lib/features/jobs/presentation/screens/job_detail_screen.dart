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
import '../../../proposals/presentation/widgets/line_item_row.dart';
import '../../../scopes/presentation/screens/scopes_screen.dart';
import '../../di/jobs_providers.dart';
import '../../domain/entities/job.dart';
import '../../domain/usecases/job_usecases.dart';
import '../controllers/jobs_providers.dart';
import '../widgets/job_status_label.dart';
import 'job_checklist_screen.dart';
import 'job_complete_screen.dart';
import 'job_crew_screen.dart';
import 'today_screen.dart';

/// One job: when and where, its checklist, crew and instructions. While
/// it's open (scheduled or in progress), `jobs.edit` edits it and its
/// checklist and cancels it, and `jobs.assign` changes the crew; until it
/// starts, `jobs.edit` can delete it.
///
/// On site, the crew works it top to bottom: check in, start, tick the
/// checklist, complete (on its own page), check out. Checking in and out is
/// for the crew only; starting, ticking and completing are for the crew and
/// `jobs.edit`. The next step is the primary button.
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
enum _Busy { delete, cancel, checkIn, start, checkOut }

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

  /// Runs a field action ([kind]) and shows the job as saved.
  Future<void> _act(_Busy kind, Future<Job> Function(JobRef job) action) async {
    setState(() => _busy = kind);
    try {
      await action(_ref);
      invalidateJobs(ref);
      // Keep the button busy until the page shows the change.
      await ref.read(jobProvider((widget.clientId, widget.jobId)).future);
    } on Failure catch (f) {
      if (mounted) await _showFailure(f);
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  /// The crew's next steps on site, in order: check in, start, complete,
  /// check out. The first one offered is the primary button.
  List<Widget> _fieldActions(
    Job job, {
    required String? me,
    required bool canEdit,
  }) {
    final l10n = AppLocalizations.of(context);
    final here = GoRouterState.of(context).matchedLocation;
    final busy = _busy != null;
    final mine = me == null ? null : job.crewMember(me);
    final canRun = canEdit || mine != null;
    final actions = <(String, IconData, _Busy?, VoidCallback)>[
      if (mine != null && mine.checkInTime == null && job.isOpen)
        (
          l10n.checkIn,
          Icons.login_rounded,
          _Busy.checkIn,
          () => _act(_Busy.checkIn, ref.read(checkInProvider).call),
        ),
      if (canRun && job.status == JobStatus.scheduled)
        (
          l10n.startJob,
          Icons.play_arrow_rounded,
          _Busy.start,
          () => _act(_Busy.start, ref.read(startJobProvider).call),
        ),
      if (canRun && job.status == JobStatus.inProgress)
        (
          l10n.completeJob,
          Icons.check_rounded,
          null,
          () => context.push('$here/${JobCompleteScreen.route}'),
        ),
      if (mine?.checkInTime != null && mine?.checkOutTime == null)
        (
          l10n.checkOut,
          Icons.logout_rounded,
          _Busy.checkOut,
          () => _act(_Busy.checkOut, ref.read(checkOutProvider).call),
        ),
    ];
    return [
      if (mine?.checkInTime case final t?)
        PageBox(
          child: Notice(
            message: switch (mine?.checkOutTime) {
              final out? => l10n.youCheckedInOut(
                context.formatTime(t),
                context.formatTime(out),
              ),
              null => l10n.youCheckedIn(context.formatTime(t)),
            },
            tone: NoticeTone.success,
          ),
        ),
      for (final (i, (label, icon, kind, onPressed)) in actions.indexed)
        PageBox(
          top: i == 0 ? 16 : SpaceSpace.gap,
          child: i == 0
              ? PrimaryButton(
                  label: label,
                  icon: icon,
                  busy: kind != null && _busy == kind,
                  onPressed: busy ? null : onPressed,
                )
              : SecondaryButton(
                  label: label,
                  icon: icon,
                  onPressed: busy ? null : onPressed,
                ),
        ),
    ];
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
                  PageBox(
                    top: 8,
                    child: _SummaryCard(
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
                  if (job.status == JobStatus.cancelled)
                    PageBox(
                      child: Notice(
                        message: l10n.jobCancelledNotice,
                        tone: NoticeTone.info,
                      ),
                    ),
                  ..._fieldActions(job, me: me, canEdit: canEdit),
                  if (job.instructions?.trim() case final text?
                      when text.isNotEmpty)
                    PageBox(
                      top: SpaceSpace.gap,
                      child: ListCard(
                        children: [
                          ListRow(
                            leading: const IconBadge(
                              icon: Icons.info_outline_rounded,
                            ),
                            title: text,
                            subtitle: l10n.jobInstructions,
                          ),
                        ],
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
                            _CrewRow(person: person),
                      ],
                    ),
                  ),
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
}

/// The head of the job: the time big across the card, the day and the kind
/// of job under it with the status at their right, then where (the
/// location and its address) and the scope it's for, and the checklist's
/// progress across the bottom, its count on the right. At large text the
/// pill moves above the time.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.job, this.onScope});

  final Job job;

  /// Opens the scope; null when it can't be opened from here.
  final VoidCallback? onScope;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final recurring = job.jobType == JobType.recurring;
    final large = isLargeText(context);
    final time = Text(
      context.formatTimeRange(job.scheduledStart, job.scheduledEnd),
      style: theme.textTheme.headlineMedium?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
    final pill = JobStatusLabel(status: job.status);
    final kind = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          recurring ? Icons.repeat_rounded : Icons.looks_one_outlined,
          size: 16,
          color: colors.inkMuted,
        ),
        const SizedBox(width: 4),
        Text(
          recurring ? l10n.jobTypeRecurring : l10n.jobTypeSpecial,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
    final day = Text(
      context.formatDayLong(job.scheduledStart),
      style: theme.textTheme.bodyMedium,
    );
    final address = [
      job.location?.address,
      job.location?.city,
    ].whereType<String>().join(', ');

    return SpaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (large) ...[
            Align(alignment: Alignment.centerLeft, child: pill),
            const SizedBox(height: 10),
            time,
            const SizedBox(height: 4),
            day,
            const SizedBox(height: 4),
            Align(alignment: Alignment.centerLeft, child: kind),
          ] else ...[
            // The time keeps the full width so it never wraps; the status
            // sits beside the day and the kind of job.
            time,
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [day, const SizedBox(height: 4), kind],
                  ),
                ),
                const SizedBox(width: 12),
                pill,
              ],
            ),
          ],
          const SizedBox(height: 14),
          _HeadLine(
            icon: Icons.place_outlined,
            title: job.location?.name ?? l10n.notSet,
            detail: address.isEmpty ? l10n.locationLabel : address,
            label: l10n.locationLabel,
          ),
          if (job.scopeId != null)
            _HeadLine(
              icon: Icons.checklist_rtl_rounded,
              title: job.scopeArea ?? l10n.scopeWholeSite,
              detail: l10n.scopeTitle,
              label: l10n.scopeTitle,
              onTap: onScope,
            ),
          if (job.checklistTotal > 0) ...[
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    l10n.jobChecklist,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(width: 12),
                Semantics(
                  label: l10n.checklistProgress(
                    job.checklistDone,
                    job.checklistTotal,
                  ),
                  excludeSemantics: true,
                  child: Text(
                    '${job.checklistDone}/${job.checklistTotal}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SpaceProgressBar(
              value: job.checklistDone / job.checklistTotal,
              semanticsLabel: l10n.jobChecklist,
            ),
          ],
        ],
      ),
    );
  }
}

/// The crew's report once it's done: who started and finished it (when, at
/// the right; under the name at large text), the score, the client's
/// sign-off and the crew's notes.
class _CompletionCard extends StatelessWidget {
  const _CompletionCard({required this.job});

  final Job job;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final large = isLargeText(context);
    ListRow? step(IconData icon, String label, DateTime? at, String? by) {
      if (at == null && by == null) return null;
      final time = at == null ? null : context.formatTime(at);
      return ListRow(
        leading: IconBadge(icon: icon),
        title: by ?? time!,
        subtitle: [label, if (large && by != null) ?time].join(' · '),
        trailing: !large && by != null && time != null
            ? Text(time, style: moneyStyle)
            : null,
      );
    }

    final rows = [
      ?step(
        Icons.play_arrow_rounded,
        l10n.jobStartedLabel,
        job.actualStart,
        job.startedByName,
      ),
      ?step(
        Icons.check_rounded,
        l10n.jobCompletedLabel,
        job.actualEnd,
        job.completedByName,
      ),
      if (job.qualityScore case final score?)
        ListRow(
          leading: const IconBadge(icon: Icons.star_outline_rounded),
          title: l10n.qualityScoreValue(context.formatNumber('$score')),
          subtitle: l10n.qualityScoreLabel,
        ),
      if (job.clientSignoffName?.trim() case final name? when name.isNotEmpty)
        ListRow(
          leading: const IconBadge(icon: Icons.draw_outlined),
          title: name,
          subtitle: l10n.clientSignoffLabel,
        ),
      if (job.cleanerNotes?.trim() case final notes? when notes.isNotEmpty)
        ListRow(
          leading: const IconBadge(icon: Icons.sticky_note_2_outlined),
          title: notes,
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
    final large = isLargeText(context);
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
        // Who ticked it under the item; when, at the right (under it too at
        // large text).
        subtitle: switch ((item.completedAt, item.completedByName)) {
          (final t?, final n?) when large => l10n.doneAtBy(
            context.formatTime(t),
            n,
          ),
          (final t?, null) when large => context.formatTime(t),
          (_, final n?) => n,
          _ => null,
        },
        trailing: switch (item.completedAt) {
          final t? when !large => Text(
            context.formatTime(t),
            style: moneyStyle,
          ),
          _ => null,
        },
        // Acts in place: no chevron.
        chevron: false,
        onTap: busy ? null : onTap,
      ),
    );
  }
}

/// Someone on the crew: their role under the name, and when they were on
/// site at the right ("In 5:55 PM", or "5:55 PM – 8:10 PM" once out). At
/// large text the times go under the name instead.
class _CrewRow extends StatelessWidget {
  const _CrewRow({required this.person});

  final JobAssignee person;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final large = isLargeText(context);
    final times = switch ((person.checkInTime, person.checkOutTime)) {
      (final inAt?, final outAt?) => context.formatTimeRange(inAt, outAt),
      (final inAt?, null) => l10n.checkedInAt(context.formatTime(inAt)),
      (null, final outAt?) => l10n.checkedOutAt(context.formatTime(outAt)),
      _ => null,
    };
    final role = switch (person.roleOnJob?.trim()) {
      final r? when r.isNotEmpty => r,
      _ => null,
    };
    final details = [?role, if (large) ?times];
    return ListRow(
      leading: InitialsAvatar(name: person.name),
      title: person.name,
      subtitle: details.isEmpty ? null : details.join(' · '),
      trailing: times != null && !large ? Text(times, style: moneyStyle) : null,
    );
  }
}

/// A fact in the job's head card: an icon, the value, and a muted line
/// under it. With [onTap] the whole line opens it, with a chevron.
class _HeadLine extends StatelessWidget {
  const _HeadLine({
    required this.icon,
    required this.title,
    required this.detail,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String detail;

  /// What it is, for screen readers ("Location").
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    return Semantics(
      button: onTap != null,
      label: '$label: $title, $detail',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SpaceRadius.inner),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Icon(icon, size: 20, color: colors.inkMuted),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(detail, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right_rounded, color: colors.inkSoft),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
