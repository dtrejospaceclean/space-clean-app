import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

/// Draws [asset] as a [logo]-sized square centered on a [canvas]-sized
/// square (transparent unless [background] is given) and writes it to
/// `assets/brand/<name>.png`.
Future<void> renderLogo(
  WidgetTester tester,
  String name, {
  required String asset,
  required double canvas,
  required double logo,
  Color? background,
}) async {
  tester.view.physicalSize = Size.square(canvas);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    Center(
      child: RepaintBoundary(
        child: Container(
          width: canvas,
          height: canvas,
          color: background,
          alignment: Alignment.center,
          child: SizedBox.square(
            dimension: logo,
            child: SvgPicture.asset(asset),
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
