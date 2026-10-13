import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/domain/money.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../access/domain/entities/account_access.dart';
import '../../../access/presentation/controllers/account_access_provider.dart';
import '../../../clients/presentation/screens/accounts_screen.dart';
import '../../../contracts/domain/entities/contract.dart';
import '../../../contracts/presentation/controllers/contracts_providers.dart';
import '../../../contracts/presentation/screens/contracts_screen.dart';
import '../../../jobs/presentation/controllers/jobs_providers.dart';
import '../../../proposals/presentation/widgets/line_item_row.dart';
import '../../../shell/presentation/page_action.dart';
import '../../di/invoices_providers.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/usecases/invoice_usecases.dart';
import '../controllers/invoices_providers.dart';
import 'invoice_line_screen.dart';
import 'invoices_screen.dart';

/// Starts a draft invoice ([invoiceId] null) or edits one. Both need
/// `invoice.edit`, and only a draft can change. The contract is optional;
/// an empty number or due date is left to the server (the next
/// `INV-<year>-<n>`, the contract's payment terms).
class InvoiceFormScreen extends ConsumerWidget {
  const InvoiceFormScreen({super.key, required this.clientId, this.invoiceId});

  final String clientId;
  final String? invoiceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final id = invoiceId;
    if (id == null) {
      return _InvoiceForm(clientId: clientId, title: l10n.newInvoiceTitle);
    }
    // Wait for the invoice before building fields.
    return switch (ref.watch(invoiceProvider((clientId, id)))) {
      AsyncValue(value: final invoice?) => _InvoiceForm(
        key: ValueKey(id),
        clientId: clientId,
        title: l10n.editInvoice,
        initial: invoice,
      ),
      final other => SpacePage(
        title: l10n.editInvoice,
        slivers: [
          AsyncSlivers<Invoice>(
            value: other,
            skeleton: SkeletonLayout.form,
            onRetry: () => ref.invalidate(invoiceProvider((clientId, id))),
            builder: (_) => const SliverToBoxAdapter(),
          ),
        ],
      ),
    };
  }
}

class _InvoiceForm extends ConsumerStatefulWidget {
  const _InvoiceForm({
    super.key,
    required this.clientId,
    required this.title,
    this.initial,
  });

  final String clientId;
  final String title;
  final Invoice? initial;

  @override
  ConsumerState<_InvoiceForm> createState() => _InvoiceFormState();
}

class _InvoiceFormState extends ConsumerState<_InvoiceForm>
    with PageActionHost {
  static final _lineErrorKey = RegExp(r'^lineItems\.(\d+)\.');

  final _formKey = GlobalKey<FormState>();
  bool get _creating => widget.initial == null;

  late final DateTime _today = () {
    final now = ref.read(clockProvider)();
    return DateTime(now.year, now.month, now.day);
  }();

  late String? _contractId = widget.initial?.contractId;

  /// Whether the contract was picked by hand (or cleared). Until then a
  /// new invoice takes the account's only open contract.
  late bool _contractTouched = !_creating;
  late final _number = TextEditingController(
    text: widget.initial?.invoiceNumber,
  );
  late DateTime _issueDate = widget.initial?.issueDate ?? _today;

  /// Empty on a new invoice: the contract's terms set it.
  late DateTime? _dueDate = widget.initial?.dueDate;

  /// Added and changed on their own page ([InvoiceLineScreen]).
  late List<InvoiceLineDraft> _lines = [
    for (final line in widget.initial?.lineItems ?? const <InvoiceLine>[])
      InvoiceLineDraft(
        jobId: line.jobId,
        jobTitle: line.jobTitle,
        description: line.description,
        quantity: line.quantity,
        unitPrice: line.unitPrice,
      ),
  ];

  bool _saving = false;
  Failure? _failure;

  /// Why the contract picker didn't open (the account has none).
  String? _note;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // New lines come from the "+" beside the dock, like everything else the
    // app adds.
    registerPageAction(
      location: GoRouterState.of(context).matchedLocation,
      label: AppLocalizations.of(context).addLineItem,
      text: AppLocalizations.of(context).addLineItemShort,
      onPressed: () {
        if (!_saving) _openLine();
      },
    );
  }

  @override
  void dispose() {
    _number.dispose();
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
      // The only unique column here is the number.
      case ServerFailure(messageKey: 'errors.unique_violation')
          when field == 'invoiceNumber':
        return l10n.invoiceNumberTaken;
      case _:
    }
    return local?.call(value ?? '');
  };

  /// The contract an invoice bills under: open ones, plus the one it has.
  List<Contract> _contractOptions(List<Contract> all) => [
    for (final c in all)
      if (!c.isCancelled || c.id == widget.initial?.contractId) c,
  ];

  String _contractLabel(Contract c) =>
      [contractTerm(context, c), ?c.paymentTerms].join(' · ');

  Future<void> _pickContract(String? current) async {
    final l10n = AppLocalizations.of(context);
    final List<Contract> contracts;
    try {
      contracts = _contractOptions(
        await ref.read(contractsProvider(widget.clientId).future),
      );
    } on Failure catch (f) {
      if (mounted) setState(() => _failure = f);
      return;
    }
    if (!mounted) return;
    setState(() {
      if (_failure is! ValidationFailure) _failure = null;
      _note = contracts.isEmpty && current == null
          ? l10n.invoiceNoContracts
          : null;
    });
    if (_note != null) return;
    final picked = await showAppChoice(
      context,
      title: l10n.invoiceContractLabel,
      allowClear: current != null,
      options: {for (final c in contracts) c.id: _contractLabel(c)},
    );
    if (picked == null || !mounted) return;
    setState(() {
      _contractTouched = true;
      _contractId = picked.isEmpty ? null : picked;
    });
  }

  Future<void> _pickIssueDate() async {
    final picked = await showAppDatePicker(context, initial: _issueDate);
    if (picked != null) setState(() => _issueDate = picked);
  }

  Future<void> _pickDueDate() async {
    final picked = await showAppDatePicker(
      context,
      initial: _dueDate ?? _issueDate,
      last: DateTime(_today.year + 2, 12, 31),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  /// Opens the line page for line [index], or for a new line when null,
  /// and applies what it hands back.
  Future<void> _openLine([int? index]) async {
    final here = GoRouterState.of(context).matchedLocation;
    final result = await context.push<InvoiceLineResult>(
      '$here/${InvoiceLineScreen.route}',
      extra: index == null ? null : _lines[index],
    );
    if (result == null || !mounted) return;
    setState(() {
      // Server errors about the lines are stale once they change.
      if (_failure is ValidationFailure) _failure = null;
      _lines = [..._lines];
      switch ((index, result.line)) {
        case (null, final line?):
          _lines.add(line);
        case (final i?, final line?):
          _lines[i] = line;
        case (final i?, null):
          _lines.removeAt(i);
        case (null, null):
          break;
      }
    });
  }

  void _removeLine(int index) => setState(() {
    if (_failure is ValidationFailure) _failure = null;
    _lines = [..._lines]..removeAt(index);
  });

  bool get _dueBeforeIssue => _dueDate?.isBefore(_issueDate) ?? false;

  Future<void> _save(String? contractId) async {
    setState(() => _failure = null);
    if (!_formKey.currentState!.validate() || _dueBeforeIssue) {
      HapticFeedback.mediumImpact();
      return;
    }
    setState(() => _saving = true);
    try {
      final saved = await ref.read(saveInvoiceProvider)(
        SaveInvoiceParams(
          clientId: widget.clientId,
          invoiceId: widget.initial?.id,
          draft: InvoiceDraft(
            contractId: contractId,
            invoiceNumber: _number.text,
            issueDate: _issueDate,
            dueDate: _dueDate,
            lineItems: _lines,
          ),
        ),
      );
      invalidateInvoices(ref, widget.clientId);
      if (!mounted) return;
      if (_creating) {
        // A new invoice has its own page.
        context.go(
          '${AccountsScreen.path}/${widget.clientId}/'
          '${InvoicesScreen.route}/${saved.id}',
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

  /// Server errors with no field on this page: lines read "Item 2: …",
  /// the rest show as they are.
  List<String> _notices(AppLocalizations l10n) => switch (_failure) {
    null => const [],
    ValidationFailure(:final fieldErrors) => [
      for (final MapEntry(:key, :value) in fieldErrors.entries)
        if (value.isNotEmpty)
          if (_lineErrorKey.firstMatch(key) case final match?)
            l10n.lineItemError(
              int.parse(match.group(1)!) + 1,
              l10n.fieldError(value.first),
            )
          else if (key != 'invoiceNumber')
            l10n.fieldError(value.first),
    ],
    ServerFailure(messageKey: 'errors.unique_violation') => const [],
    final other => [l10n.failureMessage(other)],
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final side = pageSide(context);
    final canViewContracts =
        ref
            .watch(accountAccessProvider(widget.clientId))
            .value
            ?.can(Permissions.contractView) ??
        false;
    // Watching names the picked contract and keeps the list alive for the
    // picker; a single open one is a new invoice's default.
    final contracts = canViewContracts
        ? _contractOptions(
            ref.watch(contractsProvider(widget.clientId)).value ??
                const <Contract>[],
          )
        : const <Contract>[];
    final contractId = _contractTouched
        ? _contractId
        : _contractId ?? (contracts.length == 1 ? contracts.single.id : null);
    final contract = contracts.where((c) => c.id == contractId).firstOrNull;
    final total = centsToDecimal(
      _lines.fold(0, (sum, l) => sum + lineTotalCents(l.quantity, l.unitPrice)),
    );
    final notices = _notices(l10n);
    final inset = const EdgeInsets.symmetric(horizontal: SpaceSpace.card);

    return SpacePage(
      title: widget.title,
      bottom: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(side, 8, side, 12),
          child: PrimaryButton(
            label: l10n.saveButton,
            busy: _saving,
            onPressed: () => _save(contractId),
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
                if (_note case final note?)
                  Padding(
                    padding: EdgeInsets.fromLTRB(side, 4, side, 4),
                    child: Notice(message: note, tone: NoticeTone.info),
                  ),
                // Everything in one card: what it bills under and when,
                // then the lines (added with the "+" beside the dock) and
                // their total.
                Padding(
                  padding: EdgeInsets.fromLTRB(side, 12, side, 0),
                  child: SpaceCard(
                    // Fields carry the card's padding; line rows bring their
                    // own, so both line up at the same inset.
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            SpaceSpace.card,
                            SpaceSpace.card,
                            SpaceSpace.card,
                            12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (canViewContracts) ...[
                                PickerField(
                                  label: l10n.invoiceContractLabel,
                                  value: switch (contract) {
                                    final c? => _contractLabel(c),
                                    null => null,
                                  },
                                  onTap: _saving
                                      ? null
                                      : () => _pickContract(contractId),
                                ),
                                const SizedBox(height: 12),
                              ],
                              SpaceTextField(
                                label: l10n.invoiceNumberLabel,
                                controller: _number,
                                enabled: !_saving,
                                hint: 'INV-${_issueDate.year}-00001',
                                helper: _creating
                                    ? l10n.invoiceNumberHelp
                                    : null,
                                textCapitalization:
                                    TextCapitalization.characters,
                                validator: _validator('invoiceNumber', (v) {
                                  final text = v.trim();
                                  if (!_creating && text.isEmpty) {
                                    return l10n.validationRequired;
                                  }
                                  return text.length > 50
                                      ? l10n.validationMaxLength('50')
                                      : null;
                                }),
                              ),
                              const SizedBox(height: 12),
                              PickerField(
                                label: l10n.invoiceIssueDateLabel,
                                icon: Icons.calendar_today_outlined,
                                value: context.formatDate(_issueDate),
                                onTap: _saving ? null : _pickIssueDate,
                              ),
                              const SizedBox(height: 12),
                              PickerField(
                                label: l10n.invoiceDueDateLabel,
                                icon: Icons.event_outlined,
                                value: switch (_dueDate) {
                                  final day? => context.formatDate(day),
                                  null => null,
                                },
                                errorText: _dueBeforeIssue
                                    ? l10n.invoiceDueBeforeIssue
                                    : null,
                                onTap: _saving ? null : _pickDueDate,
                              ),
                              if (_creating && _dueDate == null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  l10n.invoiceDueDateHelp,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Headed even when empty, so the form shows where
                        // lines go and that "+" adds them.
                        Divider(indent: inset.left, endIndent: inset.right),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            SpaceSpace.card,
                            12,
                            SpaceSpace.card,
                            0,
                          ),
                          child: FieldLabel(l10n.sectionLineItems),
                        ),
                        if (_lines.isEmpty)
                          _EmptyLines(onTap: _saving ? null : _openLine),
                        for (final (i, line) in _lines.indexed) ...[
                          if (i > 0)
                            Divider(indent: inset.left, endIndent: inset.right),
                          _SwipeToRemove(
                            // Drafts have no id; each is its own object.
                            key: ObjectKey(line),
                            enabled: !_saving,
                            onRemove: () => _removeLine(i),
                            child: LineItemRow(
                              description: line.description,
                              quantity: line.quantity,
                              unitPrice: line.unitPrice,
                              lineTotal: centsToDecimal(
                                lineTotalCents(line.quantity, line.unitPrice),
                              ),
                              detail: switch (line.jobTitle) {
                                final title? => l10n.invoiceLineJob(title),
                                null => null,
                              },
                              onTap: _saving ? null : () => _openLine(i),
                            ),
                          ),
                        ],
                        Divider(indent: inset.left, endIndent: inset.right),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            SpaceSpace.card,
                            12,
                            SpaceSpace.card,
                            SpaceSpace.card,
                          ),
                          child: Text(
                            '${l10n.invoiceTotalLabel}: '
                            '${context.formatMoney(total)}',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700)
                                .merge(moneyStyle),
                          ),
                        ),
                      ],
                    ),
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

/// Where lines go before there are any: points to the "+" beside the dock,
/// and opens a new line itself for anyone who taps it instead.
class _EmptyLines extends StatelessWidget {
  const _EmptyLines({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l10n.lineItemsEmpty,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              SpaceSpace.card,
              4,
              SpaceSpace.card,
              12,
            ),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                l10n.lineItemsEmpty,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: context.colors.inkMuted),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A line row that's removed by swiping it toward the start (right to
/// left). Screen readers get the same as a "Remove item" action.
class _SwipeToRemove extends StatelessWidget {
  const _SwipeToRemove({
    required super.key,
    required this.enabled,
    required this.onRemove,
    required this.child,
  });

  final bool enabled;
  final VoidCallback onRemove;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return Semantics(
      customSemanticsActions: {
        if (enabled)
          CustomSemanticsAction(label: l10n.removeLineItem): onRemove,
      },
      child: Dismissible(
        key: key!,
        direction: enabled
            ? DismissDirection.endToStart
            : DismissDirection.none,
        onDismissed: (_) {
          HapticFeedback.mediumImpact();
          onRemove();
        },
        background: const SizedBox.shrink(),
        secondaryBackground: ColoredBox(
          color: c.dangerSoft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpaceSpace.card),
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Icon(
                Icons.delete_outline_rounded,
                color: c.danger,
                size: 24,
              ),
            ),
          ),
        ),
        child: child,
      ),
    );
  }
}
