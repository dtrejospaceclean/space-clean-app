import 'package:flutter/material.dart';

import '../tokens.dart';

/// The round header buttons: orange for the main action ("+"), white for
/// secondary ones (back, arrows). 44 dp visible, 48 dp touch target.
class CircleButton extends StatelessWidget {
  const CircleButton.dark({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  }) : _dark = true;

  const CircleButton.light({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  }) : _dark = false;

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool _dark;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        excludeSemantics: true,
        child: SizedBox.square(
          dimension: 48,
          child: Center(
            child: Material(
              color: _dark ? SpaceColors.primary : SpaceColors.surface,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onPressed,
                child: SizedBox.square(
                  dimension: 44,
                  child: Icon(
                    icon,
                    size: 22,
                    color: _dark ? Colors.white : SpaceColors.ink,
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
