import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../design/design.dart';
import '../domain/priority.dart';

extension PriorityNames on AppLocalizations {
  String priorityName(Priority priority) => switch (priority) {
    Priority.high => priorityHigh,
    Priority.medium => priorityMedium,
    Priority.low => priorityLow,
    Priority.unknown => priorityUnknown,
  };
}

/// The priority as a pill: high in red with an up arrow, the rest muted
/// with their own arrows, so it reads without color.
class PriorityLabel extends StatelessWidget {
  const PriorityLabel({super.key, required this.priority});

  final Priority priority;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (IconData icon, Color color, Color background) = switch (priority) {
      Priority.high => (
        Icons.keyboard_double_arrow_up_rounded,
        c.danger,
        c.dangerSoft,
      ),
      Priority.medium => (Icons.drag_handle_rounded, c.inkSoft, c.sunken),
      Priority.low => (Icons.keyboard_arrow_down_rounded, c.inkMuted, c.sunken),
      Priority.unknown => (Icons.help_outline_rounded, c.inkMuted, c.sunken),
    };
    return StatusPill(
      label: AppLocalizations.of(context).priorityName(priority),
      icon: icon,
      color: color,
      background: background,
    );
  }
}
