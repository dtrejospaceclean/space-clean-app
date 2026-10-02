import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/core/design/design.dart';

void main() {
  Future<void> pumpBar(WidgetTester tester, {double textScale = 1}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: SpaceTheme.light(),
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: Scaffold(
            bottomNavigationBar: SpaceBottomBar(
              currentIndex: 0,
              onTap: (_) {},
              action: BottomBarAction(
                icon: Icons.add_rounded,
                label: 'Add line item',
                text: 'Line item',
                onPressed: () {},
              ),
              items: const [
                BottomBarItem(
                  icon: Icons.today_outlined,
                  activeIcon: Icons.today_rounded,
                  label: 'Today',
                ),
                BottomBarItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Me',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('an action with text shows it beside the "+"', (tester) async {
    await pumpBar(tester);
    expect(find.text('Line item'), findsOneWidget);
    expect(find.byTooltip('Add line item'), findsOneWidget);
  });

  testWidgets('large text keeps just the "+"', (tester) async {
    await pumpBar(tester, textScale: 1.5);
    expect(find.text('Line item'), findsNothing);
    expect(find.byTooltip('Add line item'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
