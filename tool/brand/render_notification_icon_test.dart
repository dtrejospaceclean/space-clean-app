// Renders the Android notification icons from the logo's planet mark.
//
//   flutter test --update-goldens tool/brand
//
// The status bar icon (`ic_notification`, 24dp) must be one color on
// transparent: Android paints it white in the status bar and the brand
// orange in the shade (`default_notification_color`). The mark's white
// gaps become holes, so the planet and its ring still read at that size.
// The colored mark (`ic_notification_large`) is the large icon of a push
// shown while the app is open.
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

const _mark = 'assets/brand/space_clean_mark.svg';
const _res = '../../android/app/src/main/res';

/// Solid white wherever the mark has color; its white parts (and the
/// near-white edges around them) turn transparent.
const _silhouette = ColorFilter.matrix([
  0, 0, 0, 0, 255, //
  0, 0, 0, 0, 255, //
  0, 0, 0, 0, 255, //
  -2.4, -2.4, -2.4, 6.6, 0, //
]);

Future<void> _render(
  WidgetTester tester,
  String file, {
  required double size,
  ColorFilter? filter,
}) async {
  tester.view.physicalSize = Size.square(size);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  Widget mark = SvgPicture.asset(_mark);
  if (filter != null) mark = ColorFiltered(colorFilter: filter, child: mark);
  await tester.pumpWidget(
    Center(
      child: RepaintBoundary(
        child: SizedBox.square(dimension: size, child: mark),
      ),
    ),
  );
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 300)),
  );
  await tester.pumpAndSettle();
  await expectLater(
    find.byType(RepaintBoundary).first,
    matchesGoldenFile(file),
  );
}

void main() {
  const densities = {
    'mdpi': 24.0,
    'hdpi': 36.0,
    'xhdpi': 48.0,
    'xxhdpi': 72.0,
    'xxxhdpi': 96.0,
  };
  for (final MapEntry(key: density, value: size) in densities.entries) {
    testWidgets(
      'status bar $density',
      (tester) => _render(
        tester,
        '$_res/drawable-$density/ic_notification.png',
        size: size,
        filter: _silhouette,
      ),
    );
  }
  testWidgets(
    'large icon',
    (tester) => _render(
      tester,
      '$_res/drawable-nodpi/ic_notification_large.png',
      size: 256,
    ),
  );
}
