import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/l10n/role_names.dart';
import '../../../../core/widgets/adaptive.dart';
import '../../../../l10n/app_localizations.dart';
import '../../di/users_providers.dart';
import '../../domain/entities/role_info.dart';
import '../../domain/usecases/user_usecases.dart';
import '../controllers/users_providers.dart';

/// Global roles with how many users hold each. The five built-in roles are
/// fixed; owners can add, rename and delete custom ones.
class RolesScreen extends ConsumerWidget {
  const RolesScreen({super.key});

  static const path = '/me/roles';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final roles = ref.watch(rolesProvider);
    final canEdit = ref.watch(canEditUsersProvider);
    Future<void> refresh() => ref.refresh(rolesProvider.future);

    return SpacePage(
      title: l10n.rolesTitle,
      onRefresh: refresh,
      actions: [
        if (canEdit)
          CircleButton.dark(
            icon: Icons.add_rounded,
            tooltip: l10n.addRole,
            onPressed: () => _RoleEditor.open(context),
          ),
      ],
      slivers: [
        AsyncSlivers(
          value: roles,
          onRetry: refresh,
          builder: (list) => SliverMainAxisGroup(
            slivers: [
              if (!canEdit)
                PageBox(
                  top: 4,
                  child: Notice(
                    tone: NoticeTone.info,
                    message: l10n.readOnlyNotice,
                  ),
                ),
              PageBox(
                top: 8,
                child: ListCard(
                  children: [
                    for (final role in list)
                      ListRow(
                        leading: role.isSystem
                            ? const IconBadge(
                                icon: Icons.lock_outline_rounded,
                                color: SpaceColors.inkMuted,
                                background: SpaceColors.sunken,
                              )
                            : const IconBadge(
                                icon: Icons.label_outline_rounded,
                              ),
                        title: l10n.roleName(role.name),
                        subtitle: [
                          if (role.isSystem) l10n.builtInRole,
                          ?role.description,
                        ].join(' · '),
                        trailing: Text(l10n.roleUserCount(role.userCount)),
                        onTap: canEdit && !role.isSystem
                            ? () => _RoleEditor.open(context, role: role)
                            : null,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Create or edit a custom role in a bottom sheet.
class _RoleEditor extends ConsumerStatefulWidget {
  const _RoleEditor({this.role});

  final RoleInfo? role;

  static Future<void> open(BuildContext context, {RoleInfo? role}) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        builder: (_) => _RoleEditor(role: role),
      );

  @override
  ConsumerState<_RoleEditor> createState() => _RoleEditorState();
}

class _RoleEditorState extends ConsumerState<_RoleEditor> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.role?.name);
  late final _description = TextEditingController(
    text: widget.role?.description,
  );
  bool _busy = false;
  Failure? _failure;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _failure = null;
    });
    try {
      await action();
      ref.invalidate(rolesProvider);
      if (mounted) Navigator.of(context).pop();
    } on Failure catch (f) {
      if (mounted) setState(() => _failure = f);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await _run(
      () => ref.read(saveRoleProvider)(
        SaveRoleParams(
          id: widget.role?.id,
          name: _name.text,
          description: _description.text,
        ),
      ),
    );
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final role = widget.role!;
    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(l10n.deleteRoleConfirmTitle(role.name)),
        content: Text(l10n.deleteRoleConfirmBody),
        actions: [
          adaptiveAction(
            context,
            label: l10n.cancelButton,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          adaptiveAction(
            context,
            label: l10n.deleteButton,
            destructive: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _run(() => ref.read(deleteRoleProvider)(role.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final role = widget.role;
    final failure = _failure;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        SpaceSpace.page,
        0,
        SpaceSpace.page,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                role == null ? l10n.addRole : l10n.editRole,
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              if (failure != null) ...[
                Notice(message: l10n.failureMessage(failure)),
                const SizedBox(height: 12),
              ],
              SpaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SpaceTextField(
                      label: l10n.roleNameLabel,
                      controller: _name,
                      enabled: !_busy,
                      hint: 'floor_lead',
                      helper: l10n.roleNameHelp,
                      validator: (v) {
                        final name = (v ?? '').trim().toLowerCase();
                        if (name.isEmpty) return l10n.validationRequired;
                        return RoleInfo.namePattern.hasMatch(name) &&
                                name.length <= 50
                            ? null
                            : l10n.roleNameInvalid;
                      },
                    ),
                    const SizedBox(height: 12),
                    SpaceTextField(
                      label: l10n.roleDescriptionLabel,
                      controller: _description,
                      enabled: !_busy,
                      textInputAction: TextInputAction.done,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: l10n.saveButton,
                busy: _busy,
                onPressed: _save,
              ),
              if (role != null) ...[
                const SizedBox(height: 10),
                if (role.isDeletable)
                  SecondaryButton(
                    label: l10n.deleteRole,
                    icon: Icons.delete_outline_rounded,
                    destructive: true,
                    onPressed: _busy ? null : _delete,
                  )
                else
                  Text(
                    l10n.roleInUseHint,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
