import '../entities/ticket.dart';

/// The WhatsApp bot's tickets. Only global owners get in (`whatsapp.forbidden`
/// for anyone else). Every method throws a `Failure` on error.
abstract interface class WhatsAppRepository {
  /// The signed-in user as the bot knows them.
  Future<BotAgent> getMe();

  /// One of the bot's lists. Neither searched nor paginated.
  Future<List<Ticket>> getTickets(TicketView view);

  Future<TicketDetail> getTicket(String ticketId);

  /// Gives it to the signed-in user, even from someone else.
  Future<Ticket> takeTicket(String ticketId);

  /// Hands the customer back to the bot. For good: there's no reopening.
  Future<Ticket> closeTicket(String ticketId);

  /// Sends [body] to the customer on WhatsApp. A waiting ticket becomes the
  /// user's; one someone else has is refused
  /// (`whatsapp.ticket_assigned_to_another_agent`), as is one past the reply
  /// window (`whatsapp.reply_window_closed`).
  Future<BotMessage> reply(String ticketId, String body);
}
