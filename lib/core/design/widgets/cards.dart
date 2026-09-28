import 'package:flutter/material.dart';

import '../tokens.dart';

/// The white rounded card: the only container in the app. No border, no
/// shadow. Tappable when [onTap] is set.
class SpaceCard extends StatelessWidget {
  const SpaceCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(SpaceSpace.card),
    this.color,
    this.footer,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  /// Defaults to the surface color.
  final Color? color;

  /// Full-bleed strip at the bottom edge (see [AccentBanner]).
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final body = Padding(padding: padding, child: child);
    return Material(
      color: color ?? context.colors.surface,
      borderRadius: BorderRadius.circular(SpaceRadius.card),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: footer == null
            ? body
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [body, footer!],
              ),
      ),
    );
  }
}

/// A small label over a big number, like "Total spend / $1,458.90".
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.trailingIcon,
    this.caption,
    this.onTap,
    this.compact = false,
  });

  final String label;
  final String value;

  /// Tighter padding and a smaller number, for three across.
  final bool compact;

  /// Round badge at the top ("Your stats" tiles).
  final Widget? icon;

  /// Small icon in the top-right corner (e.g. an arrow).
  final IconData? trailingIcon;

  /// Muted line under the value.
  final String? caption;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SpaceCard(
      onTap: onTap,
      padding: EdgeInsets.all(compact ? 16 : SpaceSpace.card),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, const SizedBox(height: 20)],
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              if (trailingIcon != null)
                Icon(trailingIcon, size: 18, color: context.colors.ink),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: compact ? 23 : null,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: 2),
            Text(caption!, style: theme.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

/// A tile in a two-column grid: badge, title, muted subtitle.
class TileCard extends StatelessWidget {
  const TileCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.compact = false,
  });

  final Widget icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  /// Tighter padding and a smaller title, both centered, for three across.
  /// The title wraps instead of truncating, so a narrow tile grows taller.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SpaceCard(
      onTap: onTap,
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 10, vertical: 14)
          : const EdgeInsets.all(SpaceSpace.card),
      child: Column(
        crossAxisAlignment: compact
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          SizedBox(height: compact ? 10 : 28),
          Text(
            title,
            textAlign: compact ? TextAlign.center : null,
            maxLines: compact ? null : 2,
            overflow: compact ? null : TextOverflow.ellipsis,
            style:
                (compact
                        ? theme.textTheme.titleSmall
                        : theme.textTheme.titleMedium)
                    ?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

/// Lays out cards [columns] per row (two by default) with the standard gap.
/// Each row takes the height of its tallest card; a short last row keeps
/// the same card width.
class CardGrid extends StatelessWidget {
  const CardGrid({super.key, required this.children, this.columns = 2});

  final List<Widget> children;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columns) {
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var j = i; j < i + columns; j++) ...[
                if (j > i) const SizedBox(width: SpaceSpace.gap),
                Expanded(
                  child: j < children.length
                      ? children[j]
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ),
      );
    }
    return Column(
      children: [
        for (final (i, row) in rows.indexed) ...[
          if (i > 0) const SizedBox(height: SpaceSpace.gap),
          row,
        ],
      ],
    );
  }
}

/// Cards side by side in one row, equal widths and heights.
class CardRow extends StatelessWidget {
  const CardRow({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, child) in children.indexed) ...[
          if (i > 0) const SizedBox(width: SpaceSpace.gap),
          Expanded(child: child),
        ],
      ],
    ),
  );
}

/// The navy strip along a card's bottom edge ("You saved $1,200 this month").
class AccentBanner extends StatelessWidget {
  const AccentBanner({super.key, required this.text, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.accent,
      padding: const EdgeInsets.symmetric(
        horizontal: SpaceSpace.card,
        vertical: 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: context.colors.onAccent,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
