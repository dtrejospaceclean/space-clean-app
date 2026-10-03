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

/// Every area of an account with a switch per action; the [granted] ones
/// are on. Read-only without [onToggle]: each action then shows a check or a
/// dash instead of a switch. [enabled] false keeps the switches but locks
/// them (while saving).
class AccessList extends StatelessWidget {
  const AccessList({
    super.key,
    required this.catalog,
    required this.granted,
    this.onToggle,
    this.enabled = true,
  });

  final PermissionCatalog catalog;
  final Set<String> granted;
  final ValueChanged<String>? onToggle;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onToggle = this.onToggle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, MapEntry(key: module, value: permissions))
            in catalog.byModule.entries.indexed) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, color: context.colors.line),
            ),
          // One block per area, read as a group.
          Semantics(
            container: true,
            explicitChildNodes: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 2),
                  child: Semantics(
                    header: true,
                    child: Text(
                      l10n.accessModule(module),
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: context.colors.ink,
                      ),
                    ),
                  ),
                ),
                for (final p in permissions)
                  SwitchRow(
                    label: l10n.accessAction(p),
                    value: granted.contains(p),
                    readOnly: onToggle == null,
                    onChanged: onToggle == null || !enabled
                        ? null
                        : (_) => onToggle(p),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
