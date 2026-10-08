import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/core/design/design.dart';

/// Pumps [WebFrame] in a window [width] wide and reports the width the
/// app inside it sees.
Future<double> innerWidth(
  WidgetTester tester, {
  required double width,
  bool enabled = true,
}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  late double seen;
  await tester.pumpWidget(
    MaterialApp(
      theme: SpaceTheme.light(),
      builder: (context, child) => WebFrame(enabled: enabled, child: child!),
      home: Builder(
        builder: (context) {
          seen = MediaQuery.sizeOf(context).width;
          return const SizedBox.expand(key: Key('app'));
        },
      ),
    ),
  );
  expect(tester.getSize(find.byKey(const Key('app'))).width, seen);
  return seen;
}

void main() {
  testWidgets('a wide browser window keeps the app in a centered column', (
    tester,
  ) async {
    expect(await innerWidth(tester, width: 1600), WebFrame.maxWidth);
    final left = tester.getTopLeft(find.byKey(const Key('app'))).dx;
    expect(left, (1600 - WebFrame.maxWidth) / 2);
  });

  testWidgets('a window up to tablet width is left as it is', (tester) async {
    expect(await innerWidth(tester, width: 800), 800);
  });

  testWidgets('outside the browser nothing changes', (tester) async {
    expect(await innerWidth(tester, width: 1600, enabled: false), 1600);
  });
}
