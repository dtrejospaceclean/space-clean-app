import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../scopes/domain/entities/scope.dart';
import '../../di/calendar_providers.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/usecases/calendar_usecases.dart';
import '../controllers/calendar_providers.dart';
import '../widgets/calendar_widgets.dart';

/// Moves an event to another day or time, with an optional reason. The
/// old date and time stay in its history. Needs `calendar.edit`.
class RescheduleEventScreen extends ConsumerWidget {
  const RescheduleEventScreen({
    super.key,
    required this.clientId,
    required this.eventId,
  });

  final String clientId;
  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final key = (clientId, eventId);
    return switch (ref.watch(eventProvider(key))) {
      AsyncValue(value: final event?) => _RescheduleForm(
        key: ValueKey(eventId),
        clientId: clientId,
        event: event,
      ),
      final other => SpacePage(
        title: l10n.rescheduleEvent,
        slivers: [
          AsyncSlivers<CalendarEvent>(
            value: other,
            skeleton: SkeletonLayout.form,
            onRetry: () => ref.invalidate(eventProvider(key)),
            builder: (_) => const SliverToBoxAdapter(),
          ),
        ],
      ),
    };
  }
}

class _RescheduleForm extends ConsumerStatefulWidget {
  const _RescheduleForm({
    super.key,
    required this.clientId,
    required this.event,
  });

  final String clientId;
  final CalendarEvent event;

  @override
  ConsumerState<_RescheduleForm> createState() => _RescheduleFormState();
}

class _RescheduleFormState extends ConsumerState<_RescheduleForm> {
  late DateTime _date = widget.event.date;
  late ClockTime _start = widget.event.startTime;
  late ClockTime? _end = widget.event.endTime;
  final _reason = TextEditingController();
  bool _saving = false;
  bool _tried = false;
  Failure? _failure;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

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

  /// Moves the start, and the end with it so the visit keeps its length.
  void _moveStart(ClockTime start) {
    final end = _end;
    setState(() {
      if (end != null) {
        final minutes = start.minutes + end.minutes - _start.minutes;
        _end = minutes < 24 * 60
            ? ClockTime(minutes ~/ 60, minutes % 60)
            : null;
      }
      _start = start;
    });
  }

  Future<void> _save() async {
    setState(() {
      _failure = null;
      _tried = true;
    });
    if (_endError != null) {
      HapticFeedback.mediumImpact();
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(rescheduleEventProvider)(
        RescheduleEventParams(
          clientId: widget.clientId,
          eventId: widget.event.id,
          draft: RescheduleDraft(
            date: _date,
            startTime: _start,
            endTime: _end,
            reason: _reason.text,
          ),
        ),
      );
      invalidateCalendar(ref);
      // The calendar follows the event to its new day.
      ref.read(calendarDayProvider(widget.clientId).notifier).select(_date);
      if (mounted) context.pop();
    } on Failure catch (f) {
      HapticFeedback.mediumImpact();
      if (mounted) setState(() => _failure = f);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final side = pageSide(context);
    final failure = _failure;
    String time(ClockTime t) => context.formatClock(t.hour, t.minute);

    return SpacePage(
      title: l10n.rescheduleEvent,
      bottom: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(side, 8, side, 12),
          child: PrimaryButton(
            label: l10n.rescheduleEvent,
            icon: Icons.update_rounded,
            busy: _saving,
            onPressed: _save,
          ),
        ),
      ),
      slivers: [
        if (failure != null)
          PageBox(top: 4, child: Notice(message: l10n.failureMessage(failure))),
        PageBox(
          top: 4,
          child: ListCard(children: [EventRow(event: widget.event)]),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FormSection(l10n.sectionNewTime, [
                PickerField(
                  label: l10n.eventDateLabel,
                  icon: Icons.calendar_today_outlined,
                  value: context.formatDayLong(_date),
                  onTap: _saving
                      ? null
                      : () async {
                          final picked = await showAppDatePicker(
                            context,
                            initial: _date,
                          );
                          if (picked != null) setState(() => _date = picked);
                        },
                ),
                PickerField(
                  label: l10n.startTimeLabel,
                  icon: Icons.schedule_rounded,
                  value: time(_start),
                  onTap: _saving
                      ? null
                      : () async {
                          final picked = await _pickTime(_start);
                          if (picked != null) _moveStart(picked);
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
                  onTap: _saving
                      ? null
                      : () async {
                          final picked = await _pickTime(
                            _end ??
                                ClockTime(
                                  (_start.hour + 1) % 24,
                                  _start.minute,
                                ),
                          );
                          if (picked != null) setState(() => _end = picked);
                        },
                ),
                SpaceTextField(
                  label: l10n.rescheduleReasonLabel,
                  controller: _reason,
                  enabled: !_saving,
                  hint: l10n.rescheduleReasonHint,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: null,
                  // The API keeps up to 500 characters.
                  inputFormatters: [LengthLimitingTextInputFormatter(500)],
                ),
              ], footer: l10n.rescheduleHelp),
            ],
          ),
        ),
      ],
    );
  }
}
