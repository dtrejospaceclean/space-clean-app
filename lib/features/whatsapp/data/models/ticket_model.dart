import '../../domain/entities/ticket.dart';

/// Reads the bot's DTOs (`src/shared/contracts/inbox-api.ts` in the bot's
/// repo). Dates are ISO strings in UTC, shown in local time.
abstract final class TicketModel {
  static DateTime _at(Object? value) =>
      DateTime.parse(value! as String).toLocal();

  static DateTime? _maybeAt(Object? value) => switch (value) {
    final String s => DateTime.tryParse(s)?.toLocal(),
    _ => null,
  };

  static Map<String, dynamic> _map(Object? value) =>
      (value! as Map).cast<String, dynamic>();

  static BotAgent agent(Map<String, dynamic> json) =>
      BotAgent(id: json['id'] as String, name: json['name'] as String? ?? '');

  static BotAgent? _maybeAgent(Object? value) => switch (value) {
    final Map m => agent(m.cast<String, dynamic>()),
    _ => null,
  };

  static BotContact _contact(Map<String, dynamic> json) => BotContact(
    id: json['id'] as String,
    waId: json['waId'] as String? ?? '',
    name: json['name'] as String?,
  );

  static BotMessage message(Map<String, dynamic> json) => BotMessage(
    id: json['id'] as String,
    ticketId: json['ticketId'] as String?,
    sender: MessageSender.fromWire(json['sentBy'] as String?),
    agent: _maybeAgent(json['agent']),
    type: json['type'] as String? ?? 'text',
    body: json['body'] as String?,
    delivery: DeliveryStatus.fromWire(json['status'] as String?),
    createdAt: _at(json['createdAt']),
  );

  static Ticket fromJson(Map<String, dynamic> json) => Ticket(
    id: json['id'] as String,
    status: TicketStatus.fromWire(json['status'] as String?),
    contact: _contact(_map(json['contact'])),
    assignedAgent: _maybeAgent(json['assignedAgent']),
    openedAt: _at(json['openedAt']),
    closedAt: _maybeAt(json['closedAt']),
    lastMessage: switch (json['lastMessage']) {
      final Map m => message(m.cast<String, dynamic>()),
      _ => null,
    },
    replyWindowClosesAt: _maybeAt(json['replyWindowClosesAt']),
  );

  static TicketDetail detail(Map<String, dynamic> json) => TicketDetail(
    ticket: fromJson(json),
    messages: [
      for (final m in json['messages'] as List? ?? const [])
        message((m as Map).cast<String, dynamic>()),
    ],
  );
}
