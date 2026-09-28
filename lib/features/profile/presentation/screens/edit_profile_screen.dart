import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../di/profile_providers.dart';
import '../../domain/entities/profile_draft.dart';
import '../../../../core/widgets/us_phone.dart';

/// The signed-in user's own details (`PATCH /auth/me`), open to everyone.
/// Email, roles and employment stay with owners, under Administration.
class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  static const path = '/me/edit';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(authControllerProvider).value) {
      Authenticated(:final user) => _ProfileForm(
        key: ValueKey(user.id),
        user: user,
      ),
      _ => const SizedBox.shrink(),
    };
  }
}

class _ProfileForm extends ConsumerStatefulWidget {
  const _ProfileForm({super.key, required this.user});

  final User user;

  @override
  ConsumerState<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<_ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.user.name);
  late final _phone = TextEditingController(
    text: UsPhone.format(widget.user.phoneNumber),
  );
  late final _emergencyName = TextEditingController(
    text: widget.user.emergencyContactName,
  );
  late final _emergencyPhone = TextEditingController(
    text: UsPhone.format(widget.user.emergencyContactPhone),
  );

  bool _saving = false;
  Failure? _failure;

  @override
  void dispose() {
    for (final c in [_name, _phone, _emergencyName, _emergencyPhone]) {
      c.dispose();
    }
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

  Future<void> _save() async {
    setState(() => _failure = null);
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }
    setState(() => _saving = true);
    try {
      final saved = await ref.read(updateMyProfileProvider)(
        ProfileDraft(
          name: _name.text,
          phoneNumber: _phone.text,
          emergencyContactName: _emergencyName.text,
          emergencyContactPhone: _emergencyPhone.text,
        ),
      );
      if (!mounted) return;
      // Close first: this form rebuilds from the signed-in user.
      context.pop();
      ref.read(authControllerProvider.notifier).replaceUser(saved);
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

    return SpacePage(
      title: l10n.editProfile,
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
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                  FormSection(l10n.sectionContact, [
                    SpaceTextField(
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
                    SpaceTextField(
                      label: l10n.phoneLabel,
                      controller: _phone,
                      enabled: !_saving,
                      phone: true,
                      validator: _validator('phoneNumber'),
                    ),
                  ], footer: l10n.profileEmailFootnote(widget.user.email)),
                  FormSection(l10n.sectionEmergency, [
                    SpaceTextField(
                      label: l10n.emergencyNameLabel,
                      controller: _emergencyName,
                      enabled: !_saving,
                      textCapitalization: TextCapitalization.words,
                      validator: _validator('emergencyContactName'),
                    ),
                    SpaceTextField(
                      label: l10n.emergencyPhoneLabel,
                      controller: _emergencyPhone,
                      enabled: !_saving,
                      phone: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _save(),
                      validator: _validator('emergencyContactPhone'),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
