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

  /// Not drawn: the tabs are icons only. Screen readers announce it and a
  /// long press shows it.
  final String label;
}

/// The one global action beside the tab dock (the round "+").
class BottomBarAction {
  const BottomBarAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
}

/// The tab dock: a floating white pill of icon-only tabs, with an optional
/// round orange action beside it. The current tab sits in a soft orange pill
/// with a filled Orange Ink icon. Same on both platforms. Flat, per the
/// No-Shadow Rule: it separates from the page by tone, and content stops
/// above it.
class SpaceBottomBar extends StatelessWidget {
  const SpaceBottomBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.action,
  });

  final List<BottomBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final BottomBarAction? action;

  /// The dock's height; the action circle matches it.
  static const height = 60.0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Just above the home indicator (tucked into its inset, which is mostly
    // empty space), or 16 from the edge when there is none.
    final inset = MediaQuery.viewPaddingOf(context).bottom;
    final bottom = inset > 0 ? inset - 8 : 16.0;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 200);
    final action = this.action;

    return ColoredBox(
      color: c.ground,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, bottom),
        child: Row(
          children: [
            Expanded(
              child: Material(
                color: c.surface,
                shape: const StadiumBorder(),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Row(
                    children: [
                      for (final (i, item) in items.indexed)
                        Expanded(
                          child: _Tab(
                            item: item,
                            active: i == currentIndex,
                            duration: duration,
                            onTap: () => onTap(i),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (action != null) ...[
              const SizedBox(width: 10),
              _ActionButton(action: action),
            ],
          ],
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

    return Tooltip(
      message: item.label,
      child: Semantics(
        selected: active,
        button: true,
        label: item.label,
        excludeSemantics: true,
        child: AnimatedContainer(
          duration: duration,
          curve: Curves.easeOutCubic,
          decoration: ShapeDecoration(
            color: active
                ? c.highlightSoft
                : c.highlightSoft.withValues(alpha: 0),
            shape: const StadiumBorder(),
          ),
          child: Material(
            type: MaterialType.transparency,
            shape: const StadiumBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: SizedBox(
                // 48 tall inside the 60 dock: a full thumb target.
                height: SpaceBottomBar.height - 12,
                child: Center(
                  child: Icon(
                    active ? item.activeIcon : item.icon,
                    color: active ? c.highlightInk : c.inkMuted,
                    size: 26,
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.action});

  final BottomBarAction action;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: action.label,
      child: Semantics(
        button: true,
        label: action.label,
        excludeSemantics: true,
        child: Material(
          color: context.colors.primary,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: action.onPressed,
            child: SizedBox.square(
              dimension: SpaceBottomBar.height,
              child: Icon(
                action.icon,
                color: context.colors.onPrimary,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
