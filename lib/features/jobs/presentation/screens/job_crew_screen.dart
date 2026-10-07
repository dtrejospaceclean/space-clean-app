import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../team/domain/entities/member.dart';
import '../../../team/presentation/controllers/team_providers.dart';
import '../../di/jobs_providers.dart';
import '../../domain/entities/job.dart';
import '../../domain/usecases/job_usecases.dart';
import '../controllers/jobs_providers.dart';

/// Who goes on a job: a switch per active staff member of the account
/// (from Team, so it needs `team.view` to offer anyone new). Saving
/// replaces the crew; people who stay keep their role and check-in times.
/// Needs `jobs.assign`.
class JobCrewScreen extends ConsumerWidget {
  const JobCrewScreen({super.key, required this.clientId, required this.jobId});

  /// Path segment under a job.
  static const route = 'crew';

  final String clientId;
  final String jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // Wait for the job before building the switches.
    return switch (ref.watch(jobProvider((clientId, jobId)))) {
      AsyncValue(value: final job?) => _CrewForm(
        key: ValueKey(jobId),
        job: job,
      ),
      final other => SpacePage(
        title: l10n.editCrewTitle,
        slivers: [
          AsyncSlivers<Job>(
            value: other,
            onRetry: () => ref.invalidate(jobProvider((clientId, jobId))),
            builder: (_) => const SliverToBoxAdapter(),
          ),
        ],
      ),
    };
  }
}

class _CrewForm extends ConsumerStatefulWidget {
  const _CrewForm({super.key, required this.job});

  final Job job;

  @override
  ConsumerState<_CrewForm> createState() => _CrewFormState();
}

class _CrewFormState extends ConsumerState<_CrewForm> {
  late final Set<String> _picked = {
    for (final a in widget.job.assignees) a.userId,
  };
  bool _saving = false;
  Failure? _failure;

  Future<void> _save() async {
    final job = widget.job;
    final roles = {for (final a in job.assignees) a.userId: a.roleOnJob};
    setState(() {
      _saving = true;
      _failure = null;
    });
    try {
      await ref.read(setJobCrewProvider)(
        SetCrewParams(
          clientId: job.clientId,
          jobId: job.id,
          crew: [
            for (final id in _picked)
              CrewMember(userId: id, roleOnJob: roles[id]),
          ],
        ),
      );
      invalidateJobs(ref);
      if (mounted) context.pop();
    } on Failure catch (f) {
      HapticFeedback.mediumImpact();
      if (mounted) setState(() => _failure = f);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final side = pageSide(context);
    final job = widget.job;
    final members = ref.watch(membersProvider(job.clientId));

    // Active staff (client logins don't clean), plus whoever is on the job
    // already, so they can be taken off even if they left the team.
    final names = <String, String>{
      for (final Member m in members.value ?? const [])
        if (m.isActive && m.baseRole != 'client') m.userId: m.name,
      for (final a in job.assignees) a.userId: a.name,
    };
    final people = names.entries.toList()
      ..sort((a, b) => a.value.toLowerCase().compareTo(b.value.toLowerCase()));

    final failure = _failure;
    final notices = <(String, NoticeTone)>[
      if (failure != null) (l10n.failureMessage(failure), NoticeTone.error),
      // The team couldn't load (no access to it, offline).
      if (members.error case final Failure f when !members.hasValue)
        (l10n.failureMessage(f), NoticeTone.error)
      else if (members.hasValue && people.isEmpty)
        (l10n.eventNoMembers, NoticeTone.info),
    ];

    return SpacePage(
      title: l10n.editCrewTitle,
      bottom: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(side, 8, side, 12),
          child: PrimaryButton(
            label: l10n.saveButton,
            busy: _saving,
            onPressed: _save,
          ),
        ),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (message, tone) in notices)
                Padding(
                  padding: EdgeInsets.fromLTRB(side, 4, side, 4),
                  child: Notice(message: message, tone: tone),
                ),
              if (members.isLoading && !members.hasValue)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator.adaptive()),
                ),
              if (people.isNotEmpty)
                FormSection(l10n.jobCrew, [
                  for (final MapEntry(key: id, value: name) in people)
                    SwitchRow(
                      label: name,
                      value: _picked.contains(id),
                      onChanged: _saving
                          ? null
                          : (on) => setState(
                              () => on ? _picked.add(id) : _picked.remove(id),
                            ),
                    ),
                ], footer: l10n.editCrewHelp),
            ],
          ),
        ),
      ],
    );
  }
}
