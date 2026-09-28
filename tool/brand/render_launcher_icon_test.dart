// Renders the Android launcher icon PNGs from the logo's planet mark (the
// wordmark is unreadable at icon size).
//
//   flutter test --update-goldens tool/brand
//
// Then: dart run flutter_launcher_icons
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'render.dart';

const _mark = 'assets/brand/space_clean_mark.svg';
const _markWhite = 'assets/brand/space_clean_mark_white.svg';

void main() {
  // Adaptive icon (Android 8+): 108dp layers, of which launchers show at
  // least the middle 66dp circle. Keep the mark inside it.
  testWidgets(
    'foreground',
    (tester) => renderLogo(
      tester,
      'launcher_icon_foreground',
      asset: _mark,
      canvas: 1024,
      logo: 560,
    ),
  );
  // Themed icon (Android 13+): only the shape is used, tinted by the system.
  testWidgets(
    'monochrome',
    (tester) => renderLogo(
      tester,
      'launcher_icon_monochrome',
      asset: _markWhite,
      canvas: 1024,
      logo: 560,
    ),
  );
  // Legacy icon (before Android 8): shown unmasked, so the ground is part
  // of the image.
  testWidgets(
    'legacy',
    (tester) => renderLogo(
      tester,
      'launcher_icon',
      asset: _mark,
      canvas: 1024,
      logo: 780,
      background: Colors.white,
    ),
  );
  // Google Play listing: 512 × 512, full square (Play rounds the corners).
  testWidgets(
    'play store',
    (tester) => renderLogo(
      tester,
      'play_store_icon',
      asset: _mark,
      canvas: 512,
      logo: 370,
      background: Colors.white,
    ),
  );
}
