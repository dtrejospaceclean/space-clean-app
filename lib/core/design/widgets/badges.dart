import 'package:flutter/material.dart';

import '../tokens.dart';

/// Round icon badge at the top of tiles.
class IconBadge extends StatelessWidget {
  const IconBadge({
    super.key,
    required this.icon,
    this.color = SpaceColors.accent,
    this.background = SpaceColors.accentSoft,
    this.size = 40,
  });

  /// Solid navy badge with a white icon.
  const IconBadge.strong({super.key, required this.icon, this.size = 40})
    : color = SpaceColors.onAccent,
      background = SpaceColors.accent;

  final IconData icon;
  final Color color;
  final Color background;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: background, shape: BoxShape.circle),
    child: Icon(icon, color: color, size: size * 0.5),
  );
}

/// Initials in a circle ("WJ"), for people and accounts.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.name,
    this.size = 44,
    this.background = SpaceColors.sunken,
    this.foreground = SpaceColors.ink,
  });

  final String name;
  final double size;
  final Color background;
  final Color foreground;

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
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Text(
        initialsOf(name),
        style: TextStyle(
          fontFamily: 'Manrope',
          color: foreground,
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
