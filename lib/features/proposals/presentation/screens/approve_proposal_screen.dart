import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../l10n/app_localizations.dart';
import '../../di/proposals_providers.dart';
import '../../domain/entities/proposal.dart';
import '../../domain/usecases/proposal_usecases.dart';
import '../controllers/proposals_providers.dart';
import '../widgets/line_item_row.dart';
import 'proposals_screen.dart';

/// Approves the current version at an agreed price, which starts from the
/// version's own price or else its line items' total. Needs
/// `proposal.edit`.
class ApproveProposalScreen extends ConsumerWidget {
  const ApproveProposalScreen({
    super.key,
    required this.clientId,
    required this.proposalId,
  });

  final String clientId;
  final String proposalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final key = (clientId, proposalId);
    return switch (ref.watch(proposalProvider(key))) {
      AsyncData(value: final proposal) => _ApproveForm(
        key: ValueKey(proposalId),
        clientId: clientId,
        proposal: proposal,
      ),
      final other => SpacePage(
        title: l10n.approveProposalTitle,
        slivers: [
          AsyncSlivers<Proposal>(
            value: other,
            onRetry: () => ref.invalidate(proposalProvider(key)),
            builder: (_) => const SliverToBoxAdapter(),
          ),
        ],
      ),
    };
  }
}

class _ApproveForm extends ConsumerStatefulWidget {
  const _ApproveForm({
    super.key,
    required this.clientId,
    required this.proposal,
  });

  final String clientId;
  final Proposal proposal;

  @override
  ConsumerState<_ApproveForm> createState() => _ApproveFormState();
}

class _ApproveFormState extends ConsumerState<_ApproveForm> {
  static final _moneyPattern = RegExp(r'^\d+(\.\d{1,2})?$');

  final _formKey = GlobalKey<FormState>();
  late final _price = TextEditingController(
    text:
        widget.proposal.agreedPrice ??
        (widget.proposal.lineItems.isEmpty
            ? null
            : widget.proposal.lineItemsTotal),
  );
  bool _saving = false;
  Failure? _failure;

  @override
  void dispose() {
    _price.dispose();
    super.dispose();
  }

  Future<void> _approve() async {
    setState(() => _failure = null);
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(approveProposalProvider)(
        ApproveProposalParams(
          clientId: widget.clientId,
          proposalId: widget.proposal.id,
          agreedPrice: _price.text,
        ),
      );
      invalidateProposals(ref, widget.clientId);
      if (mounted) context.pop();
    } on Failure catch (f) {
      HapticFeedback.mediumImpact();
      if (!mounted) return;
      setState(() => _failure = f);
      _formKey.currentState!.validate();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = widget.proposal;
    final failure = _failure;

    return SpacePage(
      title: l10n.approveProposalTitle,
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
            label: l10n.approveButton,
            icon: Icons.check_rounded,
            busy: _saving,
            onPressed: _approve,
          ),
        ),
      ),
      slivers: [
        if (failure != null && failure is! ValidationFailure)
          PageBox(top: 4, child: Notice(message: l10n.failureMessage(failure))),
        PageBox(
          top: 4,
          child: ListCard(
            children: [
              ProposalRow(proposal: p),
              ListRow(
                title: l10n.lineItemsTotalLabel,
                trailing: Text(
                  context.formatMoney(p.lineItemsTotal),
                  style: moneyStyle,
                ),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Form(
            key: _formKey,
            child: FormSection(l10n.sectionPricing, [
              SpaceTextField(
                label: l10n.agreedPriceLabel,
                controller: _price,
                enabled: !_saving,
                hint: '2400',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                textInputAction: TextInputAction.done,
                validator: (v) {
                  if (_failure case ValidationFailure(:final fieldErrors)) {
                    if (fieldErrors['agreedPrice'] case final errors?
                        when errors.isNotEmpty) {
                      return l10n.fieldError(errors.first);
                    }
                  }
                  return switch ((v ?? '').trim()) {
                    '' => l10n.validationRequired,
                    final text when !_moneyPattern.hasMatch(text) =>
                      l10n.invalidPrice,
                    _ => null,
                  };
                },
              ),
            ], footer: l10n.approveHelp),
          ),
        ),
      ],
    );
  }
}
