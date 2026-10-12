import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../core/widgets/adaptive.dart';
import '../../../../core/widgets/priority_label.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../access/domain/entities/account_access.dart';
import '../../../access/presentation/controllers/account_access_provider.dart';
import '../../../jobs/presentation/screens/account_jobs_screen.dart';
import '../../../locations/presentation/screens/locations_screen.dart';
import '../../../proposals/presentation/widgets/line_item_row.dart';
import '../../../team/presentation/controllers/team_providers.dart';
import '../../di/complaints_providers.dart';
import '../../domain/entities/complaint.dart';
import '../../domain/usecases/complaint_usecases.dart';
import '../controllers/complaints_providers.dart';
import '../widgets/complaint_labels.dart';

/// One complaint: a head card (title, status, priority, who reported it
/// and what they said, Edit), then where it happened and who has it, and
/// how it was resolved. While it's being worked on, `complaints.edit` edits
/// and resolves it and `complaints.assign` (re)assigns it; once resolved it's
/// read-only until reopened.
class ComplaintScreen extends ConsumerStatefulWidget {
  const ComplaintScreen({
    super.key,
    required this.clientId,
    required this.complaintId,
  });

  final String clientId;
  final String complaintId;

  @override
  ConsumerState<ComplaintScreen> createState() => _ComplaintScreenState();
}

/// What's in flight: nothing else on the page starts until it settles.
enum _Busy { assign, reopen }

class _ComplaintScreenState extends ConsumerState<ComplaintScreen> {
  _Busy? _busy;

  ComplaintRef get _ref =>
      ComplaintRef(clientId: widget.clientId, complaintId: widget.complaintId);

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

  /// Runs [action] as [kind], then reloads; failures show in a dialog.
  Future<void> _run(_Busy kind, Future<void> Function() action) async {
    setState(() => _busy = kind);
    try {
      await action();
      invalidateComplaints(ref, widget.clientId);
    } on Failure catch (f) {
      if (mounted) await _showFailure(f);
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  /// Picks an active member who works on the account (not the client's own
  /// people) and gives them the complaint.
  Future<void> _assign(Complaint c) async {
    final l10n = AppLocalizations.of(context);
    final List<({String id, String name})> people;
    try {
      people = [
        for (final m in await ref.read(membersProvider(widget.clientId).future))
          if (m.isActive && m.baseRole != 'client')
            (id: m.userId, name: m.name),
      ];
    } on Failure catch (f) {
      if (mounted) await _showFailure(f);
      return;
    }
    if (!mounted) return;
    final picked = await showAppChoice(
      context,
      title: l10n.assignedToLabel,
      allowClear: false,
      options: {for (final p in people) p.id: p.name},
    );
    if (picked == null || picked == c.assignedToId || !mounted) return;
    await _run(
      _Busy.assign,
      () => ref.read(assignComplaintProvider)(
        AssignComplaintParams(complaint: _ref, userId: picked),
      ),
    );
  }

  Future<void> _reopen() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(l10n.reopenComplaintConfirmTitle),
        content: Text(l10n.reopenComplaintConfirmBody),
        actions: [
          adaptiveAction(
            context,
            label: l10n.keepResolved,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          adaptiveAction(
            context,
            label: l10n.reopenComplaint,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _run(_Busy.reopen, () => ref.read(reopenComplaintProvider)(_ref));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final key = (widget.clientId, widget.complaintId);
    final complaint = ref.watch(complaintProvider(key));
    final access = ref.watch(accountAccessProvider(widget.clientId)).value;
    final canEdit = access?.can(Permissions.complaintsEdit) ?? false;
    final canAssign = access?.can(Permissions.complaintsAssign) ?? false;
    final canViewInfo = access?.can(Permissions.infoView) ?? false;
    final canViewJobs = access?.can(Permissions.jobsView) ?? false;
    // The assignee picker lists the team, which needs `team.view`.
    if (canAssign) ref.watch(membersProvider(widget.clientId));
    final here = GoRouterState.of(context).matchedLocation;
    final list = here.substring(0, here.lastIndexOf('/'));
    final account = list.substring(0, list.lastIndexOf('/'));
    final busy = _busy != null;
    Future<void> refresh() => ref.refresh(complaintProvider(key).future);

    return PopScope(
      canPop: !busy,
      child: AbsorbPointer(
        absorbing: busy,
        child: SpacePage(
          title: l10n.complaintTitle,
          onRefresh: busy ? null : refresh,
          slivers: [
            AsyncSlivers(
              value: complaint,
              onRetry: refresh,
              builder: (c) {
                String? text(String? v) =>
                    v == null || v.trim().isEmpty ? null : v.trim();
                final job = switch ((c.jobTitle, c.jobStart)) {
                  (final title?, final start?) =>
                    '$title · ${context.formatDate(start)}',
                  (final title?, null) => title,
                  _ => null,
                };

                return SliverMainAxisGroup(
                  slivers: [
                    PageBox(
                      top: 4,
                      child: _HeadCard(
                        complaint: c,
                        onEdit: canEdit && c.isEditable
                            ? () => context.push('$here/edit')
                            : null,
                      ),
                    ),
                    if (c.isResolved && (canEdit || canAssign))
                      PageBox(
                        child: Notice(
                          message: l10n.resolvedComplaintNotice,
                          tone: NoticeTone.info,
                        ),
                      ),
                    PageBox(top: 16, child: CapsHeader(l10n.sectionDetails)),
                    PageBox(
                      top: 0,
                      child: ListCard(
                        children: [
                          FactRow(
                            label: l10n.locationLabel,
                            value: c.locationName,
                            onTap: canViewInfo && c.locationId != null
                                ? () => context.push(
                                    '$account/${LocationsScreen.route}/'
                                    '${c.locationId}',
                                  )
                                : null,
                          ),
                          FactRow(
                            label: l10n.areaNameLabel,
                            value: text(c.area),
                          ),
                          FactRow(
                            label: l10n.complaintJobLabel,
                            value: job,
                            onTap: canViewJobs && c.jobId != null
                                ? () => context.push(
                                    '$account/${AccountJobsScreen.route}/'
                                    '${c.jobId}',
                                  )
                                : null,
                          ),
                          FactRow(
                            label: l10n.assignedToLabel,
                            value: _busy == _Busy.assign
                                ? '…'
                                : c.assignedToName,
                            onTap: canAssign && c.isEditable && !busy
                                ? () => _assign(c)
                                : null,
                          ),
                        ],
                      ),
                    ),
                    if (c.isResolved) ...[
                      PageBox(
                        top: 16,
                        child: CapsHeader(l10n.complaintResolutionSection),
                      ),
                      PageBox(
                        top: 0,
                        child: FactCard(
                          rows: [
                            [
                              (l10n.resolvedByLabel, c.resolvedByName),
                              (
                                l10n.resolutionTimeLabel,
                                switch (c.resolutionHours) {
                                  final h? => l10n.resolutionHoursValue(
                                    context.formatNumber('$h'),
                                  ),
                                  null => null,
                                },
                              ),
                            ],
                            [
                              (
                                l10n.resolutionNotesLabel,
                                text(c.resolutionNotes),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    if (canEdit && c.isEditable)
                      PageBox(
                        top: 24,
                        child: PrimaryButton(
                          label: l10n.resolveComplaint,
                          icon: Icons.task_alt_rounded,
                          onPressed: busy
                              ? null
                              : () => context.push('$here/resolve'),
                        ),
                      ),
                    if (canEdit && c.isResolved)
                      PageBox(
                        top: 20,
                        child: Center(
                          child: LinkButton(
                            label: l10n.reopenComplaint,
                            icon: Icons.replay_rounded,
                            onPressed: busy ? null : _reopen,
                          ),
                        ),
                      ),
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

/// The head of the page: the title with Edit at the corner, the status and
/// priority, who reported it and when, then what they said. At large text
/// Edit moves under the pills.
class _HeadCard extends StatelessWidget {
  const _HeadCard({required this.complaint, required this.onEdit});

  final Complaint complaint;

  /// Null hides Edit.
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final c = complaint;
    final large = isLargeText(context);
    final edit = switch (onEdit) {
      final onEdit? => PillButton(
        label: l10n.editButton,
        icon: Icons.edit_outlined,
        tooltip: l10n.editComplaint,
        onPressed: onEdit,
      ),
      null => null,
    };
    final reported = context.formatDate(c.reportedDate);

    return SpaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  c.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (edit != null && !large) ...[const SizedBox(width: 12), edit],
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ComplaintStatusLabel(status: c.status),
              if (!c.isResolved) PriorityLabel(priority: c.priority),
            ],
          ),
          if (edit != null && large) ...[
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerLeft, child: edit),
          ],
          const SizedBox(height: 10),
          Text(
            switch (c.reportedByName) {
              final name? => l10n.complaintReportedBy(reported, name),
              null => l10n.complaintReported(reported),
            },
            style: theme.textTheme.bodyMedium?.copyWith(
              color: context.colors.inkMuted,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(),
          ),
          Text(c.description, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
