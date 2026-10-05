import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/scope.dart';

/// What the scope form hands the time window page: the window to edit
/// (null for a new one) and whether its frequency names weekdays.
class TimeWindowArgs {
  const TimeWindowArgs({this.window, this.needsDays = false});

  final ScopeSchedule? window;
  final bool needsDays;
}

/// What the time window page hands back: the window as edited, or null
/// [window] to remove it.
class TimeWindowResult {
  const TimeWindowResult(this.window);

  final ScopeSchedule? window;
}

/// Adds a time window to the scope being edited or changes one: its
/// weekdays (weekly and biweekly work), start and optional end, and
/// whether it's running. Nothing is saved here: "Done" hands it back to
/// the form, whose Save sends the whole scope.
class TimeWindowScreen extends StatefulWidget {
  const TimeWindowScreen({super.key, required this.args});

  /// Path segment under a scope form.
  static const route = 'window';

  final TimeWindowArgs args;

  @override
  State<TimeWindowScreen> createState() => _TimeWindowScreenState();
}

class _TimeWindowScreenState extends State<TimeWindowScreen> {
  late final ScopeSchedule? _initial = widget.args.window;
  late final Set<int> _days = {...?_initial?.daysOfWeek};
  late ClockTime _start = _initial?.startTime ?? const ClockTime(8, 0);
  late ClockTime? _end = _initial?.endTime;
  late bool _active = _initial?.isActive ?? true;

  /// Errors show only after a first "Done".
  bool _tried = false;

  String? get _daysError => _tried && widget.args.needsDays && _days.isEmpty
      ? AppLocalizations.of(context).pickWeekdays
      : null;

  String? get _endError => switch (_end) {
    final end? when _tried && end.compareTo(_start) <= 0 => AppLocalizations.of(
      context,
    ).endBeforeStart,
    _ => null,
  };

  Future<ClockTime?> _pickTime(ClockTime initial) async {
    final picked = await showAppTimePicker(
      context,
      initial: TimeOfDay(hour: initial.hour, minute: initial.minute),
    );
    return picked == null ? null : ClockTime(picked.hour, picked.minute);
  }

  void _done() {
    setState(() => _tried = true);
    if (_daysError != null || _endError != null) {
      HapticFeedback.mediumImpact();
      return;
    }
    context.pop(
      TimeWindowResult(
        ScopeSchedule(
          daysOfWeek: widget.args.needsDays ? (_days.toList()..sort()) : [],
          startTime: _start,
          endTime: _end,
          isActive: _active,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final side = pageSide(context);
    String time(ClockTime t) => context.formatClock(t.hour, t.minute);
    final daysError = _daysError;

    return SpacePage(
      title: _initial == null ? l10n.addTimeWindow : l10n.editTimeWindow,
      bottom: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(side, 8, side, 12),
          child: PrimaryButton(label: l10n.doneButton, onPressed: _done),
        ),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.args.needsDays)
                FormSection(l10n.weekdaysLabel, [
                  ChoicePills<int>(
                    options: {
                      for (var d = 1; d <= 7; d++)
                        d: context.formatWeekdayShort(d),
                    },
                    selected: _days,
                    onToggle: (d) => setState(
                      () => _days.contains(d) ? _days.remove(d) : _days.add(d),
                    ),
                  ),
                  if (daysError != null)
                    Text(
                      daysError,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: context.colors.danger,
                      ),
                    ),
                ]),
              FormSection(l10n.sectionHours, [
                PickerField(
                  label: l10n.startTimeLabel,
                  icon: Icons.schedule_rounded,
                  value: time(_start),
                  onTap: () async {
                    final picked = await _pickTime(_start);
                    if (picked != null) setState(() => _start = picked);
                  },
                ),
                PickerField(
                  label: l10n.endTimeLabel,
                  icon: Icons.schedule_rounded,
                  value: switch (_end) {
                    final end? => time(end),
                    null => null,
                  },
                  errorText: _endError,
                  onTap: () async {
                    // An hour after the start, unless one is set already.
                    final picked = await _pickTime(
                      _end ?? ClockTime((_start.hour + 1) % 24, _start.minute),
                    );
                    if (picked != null) setState(() => _end = picked);
                  },
                ),
                if (_end != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: LinkButton(
                      label: l10n.noEndTime,
                      onPressed: () => setState(() => _end = null),
                    ),
                  ),
                SwitchRow(
                  label: l10n.timeWindowActiveLabel,
                  value: _active,
                  onChanged: (v) => setState(() => _active = v),
                ),
              ], footer: l10n.timeWindowActiveHelp),
              // Only a window already on the scope can be taken off it.
              if (_initial != null)
                Padding(
                  padding: EdgeInsets.fromLTRB(side, 24, side, 0),
                  child: SecondaryButton(
                    label: l10n.removeTimeWindow,
                    icon: Icons.delete_outline_rounded,
                    destructive: true,
                    onPressed: () => context.pop(const TimeWindowResult(null)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
