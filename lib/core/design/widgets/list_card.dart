import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens.dart';
import 'cards.dart';

/// Rows inside one white card, separated by hairlines.
class ListCard extends StatelessWidget {
  const ListCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SpaceCard(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          for (final (i, child) in children.indexed) ...[
            if (i > 0)
              const Divider(
                indent: SpaceSpace.card,
                endIndent: SpaceSpace.card,
              ),
            child,
          ],
        ],
      ),
    );
  }
}

/// A row in a [ListCard]: optional leading badge/avatar, title, muted
/// subtitle, trailing value; a chevron when tappable.
class ListRow extends StatelessWidget {
  const ListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.tag,
    this.leading,
    this.trailing,
    this.onTap,
    this.destructive = false,
    this.muted = false,
    this.chevron,
  });

  final String title;
  final String? subtitle;

  /// A small widget under the subtitle, such as a status pill.
  final Widget? tag;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;

  /// For a missing value ("Not set"): the title recedes to muted ink so it
  /// doesn't read like real data.
  final bool muted;

  /// Whether to end with a chevron. Defaults to showing one when tappable;
  /// rows that act in place (a choice) turn it off.
  final bool? chevron;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 60),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpaceSpace.card,
            vertical: 10,
          ),
          child: Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 14)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: destructive
                            ? context.colors.danger
                            : muted
                            ? context.colors.inkMuted
                            : null,
                        fontWeight: muted ? FontWeight.w500 : null,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!, style: theme.textTheme.bodyMedium),
                    ],
                    if (tag case final tag?) ...[
                      const SizedBox(height: 6),
                      tag,
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12),
                DefaultTextStyle.merge(
                  style: theme.textTheme.bodyMedium,
                  child: trailing!,
                ),
              ],
              if (chevron ?? onTap != null) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.colors.inkSoft,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// One option of a single choice in a [ListCard] (a language, a theme):
/// tapping picks it, and the picked one shows a filled check. Read out as a
/// selected or unselected option of a group. With [multiple], one of several
/// that can be picked together (an invoice's recipients): tapping toggles it,
/// and it's read out as a checkbox.
class ChoiceRow extends StatelessWidget {
  const ChoiceRow({
    super.key,
    required this.title,
    required this.selected,
    required this.onSelect,
    this.subtitle,
    this.leading,
    this.multiple = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final bool selected;

  /// Picks it; with [multiple], toggles it.
  final VoidCallback onSelect;
  final bool multiple;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Semantics(
      checked: selected,
      inMutuallyExclusiveGroup: !multiple,
      child: ListRow(
        title: title,
        subtitle: subtitle,
        leading: leading,
        chevron: false,
        onTap: selected && !multiple
            ? null
            : () {
                HapticFeedback.selectionClick();
                onSelect();
              },
        // The shape changes too, so the choice never rests on color alone.
        trailing: Icon(
          selected ? Icons.check_circle_rounded : Icons.circle_outlined,
          size: 26,
          color: selected ? context.colors.accent : context.colors.inkSoft,
        ),
      ),
    ),
  );
}
