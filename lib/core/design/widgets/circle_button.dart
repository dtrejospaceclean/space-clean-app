import 'package:flutter/material.dart';

import '../tokens.dart';

/// The round header buttons: orange for the main action ("+"), white for
/// secondary ones (back, arrows). 44 dp visible, 48 dp touch target.
/// While [busy] it shows a spinner in place of the icon and can't be tapped.
class CircleButton extends StatelessWidget {
  const CircleButton.dark({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.busy = false,
  }) : _dark = true;

  const CircleButton.light({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.busy = false,
  }) : _dark = false;

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool busy;
  final bool _dark;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        enabled: !busy && onPressed != null,
        label: tooltip,
        excludeSemantics: true,
        child: SizedBox.square(
          dimension: 48,
          child: Center(
            child: Material(
              color: _dark ? context.colors.primary : context.colors.surface,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: busy ? null : onPressed,
                child: SizedBox.square(
                  dimension: 44,
                  child: busy
                      ? Center(
                          child: SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: _dark
                                  ? context.colors.onPrimary
                                  : context.colors.ink,
                            ),
                          ),
                        )
                      : Icon(
                          icon,
                          size: 22,
                          color: _dark
                              ? context.colors.onPrimary
                              : context.colors.ink,
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
