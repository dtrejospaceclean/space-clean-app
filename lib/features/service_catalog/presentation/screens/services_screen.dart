import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/service_item.dart';
import '../controllers/service_catalog_providers.dart';

/// The company-wide service catalog: every service, active and inactive, in
/// one list by name. Adding a service and managing categories and units live
/// in the tab dock's "+".
class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  static const path = '/me/services';

  @override
  Widget build(BuildContext context) => _CatalogPage(
    list: CatalogList.services,
    title: AppLocalizations.of(context).servicesTitle,
  );
}

/// Every category, active and inactive; "+" in the tab dock adds one.
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  static const path = '${ServicesScreen.path}/categories';

  @override
  Widget build(BuildContext context) => _CatalogPage(
    list: CatalogList.categories,
    title: AppLocalizations.of(context).categoriesTitle,
  );
}

/// Every unit services are priced in, active and inactive; "+" in the tab
/// dock adds one.
class UnitsScreen extends StatelessWidget {
  const UnitsScreen({super.key});

  static const path = '${ServicesScreen.path}/units';

  @override
  Widget build(BuildContext context) => _CatalogPage(
    list: CatalogList.units,
    title: AppLocalizations.of(context).unitsTitle,
  );
}

/// One catalog list: a search over every entry, active and inactive, each
/// marked with its status icon.
class _CatalogPage extends ConsumerStatefulWidget {
  const _CatalogPage({required this.list, required this.title});

  final CatalogList list;
  final String title;

  @override
  ConsumerState<_CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends ConsumerState<_CatalogPage> {
  late final _search = TextEditingController(
    text: ref.read(catalogQueryProvider(widget.list)).search,
  );
  Timer? _debounce;

  /// Typed text waiting out the debounce, not yet searched.
  bool _pending = false;

  CatalogQueryController get _query =>
      ref.read(catalogQueryProvider(widget.list).notifier);

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearch(String text) {
    _debounce?.cancel();
    setState(() => _pending = true);
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _query.search(text);
      setState(() => _pending = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final list = widget.list;
    final query = ref.watch(catalogQueryProvider(list));
    final canManage = ref.watch(canManageServicesProvider);
    final loading = switch (list) {
      CatalogList.services => ref.watch(servicesProvider).isLoading,
      CatalogList.categories => ref.watch(categoriesProvider).isLoading,
      CatalogList.units => ref.watch(unitsProvider).isLoading,
    };
    Future<void> refresh() => switch (list) {
      CatalogList.services => ref.refresh(servicesProvider.future),
      CatalogList.categories => ref.refresh(categoriesProvider.future),
      CatalogList.units => ref.refresh(unitsProvider.future),
    };

    return SpacePage(
      title: widget.title,
      onRefresh: refresh,
      slivers: [
        PageBox(
          top: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SearchField(
                controller: _search,
                hint: switch (list) {
                  CatalogList.services => l10n.searchServicesHint,
                  CatalogList.categories => l10n.searchCategoriesHint,
                  CatalogList.units => l10n.searchUnitsHint,
                },
                onChanged: _onSearch,
                // From the first keystroke until the results are in.
                busy: _pending || loading,
              ),
            ],
          ),
        ),
        switch (list) {
          CatalogList.services => _ServicesList(
            query: query,
            canManage: canManage,
            onRetry: refresh,
          ),
          CatalogList.categories => _CategoriesList(
            query: query,
            canManage: canManage,
            onRetry: refresh,
          ),
          CatalogList.units => _UnitsList(
            query: query,
            canManage: canManage,
            onRetry: refresh,
          ),
        },
      ],
    );
  }
}

/// No search: the list itself is empty.
bool _unfiltered(CatalogQuery q) => q.search.trim().isEmpty;

/// What an empty list says: "nothing yet" (with how to start, for those who
/// can add) or "nothing matches".
Widget _empty(
  AppLocalizations l10n,
  CatalogQuery query,
  bool canManage, {
  required IconData icon,
  required String none,
  required String noneHint,
}) => _unfiltered(query)
    ? MessageSliver(icon: icon, title: none, hint: canManage ? noneHint : null)
    : MessageSliver(
        icon: icon,
        title: l10n.noMatchesFound,
        hint: l10n.noMatchesHint,
      );

/// The right-hand column of a row: a figure (price, count) in tabular digits,
/// with the entry's status icon under it.
class _Trailing extends StatelessWidget {
  const _Trailing({required this.value, required this.isActive, this.strong});

  final String value;
  final bool isActive;

  /// A real figure reads in ink and bold; a placeholder stays muted.
  final bool? strong;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strong = this.strong ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          textAlign: TextAlign.end,
          style:
              (strong
                      ? theme.textTheme.titleMedium
                      : theme.textTheme.bodyMedium)
                  ?.copyWith(
                    fontWeight: strong ? FontWeight.w700 : null,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
        ),
        const SizedBox(height: 4),
        StatusIcon(isActive: isActive),
      ],
    );
  }
}

class _ServicesList extends ConsumerWidget {
  const _ServicesList({
    required this.query,
    required this.canManage,
    required this.onRetry,
  });

  final CatalogQuery query;
  final bool canManage;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AsyncSlivers(
      value: ref.watch(servicesProvider),
      onRetry: onRetry,
      builder: (list) {
        if (list.isEmpty) {
          return _empty(
            l10n,
            query,
            canManage,
            icon: Icons.cleaning_services_outlined,
            none: l10n.noServicesYet,
            noneHint: l10n.noServicesYetHint,
          );
        }
        return PageBox(
          child: ListCard(
            children: [
              for (final service in list)
                ListRow(
                  title: service.name,
                  // Retired services recede; the icon says which is which.
                  muted: !service.isActive,
                  subtitle: [
                    ?service.category?.name,
                    l10n.perUnit(service.unit.short),
                  ].join(' · '),
                  trailing: _Trailing(
                    value: switch (service.defaultPrice) {
                      final price? => context.formatMoney(price),
                      null => l10n.noDefaultPrice,
                    },
                    strong: service.defaultPrice != null,
                    isActive: service.isActive,
                  ),
                  onTap: canManage
                      ? () =>
                            context.push('${ServicesScreen.path}/${service.id}')
                      : null,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoriesList extends ConsumerWidget {
  const _CategoriesList({
    required this.query,
    required this.canManage,
    required this.onRetry,
  });

  final CatalogQuery query;
  final bool canManage;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AsyncSlivers(
      value: ref.watch(categoriesProvider),
      onRetry: onRetry,
      builder: (list) {
        if (list.isEmpty) {
          return _empty(
            l10n,
            query,
            canManage,
            icon: Icons.category_outlined,
            none: l10n.noCategoriesYet,
            noneHint: l10n.noCategoriesYetHint,
          );
        }
        return PageBox(
          child: ListCard(
            children: [
              for (final category in list)
                ListRow(
                  title: category.name,
                  muted: !category.isActive,
                  subtitle: category.description,
                  trailing: _Trailing(
                    value: l10n.serviceCount(category.serviceCount),
                    isActive: category.isActive,
                  ),
                  onTap: canManage
                      ? () => context.push(
                          '${CategoriesScreen.path}/${category.id}',
                        )
                      : null,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _UnitsList extends ConsumerWidget {
  const _UnitsList({
    required this.query,
    required this.canManage,
    required this.onRetry,
  });

  final CatalogQuery query;
  final bool canManage;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AsyncSlivers(
      value: ref.watch(unitsProvider),
      onRetry: onRetry,
      builder: (list) {
        if (list.isEmpty) {
          return _empty(
            l10n,
            query,
            canManage,
            icon: Icons.straighten_rounded,
            none: l10n.noUnitsYet,
            noneHint: l10n.noUnitsYetHint,
          );
        }
        return PageBox(
          child: ListCard(
            children: [
              for (final unit in list)
                ListRow(
                  title: unit.name,
                  muted: !unit.isActive,
                  // How prices show it; nothing when that's just the name.
                  subtitle: unit.abbreviation == null
                      ? null
                      : l10n.shownAs(unit.abbreviation!),
                  trailing: _Trailing(
                    value: l10n.serviceCount(unit.serviceCount),
                    isActive: unit.isActive,
                  ),
                  onTap: canManage
                      ? () => context.push('${UnitsScreen.path}/${unit.id}')
                      : null,
                ),
            ],
          ),
        );
      },
    );
  }
}
