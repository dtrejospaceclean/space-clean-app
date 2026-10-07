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
import '../../../locations/domain/entities/location.dart';
import '../../../locations/presentation/controllers/locations_providers.dart';
import '../../../scopes/domain/entities/scope.dart';
import '../../../scopes/domain/usecases/scope_usecases.dart';
import '../../../scopes/presentation/controllers/scopes_providers.dart';
import '../../../scopes/presentation/widgets/scope_labels.dart';
import '../../di/jobs_providers.dart';
import '../../domain/entities/job.dart';
import '../../domain/usecases/job_usecases.dart';
import '../controllers/jobs_providers.dart';
import 'account_jobs_screen.dart';

/// A new job ([jobId] null) or an edit of an open one: what, where (a
/// location, and optionally the scope it's for) and when. An end before the
/// start runs into the next day, for night work. Crew and checklist are
/// set on the job's page. Needs `jobs.edit`.
class JobFormScreen extends ConsumerWidget {
  const JobFormScreen({super.key, required this.clientId, this.jobId});

  final String clientId;
  final String? jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final id = jobId;
    if (id == null) return _JobForm(clientId: clientId);
    // Wait for the job before building fields.
    return switch (ref.watch(jobProvider((clientId, id)))) {
      AsyncValue(value: final job?) => _JobForm(
        key: ValueKey(id),
        clientId: clientId,
        initial: job,
      ),
      final other => SpacePage(
        title: l10n.editJob,
        slivers: [
          AsyncSlivers<Job>(
            value: other,
            onRetry: () => ref.invalidate(jobProvider((clientId, id))),
            builder: (_) => const SliverToBoxAdapter(),
          ),
        ],
      ),
    };
  }
}

class _JobForm extends ConsumerStatefulWidget {
  const _JobForm({super.key, required this.clientId, this.initial});

  final String clientId;

  /// The job edited; null to create.
  final Job? initial;

  @override
  ConsumerState<_JobForm> createState() => _JobFormState();
}

/// The fields whose server errors show on a text field; the rest show on
/// top of the form.
const _textFields = {'title', 'instructions'};

class _JobFormState extends ConsumerState<_JobForm> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.initial?.title);
  late final _instructions = TextEditingController(
    text: widget.initial?.instructions,
  );
  late DateTime _date = switch (widget.initial?.scheduledStart) {
    final s? => DateTime(s.year, s.month, s.day),
    null => () {
      final now = ref.read(clockProvider)();
      return DateTime(now.year, now.month, now.day);
    }(),
  };
  late ClockTime _start = switch (widget.initial?.scheduledStart) {
    final s? => ClockTime(s.hour, s.minute),
    null => const ClockTime(8, 0),
  };
  late ClockTime? _end = switch (widget.initial?.scheduledEnd) {
    final e? => ClockTime(e.hour, e.minute),
    null => null,
  };
  late String? _locationId = widget.initial?.locationId;
  late String? _scopeId = widget.initial?.scopeId;

  bool _saving = false;
  bool _tried = false;
  Failure? _failure;

  /// Why a picker had nothing to offer.
  String? _pickerNote;

  bool get _creating => widget.initial == null;

  @override
  void dispose() {
    _title.dispose();
    _instructions.dispose();
    super.dispose();
  }

  /// An end at the start would make an empty job.
  String? get _endError => switch (_end) {
    final end? when _tried && end == _start => AppLocalizations.of(
      context,
    ).endBeforeStart,
    _ => null,
  };

  /// An end before the start is on the next day.
  bool get _endsNextDay => switch (_end) {
    final end? => end.compareTo(_start) < 0,
    null => false,
  };

  DateTime _at(ClockTime t, {bool nextDay = false}) => DateTime(
    _date.year,
    _date.month,
    _date.day + (nextDay ? 1 : 0),
    t.hour,
    t.minute,
  );

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
    required bool allowClear,
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
      _pickerNote = items.isEmpty && !allowClear ? empty : null;
      if (_failure is! ValidationFailure) _failure = null;
    });
    if (items.isEmpty && !allowClear) return;
    final picked = await showAppChoice(
      context,
      title: title,
      allowClear: allowClear,
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

  Future<void> _save(String? locationId) async {
    setState(() {
      _failure = null;
      _tried = true;
    });
    if (!_formKey.currentState!.validate() ||
        _endError != null ||
        locationId == null) {
      HapticFeedback.mediumImpact();
      return;
    }
    setState(() => _saving = true);
    try {
      final saved = await ref.read(saveJobProvider)(
        SaveJobParams(
          clientId: widget.clientId,
          jobId: widget.initial?.id,
          draft: JobDraft(
            title: _title.text,
            locationId: locationId,
            scopeId: _scopeId,
            scheduledStart: _at(_start),
            scheduledEnd: switch (_end) {
              final end? => _at(end, nextDay: _endsNextDay),
              null => null,
            },
            instructions: _instructions.text,
          ),
        ),
      );
      invalidateJobs(ref);
      if (!mounted) return;
      if (_creating) {
        // A new job has its own page, where its crew and checklist are set.
        context.go(
          '${AccountsScreen.path}/${widget.clientId}/'
          '${AccountJobsScreen.route}/${saved.id}',
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
    final locationList = ref.watch(allLocationsProvider(widget.clientId));
    final scopeQuery = ScopeQuery(clientId: widget.clientId);
    final scopes = ref.watch(scopesProvider(scopeQuery)).value;
    final locations = locationList.value ?? const <Location>[];
    // The only location is the default.
    final locationId =
        _locationId ?? (locations.length == 1 ? locations.single.id : null);
    final locationName =
        locations.where((l) => l.id == locationId).firstOrNull?.name ??
        (locationId == initial?.locationId ? initial?.location?.name : null);
    final scope = scopes?.where((s) => s.id == _scopeId).firstOrNull;
    final scopeName = switch (scope) {
      final s? => scopeTitle(l10n, s),
      null when _scopeId != null && _scopeId == initial?.scopeId =>
        initial?.scopeArea ?? l10n.scopeWholeSite,
      _ => null,
    };

    // Server errors with no field of their own show on top.
    final failure = _failure;
    final notices = <String>[
      ...switch (failure) {
        null => const <String>[],
        ValidationFailure(:final fieldErrors) when fieldErrors.isNotEmpty => [
          for (final MapEntry(:key, :value) in fieldErrors.entries)
            if (!_textFields.contains(key) && value.isNotEmpty)
              l10n.fieldError(value.first),
        ],
        final other => [l10n.failureMessage(other)],
      },
      // The locations couldn't load (no access to them, offline).
      if (locationList.error case final Failure f
          when failure == null && !locationList.hasValue)
        l10n.failureMessage(f),
    ];

    return SpacePage(
      title: _creating ? l10n.newJobTitle : l10n.editJob,
      bottom: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(side, 8, side, 12),
          child: PrimaryButton(
            label: l10n.saveButton,
            busy: _saving,
            onPressed: () => _save(locationId),
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
                for (final message in notices)
                  Padding(
                    padding: EdgeInsets.fromLTRB(side, 4, side, 4),
                    child: Notice(message: message),
                  ),
                if (_pickerNote case final note?)
                  Padding(
                    padding: EdgeInsets.fromLTRB(side, 4, side, 4),
                    child: Notice(message: note, tone: NoticeTone.info),
                  ),
                FormSection(l10n.sectionGeneral, [
                  SpaceTextField(
                    label: l10n.jobNameLabel,
                    controller: _title,
                    enabled: !_saving,
                    hint: l10n.jobNameHint,
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
                            allowClear: _scopeId != null,
                            apply: (s) {
                              _scopeId = s?.id;
                              // A scope says where, and names the job if it
                              // has no title yet.
                              if (s == null) return;
                              _locationId = s.locationId;
                              if (_title.text.trim().isEmpty) {
                                _title.text = scopeTitle(l10n, s);
                              }
                            },
                          ),
                  ),
                  PickerField(
                    label: l10n.locationLabel,
                    value: locationName,
                    errorText: _tried && locationId == null
                        ? l10n.validationRequired
                        : null,
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
                            allowClear: false,
                            apply: (l) {
                              _locationId = l?.id;
                              // A scope belongs to one location.
                              if (scope != null && scope.locationId != l?.id) {
                                _scopeId = null;
                              }
                            },
                          ),
                  ),
                ]),
                FormSection(l10n.sectionWhen, [
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
                  PickerField(
                    label: l10n.endTimeLabel,
                    icon: Icons.schedule_rounded,
                    value: switch (_end) {
                      final end? when _endsNextDay => l10n.endsNextDay(
                        time(end),
                      ),
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
                                    (_start.hour + 2) % 24,
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
                ], footer: l10n.jobEndHelp),
                FormSection(l10n.sectionDetails, [
                  SpaceTextField(
                    label: l10n.jobInstructions,
                    controller: _instructions,
                    enabled: !_saving,
                    hint: l10n.jobInstructionsHint,
                    textCapitalization: TextCapitalization.sentences,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    maxLines: null,
                    validator: _validator(
                      'instructions',
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
