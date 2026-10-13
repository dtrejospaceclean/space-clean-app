import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../l10n/app_localizations.dart';
import '../../di/jobs_providers.dart';
import '../../domain/entities/job.dart';
import '../../domain/usecases/job_usecases.dart';
import '../controllers/jobs_providers.dart';

/// Finishes a job in progress: an optional quality score (1–5), the crew's
/// notes, and the name of whoever signed off on site. Says first when
/// checklist items are still open. For the job's crew or `jobs.edit`.
class JobCompleteScreen extends ConsumerWidget {
  const JobCompleteScreen({
    super.key,
    required this.clientId,
    required this.jobId,
  });

  /// Path segment under a job.
  static const route = 'complete';

  final String clientId;
  final String jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // Wait for the job before building fields.
    return switch (ref.watch(jobProvider((clientId, jobId)))) {
      AsyncValue(value: final job?) => _CompleteForm(
        key: ValueKey(jobId),
        job: job,
      ),
      final other => SpacePage(
        title: l10n.completeJobTitle,
        slivers: [
          AsyncSlivers<Job>(
            value: other,
            skeleton: SkeletonLayout.form,
            onRetry: () => ref.invalidate(jobProvider((clientId, jobId))),
            builder: (_) => const SliverToBoxAdapter(),
          ),
        ],
      ),
    };
  }
}

class _CompleteForm extends ConsumerStatefulWidget {
  const _CompleteForm({super.key, required this.job});

  final Job job;

  @override
  ConsumerState<_CompleteForm> createState() => _CompleteFormState();
}

/// The fields whose server errors show on a text field; the rest show on
/// top of the form.
const _textFields = {'cleanerNotes', 'clientSignoffName'};

class _CompleteFormState extends ConsumerState<_CompleteForm> {
  final _formKey = GlobalKey<FormState>();
  final _notes = TextEditingController();
  final _signoff = TextEditingController();
  int? _score;
  bool _saving = false;
  Failure? _failure;

  @override
  void dispose() {
    _notes.dispose();
    _signoff.dispose();
    super.dispose();
  }

  /// Shows a server-side error for [field] first, then the [local] rule.
  FormFieldValidator<String> _validator(
    String field,
    String? Function(String value) local,
  ) => (value) {
    if (_failure case ValidationFailure(:final fieldErrors)) {
      if (fieldErrors[field] case final errors? when errors.isNotEmpty) {
        return AppLocalizations.of(context).fieldError(errors.first);
      }
    }
    return local(value ?? '');
  };

  Future<void> _save() async {
    setState(() => _failure = null);
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }
    final job = widget.job;
    setState(() => _saving = true);
    try {
      await ref.read(completeJobProvider)(
        CompleteJobParams(
          clientId: job.clientId,
          jobId: job.id,
          completion: JobCompletion(
            qualityScore: _score,
            cleanerNotes: _notes.text,
            clientSignoffName: _signoff.text,
          ),
        ),
      );
      invalidateJobs(ref);
      if (mounted) context.pop();
    } on Failure catch (f) {
      HapticFeedback.mediumImpact();
      if (!mounted) return;
      setState(() => _failure = f);
      // Re-run validators so server field errors appear on their fields.
      _formKey.currentState!.validate();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final side = pageSide(context);
    final job = widget.job;
    final open = job.checklistTotal - job.checklistDone;

    final failure = _failure;
    final notices = <(String, NoticeTone)>[
      ...switch (failure) {
        null => const <(String, NoticeTone)>[],
        ValidationFailure(:final fieldErrors) when fieldErrors.isNotEmpty => [
          for (final MapEntry(:key, :value) in fieldErrors.entries)
            if (!_textFields.contains(key) && value.isNotEmpty)
              (l10n.fieldError(value.first), NoticeTone.error),
        ],
        final other => [(l10n.failureMessage(other), NoticeTone.error)],
      },
      if (open > 0) (l10n.checklistStillOpen(open), NoticeTone.info),
    ];

    return SpacePage(
      title: l10n.completeJobTitle,
      bottom: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(side, 8, side, 12),
          child: PrimaryButton(
            label: l10n.completeJob,
            busy: _saving,
            onPressed: _save,
          ),
        ),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (message, tone) in notices)
                  Padding(
                    padding: EdgeInsets.fromLTRB(side, 4, side, 4),
                    child: Notice(message: message, tone: tone),
                  ),
                FormSection(l10n.qualityScoreLabel, [
                  Semantics(
                    label: l10n.qualityScoreLabel,
                    child: ChoicePills<int>(
                      options: {for (var i = 1; i <= 5; i++) i: '$i'},
                      selected: {?_score},
                      // Tapping the picked score again clears it.
                      onToggle: _saving
                          ? null
                          : (v) =>
                                setState(() => _score = _score == v ? null : v),
                    ),
                  ),
                ], footer: l10n.qualityScoreHelp),
                FormSection(l10n.sectionDetails, [
                  SpaceTextField(
                    label: l10n.cleanerNotesLabel,
                    controller: _notes,
                    enabled: !_saving,
                    hint: l10n.cleanerNotesHint,
                    textCapitalization: TextCapitalization.sentences,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    maxLines: null,
                    validator: _validator(
                      'cleanerNotes',
                      (v) => v.trim().length > 2000
                          ? l10n.validationMaxLength('2000')
                          : null,
                    ),
                  ),
                  SpaceTextField(
                    label: l10n.clientSignoffLabel,
                    controller: _signoff,
                    enabled: !_saving,
                    hint: l10n.clientSignoffHint,
                    helper: l10n.clientSignoffHelp,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    validator: _validator(
                      'clientSignoffName',
                      (v) => v.trim().length > 200
                          ? l10n.validationMaxLength('200')
                          : null,
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
