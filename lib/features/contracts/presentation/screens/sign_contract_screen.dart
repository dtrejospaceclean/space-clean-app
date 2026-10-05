import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../jobs/presentation/controllers/jobs_providers.dart';
import '../../di/contracts_providers.dart';
import '../../domain/entities/contract.dart';
import '../../domain/usecases/contract_usecases.dart';
import '../controllers/contracts_providers.dart';
import 'contracts_screen.dart';

/// Records the signature, as the signed-in user, on a day up to today (an
/// earlier one for a contract signed on paper), and activates the contract.
/// Needs `contract.edit`.
class SignContractScreen extends ConsumerWidget {
  const SignContractScreen({
    super.key,
    required this.clientId,
    required this.contractId,
  });

  final String clientId;
  final String contractId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final key = (clientId, contractId);
    return switch (ref.watch(contractProvider(key))) {
      AsyncValue(value: final contract?) => _SignForm(
        key: ValueKey(contractId),
        clientId: clientId,
        contract: contract,
      ),
      final other => SpacePage(
        title: l10n.signContract,
        slivers: [
          AsyncSlivers<Contract>(
            value: other,
            onRetry: () => ref.invalidate(contractProvider(key)),
            builder: (_) => const SliverToBoxAdapter(),
          ),
        ],
      ),
    };
  }
}

class _SignForm extends ConsumerStatefulWidget {
  const _SignForm({super.key, required this.clientId, required this.contract});

  final String clientId;
  final Contract contract;

  @override
  ConsumerState<_SignForm> createState() => _SignFormState();
}

class _SignFormState extends ConsumerState<_SignForm> {
  late final DateTime _today = () {
    final now = ref.read(clockProvider)();
    return DateTime(now.year, now.month, now.day);
  }();
  late DateTime _signedOn = _today;
  bool _saving = false;
  Failure? _failure;

  Future<void> _pickDate() async {
    final picked = await showAppDatePicker(
      context,
      initial: _signedOn,
      last: _today,
    );
    if (picked != null) setState(() => _signedOn = picked);
  }

  Future<void> _sign() async {
    setState(() {
      _failure = null;
      _saving = true;
    });
    try {
      await ref.read(signContractProvider)(
        SignContractParams(
          clientId: widget.clientId,
          contractId: widget.contract.id,
          // Today is the server's default.
          signedDate: _signedOn == _today ? null : _signedOn,
        ),
      );
      invalidateContracts(ref, widget.clientId);
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
    final side = pageSide(context);

    return SpacePage(
      title: l10n.signContract,
      bottom: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(side, 8, side, 12),
          child: PrimaryButton(
            label: l10n.signContract,
            icon: Icons.draw_outlined,
            busy: _saving,
            onPressed: _sign,
          ),
        ),
      ),
      slivers: [
        if (failure != null)
          PageBox(top: 4, child: Notice(message: l10n.failureMessage(failure))),
        PageBox(
          top: 4,
          child: ListCard(children: [ContractRow(contract: widget.contract)]),
        ),
        SliverToBoxAdapter(
          child: FormSection(l10n.signatureLabel, [
            PickerField(
              label: l10n.signedOnLabel,
              icon: Icons.calendar_today_outlined,
              value: context.formatDate(_signedOn),
              onTap: _saving ? null : _pickDate,
            ),
          ], footer: l10n.signContractHelp),
        ),
      ],
    );
  }
}
