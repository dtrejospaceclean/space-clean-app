import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../invoices/presentation/screens/invoice_pdf_screen.dart';
import '../../di/locations_providers.dart';
import '../../domain/entities/location.dart';
import '../../domain/usecases/location_usecases.dart';
import '../controllers/locations_providers.dart';

/// Add a location to an account ([locationId] null) or edit one. Both need
/// `info.edit` on the account. Typing the street address suggests US
/// addresses (debounced, since every search counts toward a monthly
/// allowance); a pick fills the address fields, which stay editable. When
/// search can't be used the address is typed by hand. The server places
/// the address on the map when it's saved.
class LocationFormScreen extends ConsumerWidget {
  const LocationFormScreen({
    super.key,
    required this.clientId,
    this.locationId,
  });

  final String clientId;
  final String? locationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final id = locationId;
    if (id == null) {
      return _LocationForm(clientId: clientId, title: l10n.newLocationTitle);
    }
    // Wait for the location before building fields.
    return switch (ref.watch(locationProvider((clientId, id)))) {
      AsyncValue(value: final location?) => _LocationForm(
        key: ValueKey(id),
        clientId: clientId,
        title: l10n.editLocation,
        initial: location,
      ),
      final other => SpacePage(
        title: l10n.editLocation,
        slivers: [
          AsyncSlivers<Location>(
            value: other,
            skeleton: SkeletonLayout.form,
            onRetry: () => ref.invalidate(locationProvider((clientId, id))),
            builder: (_) => const SliverToBoxAdapter(),
          ),
        ],
      ),
    };
  }
}

class _LocationForm extends ConsumerStatefulWidget {
  const _LocationForm({
    super.key,
    required this.clientId,
    required this.title,
    this.initial,
  });

  final String clientId;
  final String title;
  final Location? initial;

  @override
  ConsumerState<_LocationForm> createState() => _LocationFormState();
}

class _LocationFormState extends ConsumerState<_LocationForm> {
  /// Up to 2 decimals, like the API allows.
  static final _areaPattern = RegExp(r'^\d+(\.\d{1,2})?$');
  static final _wholePattern = RegExp(r'^\d+$');

  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.name);
  late final _address = TextEditingController(text: widget.initial?.address);
  late final _city = TextEditingController(text: widget.initial?.city);
  late final _state = TextEditingController(text: widget.initial?.state);
  late final _zip = TextEditingController(text: widget.initial?.zipCode);
  late final _area = TextEditingController(text: widget.initial?.squareFootage);
  late final _floors = TextEditingController(
    text: widget.initial?.floorCount?.toString(),
  );
  late final _access = TextEditingController(text: widget.initial?.accessCodes);
  late final _instructions = TextEditingController(
    text: widget.initial?.specialInstructions,
  );

  bool _saving = false;
  Failure? _failure;

  final _addressFocus = FocusNode();
  Timer? _debounce;

  /// Bumped per search, so a slow answer to an older one is dropped.
  int _searchId = 0;
  bool _searching = false;
  List<AddressSuggestion> _suggestions = const [];

  /// Search can't be used for the rest of this form (`geo.*`).
  bool _searchOff = false;

  static const _debounceTime = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _addressFocus.addListener(() {
      if (!_addressFocus.hasFocus) _clearSuggestions();
    });
  }

  void _clearSuggestions() {
    _debounce?.cancel();
    _searchId++;
    if (_suggestions.isNotEmpty || _searching) {
      setState(() {
        _suggestions = const [];
        _searching = false;
      });
    }
  }

  void _addressChanged(String value) {
    if (_searchOff) return;
    _clearSuggestions();
    if (value.trim().length < SuggestAddresses.minLength) return;
    _debounce = Timer(_debounceTime, () => _search(value));
  }

  Future<void> _search(String query) async {
    final id = ++_searchId;
    setState(() => _searching = true);
    try {
      final found = await ref.read(suggestAddressesProvider)(
        AddressSearch(
          clientId: widget.clientId,
          query: query,
          language: documentLanguage(context),
        ),
      );
      if (!mounted || id != _searchId) return;
      setState(() => _suggestions = found);
    } on Failure catch (f) {
      if (!mounted || id != _searchId) return;
      // Offline or a one-off error: just no suggestions this time.
      if (SuggestAddresses.unavailableKeys.contains(f.messageKey)) {
        setState(() => _searchOff = true);
      }
    } finally {
      if (mounted && id == _searchId) setState(() => _searching = false);
    }
  }

  /// Copies the pick into the fields; one it doesn't know is left as typed,
  /// and the next field gets the focus while one is still empty.
  void _pick(AddressSuggestion s) {
    _address.text = s.address;
    if (s.city case final city?) _city.text = city;
    if (s.state case final state?) _state.text = state;
    if (s.zipCode case final zip?) _zip.text = zip;
    _clearSuggestions();
    final complete = [
      _city,
      _state,
      _zip,
    ].every((c) => c.text.trim().isNotEmpty);
    if (complete) {
      _addressFocus.unfocus();
    } else {
      FocusScope.of(context).nextFocus();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _addressFocus.dispose();
    for (final c in [
      _name,
      _address,
      _city,
      _state,
      _zip,
      _area,
      _floors,
      _access,
      _instructions,
    ]) {
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

  Future<void> _save() async {
    setState(() => _failure = null);
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(saveLocationProvider)(
        SaveLocationParams(
          clientId: widget.clientId,
          locationId: widget.initial?.id,
          draft: LocationDraft(
            name: _name.text,
            address: _address.text,
            city: _city.text,
            state: _state.text,
            zipCode: _zip.text,
            squareFootage: _area.text,
            floorCount: _floors.text,
            accessCodes: _access.text,
            specialInstructions: _instructions.text,
          ),
        ),
      );
      invalidateLocations(ref, widget.clientId);
      if (mounted) context.pop();
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

  Widget _text(
    String label,
    TextEditingController controller,
    String field, {
    String? hint,
    String? helper,
    TextCapitalization capitalization = TextCapitalization.words,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
    TextInputAction action = TextInputAction.next,
    int? maxLines = 1,
    String? Function(String value)? validate,
  }) => SpaceTextField(
    label: label,
    controller: controller,
    enabled: !_saving,
    hint: hint,
    helper: helper,
    textCapitalization: capitalization,
    keyboardType: keyboardType,
    inputFormatters: formatters,
    textInputAction: action,
    maxLines: maxLines,
    validator: _validator(field, validate),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final failure = _failure;
    String? required(String v) =>
        v.trim().isEmpty ? l10n.validationRequired : null;

    return SpacePage(
      title: widget.title,
      bottom: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            pageSide(context),
            8,
            pageSide(context),
            12,
          ),
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
                // Field-level failures show on their fields; the rest on top.
                if (failure != null && failure is! ValidationFailure)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      pageSide(context),
                      4,
                      pageSide(context),
                      0,
                    ),
                    child: Notice(message: l10n.failureMessage(failure)),
                  ),
                FormSection(l10n.sectionGeneral, [
                  _text(
                    l10n.serviceNameLabel,
                    _name,
                    'name',
                    hint: l10n.locationNameHint,
                    capitalization: TextCapitalization.sentences,
                    validate: required,
                  ),
                ]),
                FormSection(l10n.sectionAddress, [
                  if (_searchOff)
                    Notice(
                      message: l10n.addressSearchUnavailable,
                      tone: NoticeTone.info,
                    ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SpaceTextField(
                        label: l10n.streetAddressLabel,
                        controller: _address,
                        focusNode: _addressFocus,
                        enabled: !_saving,
                        hint: _searchOff ? null : l10n.addressSearchHint,
                        textCapitalization: TextCapitalization.words,
                        keyboardType: TextInputType.streetAddress,
                        suffix: _searching
                            ? const Padding(
                                padding: EdgeInsets.all(14),
                                child: SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator.adaptive(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : null,
                        onChanged: _addressChanged,
                        validator: _validator('address', required),
                      ),
                      if (_suggestions.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _Suggestions(suggestions: _suggestions, onPick: _pick),
                      ],
                    ],
                  ),
                  _text(
                    l10n.billingCityLabel,
                    _city,
                    'city',
                    validate: required,
                  ),
                  _text(
                    l10n.billingStateLabel,
                    _state,
                    'state',
                    validate: required,
                  ),
                  _text(
                    l10n.billingZipLabel,
                    _zip,
                    'zipCode',
                    capitalization: TextCapitalization.characters,
                    validate: required,
                  ),
                ]),
                FormSection(l10n.sectionSiteDetails, [
                  _text(
                    l10n.squareFootageLabel,
                    _area,
                    'squareFootage',
                    hint: '12000',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    formatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    validate: (v) =>
                        v.trim().isEmpty || _areaPattern.hasMatch(v.trim())
                        ? null
                        : l10n.invalidSquareFootage,
                  ),
                  _text(
                    l10n.floorCountLabel,
                    _floors,
                    'floorCount',
                    keyboardType: TextInputType.number,
                    formatters: [FilteringTextInputFormatter.digitsOnly],
                    validate: (v) =>
                        v.trim().isEmpty || _wholePattern.hasMatch(v.trim())
                        ? null
                        : l10n.invalidWholeNumber,
                  ),
                  _text(
                    l10n.accessCodesLabel,
                    _access,
                    'accessCodes',
                    helper: l10n.accessCodesHelp,
                    capitalization: TextCapitalization.none,
                  ),
                  _text(
                    l10n.specialInstructionsLabel,
                    _instructions,
                    'specialInstructions',
                    hint: l10n.specialInstructionsHint,
                    capitalization: TextCapitalization.sentences,
                    keyboardType: TextInputType.multiline,
                    action: TextInputAction.newline,
                    maxLines: null,
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

/// The addresses found for what's typed, under the street field.
class _Suggestions extends StatelessWidget {
  const _Suggestions({required this.suggestions, required this.onPick});

  final List<AddressSuggestion> suggestions;
  final ValueChanged<AddressSuggestion> onPick;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Semantics(
      container: true,
      liveRegion: true,
      label: l10n.addressSuggestionsLabel(suggestions.length),
      child: Material(
        color: c.sunken,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SpaceRadius.inner),
          side: BorderSide(color: c.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, s) in suggestions.indexed) ...[
              if (i > 0) const Divider(height: 1),
              Semantics(
                container: true,
                button: true,
                label: '${s.name}, ${s.description}',
                excludeSemantics: true,
                child: InkWell(
                  onTap: () => onPick(s),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.place_outlined,
                            size: 20,
                            color: c.inkMuted,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.name,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (s.description.isNotEmpty)
                                  Text(
                                    s.description,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: c.inkMuted,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: Text(
                l10n.addressSuggestionsBy,
                textAlign: TextAlign.end,
                style: theme.textTheme.labelSmall?.copyWith(color: c.inkFaint),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
