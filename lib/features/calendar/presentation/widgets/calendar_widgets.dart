import 'package:flutter/material.dart';

import '../../../../core/design/design.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../scopes/domain/entities/scope.dart';
import '../../domain/entities/calendar_event.dart';

extension CalendarEventStatusNames on AppLocalizations {
  String eventStatus(CalendarEventStatus s) => switch (s) {
    CalendarEventStatus.scheduled => eventStatusScheduled,
    CalendarEventStatus.rescheduled => eventStatusRescheduled,
    CalendarEventStatus.cancelled => eventStatusCancelled,
    CalendarEventStatus.converted => eventStatusConverted,
    CalendarEventStatus.unknown => eventStatusUnknown,
  };
}

/// "7:00 AM – 8:00 AM", or the start alone.
String eventTimes(BuildContext context, CalendarEvent e) {
  String time(ClockTime t) => context.formatClock(t.hour, t.minute);
  return switch (e.endTime) {
    final end? => '${time(e.startTime)} – ${time(end)}',
    null => time(e.startTime),
  };
}

/// The status as a pill with an icon. Scheduled is the norm, so it has
/// none ([forScheduled] shows it anyway, for the event's own page).
class EventStatusLabel extends StatelessWidget {
  const EventStatusLabel({
    super.key,
    required this.status,
    this.forScheduled = false,
  });

  final CalendarEventStatus status;
  final bool forScheduled;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final style = switch (status) {
      CalendarEventStatus.scheduled when !forScheduled => null,
      CalendarEventStatus.scheduled => (
        Icons.event_available_outlined,
        c.accent,
        c.accentSoft,
      ),
      CalendarEventStatus.rescheduled => (
        Icons.update_rounded,
        c.highlightInk,
        c.highlightSoft,
      ),
      CalendarEventStatus.cancelled => (
        Icons.block_rounded,
        c.danger,
        c.dangerSoft,
      ),
      CalendarEventStatus.converted => (
        Icons.cleaning_services_outlined,
        c.successInk,
        c.successSoft,
      ),
      CalendarEventStatus.unknown => (
        Icons.help_outline_rounded,
        c.inkMuted,
        c.sunken,
      ),
    };
    if (style == null) return const SizedBox.shrink();
    final (icon, color, background) = style;
    return StatusPill(
      label: AppLocalizations.of(context).eventStatus(status),
      icon: icon,
      color: color,
      background: background,
    );
  }
}

/// An event as a list row: its title, when, and where; the status as a
/// pill unless it's simply scheduled.
class EventRow extends StatelessWidget {
  const EventRow({super.key, required this.event, this.onTap});

  final CalendarEvent event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final e = event;
    return ListRow(
      leading: IconBadge(
        icon: e.isGenerated ? Icons.repeat_rounded : Icons.event_outlined,
      ),
      title: e.title,
      subtitle: [eventTimes(context, e), ?e.locationName].join(' · '),
      muted: e.isCancelled,
      tag: e.status == CalendarEventStatus.scheduled
          ? null
          : EventStatusLabel(status: e.status),
      onTap: onTap,
    );
  }
}

/// A month as a Monday-first grid of days. A dot marks days with events
/// that aren't cancelled; [selected] is filled and today is outlined.
class MonthGrid extends StatelessWidget {
  const MonthGrid({
    super.key,
    required this.year,
    required this.month,
    required this.selected,
    required this.today,
    required this.counts,
    required this.onSelect,
  });

  final int year;
  final int month;
  final DateTime selected;
  final DateTime today;

  /// Events that aren't cancelled, per day of the month.
  final Map<int, int> counts;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final first = DateTime(year, month);
    final days = DateTime(year, month + 1, 0).day;
    // Blank cells before the 1st, Monday first.
    final lead = first.weekday - 1;
    final cells = lead + days;
    final rows = (cells / 7).ceil();
    // The day's circle grows with the text, but seven still fit a phone.
    final circle = MediaQuery.textScalerOf(context).scale(30).clamp(34.0, 42.0);

    Widget day(int d) {
      final date = DateTime(year, month, d);
      final isSelected = DateUtils.isSameDay(date, selected);
      final isToday = DateUtils.isSameDay(date, today);
      final count = counts[d] ?? 0;
      final c = context.colors;
      return Semantics(
        button: true,
        selected: isSelected,
        label: [
          context.formatDayLong(date),
          l10n.eventsCount(count),
        ].join(', '),
        excludeSemantics: true,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => onSelect(date),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 46),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: circle,
                  height: circle,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? c.primary : null,
                    border: isToday && !isSelected
                        ? Border.all(color: c.accent, width: 1.5)
                        : null,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$d',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: isToday || isSelected
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: isSelected ? c.onPrimary : c.ink,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: count > 0 ? c.accent : Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Weekday initials, Monday first.
        ExcludeSemantics(
          child: Row(
            children: [
              for (var d = 1; d <= 7; d++)
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      context.formatWeekdayShort(d),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: context.colors.inkMuted,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        for (var r = 0; r < rows; r++)
          Row(
            children: [
              for (var col = 0; col < 7; col++)
                Expanded(
                  child: switch (r * 7 + col - lead + 1) {
                    final d when d >= 1 && d <= days => day(d),
                    _ => const SizedBox(height: 46),
                  },
                ),
            ],
          ),
      ],
    );
  }
}
