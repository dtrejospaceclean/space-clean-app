import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../adaptive.dart';

/// A group of rows: an inset-grouped section on iOS, a titled list on Android.
class AppListSection extends StatelessWidget {
  const AppListSection({super.key, this.title, required this.children});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (useCupertino(context)) {
      return CupertinoListSection.insetGrouped(
        header: title == null
            ? null
            : Text(
                title!.toUpperCase(),
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.2,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
              ),
        children: children,
      );
    }
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                title!,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ...children,
        ],
      ),
    );
  }
}

/// One row: CupertinoListTile on iOS, ListTile on Android. Rows with [onTap]
/// show the platform's disclosure affordance.
class AppListRow extends StatelessWidget {
  const AppListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.destructive = false,
  });

  final String title;
  final String? subtitle;
  final IconData? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = destructive ? theme.colorScheme.error : null;
    final lead = leading == null ? null : Icon(leading, color: color);

    if (useCupertino(context)) {
      return CupertinoListTile(
        leading: lead,
        title: Text(title, style: TextStyle(color: color)),
        subtitle: subtitle == null ? null : Text(subtitle!),
        additionalInfo: trailing,
        trailing: onTap == null ? null : const CupertinoListTileChevron(),
        onTap: onTap,
      );
    }
    return ListTile(
      minTileHeight: 56,
      leading: lead,
      title: Text(title, style: TextStyle(color: color)),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
