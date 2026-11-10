import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/usecase/usecase.dart';
import '../../di/whatsapp_providers.dart';
import '../../domain/entities/ticket.dart';

/// The signed-in user as the bot knows them, to tell their tickets apart.
final botAgentProvider = FutureProvider.autoDispose<BotAgent>(
  (ref) => ref.watch(getBotAgentProvider)(const NoParams()),
);

/// One of the bot's ticket lists.
final ticketsProvider = FutureProvider.autoDispose
    .family<List<Ticket>, TicketView>(
      (ref, view) => ref.watch(getTicketsProvider)(view),
    );

/// One ticket with the customer's recent messages.
final ticketProvider = FutureProvider.autoDispose.family<TicketDetail, String>(
  (ref, ticketId) => ref.watch(getTicketProvider)(ticketId),
);

/// Drops every ticket list and ticket after a write (or to poll).
void invalidateTickets(WidgetRef ref) => ref
  ..invalidate(ticketsProvider)
  ..invalidate(ticketProvider);
