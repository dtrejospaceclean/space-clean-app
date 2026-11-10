import 'package:flutter/material.dart';

import '../../../../core/design/design.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/ticket.dart';

extension TicketNames on AppLocalizations {
  String ticketStatus(TicketStatus status) => switch (status) {
    TicketStatus.waiting => ticketStatusWaiting,
    TicketStatus.assigned => ticketStatusAssigned,
    TicketStatus.closed => ticketStatusClosed,
    TicketStatus.unknown => ticketStatusUnknown,
  };

  /// The text, or what kind of attachment it was (the bot doesn't pass
  /// media on).
  String messageText(BotMessage m) => switch (m.body?.trim()) {
    final body? when body.isNotEmpty => body,
    _ => ticketAttachment(m.type),
  };

  String delivery(DeliveryStatus status) => switch (status) {
    DeliveryStatus.sent => deliverySent,
    DeliveryStatus.delivered => deliveryDelivered,
    DeliveryStatus.read => deliveryRead,
    DeliveryStatus.failed => deliveryFailed,
  };
}

/// "2:15 PM" today, "Yesterday", else the date.
String ticketWhen(BuildContext context, DateTime at, DateTime now) {
  final day = DateTime(at.year, at.month, at.day);
  final today = DateTime(now.year, now.month, now.day);
  return switch (today.difference(day).inDays) {
    0 => context.formatTime(at),
    1 => AppLocalizations.of(context).notificationYesterday,
    _ => context.formatDate(at),
  };
}

/// The time alone today, else the day ("Yesterday", the date) and the time.
String messageStamp(BuildContext context, DateTime at, DateTime now) {
  final time = context.formatTime(at);
  final sameDay =
      at.year == now.year && at.month == now.month && at.day == now.day;
  return sameDay ? time : '${ticketWhen(context, at, now)} $time';
}

/// Where a ticket stands as a pill: waiting in orange, an assigned one
/// naming who has it ("With you") in navy, closed muted.
class TicketStatusLabel extends StatelessWidget {
  const TicketStatusLabel({super.key, required this.ticket, this.meId});

  final Ticket ticket;

  /// The user's agent id, to say "With you"; null while unknown.
  final String? meId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final t = ticket;
    final agent = t.assignedAgent;
    final (
      String label,
      IconData icon,
      Color color,
      Color background,
    ) = switch (t.status) {
      TicketStatus.waiting => (
        l10n.ticketStatusWaiting,
        Icons.hourglass_top_rounded,
        c.highlightInk,
        c.highlightSoft,
      ),
      TicketStatus.assigned => (
        switch (agent) {
          _ when meId != null && t.isAssignedTo(meId!) => l10n.ticketWithYou,
          final a? when a.name.isNotEmpty => l10n.ticketWith(a.name),
          _ => l10n.ticketStatusAssigned,
        },
        Icons.support_agent_rounded,
        c.accent,
        c.accentSoft,
      ),
      TicketStatus.closed => (
        l10n.ticketStatusClosed,
        Icons.check_rounded,
        c.inkMuted,
        c.sunken,
      ),
      TicketStatus.unknown => (
        l10n.ticketStatusUnknown,
        Icons.help_outline_rounded,
        c.inkMuted,
        c.sunken,
      ),
    };
    return StatusPill(
      label: label,
      icon: icon,
      color: color,
      background: background,
    );
  }
}

/// A ticket as a list row: the customer, their last message and when, and
/// where it stands. Closed ones are muted.
class TicketRow extends StatelessWidget {
  const TicketRow({
    super.key,
    required this.ticket,
    required this.now,
    this.meId,
    this.onTap,
  });

  final Ticket ticket;
  final DateTime now;
  final String? meId;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = ticket;
    final last = t.lastMessage;
    return ListRow(
      leading: InitialsAvatar(name: t.contact.displayName),
      title: t.contact.displayName,
      subtitle: [
        if (last != null) l10n.messageText(last) else t.contact.phone,
        ticketWhen(context, last?.createdAt ?? t.openedAt, now),
      ].join(' · '),
      muted: t.isClosed,
      tag: TicketStatusLabel(ticket: t, meId: meId),
      onTap: onTap,
    );
  }
}
