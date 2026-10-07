import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../access/domain/entities/account_access.dart';
import '../../../access/presentation/controllers/account_access_provider.dart';
import '../../../clients/presentation/controllers/clients_providers.dart';
import '../../domain/entities/job.dart';
import '../../domain/usecases/job_usecases.dart';
import '../controllers/jobs_providers.dart';
import '../widgets/job_row.dart';

/// One account's jobs, a day at a time: Upcoming (from today on) or the past
/// 30 days, each with its count; the picked day's heading and how many jobs
/// it has; a strip of days to pick from (a dot marks days with jobs); and
/// that day's jobs. A status filter narrows them. New ones come from the
/// dock's "+" (`jobs.edit`) or from a calendar event.
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

  /// The day picked on the strip; null picks a sensible one.
  DateTime? _day;

  /// Only jobs with this status; null shows all.
  JobStatus? _status;

  static DateTime _dateOf(DateTime t) => DateTime(t.year, t.month, t.day);

  /// The days the strip offers for a period: from today until the last
  /// upcoming job (at least a week), or the past 30 days up to yesterday.
  static List<DateTime> _days(
    JobPeriod period,
    DateTime today,
    List<Job> jobs,
  ) {
    switch (period) {
      case JobPeriod.upcoming:
        final last = jobs.fold(
          today.add(const Duration(days: 6)),
          (d, j) => _dateOf(j.scheduledStart).isAfter(d)
              ? _dateOf(j.scheduledStart)
              : d,
        );
        return [for (var d = today; !d.isAfter(last); d = _next(d)) d];
      case JobPeriod.past:
        return [
          for (var i = JobQuery.pastDays; i >= 1; i--)
            DateTime(today.year, today.month, today.day - i),
        ];
    }
  }

  static DateTime _next(DateTime d) => DateTime(d.year, d.month, d.day + 1);

  /// Upcoming starts on the first day with work (today if none); past on
  /// the latest day with work (yesterday if none).
  static DateTime _defaultDay(
    JobPeriod period,
    DateTime today,
    List<Job> jobs,
  ) {
    final days = {for (final j in jobs) _dateOf(j.scheduledStart)};
    return switch (period) {
      JobPeriod.upcoming =>
        days.isEmpty ? today : days.reduce((a, b) => a.isBefore(b) ? a : b),
      JobPeriod.past =>
        days.isEmpty
            ? DateTime(today.year, today.month, today.day - 1)
            : days.reduce((a, b) => a.isAfter(b) ? a : b),
    };
  }

  String _statusName(AppLocalizations l10n, JobStatus s) => switch (s) {
    JobStatus.scheduled => l10n.jobStatusScheduled,
    JobStatus.inProgress => l10n.jobStatusInProgress,
    JobStatus.completed => l10n.jobStatusCompleted,
    JobStatus.cancelled => l10n.jobStatusCancelled,
    JobStatus.unknown => l10n.jobStatusUnknown,
  };

  Future<void> _pickStatus() async {
    final l10n = AppLocalizations.of(context);
    final picked = await showAppChoice(
      context,
      title: l10n.jobsFilter,
      allowClear: _status != null,
      options: {
        for (final s in [
          JobStatus.scheduled,
          JobStatus.inProgress,
          JobStatus.completed,
          JobStatus.cancelled,
        ])
          s.name: _statusName(l10n, s),
      },
    );
    if (picked == null || !mounted) return;
    setState(
      () => _status = picked.isEmpty
          ? null
          : JobStatus.values.firstWhere((s) => s.name == picked),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final today = _dateOf(ref.watch(clockProvider)());
    JobQuery query(JobPeriod p) =>
        JobQuery(clientId: widget.clientId, period: p, today: today);
    final upcoming = ref.watch(accountJobsProvider(query(JobPeriod.upcoming)));
    final past = ref.watch(accountJobsProvider(query(JobPeriod.past)));
    final jobs = _period == JobPeriod.upcoming ? upcoming : past;
    final client = ref.watch(clientByIdProvider(widget.clientId)).value;
    final canEdit =
        ref
            .watch(accountAccessProvider(widget.clientId))
            .value
            ?.can(Permissions.jobsEdit) ??
        false;
    final here = GoRouterState.of(context).matchedLocation;
    Future<void> refresh() =>
        ref.refresh(accountJobsProvider(query(_period)).future);
    final status = _status;

    return SpacePage(
      heading: HeroHeadline(
        primary: l10n.moduleJobs,
        secondary: client?.displayName,
      ),
      onRefresh: refresh,
      actions: [
        CircleButton.light(
          icon: Icons.filter_list_rounded,
          tooltip: status == null
              ? l10n.jobsFilter
              : l10n.jobsFilterOn(_statusName(l10n, status)),
          active: status != null,
          onPressed: _pickStatus,
        ),
      ],
      slivers: [
        PageBox(
          top: 4,
          child: PillToggle<JobPeriod>(
            semanticLabel: l10n.jobsPeriodLabel,
            options: {
              JobPeriod.upcoming: l10n.jobsUpcoming,
              JobPeriod.past: l10n.jobsPast,
            },
            counts: {
              if (upcoming.value case final list?)
                JobPeriod.upcoming: list.length,
              if (past.value case final list?) JobPeriod.past: list.length,
            },
            selected: _period,
            onChanged: (v) => setState(() {
              _period = v;
              _day = null;
            }),
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
            final days = _days(_period, today, list);
            final day = switch (_day) {
              final d? when days.contains(d) => d,
              _ => _defaultDay(_period, today, list),
            };
            final onDay = [
              for (final j in list)
                if (_dateOf(j.scheduledStart) == day) j,
            ];
            final shown = [
              for (final j in onDay)
                if (status == null || j.status == status) j,
            ];
            final busyDays = {for (final j in list) _dateOf(j.scheduledStart)};

            return SliverMainAxisGroup(
              slivers: [
                PageBox(
                  top: 20,
                  child: _DayHeading(
                    day: day,
                    count: onDay.length,
                    onToday: _period == JobPeriod.upcoming && day != today
                        ? () => setState(() => _day = today)
                        : null,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _DayStrip(
                      // A new strip (and scroll position) per period.
                      key: ValueKey(_period),
                      days: days,
                      selected: day,
                      today: today,
                      busyDays: busyDays,
                      onSelect: (d) {
                        HapticFeedback.selectionClick();
                        setState(() => _day = d);
                      },
                    ),
                  ),
                ),
                if (shown.isEmpty)
                  MessageSliver(
                    icon: status == null
                        ? Icons.event_available_outlined
                        : Icons.filter_list_off_rounded,
                    title: status == null
                        ? l10n.noJobsOnDay
                        : l10n.noJobsMatchFilter,
                  )
                else
                  PageSliver(
                    top: 16,
                    sliver: SliverList.separated(
                      itemCount: shown.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => JobCard(
                        job: shown[i],
                        onTap: () => context.push('$here/${shown[i].id}'),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// "Wednesday, October 7" over how many jobs it has, with "Today" at the
/// right when another day is picked.
class _DayHeading extends StatelessWidget {
  const _DayHeading({required this.day, required this.count, this.onToday});

  final DateTime day;
  final int count;
  final VoidCallback? onToday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  context.formatDayLong(day),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(l10n.jobsOnDay(count), style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
        if (onToday != null) ...[
          const SizedBox(width: 8),
          LinkButton(label: l10n.todayTitle, onPressed: onToday),
        ],
      ],
    );
  }
}

/// The days to pick from, scrolled so the picked one shows. Each shows its
/// weekday and date; the picked one is orange with a ring, today is
/// outlined, and a dot marks days with jobs.
class _DayStrip extends StatefulWidget {
  const _DayStrip({
    super.key,
    required this.days,
    required this.selected,
    required this.today,
    required this.busyDays,
    required this.onSelect,
  });

  final List<DateTime> days;
  final DateTime selected;
  final DateTime today;
  final Set<DateTime> busyDays;
  final ValueChanged<DateTime> onSelect;

  @override
  State<_DayStrip> createState() => _DayStripState();
}

class _DayStripState extends State<_DayStrip> {
  static const _cell = 60.0;
  static const _gap = 8.0;

  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    // The picked day second from the left, so the day before shows too.
    final index = widget.days.indexOf(widget.selected);
    _scroll = ScrollController(
      initialScrollOffset: math.max(0, (index - 1) * (_cell + _gap)),
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final side = pageSide(context);
    // Grows with the text size, up to half again; the cells' text shrinks
    // to fit past that.
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.5);
    return SizedBox(
      height: 84 * scale,
      child: ListView.separated(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: side - 4, vertical: 4),
        itemCount: widget.days.length,
        separatorBuilder: (_, _) => const SizedBox(width: _gap),
        itemBuilder: (context, i) {
          final day = widget.days[i];
          return _DayCell(
            day: day,
            width: _cell * scale,
            selected: day == widget.selected,
            today: day == widget.today,
            busy: widget.busyDays.contains(day),
            onTap: () => widget.onSelect(day),
          );
        },
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.width,
    required this.selected,
    required this.today,
    required this.busy,
    required this.onTap,
  });

  final DateTime day;
  final double width;
  final bool selected;
  final bool today;

  /// Has jobs.
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context);
    final ink = selected ? c.onPrimary : c.ink;
    final weekday = context.formatWeekdayShort(day.weekday).toUpperCase();
    return Semantics(
      button: true,
      selected: selected,
      label: [
        context.formatDayLong(day),
        if (today) l10n.todayTitle,
        if (busy) l10n.dayHasJobs,
      ].join(', '),
      excludeSemantics: true,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          // The ring around the picked day.
          border: Border.all(
            color: selected ? c.primary : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(SpaceRadius.inner + 4),
        ),
        child: Material(
          color: selected ? c.primary : c.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SpaceRadius.inner),
            side: today && !selected
                ? BorderSide(color: c.inkSoft)
                : BorderSide.none,
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: selected ? null : onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      weekday,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: selected ? c.onPrimary : c.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      day.day.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: !busy
                            ? Colors.transparent
                            : selected
                            ? c.onPrimary
                            : c.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
