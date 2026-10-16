import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/domain/money.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../core/widgets/adaptive.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../access/domain/entities/account_access.dart';
import '../../../access/presentation/controllers/account_access_provider.dart';
import '../../../contracts/presentation/screens/contracts_screen.dart';
import '../../../proposals/presentation/widgets/line_item_row.dart';
import '../../di/invoices_providers.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/usecases/invoice_usecases.dart';
import '../controllers/invoices_providers.dart';
import '../widgets/invoice_labels.dart';
import 'invoice_pdf_screen.dart';
import 'record_payment_screen.dart';
import 'send_invoice_screen.dart';

/// One invoice: a head card (number, status, total, dates, what's been
/// paid), its lines, its payments and its contract. With `invoice.edit`, a
/// draft can be edited, issued or deleted; an issued one takes payments,
/// each of which can be voided, and the invoice itself can be voided once
/// nothing counts as paid.
class InvoiceScreen extends ConsumerStatefulWidget {
  const InvoiceScreen({
    super.key,
    required this.clientId,
    required this.invoiceId,
  });

  final String clientId;
  final String invoiceId;

  @override
  ConsumerState<InvoiceScreen> createState() => _InvoiceScreenState();
}

/// What's in flight: nothing else on the page starts until it settles.
enum _Busy { issue, voidInvoice, delete, voidPayment }

class _InvoiceScreenState extends ConsumerState<InvoiceScreen> {
  _Busy? _busy;

  /// Who the invoice was just emailed to, to say so on the page.
  List<String>? _sentTo;

  /// Opens the send page, and says who it went to once it's back.
  Future<void> _openSend(String here) async {
    final sentTo = await context.push<List<String>>(
      '$here/${SendInvoiceScreen.route}',
    );
    if (sentTo != null && mounted) setState(() => _sentTo = sentTo);
  }

  InvoiceRef get _ref =>
      InvoiceRef(clientId: widget.clientId, invoiceId: widget.invoiceId);

  Future<bool> _confirm({
    required String title,
    required String body,
    required String action,
    required String keep,
    bool destructive = true,
  }) async {
    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(title),
        content: Text(body),
        actions: [
          adaptiveAction(
            context,
            label: keep,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          adaptiveAction(
            context,
            label: action,
            destructive: destructive,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    return confirmed == true && mounted;
  }

  Future<void> _showMessage(String message) {
    final l10n = AppLocalizations.of(context);
    return showAdaptiveDialog<void>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        content: Text(message),
        actions: [
          adaptiveAction(
            context,
            label: l10n.doneButton,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  /// Asks first, then runs [run] ([kind]) and reloads.
  Future<void> _act(
    _Busy kind, {
    required String title,
    required String body,
    required String action,
    required String keep,
    required Future<void> Function() run,
    bool destructive = true,
  }) async {
    if (!await _confirm(
      title: title,
      body: body,
      action: action,
      keep: keep,
      destructive: destructive,
    )) {
      return;
    }
    setState(() => _busy = kind);
    try {
      await run();
      invalidateInvoices(ref, widget.clientId);
    } on Failure catch (f) {
      if (mounted) {
        await _showMessage(AppLocalizations.of(context).failureMessage(f));
      }
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  /// Asks first, then deletes the draft and goes back to [list].
  Future<void> _delete(String list) async {
    final l10n = AppLocalizations.of(context);
    if (!await _confirm(
      title: l10n.deleteInvoiceConfirmTitle,
      body: l10n.deleteInvoiceConfirmBody,
      action: l10n.deleteButton,
      keep: l10n.keepInvoice,
    )) {
      return;
    }
    setState(() => _busy = _Busy.delete);
    try {
      await ref.read(deleteInvoiceProvider)(_ref);
      if (!mounted) return;
      // Leave before the lists reload, so this page doesn't flash "not
      // found" on its way out.
      context.go(list);
      invalidateInvoices(ref, widget.clientId);
    } on Failure catch (f) {
      if (!mounted) return;
      setState(() => _busy = null);
      await _showMessage(l10n.failureMessage(f));
    }
  }

  /// Voiding needs nothing paid, so with payments still counting it says
  /// what to do first instead of asking.
  Future<void> _voidInvoice(Invoice invoice) {
    final l10n = AppLocalizations.of(context);
    if (invoice.hasPayments) return _showMessage(l10n.invoicesHasPayments);
    return _act(
      _Busy.voidInvoice,
      title: l10n.voidInvoiceConfirmTitle,
      body: l10n.voidInvoiceConfirmBody,
      action: l10n.voidInvoice,
      keep: l10n.keepInvoice,
      run: () => ref.read(voidInvoiceProvider)(_ref),
    );
  }

  Future<void> _voidPayment(Payment payment) {
    final l10n = AppLocalizations.of(context);
    return _act(
      _Busy.voidPayment,
      title: l10n.voidPaymentConfirmTitle,
      body: l10n.voidPaymentConfirmBody,
      action: l10n.voidPayment,
      keep: l10n.keepPayment,
      run: () => ref.read(voidPaymentProvider)(
        VoidPaymentParams(
          clientId: widget.clientId,
          invoiceId: widget.invoiceId,
          paymentId: payment.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final key = (widget.clientId, widget.invoiceId);
    final invoice = ref.watch(invoiceProvider(key));
    final access = ref.watch(accountAccessProvider(widget.clientId)).value;
    final canEdit = access?.can(Permissions.invoiceEdit) ?? false;
    final canViewContracts = access?.can(Permissions.contractView) ?? false;
    final here = GoRouterState.of(context).matchedLocation;
    final list = here.substring(0, here.lastIndexOf('/'));
    final account = list.substring(0, list.lastIndexOf('/'));
    final busy = _busy != null;
    Future<void> refresh() => ref.refresh(invoiceProvider(key).future);

    return PopScope(
      canPop: !busy,
      child: AbsorbPointer(
        absorbing: busy,
        child: SpacePage(
          title: l10n.invoiceTitle,
          onRefresh: busy ? null : refresh,
          slivers: [
            AsyncSlivers(
              value: invoice,
              skeleton: SkeletonLayout.detail,
              onRetry: refresh,
              builder: (i) {
                final editable = canEdit && i.isEditable;
                final payable = canEdit && i.canPay;
                final voidable = canEdit && i.canVoid;
                final sendable = canEdit && i.canSend;
                final primary = (editable && i.canIssue) || payable;
                return SliverMainAxisGroup(
                  slivers: [
                    PageBox(
                      top: 4,
                      child: _HeadCard(
                        invoice: i,
                        onEdit: editable
                            ? () => context.push('$here/edit')
                            : null,
                      ),
                    ),
                    if (_sentTo case final sentTo?)
                      PageBox(
                        child: Notice(
                          message: l10n.invoiceSentTo(sentTo.join(', ')),
                          tone: NoticeTone.success,
                        ),
                      ),
                    if (i.isVoided)
                      PageBox(
                        child: Notice(
                          message: l10n.voidInvoiceNotice,
                          tone: NoticeTone.info,
                        ),
                      )
                    else if (editable && !i.canIssue)
                      PageBox(
                        child: Notice(
                          message: l10n.invoiceEmptyNotice,
                          tone: NoticeTone.info,
                        ),
                      ),
                    PageBox(top: 16, child: CapsHeader(l10n.sectionLineItems)),
                    PageBox(
                      top: 0,
                      child: ListCard(
                        children: [
                          if (i.lineItems.isEmpty)
                            _Quiet(l10n.lineItemsEmpty)
                          else
                            for (final line in i.lineItems)
                              LineItemRow(
                                description: line.description,
                                quantity: line.quantity,
                                unitPrice: line.unitPrice,
                                lineTotal: line.lineTotal,
                                detail: switch (line.jobTitle) {
                                  final title? => l10n.invoiceLineJob(title),
                                  null => null,
                                },
                              ),
                        ],
                      ),
                    ),
                    // A draft hasn't been sent, so nothing can be paid yet.
                    if (!i.isDraft) ...[
                      PageBox(top: 16, child: CapsHeader(l10n.sectionPayments)),
                      PageBox(
                        top: 0,
                        child: ListCard(
                          children: [
                            if (i.payments.isEmpty)
                              _Quiet(l10n.noPaymentsYet)
                            else
                              for (final p in i.payments)
                                _PaymentRow(
                                  payment: p,
                                  onTap: canEdit && !p.isVoided && !i.isVoided
                                      ? () => _voidPayment(p)
                                      : null,
                                ),
                          ],
                        ),
                      ),
                    ],
                    if (i.contractId case final contractId?) ...[
                      PageBox(top: 16, child: CapsHeader(l10n.sectionDetails)),
                      PageBox(
                        top: 0,
                        child: ListCard(
                          children: [
                            FactRow(
                              label: l10n.invoiceContractLabel,
                              value:
                                  i.contractPaymentTerms ?? l10n.contractTitle,
                              onTap: canViewContracts
                                  ? () => context.push(
                                      '$account/${ContractsScreen.route}/'
                                      '$contractId',
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (editable && i.canIssue)
                      PageBox(
                        top: 24,
                        child: PrimaryButton(
                          label: l10n.issueInvoice,
                          icon: Icons.send_outlined,
                          busy: _busy == _Busy.issue,
                          onPressed: busy
                              ? null
                              : () => _act(
                                  _Busy.issue,
                                  title: l10n.issueInvoiceConfirmTitle,
                                  body: l10n.issueInvoiceConfirmBody,
                                  action: l10n.issueInvoice,
                                  keep: l10n.notYet,
                                  destructive: false,
                                  run: () =>
                                      ref.read(issueInvoiceProvider)(_ref),
                                ),
                        ),
                      ),
                    if (payable)
                      PageBox(
                        top: 24,
                        child: PrimaryButton(
                          label: l10n.recordPayment,
                          icon: Icons.payments_outlined,
                          onPressed: busy
                              ? null
                              : () => context.push(
                                  '$here/${RecordPaymentScreen.route}',
                                ),
                        ),
                      ),
                    // The document itself, and (once issued) emailing it.
                    PageBox(
                      top: primary ? 12 : 24,
                      child: SecondaryButton(
                        label: l10n.viewPdf,
                        icon: Icons.picture_as_pdf_outlined,
                        onPressed: busy
                            ? null
                            : () => context.push(
                                '$here/${InvoicePdfScreen.route}',
                              ),
                      ),
                    ),
                    if (sendable)
                      PageBox(
                        top: 12,
                        child: SecondaryButton(
                          label: l10n.sendByEmail,
                          icon: Icons.send_outlined,
                          onPressed: busy ? null : () => _openSend(here),
                        ),
                      ),
                    // Quiet actions at the foot: voiding what was issued,
                    // deleting a draft.
                    if (voidable || editable)
                      PageBox(
                        top: 12,
                        child: Column(
                          children: [
                            if (voidable)
                              LinkButton(
                                label: l10n.voidInvoice,
                                icon: Icons.block_rounded,
                                destructive: true,
                                onPressed: busy ? null : () => _voidInvoice(i),
                              ),
                            if (editable)
                              LinkButton(
                                label: l10n.deleteInvoice,
                                icon: Icons.delete_outline_rounded,
                                destructive: true,
                                onPressed: busy ? null : () => _delete(list),
                              ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// The head of the page: the number with Edit at the corner, the status,
/// the total, the issue and due dates, then how much is paid and what's
/// left (red once overdue).
class _HeadCard extends StatelessWidget {
  const _HeadCard({required this.invoice, required this.onEdit});

  final Invoice invoice;

  /// Null hides Edit.
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final i = invoice;
    final large = isLargeText(context);
    final edit = switch (onEdit) {
      final onEdit? => PillButton(
        label: l10n.editButton,
        icon: Icons.edit_outlined,
        tooltip: l10n.editInvoice,
        onPressed: onEdit,
      ),
      null => null,
    };
    final total = toCents(i.totalAmount);
    final paid = toCents(i.amountPaid);
    // Money only moves once it's issued, and not on a void one.
    final showsPayments = !i.isDraft && !i.isVoided;

    return SpaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  i.invoiceNumber,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (edit != null && !large) ...[const SizedBox(width: 12), edit],
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: InvoiceStatusLabel(invoice: i),
          ),
          const SizedBox(height: 12),
          Text(
            context.formatMoney(i.totalAmount),
            style: theme.textTheme.headlineSmall
                ?.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: i.isVoided ? context.colors.inkMuted : null,
                )
                .merge(moneyStyle),
          ),
          CapsHeader(l10n.invoiceTotalLabel, header: false),
          if (edit != null && large) ...[
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerLeft, child: edit),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(),
          ),
          _FactPair(
            first: Fact(
              label: l10n.invoiceIssueDateLabel,
              value: context.formatDate(i.issueDate),
            ),
            second: Fact(
              label: l10n.invoiceDueDateLabel,
              value: context.formatDate(i.dueDate),
            ),
          ),
          if (showsPayments) ...[
            const SizedBox(height: 16),
            SpaceProgressBar(
              value: total == 0 ? 0 : paid / total,
              color: i.status == InvoiceStatus.paid
                  ? context.colors.success
                  : null,
              semanticsLabel: l10n.invoicePaidOf(
                context.formatMoney(i.amountPaid),
                context.formatMoney(i.totalAmount),
              ),
            ),
            const SizedBox(height: 8),
            ExcludeSemantics(
              child: Text(
                l10n.invoicePaidOf(
                  context.formatMoney(i.amountPaid),
                  context.formatMoney(i.totalAmount),
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: context.colors.inkMuted,
                ),
              ),
            ),
            const SizedBox(height: 4),
            if (i.status == InvoiceStatus.paid)
              _Line(
                icon: Icons.check_circle_outline_rounded,
                label: l10n.invoicePaidInFull,
                color: context.colors.successInk,
              )
            else
              _Line(
                icon: i.isOverdue
                    ? Icons.error_outline_rounded
                    : Icons.account_balance_wallet_outlined,
                label: [
                  '${l10n.invoiceBalanceLabel}: '
                      '${context.formatMoney(i.balanceDue)}',
                  if (i.isOverdue) l10n.invoiceDaysOverdue(i.daysOverdue ?? 1),
                ].join(' · '),
                color: i.isOverdue ? context.colors.danger : context.colors.ink,
              ),
          ],
        ],
      ),
    );
  }
}

/// Two facts side by side, or stacked at large text.
class _FactPair extends StatelessWidget {
  const _FactPair({required this.first, required this.second});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) => isLargeText(context)
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [first, const SizedBox(height: 12), second],
        )
      : Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            const SizedBox(width: 16),
            Expanded(child: second),
          ],
        );
}

/// A line with an icon, in [color], bold.
class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 18, color: color),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: color, fontWeight: FontWeight.w600),
        ),
      ),
    ],
  );
}

/// A payment as a row: how it came in and its reference, the day, and the
/// amount. A voided one is muted and tagged.
class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.payment, this.onTap});

  final Payment payment;

  /// Voids it; null when it can't be.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = payment;
    final large = isLargeText(context);
    final amount = context.formatMoney(p.amount);
    return ListRow(
      leading: const IconBadge(icon: Icons.payments_outlined),
      title: [l10n.paymentMethod(p.method), ?p.reference].join(' · '),
      subtitle: [
        if (large) amount,
        context.formatDate(p.paymentDate),
      ].join(' · '),
      muted: p.isVoided,
      tag: p.isVoided
          ? StatusPill(
              label: l10n.paymentVoidedTag,
              icon: Icons.block_rounded,
              color: context.colors.inkMuted,
              background: context.colors.sunken,
            )
          : null,
      trailing: large ? null : Text(amount, style: moneyStyle),
      chevron: false,
      onTap: onTap,
    );
  }
}

/// A muted line standing in for an empty list inside a card.
class _Quiet extends StatelessWidget {
  const _Quiet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 56),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SpaceSpace.card,
        vertical: 14,
      ),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: context.colors.inkMuted),
        ),
      ),
    ),
  );
}
