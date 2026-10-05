import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../clients/presentation/screens/accounts_screen.dart';
import '../../../jobs/presentation/controllers/jobs_providers.dart';
import '../../../locations/domain/entities/location.dart';
import '../../../locations/presentation/controllers/locations_providers.dart';
import '../../../scopes/domain/entities/scope.dart';
import '../../../scopes/domain/usecases/scope_usecases.dart';
import '../../../scopes/presentation/controllers/scopes_providers.dart';
import '../../../scopes/presentation/widgets/scope_labels.dart';
import '../../../team/domain/entities/member.dart';
import '../../../team/presentation/controllers/team_providers.dart';
import '../../di/calendar_providers.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/usecases/calendar_usecases.dart';
import '../controllers/calendar_providers.dart';
import 'calendar_screen.dart';

/// A one-off event ([eventId] null), on the day picked on the calendar, or
/// an edit of any event. An edit keeps the day and start time: moving goes
/// through Reschedule, which keeps the history. Needs `calendar.edit`.
class EventFormScreen extends ConsumerWidget {
  const EventFormScreen({super.key, required this.clientId, this.eventId});

  final String clientId;
  final String? eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final id = eventId;
    if (id == null) return _EventForm(clientId: clientId);
    // Wait for the event before building fields.
    return switch (ref.watch(eventProvider((clientId, id)))) {
      AsyncValue(value: final event?) => _EventForm(
        key: ValueKey(id),
        clientId: clientId,
        initial: event,
      ),
      final other => SpacePage(
        title: l10n.editEvent,
        slivers: [
          AsyncSlivers<CalendarEvent>(
            value: other,
            onRetry: () => ref.invalidate(eventProvider((clientId, id))),
            builder: (_) => const SliverToBoxAdapter(),
          ),
        ],
      ),
    };
  }
}

class _EventForm extends ConsumerStatefulWidget {
  const _EventForm({super.key, required this.clientId, this.initial});

  final String clientId;

  /// The event edited; null to create.
  final CalendarEvent? initial;

  @override
  ConsumerState<_EventForm> createState() => _EventFormState();
}

class _EventFormState extends ConsumerState<_EventForm> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.initial?.title);
  late final _notes = TextEditingController(text: widget.initial?.notes);
  late DateTime _date =
      widget.initial?.date ??
      ref.read(calendarDayProvider(widget.clientId)) ??
      () {
        final now = ref.read(clockProvider)();
        return DateTime(now.year, now.month, now.day);
      }();
  late ClockTime _start = widget.initial?.startTime ?? const ClockTime(8, 0);
  late ClockTime? _end = widget.initial?.endTime;
  late String? _locationId = widget.initial?.locationId;
  late String? _scopeId = widget.initial?.scopeId;
  late String? _assignedToId = widget.initial?.assignedToId;

  bool _saving = false;
  bool _tried = false;
  Failure? _failure;

  /// Why a picker had nothing to offer.
  String? _pickerNote;

  bool get _creating => widget.initial == null;

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  String? get _endError => switch (_end) {
    final end? when _tried && end.compareTo(_start) <= 0 => AppLocalizations.of(
      context,
    ).endBeforeStart,
    _ => null,
  };

  /// Shows a server-side error for [field] first, then the [local] rule.
  FormFieldValidator<String> _validator(
    String field, [
    String? Function(String value)? local,
  ]) => (value) {
    if (_failure case ValidationFailure(:final fieldErrors)) {
      if (fieldErrors[field] case final errors? when errors.isNotEmpty) {
        return AppLocalizations.of(context).fieldError(errors.first);
      }
    }
    return local?.call(value ?? '');
  };

  /// Waits for [list] (it may still be loading), then offers its items. A
  /// list that can't load (no access to it, offline) says why on top of the
  /// form; an empty one says so.
  Future<void> _pickFrom<T>({
    required String title,
    required Future<List<T>> list,
    required String Function(T item) id,
    required String Function(T item) label,
    required String empty,
    required bool hasValue,
    required void Function(T? item) apply,
  }) async {
    final List<T> items;
    try {
      items = await list;
    } on Failure catch (f) {
      if (mounted) setState(() => _failure = f);
      return;
    }
    if (!mounted) return;
    setState(() {
      _pickerNote = items.isEmpty && !hasValue ? empty : null;
      if (_failure is! ValidationFailure) _failure = null;
    });
    if (items.isEmpty && !hasValue) return;
    final picked = await showAppChoice(
      context,
      title: title,
      allowClear: hasValue,
      options: {for (final item in items) id(item): label(item)},
    );
    if (picked == null || !mounted) return;
    setState(
      () => apply(
        picked.isEmpty ? null : items.where((i) => id(i) == picked).firstOrNull,
      ),
    );
  }

  Future<ClockTime?> _pickTime(ClockTime initial) async {
    final picked = await showAppTimePicker(
      context,
      initial: TimeOfDay(hour: initial.hour, minute: initial.minute),
    );
    return picked == null ? null : ClockTime(picked.hour, picked.minute);
  }

  Future<void> _save() async {
    setState(() {
      _failure = null;
      _tried = true;
    });
    if (!_formKey.currentState!.validate() || _endError != null) {
      HapticFeedback.mediumImpact();
      return;
    }
    setState(() => _saving = true);
    try {
      final saved = await ref.read(saveEventProvider)(
        SaveEventParams(
          clientId: widget.clientId,
          eventId: widget.initial?.id,
          draft: EventDraft(
            title: _title.text,
            date: _creating ? _date : null,
            startTime: _creating ? _start : null,
            endTime: _end,
            locationId: _locationId,
            scopeId: _scopeId,
            assignedToId: _assignedToId,
            notes: _notes.text,
          ),
        ),
      );
      invalidateCalendar(ref);
      if (!mounted) return;
      if (_creating) {
        // The calendar shows the new event's day; the event has its page.
        ref.read(calendarDayProvider(widget.clientId).notifier).select(_date);
        context.go(
          '${AccountsScreen.path}/${widget.clientId}/'
          '${CalendarScreen.route}/${saved.id}',
        );
      } else {
        context.pop();
      }
    } on Failure catch (f) {
      HapticFeedback.mediumImpact();
      if (!mounted) return;
      setState(() => _failure = f);
      // Re-run validators so server field errors appear on their fields.
      _formKey.currentState!.validate();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final side = pageSide(context);
    final initial = widget.initial;
    String time(ClockTime t) => context.formatClock(t.hour, t.minute);

    // Names for what's picked, from the lists once they're here.
    final locations = ref.watch(allLocationsProvider(widget.clientId)).value;
    final scopeQuery = ScopeQuery(clientId: widget.clientId);
    final scopes = ref.watch(scopesProvider(scopeQuery)).value;
    final members = ref.watch(membersProvider(widget.clientId)).value;
    final locationName =
        locations?.where((l) => l.id == _locationId).firstOrNull?.name ??
        (_locationId == initial?.locationId ? initial?.locationName : null);
    final scope = scopes?.where((s) => s.id == _scopeId).firstOrNull;
    final scopeName = switch (scope) {
      final s? => scopeTitle(l10n, s),
      null when _scopeId != null && _scopeId == initial?.scopeId =>
        initial?.scopeArea ?? l10n.scopeWholeSite,
      _ => null,
    };
    final memberName =
        members?.where((m) => m.userId == _assignedToId).firstOrNull?.name ??
        (_assignedToId == initial?.assignedToId
            ? initial?.assignedToName
            : null);

    final failure = _failure;
    return SpacePage(
      title: _creating ? l10n.newEventTitle : l10n.editEvent,
      bottom: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(side, 8, side, 12),
          child: PrimaryButton(
            label: l10n.saveButton,
            busy: _saving,
            onPressed: _save,
          ),
        ),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (failure != null &&
                    (failure is! ValidationFailure ||
                        failure.fieldErrors.isEmpty))
                  Padding(
                    padding: EdgeInsets.fromLTRB(side, 4, side, 4),
                    child: Notice(message: l10n.failureMessage(failure)),
                  ),
                if (_pickerNote case final note?)
                  Padding(
                    padding: EdgeInsets.fromLTRB(side, 4, side, 4),
                    child: Notice(message: note, tone: NoticeTone.info),
                  ),
                FormSection(l10n.sectionGeneral, [
                  SpaceTextField(
                    label: l10n.eventTitleLabel,
                    controller: _title,
                    enabled: !_saving,
                    hint: l10n.eventTitleHint,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    validator: _validator(
                      'title',
                      (v) => switch (v.trim()) {
                        '' => l10n.validationRequired,
                        final t when t.length > 200 => l10n.validationMaxLength(
                          '200',
                        ),
                        _ => null,
                      },
                    ),
                  ),
                ]),
                FormSection(
                  l10n.sectionWhen,
                  [
                    if (_creating) ...[
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
                                if (picked != null) {
                                  setState(() => _date = picked);
                                }
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
                                if (picked != null) {
                                  setState(() => _start = picked);
                                }
                              },
                      ),
                    ],
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
                    if (_end != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: LinkButton(
                          label: l10n.noEndTime,
                          onPressed: _saving
                              ? null
                              : () => setState(() => _end = null),
                        ),
                      ),
                  ],
                  footer: _creating
                      ? null
                      : l10n.eventMoveHelp(
                          context.formatDayLong(_date),
                          time(_start),
                        ),
                ),
                FormSection(l10n.sectionDetails, [
                  PickerField(
                    label: l10n.scopeTitle,
                    value: scopeName,
                    onTap: _saving
                        ? null
                        : () => _pickFrom<Scope>(
                            title: l10n.scopeTitle,
                            list: ref.read(scopesProvider(scopeQuery).future),
                            id: (s) => s.id,
                            label: (s) => [
                              scopeTitle(l10n, s),
                              ?s.locationName,
                            ].join(' · '),
                            empty: l10n.eventNoScopes,
                            hasValue: _scopeId != null,
                            apply: (s) {
                              _scopeId = s?.id;
                              // A scope says where; and names the event if
                              // it has no title yet.
                              if (s == null) return;
                              _locationId ??= s.locationId;
                              if (_title.text.trim().isEmpty) {
                                _title.text = scopeTitle(l10n, s);
                              }
                            },
                          ),
                  ),
                  PickerField(
                    label: l10n.locationLabel,
                    value: locationName,
                    onTap: _saving
                        ? null
                        : () => _pickFrom<Location>(
                            title: l10n.locationLabel,
                            list: ref.read(
                              allLocationsProvider(widget.clientId).future,
                            ),
                            id: (l) => l.id,
                            label: (l) => l.name,
                            empty: l10n.eventNoLocations,
                            hasValue: _locationId != null,
                            apply: (l) => _locationId = l?.id,
                          ),
                  ),
                  PickerField(
                    label: l10n.assignedToLabel,
                    value: memberName,
                    onTap: _saving
                        ? null
                        : () => _pickFrom<Member>(
                            title: l10n.assignedToLabel,
                            list: ref
                                .read(membersProvider(widget.clientId).future)
                                .then(
                                  (all) => [
                                    for (final m in all)
                                      if (m.isActive) m,
                                  ],
                                ),
                            id: (m) => m.userId,
                            label: (m) => m.name,
                            empty: l10n.eventNoMembers,
                            hasValue: _assignedToId != null,
                            apply: (m) => _assignedToId = m?.userId,
                          ),
                  ),
                  SpaceTextField(
                    label: l10n.notesLabel,
                    controller: _notes,
                    enabled: !_saving,
                    textCapitalization: TextCapitalization.sentences,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    maxLines: null,
                    validator: _validator(
                      'notes',
                      (v) => v.trim().length > 2000
                          ? l10n.validationMaxLength('2000')
                          : null,
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
