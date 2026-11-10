/// Where a WhatsApp ticket stands. A customer who asks the bot for a person
/// opens one [waiting]; someone takes it ([assigned]); closing it hands the
/// customer back to the bot. There's no reopening: asking again opens a new
/// ticket.
enum TicketStatus {
  waiting('WAITING'),
  assigned('ASSIGNED'),
  closed('CLOSED'),

  /// A status this app doesn't know yet.
  unknown('');

  const TicketStatus(this.wire);

  /// The bot's name for it.
  final String wire;

  static TicketStatus fromWire(String? value) => values.firstWhere(
    (s) => s != unknown && s.wire == value,
    orElse: () => unknown,
  );
}

/// The lists the bot offers: the queue (waiting and assigned, oldest
/// first), the user's own, and the latest 50 closed.
enum TicketView {
  open('open'),
  mine('mine'),
  closed('closed');

  const TicketView(this.wire);

  final String wire;
}

/// Who wrote a message.
enum MessageSender {
  customer('CUSTOMER'),
  bot('BOT'),
  agent('AGENT'),
  unknown('');

  const MessageSender(this.wire);

  final String wire;

  static MessageSender fromWire(String? value) => values.firstWhere(
    (s) => s != unknown && s.wire == value,
    orElse: () => unknown,
  );
}

/// What WhatsApp reported about a message sent to the customer.
enum DeliveryStatus {
  sent('sent'),
  delivered('delivered'),
  read('read'),
  failed('failed');

  const DeliveryStatus(this.wire);

  final String wire;

  /// Null for the customer's own messages and unknown values.
  static DeliveryStatus? fromWire(String? value) =>
      values.where((s) => s.wire == value).firstOrNull;
}

/// The customer: their WhatsApp number ([waId], digits with the country
/// code) and profile name, when WhatsApp shared one.
class BotContact {
  const BotContact({required this.id, required this.waId, this.name});

  final String id;
  final String waId;
  final String? name;

  /// The profile name, else the number.
  String get displayName => switch (name?.trim()) {
    final n? when n.isNotEmpty => n,
    _ => phone,
  };

  /// [waId] with a leading "+".
  String get phone => '+$waId';
}

/// A person answering tickets. The bot calls them agents; each is one of our
/// owners, matched by their sign-in.
class BotAgent {
  const BotAgent({required this.id, required this.name});

  final String id;
  final String name;
}

class BotMessage {
  const BotMessage({
    required this.id,
    required this.sender,
    required this.type,
    required this.createdAt,
    this.ticketId,
    this.agent,
    this.body,
    this.delivery,
  });

  final String id;

  /// The ticket it was written in; null for what the customer and the bot
  /// said outside one.
  final String? ticketId;
  final MessageSender sender;

  /// Who answered, when [sender] is an agent.
  final BotAgent? agent;

  /// WhatsApp's message type: `text`, `image`, `audio`…
  final String type;

  /// The text; null for media, which the bot doesn't pass on.
  final String? body;
  final DeliveryStatus? delivery;
  final DateTime createdAt;

  /// Written by the customer; everything else was sent to them.
  bool get isFromCustomer => sender == MessageSender.customer;
}

class Ticket {
  const Ticket({
    required this.id,
    required this.status,
    required this.contact,
    required this.openedAt,
    this.assignedAgent,
    this.closedAt,
    this.lastMessage,
    this.replyWindowClosesAt,
  });

  final String id;
  final TicketStatus status;
  final BotContact contact;
  final BotAgent? assignedAgent;
  final DateTime openedAt;
  final DateTime? closedAt;
  final BotMessage? lastMessage;

  /// WhatsApp only takes free-form replies until 24 hours after the
  /// customer's last message. Null if they never wrote.
  final DateTime? replyWindowClosesAt;

  bool get isClosed => status == TicketStatus.closed;

  bool isAssignedTo(String agentId) => assignedAgent?.id == agentId;

  /// Whether WhatsApp still takes a reply at [now].
  bool replyWindowOpenAt(DateTime now) => switch (replyWindowClosesAt) {
    final closes? => now.isBefore(closes),
    null => false,
  };

  /// Taking it is needed before replying when someone else has it. A
  /// waiting ticket is taken by the first reply.
  bool needsTakingBy(String agentId) =>
      status == TicketStatus.assigned && !isAssignedTo(agentId);

  /// Whether [agentId] can reply at [now]: open, theirs or nobody's, and
  /// within WhatsApp's window.
  bool canReply(String agentId, DateTime now) =>
      !isClosed && !needsTakingBy(agentId) && replyWindowOpenAt(now);
}

/// A ticket with the customer's last 100 messages, across all their
/// tickets, oldest first.
class TicketDetail {
  const TicketDetail({required this.ticket, required this.messages});

  final Ticket ticket;
  final List<BotMessage> messages;
}

/// The longest text WhatsApp takes in one message.
const maxReplyLength = 4096;
