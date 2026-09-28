import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../core/widgets/adaptive.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../access/domain/entities/account_access.dart';
import '../../../access/presentation/controllers/account_access_provider.dart';
import '../../di/locations_providers.dart';
import '../../domain/entities/location.dart';
import '../../domain/usecases/location_usecases.dart';
import '../controllers/locations_providers.dart';

/// One site: where it is, how to get in, what the crew should know, and
/// what uses it. Editing and deleting need `info.edit`; a location used by
/// scopes of work or jobs can't be deleted.
class LocationScreen extends ConsumerWidget {
  const LocationScreen({
    super.key,
    required this.clientId,
    required this.locationId,
  });

  final String clientId;
  final String locationId;

  Future<void> _delete(BuildContext context, WidgetRef ref, Location l) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(l10n.deleteRoleConfirmTitle(l.name)),
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
    if (confirmed != true) return;
    try {
      await ref.read(deleteLocationProvider)(
        LocationRef(clientId: clientId, locationId: l.id),
      );
      if (!context.mounted) return;
      // Leave before the lists reload, so this page doesn't flash "not
      // found" on its way out.
      context.pop();
      invalidateLocations(ref, clientId);
    } on Failure catch (f) {
      if (context.mounted) {
        await showAdaptiveDialog<void>(
          context: context,
          builder: (context) => AlertDialog.adaptive(
            content: Text(l10n.failureMessage(f)),
            actions: [
              adaptiveAction(
                context,
                label: l10n.doneButton,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final location = ref.watch(locationProvider((clientId, locationId)));
    final canEdit =
        ref
            .watch(accountAccessProvider(clientId))
            .value
            ?.can(Permissions.infoEdit) ??
        false;
    final here = GoRouterState.of(context).matchedLocation;
    Future<void> refresh() =>
        ref.refresh(locationProvider((clientId, locationId)).future);

    String? orNull(String? v) => v == null || v.trim().isEmpty ? null : v;

    return SpacePage(
      title: l10n.locationTitle,
      onRefresh: refresh,
      actions: [
        if (canEdit && location.hasValue)
          CircleButton.dark(
            icon: Icons.edit_outlined,
            tooltip: l10n.editLocation,
            onPressed: () => context.push('$here/edit'),
          ),
      ],
      slivers: [
        AsyncSlivers(
          value: location,
          onRetry: refresh,
          builder: (l) {
            /// A fact: its value as the title, what it is underneath.
            ListRow fact(IconData icon, String label, String? value) => ListRow(
              leading: IconBadge(icon: icon),
              title: orNull(value) ?? l10n.notSet,
              subtitle: label,
              muted: orNull(value) == null,
            );

            return SliverMainAxisGroup(
              slivers: [
                PageBox(
                  top: 4,
                  child: SpaceCard(
                    child: Row(
                      children: [
                        IconBadge.strong(
                          icon: Icons.location_on_outlined,
                          size: 56,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l.name, style: theme.textTheme.titleLarge),
                              for (final line in [l.address, l.cityLine])
                                if (orNull(line) case final line?)
                                  Text(line, style: theme.textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                PageBox(
                  top: 12,
                  child: SectionHeader(title: l10n.sectionSiteDetails),
                ),
                PageBox(
                  top: 0,
                  child: ListCard(
                    children: [
                      fact(
                        Icons.square_foot_rounded,
                        l10n.squareFootageLabel,
                        switch (l.squareFootage) {
                          final sqft? => l10n.squareFootageValue(
                            context.formatNumber(sqft),
                          ),
                          null => null,
                        },
                      ),
                      fact(
                        Icons.layers_outlined,
                        l10n.floorCountLabel,
                        l.floorCount?.toString(),
                      ),
                      fact(
                        Icons.key_outlined,
                        l10n.accessCodesLabel,
                        l.accessCodes,
                      ),
                    ],
                  ),
                ),
                if (orNull(l.specialInstructions) case final notes?) ...[
                  PageBox(
                    top: 12,
                    child: SectionHeader(title: l10n.specialInstructionsLabel),
                  ),
                  PageBox(
                    top: 0,
                    child: SpaceCard(
                      child: Text(notes, style: theme.textTheme.bodyLarge),
                    ),
                  ),
                ],
                PageBox(
                  top: 12,
                  child: SectionHeader(title: l10n.sectionUsedBy),
                ),
                PageBox(
                  top: 0,
                  child: ListCard(
                    children: [
                      ListRow(
                        leading: const IconBadge(
                          icon: Icons.assignment_outlined,
                        ),
                        title: l10n.scopeOfWorkCount(l.scopeOfWorkCount),
                        muted: l.scopeOfWorkCount == 0,
                      ),
                      ListRow(
                        leading: const IconBadge(
                          icon: Icons.cleaning_services_outlined,
                        ),
                        title: l10n.jobCount(l.jobCount),
                        muted: l.jobCount == 0,
                      ),
                    ],
                  ),
                ),
                if (canEdit)
                  PageBox(
                    top: 24,
                    // Only unused locations can be deleted (the API refuses
                    // otherwise); used ones say why.
                    child: l.isInUse
                        ? Text(
                            l10n.locationInUse,
                            style: theme.textTheme.bodySmall,
                          )
                        : SecondaryButton(
                            label: l10n.deleteLocation,
                            icon: Icons.delete_outline_rounded,
                            destructive: true,
                            onPressed: () => _delete(context, ref, l),
                          ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
