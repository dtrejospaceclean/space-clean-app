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
    this.color = SpaceColors.surface,
    this.footer,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color color;

  /// Full-bleed strip at the bottom edge (see [AccentBanner]).
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final body = Padding(padding: padding, child: child);
    return Material(
      color: color,
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
                Icon(trailingIcon, size: 18, color: SpaceColors.ink),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: compact ? 26 : null,
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
  });

  final Widget icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SpaceCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(height: 28),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
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

/// Lays out cards two per row with the standard gap. Each row takes the
/// height of its taller card.
class CardGrid extends StatelessWidget {
  const CardGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += 2) {
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: children[i]),
              const SizedBox(width: SpaceSpace.gap),
              Expanded(
                child: i + 1 < children.length
                    ? children[i + 1]
                    : const SizedBox.shrink(),
              ),
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
      color: SpaceColors.accent,
      padding: const EdgeInsets.symmetric(
        horizontal: SpaceSpace.card,
        vertical: 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: SpaceColors.onAccent,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
