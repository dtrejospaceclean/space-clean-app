import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/service_item.dart';
import '../controllers/service_catalog_providers.dart';

/// The company-wide service catalog: search, filter by status, open a
/// service to edit it, or add one.
class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  static const path = '/me/services';

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  late final _search = TextEditingController(
    text: ref.read(serviceQueryProvider).search,
  );
  Timer? _debounce;

  /// Typed text waiting out the debounce, not yet searched.
  bool _pending = false;

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
      ref.read(serviceQueryProvider.notifier).search(text);
      setState(() => _pending = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final services = ref.watch(servicesProvider);
    final query = ref.watch(serviceQueryProvider);
    final canManage = ref.watch(canManageServicesProvider);
    Future<void> refresh() => ref.refresh(servicesProvider.future);

    return SpacePage(
      title: l10n.servicesTitle,
      onRefresh: refresh,
      actions: [
        if (canManage)
          CircleButton.dark(
            icon: Icons.add_rounded,
            tooltip: l10n.addService,
            onPressed: () => context.push('${ServicesScreen.path}/new'),
          ),
      ],
      slivers: [
        PageBox(
          top: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SearchField(
                controller: _search,
                hint: l10n.searchServicesHint,
                onChanged: _onSearch,
                // From the first keystroke until the results are in.
                busy: _pending || services.isLoading,
              ),
              const SizedBox(height: 12),
              PillToggle<bool?>(
                options: {
                  true: l10n.filterActive,
                  false: l10n.filterInactive,
                  null: l10n.filterAll,
                },
                selected: query.isActive,
                onChanged: (v) =>
                    ref.read(serviceQueryProvider.notifier).status(v),
              ),
            ],
          ),
        ),
        AsyncSlivers(
          value: services,
          onRetry: refresh,
          builder: (list) {
            if (list.isEmpty) {
              // No search and the default filter: the catalog is empty.
              final unfiltered =
                  query.search.trim().isEmpty && query.isActive == true;
              return MessageSliver(
                icon: Icons.cleaning_services_outlined,
                title: unfiltered ? l10n.noServicesYet : l10n.noServicesFound,
                hint: unfiltered
                    ? (canManage ? l10n.noServicesYetHint : null)
                    : l10n.noServicesFoundHint,
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
                        ?service.category,
                        _price(context, l10n, service),
                      ].join(' · '),
                      trailing: service.isActive
                          ? null
                          : StatusPill(
                              label: l10n.inactiveTag,
                              color: context.colors.inkMuted,
                              background: context.colors.sunken,
                            ),
                      onTap: canManage
                          ? () => context.push(
                              '${ServicesScreen.path}/${service.id}',
                            )
                          : null,
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  /// "$0.12 / sq ft", or "per sq ft" without a default price.
  static String _price(
    BuildContext context,
    AppLocalizations l10n,
    ServiceItem service,
  ) => switch (service.defaultPrice) {
    final price? => l10n.pricePerUnit(
      context.formatMoney(price),
      service.unitOfMeasure,
    ),
    null => l10n.perUnit(service.unitOfMeasure),
  };
}
