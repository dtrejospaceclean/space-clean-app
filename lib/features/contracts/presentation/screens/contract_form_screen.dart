import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../access/domain/entities/account_access.dart';
import '../../../access/presentation/controllers/account_access_provider.dart';
import '../../../clients/presentation/screens/accounts_screen.dart';
import '../../../jobs/presentation/controllers/jobs_providers.dart';
import '../../../proposals/domain/entities/proposal.dart';
import '../../../proposals/presentation/controllers/proposals_providers.dart';
import '../../../proposals/presentation/screens/proposals_screen.dart';
import '../../di/contracts_providers.dart';
import '../../domain/entities/contract.dart';
import '../../domain/usecases/contract_usecases.dart';
import '../controllers/contracts_providers.dart';
import 'contracts_screen.dart';

/// A new draft contract ([contractId] null) or an edit of one. A new one
/// can start from an approved proposal ([proposalId], or picked here),
/// which fills in its value. Needs `contract.edit`.
class ContractFormScreen extends ConsumerWidget {
  const ContractFormScreen({
    super.key,
    required this.clientId,
    this.contractId,
    this.proposalId,
  });

  final String clientId;
  final String? contractId;

  /// The approved proposal a new contract starts from.
  final String? proposalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    Widget waiting<T>(String title, AsyncValue<T> value, VoidCallback retry) =>
        SpacePage(
          title: title,
          slivers: [
            AsyncSlivers<T>(
              value: value,
              skeleton: SkeletonLayout.form,
              onRetry: retry,
              builder: (_) => const SliverToBoxAdapter(),
            ),
          ],
        );

    // Wait for what the fields start from.
    if (contractId case final id?) {
      return switch (ref.watch(contractProvider((clientId, id)))) {
        AsyncValue(value: final contract?) => _ContractForm(
          key: ValueKey(id),
          clientId: clientId,
          initial: contract,
        ),
        final other => waiting(
          l10n.editContract,
          other,
          () => ref.invalidate(contractProvider((clientId, id))),
        ),
      };
    }
    if (proposalId case final id?) {
      return switch (ref.watch(proposalProvider((clientId, id)))) {
        AsyncValue(value: final proposal?) => _ContractForm(
          key: ValueKey(id),
          clientId: clientId,
          proposal: proposal,
        ),
        final other => waiting(
          l10n.newContractTitle,
          other,
          () => ref.invalidate(proposalProvider((clientId, id))),
        ),
      };
    }
    return _ContractForm(clientId: clientId);
  }
}

class _ContractForm extends ConsumerStatefulWidget {
  const _ContractForm({
    super.key,
    required this.clientId,
    this.initial,
    this.proposal,
  });

  final String clientId;

  /// The contract edited; null to create.
  final Contract? initial;

  /// The proposal a new contract starts from.
  final Proposal? proposal;

  @override
  ConsumerState<_ContractForm> createState() => _ContractFormState();
}

class _ContractFormState extends ConsumerState<_ContractForm> {
  static final _moneyPattern = RegExp(r'^\d+(\.\d{1,2})?$');
  static final _wholePattern = RegExp(r'^\d+$');

  final _formKey = GlobalKey<FormState>();

  /// Only a new contract picks its proposal; it's fixed afterwards.
  late Proposal? _proposal = widget.proposal;
  late final _value = TextEditingController(
    text: widget.initial?.contractValue ?? widget.proposal?.price,
  );
  late DateTime _start = widget.initial?.startDate ?? _today;
  late DateTime? _expiration = widget.initial?.expirationDate;
  late bool _autoRenew = widget.initial?.autoRenew ?? false;
  late final _terms = TextEditingController(text: widget.initial?.paymentTerms);
  late final _notice = TextEditingController(
    text: widget.initial?.cancellationNoticeDays?.toString(),
  );

  bool _saving = false;
  Failure? _failure;

  bool get _creating => widget.initial == null;

  DateTime get _today {
    final now = ref.read(clockProvider)();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _value.dispose();
    _terms.dispose();
    _notice.dispose();
    super.dispose();
  }

  /// A server-side error for [field], if the last save had one.
  String? _serverError(String field) {
    if (_failure case ValidationFailure(:final fieldErrors)) {
      if (fieldErrors[field] case final errors? when errors.isNotEmpty) {
        return AppLocalizations.of(context).fieldError(errors.first);
      }
    }
    return null;
  }

  /// Shows a server-side error for [field] first, then the [local] rule.
  FormFieldValidator<String> _validator(
    String field, [
    String? Function(String value)? local,
  ]) =>
      (value) => _serverError(field) ?? local?.call(value ?? '');

  String? get _expirationError {
    final end = _expiration;
    if (end != null && end.isBefore(_start)) {
      return AppLocalizations.of(context).expirationBeforeStart;
    }
    return _serverError('expirationDate');
  }

  Future<void> _pickProposal(List<Proposal> approved) async {
    final l10n = AppLocalizations.of(context);
    final picked = await showAppChoice(
      context,
      title: l10n.contractProposalLabel,
      options: {for (final p in approved) p.id: _proposalLabel(l10n, p)},
    );
    if (picked == null || !mounted) return;
    final next = approved.where((p) => p.id == picked).firstOrNull;
    setState(() {
      // The value follows the proposal unless it was typed by hand.
      final previous = _proposal?.price;
      if (next != null &&
          (_value.text.trim().isEmpty || _value.text == previous)) {
        _value.text = next.price;
      }
      _proposal = next;
    });
  }

  Future<void> _pickStart() async {
    final picked = await showAppDatePicker(
      context,
      initial: _start,
      last: DateTime(_today.year + 10, 12, 31),
    );
    if (picked != null) setState(() => _start = picked);
  }

  Future<void> _pickExpiration() async {
    final picked = await showAppDatePicker(
      context,
      // A year's term, unless one is set already.
      initial:
          _expiration ??
          DateTime(_start.year + 1, _start.month, _start.day - 1),
      last: DateTime(_today.year + 20, 12, 31),
    );
    if (picked != null) setState(() => _expiration = picked);
  }

  Future<void> _save() async {
    setState(() => _failure = null);
    if (!_formKey.currentState!.validate() || _expirationError != null) {
      HapticFeedback.mediumImpact();
      return;
    }
    setState(() => _saving = true);
    try {
      final saved = await ref.read(saveContractProvider)(
        SaveContractParams(
          clientId: widget.clientId,
          contractId: widget.initial?.id,
          draft: ContractDraft(
            proposalId: _creating ? _proposal?.id : null,
            contractValue: _value.text,
            startDate: _start,
            expirationDate: _expiration,
            paymentTerms: _terms.text,
            autoRenew: _autoRenew,
            cancellationNoticeDays: _notice.text,
          ),
        ),
      );
      invalidateContracts(ref, widget.clientId);
      if (!mounted) return;
      if (_creating) {
        // A new contract has its own page.
        context.go(
          '${AccountsScreen.path}/${widget.clientId}/'
          '${ContractsScreen.route}/${saved.id}',
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final failure = _failure;
    final canPickProposal =
        _creating &&
        (ref
                .watch(accountAccessProvider(widget.clientId))
                .value
                ?.can(Permissions.proposalView) ??
            false);
    final approved = canPickProposal
        ? [
            for (final p
                in ref.watch(proposalsProvider(widget.clientId)).value ??
                    const <Proposal>[])
              if (p.isApproved) p,
          ]
        : const <Proposal>[];
    final side = pageSide(context);

    return SpacePage(
      title: _creating ? l10n.newContractTitle : l10n.editContract,
      bottom: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(side, 8, side, 12),
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
                if (failure != null && failure is! ValidationFailure)
                  Padding(
                    padding: EdgeInsets.fromLTRB(side, 4, side, 0),
                    child: Notice(message: l10n.failureMessage(failure)),
                  ),
                FormSection(l10n.sectionPricing, [
                  // Starting from a proposal is a choice only while
                  // creating, and only among the approved ones.
                  if (canPickProposal &&
                      (approved.isNotEmpty || _proposal != null))
                    PickerField(
                      label: l10n.contractProposalLabel,
                      value: switch (_proposal) {
                        final p? => _proposalLabel(l10n, p),
                        null => null,
                      },
                      errorText: _serverError('proposalId'),
                      onTap: _saving ? null : () => _pickProposal(approved),
                    ),
                  SpaceTextField(
                    label: l10n.contractValueLabel,
                    controller: _value,
                    enabled: !_saving,
                    hint: '2400',
                    helper: _proposal == null
                        ? null
                        : l10n.contractValueFromProposalHelp,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    textInputAction: TextInputAction.next,
                    validator: _validator(
                      'contractValue',
                      (v) => switch (v.trim()) {
                        '' => l10n.validationRequired,
                        final text when !_moneyPattern.hasMatch(text) =>
                          l10n.invalidPrice,
                        _ => null,
                      },
                    ),
                  ),
                  SpaceTextField(
                    label: l10n.paymentTermsLabel,
                    controller: _terms,
                    enabled: !_saving,
                    hint: l10n.paymentTermsHint,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    validator: _validator(
                      'paymentTerms',
                      (v) => v.trim().length > 100
                          ? l10n.validationMaxLength('100')
                          : null,
                    ),
                  ),
                ]),
                FormSection(l10n.sectionTerm, [
                  PickerField(
                    label: l10n.contractStartLabel,
                    icon: Icons.calendar_today_outlined,
                    value: context.formatDate(_start),
                    errorText: _serverError('startDate'),
                    onTap: _saving ? null : _pickStart,
                  ),
                  PickerField(
                    label: l10n.contractExpirationLabel,
                    icon: Icons.calendar_today_outlined,
                    value: switch (_expiration) {
                      final day? => context.formatDate(day),
                      null => null,
                    },
                    errorText: _expirationError,
                    onTap: _saving ? null : _pickExpiration,
                  ),
                  if (_expiration != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: LinkButton(
                        label: l10n.noEndDate,
                        onPressed: _saving
                            ? null
                            : () => setState(() => _expiration = null),
                      ),
                    ),
                  SwitchRow(
                    label: l10n.autoRenewLabel,
                    value: _autoRenew,
                    onChanged: _saving
                        ? null
                        : (v) => setState(() => _autoRenew = v),
                  ),
                  SpaceTextField(
                    label: l10n.cancellationNoticeLabel,
                    controller: _notice,
                    enabled: !_saving,
                    hint: '30',
                    helper: l10n.cancellationNoticeHelp,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textInputAction: TextInputAction.done,
                    validator: _validator(
                      'cancellationNoticeDays',
                      (v) =>
                          v.trim().isEmpty || _wholePattern.hasMatch(v.trim())
                          ? null
                          : l10n.invalidWholeNumber,
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// "Office cleaning and 1 more · Version 2".
String _proposalLabel(AppLocalizations l10n, Proposal p) =>
    '${proposalSummary(l10n, p)} · ${l10n.proposalVersion(p.versionNumber)}';
