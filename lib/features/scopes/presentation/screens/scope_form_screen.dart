import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../clients/presentation/screens/accounts_screen.dart';
import '../../../contracts/domain/entities/contract.dart';
import '../../../contracts/presentation/controllers/contracts_providers.dart';
import '../../../contracts/presentation/screens/contracts_screen.dart';
import '../../../locations/domain/entities/location.dart';
import '../../../locations/presentation/controllers/locations_providers.dart';
import '../../../service_catalog/domain/entities/service_item.dart';
import '../../../service_catalog/presentation/controllers/service_catalog_providers.dart';
import '../../../shell/presentation/page_action.dart';
import '../../di/scopes_providers.dart';
import '../../domain/entities/scope.dart';
import '../../domain/usecases/scope_usecases.dart';
import '../controllers/scopes_providers.dart';
import '../widgets/scope_labels.dart';
import 'scopes_screen.dart';
import 'time_window_screen.dart';

/// A new scope ([scopeId] null) or an edit of one. A new one picks its
/// contract (not a cancelled one; the only one by default) and keeps it.
/// Time windows are added with the dock's "+" and edited on their own page.
/// Needs `scope.edit`.
class ScopeFormScreen extends ConsumerWidget {
  const ScopeFormScreen({super.key, required this.clientId, this.scopeId});

  final String clientId;
  final String? scopeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final id = scopeId;
    if (id == null) {
      return _ScopeForm(clientId: clientId);
    }
    // Wait for the scope before building fields.
    return switch (ref.watch(scopeProvider((clientId, id)))) {
      AsyncValue(value: final scope?) => _ScopeForm(
        key: ValueKey(id),
        clientId: clientId,
        initial: scope,
      ),
      final other => SpacePage(
        title: l10n.editScope,
        slivers: [
          AsyncSlivers<Scope>(
            value: other,
            onRetry: () => ref.invalidate(scopeProvider((clientId, id))),
            builder: (_) => const SliverToBoxAdapter(),
          ),
        ],
      ),
    };
  }
}

class _ScopeForm extends ConsumerStatefulWidget {
  const _ScopeForm({super.key, required this.clientId, this.initial});

  final String clientId;

  /// The scope edited; null to create.
  final Scope? initial;

  @override
  ConsumerState<_ScopeForm> createState() => _ScopeFormState();
}

/// The fields whose server errors show on a text field; the rest show on
/// top of the form.
const _textFields = {
  'areaName',
  'estimatedDurationMinutes',
  'instructions',
  'exclusions',
  'requiredSupplies',
};

class _ScopeFormState extends ConsumerState<_ScopeForm> with PageActionHost {
  static final _wholePattern = RegExp(r'^\d+$');

  final _formKey = GlobalKey<FormState>();
  String? _contractId;
  late String? _locationId = widget.initial?.locationId;
  late String? _serviceId = widget.initial?.serviceId;
  late ScopeFrequency _frequency =
      widget.initial?.frequency ?? ScopeFrequency.weekly;
  late List<ScopeSchedule> _windows = [...?widget.initial?.schedules];
  late final _area = TextEditingController(text: widget.initial?.areaName);
  late final _duration = TextEditingController(
    text: widget.initial?.estimatedDurationMinutes?.toString(),
  );
  late final _instructions = TextEditingController(
    text: widget.initial?.instructions,
  );
  late final _exclusions = TextEditingController(
    text: widget.initial?.exclusions,
  );
  late final _supplies = TextEditingController(
    text: widget.initial?.requiredSupplies,
  );

  bool _saving = false;

  /// Why a picker had nothing to offer.
  String? _pickerNote;

  /// Picker errors show only after a first Save.
  bool _tried = false;
  Failure? _failure;

  bool get _creating => widget.initial == null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // New windows come from the "+" beside the dock, like everything else
    // the app adds.
    registerPageAction(
      location: GoRouterState.of(context).matchedLocation,
      label: AppLocalizations.of(context).addTimeWindow,
      text: AppLocalizations.of(context).addTimeWindowShort,
      onPressed: () {
        if (!_saving) _openWindow();
      },
    );
  }

  @override
  void dispose() {
    for (final c in [_area, _duration, _instructions, _exclusions, _supplies]) {
      c.dispose();
    }
    super.dispose();
  }

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

  /// Opens the time window page for window [index], or for a new one when
  /// null, and applies what it hands back.
  Future<void> _openWindow([int? index]) async {
    final here = GoRouterState.of(context).matchedLocation;
    final result = await context.push<TimeWindowResult>(
      '$here/${TimeWindowScreen.route}',
      extra: TimeWindowArgs(
        window: index == null ? null : _windows[index],
        needsDays: _frequency.needsDays,
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      if (_failure is ValidationFailure) _failure = null;
      _windows = [..._windows];
      switch ((index, result.window)) {
        case (null, final w?):
          _windows.add(w);
        case (final i?, final w?):
          _windows[i] = w;
        case (final i?, null):
          _windows.removeAt(i);
        case (null, null):
          break;
      }
      _windows.sort((a, b) => a.startTime.compareTo(b.startTime));
    });
  }

  /// Waits for [list] (it may still be loading), then offers its items. A
  /// list that can't load (no access to it, offline) says why on top of the
  /// form; an empty one says what to add first.
  Future<void> _pickFrom<T>({
    required String title,
    required Future<List<T>> list,
    required String Function(T item) id,
    required String Function(T item) label,
    required String empty,
    required ValueChanged<String?> apply,
    bool allowClear = false,
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
      _pickerNote = items.isEmpty ? empty : null;
      if (_failure is! ValidationFailure) _failure = null;
    });
    if (items.isEmpty) return;
    await _pick(
      title: title,
      allowClear: allowClear,
      options: {for (final item in items) id(item): label(item)},
      apply: apply,
    );
  }

  Future<void> _pick({
    required String title,
    required Map<String, String> options,
    required bool allowClear,
    required ValueChanged<String?> apply,
  }) async {
    final picked = await showAppChoice(
      context,
      title: title,
      options: options,
      allowClear: allowClear,
    );
    if (picked == null || !mounted) return;
    setState(() => apply(picked.isEmpty ? null : picked));
  }

  /// Weekly and biweekly windows each need their weekdays.
  bool get _windowsMissingDays =>
      _frequency.needsDays && _windows.any((w) => w.daysOfWeek.isEmpty);

  Future<void> _save({
    required String? contractId,
    required String? locationId,
  }) async {
    setState(() {
      _failure = null;
      _tried = true;
    });
    final fieldsOk = _formKey.currentState!.validate();
    if (!fieldsOk ||
        (_creating && contractId == null) ||
        locationId == null ||
        _windowsMissingDays) {
      HapticFeedback.mediumImpact();
      return;
    }
    final initial = widget.initial;
    // Replacing the windows unlinks the jobs and events made from them, so
    // an edit sends them only when they (or the frequency, which decides
    // whether days are kept) changed.
    final sendWindows =
        initial == null ||
        initial.frequency != _frequency ||
        !listEquals(initial.schedules, _windows);
    setState(() => _saving = true);
    try {
      final saved = await ref.read(saveScopeProvider)(
        SaveScopeParams(
          clientId: widget.clientId,
          scopeId: initial?.id,
          draft: ScopeDraft(
            contractId: _creating ? contractId : null,
            locationId: locationId,
            serviceId: _serviceId,
            areaName: _area.text,
            frequency: _frequency,
            instructions: _instructions.text,
            exclusions: _exclusions.text,
            estimatedDurationMinutes: _duration.text,
            requiredSupplies: _supplies.text,
            schedules: sendWindows ? _windows : null,
          ),
        ),
      );
      invalidateScopes(ref);
      // The contract's scope count changed.
      invalidateContracts(ref, widget.clientId);
      if (!mounted) return;
      if (_creating) {
        // A new scope has its own page.
        context.go(
          '${AccountsScreen.path}/${widget.clientId}/'
          '${ScopesScreen.route}/${saved.id}',
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
    final theme = Theme.of(context);
    final side = pageSide(context);

    // Every list a picker offers; a single choice is taken as the default.
    final contractList = _creating
        ? ref.watch(contractsProvider(widget.clientId))
        : null;
    final locationList = ref.watch(allLocationsProvider(widget.clientId));
    final contracts = [
      for (final c in contractList?.value ?? const <Contract>[])
        if (!c.isCancelled) c,
    ];
    final locations = locationList.value ?? const <Location>[];
    final services =
        ref.watch(activeServicesProvider).value ?? const <ServiceItem>[];
    final contractId =
        _contractId ?? (contracts.length == 1 ? contracts.single.id : null);
    final locationId =
        _locationId ?? (locations.length == 1 ? locations.single.id : null);
    final contract = contracts.where((c) => c.id == contractId).firstOrNull;
    final location = locations.where((l) => l.id == locationId).firstOrNull;
    final service = services.where((s) => s.id == _serviceId).firstOrNull;

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
      // A list a picker needs that couldn't load (no access, offline).
      for (final list in [contractList, locationList])
        if (list?.error case final Failure f
            when failure == null && !list!.hasValue)
          l10n.failureMessage(f),
    ];

    return SpacePage(
      title: _creating ? l10n.newScopeTitle : l10n.editScope,
      bottom: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(side, 8, side, 12),
          child: PrimaryButton(
            label: l10n.saveButton,
            busy: _saving,
            onPressed: () =>
                _save(contractId: contractId, locationId: locationId),
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
                  if (_creating)
                    PickerField(
                      label: l10n.contractTitle,
                      value: switch (contract) {
                        final c? => contractTerm(context, c),
                        null => null,
                      },
                      errorText: _tried && contractId == null
                          ? l10n.validationRequired
                          : null,
                      onTap: _saving
                          ? null
                          : () => _pickFrom<Contract>(
                              title: l10n.contractTitle,
                              list: ref
                                  .read(
                                    contractsProvider(widget.clientId).future,
                                  )
                                  .then(
                                    (all) => [
                                      for (final c in all)
                                        if (!c.isCancelled) c,
                                    ],
                                  ),
                              id: (c) => c.id,
                              label: (c) => contractTerm(context, c),
                              empty: l10n.scopeNeedsContract,
                              apply: (id) => _contractId = id,
                            ),
                    ),
                  PickerField(
                    label: l10n.locationLabel,
                    value: location?.name,
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
                            empty: l10n.scopeNeedsLocation,
                            apply: (id) => _locationId = id,
                          ),
                  ),
                  SpaceTextField(
                    label: l10n.areaNameLabel,
                    controller: _area,
                    enabled: !_saving,
                    hint: l10n.areaNameHint,
                    helper: l10n.areaNameHelp,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    validator: _validator(
                      'areaName',
                      (v) => v.trim().length > 150
                          ? l10n.validationMaxLength('150')
                          : null,
                    ),
                  ),
                  PickerField(
                    label: l10n.scopeServiceLabel,
                    value: switch (_serviceId) {
                      null => null,
                      _ when service != null => service.name,
                      // Linked to a service retired since.
                      _ =>
                        widget.initial?.serviceName ?? l10n.serviceNotInCatalog,
                    },
                    onTap: _saving
                        ? null
                        : () => _pickFrom<ServiceItem>(
                            title: l10n.scopeServiceLabel,
                            list: ref.read(activeServicesProvider.future),
                            id: (s) => s.id,
                            label: (s) => s.name,
                            empty: l10n.scopeNoServices,
                            allowClear: _serviceId != null,
                            apply: (id) => _serviceId = id,
                          ),
                  ),
                ]),
                FormSection(l10n.sectionSchedule, [
                  PickerField(
                    label: l10n.frequencyLabel,
                    value: l10n.scopeFrequency(_frequency),
                    onTap: _saving
                        ? null
                        : () => _pick(
                            title: l10n.frequencyLabel,
                            allowClear: false,
                            options: {
                              for (final f in ScopeFrequency.known)
                                f.wire: l10n.scopeFrequency(f),
                            },
                            apply: (wire) =>
                                _frequency = ScopeFrequency.fromWire(wire),
                          ),
                  ),
                ]),
                // The windows, each opening its own page.
                Padding(
                  padding: EdgeInsets.fromLTRB(side, 12, side, 0),
                  child: SectionHeader(title: l10n.sectionTimeWindows),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: side),
                  child: ListCard(
                    children: [
                      if (_windows.isEmpty)
                        ListRow(title: l10n.timeWindowsEmpty, muted: true),
                      for (final (i, w) in _windows.indexed)
                        ListRow(
                          leading: const IconBadge(
                            icon: Icons.schedule_rounded,
                          ),
                          title: scheduleTimes(context, w),
                          subtitle: switch (_frequency.needsDays) {
                            false => null,
                            true when w.daysOfWeek.isEmpty => l10n.pickWeekdays,
                            true => scheduleDays(context, w),
                          },
                          destructive:
                              _frequency.needsDays && w.daysOfWeek.isEmpty,
                          muted: !w.isActive,
                          trailing: w.isActive
                              ? null
                              : Text(l10n.timeWindowPaused),
                          onTap: _saving ? null : () => _openWindow(i),
                        ),
                    ],
                  ),
                ),
                if (_tried && _windowsMissingDays)
                  Padding(
                    padding: EdgeInsets.fromLTRB(side, 8, side, 0),
                    child: Text(
                      l10n.windowsNeedWeekdays,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: context.colors.danger,
                      ),
                    ),
                  ),
                FormSection(l10n.sectionDetails, [
                  SpaceTextField(
                    label: l10n.estimatedDurationLabel,
                    controller: _duration,
                    enabled: !_saving,
                    hint: '60',
                    helper: l10n.estimatedDurationHelp,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textInputAction: TextInputAction.next,
                    validator: _validator(
                      'estimatedDurationMinutes',
                      (v) =>
                          v.trim().isEmpty || _wholePattern.hasMatch(v.trim())
                          ? null
                          : l10n.invalidWholeNumber,
                    ),
                  ),
                  for (final (label, controller, field, hint) in [
                    (
                      l10n.instructionsLabel,
                      _instructions,
                      'instructions',
                      l10n.instructionsHint,
                    ),
                    (
                      l10n.exclusionsLabel,
                      _exclusions,
                      'exclusions',
                      l10n.exclusionsHint,
                    ),
                    (
                      l10n.requiredSuppliesLabel,
                      _supplies,
                      'requiredSupplies',
                      l10n.requiredSuppliesHint,
                    ),
                  ])
                    SpaceTextField(
                      label: label,
                      controller: controller,
                      enabled: !_saving,
                      hint: hint,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      maxLines: null,
                      validator: _validator(field),
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
