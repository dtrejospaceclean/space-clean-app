import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/l10n/role_names.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../users/domain/entities/managed_user.dart';
import '../../di/team_providers.dart';
import '../../domain/entities/member.dart';
import '../../domain/usecases/team_usecases.dart';
import '../controllers/team_providers.dart';
import '../widgets/access_list.dart';

/// Picks a base role, in the catalog's order.
Future<String?> _pickRole(
  BuildContext context,
  PermissionCatalog catalog,
  String label,
) {
  final l10n = AppLocalizations.of(context);
  return showAppChoice(
    context,
    title: label,
    allowClear: false,
    options: {for (final r in catalog.roles) r: l10n.roleName(r)},
  );
}

/// The pinned Save button every form here uses.
Widget _saveBar(
  BuildContext context, {
  required bool busy,
  VoidCallback? onSave,
}) => SafeArea(
  top: false,
  child: Padding(
    padding: EdgeInsets.fromLTRB(pageSide(context), 8, pageSide(context), 12),
    child: PrimaryButton(
      label: AppLocalizations.of(context).saveButton,
      busy: busy,
      onPressed: onSave,
    ),
  ),
);

/// A failure that isn't about one field, above the form.
Widget _failureNotice(BuildContext context, Failure failure) => Padding(
  padding: EdgeInsets.fromLTRB(pageSide(context), 4, pageSide(context), 0),
  child: Notice(message: AppLocalizations.of(context).failureMessage(failure)),
);

/// Owners add someone to an account's team: pick an active user and their
/// base role. Access starts at the role's defaults and can be adjusted from
/// the member's screen.
class AddMemberScreen extends ConsumerStatefulWidget {
  const AddMemberScreen({super.key, required this.clientId});

  final String clientId;

  @override
  ConsumerState<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends ConsumerState<AddMemberScreen> {
  ManagedUser? _user;
  String? _role;
  bool _saving = false;
  bool _tried = false;
  Failure? _failure;

  Future<void> _pickUser(List<ManagedUser> users, PermissionCatalog c) async {
    final l10n = AppLocalizations.of(context);
    final picked = await showAppChoice(
      context,
      title: l10n.memberUserLabel,
      allowClear: false,
      options: {for (final u in users) u.id: u.name},
    );
    if (picked == null || !mounted) return;
    final user = users.firstWhere((u) => u.id == picked);
    setState(() {
      _user = user;
      // Start from the role that fits them; the owner can still change it.
      _role = TeamPolicy.suggestedRole(
        user.roles.map((r) => r.name),
        c.roles,
        external: user.userType == UserType.external,
      );
    });
  }

  Future<void> _save() async {
    final user = _user;
    final role = _role;
    setState(() {
      _tried = true;
      _failure = null;
    });
    if (user == null || role == null) {
      HapticFeedback.mediumImpact();
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(addMemberProvider)(
        AddMemberParams(
          clientId: widget.clientId,
          userId: user.id,
          baseRole: role,
        ),
      );
      ref.invalidate(membersProvider(widget.clientId));
      if (!mounted) return;
      // Onto their screen, where access can be adjusted.
      final here = GoRouterState.of(context).matchedLocation;
      context.pushReplacement(
        '${here.substring(0, here.lastIndexOf('/'))}/${user.id}',
      );
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
    final loaded = bothLoaded(
      bothLoaded(
        ref.watch(activeUsersProvider),
        ref.watch(membersProvider(widget.clientId)),
      ),
      ref.watch(permissionCatalogProvider),
    );
    final failure = _failure;

    return SpacePage(
      title: l10n.addMemberTitle,
      bottom: loaded.hasValue
          ? _saveBar(context, busy: _saving, onSave: _save)
          : null,
      slivers: [
        AsyncSlivers(
          value: loaded,
          skeleton: SkeletonLayout.form,
          onRetry: () => ref
            ..invalidate(activeUsersProvider)
            ..invalidate(membersProvider(widget.clientId))
            ..invalidate(permissionCatalogProvider),
          builder: (value) {
            final ((users, members), catalog) = value;
            final memberIds = {for (final m in members) m.userId};
            final candidates = users
                .where((u) => u.isActive && !memberIds.contains(u.id))
                .toList();
            final user = _user;
            final role = _role;
            return SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (failure != null) _failureNotice(context, failure),
                  FormSection(
                    l10n.sectionGeneral,
                    [
                      PickerField(
                        label: l10n.memberUserLabel,
                        icon: Icons.person_outline_rounded,
                        value: user?.name,
                        errorText: _tried && user == null
                            ? l10n.validationRequired
                            : null,
                        onTap: _saving || candidates.isEmpty
                            ? null
                            : () => _pickUser(candidates, catalog),
                      ),
                      PickerField(
                        label: l10n.baseRoleLabel,
                        icon: Icons.badge_outlined,
                        value: role == null ? null : l10n.roleName(role),
                        errorText: _tried && role == null
                            ? l10n.validationRequired
                            : null,
                        onTap: _saving
                            ? null
                            : () async {
                                final picked = await _pickRole(
                                  context,
                                  catalog,
                                  l10n.baseRoleLabel,
                                );
                                if (picked != null) {
                                  setState(() => _role = picked);
                                }
                              },
                      ),
                    ],
                    footer: candidates.isEmpty
                        ? l10n.noOneToAdd
                        : l10n.addMemberHelp,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Owners change a member's base role and exactly what they may do.
class MemberAccessScreen extends ConsumerWidget {
  const MemberAccessScreen({
    super.key,
    required this.clientId,
    required this.userId,
  });

  final String clientId;
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // Wait for the member and the catalog before building the editor.
    return switch (bothLoaded(
      ref.watch(memberProvider((clientId, userId))),
      ref.watch(permissionCatalogProvider),
    )) {
      AsyncValue(value: (final member, final catalog)?) => _AccessEditor(
        key: ValueKey(userId),
        member: member,
        catalog: catalog,
      ),
      final other => SpacePage(
        title: l10n.editAccess,
        slivers: [
          AsyncSlivers<Object?>(
            value: other,
            skeleton: SkeletonLayout.form,
            onRetry: () => ref
              ..invalidate(membersProvider(clientId))
              ..invalidate(permissionCatalogProvider),
            builder: (_) => const SliverToBoxAdapter(),
          ),
        ],
      ),
    };
  }
}

class _AccessEditor extends ConsumerStatefulWidget {
  const _AccessEditor({super.key, required this.member, required this.catalog});

  final Member member;
  final PermissionCatalog catalog;

  @override
  ConsumerState<_AccessEditor> createState() => _AccessEditorState();
}

class _AccessEditorState extends ConsumerState<_AccessEditor> {
  late String _role = widget.member.baseRole;
  late Set<String> _granted = {...widget.member.permissions};
  bool _saving = false;
  Failure? _failure;

  Future<void> _changeRole() async {
    final l10n = AppLocalizations.of(context);
    final picked = await _pickRole(context, widget.catalog, l10n.baseRoleLabel);
    if (picked == null || picked == _role || !mounted) return;
    setState(() {
      _role = picked;
      _granted = {...widget.catalog.defaultsFor(picked)};
    });
  }

  Future<void> _save() async {
    setState(() {
      _failure = null;
      _saving = true;
    });
    try {
      await ref.read(updateMemberAccessProvider)(
        UpdateAccessParams(
          member: widget.member,
          catalog: widget.catalog,
          baseRole: _role,
          permissions: _granted,
        ),
      );
      ref.invalidate(membersProvider(widget.member.clientId));
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
    final catalog = widget.catalog;
    final failure = _failure;
    final defaults = catalog.defaultsFor(_role);
    final isDefault =
        _granted.length == defaults.length && _granted.containsAll(defaults);

    return SpacePage(
      title: l10n.editAccess,
      bottom: _saveBar(context, busy: _saving, onSave: _save),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (failure != null) _failureNotice(context, failure),
              FormSection(l10n.sectionGeneral, [
                PickerField(
                  label: l10n.memberUserLabel,
                  icon: Icons.person_outline_rounded,
                  value: widget.member.name,
                  onTap: null,
                ),
                PickerField(
                  label: l10n.baseRoleLabel,
                  icon: Icons.badge_outlined,
                  value: l10n.roleName(_role),
                  onTap: _saving ? null : _changeRole,
                ),
              ], footer: l10n.baseRoleChangeHelp),
              FormSection(l10n.sectionAccess, [
                AccessList(
                  catalog: catalog,
                  granted: _granted,
                  enabled: !_saving,
                  onToggle: (p) =>
                      setState(() => _granted = catalog.toggled(_granted, p)),
                ),
                if (!isDefault)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: LinkButton(
                      label: l10n.resetAccess,
                      onPressed: _saving
                          ? null
                          : () => setState(() => _granted = {...defaults}),
                    ),
                  ),
              ], footer: l10n.accessHelp),
            ],
          ),
        ),
      ],
    );
  }
}
