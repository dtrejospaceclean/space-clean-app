import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/widgets/adaptive.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../users/domain/entities/managed_user.dart';
import '../../di/clients_providers.dart';
import '../../domain/entities/client.dart';
import '../../domain/usecases/manage_clients.dart';
import '../controllers/clients_providers.dart';
import '../widgets/client_labels.dart';
import 'accounts_screen.dart';

/// Create an account ([clientId] null; owners and account managers) or edit
/// one (`info.edit` on it).
class AccountFormScreen extends ConsumerWidget {
  const AccountFormScreen({super.key, this.clientId});

  final String? clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final id = clientId;
    final client = id == null ? null : ref.watch(clientDetailProvider(id));
    final title = id == null ? l10n.newAccountTitle : l10n.editAccount;

    // Wait for the account when editing before building fields.
    if (client != null && !client.hasValue) {
      return SpacePage(
        title: title,
        slivers: [
          AsyncSlivers<Object?>(
            value: client,
            onRetry: () => ref.invalidate(clientDetailProvider(id!)),
            builder: (_) => const SliverToBoxAdapter(),
          ),
        ],
      );
    }
    return _AccountForm(
      key: ValueKey(id),
      title: title,
      initial: client?.value,
    );
  }
}

class _AccountForm extends ConsumerStatefulWidget {
  const _AccountForm({super.key, required this.title, this.initial});

  final String title;
  final Client? initial;

  @override
  ConsumerState<_AccountForm> createState() => _AccountFormState();
}

/// The three people-in-charge slots, by request-body field.
enum _Slot {
  accountManager('accountManagerUserId'),
  supervisor('supervisorUserId'),
  salesperson('salespersonUserId');

  const _Slot(this.field);

  final String field;
}

class _AccountFormState extends ConsumerState<_AccountForm> {
  final _formKey = GlobalKey<FormState>();
  late final _legalName = TextEditingController(
    text: widget.initial?.legalName,
  );
  late final _dba = TextEditingController(text: widget.initial?.dba);
  late final _industry = TextEditingController(text: widget.initial?.industry);
  late final _serviceType = TextEditingController(
    text: widget.initial?.serviceType,
  );
  late final _taxId = TextEditingController(text: widget.initial?.taxId);
  late final _address = TextEditingController(
    text: widget.initial?.billingAddress,
  );
  late final _city = TextEditingController(text: widget.initial?.billingCity);
  late final _state = TextEditingController(text: widget.initial?.billingState);
  late final _zip = TextEditingController(text: widget.initial?.billingZip);
  late ClientStatus _status = widget.initial?.status ?? ClientStatus.prospect;
  late final Map<_Slot, ClientAssignee?> _assignees = {
    _Slot.accountManager: widget.initial?.accountManager,
    _Slot.supervisor: widget.initial?.supervisor,
    _Slot.salesperson: widget.initial?.salesperson,
  };

  bool _saving = false;
  Failure? _failure;

  @override
  void dispose() {
    for (final c in [
      _legalName,
      _dba,
      _industry,
      _serviceType,
      _taxId,
      _address,
      _city,
      _state,
      _zip,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// A server-side error for [field], shown by that field's validator.
  String? _serverError(String field) => switch (_failure) {
    ValidationFailure(:final fieldErrors) => switch (fieldErrors[field]) {
      final errors? when errors.isNotEmpty => AppLocalizations.of(
        context,
      ).fieldError(errors.first),
      _ => null,
    },
    _ => null,
  };

  FormFieldValidator<String> _validator(
    String field, [
    String? Function(String value)? local,
  ]) =>
      (value) => _serverError(field) ?? local?.call(value ?? '');

  ClientDraft _draft() {
    final initial = widget.initial;
    bool emptied(String? before, TextEditingController now) =>
        (before ?? '').isNotEmpty && now.text.trim().isEmpty;
    // Assignees are sent only when they changed, so an untouched one who
    // has since been deactivated doesn't block the save.
    String? changedAssignee(_Slot slot, ClientAssignee? before) {
      final now = _assignees[slot];
      return now != null && now.id != before?.id ? now.id : null;
    }

    final cleared = <String>{
      if (initial != null) ...{
        if (emptied(initial.dba, _dba)) 'dba',
        if (emptied(initial.industry, _industry)) 'industry',
        if (emptied(initial.serviceType, _serviceType)) 'serviceType',
        if (emptied(initial.taxId, _taxId)) 'taxId',
        if (emptied(initial.billingAddress, _address)) 'billingAddress',
        if (emptied(initial.billingCity, _city)) 'billingCity',
        if (emptied(initial.billingState, _state)) 'billingState',
        if (emptied(initial.billingZip, _zip)) 'billingZip',
        if (initial.accountManager != null &&
            _assignees[_Slot.accountManager] == null)
          _Slot.accountManager.field,
        if (initial.supervisor != null && _assignees[_Slot.supervisor] == null)
          _Slot.supervisor.field,
        if (initial.salesperson != null &&
            _assignees[_Slot.salesperson] == null)
          _Slot.salesperson.field,
      },
    };
    return ClientDraft(
      legalName: _legalName.text,
      dba: _dba.text,
      industry: _industry.text,
      serviceType: _serviceType.text,
      status: initial == null || _status != initial.status ? _status : null,
      taxId: _taxId.text,
      billingAddress: _address.text,
      billingCity: _city.text,
      billingState: _state.text,
      billingZip: _zip.text,
      accountManagerUserId: changedAssignee(
        _Slot.accountManager,
        initial?.accountManager,
      ),
      supervisorUserId: changedAssignee(_Slot.supervisor, initial?.supervisor),
      salespersonUserId: changedAssignee(
        _Slot.salesperson,
        initial?.salesperson,
      ),
      cleared: cleared,
    );
  }

  Future<void> _save() async {
    setState(() => _failure = null);
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }
    setState(() => _saving = true);
    try {
      final initial = widget.initial;
      final saved = initial == null
          ? await ref.read(createClientProvider)(_draft())
          : await ref.read(updateClientProvider)(
              UpdateClientParams(id: initial.id, draft: _draft()),
            );
      ref
        ..invalidate(myClientsProvider)
        ..invalidate(clientDetailProvider(saved.id));
      if (!mounted) return;
      if (initial != null) {
        context.pop();
      } else if (ref.read(seesAllAccountsProvider)) {
        context.pushReplacement('${AccountsScreen.path}/${saved.id}');
      } else {
        // Creating an account doesn't make its creator a member.
        setState(() => _saving = false);
        await _showCreatedNotice();
        if (mounted) context.pop();
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

  Future<void> _showCreatedNotice() {
    final l10n = AppLocalizations.of(context);
    return showAdaptiveDialog<void>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(l10n.accountCreatedTitle),
        content: Text(l10n.accountCreatedNotMember),
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

  Future<void> _pickAssignee(
    _Slot slot,
    String label,
    List<ManagedUser> users,
  ) async {
    final current = _assignees[slot];
    final picked = await showAppChoice(
      context,
      title: label,
      allowClear: current != null,
      options: {
        // Keep the current one even if they no longer qualify.
        if (current != null) current.id: current.name,
        for (final u in users) u.id: u.name,
      },
    );
    if (picked == null) return;
    setState(() {
      if (picked.isEmpty) {
        _assignees[slot] = null;
      } else if (picked != current?.id) {
        final user = users.firstWhere((u) => u.id == picked);
        _assignees[slot] = ClientAssignee(
          id: user.id,
          name: user.name,
          email: user.email,
        );
      }
    });
  }

  /// A titled white card of fields, with page margins.
  Widget _section(String title, List<Widget> fields, {String? footer}) =>
      Padding(
        padding: EdgeInsets.fromLTRB(
          pageSide(context),
          12,
          pageSide(context),
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(title: title),
            SpaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, f) in fields.indexed) ...[
                    if (i > 0) const SizedBox(height: 12),
                    f,
                  ],
                  if (footer != null) ...[
                    const SizedBox(height: 10),
                    Text(footer, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ],
              ),
            ),
          ],
        ),
      );

  Widget _text(
    String label,
    TextEditingController controller,
    String field, {
    String? hint,
    String? helper,
    TextCapitalization capitalization = TextCapitalization.sentences,
    TextInputType? keyboardType,
    String? Function(String value)? validate,
  }) => SpaceTextField(
    label: label,
    controller: controller,
    enabled: !_saving,
    hint: hint,
    helper: helper,
    textCapitalization: capitalization,
    keyboardType: keyboardType,
    validator: _validator(field, validate),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final failure = _failure;
    // Staff only: a client's own people can't be put in charge.
    final assignable = ref.watch(assignableUsersProvider);
    final users = assignable.value
        ?.where((u) => u.isActive && u.userType == UserType.internal)
        .toList();
    // Loaded, but this user can't list users: pickers stay read-only.
    final cannotAssign = assignable.hasValue && assignable.value == null;

    Widget assignee(_Slot slot, String label) => PickerField(
      label: label,
      icon: Icons.person_outline_rounded,
      value: _assignees[slot]?.name,
      onTap: _saving || users == null
          ? null
          : () => _pickAssignee(slot, label, users),
    );

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
                if (failure != null && failure is! ValidationFailure)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      pageSide(context),
                      4,
                      pageSide(context),
                      0,
                    ),
                    child: Notice(message: l10n.failureMessage(failure)),
                  ),
                _section(l10n.sectionGeneral, [
                  _text(
                    l10n.legalNameLabel,
                    _legalName,
                    'legalName',
                    capitalization: TextCapitalization.words,
                    validate: (v) =>
                        v.trim().isEmpty ? l10n.validationRequired : null,
                  ),
                  _text(
                    l10n.dbaLabel,
                    _dba,
                    'dba',
                    helper: l10n.dbaHelp,
                    capitalization: TextCapitalization.words,
                  ),
                  _text(l10n.industryLabel, _industry, 'industry'),
                  _text(
                    l10n.serviceTypeLabel,
                    _serviceType,
                    'serviceType',
                    hint: l10n.serviceTypeHint,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.accountStatusLabel,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      PillToggle<ClientStatus>(
                        semanticLabel: l10n.accountStatusLabel,
                        track: context.colors.sunken,
                        options: {
                          for (final s in [
                            ClientStatus.prospect,
                            ClientStatus.active,
                            ClientStatus.inactive,
                          ])
                            s: l10n.clientStatusLabel(s),
                        },
                        selected: _status,
                        onChanged: (s) {
                          if (!_saving) setState(() => _status = s);
                        },
                      ),
                    ],
                  ),
                ]),
                _section(l10n.sectionBilling, [
                  _text(
                    l10n.taxIdLabel,
                    _taxId,
                    'taxId',
                    capitalization: TextCapitalization.characters,
                  ),
                  _text(
                    l10n.billingAddressLabel,
                    _address,
                    'billingAddress',
                    keyboardType: TextInputType.streetAddress,
                  ),
                  _text(
                    l10n.billingCityLabel,
                    _city,
                    'billingCity',
                    capitalization: TextCapitalization.words,
                  ),
                  _text(
                    l10n.billingStateLabel,
                    _state,
                    'billingState',
                    capitalization: TextCapitalization.words,
                  ),
                  _text(l10n.billingZipLabel, _zip, 'billingZip'),
                ]),
                _section(l10n.sectionPeopleInCharge, [
                  assignee(_Slot.accountManager, l10n.roleAccountManager),
                  assignee(_Slot.supervisor, l10n.roleSupervisor),
                  assignee(_Slot.salesperson, l10n.salespersonLabel),
                ], footer: cannotAssign ? l10n.assigneesReadOnly : null),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
