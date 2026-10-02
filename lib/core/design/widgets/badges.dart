import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../tokens.dart';

/// Round icon badge at the top of tiles.
class IconBadge extends StatelessWidget {
  const IconBadge({
    super.key,
    required this.icon,
    this.color,
    this.background,
    this.size = 40,
  }) : _strong = false;

  /// Solid accent badge (navy in light mode) with a contrasting icon.
  const IconBadge.strong({super.key, required this.icon, this.size = 40})
    : color = null,
      background = null,
      _strong = true;

  final IconData icon;

  /// Defaults to the accent on its soft tint.
  final Color? color;
  final Color? background;
  final double size;
  final bool _strong;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background ?? (_strong ? c.accent : c.accentSoft),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color ?? (_strong ? c.onAccent : c.accent),
        size: size * 0.5,
      ),
    );
  }
}

/// Initials in a circle ("WJ"), for people and accounts.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.name,
    this.size = 44,
    this.background,
    this.foreground,
  });

  final String name;
  final double size;

  /// Default to the sunken tone with ink initials.
  final Color? background;
  final Color? foreground;

  static String initialsOf(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    final first = parts.first.characters.first;
    final last = parts.length > 1 ? parts.last.characters.first : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background ?? context.colors.sunken,
        shape: BoxShape.circle,
      ),
      child: Text(
        initialsOf(name),
        style: TextStyle(
          fontFamily: 'Manrope',
          color: foreground ?? context.colors.ink,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.34,
        ),
      ),
    ),
  );
}

/// Small rounded label with a colored dot or icon: status, tags.
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.color,
    required this.background,
    this.icon,
  });

  final String label;
  final Color color;
  final Color background;

  /// Keeps meaning without color alone.
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(SpaceRadius.pill),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
        ],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Manrope',
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Active or inactive as an icon, for lists that show both: a filled green
/// check or a muted outlined minus. The shapes differ, so color isn't the
/// only cue; screen readers and a long press give the word.
class StatusIcon extends StatelessWidget {
  const StatusIcon({super.key, required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = isActive ? l10n.activeTag : l10n.inactiveTag;
    return Tooltip(
      message: label,
      child: Semantics(
        label: label,
        excludeSemantics: true,
        child: Icon(
          isActive
              ? Icons.check_circle_rounded
              : Icons.remove_circle_outline_rounded,
          size: 20,
          color: isActive ? context.colors.success : context.colors.inkMuted,
        ),
      ),
    );
  }
}

/// A small orange count over the top-right of [child] (an avatar): unread
/// notifications. Hidden at 0; "99+" past that. Visual only, so the
/// widget that owns it says the count to screen readers.
class CountBadge extends StatelessWidget {
  const CountBadge({super.key, required this.count, required this.child});

  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return child;
    final c = context.colors;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        PositionedDirectional(
          top: -4,
          end: -6,
          child: ExcludeSemantics(
            child: Container(
              constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              alignment: Alignment.center,
              // A ring in the page's tone keeps it apart from the avatar.
              decoration: ShapeDecoration(
                color: c.primary,
                shape: StadiumBorder(
                  side: BorderSide(color: c.ground, width: 2),
                ),
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  color: c.onPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
