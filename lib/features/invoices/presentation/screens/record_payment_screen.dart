import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/domain/money.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../jobs/presentation/controllers/jobs_providers.dart';
import '../../di/invoices_providers.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/usecases/invoice_usecases.dart';
import '../controllers/invoices_providers.dart';
import '../widgets/invoice_labels.dart';
import 'invoices_screen.dart';

/// Records money received against an issued or partly paid invoice: the
/// amount (the balance due to start with, never more), how it came in, the
/// day (up to today) and a reference. The status follows on its own.
/// Needs `invoice.edit`.
class RecordPaymentScreen extends ConsumerWidget {
  const RecordPaymentScreen({
    super.key,
    required this.clientId,
    required this.invoiceId,
  });

  /// Path segment under an invoice's page.
  static const route = 'pay';

  final String clientId;
  final String invoiceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final key = (clientId, invoiceId);
    return switch (ref.watch(invoiceProvider(key))) {
      AsyncValue(value: final invoice?) => _PaymentForm(
        key: ValueKey(invoiceId),
        clientId: clientId,
        invoice: invoice,
      ),
      final other => SpacePage(
        title: l10n.recordPayment,
        slivers: [
          AsyncSlivers<Invoice>(
            value: other,
            onRetry: () => ref.invalidate(invoiceProvider(key)),
            builder: (_) => const SliverToBoxAdapter(),
          ),
        ],
      ),
    };
  }
}

class _PaymentForm extends ConsumerStatefulWidget {
  const _PaymentForm({
    super.key,
    required this.clientId,
    required this.invoice,
  });

  final String clientId;
  final Invoice invoice;

  @override
  ConsumerState<_PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends ConsumerState<_PaymentForm> {
  /// Up to 2 decimals, like the API allows.
  static final _decimalPattern = RegExp(r'^\d+(\.\d{1,2})?$');

  final _formKey = GlobalKey<FormState>();
  late final DateTime _today = () {
    final now = ref.read(clockProvider)();
    return DateTime(now.year, now.month, now.day);
  }();

  /// Most payments settle the invoice, so it starts at the balance.
  late final _amount = TextEditingController(
    text: centsToDecimal(toCents(widget.invoice.balanceDue)),
  );
  final _reference = TextEditingController();
  PaymentMethod? _method;
  late DateTime _paidOn = _today;

  /// Set once Save is tapped without a method.
  bool _methodMissing = false;
  bool _saving = false;
  Failure? _failure;

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
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

  Future<void> _pickDate() async {
    final picked = await showAppDatePicker(
      context,
      initial: _paidOn,
      last: _today,
    );
    if (picked != null) setState(() => _paidOn = picked);
  }

  Future<void> _save() async {
    setState(() {
      _failure = null;
      _methodMissing = _method == null;
    });
    final valid = _formKey.currentState!.validate();
    final method = _method;
    if (!valid || method == null) {
      HapticFeedback.mediumImpact();
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(recordPaymentProvider)(
        RecordPaymentParams(
          clientId: widget.clientId,
          invoiceId: widget.invoice.id,
          payment: PaymentDraft(
            amount: _amount.text,
            method: method,
            // Always the phone's day: the server's "today" is in UTC, which
            // is already tomorrow on a US evening.
            paymentDate: _paidOn,
            reference: _reference.text,
          ),
        ),
      );
      invalidateInvoices(ref, widget.clientId);
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
    final side = pageSide(context);
    final balance = context.formatMoney(widget.invoice.balanceDue);
    final balanceCents = toCents(widget.invoice.balanceDue);

    return SpacePage(
      title: l10n.recordPayment,
      bottom: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(side, 8, side, 12),
          child: PrimaryButton(
            label: l10n.recordPayment,
            icon: Icons.payments_outlined,
            busy: _saving,
            onPressed: _save,
          ),
        ),
      ),
      slivers: [
        if (failure != null && failure is! ValidationFailure)
          PageBox(top: 4, child: Notice(message: l10n.failureMessage(failure))),
        PageBox(
          top: 4,
          child: ListCard(children: [InvoiceRow(invoice: widget.invoice)]),
        ),
        SliverToBoxAdapter(
          child: Form(
            key: _formKey,
            child: FormSection(null, [
              SpaceTextField(
                label: l10n.paymentAmountLabel,
                controller: _amount,
                enabled: !_saving,
                helper: l10n.paymentAmountHelp(balance),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                validator: _validator('amount', (v) {
                  final text = v.trim();
                  if (!_decimalPattern.hasMatch(text) || toCents(text) <= 0) {
                    return l10n.invalidAmount;
                  }
                  return toCents(text) > balanceCents
                      ? l10n.paymentOverBalance(balance)
                      : null;
                }),
              ),
              _MethodPicker(
                selected: _method,
                missing: _methodMissing && _method == null,
                onPick: _saving ? null : (m) => setState(() => _method = m),
              ),
              PickerField(
                label: l10n.paymentDateLabel,
                icon: Icons.calendar_today_outlined,
                value: context.formatDate(_paidOn),
                onTap: _saving ? null : _pickDate,
              ),
              SpaceTextField(
                label: l10n.paymentReferenceLabel,
                controller: _reference,
                enabled: !_saving,
                hint: l10n.paymentReferenceHint,
                textInputAction: TextInputAction.done,
                validator: _validator(
                  'transactionReference',
                  (v) => v.trim().length > 200
                      ? l10n.validationMaxLength('200')
                      : null,
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

/// How the payment came in, as pills; says so when none is picked.
class _MethodPicker extends StatelessWidget {
  const _MethodPicker({
    required this.selected,
    required this.missing,
    required this.onPick,
  });

  final PaymentMethod? selected;
  final bool missing;
  final ValueChanged<PaymentMethod>? onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FieldLabel(l10n.paymentMethodLabel),
        ChoicePills<PaymentMethod>(
          options: {
            for (final m in PaymentMethod.choices) m: l10n.paymentMethod(m),
          },
          selected: {?selected},
          onToggle: onPick,
        ),
        if (missing) ...[
          const SizedBox(height: 6),
          Text(
            l10n.paymentMethodRequired,
            style: theme.textTheme.bodySmall?.copyWith(
              color: context.colors.danger,
            ),
          ),
        ],
      ],
    );
  }
}
