import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/l10n/role_names.dart';
import '../../../../core/widgets/adaptive.dart';
import '../../../../core/widgets/app/app_form.dart';
import '../../../../core/widgets/app/app_list.dart';
import '../../../../core/widgets/app/app_page.dart';
import '../../../../core/widgets/app/async_slivers.dart';
import '../../../../core/widgets/threshold/threshold_notice.dart';
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
    final cupertino = useCupertino(context);
    final roles = ref.watch(rolesProvider);
    final canEdit = ref.watch(canEditUsersProvider);
    Future<void> refresh() => ref.refresh(rolesProvider.future);

    return AppPage(
      title: l10n.rolesTitle,
      grouped: true,
      onRefresh: refresh,
      actions: [
        if (canEdit)
          IconButton(
            tooltip: l10n.addRole,
            icon: Icon(cupertino ? CupertinoIcons.add : Icons.add),
            onPressed: () => _RoleEditor.open(context),
          ),
      ],
      slivers: [
        AsyncSlivers(
          value: roles,
          onRetry: refresh,
          builder: (list) => SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!canEdit)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: ThresholdNotice(
                      tone: NoticeTone.info,
                      message: l10n.readOnlyNotice,
                    ),
                  ),
                AppListSection(
                  children: [
                    for (final role in list)
                      AppListRow(
                        leading: role.isSystem
                            ? (cupertino
                                  ? CupertinoIcons.lock
                                  : Icons.lock_outline)
                            : (cupertino
                                  ? CupertinoIcons.tag
                                  : Icons.label_outline),
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Create or edit a custom role, in a sheet (Android) or full-screen modal
/// page (iOS).
class _RoleEditor extends ConsumerStatefulWidget {
  const _RoleEditor({this.role});

  final RoleInfo? role;

  static Future<void> open(BuildContext context, {RoleInfo? role}) {
    final editor = _RoleEditor(role: role);
    if (useCupertino(context)) {
      return Navigator.of(context, rootNavigator: true).push(
        CupertinoPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => editor,
        ),
      );
    }
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useRootNavigator: true,
      builder: (_) => editor,
    );
  }

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
    final cupertino = useCupertino(context);
    final role = widget.role;
    final failure = _failure;
    final title = role == null ? l10n.addRole : l10n.editRole;

    final form = Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (failure != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: ThresholdNotice(message: l10n.failureMessage(failure)),
            ),
          AppFormSection(
            footer: l10n.roleNameHelp,
            children: [
              AppTextField(
                label: l10n.roleNameLabel,
                controller: _name,
                enabled: !_busy,
                hint: 'floor_lead',
                validator: (v) {
                  final name = (v ?? '').trim().toLowerCase();
                  if (name.isEmpty) return l10n.validationRequired;
                  return RoleInfo.namePattern.hasMatch(name) &&
                          name.length <= 50
                      ? null
                      : l10n.roleNameInvalid;
                },
              ),
              AppTextField(
                label: l10n.roleDescriptionLabel,
                controller: _description,
                enabled: !_busy,
                textInputAction: TextInputAction.done,
              ),
            ],
          ),
          if (role != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: role.isDeletable
                  ? TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                      onPressed: _busy ? null : _delete,
                      icon: const Icon(Icons.delete_outline),
                      label: Text(l10n.deleteRole),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        l10n.roleInUseHint,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
            ),
        ],
      ),
    );

    if (cupertino) {
      return CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGroupedBackground.resolveFrom(
          context,
        ),
        navigationBar: CupertinoNavigationBar(
          middle: Text(title),
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _busy ? null : () => Navigator.of(context).pop(),
            child: Text(l10n.cancelButton),
          ),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _busy ? null : _save,
            child: Text(
              l10n.saveButton,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        child: SafeArea(
          child: Material(type: MaterialType.transparency, child: form),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            form,
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: FilledButton(
                onPressed: _busy ? null : _save,
                child: Text(l10n.saveButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
