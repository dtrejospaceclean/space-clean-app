import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/refresh/live_data.dart';
import '../../../../core/search/text_search.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../jobs/presentation/controllers/jobs_providers.dart';
import '../../domain/entities/ticket.dart';
import '../controllers/whatsapp_providers.dart';
import '../widgets/ticket_labels.dart';

/// The WhatsApp bot's tickets (Me → Administration, owners only): a toggle
/// between the queue (waiting and assigned, oldest first, as the bot orders
/// them), the user's own and the latest closed, with a search on the loaded
/// list. The bot pushes nothing, so the page polls while in view.
class TicketsScreen extends ConsumerStatefulWidget {
  const TicketsScreen({super.key});

  static const path = '/me/whatsapp';

  @override
  ConsumerState<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends ConsumerState<TicketsScreen> {
  TicketView _view = TicketView.open;

  final _search = TextEditingController();

  /// The bot can't search, but each list is already here.
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tickets = ref.watch(ticketsProvider(_view));
    // The queue is always loaded, for its count.
    final queued = ref.watch(ticketsProvider(TicketView.open)).value?.length;
    final meId = ref.watch(botAgentProvider).value?.id;
    final now = ref.watch(clockProvider)();
    Future<void> refresh() => ref.refresh(ticketsProvider(_view).future);

    return RefreshWhileShown(
      onRefresh: () => ref.invalidate(ticketsProvider),
      child: SpacePage(
        title: l10n.whatsappTitle,
        onRefresh: refresh,
        slivers: [
          PageBox(
            top: 4,
            child: SearchField(
              controller: _search,
              hint: l10n.searchTicketsHint,
              onChanged: (text) => setState(() => _query = text),
            ),
          ),
          PageBox(
            child: PillToggle<TicketView>(
              semanticLabel: l10n.ticketsFilterLabel,
              options: {
                TicketView.open: l10n.ticketsFilterOpen(queued ?? 0),
                TicketView.mine: l10n.ticketsFilterMine,
                TicketView.closed: l10n.ticketsFilterClosed,
              },
              selected: _view,
              onChanged: (v) => setState(() => _view = v),
            ),
          ),
          AsyncSlivers(
            value: tickets,
            onRetry: refresh,
            builder: (list) {
              final shown = list
                  .where((t) => matchesTicket(l10n, t, _query))
                  .toList();
              if (shown.isEmpty && _query.trim().isNotEmpty) {
                return MessageSliver(
                  icon: Icons.search_off_rounded,
                  title: l10n.noMatchesFound,
                  hint: l10n.noMatchesHint,
                );
              }
              if (shown.isEmpty) {
                return switch (_view) {
                  TicketView.open => MessageSliver(
                    icon: Icons.forum_outlined,
                    title: l10n.noOpenTickets,
                    hint: l10n.noOpenTicketsHint,
                  ),
                  TicketView.mine => MessageSliver(
                    icon: Icons.support_agent_rounded,
                    title: l10n.noMyTickets,
                    hint: l10n.noMyTicketsHint,
                  ),
                  TicketView.closed => MessageSliver(
                    icon: Icons.check_circle_outline_rounded,
                    title: l10n.noClosedTickets,
                  ),
                };
              }
              return PageBox(
                child: ListCard(
                  children: [
                    for (final t in shown)
                      TicketRow(
                        ticket: t,
                        now: now,
                        meId: meId,
                        onTap: () =>
                            context.push('${TicketsScreen.path}/${t.id}'),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Whether [query] appears in [t]'s customer name or number, last message,
/// who has it or its status.
bool matchesTicket(AppLocalizations l10n, Ticket t, String query) =>
    matchesSearch(query, [
      t.contact.name,
      t.contact.waId,
      t.lastMessage?.body,
      t.assignedAgent?.name,
      l10n.ticketStatus(t.status),
    ]);
