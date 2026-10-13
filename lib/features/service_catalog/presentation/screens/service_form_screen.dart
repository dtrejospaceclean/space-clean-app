import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../l10n/app_localizations.dart';
import '../../di/service_catalog_providers.dart';
import '../../domain/entities/service_item.dart';
import '../../domain/usecases/service_catalog_usecases.dart';
import '../controllers/service_catalog_providers.dart';

/// Add a service ([serviceId] null) or edit one, including retiring it.
/// Owners and account managers only.
class ServiceFormScreen extends ConsumerWidget {
  const ServiceFormScreen({super.key, this.serviceId});

  final String? serviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final id = serviceId;
    if (id == null) return _ServiceForm(title: l10n.newServiceTitle);

    final title = l10n.editServiceTitle;
    return switch (ref.watch(serviceProvider(id))) {
      AsyncValue(:final value?) => _ServiceForm(
        key: ValueKey(id),
        title: title,
        initial: value,
      ),
      final other => SpacePage(
        title: title,
        slivers: [
          AsyncSlivers<ServiceItem>(
            value: other,
            skeleton: SkeletonLayout.form,
            onRetry: () => ref.invalidate(serviceProvider(id)),
            builder: (_) => const SliverToBoxAdapter(),
          ),
        ],
      ),
    };
  }
}

class _ServiceForm extends ConsumerStatefulWidget {
  const _ServiceForm({super.key, required this.title, this.initial});

  final String title;
  final ServiceItem? initial;

  @override
  ConsumerState<_ServiceForm> createState() => _ServiceFormState();
}

class _ServiceFormState extends ConsumerState<_ServiceForm> {
  static const _categoryGone = 'service_catalog.category_not_found';
  static const _unitGone = 'service_catalog.unit_not_found';

  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.name);
  late final _price = TextEditingController(text: widget.initial?.defaultPrice);
  late ServiceCategory? _category = widget.initial?.category;
  late UnitOfMeasure? _unit = widget.initial?.unit;
  late bool _active = widget.initial?.isActive ?? true;

  bool _saving = false;
  Failure? _failure;

  /// Set when Save is tapped without a unit.
  bool _unitMissing = false;

  static final _moneyPattern = RegExp(r'^\d+(\.\d{1,2})?$');

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    super.dispose();
  }

  /// A server-side error for [field] (a body path), if any.
  String? _serverError(String field) {
    final l10n = AppLocalizations.of(context);
    return switch (_failure) {
      ValidationFailure(:final fieldErrors) => switch (fieldErrors[field]) {
        final errors? when errors.isNotEmpty => l10n.fieldError(errors.first),
        _ => null,
      },
      ServerFailure(messageKey: _categoryGone) when field == 'categoryId' =>
        l10n.serviceCatalogCategoryNotFound,
      ServerFailure(messageKey: _unitGone) when field == 'unitOfMeasureId' =>
        l10n.serviceCatalogUnitNotFound,
      _ => null,
    };
  }

  /// Shows a server-side error for [field] first, then the [local] rule.
  FormFieldValidator<String> _validator(
    String field, [
    String? Function(String value)? local,
  ]) =>
      (value) => _serverError(field) ?? local?.call(value ?? '');

  Future<void> _pickCategory() async {
    final l10n = AppLocalizations.of(context);
    final active = await ref.read(activeCategoriesProvider.future);
    if (!mounted) return;
    final current = _category;
    final options = {
      // A retired current category stays listed so it can be kept.
      if (current != null && active.every((c) => c.id != current.id))
        current.id: current,
      for (final c in active) c.id: c,
    };
    final picked = await showAppChoice(
      context,
      title: l10n.serviceCategoryLabel,
      allowClear: current != null,
      options: {for (final c in options.values) c.id: c.name},
    );
    if (picked != null) {
      setState(() => _category = picked.isEmpty ? null : options[picked]);
    }
  }

  Future<void> _pickUnit() async {
    final l10n = AppLocalizations.of(context);
    final active = await ref.read(activeUnitsProvider.future);
    if (!mounted) return;
    final current = _unit;
    final options = {
      if (current != null && active.every((u) => u.id != current.id))
        current.id: current,
      for (final u in active) u.id: u,
    };
    if (options.isEmpty) {
      setState(() => _unitMissing = true);
      return;
    }
    final picked = await showAppChoice(
      context,
      title: l10n.unitOfMeasureLabel,
      // The API can change a unit but not clear it.
      allowClear: false,
      options: {for (final u in options.values) u.id: _unitLabel(u)},
    );
    if (picked != null && picked.isNotEmpty) {
      setState(() {
        _unit = options[picked];
        _unitMissing = false;
      });
    }
  }

  /// "Square foot (sq ft)".
  static String _unitLabel(UnitOfMeasure u) => switch (u.abbreviation) {
    final short? when short != u.name => '${u.name} ($short)',
    _ => u.name,
  };

  Future<void> _save() async {
    setState(() {
      _failure = null;
      _unitMissing = _unit == null;
    });
    final fieldsValid = _formKey.currentState!.validate();
    final unit = _unit;
    if (!fieldsValid || unit == null) {
      HapticFeedback.mediumImpact();
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(saveServiceProvider)(
        SaveParams(
          id: widget.initial?.id,
          draft: ServiceDraft(
            name: _name.text,
            unitOfMeasureId: unit.id,
            categoryId: _category?.id,
            defaultPrice: _price.text,
            isActive: _active,
          ),
        ),
      );
      invalidateCatalog(ref);
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final failure = _failure;
    // Field-level failures show on their fields; everything else on top.
    final showBanner =
        failure != null &&
        failure is! ValidationFailure &&
        failure.messageKey != _categoryGone &&
        failure.messageKey != _unitGone;
    final noUnits = ref.watch(activeUnitsProvider).value?.isEmpty ?? false;
    // Keeps the category picker's list loaded while the form is open.
    ref.watch(activeCategoriesProvider);

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
                if (showBanner)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      pageSide(context),
                      4,
                      pageSide(context),
                      0,
                    ),
                    child: Notice(message: l10n.failureMessage(failure)),
                  ),
                // One card: what the service is and how it's priced.
                FormSection(null, [
                  SpaceTextField(
                    label: l10n.serviceNameLabel,
                    controller: _name,
                    enabled: !_saving,
                    textCapitalization: TextCapitalization.sentences,
                    validator: _validator(
                      'name',
                      (v) => v.trim().isEmpty ? l10n.validationRequired : null,
                    ),
                  ),
                  PickerField(
                    label: l10n.serviceCategoryLabel,
                    value: _category?.name,
                    onTap: _saving ? null : _pickCategory,
                    errorText: _serverError('categoryId'),
                  ),
                  PickerField(
                    label: l10n.unitOfMeasureLabel,
                    value: switch (_unit) {
                      final unit? => _unitLabel(unit),
                      null => null,
                    },
                    onTap: _saving ? null : _pickUnit,
                    errorText:
                        _serverError('unitOfMeasureId') ??
                        (_unitMissing
                            ? (noUnits
                                  ? l10n.noUnitsToPick
                                  : l10n.validationRequired)
                            : null),
                  ),
                  SpaceTextField(
                    label: l10n.defaultPriceLabel,
                    controller: _price,
                    enabled: !_saving,
                    hint: '0.12',
                    textInputAction: TextInputAction.done,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    validator: _validator('defaultPrice', (v) {
                      final text = v.trim();
                      return text.isEmpty || _moneyPattern.hasMatch(text)
                          ? null
                          : l10n.invalidPrice;
                    }),
                  ),
                ], footer: l10n.defaultPriceHelp),
                // A new service starts active.
                if (widget.initial != null)
                  FormSection(l10n.accountStatusLabel, [
                    PillToggle<bool>(
                      options: {
                        true: l10n.filterActive,
                        false: l10n.filterInactive,
                      },
                      selected: _active,
                      onChanged: _saving
                          ? (_) {}
                          : (v) => setState(() => _active = v),
                      track: context.colors.sunken,
                    ),
                  ], footer: _active ? null : l10n.serviceInactiveHelp),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
