import 'package:flutter/material.dart';

import '../../../../core/design/design.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../proposals/presentation/widgets/line_item_row.dart';
import '../../domain/entities/job.dart';
import 'job_status_label.dart';

/// One job as a white card with its status color down the left edge: the
/// time big (what crew scan for) with how long it runs and its status, then
/// the title, where it is, and the checklist's progress in the status color.
class JobCard extends StatelessWidget {
  const JobCard({
    super.key,
    required this.job,
    this.accountName,
    required this.onTap,
  });

  final Job job;

  /// Shown when the list mixes accounts.
  final String? accountName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final tone = _JobTone.of(context, job.status);
    final large = isLargeText(context);
    final place = [
      ?accountName,
      if (job.location?.name case final name? when name.isNotEmpty) name,
      if (job.scopeArea case final area? when area.isNotEmpty) area,
    ].join(' • ');

    final time = Text(
      context.formatTimeRange(job.scheduledStart, job.scheduledEnd),
      style: theme.textTheme.headlineSmall?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
    final duration = switch (job.scheduledEnd) {
      final end? when end.isAfter(job.scheduledStart) => _DurationChip(
        duration: end.difference(job.scheduledStart),
        active: job.status == JobStatus.inProgress,
      ),
      _ => null,
    };
    final pill = JobStatusLabel(status: job.status);

    return Semantics(
      button: true,
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(SpaceRadius.card),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (large) ...[
                      Align(alignment: Alignment.centerLeft, child: pill),
                      const SizedBox(height: 10),
                    ],
                    Row(
                      children: [
                        Expanded(child: time),
                        if (!large) ...[const SizedBox(width: 12), pill],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            job.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: colors.sunken,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: colors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                    // Where, with how long it runs at the right (the time
                    // row has no room for it in 12-hour time).
                    if (place.isNotEmpty || duration != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (place.isNotEmpty) ...[
                            Icon(
                              Icons.place_outlined,
                              size: 16,
                              color: colors.inkMuted,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                place,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ] else
                            const Spacer(),
                          if (duration != null) ...[
                            const SizedBox(width: 10),
                            duration,
                          ],
                        ],
                      ),
                    ],
                    if (job.checklistTotal > 0 &&
                        job.status != JobStatus.cancelled) ...[
                      const SizedBox(height: 14),
                      Divider(height: 1, thickness: 1, color: colors.line),
                      const SizedBox(height: 12),
                      _Progress(job: job, tone: tone),
                    ],
                  ],
                ),
              ),
              // The status color down the left edge.
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: ExcludeSemantics(
                  child: SizedBox(
                    width: 5,
                    child: ColoredBox(color: tone.edge),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// How a status colors a card: the left edge, the progress bar, and the
/// progress figure.
class _JobTone {
  const _JobTone({required this.edge, required this.bar, required this.ink});

  final Color edge;
  final Color bar;

  /// The progress figure; dark enough for small text on white.
  final Color ink;

  static _JobTone of(BuildContext context, JobStatus status) {
    final c = context.colors;
    return switch (status) {
      JobStatus.completed => _JobTone(
        edge: c.success,
        bar: c.success,
        ink: c.successInk,
      ),
      JobStatus.inProgress => _JobTone(
        edge: c.primary,
        bar: c.primary,
        ink: c.highlightInk,
      ),
      JobStatus.scheduled => _JobTone(
        edge: c.accentSoft,
        bar: c.accent,
        ink: c.inkMuted,
      ),
      JobStatus.cancelled || JobStatus.unknown => _JobTone(
        edge: c.line,
        bar: c.inkFaint,
        ink: c.inkMuted,
      ),
    };
  }
}

/// "Task completion · 1 of 1 done (100%)" over a bar in the status color.
class _Progress extends StatelessWidget {
  const _Progress({required this.job, required this.tone});

  final Job job;
  final _JobTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final done = job.checklistDone;
    final total = job.checklistTotal;
    final label = switch (job.status) {
      JobStatus.completed => l10n.jobProgressCompleted,
      JobStatus.inProgress => l10n.jobProgressActive,
      _ => l10n.jobChecklist,
    };
    final figure = l10n.checklistProgressPercent(
      done,
      total,
      (done * 100 / total).round(),
    );
    final emphasis =
        job.status == JobStatus.completed || job.status == JobStatus.inProgress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 12,
          runSpacing: 2,
          children: [
            Text(label, style: theme.textTheme.bodyMedium),
            Text(
              figure,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: tone.ink,
                fontWeight: emphasis ? FontWeight.w700 : null,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SpaceProgressBar(
          value: done / total,
          height: 8,
          color: tone.bar,
          semanticsLabel: l10n.jobChecklist,
        ),
      ],
    );
  }
}

/// How long the job is planned for ("3h 58m"); orange while it's running.
class _DurationChip extends StatelessWidget {
  const _DurationChip({required this.duration, required this.active});

  final Duration duration;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final minutes = duration.inMinutes;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: active ? c.highlightSoft : c.sunken,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        l10n.durationHoursMinutes(
          minutes ~/ 60,
          (minutes % 60).toString().padLeft(2, '0'),
        ),
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontFeatures: const [FontFeature.tabularFigures()],
          color: active ? c.highlightInk : c.inkMuted,
        ),
      ),
    );
  }
}
