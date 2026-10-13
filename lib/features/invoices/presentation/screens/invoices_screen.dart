import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../core/search/text_search.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../access/domain/entities/account_access.dart';
import '../../../access/presentation/controllers/account_access_provider.dart';
import '../../../proposals/presentation/widgets/line_item_row.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/usecases/invoice_usecases.dart';
import '../controllers/invoices_providers.dart';
import '../widgets/invoice_labels.dart';

/// One client account's invoices (or, with [contractId], one contract's),
/// latest issue date first, each with its status and amount. A toggle
/// narrows them to the overdue ones, and a search finds one. New ones come
/// from the dock's "+" (`invoice.edit`).
class InvoicesScreen extends ConsumerStatefulWidget {
  const InvoicesScreen({super.key, required this.clientId, this.contractId});

  /// Path segment under `/accounts/:clientId`.
  static const route = 'invoices';

  final String clientId;

  /// Only this contract's invoices (`?contract=`).
  final String? contractId;

  @override
  ConsumerState<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends ConsumerState<InvoicesScreen> {
  /// Only the overdue ones. The whole list is already here, so this
  /// filters on the phone.
  bool _overdueOnly = false;

  final _search = TextEditingController();

  /// The API can't search invoices, but the whole list is already here.
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final clientId = widget.clientId;
    final query = InvoiceQuery(
      clientId: clientId,
      contractId: widget.contractId,
    );
    final invoices = ref.watch(invoicesProvider(query));
    final canEdit =
        ref
            .watch(accountAccessProvider(clientId))
            .value
            ?.can(Permissions.invoiceEdit) ??
        false;
    final location = GoRouterState.of(context).matchedLocation;
    Future<void> refresh() => ref.refresh(invoicesProvider(query).future);

    return SpacePage(
      title: l10n.moduleInvoices,
      onRefresh: refresh,
      slivers: [
        PageBox(
          top: 4,
          child: SearchField(
            controller: _search,
            hint: l10n.searchInvoicesHint,
            onChanged: (text) => setState(() => _query = text),
          ),
        ),
        if (widget.contractId != null)
          PageBox(
            top: 4,
            child: Notice(
              message: l10n.invoicesOfOneContract,
              tone: NoticeTone.info,
            ),
          ),
        AsyncSlivers(
          value: invoices,
          onRetry: refresh,
          builder: (list) {
            if (list.isEmpty) {
              return MessageSliver(
                icon: Icons.receipt_long_outlined,
                title: l10n.noInvoicesYet,
                hint: canEdit && widget.contractId == null
                    ? l10n.noInvoicesYetHint
                    : null,
              );
            }
            final found = list
                .where((i) => matchesInvoice(context, i, _query))
                .toList();
            final overdue = found.where((i) => i.isOverdue).toList()
              // Longest overdue first: what to chase.
              ..sort(
                (a, b) => (b.daysOverdue ?? 0).compareTo(a.daysOverdue ?? 0),
              );
            final shown = _overdueOnly ? overdue : found;
            return SliverMainAxisGroup(
              slivers: [
                PageBox(
                  child: PillToggle<bool>(
                    semanticLabel: l10n.invoicesFilterLabel,
                    options: {
                      false: l10n.invoicesFilterAll,
                      true: l10n.invoicesFilterOverdue(overdue.length),
                    },
                    selected: _overdueOnly,
                    onChanged: (v) => setState(() => _overdueOnly = v),
                  ),
                ),
                if (shown.isEmpty && _query.trim().isNotEmpty)
                  MessageSliver(
                    icon: Icons.search_off_rounded,
                    title: l10n.noMatchesFound,
                    hint: l10n.noMatchesHint,
                  )
                else if (shown.isEmpty)
                  MessageSliver(
                    icon: Icons.verified_outlined,
                    title: l10n.noInvoicesOverdue,
                    hint: l10n.noInvoicesOverdueHint,
                  )
                else
                  PageBox(
                    child: ListCard(
                      children: [
                        for (final invoice in shown)
                          InvoiceRow(
                            invoice: invoice,
                            // The list's path, without `?contract=`.
                            onTap: () =>
                                context.push('$location/${invoice.id}'),
                          ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// An invoice as a list row: its number, when it's due (and what's left
/// on a partly paid one), its status as a pill, and its total.
class InvoiceRow extends StatelessWidget {
  const InvoiceRow({super.key, required this.invoice, this.onTap});

  final Invoice invoice;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final i = invoice;
    final largeText = isLargeText(context);
    final total = context.formatMoney(i.totalAmount);
    // Like contracts: the amount trails, or moves under the title at large
    // text so the title keeps the width to wrap.
    final details = [
      if (largeText) total,
      if (i.isOverdue)
        l10n.invoiceDaysOverdue(i.daysOverdue ?? 1)
      else if (!i.isVoided && i.status != InvoiceStatus.paid)
        l10n.invoiceDueOn(context.formatDate(i.dueDate)),
      if (i.status == InvoiceStatus.partiallyPaid)
        l10n.invoiceBalanceOf(context.formatMoney(i.balanceDue)),
    ];
    return ListRow(
      leading: const IconBadge(icon: Icons.receipt_long_outlined),
      title: i.invoiceNumber,
      muted: i.isVoided,
      subtitle: details.isEmpty ? null : details.join(' · '),
      tag: InvoiceStatusLabel(invoice: i),
      trailing: largeText ? null : Text(total, style: moneyStyle),
      onTap: onTap,
    );
  }
}

/// Whether [query] appears in [i]'s number, status, line items (or their
/// jobs), total, or issue and due dates as shown.
bool matchesInvoice(BuildContext context, Invoice i, String query) {
  final l10n = AppLocalizations.of(context);
  return matchesSearch(query, [
    i.invoiceNumber,
    if (i.isOverdue) l10n.invoiceStatusOverdue,
    l10n.invoiceStatus(i.status),
    for (final line in i.lineItems) ...[line.description, line.jobTitle],
    context.formatMoney(i.totalAmount),
    context.formatDate(i.issueDate),
    context.formatDate(i.dueDate),
  ]);
}
