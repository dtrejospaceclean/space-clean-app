import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../clients/presentation/screens/accounts_screen.dart';
import '../../../service_catalog/presentation/controllers/service_catalog_providers.dart';
import '../../../shell/presentation/page_action.dart';
import '../../di/proposals_providers.dart';
import '../../domain/entities/proposal.dart';
import '../../domain/usecases/proposal_usecases.dart';
import '../controllers/proposals_providers.dart';
import '../widgets/line_item_row.dart';
import '../widgets/proposal_stage_label.dart';
import 'line_item_screen.dart';
import 'proposals_screen.dart';

/// Starts a negotiation ([ProposalSave.create]), edits the current version
/// in place ([ProposalSave.edit]) or adds a version on top of it
/// ([ProposalSave.newVersion], prefilled from [proposalId]). All need
/// `proposal.edit`.
class ProposalFormScreen extends ConsumerWidget {
  const ProposalFormScreen({
    super.key,
    required this.clientId,
    required this.mode,
    this.proposalId,
  }) : assert((proposalId == null) == (mode == ProposalSave.create));

  final String clientId;
  final ProposalSave mode;
  final String? proposalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final title = switch (mode) {
      ProposalSave.create => l10n.newProposalTitle,
      ProposalSave.edit => l10n.editProposal,
      ProposalSave.newVersion => l10n.newVersionTitle,
    };
    final id = proposalId;
    if (id == null) {
      return _ProposalForm(clientId: clientId, mode: mode, title: title);
    }
    // Wait for the version before building fields.
    return switch (ref.watch(proposalProvider((clientId, id)))) {
      AsyncData(value: final proposal) => _ProposalForm(
        key: ValueKey(id),
        clientId: clientId,
        mode: mode,
        title: title,
        initial: proposal,
      ),
      final other => SpacePage(
        title: title,
        slivers: [
          AsyncSlivers<Proposal>(
            value: other,
            onRetry: () => ref.invalidate(proposalProvider((clientId, id))),
            builder: (_) => const SliverToBoxAdapter(),
          ),
        ],
      ),
    };
  }
}

class _ProposalForm extends ConsumerStatefulWidget {
  const _ProposalForm({
    super.key,
    required this.clientId,
    required this.mode,
    required this.title,
    this.initial,
  });

  final String clientId;
  final ProposalSave mode;
  final String title;
  final Proposal? initial;

  @override
  ConsumerState<_ProposalForm> createState() => _ProposalFormState();
}

class _ProposalFormState extends ConsumerState<_ProposalForm>
    with PageActionHost {
  /// Up to 2 decimals, like the API allows.
  static final _decimalPattern = RegExp(r'^\d+(\.\d{1,2})?$');
  static final _itemErrorKey = RegExp(r'^lineItems\.(\d+)\.');

  final _formKey = GlobalKey<FormState>();
  late ProposalStage _stage = switch (widget.initial?.stage) {
    final stage? when ProposalStage.open.contains(stage) => stage,
    _ => ProposalStage.lead,
  };
  late DateTime? _validUntil = widget.initial?.validUntil;
  late final _price = TextEditingController(text: widget.initial?.agreedPrice);

  /// A new version describes what changed, so it starts with no note.
  late final _note = TextEditingController(
    text: widget.mode == ProposalSave.edit ? widget.initial?.versionNote : null,
  );

  /// Added and changed on their own page ([LineItemScreen]).
  late List<LineItemDraft> _items = [
    for (final item in widget.initial?.lineItems ?? const <ProposalLineItem>[])
      LineItemDraft(
        serviceId: item.serviceId,
        description: item.description,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
      ),
  ];

  bool _saving = false;
  Failure? _failure;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // New items come from the "+" beside the dock, like everything else
    // the app adds.
    registerPageAction(
      location: GoRouterState.of(context).matchedLocation,
      label: AppLocalizations.of(context).addLineItem,
      onPressed: () {
        if (!_saving) _openItem();
      },
    );
  }

  @override
  void dispose() {
    _price.dispose();
    _note.dispose();
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

  Future<void> _pickStage() async {
    final l10n = AppLocalizations.of(context);
    final picked = await showAppChoice(
      context,
      title: l10n.pipelineStageLabel,
      allowClear: false,
      options: {
        for (final stage in ProposalStage.open)
          stage.wire: l10n.proposalStage(stage),
      },
    );
    if (picked != null) {
      setState(() => _stage = ProposalStage.fromWire(picked));
    }
  }

  Future<void> _pickDate() async {
    final picked = await showAppDatePicker(context, initial: _validUntil);
    if (picked != null) setState(() => _validUntil = picked);
  }

  /// Opens the line item page for item [index], or for a new item when
  /// null, and applies what it hands back.
  Future<void> _openItem([int? index]) async {
    final here = GoRouterState.of(context).matchedLocation;
    final result = await context.push<LineItemResult>(
      '$here/${LineItemScreen.route}',
      extra: index == null ? null : _items[index],
    );
    if (result == null || !mounted) return;
    setState(() {
      // Server errors about the items are stale once they change.
      if (_failure is ValidationFailure) _failure = null;
      _items = [..._items];
      switch ((index, result.item)) {
        case (null, final item?):
          _items.add(item);
        case (final i?, final item?):
          _items[i] = item;
        case (final i?, null):
          _items.removeAt(i);
        case (null, null):
          break;
      }
    });
  }

  Future<void> _save() async {
    setState(() => _failure = null);
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }
    setState(() => _saving = true);
    try {
      final saved = await ref.read(saveProposalProvider)(
        SaveProposalParams(
          clientId: widget.clientId,
          mode: widget.mode,
          proposalId: widget.initial?.id,
          draft: ProposalDraft(
            stage: _stage,
            agreedPrice: _price.text,
            validUntil: _validUntil,
            versionNote: _note.text,
            lineItems: _items,
          ),
        ),
      );
      invalidateProposals(ref, widget.clientId);
      if (!mounted) return;
      switch (widget.mode) {
        case ProposalSave.edit:
          context.pop();
        // A new negotiation or version has its own page.
        case ProposalSave.create || ProposalSave.newVersion:
          context.go(
            '${AccountsScreen.path}/${widget.clientId}/'
            '${ProposalsScreen.route}/${saved.id}',
          );
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

  /// Server errors about line items have no field on this page, so they
  /// read "Item 2: …" above the form.
  List<String> _itemErrors(AppLocalizations l10n) => switch (_failure) {
    ValidationFailure(:final fieldErrors) => [
      for (final MapEntry(:key, :value) in fieldErrors.entries)
        if (_itemErrorKey.firstMatch(key) case final match?
            when value.isNotEmpty)
          l10n.lineItemError(
            int.parse(match.group(1)!) + 1,
            l10n.fieldError(value.first),
          ),
    ],
    _ => const [],
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final failure = _failure;
    final catalog = ref.watch(activeServicesProvider).value;
    final total = centsToDecimal(
      _items.fold(0, (sum, i) => sum + lineTotalCents(i.quantity, i.unitPrice)),
    );
    final notices = [
      if (failure != null && failure is! ValidationFailure)
        l10n.failureMessage(failure),
      ..._itemErrors(l10n),
    ];

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
                for (final message in notices)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      pageSide(context),
                      4,
                      pageSide(context),
                      4,
                    ),
                    child: Notice(message: message),
                  ),
                // Everything in one card: the stage and note, the items
                // (added with the "+" beside the dock), then the price
                // agreed for them and how long it holds.
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    pageSide(context),
                    12,
                    pageSide(context),
                    0,
                  ),
                  child: SpaceCard(
                    // Fields carry the card's padding; item rows bring their
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
                              PickerField(
                                label: l10n.pipelineStageLabel,
                                value: l10n.proposalStage(_stage),
                                onTap: _saving ? null : _pickStage,
                              ),
                              const SizedBox(height: 12),
                              SpaceTextField(
                                label: l10n.versionNoteLabel,
                                controller: _note,
                                enabled: !_saving,
                                hint: l10n.versionNoteHint,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                validator: _validator('versionNote'),
                              ),
                            ],
                          ),
                        ),
                        for (final (i, item) in _items.indexed) ...[
                          const Divider(
                            indent: SpaceSpace.card,
                            endIndent: SpaceSpace.card,
                          ),
                          LineItemRow(
                            description: item.description,
                            quantity: item.quantity,
                            unitPrice: item.unitPrice,
                            lineTotal: centsToDecimal(
                              lineTotalCents(item.quantity, item.unitPrice),
                            ),
                            unit: catalog
                                ?.where((s) => s.id == item.serviceId)
                                .firstOrNull
                                ?.unit
                                .short,
                            onTap: _saving ? null : () => _openItem(i),
                          ),
                        ],
                        if (_items.isNotEmpty)
                          const Divider(
                            indent: SpaceSpace.card,
                            endIndent: SpaceSpace.card,
                          ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            SpaceSpace.card,
                            12,
                            SpaceSpace.card,
                            SpaceSpace.card,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SpaceTextField(
                                label: l10n.agreedPriceLabel,
                                controller: _price,
                                enabled: !_saving,
                                hint: '2400',
                                helper: l10n.agreedPriceHelp,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.]'),
                                  ),
                                ],
                                textInputAction: TextInputAction.done,
                                validator: _validator('agreedPrice', (v) {
                                  final text = v.trim();
                                  return text.isEmpty ||
                                          _decimalPattern.hasMatch(text)
                                      ? null
                                      : l10n.invalidPrice;
                                }),
                              ),
                              const SizedBox(height: 12),
                              PickerField(
                                label: l10n.validUntilLabel,
                                icon: Icons.calendar_today_outlined,
                                value: switch (_validUntil) {
                                  final day? => context.formatDate(day),
                                  null => null,
                                },
                                onTap: _saving ? null : _pickDate,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${l10n.lineItemsTotalLabel}: '
                                '${context.formatMoney(total)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              if (widget.mode == ProposalSave.newVersion) ...[
                                const SizedBox(height: 4),
                                Text(
                                  l10n.newVersionHelp,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ],
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
