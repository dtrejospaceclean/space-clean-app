import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens.dart';

class BottomBarItem {
  const BottomBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// The tab dock: a white pill resting on the ground, inset from the screen
/// edges like a card. The current tab is a solid orange pill with its filled
/// icon and label side by side; the others stack an outlined icon over a
/// muted label. Same on both platforms. Flat, per the No-Shadow Rule: it
/// separates from the page by tone, and content stops above it.
class SpaceBottomBar extends StatelessWidget {
  const SpaceBottomBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<BottomBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// How much wider the current tab is than the others, so its label fits
  /// beside the icon.
  static const _activeWeight = 1.3;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Above the home indicator or navigation bar, never flush with the edge.
    final bottom = math.max(MediaQuery.viewPaddingOf(context).bottom, 12.0);
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 240);

    return ColoredBox(
      color: c.ground,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, bottom),
        child: Material(
          color: c.surface,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final unit =
                    constraints.maxWidth / (items.length - 1 + _activeWeight);
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (i, item) in items.indexed)
                        AnimatedContainer(
                          duration: duration,
                          curve: Curves.easeOutCubic,
                          width: i == currentIndex
                              ? unit * _activeWeight
                              : unit,
                          child: _Tab(
                            item: item,
                            active: i == currentIndex,
                            duration: duration,
                            onTap: () => onTap(i),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.item,
    required this.active,
    required this.duration,
    required this.onTap,
  });

  final BottomBarItem item;
  final bool active;
  final Duration duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final label = Text(
      item.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: 'Manrope',
        fontSize: active ? 14 : 12.5,
        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
        color: active ? c.onPrimary : c.inkMuted,
      ),
    );

    return Semantics(
      selected: active,
      button: true,
      label: item.label,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: duration,
        curve: Curves.easeOutCubic,
        decoration: ShapeDecoration(
          color: active ? c.primary : c.primary.withValues(alpha: 0),
          shape: const StadiumBorder(),
        ),
        child: Material(
          type: MaterialType.transparency,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              // Well above the 48dp minimum: gloves, one hand, on the move.
              constraints: const BoxConstraints(minHeight: 58),
              child: AnimatedSwitcher(
                duration: duration,
                child: active
                    ? Padding(
                        key: const ValueKey(true),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(item.activeIcon, color: c.onPrimary, size: 22),
                            const SizedBox(width: 8),
                            Flexible(child: label),
                          ],
                        ),
                      )
                    : Padding(
                        key: const ValueKey(false),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 6,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(item.icon, color: c.inkMuted, size: 24),
                            const SizedBox(height: 3),
                            label,
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
