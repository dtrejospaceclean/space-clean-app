import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/l10n/role_names.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../access/presentation/controllers/account_access_provider.dart';
import '../account_modules.dart';
import '../controllers/clients_providers.dart';
import '../controllers/module_order_controller.dart';

/// One client account: what the user may open here, driven by their
/// effective permissions (nothing they can't use is shown), as one list in
/// the order the user set. Reorder turns the rows into drag handles.
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key, required this.clientId});

  final String clientId;

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  bool _reordering = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final clientId = widget.clientId;
    final client = ref.watch(clientByIdProvider(clientId)).value;
    final access = ref.watch(accountAccessProvider(clientId));
    final order = ref.watch(moduleOrderProvider);
    final modules = switch (access.value) {
      final access? => orderedModules(access, order),
      null => const <AccountModule>[],
    };
    final here = GoRouterState.of(context).matchedLocation;
    Future<void> refresh() =>
        ref.refresh(accountAccessProvider(clientId).future);

    return SpacePage(
      heading: HeroHeadline(
        primary: client?.displayName ?? l10n.accountsTitle,
        secondary: switch (access.value?.baseRole) {
          final role? => l10n.yourRole(l10n.roleName(role)),
          null => null,
        },
      ),
      onRefresh: _reordering ? null : refresh,
      actions: [
        // Nothing to order with one module.
        if (modules.length > 1)
          _reordering
              ? CircleButton.dark(
                  icon: Icons.check_rounded,
                  tooltip: l10n.doneButton,
                  onPressed: () => setState(() => _reordering = false),
                )
              : CircleButton.light(
                  icon: Icons.swap_vert_rounded,
                  tooltip: l10n.reorderModules,
                  onPressed: () => setState(() => _reordering = true),
                ),
      ],
      slivers: [
        AsyncSlivers(
          value: access,
          onRetry: refresh,
          builder: (_) {
            if (modules.isEmpty) {
              return MessageSliver(
                icon: Icons.lock_outline_rounded,
                title: l10n.noModules,
              );
            }
            if (_reordering) {
              return SliverMainAxisGroup(
                slivers: [
                  PageBox(
                    top: 16,
                    child: Text(
                      l10n.reorderModulesHint,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  PageBox(
                    top: 8,
                    child: _ReorderList(
                      modules: modules,
                      onReorder: (routes) => ref
                          .read(moduleOrderProvider.notifier)
                          .reorder(routes),
                    ),
                  ),
                ],
              );
            }
            return PageBox(
              top: 16,
              child: ListCard(
                children: [
                  for (final module in modules)
                    ListRow(
                      leading: IconBadge(icon: module.icon),
                      title: module.label(l10n),
                      subtitle: module.description(l10n),
                      onTap: () => context.push('$here/${module.route}'),
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

/// The modules as a card of rows dragged by their handles. Screen readers
/// get move up/down actions on each row from [ReorderableListView].
class _ReorderList extends StatelessWidget {
  const _ReorderList({required this.modules, required this.onReorder});

  final List<AccountModule> modules;

  /// The visible modules' routes in their new order.
  final ValueChanged<List<String>> onReorder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return SpaceCard(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ReorderableListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        buildDefaultDragHandles: false,
        // Flat, per the No-Shadow Rule: the lifted row is told apart by
        // tone, not elevation.
        proxyDecorator: (child, _, _) => Material(
          color: c.highlightSoft,
          borderRadius: BorderRadius.circular(SpaceRadius.inner),
          child: child,
        ),
        onReorderItem: (from, to) {
          final routes = [for (final m in modules) m.route];
          routes.insert(to, routes.removeAt(from));
          onReorder(routes);
        },
        children: [
          for (final (i, module) in modules.indexed)
            Column(
              key: ValueKey(module.route),
              mainAxisSize: MainAxisSize.min,
              children: [
                if (i > 0)
                  const Divider(
                    indent: SpaceSpace.card,
                    endIndent: SpaceSpace.card,
                  ),
                // A long press anywhere lifts the row; the handle lifts it
                // straight away.
                ReorderableDelayedDragStartListener(
                  index: i,
                  child: ListRow(
                    leading: IconBadge(icon: module.icon),
                    title: module.label(l10n),
                    subtitle: module.description(l10n),
                    chevron: false,
                    trailing: ReorderableDragStartListener(
                      index: i,
                      child: SizedBox.square(
                        dimension: 48,
                        child: Icon(
                          Icons.drag_handle_rounded,
                          color: c.inkMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
