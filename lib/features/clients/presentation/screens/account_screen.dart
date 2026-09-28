import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/l10n/role_names.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../access/presentation/controllers/account_access_provider.dart';
import '../account_modules.dart';
import '../controllers/clients_providers.dart';

/// One client account: what the user may open here, driven by their
/// effective permissions (nothing they can't use is shown).
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final client = ref.watch(clientByIdProvider(clientId)).value;
    final access = ref.watch(accountAccessProvider(clientId));
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
      onRefresh: refresh,
      slivers: [
        AsyncSlivers(
          value: access,
          onRetry: refresh,
          builder: (access) {
            final sections = visibleModules(access);
            return SliverMainAxisGroup(
              slivers: [
                if (sections.isEmpty)
                  MessageSliver(
                    icon: Icons.lock_outline_rounded,
                    title: l10n.noModules,
                  ),
                for (final MapEntry(key: section, value: modules)
                    in sections.entries) ...[
                  PageBox(
                    top: 16,
                    child: SectionHeader(title: section.label(l10n)),
                  ),
                  PageBox(
                    top: 0,
                    child: switch (section) {
                      // The account's own records: tiles, three across
                      // (two when large text needs the width).
                      AccountSection.account => CardGrid(
                        columns:
                            MediaQuery.textScalerOf(context).scale(1) >= 1.5
                            ? 2
                            : 3,
                        children: [
                          for (final module in modules)
                            Semantics(
                              button: true,
                              hint: module.description(l10n),
                              child: TileCard(
                                compact: true,
                                icon: IconBadge.strong(
                                  icon: module.icon,
                                  size: 34,
                                ),
                                title: module.label(l10n),
                                onTap: () =>
                                    context.push('$here/${module.route}'),
                              ),
                            ),
                        ],
                      ),
                      AccountSection.work => ListCard(
                        children: [
                          for (final module in modules)
                            ListRow(
                              leading: IconBadge.strong(icon: module.icon),
                              title: module.label(l10n),
                              subtitle: module.description(l10n),
                              onTap: () =>
                                  context.push('$here/${module.route}'),
                            ),
                        ],
                      ),
                    },
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
