import 'package:flutter/material.dart';

/// Whether to use Cupertino conventions (iOS) instead of Material (Android).
bool useCupertino(BuildContext context) => switch (Theme.of(context).platform) {
  TargetPlatform.iOS || TargetPlatform.macOS => true,
  _ => false,
};
