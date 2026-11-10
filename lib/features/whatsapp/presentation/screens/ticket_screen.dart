import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/refresh/live_data.dart';
import '../../../../core/widgets/adaptive.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../jobs/presentation/controllers/jobs_providers.dart';
import '../../di/whatsapp_providers.dart';
import '../../domain/entities/ticket.dart';
import '../../domain/usecases/whatsapp_usecases.dart';
import '../controllers/whatsapp_providers.dart';
import '../widgets/ticket_labels.dart';

/// One WhatsApp ticket: the customer's number and where the ticket stands,
/// their recent messages (across tickets, newest at the bottom), and at the
/// foot whatever the user can do: reply, take it from someone else, or
/// read why they can't (closed, or past WhatsApp's 24-hour window). The
/// header's ✓ closes it, handing the customer back to the bot.
class TicketScreen extends ConsumerStatefulWidget {
  const TicketScreen({super.key, required this.ticketId});

  final String ticketId;

  @override
  ConsumerState<TicketScreen> createState() => _TicketScreenState();
}

enum _Busy { reply, take, close }

class _TicketScreenState extends ConsumerState<TicketScreen> {
  _Busy? _busy;
  final _reply = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Send turns on and off with the text.
    _reply.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  Future<void> _showFailure(Failure f) {
    final l10n = AppLocalizations.of(context);
    return showAdaptiveDialog<void>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        content: Text(l10n.failureMessage(f)),
        actions: [
          adaptiveAction(
            context,
            label: l10n.doneButton,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  /// Runs [action] as [kind]; true when it went through. Either way the
  /// ticket reloads: a refusal (taken, closed meanwhile) means it changed.
  Future<bool> _run(_Busy kind, Future<void> Function() action) async {
    setState(() => _busy = kind);
    try {
      await action();
      return true;
    } on Failure catch (f) {
      if (mounted) await _showFailure(f);
      return false;
    } finally {
      if (mounted) {
        invalidateTickets(ref);
        setState(() => _busy = null);
      }
    }
  }

  Future<void> _send() async {
    final body = _reply.text;
    if (body.trim().isEmpty) return;
    final sent = await _run(
      _Busy.reply,
      () => ref.read(replyToTicketProvider)(
        ReplyParams(ticketId: widget.ticketId, body: body),
      ),
    );
    if (sent && mounted) _reply.clear();
  }

  Future<void> _close() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(l10n.closeTicketConfirmTitle),
        content: Text(l10n.closeTicketConfirmBody),
        actions: [
          adaptiveAction(
            context,
            label: l10n.keepTicketOpen,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          adaptiveAction(
            context,
            label: l10n.closeTicketAction,
            destructive: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _run(
      _Busy.close,
      () => ref.read(closeTicketProvider)(widget.ticketId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final detail = ref.watch(ticketProvider(widget.ticketId));
    final meId = ref.watch(botAgentProvider).value?.id;
    final now = ref.watch(clockProvider)();
    Future<void> refresh() =>
        ref.refresh(ticketProvider(widget.ticketId).future);

    final d = detail.value;
    if (d == null) {
      return SpacePage(
        title: l10n.whatsappTitle,
        onRefresh: refresh,
        slivers: [
          AsyncSlivers(
            value: detail,
            skeleton: SkeletonLayout.detail,
            onRetry: refresh,
            builder: (_) => const SliverToBoxAdapter(),
          ),
        ],
      );
    }

    final t = d.ticket;
    final busy = _busy != null;
    return RefreshWhileShown(
      onRefresh: () => ref.invalidate(ticketProvider(widget.ticketId)),
      child: SpacePage(
        title: t.contact.displayName,
        actions: [
          if (!t.isClosed)
            CircleButton.light(
              icon: Icons.task_alt_rounded,
              tooltip: l10n.closeTicket,
              busy: _busy == _Busy.close,
              onPressed: busy ? null : _close,
            ),
        ],
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: pageSide(context)),
              child: _Summary(ticket: t, meId: meId, now: now),
            ),
            Expanded(
              child: RefreshIndicator.adaptive(
                onRefresh: refresh,
                color: context.colors.primary,
                child: _Messages(messages: d.messages, meId: meId, now: now),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  pageSide(context),
                  8,
                  pageSide(context),
                  12,
                ),
                child: _footer(l10n, t, meId: meId, now: now),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// What the user can do at the foot: read why not, take it, or reply.
  Widget _footer(
    AppLocalizations l10n,
    Ticket t, {
    required String? meId,
    required DateTime now,
  }) {
    final busy = _busy != null;
    if (t.isClosed) {
      return Notice(message: l10n.ticketClosedNotice, tone: NoticeTone.info);
    }
    // Who the user is decides between Take and the reply box.
    if (meId == null) return const SizedBox.shrink();
    if (t.needsTakingBy(meId)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Notice(
            message: l10n.ticketTakenBy(t.assignedAgent?.name ?? ''),
            tone: NoticeTone.info,
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: l10n.takeTicket,
            icon: Icons.support_agent_rounded,
            busy: _busy == _Busy.take,
            onPressed: busy
                ? null
                : () => _run(
                    _Busy.take,
                    () => ref.read(takeTicketProvider)(t.id),
                  ),
          ),
        ],
      );
    }
    if (!t.replyWindowOpenAt(now)) {
      return Notice(message: l10n.replyWindowClosed, tone: NoticeTone.info);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (t.status == TicketStatus.waiting)
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 4),
            child: Text(
              l10n.ticketWaitingHint,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: context.colors.inkMuted),
            ),
          ),
        _Composer(
          controller: _reply,
          busy: _busy == _Busy.reply,
          onSend: busy || _reply.text.trim().isEmpty ? null : _send,
        ),
      ],
    );
  }
}

/// Under the header: the number, where the ticket stands, and until when
/// WhatsApp takes a reply.
class _Summary extends StatelessWidget {
  const _Summary({required this.ticket, required this.meId, required this.now});

  final Ticket ticket;
  final String? meId;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = ticket;
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: context.colors.inkMuted,
    );
    final windowCloses = t.replyWindowClosesAt;
    return SpaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TicketStatusLabel(ticket: t, meId: meId),
              Text(t.contact.phone, style: theme.textTheme.bodyLarge),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            [
              l10n.ticketOpenedAt(ticketWhen(context, t.openedAt, now)),
              if (!t.isClosed &&
                  windowCloses != null &&
                  t.replyWindowOpenAt(now))
                l10n.replyWindowUntil(messageStamp(context, windowCloses, now)),
            ].join(' · '),
            style: muted,
          ),
        ],
      ),
    );
  }
}

/// The conversation, newest at the bottom, starting there.
class _Messages extends StatelessWidget {
  const _Messages({
    required this.messages,
    required this.meId,
    required this.now,
  });

  final List<BotMessage> messages;
  final String? meId;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (messages.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              l10n.ticketNoMessages,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: context.colors.inkMuted),
            ),
          ),
        ],
      );
    }
    final newestFirst = messages.reversed.toList();
    return ListView.builder(
      reverse: true,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(pageSide(context), 12, pageSide(context), 4),
      itemCount: newestFirst.length,
      itemBuilder: (context, i) =>
          _Bubble(message: newestFirst[i], meId: meId, now: now),
    );
  }
}

/// One message: the customer's on the left in white, what was sent to them
/// on the right in navy wash, named (the bot, the user or another person),
/// then when and, for sent ones, what WhatsApp reported.
class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.meId, required this.now});

  final BotMessage message;
  final String? meId;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final c = context.colors;
    final m = message;
    final incoming = m.isFromCustomer;
    final author = switch (m.sender) {
      MessageSender.customer || MessageSender.unknown => null,
      MessageSender.bot => l10n.ticketSenderBot,
      MessageSender.agent => switch (m.agent) {
        final a? when a.id == meId => l10n.ticketSenderYou,
        final a? => a.name,
        null => null,
      },
    };
    final delivery = m.delivery;
    final meta = theme.textTheme.bodySmall?.copyWith(
      color: c.inkMuted,
      fontSize: 12.5,
    );
    final media = m.body?.trim().isEmpty ?? true;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: incoming
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          if (author != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 2, left: 4, right: 4),
              child: Text(author, style: meta),
            ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.78,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: incoming ? c.surface : c.accentSoft,
                borderRadius: BorderRadius.circular(SpaceRadius.inner),
              ),
              child: Text(
                l10n.messageText(m),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontStyle: media ? FontStyle.italic : null,
                  color: media ? c.inkMuted : null,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(messageStamp(context, m.createdAt, now), style: meta),
                if (delivery != null) ...[
                  const SizedBox(width: 4),
                  _DeliveryIcon(status: delivery),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryIcon extends StatelessWidget {
  const _DeliveryIcon({required this.status});

  final DeliveryStatus status;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (IconData icon, Color color) = switch (status) {
      DeliveryStatus.sent => (Icons.check_rounded, c.inkMuted),
      DeliveryStatus.delivered => (Icons.done_all_rounded, c.inkMuted),
      DeliveryStatus.read => (Icons.done_all_rounded, c.accent),
      DeliveryStatus.failed => (Icons.error_outline_rounded, c.danger),
    };
    final label = AppLocalizations.of(context).delivery(status);
    return Tooltip(
      message: label,
      child: Icon(icon, size: 15, color: color, semanticLabel: label),
    );
  }
}

/// The reply box: a white pill that grows with the text, and Send.
class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.busy,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool busy;

  /// Null while there's nothing to send.
  final VoidCallback? onSend;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(SpaceRadius.card),
              border: Border.all(color: c.line),
            ),
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 5,
              maxLength: maxReplyLength,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: l10n.ticketReplyHint,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        CircleButton.dark(
          icon: Icons.send_rounded,
          tooltip: l10n.sendReply,
          busy: busy,
          onPressed: onSend,
        ),
      ],
    );
  }
}
