import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../access/domain/entities/account_access.dart';
import '../../../access/presentation/controllers/account_access_provider.dart';
import '../../../jobs/presentation/controllers/jobs_providers.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/usecases/calendar_usecases.dart';
import '../controllers/calendar_providers.dart';
import '../widgets/calendar_widgets.dart';

/// One client account's calendar: a month grid with a dot on each day that
/// has events, and the picked day's events below it. With `calendar.edit`,
/// opening a month first fills it from the scopes' time windows; one-off
/// events come from the dock's "+".
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key, required this.clientId});

  /// Path segment under `/accounts/:clientId`.
  static const route = 'calendar';

  final String clientId;

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  /// The first day of the month shown; the picked day's month to start.
  late DateTime _month = () {
    final day = _selected;
    return DateTime(day.year, day.month);
  }();

  DateTime get _today {
    final now = ref.read(clockProvider)();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime get _selected =>
      ref.read(calendarDayProvider(widget.clientId)) ?? _today;

  void _select(DateTime day) =>
      ref.read(calendarDayProvider(widget.clientId).notifier).select(day);

  /// Shows [month], picking today if it's in it, else its 1st.
  void _showMonth(DateTime month) {
    final today = _today;
    setState(() => _month = DateTime(month.year, month.month));
    _select(
      today.year == month.year && today.month == month.month
          ? today
          : DateTime(month.year, month.month),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final clientId = widget.clientId;
    final access = ref.watch(accountAccessProvider(clientId));
    final canEdit = access.value?.can(Permissions.calendarEdit) ?? false;
    final today = _today;
    final selected = ref.watch(calendarDayProvider(clientId)) ?? today;
    // Wait for the access first, so a month isn't loaded twice (without and
    // then with filling it).
    final query = access.hasValue
        ? MonthQuery(
            clientId: clientId,
            year: _month.year,
            month: _month.month,
            generate: canEdit,
          )
        : null;
    final events = query == null
        ? const AsyncValue<List<CalendarEvent>>.loading()
        : ref.watch(monthEventsProvider(query));
    final counts = <int, int>{};
    for (final e in events.value ?? const <CalendarEvent>[]) {
      if (!e.isCancelled) {
        counts.update(e.date.day, (n) => n + 1, ifAbsent: () => 1);
      }
    }
    final here = GoRouterState.of(context).matchedLocation;
    Future<void> refresh() => query == null
        ? Future.value()
        : ref.refresh(monthEventsProvider(query).future);

    final showsToday = _month.year == today.year && _month.month == today.month;

    return SpacePage(
      title: l10n.moduleCalendar,
      onRefresh: refresh,
      actions: [
        if (!showsToday || !DateUtils.isSameDay(selected, today))
          CircleButton.light(
            icon: Icons.today_rounded,
            tooltip: l10n.goToToday,
            onPressed: () => _showMonth(today),
          ),
      ],
      slivers: [
        PageBox(
          top: 4,
          child: SpaceCard(
            child: Column(
              children: [
                Row(
                  children: [
                    CircleButton.light(
                      icon: Icons.chevron_left_rounded,
                      tooltip: l10n.previousMonth,
                      onPressed: () =>
                          _showMonth(DateTime(_month.year, _month.month - 1)),
                    ),
                    Expanded(
                      child: Text(
                        context.formatMonthYear(_month),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    CircleButton.light(
                      icon: Icons.chevron_right_rounded,
                      tooltip: l10n.nextMonth,
                      onPressed: () =>
                          _showMonth(DateTime(_month.year, _month.month + 1)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                MonthGrid(
                  year: _month.year,
                  month: _month.month,
                  selected: selected,
                  today: today,
                  counts: counts,
                  onSelect: _select,
                ),
              ],
            ),
          ),
        ),
        PageBox(
          top: 20,
          child: SectionHeader(title: context.formatDayLong(selected)),
        ),
        AsyncSlivers(
          value: events,
          onRetry: refresh,
          builder: (list) {
            final onDay = [
              for (final e in list)
                if (DateUtils.isSameDay(e.date, selected)) e,
            ];
            if (onDay.isEmpty) {
              return MessageSliver(
                icon: Icons.event_available_outlined,
                title: l10n.nothingScheduled,
                hint: canEdit ? l10n.nothingScheduledHint : null,
              );
            }
            return PageBox(
              top: 0,
              child: ListCard(
                children: [
                  for (final e in onDay)
                    EventRow(
                      event: e,
                      onTap: () => context.push('$here/${e.id}'),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
