import 'package:flutter/material.dart';

import '../../../../core/design/design.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/invoice.dart';

extension InvoiceNames on AppLocalizations {
  String invoiceStatus(InvoiceStatus status) => switch (status) {
    InvoiceStatus.draft => invoiceStatusDraft,
    InvoiceStatus.issued => invoiceStatusIssued,
    InvoiceStatus.partiallyPaid => invoiceStatusPartiallyPaid,
    InvoiceStatus.paid => invoiceStatusPaid,
    InvoiceStatus.voided => invoiceStatusVoid,
    InvoiceStatus.unknown => invoiceStatusUnknown,
  };

  String paymentMethod(PaymentMethod method) => switch (method) {
    PaymentMethod.cash => paymentMethodCash,
    PaymentMethod.check => paymentMethodCheck,
    PaymentMethod.card => paymentMethodCard,
    PaymentMethod.bankTransfer => paymentMethodBankTransfer,
    PaymentMethod.other => paymentMethodOther,
    PaymentMethod.unknown => paymentMethodUnknown,
  };
}

/// The status as a tinted pill with an icon, so it never depends on color
/// alone: draft muted (not sent yet), issued in navy, partly paid in
/// orange, paid in green, overdue in red, void muted.
class InvoiceStatusLabel extends StatelessWidget {
  const InvoiceStatusLabel({super.key, required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final (
      String label,
      IconData icon,
      Color color,
      Color background,
    ) = switch (invoice.status) {
      _ when invoice.isOverdue => (
        l10n.invoiceStatusOverdue,
        Icons.error_outline_rounded,
        c.danger,
        c.dangerSoft,
      ),
      InvoiceStatus.draft => (
        l10n.invoiceStatusDraft,
        Icons.edit_note_rounded,
        c.inkMuted,
        c.sunken,
      ),
      InvoiceStatus.issued => (
        l10n.invoiceStatusIssued,
        Icons.send_outlined,
        c.accent,
        c.accentSoft,
      ),
      InvoiceStatus.partiallyPaid => (
        l10n.invoiceStatusPartiallyPaid,
        Icons.timelapse_rounded,
        c.highlightInk,
        c.highlightSoft,
      ),
      InvoiceStatus.paid => (
        l10n.invoiceStatusPaid,
        Icons.check_rounded,
        c.successInk,
        c.successSoft,
      ),
      final status => (
        l10n.invoiceStatus(status),
        status == InvoiceStatus.voided
            ? Icons.block_rounded
            : Icons.help_outline_rounded,
        c.inkMuted,
        c.sunken,
      ),
    };
    return StatusPill(
      label: label,
      icon: icon,
      color: color,
      background: background,
    );
  }
}
