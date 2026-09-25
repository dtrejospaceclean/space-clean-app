import 'package:flutter/material.dart';

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
    this.leading,
    this.trailing,
    this.onTap,
    this.destructive = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;

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
                        color: destructive ? context.colors.danger : null,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!, style: theme.textTheme.bodyMedium),
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
              if (onTap != null) ...[
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
