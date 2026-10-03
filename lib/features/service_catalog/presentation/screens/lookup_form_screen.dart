import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/widgets/adaptive.dart';
import '../../../../l10n/app_localizations.dart';
import '../../di/service_catalog_providers.dart';
import '../../domain/entities/service_item.dart';
import '../../domain/usecases/service_catalog_usecases.dart';
import '../controllers/service_catalog_providers.dart';

/// Which catalog lookup a [LookupFormScreen] edits.
enum LookupKind { category, unit }

/// Add ([id] null) or edit a service category or a unit of measure: a name,
/// one detail (description or abbreviation) and the status. Delete shows
/// only while no service uses it; otherwise it's retired instead.
class LookupFormScreen extends ConsumerWidget {
  const LookupFormScreen({super.key, required this.kind, this.id});

  final LookupKind kind;
  final String? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final id = this.id;
    final (newTitle, editTitle) = switch (kind) {
      LookupKind.category => (l10n.newCategoryTitle, l10n.editCategoryTitle),
      LookupKind.unit => (l10n.newUnitTitle, l10n.editUnitTitle),
    };
    if (id == null) return _LookupForm(kind: kind, title: newTitle);

    final AsyncValue<Object> value = switch (kind) {
      LookupKind.category => ref.watch(categoryProvider(id)),
      LookupKind.unit => ref.watch(unitProvider(id)),
    };
    // A refresh keeps the last value, so the form stays while it reloads.
    final lookup = switch (value.value) {
      final ServiceCategory c => _Lookup.category(c),
      final UnitOfMeasure u => _Lookup.unit(u),
      _ => null,
    };
    return switch (lookup) {
      final lookup? => _LookupForm(
        key: ValueKey(id),
        kind: kind,
        title: editTitle,
        initial: lookup,
      ),
      null => SpacePage(
        title: editTitle,
        slivers: [
          AsyncSlivers<Object>(
            value: value,
            onRetry: () => kind == LookupKind.category
                ? ref.invalidate(categoryProvider(id))
                : ref.invalidate(unitProvider(id)),
            builder: (_) => const SliverToBoxAdapter(),
          ),
        ],
      ),
    };
  }
}

/// The fields both lookups share.
class _Lookup {
  const _Lookup({
    required this.id,
    required this.name,
    required this.detail,
    required this.isActive,
    required this.serviceCount,
  });

  _Lookup.category(ServiceCategory c)
    : this(
        id: c.id,
        name: c.name,
        detail: c.description,
        isActive: c.isActive,
        serviceCount: c.serviceCount,
      );

  _Lookup.unit(UnitOfMeasure u)
    : this(
        id: u.id,
        name: u.name,
        detail: u.abbreviation,
        isActive: u.isActive,
        serviceCount: u.serviceCount,
      );

  final String id;
  final String name;
  final String? detail;
  final bool isActive;
  final int serviceCount;
}

class _LookupForm extends ConsumerStatefulWidget {
  const _LookupForm({
    super.key,
    required this.kind,
    required this.title,
    this.initial,
  });

  final LookupKind kind;
  final String title;
  final _Lookup? initial;

  @override
  ConsumerState<_LookupForm> createState() => _LookupFormState();
}

class _LookupFormState extends ConsumerState<_LookupForm> {
  static const _nameTaken = 'errors.unique_violation';

  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.name);
  late final _detail = TextEditingController(text: widget.initial?.detail);
  late bool _active = widget.initial?.isActive ?? true;

  bool _saving = false;
  Failure? _failure;

  bool get _isCategory => widget.kind == LookupKind.category;

  @override
  void dispose() {
    _name.dispose();
    _detail.dispose();
    super.dispose();
  }

  /// Shows a server-side error for [field] first, then the [local] rule.
  FormFieldValidator<String> _validator(
    String field, [
    String? Function(String value)? local,
  ]) => (value) {
    final l10n = AppLocalizations.of(context);
    switch (_failure) {
      case ValidationFailure(:final fieldErrors):
        if (fieldErrors[field] case final errors? when errors.isNotEmpty) {
          return l10n.fieldError(errors.first);
        }
      case ServerFailure(messageKey: _nameTaken) when field == 'name':
        return l10n.lookupNameTaken;
      default:
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
      final params = SaveParams(
        id: widget.initial?.id,
        draft: LookupDraft(
          name: _name.text,
          detail: _detail.text,
          isActive: _active,
        ),
      );
      if (_isCategory) {
        await ref.read(saveCategoryProvider)(params);
      } else {
        await ref.read(saveUnitProvider)(params);
      }
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

  Future<void> _delete(_Lookup lookup) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(l10n.deleteRoleConfirmTitle(lookup.name)),
        content: Text(l10n.deleteRoleConfirmBody),
        actions: [
          adaptiveAction(
            context,
            label: l10n.cancelButton,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          adaptiveAction(
            context,
            label: l10n.deleteButton,
            destructive: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _saving = true;
      _failure = null;
    });
    try {
      if (_isCategory) {
        await ref.read(deleteCategoryProvider)(lookup.id);
      } else {
        await ref.read(deleteUnitProvider)(lookup.id);
      }
      invalidateCatalog(ref);
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
    final failure = _failure;
    final initial = widget.initial;
    // Field-level failures show on their fields; everything else on top.
    final showBanner =
        failure != null &&
        failure is! ValidationFailure &&
        failure.messageKey != _nameTaken;

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
                FormSection(
                  _isCategory
                      ? l10n.catalogCategoryLabel
                      : l10n.catalogUnitLabel,
                  [
                    SpaceTextField(
                      label: l10n.serviceNameLabel,
                      controller: _name,
                      enabled: !_saving,
                      hint: _isCategory
                          ? l10n.categoryNameHint
                          : l10n.unitNameHint,
                      textCapitalization: TextCapitalization.sentences,
                      validator: _validator(
                        'name',
                        (v) =>
                            v.trim().isEmpty ? l10n.validationRequired : null,
                      ),
                    ),
                    if (_isCategory)
                      SpaceTextField(
                        label: l10n.categoryDescriptionLabel,
                        controller: _detail,
                        enabled: !_saving,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.done,
                        validator: _validator('description'),
                      )
                    else
                      SpaceTextField(
                        label: l10n.abbreviationLabel,
                        controller: _detail,
                        enabled: !_saving,
                        hint: l10n.abbreviationHint,
                        helper: l10n.abbreviationHelp,
                        textInputAction: TextInputAction.done,
                        validator: _validator('abbreviation'),
                      ),
                  ],
                ),
                // A new entry starts active.
                if (initial != null)
                  FormSection(
                    l10n.accountStatusLabel,
                    [
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
                    ],
                    footer: _active
                        ? null
                        : _isCategory
                        ? l10n.categoryInactiveHelp
                        : l10n.unitInactiveHelp,
                  ),
                if (initial != null)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      pageSide(context),
                      24,
                      pageSide(context),
                      24,
                    ),
                    // Only unused entries can be deleted (the API refuses
                    // otherwise); used ones say why and point to Inactive.
                    child: initial.serviceCount == 0
                        ? SecondaryButton(
                            label: _isCategory
                                ? l10n.deleteCategory
                                : l10n.deleteUnit,
                            icon: Icons.delete_outline_rounded,
                            destructive: true,
                            onPressed: _saving ? null : () => _delete(initial),
                          )
                        : Text(
                            l10n.lookupInUse(initial.serviceCount),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
