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

/// One site: a head card (name, address, Edit), then capitals-titled cards
/// for how to get in and what the crew should know, and what uses it. Editing and deleting need `info.edit`; a location used by
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
      slivers: [
        AsyncSlivers(
          value: location,
          skeleton: SkeletonLayout.detail,
          onRetry: refresh,
          builder: (l) {
            // Beside the name it would squeeze it at large text sizes, so
            // it moves under the address there.
            final large = MediaQuery.textScalerOf(context).scale(1) >= 1.5;
            final edit = canEdit
                ? PillButton(
                    label: l10n.editButton,
                    icon: Icons.edit_outlined,
                    tooltip: l10n.editLocation,
                    onPressed: () => context.push('$here/edit'),
                  )
                : null;

            return SliverMainAxisGroup(
              slivers: [
                PageBox(
                  top: 4,
                  child: SpaceCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const IconBadge.strong(
                          icon: Icons.location_on_outlined,
                          size: 64,
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
                              if (edit != null && large) ...[
                                const SizedBox(height: 10),
                                edit,
                              ],
                            ],
                          ),
                        ),
                        if (edit != null && !large) ...[
                          const SizedBox(width: 8),
                          edit,
                        ],
                      ],
                    ),
                  ),
                ),
                PageBox(top: 16, child: CapsHeader(l10n.sectionSiteDetails)),
                PageBox(
                  top: 0,
                  child: FactCard(
                    rows: [
                      [
                        (
                          l10n.squareFootageLabel,
                          switch (l.squareFootage) {
                            final sqft? => l10n.squareFootageValue(
                              context.formatNumber(sqft),
                            ),
                            null => null,
                          },
                        ),
                        (l10n.floorCountLabel, l.floorCount?.toString()),
                      ],
                      // Free text: each on a row of its own.
                      [(l10n.accessCodesLabel, orNull(l.accessCodes))],
                      [
                        (
                          l10n.specialInstructionsLabel,
                          orNull(l.specialInstructions),
                        ),
                      ],
                    ],
                  ),
                ),
                PageBox(top: 16, child: CapsHeader(l10n.sectionUsedBy)),
                PageBox(
                  top: 0,
                  child: FactCard(
                    rows: [
                      [
                        (
                          l10n.moduleScope,
                          l10n.scopeOfWorkCount(l.scopeOfWorkCount),
                        ),
                        (l10n.moduleJobs, l10n.jobCount(l.jobCount)),
                      ],
                    ],
                  ),
                ),
                if (canEdit)
                  PageBox(
                    top: 20,
                    // Only unused locations can be deleted (the API refuses
                    // otherwise); used ones say why.
                    child: l.isInUse
                        ? Text(
                            l10n.locationInUse,
                            style: theme.textTheme.bodySmall,
                          )
                        : Center(
                            child: LinkButton(
                              label: l10n.deleteLocation,
                              icon: Icons.delete_outline_rounded,
                              destructive: true,
                              onPressed: () => _delete(context, ref, l),
                            ),
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
