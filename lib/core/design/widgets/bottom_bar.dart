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

/// White tab bar: outlined blue-gray icons; the active tab orange with a filled
/// icon and bold label, over a navy dot. Same on both platforms.
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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SpaceColors.surface,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              for (final (i, item) in items.indexed)
                Expanded(
                  child: _Tab(
                    item: item,
                    active: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.item, required this.active, required this.onTap});

  final BottomBarItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? SpaceColors.primary : SpaceColors.inkMuted;
    return Semantics(
      selected: active,
      button: true,
      label: item.label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(active ? item.activeIcon : item.icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12.5,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
            const SizedBox(height: 3),
            // A navy dot pairs the logo's two colors on the current tab.
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: active ? 5 : 0,
              height: 5,
              decoration: const BoxDecoration(
                color: SpaceColors.accent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
