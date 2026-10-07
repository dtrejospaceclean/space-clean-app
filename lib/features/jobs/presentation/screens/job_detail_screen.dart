import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../../locations/presentation/screens/locations_screen.dart';
import '../../../proposals/presentation/widgets/line_item_row.dart';
import '../../../scopes/presentation/screens/scopes_screen.dart';
import '../../../scopes/presentation/widgets/scope_labels.dart';
import '../../di/jobs_providers.dart';
import '../../domain/entities/job.dart';
import '../../domain/usecases/job_usecases.dart';
import '../controllers/jobs_providers.dart';
import '../widgets/job_status_label.dart';
import 'job_checklist_screen.dart';
import 'job_complete_screen.dart';
import 'job_crew_screen.dart';
import 'today_screen.dart';

/// One job: a summary card (when, status, where and for which scope, the
/// checklist's progress), the crew's next step, the site instructions, an
/// activity log of what happened on site, then the checklist and the crew.
///
/// While it's open (scheduled or in progress), `jobs.edit` edits it and its
/// checklist and cancels it (from the header's menu), and `jobs.assign`
/// changes the crew; until it starts, `jobs.edit` can delete it.
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

/// The header menu's choices.
enum _MenuAction { edit, cancel, delete }

class _JobDetailScreenState extends ConsumerState<JobDetailScreen> {
  _Busy? _busy;

  /// The checklist items being ticked or reopened.
  final _ticking = <String>{};

  /// "Review tasks" scrolls here.
  final _checklistKey = GlobalKey();

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

  /// The header's "⋯": edit, cancel and delete, as the job allows.
  Future<void> _openMenu(
    Set<_MenuAction> actions, {
    required String here,
    required String list,
  }) async {
    final l10n = AppLocalizations.of(context);
    final picked = await showAppChoice(
      context,
      allowClear: false,
      options: {
        if (actions.contains(_MenuAction.edit))
          _MenuAction.edit.name: l10n.editJob,
        if (actions.contains(_MenuAction.cancel))
          _MenuAction.cancel.name: l10n.cancelJob,
        if (actions.contains(_MenuAction.delete))
          _MenuAction.delete.name: l10n.deleteJob,
      },
      destructive: {_MenuAction.cancel.name, _MenuAction.delete.name},
    );
    if (picked == null || !mounted) return;
    switch (_MenuAction.values.firstWhere((a) => a.name == picked)) {
      case _MenuAction.edit:
        context.push('$here/edit');
      case _MenuAction.cancel:
        await _cancel();
      case _MenuAction.delete:
        await _delete(list);
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

  void _reviewTasks() {
    final target = _checklistKey.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
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
    final canViewInfo = access?.can(Permissions.infoView) ?? false;
    final me = switch (ref.watch(authControllerProvider).value) {
      Authenticated(:final user) => user.id,
      _ => null,
    };
    final j = job.value;
    final here = GoRouterState.of(context).matchedLocation;
    // Opened from Today or from the account's jobs. Related pages open only
    // within the account's stack.
    final fromAccount = here.startsWith(AccountsScreen.path);
    final account = '${AccountsScreen.path}/${widget.clientId}';
    final list = fromAccount
        ? here.substring(0, here.lastIndexOf('/'))
        : TodayScreen.path;
    final busy = _busy != null;
    final menu = <_MenuAction>{
      if (canEdit && (j?.isOpen ?? false)) _MenuAction.edit,
      if (canEdit && (j?.canCancel ?? false)) _MenuAction.cancel,
      if (canEdit && (j?.canDelete ?? false)) _MenuAction.delete,
    };
    Future<void> refresh() => ref.refresh(jobProvider(key).future);

    return PopScope(
      canPop: !busy,
      child: AbsorbPointer(
        absorbing: busy,
        child: SpacePage(
          title: j?.title,
          onRefresh: busy ? null : refresh,
          actions: [
            if (menu.isNotEmpty)
              CircleButton.light(
                icon: Icons.more_horiz_rounded,
                tooltip: l10n.moreActions,
                busy: _busy == _Busy.delete || _busy == _Busy.cancel,
                onPressed: () => _openMenu(menu, here: here, list: list),
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
                      onLocation: switch (job.locationId) {
                        final id? when canViewInfo && fromAccount =>
                          () => context.push(
                            '$account/${LocationsScreen.route}/$id',
                          ),
                        _ => null,
                      },
                      onScope: switch (job.scopeId) {
                        final id? when canViewScopes && fromAccount =>
                          () => context.push(
                            '$account/${ScopesScreen.route}/$id',
                          ),
                        _ => null,
                      },
                      onReviewTasks: _reviewTasks,
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
                    PageBox(top: 16, child: _InstructionsCard(text: text)),
                  if (_ActivityLog.eventsOf(context, job) case final events
                      when events.isNotEmpty)
                    PageBox(top: 16, child: _ActivityLog(events: events)),
                  PageBox(
                    top: 16,
                    child: KeyedSubtree(
                      key: _checklistKey,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The head of the job: a status-colored edge along the top; the time big
/// across the card; how long it runs and the day, with the status at their
/// right (above the time at large text); what kind of
/// job; where and for which scope (each opening its page when it can); and
/// the checklist's progress, with a link down to the tasks.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.job,
    required this.onReviewTasks,
    this.onLocation,
    this.onScope,
  });

  final Job job;
  final VoidCallback? onLocation;
  final VoidCallback? onScope;
  final VoidCallback onReviewTasks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final tone = JobTone.of(context, job.status);
    final large = isLargeText(context);
    final recurring = job.jobType == JobType.recurring;
    final address = [
      job.location?.address,
      job.location?.city,
    ].whereType<String>().join(', ');

    final time = Text(
      context.formatTimeRange(job.scheduledStart, job.scheduledEnd),
      style: theme.textTheme.headlineMedium?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
    final pill = JobStatusLabel(status: job.status);
    final minutes = switch (job.scheduledEnd) {
      final end? when end.isAfter(job.scheduledStart) =>
        end.difference(job.scheduledStart).inMinutes,
      _ => null,
    };
    Widget divider() => Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Divider(height: 1, thickness: 1, color: colors.line),
    );

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(SpaceRadius.card),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The status color along the top edge.
          ExcludeSemantics(
            child: SizedBox(height: 5, child: ColoredBox(color: tone.edge)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (large) ...[
                  Align(alignment: Alignment.centerLeft, child: pill),
                  const SizedBox(height: 10),
                  time,
                ] else
                  // The time keeps the full width so 12-hour times stay on
                  // one line; the status sits beside the day below.
                  time,
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (minutes != null)
                            _Chip(
                              icon: Icons.schedule_rounded,
                              label: l10n.durationHoursMinutes(
                                minutes ~/ 60,
                                (minutes % 60).toString().padLeft(2, '0'),
                              ),
                            ),
                          Text(
                            context.formatDayLong(job.scheduledStart),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    if (!large) ...[const SizedBox(width: 12), pill],
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _Chip(
                    icon: recurring
                        ? Icons.repeat_rounded
                        : Icons.looks_one_outlined,
                    label: recurring
                        ? l10n.jobTypeRecurring
                        : l10n.jobTypeSpecial,
                    tinted: true,
                  ),
                ),
                divider(),
                _FactRow(
                  icon: Icons.place_outlined,
                  label: l10n.locationLabel,
                  title: job.location?.name ?? l10n.notSet,
                  detail: address.isEmpty ? null : address,
                  onTap: onLocation,
                ),
                if (job.scopeId != null) ...[
                  const SizedBox(height: 4),
                  _FactRow(
                    icon: Icons.checklist_rtl_rounded,
                    label: l10n.scopeTitle,
                    title: job.scopeArea ?? l10n.scopeWholeSite,
                    detail: switch (job.scopeFrequency) {
                      final f? => l10n.scopeFrequency(f),
                      null => null,
                    },
                    onTap: onScope,
                  ),
                ],
                if (job.checklistTotal > 0) ...[
                  divider(),
                  _ChecklistSummary(
                    job: job,
                    tone: tone,
                    onReview: onReviewTasks,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A small rounded label with an icon: the duration, the kind of job.
class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, this.tinted = false});

  final IconData icon;
  final String label;

  /// Orange wash, for the kind of job.
  final bool tinted;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final ink = tinted ? c.highlightInk : c.inkMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tinted ? c.highlightSoft : c.sunken,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: ink),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One fact in the summary: a sunken icon tile, a small label over the
/// value, a detail line, and a chevron when it opens something.
class _FactRow extends StatelessWidget {
  const _FactRow({
    required this.icon,
    required this.label,
    required this.title,
    this.detail,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String title;
  final String? detail;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.colors;
    return Semantics(
      button: onTap != null,
      label: [label, title, ?detail].join(', '),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SpaceRadius.inner),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: c.sunken,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 22, color: c.ink),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: c.inkMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (detail case final d?) ...[
                        const SizedBox(height: 2),
                        Text(d, style: theme.textTheme.bodyMedium),
                      ],
                    ],
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right_rounded, color: c.inkSoft),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "Checklist ● · 12 of 12 completed" over a bar in the status color, then
/// "100% done" and "Review tasks →".
class _ChecklistSummary extends StatelessWidget {
  const _ChecklistSummary({
    required this.job,
    required this.tone,
    required this.onReview,
  });

  final Job job;
  final JobTone tone;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final done = job.checklistDone;
    final total = job.checklistTotal;
    final percent = (done * 100 / total).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                l10n.jobChecklist,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ExcludeSemantics(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: tone.bar,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const Spacer(),
            Text(
              l10n.checklistCompletedCount(done, total),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SpaceProgressBar(
          value: done / total,
          height: 8,
          color: tone.bar,
          semanticsLabel: l10n.jobChecklist,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.percentDone(percent),
                style: theme.textTheme.bodySmall?.copyWith(color: c.inkMuted),
              ),
            ),
            TextButton.icon(
              onPressed: onReview,
              iconAlignment: IconAlignment.end,
              icon: Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: c.accent,
              ),
              label: Text(
                l10n.reviewTasks,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: c.accent,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// The site instructions (codes, where to enter) with a Copy button, so a
/// code can go straight into a keypad app or a message.
class _InstructionsCard extends StatefulWidget {
  const _InstructionsCard({required this.text});

  final String text;

  @override
  State<_InstructionsCard> createState() => _InstructionsCardState();
}

class _InstructionsCardState extends State<_InstructionsCard> {
  bool _copied = false;
  Timer? _reset;

  @override
  void dispose() {
    _reset?.cancel();
    super.dispose();
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.text));
    HapticFeedback.lightImpact();
    if (!mounted) return;
    setState(() => _copied = true);
    _reset?.cancel();
    _reset = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return SpaceCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: c.highlightSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.key_rounded, color: c.highlightInk),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.jobInstructions,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(widget.text, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Semantics(
            liveRegion: true,
            child: Material(
              color: c.highlightSoft,
              shape: const StadiumBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: _copy,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_copied) ...[
                          Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: c.highlightInk,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          _copied ? l10n.copiedButton : l10n.copyButton,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: c.highlightInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// What kind of entry the activity log shows.
enum _EventKind { checkIn, checkOut, started, completed, quality, signoff }

/// One entry of the activity log.
class _Event {
  const _Event({
    required this.kind,
    required this.label,
    required this.title,
    this.at,
    this.detail,
    this.score,
  });

  final _EventKind kind;
  final String label;
  final String title;
  final DateTime? at;
  final String? detail;

  /// 0 to 5, for the quality entry's stars.
  final num? score;
}

/// What happened on site, in order: each check-in and check-out, the start
/// and the finish, the quality score with the crew's notes, and the client's
/// sign-off. Each entry hangs off a rail with its own mark.
class _ActivityLog extends StatelessWidget {
  const _ActivityLog({required this.events});

  final List<_Event> events;

  static List<_Event> eventsOf(BuildContext context, Job job) {
    final l10n = AppLocalizations.of(context);
    final events = <_Event>[
      for (final a in job.assignees) ...[
        if (a.checkInTime case final t?)
          _Event(
            kind: _EventKind.checkIn,
            label: l10n.eventCheckedIn,
            title: a.name,
            at: t,
            detail: a.roleOnJob,
          ),
        if (a.checkOutTime case final t?)
          _Event(
            kind: _EventKind.checkOut,
            label: l10n.eventCheckedOut,
            title: a.name,
            at: t,
            detail: a.roleOnJob,
          ),
      ],
      if (job.actualStart != null || job.startedByName != null)
        _Event(
          kind: _EventKind.started,
          label: l10n.jobStartedLabel,
          title: job.startedByName ?? l10n.jobStartedLabel,
          at: job.actualStart,
        ),
      if (job.actualEnd != null || job.completedByName != null)
        _Event(
          kind: _EventKind.completed,
          label: l10n.eventWorkCompleted,
          title: job.completedByName ?? l10n.eventWorkCompleted,
          at: job.actualEnd,
        ),
      if (job.qualityScore != null ||
          (job.cleanerNotes?.trim().isNotEmpty ?? false))
        _Event(
          kind: _EventKind.quality,
          label: job.qualityScore == null
              ? l10n.cleanerNotesLabel
              : l10n.qualityScoreLabel,
          title: switch (job.qualityScore) {
            final s? => l10n.qualityScoreValue(context.formatNumber('$s')),
            null => job.completedByName ?? '',
          },
          // Given when it was completed.
          at: job.actualEnd?.add(const Duration(microseconds: 1)),
          detail: job.cleanerNotes?.trim(),
          score: job.qualityScore,
        ),
      if (job.clientSignoffName?.trim() case final name? when name.isNotEmpty)
        _Event(
          kind: _EventKind.signoff,
          label: l10n.clientSignoffLabel,
          title: name,
          at: job.clientSignoffAt ?? job.actualEnd,
        ),
    ];
    // In time order; entries without a time keep their place at the end.
    final timed = [
      for (final e in events)
        if (e.at != null) e,
    ]..sort((a, b) => a.at!.compareTo(b.at!));
    return [
      ...timed,
      for (final e in events)
        if (e.at == null) e,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return SpaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    l10n.activityTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.activityCount(events.length),
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final (i, e) in events.indexed)
            _EventTile(event: e, last: i == events.length - 1),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event, required this.last});

  final _Event event;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.colors;
    final e = event;
    final (IconData icon, Color mark, Color markInk) = switch (e.kind) {
      _EventKind.checkIn => (Icons.login_rounded, c.accentSoft, c.accent),
      _EventKind.checkOut => (Icons.logout_rounded, c.accentSoft, c.accent),
      _EventKind.started => (Icons.play_arrow_rounded, c.accentSoft, c.accent),
      _EventKind.completed => (Icons.check_rounded, c.success, c.surface),
      _EventKind.quality => (
        Icons.star_rounded,
        c.highlightSoft,
        c.highlightInk,
      ),
      _EventKind.signoff => (Icons.draw_outlined, c.accentSoft, c.accent),
    };
    final quality = e.kind == _EventKind.quality;
    final time = switch (e.at) {
      final t? => context.formatTime(t),
      null => null,
    };

    return MergeSemantics(
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The rail: this entry's mark, and the line down to the next.
            SizedBox(
              width: 28,
              child: Column(
                children: [
                  const SizedBox(height: 14),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: mark,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 15, color: markInk),
                  ),
                  if (!last)
                    Expanded(child: Container(width: 2, color: c.line)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: last ? 0 : 10),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 12, 14),
                  decoration: BoxDecoration(
                    color: quality ? c.highlightSoft : c.sunken,
                    borderRadius: BorderRadius.circular(SpaceRadius.inner),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              e.label,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: quality ? c.highlightInk : c.inkMuted,
                              ),
                            ),
                          ),
                          if (quality && e.score != null)
                            _Stars(score: e.score!)
                          else if (time != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: c.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: c.line),
                              ),
                              child: Text(
                                time,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: c.ink,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        e.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (e.detail case final d? when d.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          quality ? '“$d”' : d,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontStyle: quality ? FontStyle.italic : null,
                            color: quality ? c.ink : null,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Five stars for a 0–5 score, halves included. The score itself is in
/// the entry's text, so these are left out of what screen readers say.
class _Stars extends StatelessWidget {
  const _Stars({required this.score});

  final num score;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final halves = (score * 2).round();
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 5; i++)
            Icon(
              halves >= (i + 1) * 2
                  ? Icons.star_rounded
                  : halves == i * 2 + 1
                  ? Icons.star_half_rounded
                  : Icons.star_outline_rounded,
              size: 18,
              color: c.highlight,
            ),
        ],
      ),
    );
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
