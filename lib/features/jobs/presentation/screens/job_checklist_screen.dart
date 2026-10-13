import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../shell/presentation/page_action.dart';
import '../../di/jobs_providers.dart';
import '../../domain/entities/job.dart';
import '../../domain/usecases/job_usecases.dart';
import '../controllers/jobs_providers.dart';

/// A job's checklist as one field per item, in order. New items come from
/// the dock's "+". Saving replaces every item, all unticked, so the page
/// warns when some are ticked already. Needs `jobs.edit`.
class JobChecklistScreen extends ConsumerWidget {
  const JobChecklistScreen({
    super.key,
    required this.clientId,
    required this.jobId,
  });

  /// Path segment under a job.
  static const route = 'checklist';

  /// The API takes up to this many items, each up to [maxLength].
  static const maxItems = 50;
  static const maxLength = 300;

  final String clientId;
  final String jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // Wait for the job before building fields.
    return switch (ref.watch(jobProvider((clientId, jobId)))) {
      AsyncValue(value: final job?) => _ChecklistForm(
        key: ValueKey(jobId),
        job: job,
      ),
      final other => SpacePage(
        title: l10n.editChecklistTitle,
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

class _ChecklistForm extends ConsumerStatefulWidget {
  const _ChecklistForm({super.key, required this.job});

  final Job job;

  @override
  ConsumerState<_ChecklistForm> createState() => _ChecklistFormState();
}

/// One field: its text, and the focus a new one takes.
class _Item {
  _Item([String text = ''])
    : controller = TextEditingController(text: text),
      focus = FocusNode();

  final TextEditingController controller;
  final FocusNode focus;

  void dispose() {
    controller.dispose();
    focus.dispose();
  }
}

class _ChecklistFormState extends ConsumerState<_ChecklistForm>
    with PageActionHost {
  final _formKey = GlobalKey<FormState>();
  late final List<_Item> _items = [
    for (final item in widget.job.checklist) _Item(item.description),
  ];
  bool _saving = false;
  Failure? _failure;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context);
    registerPageAction(
      location: GoRouterState.of(context).matchedLocation,
      label: l10n.addChecklistItem,
      text: l10n.addChecklistItemShort,
      onPressed: () {
        if (!_saving) _add();
      },
    );
  }

  @override
  void dispose() {
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  void _add() {
    // The page says it's full.
    if (_items.length >= JobChecklistScreen.maxItems) {
      HapticFeedback.mediumImpact();
      return;
    }
    final item = _Item();
    setState(() => _items.add(item));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) item.focus.requestFocus();
    });
  }

  void _remove(_Item item) {
    setState(() => _items.remove(item));
    // After the field is gone from the tree.
    WidgetsBinding.instance.addPostFrameCallback((_) => item.dispose());
  }

  List<String> get _texts => [
    for (final item in _items)
      if (item.controller.text.trim() case final text when text.isNotEmpty)
        text,
  ];

  Future<void> _save() async {
    setState(() => _failure = null);
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }
    final job = widget.job;
    // Saving clears every tick, so leave an unchanged list alone.
    if (listEquals(_texts, [for (final i in job.checklist) i.description])) {
      context.pop();
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(setJobChecklistProvider)(
        SetChecklistParams(
          clientId: job.clientId,
          jobId: job.id,
          items: _texts,
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
    final ticked = widget.job.checklistDone;
    final failure = _failure;
    final full = _items.length >= JobChecklistScreen.maxItems;

    return SpacePage(
      title: l10n.editChecklistTitle,
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (failure != null)
                  Padding(
                    padding: EdgeInsets.fromLTRB(side, 4, side, 4),
                    child: Notice(message: l10n.failureMessage(failure)),
                  ),
                if (ticked > 0)
                  Padding(
                    padding: EdgeInsets.fromLTRB(side, 4, side, 4),
                    child: Notice(
                      message: l10n.checklistResetWarning(ticked),
                      tone: NoticeTone.info,
                    ),
                  ),
                if (full)
                  Padding(
                    padding: EdgeInsets.fromLTRB(side, 4, side, 4),
                    child: Notice(
                      message: l10n.checklistFull(JobChecklistScreen.maxItems),
                      tone: NoticeTone.info,
                    ),
                  ),
                FormSection(null, [
                  if (_items.isEmpty)
                    Text(
                      l10n.checklistEmptyHint,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  for (final (i, item) in _items.indexed)
                    SpaceTextField(
                      key: ObjectKey(item),
                      label: l10n.checklistItemLabel(i + 1),
                      controller: item.controller,
                      focusNode: item.focus,
                      enabled: !_saving,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.done,
                      labelAction: LinkButton(
                        label: l10n.removeButton,
                        onPressed: _saving ? null : () => _remove(item),
                      ),
                      validator: (v) =>
                          (v ?? '').trim().length > JobChecklistScreen.maxLength
                          ? l10n.validationMaxLength(
                              '${JobChecklistScreen.maxLength}',
                            )
                          : null,
                    ),
                ], footer: l10n.checklistEditHelp),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
