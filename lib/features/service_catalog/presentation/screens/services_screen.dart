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
    final categoryName = switch (query.categoryId) {
      final id? =>
        ref
            .watch(activeCategoriesProvider)
            .value
            ?.where((c) => c.id == id)
            .firstOrNull
            ?.name,
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
              const SizedBox(height: 16),
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
                const SizedBox(height: 12),
                PickerField(
                  label: l10n.serviceCategoryLabel,
                  value: query.categoryId == null
                      ? l10n.allCategories
                      : categoryName ?? '…',
                  onTap: _pickCategory,
                ),
              ],
              const SizedBox(height: 12),
              PillToggle<bool?>(
                options: {
                  true: l10n.filterActive,
                  false: l10n.filterInactive,
                  null: l10n.filterAll,
                },
                selected: query.isActive,
                onChanged: _query.status,
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

Widget? _inactivePill(BuildContext context, bool isActive) => isActive
    ? null
    : StatusPill(
        label: AppLocalizations.of(context).inactiveTag,
        color: context.colors.inkMuted,
        background: context.colors.sunken,
      );

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
                  leading: const IconBadge(
                    icon: Icons.cleaning_services_outlined,
                  ),
                  title: service.name,
                  subtitle: [
                    ?service.category?.name,
                    servicePrice(context, service),
                  ].join(' · '),
                  trailing: _inactivePill(context, service.isActive),
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

/// "$0.12 / sq ft", or "per sq ft" without a default price.
String servicePrice(BuildContext context, ServiceItem service) {
  final l10n = AppLocalizations.of(context);
  return switch (service.defaultPrice) {
    final price? => l10n.pricePerUnit(
      context.formatMoney(price),
      service.unit.short,
    ),
    null => l10n.perUnit(service.unit.short),
  };
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
                  leading: const IconBadge(icon: Icons.category_outlined),
                  title: category.name,
                  subtitle: [
                    ?category.description,
                    l10n.serviceCount(category.serviceCount),
                  ].join(' · '),
                  trailing: _inactivePill(context, category.isActive),
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
                  leading: const IconBadge(icon: Icons.straighten_rounded),
                  title: unit.name,
                  subtitle: [
                    ?unit.abbreviation,
                    l10n.serviceCount(unit.serviceCount),
                  ].join(' · '),
                  trailing: _inactivePill(context, unit.isActive),
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
