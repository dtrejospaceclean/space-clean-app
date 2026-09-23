import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Whether to use Cupertino conventions (iOS) instead of Material (Android).
bool useCupertino(BuildContext context) => switch (Theme.of(context).platform) {
  TargetPlatform.iOS || TargetPlatform.macOS => true,
  _ => false,
};

/// Dialog button in the platform's style.
Widget adaptiveAction(
  BuildContext context, {
  required String label,
  required VoidCallback onPressed,
  bool destructive = false,
}) {
  if (useCupertino(context)) {
    return CupertinoDialogAction(
      isDestructiveAction: destructive,
      onPressed: onPressed,
      child: Text(label),
    );
  }
  return TextButton(
    onPressed: onPressed,
    style: destructive
        ? TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          )
        : null,
    child: Text(label),
  );
}
