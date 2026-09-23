import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/threshold_palette.dart';
import '../adaptive.dart';

/// The one primary action on a threshold screen: full width, 60 dp tall.
/// Material filled button on Android, Cupertino filled button on iOS.
class ThresholdButton extends StatelessWidget {
  const ThresholdButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;

  /// Shows a spinner and ignores taps, keeping the button's color.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final palette = ThresholdPalette.of(context);
    final cupertino = useCupertino(context);
    final child = busy
        ? SizedBox.square(
            dimension: 24,
            child: cupertino
                ? CupertinoActivityIndicator(color: palette.onAction)
                : CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: palette.onAction,
                  ),
          )
        : Text(label);
    final textStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: palette.onAction,
    );

    return Semantics(
      button: true,
      enabled: !busy && onPressed != null,
      label: label,
      excludeSemantics: true,
      child: SizedBox(
        height: 60,
        width: double.infinity,
        child: cupertino
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                color: palette.action,
                disabledColor: palette.action,
                borderRadius: BorderRadius.circular(14),
                onPressed: busy ? null : onPressed,
                child: DefaultTextStyle(style: textStyle!, child: child),
              )
            : FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: palette.action,
                  foregroundColor: palette.onAction,
                  disabledBackgroundColor: palette.action,
                  disabledForegroundColor: palette.onAction,
                  textStyle: textStyle,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: busy ? null : onPressed,
                child: child,
              ),
      ),
    );
  }
}

/// Secondary text action on a threshold screen, e.g. "Forgot password?".
class ThresholdLinkButton extends StatelessWidget {
  const ThresholdLinkButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;

  /// Smaller type, for use inside a label row.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = ThresholdPalette.of(context);
    final color = onPressed == null ? palette.onGroundMuted : palette.link;
    final style = TextStyle(
      fontSize: compact ? 15 : 16,
      fontWeight: FontWeight.w600,
      color: color,
      decoration: TextDecoration.underline,
      decorationColor: color,
      decorationThickness: 1.5,
    );

    if (useCupertino(context)) {
      return CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        minimumSize: const Size(48, 48),
        onPressed: onPressed,
        child: Text(label, style: style),
      );
    }
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: palette.link,
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      onPressed: onPressed,
      child: Text(label, style: style),
    );
  }
}
