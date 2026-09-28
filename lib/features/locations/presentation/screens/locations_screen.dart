import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../access/domain/entities/account_access.dart';
import '../../../access/presentation/controllers/account_access_provider.dart';
import '../controllers/locations_providers.dart';

/// The sites of one client account, by name, with a search. New ones come
/// from the dock's "+" (`info.edit`).
class LocationsScreen extends ConsumerStatefulWidget {
  const LocationsScreen({super.key, required this.clientId});

  /// Path segment under `/accounts/:clientId`.
  static const route = 'locations';

  final String clientId;

  @override
  ConsumerState<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends ConsumerState<LocationsScreen> {
  late final _search = TextEditingController(
    text: ref.read(locationSearchProvider(widget.clientId)),
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
      ref.read(locationSearchProvider(widget.clientId).notifier).search(text);
      setState(() => _pending = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final clientId = widget.clientId;
    final locations = ref.watch(locationsProvider(clientId));
    final searching = ref.watch(locationSearchProvider(clientId)).isNotEmpty;
    final canEdit =
        ref
            .watch(accountAccessProvider(clientId))
            .value
            ?.can(Permissions.infoEdit) ??
        false;
    final here = GoRouterState.of(context).matchedLocation;
    Future<void> refresh() => ref.refresh(locationsProvider(clientId).future);

    return SpacePage(
      title: l10n.moduleLocations,
      onRefresh: refresh,
      slivers: [
        PageBox(
          top: 4,
          child: SearchField(
            controller: _search,
            hint: l10n.searchLocationsHint,
            onChanged: _onSearch,
            // From the first keystroke until the results are in.
            busy: _pending || locations.isLoading,
          ),
        ),
        AsyncSlivers(
          value: locations,
          onRetry: refresh,
          builder: (list) {
            if (list.isEmpty) {
              return searching
                  ? MessageSliver(
                      icon: Icons.location_on_outlined,
                      title: l10n.noMatchesFound,
                      hint: l10n.noMatchesHint,
                    )
                  : MessageSliver(
                      icon: Icons.location_on_outlined,
                      title: l10n.noLocationsYet,
                      hint: canEdit ? l10n.noLocationsYetHint : null,
                    );
            }
            return PageBox(
              child: ListCard(
                children: [
                  for (final location in list)
                    ListRow(
                      leading: const IconBadge(
                        icon: Icons.location_on_outlined,
                      ),
                      title: location.name,
                      subtitle: [
                        location.address,
                        location.cityLine,
                      ].where((v) => v.trim().isNotEmpty).join(', '),
                      onTap: () => context.push('$here/${location.id}'),
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
