import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../core/widgets/adaptive.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../access/domain/entities/account_access.dart';
import '../../../access/presentation/controllers/account_access_provider.dart';
import '../../../jobs/di/jobs_providers.dart';
import '../../../jobs/domain/usecases/job_usecases.dart';
import '../../../jobs/presentation/controllers/jobs_providers.dart';
import '../../../jobs/presentation/screens/account_jobs_screen.dart';
import '../../../proposals/presentation/widgets/line_item_row.dart';
import '../../../scopes/domain/entities/scope.dart';
import '../../../scopes/presentation/screens/scopes_screen.dart';
import '../../di/calendar_providers.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/usecases/calendar_usecases.dart';
import '../controllers/calendar_providers.dart';
import '../widgets/calendar_widgets.dart';

/// One calendar event: when and where, its scope and who it's assigned
/// to, and where it was moved from. With `calendar.edit`, until it's
/// cancelled or turned into a job, it can be edited, rescheduled and
/// cancelled; until it's a job, it can be deleted. With `jobs.edit` it can
/// be turned into a job, which then opens from here.
class EventScreen extends ConsumerStatefulWidget {
  const EventScreen({super.key, required this.clientId, required this.eventId});

  final String clientId;
  final String eventId;

  @override
  ConsumerState<EventScreen> createState() => _EventScreenState();
}

/// What's in flight: nothing else on the page starts until it settles.
enum _Busy { delete, cancel, convert }

class _EventScreenState extends ConsumerState<EventScreen> {
  _Busy? _busy;

  EventRef get _ref =>
      EventRef(clientId: widget.clientId, eventId: widget.eventId);

  Future<bool> _confirm(String title, String body, String action) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(title),
        content: Text(body),
        actions: [
          adaptiveAction(
            context,
            label: l10n.keepEvent,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          adaptiveAction(
            context,
            label: action,
            destructive: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    return confirmed == true && mounted;
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

  /// Asks first, then deletes [event] and goes back to [calendar].
  Future<void> _delete(CalendarEvent event, String calendar) async {
    final l10n = AppLocalizations.of(context);
    if (!await _confirm(
      l10n.deleteEventConfirmTitle,
      // One from a scope won't come back when its month is filled again.
      event.isGenerated
          ? l10n.deleteGeneratedEventConfirmBody
          : l10n.deleteEventConfirmBody,
      l10n.deleteButton,
    )) {
      return;
    }
    setState(() => _busy = _Busy.delete);
    try {
      await ref.read(deleteEventProvider)(_ref);
      if (!mounted) return;
      // Leave before the lists reload, so this page doesn't flash "not
      // found" on its way out.
      context.go(calendar);
      invalidateCalendar(ref);
    } on Failure catch (f) {
      if (!mounted) return;
      setState(() => _busy = null);
      await _showFailure(f);
    }
  }

  Future<void> _cancel() async {
    final l10n = AppLocalizations.of(context);
    if (!await _confirm(
      l10n.cancelEventConfirmTitle,
      l10n.cancelEventConfirmBody,
      l10n.cancelEvent,
    )) {
      return;
    }
    setState(() => _busy = _Busy.cancel);
    try {
      await ref.read(cancelEventProvider)(_ref);
      invalidateCalendar(ref);
    } on Failure catch (f) {
      if (mounted) await _showFailure(f);
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  /// Makes a job of [event] on its day and time, with its assignee as the
  /// crew, and opens it.
  Future<void> _convert(CalendarEvent event, String account) async {
    setState(() => _busy = _Busy.convert);
    try {
      final job = await ref.read(convertEventToJobProvider)(
        ConvertEventParams(
          clientId: widget.clientId,
          eventId: event.id,
          assignedToId: event.assignedToId,
        ),
      );
      invalidateCalendar(ref);
      invalidateJobs(ref);
      if (!mounted) return;
      setState(() => _busy = null);
      context.push('$account/${AccountJobsScreen.route}/${job.id}');
    } on Failure catch (f) {
      if (!mounted) return;
      setState(() => _busy = null);
      await _showFailure(f);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final key = (widget.clientId, widget.eventId);
    final event = ref.watch(eventProvider(key));
    final history = ref.watch(eventReschedulesProvider(key)).value ?? [];
    final access = ref.watch(accountAccessProvider(widget.clientId)).value;
    final canEdit = access?.can(Permissions.calendarEdit) ?? false;
    final canViewScopes = access?.can(Permissions.scopeView) ?? false;
    final canMakeJobs = access?.can(Permissions.jobsEdit) ?? false;
    final canViewJobs = access?.can(Permissions.jobsView) ?? false;
    final e = event.value;
    final editable = canEdit && (e?.isEditable ?? false);
    final here = GoRouterState.of(context).matchedLocation;
    final calendar = here.substring(0, here.lastIndexOf('/'));
    final account = calendar.substring(0, calendar.lastIndexOf('/'));
    final busy = _busy != null;
    String at(DateTime day, ClockTime time) =>
        '${context.formatDate(day)}, ${context.formatClock(time.hour, time.minute)}';
    void reschedule() => context.push('$here/reschedule');
    Future<void> refresh() {
      ref.invalidate(eventReschedulesProvider(key));
      return ref.refresh(eventProvider(key).future);
    }

    return PopScope(
      canPop: !busy,
      child: AbsorbPointer(
        absorbing: busy,
        child: SpacePage(
          title: l10n.eventTitle,
          onRefresh: busy ? null : refresh,
          actions: [
            if (canEdit && (e?.canDelete ?? false))
              CircleButton.light(
                icon: Icons.delete_outline_rounded,
                tooltip: l10n.deleteEvent,
                busy: _busy == _Busy.delete,
                onPressed: () => _delete(e!, calendar),
              ),
            if (editable)
              CircleButton.dark(
                icon: Icons.edit_outlined,
                tooltip: l10n.editEvent,
                onPressed: busy ? null : () => context.push('$here/edit'),
              ),
          ],
          slivers: [
            AsyncSlivers(
              value: event,
              onRetry: refresh,
              builder: (e) {
                ListRow fact(
                  IconData icon,
                  String label,
                  String? value, {
                  VoidCallback? onTap,
                }) => ListRow(
                  leading: IconBadge(icon: icon),
                  title: value ?? l10n.notSet,
                  subtitle: label,
                  muted: value == null,
                  onTap: onTap,
                );

                return SliverMainAxisGroup(
                  slivers: [
                    PageBox(top: 4, child: _HeadCard(event: e)),
                    if (e.isConverted)
                      PageBox(
                        child: Notice(
                          message: l10n.eventConvertedNotice,
                          tone: NoticeTone.info,
                        ),
                      )
                    else if (e.isCancelled)
                      PageBox(
                        child: Notice(
                          message: l10n.eventCancelledNotice,
                          tone: NoticeTone.info,
                        ),
                      ),
                    PageBox(
                      child: ListCard(
                        children: [
                          if (e.jobId case final jobId? when canViewJobs)
                            ListRow(
                              leading: const IconBadge(
                                icon: Icons.cleaning_services_outlined,
                              ),
                              title: l10n.openJob,
                              onTap: () => context.push(
                                '$account/${AccountJobsScreen.route}/$jobId',
                              ),
                            ),
                          fact(
                            Icons.location_on_outlined,
                            l10n.locationLabel,
                            e.locationName,
                          ),
                          if (e.scopeId case final scopeId?)
                            fact(
                              Icons.checklist_rtl_rounded,
                              l10n.scopeTitle,
                              e.scopeArea ?? l10n.scopeWholeSite,
                              onTap: canViewScopes
                                  ? () => context.push(
                                      '$account/${ScopesScreen.route}/'
                                      '$scopeId',
                                    )
                                  : null,
                            ),
                          fact(
                            Icons.person_outline_rounded,
                            l10n.assignedToLabel,
                            e.assignedToName,
                          ),
                          if (e.notes case final notes?
                              when notes.trim().isNotEmpty)
                            fact(
                              Icons.sticky_note_2_outlined,
                              l10n.notesLabel,
                              notes,
                            ),
                        ],
                      ),
                    ),
                    // A cancelled event can't become a job, and one already
                    // did.
                    if (canMakeJobs && e.isEditable)
                      PageBox(
                        top: 24,
                        child: PrimaryButton(
                          label: l10n.createJobFromEvent,
                          icon: Icons.cleaning_services_outlined,
                          busy: _busy == _Busy.convert,
                          onPressed: busy ? null : () => _convert(e, account),
                        ),
                      ),
                    if (editable) ...[
                      PageBox(
                        top: canMakeJobs ? SpaceSpace.gap : 24,
                        // Second to "Create job" when that shows.
                        child: canMakeJobs
                            ? SecondaryButton(
                                label: l10n.rescheduleEvent,
                                icon: Icons.update_rounded,
                                onPressed: busy ? null : reschedule,
                              )
                            : PrimaryButton(
                                label: l10n.rescheduleEvent,
                                icon: Icons.update_rounded,
                                onPressed: busy ? null : reschedule,
                              ),
                      ),
                      PageBox(
                        child: SecondaryButton(
                          label: l10n.cancelEvent,
                          icon: Icons.block_rounded,
                          destructive: true,
                          onPressed: busy ? null : _cancel,
                        ),
                      ),
                    ],
                    // Where it was before each move.
                    if (history.isNotEmpty) ...[
                      PageBox(
                        top: 24,
                        child: SectionHeader(title: l10n.sectionMoves),
                      ),
                      PageBox(
                        top: 0,
                        child: ListCard(
                          children: [
                            for (final m in history)
                              ListRow(
                                leading: const IconBadge(
                                  icon: Icons.history_rounded,
                                ),
                                title: l10n.movedFrom(
                                  at(m.previousDate, m.previousStart),
                                ),
                                subtitle: [
                                  l10n.movedTo(at(m.newDate, m.newStart)),
                                  if (m.reason case final reason?
                                      when reason.trim().isNotEmpty)
                                    reason.trim(),
                                  if (m.byName case final name?)
                                    l10n.movedBy(name),
                                ].join(' · '),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// The head of the page: the title beside the status, then the day and
/// the time. At large text the pill moves above the title.
class _HeadCard extends StatelessWidget {
  const _HeadCard({required this.event});

  final CalendarEvent event;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final e = event;
    final title = Text(
      e.title,
      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
    );
    final pill = EventStatusLabel(status: e.status, forScheduled: true);
    Widget line(IconData icon, String value) => Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 16, color: context.colors.inkMuted),
          ),
          const SizedBox(width: 6),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );

    return SpaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isLargeText(context)) ...[
            Align(alignment: Alignment.centerLeft, child: pill),
            const SizedBox(height: 10),
            title,
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: title),
                const SizedBox(width: 12),
                pill,
              ],
            ),
          line(Icons.event_outlined, context.formatDayLong(e.date)),
          line(Icons.schedule_rounded, eventTimes(context, e)),
          line(
            e.isGenerated ? Icons.repeat_rounded : Icons.looks_one_outlined,
            e.isGenerated ? l10n.eventFromScope : l10n.eventOneOff,
          ),
        ],
      ),
    );
  }
}
