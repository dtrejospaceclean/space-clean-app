import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/core/error/failures.dart';
import 'package:sp_cln_app/features/whatsapp/domain/entities/ticket.dart';

import '../../../helpers/test_app.dart';

Future<FakeWhatsAppRepository> openTickets(
  WidgetTester tester, {
  FakeWhatsAppRepository? whatsApp,
}) async {
  whatsApp ??= FakeWhatsAppRepository();
  await pumpApp(
    tester,
    auth: FakeAuthRepository(sessionUser: owner),
    whatsApp: whatsApp,
  );
  await tester.tap(find.byTooltip('Me'));
  await tester.pumpAndSettle();
  // The last Administration row; clear it of the floating dock.
  await tester.scrollUntilVisible(find.text('WhatsApp'), 200);
  await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
  await tester.pumpAndSettle();
  await tester.tap(find.text('WhatsApp'));
  await tester.pumpAndSettle();
  return whatsApp;
}

Future<void> openTicket(WidgetTester tester, String name) async {
  await tester.tap(find.text(name));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('only owners see WhatsApp under Administration', (tester) async {
    await pumpApp(
      tester,
      auth: FakeAuthRepository(sessionUser: accountManager),
    );
    await tester.tap(find.byTooltip('Me'));
    await tester.pumpAndSettle();

    expect(find.text('Service catalog'), findsOneWidget);
    expect(find.text('WhatsApp'), findsNothing);
  });

  testWidgets('lists the queue, the user\'s own and the closed tickets', (
    tester,
  ) async {
    await openTickets(tester);

    expect(find.text('Open (3)'), findsOneWidget);
    expect(find.text('Ana López'), findsOneWidget);
    expect(find.text('Waiting'), findsOneWidget);
    expect(find.text('With you'), findsOneWidget);
    expect(find.text('With Marta'), findsOneWidget);
    expect(find.text('Rosa Díaz'), findsNothing);

    await tester.tap(find.text('Mine'));
    await tester.pumpAndSettle();
    expect(find.text('Carlos Medina'), findsOneWidget);
    expect(find.text('Ana López'), findsNothing);

    await tester.tap(find.text('Closed'));
    await tester.pumpAndSettle();
    expect(find.text('Rosa Díaz'), findsOneWidget);
  });

  testWidgets('searches by name, number or message', (tester) async {
    await openTickets(tester);

    await tester.enterText(find.byType(TextField), '0199');
    await tester.pumpAndSettle();
    expect(find.text('Luis Vega'), findsOneWidget);
    expect(find.text('Ana López'), findsNothing);

    await tester.enterText(find.byType(TextField), 'cotizacion');
    await tester.pumpAndSettle();
    expect(find.text('Ana López'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'nobody');
    await tester.pumpAndSettle();
    expect(find.text('Nothing matches'), findsOneWidget);
  });

  testWidgets('replying to a waiting ticket sends it and makes it yours', (
    tester,
  ) async {
    final whatsApp = await openTickets(tester);
    await openTicket(tester, 'Ana López');

    expect(find.text('+50488887777'), findsOneWidget);
    expect(find.text('Necesito una cotización'), findsOneWidget);
    expect(find.text('Replying makes this ticket yours.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '  Con gusto  ');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Send'));
    await tester.pumpAndSettle();

    expect(whatsApp.replies, [('t1', 'Con gusto')]);
    expect(find.text('Con gusto'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
    expect(find.text('With you'), findsOneWidget);
    expect(find.text('Replying makes this ticket yours.'), findsNothing);
  });

  testWidgets("someone else's ticket is taken before replying", (tester) async {
    final whatsApp = await openTickets(tester);
    await openTicket(tester, 'Luis Vega');

    expect(
      find.text('Marta has this ticket. Take it to reply.'),
      findsOneWidget,
    );
    expect(find.byTooltip('Send'), findsNothing);

    await tester.tap(find.text('Take ticket'));
    await tester.pumpAndSettle();

    expect(whatsApp.taken, ['t3']);
    expect(find.byTooltip('Send'), findsOneWidget);
  });

  testWidgets('closing hands the customer back to the bot', (tester) async {
    final whatsApp = await openTickets(tester);
    await openTicket(tester, 'Carlos Medina');

    await tester.tap(find.byTooltip('Close and hand back to the bot'));
    await tester.pumpAndSettle();
    expect(find.text('Close this ticket?'), findsOneWidget);
    await tester.tap(find.text('Close').last);
    await tester.pumpAndSettle();

    expect(whatsApp.closed, ['t2']);
    expect(
      find.text('This ticket is closed. The customer is back with the bot.'),
      findsOneWidget,
    );
    expect(find.byTooltip('Close and hand back to the bot'), findsNothing);
    expect(find.byTooltip('Send'), findsNothing);
  });

  testWidgets('past the 24-hour window there is no reply box', (tester) async {
    final stale = Ticket(
      id: 't9',
      status: TicketStatus.assigned,
      contact: const BotContact(id: 'c9', waId: '17135550100', name: 'Eva'),
      assignedAgent: FakeWhatsAppRepository.me,
      openedAt: testNow.subtract(const Duration(days: 3)),
      replyWindowClosesAt: testNow.subtract(const Duration(days: 1)),
    );
    await openTickets(
      tester,
      whatsApp: FakeWhatsAppRepository(tickets: [stale]),
    );
    await openTicket(tester, 'Eva');

    expect(find.textContaining('within 24 hours'), findsOneWidget);
    expect(find.byTooltip('Send'), findsNothing);
  });

  testWidgets('a refusal shows why', (tester) async {
    await openTickets(
      tester,
      whatsApp: FakeWhatsAppRepository(
        failure: const ServerFailure('whatsapp.forbidden', statusCode: 403),
      ),
    );

    expect(
      find.text('Only owners can open the WhatsApp tickets.'),
      findsOneWidget,
    );
  });
}
