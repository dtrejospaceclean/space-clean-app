import 'package:flutter/material.dart';

import '../tokens.dart';

/// The one main action on a screen: an orange pill, full width, 56 dp.
/// Keeps its color and shows a spinner while [busy].
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: !busy && onPressed != null,
      label: label,
      excludeSemantics: true,
      child: FilledButton(
        onPressed: busy ? null : onPressed,
        child: busy
            ? SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: context.colors.onPrimary,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Flexible(child: Text(label)),
                ],
              ),
      ),
    );
  }
}

/// A white pill for secondary actions ("Sign out", "Deactivate").
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.destructive = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? context.colors.danger : context.colors.ink;
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: context.colors.surface,
        foregroundColor: color,
        disabledBackgroundColor: context.colors.surface,
        disabledForegroundColor: context.colors.inkFaint,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
          Flexible(child: Text(label)),
        ],
      ),
    );
  }
}

/// An inline text action ("Forgot password?", "Not you?"). [destructive]
/// turns it red, for a quiet "Delete account" at the foot of a page.
class LinkButton extends StatelessWidget {
  const LinkButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.destructive = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final style = TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      foregroundColor: destructive ? context.colors.danger : null,
      disabledForegroundColor: context.colors.inkFaint,
    );
    final icon = this.icon;
    if (icon == null) {
      return TextButton(onPressed: onPressed, style: style, child: Text(label));
    }
    return TextButton.icon(
      onPressed: onPressed,
      style: style,
      icon: Icon(icon, size: 20),
      label: Text(label),
    );
  }
}

/// A small sunken pill with an icon, at a card's corner ("✎ Edit").
/// [tooltip] names it in full for screen readers ("Edit account").
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    excludeFromSemantics: true,
    child: Semantics(
      button: true,
      enabled: onPressed != null,
      label: tooltip,
      excludeSemantics: true,
      child: TextButton.icon(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: context.colors.sunken,
          foregroundColor: context.colors.ink,
          disabledForegroundColor: context.colors.inkFaint,
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: const StadiumBorder(),
        ),
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    ),
  );
}
