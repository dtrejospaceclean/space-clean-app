import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/service_item.dart';
import '../controllers/service_catalog_providers.dart';

/// The company-wide catalog in three tabs: services, the categories that
/// group them, and the units they're priced in. Each tab has its own search
/// and status filter; services also filter by category.
class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key});

  static const path = '/me/services';
  static const categoriesPath = '$path/categories';
  static const unitsPath = '$path/units';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tab = ref.watch(catalogTabProvider);
    final canManage = ref.watch(canManageServicesProvider);
    final (addLabel, addPath) = switch (tab) {
      CatalogTab.services => (l10n.addService, path),
      CatalogTab.categories => (l10n.addCategory, categoriesPath),
      CatalogTab.units => (l10n.addUnit, unitsPath),
    };

    return _CatalogTab(
      key: ValueKey(tab),
      tab: tab,
      actions: [
        if (canManage)
          CircleButton.dark(
            icon: Icons.add_rounded,
            tooltip: addLabel,
            onPressed: () => context.push('$addPath/new'),
          ),
      ],
    );
  }
}

class _CatalogTab extends ConsumerStatefulWidget {
  const _CatalogTab({super.key, required this.tab, required this.actions});

  final CatalogTab tab;
  final List<Widget> actions;

  @override
  ConsumerState<_CatalogTab> createState() => _CatalogTabState();
}

class _CatalogTabState extends ConsumerState<_CatalogTab> {
  late final _search = TextEditingController(
    text: ref.read(catalogQueryProvider(widget.tab)).search,
  );
  Timer? _debounce;

  /// Typed text waiting out the debounce, not yet searched.
  bool _pending = false;

  CatalogQueryController get _query =>
      ref.read(catalogQueryProvider(widget.tab).notifier);

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

  Future<void> _pickCategory() async {
    final l10n = AppLocalizations.of(context);
    final categories = await ref.read(activeCategoriesProvider.future);
    if (!mounted) return;
    final current = ref.read(catalogQueryProvider(widget.tab)).categoryId;
    final picked = await showAppChoice(
      context,
      title: l10n.serviceCategoryLabel,
      allowClear: current != null,
      options: {for (final c in categories) c.id: c.name},
    );
    if (picked != null) _query.category(picked.isEmpty ? null : picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tab = widget.tab;
    final query = ref.watch(catalogQueryProvider(tab));
    final canManage = ref.watch(canManageServicesProvider);
    final loading = switch (tab) {
      CatalogTab.services => ref.watch(servicesProvider).isLoading,
      CatalogTab.categories => ref.watch(categoriesProvider).isLoading,
      CatalogTab.units => ref.watch(unitsProvider).isLoading,
    };
    Future<void> refresh() => switch (tab) {
      CatalogTab.services => ref.refresh(servicesProvider.future),
      CatalogTab.categories => ref.refresh(categoriesProvider.future),
      CatalogTab.units => ref.refresh(unitsProvider.future),
    };
    // The applied category's name: from the pickable (active) ones, or from
    // the services it matched if it was retired since.
    final categoryName = switch (query.categoryId) {
      final id? => [
        ...?ref.watch(activeCategoriesProvider).value,
        ...?ref.watch(servicesProvider).value?.map((s) => s.category).nonNulls,
      ].where((c) => c.id == id).firstOrNull?.name,
      null => null,
    };

    return SpacePage(
      title: l10n.servicesTitle,
      onRefresh: refresh,
      actions: widget.actions,
      slivers: [
        PageBox(
          top: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PillToggle<CatalogTab>(
                options: {
                  CatalogTab.services: l10n.catalogTabServices,
                  CatalogTab.categories: l10n.catalogTabCategories,
                  CatalogTab.units: l10n.catalogTabUnits,
                },
                selected: tab,
                onChanged: ref.read(catalogTabProvider.notifier).select,
              ),
              const SizedBox(height: 20),
              SearchField(
                controller: _search,
                hint: switch (tab) {
                  CatalogTab.services => l10n.searchServicesHint,
                  CatalogTab.categories => l10n.searchCategoriesHint,
                  CatalogTab.units => l10n.searchUnitsHint,
                },
                onChanged: _onSearch,
                // From the first keystroke until the results are in.
                busy: _pending || loading,
              ),
              if (tab == CatalogTab.services) ...[
                const SizedBox(height: 10),
                FilterPill(
                  icon: Icons.category_outlined,
                  label: l10n.serviceCategoryLabel,
                  value: query.categoryId == null
                      ? l10n.allCategories
                      : categoryName ?? l10n.serviceCategoryLabel,
                  onTap: _pickCategory,
                  onClear: query.categoryId == null
                      ? null
                      : () => _query.category(null),
                ),
              ],
              const SizedBox(height: 12),
              // Compact, so it reads as a filter under the full-width tabs;
              // full width once large text wouldn't fit compact.
              Align(
                alignment: Alignment.centerLeft,
                child: PillToggle<bool?>(
                  expand: MediaQuery.textScalerOf(context).scale(10) > 13,
                  semanticLabel: l10n.accountStatusLabel,
                  options: {
                    true: l10n.filterActive,
                    false: l10n.filterInactive,
                    null: l10n.filterAll,
                  },
                  selected: query.isActive,
                  onChanged: _query.status,
                ),
              ),
            ],
          ),
        ),
        switch (tab) {
          CatalogTab.services => _ServicesList(
            query: query,
            canManage: canManage,
            onRetry: refresh,
          ),
          CatalogTab.categories => _CategoriesList(
            query: query,
            canManage: canManage,
            onRetry: refresh,
          ),
          CatalogTab.units => _UnitsList(
            query: query,
            canManage: canManage,
            onRetry: refresh,
          ),
        },
      ],
    );
  }
}

/// No search and the default filters: the list itself is empty.
bool _unfiltered(CatalogQuery q) =>
    q.search.trim().isEmpty && q.isActive == true && q.categoryId == null;

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
/// with an "Inactive" pill under it for retired entries.
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
        if (!isActive) ...[
          const SizedBox(height: 4),
          StatusPill(
            label: AppLocalizations.of(context).inactiveTag,
            color: context.colors.inkMuted,
            background: context.colors.sunken,
          ),
        ],
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
        // Grouped under their category, in the API's order (by category,
        // then name); uncategorized services come last.
        final groups = <String?, List<ServiceItem>>{};
        for (final service in list) {
          (groups[service.category?.name] ??= []).add(service);
        }
        final uncategorized = groups.remove(null);
        return SliverMainAxisGroup(
          slivers: [
            for (final (name, services) in [
              ...groups.entries.map((e) => (e.key!, e.value)),
              if (uncategorized != null) (l10n.noCategoryGroup, uncategorized),
            ]) ...[
              PageBox(top: 12, child: SectionHeader(title: name)),
              PageBox(
                top: 0,
                child: ListCard(
                  children: [
                    for (final service in services)
                      ListRow(
                        title: service.name,
                        subtitle: l10n.perUnit(service.unit.short),
                        trailing: _Trailing(
                          value: switch (service.defaultPrice) {
                            final price? => context.formatMoney(price),
                            null => l10n.noDefaultPrice,
                          },
                          strong: service.defaultPrice != null,
                          isActive: service.isActive,
                        ),
                        onTap: canManage
                            ? () => context.push(
                                '${ServicesScreen.path}/${service.id}',
                              )
                            : null,
                      ),
                  ],
                ),
              ),
            ],
          ],
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
                  subtitle: category.description,
                  trailing: _Trailing(
                    value: l10n.serviceCount(category.serviceCount),
                    isActive: category.isActive,
                  ),
                  onTap: canManage
                      ? () => context.push(
                          '${ServicesScreen.categoriesPath}/${category.id}',
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
                  // How prices show it; nothing when that's just the name.
                  subtitle: unit.abbreviation == null
                      ? null
                      : l10n.shownAs(unit.abbreviation!),
                  trailing: _Trailing(
                    value: l10n.serviceCount(unit.serviceCount),
                    isActive: unit.isActive,
                  ),
                  onTap: canManage
                      ? () => context.push(
                          '${ServicesScreen.unitsPath}/${unit.id}',
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
