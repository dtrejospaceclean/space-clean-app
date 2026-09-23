// Renders the white knockout logo to PNGs for the native launch screens.
//
//   flutter test --update-goldens tool/brand
//
// Then: dart run flutter_native_splash:create
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _render(
  WidgetTester tester,
  String name, {
  required String asset,
  required double canvas,
  required double logo,
}) async {
  tester.view.physicalSize = Size.square(canvas);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    Center(
      child: RepaintBoundary(
        child: SizedBox.square(
          dimension: canvas,
          child: Center(
            child: SizedBox.square(
              dimension: logo,
              child: SvgPicture.asset(
                'assets/brand/space_clean_logo_white.svg',
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 300)),
  );
  await tester.pumpAndSettle();
  await expectLater(
    find.byType(RepaintBoundary).first,
    matchesGoldenFile('../../assets/brand/$name.png'),
  );
}

const _color = 'assets/brand/space_clean_logo.svg';
const _white = 'assets/brand/space_clean_logo_white.svg';

void main() {
  // Light launch (white ground): full-color logo. Dark launch (ember): white.
  // iOS and pre-12 Android: logo fills most of the image.
  testWidgets(
    'splash',
    (tester) =>
        _render(tester, 'splash_logo', asset: _color, canvas: 768, logo: 640),
  );
  testWidgets(
    'splash dark',
    (tester) => _render(
      tester,
      'splash_logo_dark',
      asset: _white,
      canvas: 768,
      logo: 640,
    ),
  );
  // Android 12+ masks the icon to a circle 2/3 of the image, so keep the
  // logo inside it.
  testWidgets(
    'splash android 12',
    (tester) => _render(
      tester,
      'splash_logo_android12',
      asset: _color,
      canvas: 1152,
      logo: 520,
    ),
  );
  testWidgets(
    'splash android 12 dark',
    (tester) => _render(
      tester,
      'splash_logo_android12_dark',
      asset: _white,
      canvas: 1152,
      logo: 520,
    ),
  );
}
