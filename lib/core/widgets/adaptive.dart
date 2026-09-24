import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../design/tokens.dart';

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
      // Navy, not the orange primary: orange text on the translucent iOS
      // alert would fall under 4.5:1. Destructive actions keep system red.
      textStyle: destructive
          ? null
          : const TextStyle(color: SpaceColors.accent),
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
