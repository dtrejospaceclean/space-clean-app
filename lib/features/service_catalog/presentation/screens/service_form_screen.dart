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
      AsyncData(:final value) => _ServiceForm(
        key: ValueKey(id),
        title: title,
        initial: value,
      ),
      final other => SpacePage(
        title: title,
        slivers: [
          AsyncSlivers<ServiceItem>(
            value: other,
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
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.name);
  late final _category = TextEditingController(text: widget.initial?.category);
  late final _unit = TextEditingController(text: widget.initial?.unitOfMeasure);
  late final _price = TextEditingController(text: widget.initial?.defaultPrice);
  late bool _active = widget.initial?.isActive ?? true;

  bool _saving = false;
  Failure? _failure;

  static final _moneyPattern = RegExp(r'^\d+(\.\d{1,2})?$');

  @override
  void dispose() {
    for (final c in [_name, _category, _unit, _price]) {
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

  String? _required(String value) => value.trim().isEmpty
      ? AppLocalizations.of(context).validationRequired
      : null;

  Future<void> _save() async {
    setState(() => _failure = null);
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }
    setState(() => _saving = true);
    try {
      final saved = await ref.read(saveServiceProvider)(
        SaveServiceParams(
          id: widget.initial?.id,
          draft: ServiceDraft(
            name: _name.text,
            unitOfMeasure: _unit.text,
            category: _category.text,
            defaultPrice: _price.text,
            isActive: _active,
          ),
        ),
      );
      ref
        ..invalidate(servicesProvider)
        ..invalidate(serviceProvider(saved.id));
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
                FormSection(l10n.sectionService, [
                  SpaceTextField(
                    label: l10n.serviceNameLabel,
                    controller: _name,
                    enabled: !_saving,
                    textCapitalization: TextCapitalization.sentences,
                    validator: _validator('name', _required),
                  ),
                  SpaceTextField(
                    label: l10n.serviceCategoryLabel,
                    controller: _category,
                    enabled: !_saving,
                    hint: l10n.serviceCategoryHint,
                    textCapitalization: TextCapitalization.sentences,
                    validator: _validator('category'),
                  ),
                ]),
                FormSection(l10n.sectionPricing, [
                  SpaceTextField(
                    label: l10n.unitOfMeasureLabel,
                    controller: _unit,
                    enabled: !_saving,
                    hint: l10n.unitOfMeasureHint,
                    validator: _validator('unitOfMeasure', _required),
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
