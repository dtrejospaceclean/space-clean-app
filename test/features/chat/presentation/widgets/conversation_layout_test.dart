import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/chat/presentation/widgets/conversation_layout.dart';

const _messages = Key('messages');
const _composer = Key('composer');

Future<void> _pump(WidgetTester tester, {required double height}) =>
    tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: 390,
            height: height,
            child: const ConversationLayout(
              messages: SizedBox.expand(key: _messages),
              // The input and an open photo picker.
              composer: SizedBox(key: _composer, height: 336),
            ),
          ),
        ),
      ),
    );

void main() {
  testWidgets('the messages take what the composer leaves', (tester) async {
    await _pump(tester, height: 600);

    expect(tester.getSize(find.byKey(_composer)).height, 336);
    expect(tester.getSize(find.byKey(_messages)).height, 264);
  });

  testWidgets('a composer taller than the page scrolls instead of '
      'overflowing', (tester) async {
    // The keyboard still open while the picker opens.
    await _pump(tester, height: 200);

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byKey(_messages)).height, 0);
  });
}
