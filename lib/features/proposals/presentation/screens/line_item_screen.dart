import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../service_catalog/domain/entities/service_item.dart';
import '../../../service_catalog/presentation/controllers/service_catalog_providers.dart';
import '../../domain/entities/proposal.dart';

/// What the line item page hands back to the proposal form: the item as
/// edited, or null [item] to remove it.
class LineItemResult {
  const LineItemResult(this.item);

  final LineItemDraft? item;
}

/// Adds a line item to the proposal being edited ([initial] null) or
/// changes one. Nothing is saved here: "Done" hands the item back to the
/// form, whose Save sends the whole proposal.
class LineItemScreen extends ConsumerStatefulWidget {
  const LineItemScreen({super.key, this.initial});

  /// Path segment under a proposal form.
  static const route = 'item';

  final LineItemDraft? initial;

  @override
  ConsumerState<LineItemScreen> createState() => _LineItemScreenState();
}

class _LineItemScreenState extends ConsumerState<LineItemScreen> {
  /// Up to 2 decimals, like the API allows.
  static final _decimalPattern = RegExp(r'^\d+(\.\d{1,2})?$');

  final _formKey = GlobalKey<FormState>();
  late String? _serviceId = widget.initial?.serviceId;
  late final _description = TextEditingController(
    text: widget.initial?.description,
  );
  late final _quantity = TextEditingController(text: widget.initial?.quantity);
  late final _unitPrice = TextEditingController(
    text: widget.initial?.unitPrice,
  );
  Failure? _failure;

  @override
  void dispose() {
    _description.dispose();
    _quantity.dispose();
    _unitPrice.dispose();
    super.dispose();
  }

  /// Links a catalog service, filling the description and price unless
  /// they were typed by hand.
  Future<void> _pickService() async {
    final l10n = AppLocalizations.of(context);
    final List<ServiceItem> services;
    try {
      services = await ref.read(activeServicesProvider.future);
    } on Failure catch (f) {
      setState(() => _failure = f);
      return;
    }
    if (!mounted) return;
    final picked = await showAppChoice(
      context,
      title: l10n.lineItemServiceLabel,
      allowClear: _serviceId != null,
      options: {
        for (final s in services)
          s.id: switch (s.defaultPrice) {
            final price? =>
              '${s.name} · ${context.formatMoney(price)} '
                  '${l10n.perUnit(s.unit.short)}',
            null => s.name,
          },
      },
    );
    if (picked == null || !mounted) return;
    final previous = services.where((s) => s.id == _serviceId).firstOrNull;
    final next = services.where((s) => s.id == picked).firstOrNull;
    bool untouched(TextEditingController c, String? filled) =>
        c.text.trim().isEmpty || c.text == filled;
    setState(() {
      _failure = null;
      _serviceId = next?.id;
      if (next == null) return;
      if (untouched(_description, previous?.name)) {
        _description.text = next.name;
      }
      if (next.defaultPrice case final price?
          when untouched(_unitPrice, previous?.defaultPrice)) {
        _unitPrice.text = price;
      }
    });
  }

  void _done() {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }
    context.pop(
      LineItemResult(
        LineItemDraft(
          serviceId: _serviceId,
          description: _description.text.trim(),
          quantity: _quantity.text.trim(),
          unitPrice: _unitPrice.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final failure = _failure;
    final catalog = ref.watch(activeServicesProvider).value;
    final service = catalog?.where((s) => s.id == _serviceId).firstOrNull;
    String? decimal(String v, String message) => switch (v.trim()) {
      '' => l10n.validationRequired,
      final text => _decimalPattern.hasMatch(text) ? null : message,
    };
    const decimalKeyboard = TextInputType.numberWithOptions(decimal: true);
    final decimalOnly = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))];
    final total = centsToDecimal(
      lineTotalCents(_quantity.text, _unitPrice.text),
    );

    return SpacePage(
      title: widget.initial == null ? l10n.addLineItem : l10n.editLineItem,
      bottom: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            pageSide(context),
            8,
            pageSide(context),
            12,
          ),
          child: PrimaryButton(label: l10n.doneButton, onPressed: _done),
        ),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (failure != null)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      pageSide(context),
                      4,
                      pageSide(context),
                      0,
                    ),
                    child: Notice(message: l10n.failureMessage(failure)),
                  ),
                // One card: what the item is and what it costs.
                FormSection(null, [
                  PickerField(
                    label: l10n.lineItemServiceLabel,
                    value: switch (_serviceId) {
                      null => null,
                      _ when service != null => service.name,
                      // Linked to a service that's been retired since.
                      _ when catalog != null => l10n.serviceNotInCatalog,
                      _ => null,
                    },
                    onTap: _pickService,
                  ),
                  SpaceTextField(
                    label: l10n.lineItemDescriptionLabel,
                    controller: _description,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null,
                    validator: (v) => (v ?? '').trim().isEmpty
                        ? l10n.validationRequired
                        : null,
                  ),
                  SpaceTextField(
                    label: switch (service) {
                      final s? => l10n.lineItemQuantityUnitLabel(s.unit.short),
                      null => l10n.lineItemQuantityLabel,
                    },
                    controller: _quantity,
                    hint: '12000',
                    keyboardType: decimalKeyboard,
                    inputFormatters: decimalOnly,
                    onChanged: (_) => setState(() {}),
                    validator: (v) => decimal(v ?? '', l10n.invalidQuantity),
                  ),
                  SpaceTextField(
                    label: l10n.lineItemUnitPriceLabel,
                    controller: _unitPrice,
                    hint: '0.12',
                    keyboardType: decimalKeyboard,
                    inputFormatters: decimalOnly,
                    textInputAction: TextInputAction.done,
                    onChanged: (_) => setState(() {}),
                    validator: (v) => decimal(v ?? '', l10n.invalidPrice),
                  ),
                ], footer: l10n.lineItemTotal(context.formatMoney(total))),
                // Only an item already on the proposal can be taken off it.
                if (widget.initial != null)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      pageSide(context),
                      24,
                      pageSide(context),
                      0,
                    ),
                    child: SecondaryButton(
                      label: l10n.removeLineItem,
                      icon: Icons.delete_outline_rounded,
                      destructive: true,
                      onPressed: () => context.pop(const LineItemResult(null)),
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
