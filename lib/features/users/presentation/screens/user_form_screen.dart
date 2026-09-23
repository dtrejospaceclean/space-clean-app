import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../core/l10n/role_names.dart';
import '../../../../core/widgets/adaptive.dart';
import '../../../../core/widgets/app/app_form.dart';
import '../../../../core/widgets/app/app_page.dart';
import '../../../../core/widgets/app/async_slivers.dart';
import '../../../../core/widgets/threshold/threshold_notice.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../password_reset/domain/entities/password_policy.dart';
import '../../di/users_providers.dart';
import '../../domain/entities/managed_user.dart';
import '../../domain/entities/role_info.dart';
import '../../domain/usecases/user_usecases.dart';
import '../controllers/users_providers.dart';
import '../widgets/user_labels.dart';

/// Create a user ([userId] null) or edit one. Owners only.
class UserFormScreen extends ConsumerWidget {
  const UserFormScreen({super.key, this.userId});

  final String? userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final id = userId;
    final roles = ref.watch(rolesProvider);
    final user = id == null ? null : ref.watch(userProvider(id));
    final title = id == null ? l10n.newUserTitle : l10n.editUser;

    // Wait for the roles (and the user when editing) before building fields.
    final ready = switch ((roles, user)) {
      (AsyncData(value: final r), null) => (r, null),
      (AsyncData(value: final r), AsyncData(value: final u)) => (r, u),
      _ => null,
    };
    if (ready == null) {
      final failed = roles.hasError ? roles : user;
      return AppPage(
        title: title,
        grouped: true,
        slivers: [
          AsyncSlivers<Object?>(
            value: failed ?? const AsyncLoading(),
            onRetry: () {
              ref.invalidate(rolesProvider);
              if (id != null) ref.invalidate(userProvider(id));
            },
            builder: (_) => const SliverToBoxAdapter(),
          ),
        ],
      );
    }
    return _UserForm(
      key: ValueKey(id),
      title: title,
      roles: ready.$1,
      initial: ready.$2,
    );
  }
}

class _UserForm extends ConsumerStatefulWidget {
  const _UserForm({
    super.key,
    required this.title,
    required this.roles,
    this.initial,
  });

  final String title;
  final List<RoleInfo> roles;
  final ManagedUser? initial;

  @override
  ConsumerState<_UserForm> createState() => _UserFormState();
}

class _UserFormState extends ConsumerState<_UserForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.name);
  late final _email = TextEditingController(text: widget.initial?.email);
  final _password = TextEditingController();
  late final _phone = TextEditingController(text: widget.initial?.phoneNumber);
  late final _employeeId = TextEditingController(
    text: widget.initial?.employeeId,
  );
  late final _payRate = TextEditingController(text: widget.initial?.payRate);
  late final _emergencyName = TextEditingController(
    text: widget.initial?.emergencyContactName,
  );
  late final _emergencyPhone = TextEditingController(
    text: widget.initial?.emergencyContactPhone,
  );
  late String? _employmentType = widget.initial?.employmentType;
  late DateTime? _hireDate = widget.initial?.hireDate;
  late final Set<String> _roleIds = {
    ...?widget.initial?.roles.map((r) => r.id),
  };

  bool _saving = false;
  Failure? _failure;

  bool get _creating => widget.initial == null;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _moneyPattern = RegExp(r'^\d+(\.\d{1,2})?$');

  @override
  void dispose() {
    for (final c in [
      _name,
      _email,
      _password,
      _phone,
      _employeeId,
      _payRate,
      _emergencyName,
      _emergencyPhone,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// A server-side error for [field], shown by that field's validator.
  String? _serverError(String field) {
    final l10n = AppLocalizations.of(context);
    return switch (_failure) {
      ValidationFailure(:final fieldErrors) => switch (fieldErrors[field]) {
        final errors? when errors.isNotEmpty => l10n.fieldError(errors.first),
        _ => null,
      },
      ServerFailure(messageKey: 'users.email_taken') when field == 'email' =>
        l10n.usersEmailTaken,
      _ => null,
    };
  }

  FormFieldValidator<String> _validator(
    String field, [
    String? Function(String value)? local,
  ]) =>
      (value) => _serverError(field) ?? local?.call(value ?? '');

  UserDraft _draft() {
    final initial = widget.initial;
    // On edit, an emptied optional field is sent as null to clear it.
    final cleared = <String>{
      if (initial != null) ...{
        if ((initial.phoneNumber ?? '').isNotEmpty &&
            _phone.text.trim().isEmpty)
          'phoneNumber',
        if ((initial.employeeId ?? '').isNotEmpty &&
            _employeeId.text.trim().isEmpty)
          'employeeId',
        if ((initial.payRate ?? '').isNotEmpty && _payRate.text.trim().isEmpty)
          'payRate',
        if (initial.employmentType != null && _employmentType == null)
          'employmentType',
        if (initial.hireDate != null && _hireDate == null) 'hireDate',
        if ((initial.emergencyContactName ?? '').isNotEmpty &&
            _emergencyName.text.trim().isEmpty)
          'emergencyContactName',
        if ((initial.emergencyContactPhone ?? '').isNotEmpty &&
            _emergencyPhone.text.trim().isEmpty)
          'emergencyContactPhone',
      },
    };
    return UserDraft(
      name: _name.text,
      email: _email.text,
      password: _password.text.isEmpty ? null : _password.text,
      phoneNumber: _phone.text,
      employeeId: _employeeId.text,
      employmentType: _employmentType,
      payRate: _payRate.text,
      hireDate: _hireDate,
      emergencyContactName: _emergencyName.text,
      emergencyContactPhone: _emergencyPhone.text,
      roleIds: _creating ? _roleIds.toList() : null,
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
          ? await ref.read(createUserProvider)(_draft())
          : await ref.read(updateUserProvider)(
              UpdateUserParams(
                id: initial.id,
                draft: _draft(),
                roleIds: _roleIds.toList(),
              ),
            );
      ref
        ..invalidate(usersProvider)
        ..invalidate(userProvider(saved.id))
        ..invalidate(rolesProvider);
      if (!mounted) return;
      if (initial == null) {
        context.pushReplacement(
          '${GoRouterState.of(context).matchedLocation.replaceAll(RegExp(r'/new$'), '')}/${saved.id}',
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
    final cupertino = useCupertino(context);
    final failure = _failure;
    // Field-level failures show on their fields; everything else on top.
    final showBanner =
        failure != null &&
        failure is! ValidationFailure &&
        failure.messageKey != 'users.email_taken';

    final save = _saving
        ? const Padding(
            padding: EdgeInsets.all(12),
            child: SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator.adaptive(strokeWidth: 2),
            ),
          )
        : cupertino
        ? CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _save,
            child: Text(
              l10n.saveButton,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          )
        : TextButton(onPressed: _save, child: Text(l10n.saveButton));

    return AppPage(
      title: widget.title,
      grouped: true,
      actions: [save],
      slivers: [
        SliverToBoxAdapter(
          child: Form(
            key: _formKey,
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showBanner)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: ThresholdNotice(
                        message: l10n.failureMessage(failure),
                      ),
                    ),
                  AppFormSection(
                    title: l10n.sectionContact,
                    children: [
                      AppTextField(
                        label: l10n.nameLabel,
                        controller: _name,
                        enabled: !_saving,
                        textCapitalization: TextCapitalization.words,
                        autofillHints: const [AutofillHints.name],
                        validator: _validator(
                          'name',
                          (v) =>
                              v.trim().isEmpty ? l10n.validationRequired : null,
                        ),
                      ),
                      AppTextField(
                        label: l10n.emailLabel,
                        controller: _email,
                        enabled: !_saving,
                        keyboardType: TextInputType.emailAddress,
                        hint: l10n.emailHint,
                        validator: _validator('email', (v) {
                          if (v.trim().isEmpty) return l10n.validationRequired;
                          if (!_emailPattern.hasMatch(v.trim())) {
                            return l10n.validationInvalidEmail;
                          }
                          return null;
                        }),
                      ),
                      AppTextField(
                        label: l10n.phoneLabel,
                        controller: _phone,
                        enabled: !_saving,
                        keyboardType: TextInputType.phone,
                        validator: _validator('phoneNumber'),
                      ),
                    ],
                  ),
                  AppFormSection(
                    title: l10n.sectionSignIn,
                    footer: _creating
                        ? l10n.passwordHelpCreate
                        : l10n.passwordHelpEdit,
                    children: [
                      AppTextField(
                        label: _creating
                            ? l10n.initialPasswordLabel
                            : l10n.newPasswordOptionalLabel,
                        controller: _password,
                        enabled: !_saving,
                        obscureText: true,
                        autofillHints: const [AutofillHints.newPassword],
                        validator: _validator('password', (v) {
                          if (v.isEmpty) {
                            return _creating ? l10n.validationRequired : null;
                          }
                          return v.length < PasswordPolicy.minLength
                              ? l10n.validationMinLength(
                                  '${PasswordPolicy.minLength}',
                                )
                              : null;
                        }),
                      ),
                    ],
                  ),
                  AppFormSection(
                    title: l10n.sectionRoles,
                    footer: _roleIds.isEmpty ? l10n.noRolesSelected : null,
                    children: [
                      for (final role in widget.roles)
                        AppCheckRow(
                          title: l10n.roleName(role.name),
                          subtitle: role.description,
                          checked: _roleIds.contains(role.id),
                          onChanged: _saving
                              ? null
                              : (checked) => setState(
                                  () => checked
                                      ? _roleIds.add(role.id)
                                      : _roleIds.remove(role.id),
                                ),
                        ),
                    ],
                  ),
                  AppFormSection(
                    title: l10n.sectionEmployment,
                    children: [
                      AppTextField(
                        label: l10n.employeeIdLabel,
                        controller: _employeeId,
                        enabled: !_saving,
                        validator: _validator('employeeId'),
                      ),
                      AppPickerRow(
                        label: l10n.employmentTypeLabel,
                        value: switch (_employmentType) {
                          final t? => l10n.employmentLabel(t),
                          null => null,
                        },
                        onTap: _saving
                            ? null
                            : () async {
                                final picked = await showAppChoice(
                                  context,
                                  title: l10n.employmentTypeLabel,
                                  options: {
                                    for (final t in {
                                      ...EmploymentTypes.all,
                                      ?_employmentType,
                                    })
                                      t: l10n.employmentLabel(t),
                                  },
                                );
                                if (picked != null) {
                                  setState(
                                    () => _employmentType = picked.isEmpty
                                        ? null
                                        : picked,
                                  );
                                }
                              },
                      ),
                      AppTextField(
                        label: l10n.payRateLabel,
                        controller: _payRate,
                        enabled: !_saving,
                        hint: '18.50',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                        validator: _validator('payRate', (v) {
                          final text = v.trim();
                          return text.isEmpty || _moneyPattern.hasMatch(text)
                              ? null
                              : l10n.invalidPayRate;
                        }),
                      ),
                      AppPickerRow(
                        label: l10n.hireDateLabel,
                        value: _hireDate == null
                            ? null
                            : context.formatDayLong(_hireDate!),
                        onTap: _saving
                            ? null
                            : () async {
                                final picked = await showAppDatePicker(
                                  context,
                                  initial: _hireDate,
                                );
                                if (picked != null) {
                                  setState(() => _hireDate = picked);
                                }
                              },
                      ),
                    ],
                  ),
                  AppFormSection(
                    title: l10n.sectionEmergency,
                    children: [
                      AppTextField(
                        label: l10n.emergencyNameLabel,
                        controller: _emergencyName,
                        enabled: !_saving,
                        textCapitalization: TextCapitalization.words,
                        validator: _validator('emergencyContactName'),
                      ),
                      AppTextField(
                        label: l10n.emergencyPhoneLabel,
                        controller: _emergencyPhone,
                        enabled: !_saving,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        validator: _validator('emergencyContactPhone'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
