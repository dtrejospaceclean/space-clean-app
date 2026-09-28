import 'package:flutter/material.dart';

import '../../../../core/design/design.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/member.dart';

extension AccessLabels on AppLocalizations {
  /// The area a permission belongs to ("jobs" → "Jobs").
  String accessModule(String module) => switch (module) {
    'info' => moduleInfo,
    'proposal' => moduleProposals,
    'contract' => moduleContracts,
    'scope' => moduleScope,
    'jobs' => moduleJobs,
    'complaints' => moduleComplaints,
    'calendar' => moduleCalendar,
    'tasks' => moduleTasks,
    'files' => moduleFiles,
    'team' => moduleTeam,
    'timeline' => moduleTimeline,
    _ => module,
  };

  /// What a permission allows in its area ("jobs.assign" → "Assign").
  String accessAction(String permission) =>
      switch (permission.split('.').last) {
        'view' => accessView,
        'edit' => accessEdit,
        'assign' => accessAssign,
        'download' => accessDownload,
        'upload' => accessUpload,
        'manage' => accessManage,
        final action => action,
      };
}

/// Every area of an account with its actions as pills; the [granted] ones
/// are on. Read-only without [onToggle].
class AccessList extends StatelessWidget {
  const AccessList({
    super.key,
    required this.catalog,
    required this.granted,
    this.onToggle,
  });

  final PermissionCatalog catalog;
  final Set<String> granted;
  final ValueChanged<String>? onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, MapEntry(key: module, value: permissions))
            in catalog.byModule.entries.indexed) ...[
          if (i > 0) const SizedBox(height: 14),
          // One block per area, read as a group.
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.accessModule(module),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: context.colors.ink,
                ),
              ),
              const SizedBox(height: 8),
              ChoicePills<String>(
                options: {for (final p in permissions) p: l10n.accessAction(p)},
                selected: granted,
                onToggle: onToggle,
              ),
            ],
          ),
        ],
      ],
    );
  }
}
