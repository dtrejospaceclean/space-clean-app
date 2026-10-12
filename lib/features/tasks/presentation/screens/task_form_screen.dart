import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../core/widgets/priority_label.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../clients/presentation/screens/accounts_screen.dart';
import '../../../jobs/presentation/controllers/jobs_providers.dart';
import '../../../team/presentation/controllers/team_providers.dart';
import '../../di/tasks_providers.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/task_usecases.dart';
import '../controllers/tasks_providers.dart';
import 'tasks_screen.dart';

/// A new task ([taskId] null) or an edit of an open one. Needs
/// `tasks.edit`. The assignee comes from the account's team.
class TaskFormScreen extends ConsumerWidget {
  const TaskFormScreen({super.key, required this.clientId, this.taskId});

  final String clientId;
  final String? taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final id = taskId;
    if (id == null) return _TaskForm(clientId: clientId);
    // Wait for the task before building fields.
    return switch (ref.watch(taskProvider((clientId, id)))) {
      AsyncValue(value: final task?) => _TaskForm(
        key: ValueKey(id),
        clientId: clientId,
        initial: task,
      ),
      final other => SpacePage(
        title: l10n.editTask,
        slivers: [
          AsyncSlivers<Task>(
            value: other,
            onRetry: () => ref.invalidate(taskProvider((clientId, id))),
            builder: (_) => const SliverToBoxAdapter(),
          ),
        ],
      ),
    };
  }
}

class _TaskForm extends ConsumerStatefulWidget {
  const _TaskForm({super.key, required this.clientId, this.initial});

  final String clientId;

  /// The task edited; null to create.
  final Task? initial;

  @override
  ConsumerState<_TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends ConsumerState<_TaskForm> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.initial?.title);
  late final _description = TextEditingController(
    text: widget.initial?.description,
  );
  late Priority _priority = switch (widget.initial?.priority) {
    final p? when p != Priority.unknown => p,
    _ => Priority.medium,
  };
  late DateTime? _due = widget.initial?.dueDate;
  late String? _assignedToId = widget.initial?.assignedToId;

  bool _saving = false;
  Failure? _failure;

  /// Why the assignee picker had nothing to offer.
  String? _pickerNote;

  bool get _creating => widget.initial == null;

  DateTime get _today {
    final now = ref.read(clockProvider)();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  /// Shows a server-side error for [field] first, then the [local] rule.
  FormFieldValidator<String> _validator(
    String field, [
    String? Function(String value)? local,
  ]) =>
      (value) => _serverError(field) ?? local?.call(value ?? '');

  String? _serverError(String field) {
    if (_failure case ValidationFailure(:final fieldErrors)) {
      if (fieldErrors[field] case final errors? when errors.isNotEmpty) {
        return AppLocalizations.of(context).fieldError(errors.first);
      }
    }
    return null;
  }

  Future<void> _pickDue() async {
    final picked = await showAppDatePicker(
      context,
      initial: _due ?? _today,
      last: DateTime(_today.year + 5, 12, 31),
    );
    if (picked != null) setState(() => _due = picked);
  }

  /// The account's active staff, not the client's own people. A team that
  /// can't load (no `team.view`, offline) says why on top of the form.
  Future<void> _pickAssignee() async {
    final l10n = AppLocalizations.of(context);
    final List<({String id, String name})> people;
    try {
      people = [
        for (final m in await ref.read(membersProvider(widget.clientId).future))
          if (m.isActive && m.baseRole != 'client')
            (id: m.userId, name: m.name),
      ];
    } on Failure catch (f) {
      if (mounted) setState(() => _failure = f);
      return;
    }
    if (!mounted) return;
    final hasValue = _assignedToId != null;
    setState(() {
      _pickerNote = people.isEmpty && !hasValue ? l10n.eventNoMembers : null;
      if (_failure is! ValidationFailure) _failure = null;
    });
    if (people.isEmpty && !hasValue) return;
    final picked = await showAppChoice(
      context,
      title: l10n.assignedToLabel,
      allowClear: hasValue,
      options: {for (final p in people) p.id: p.name},
    );
    if (picked == null || !mounted) return;
    setState(() => _assignedToId = picked.isEmpty ? null : picked);
  }

  Future<void> _save() async {
    setState(() => _failure = null);
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }
    setState(() => _saving = true);
    try {
      final saved = await ref.read(saveTaskProvider)(
        SaveTaskParams(
          clientId: widget.clientId,
          taskId: widget.initial?.id,
          draft: TaskDraft(
            title: _title.text,
            description: _description.text,
            priority: _priority,
            dueDate: _due,
            assignedToId: _assignedToId,
          ),
        ),
      );
      invalidateTasks(ref, widget.clientId);
      if (!mounted) return;
      if (_creating) {
        // A new task has its own page.
        context.go(
          '${AccountsScreen.path}/${widget.clientId}/'
          '${TasksScreen.route}/${saved.id}',
        );
      } else {
        context.pop();
      }
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
    final initial = widget.initial;
    // The name of who's picked, once the team is here. Watching also keeps
    // the list alive for the picker.
    final members = ref.watch(membersProvider(widget.clientId)).value;
    final assigneeName =
        members?.where((m) => m.userId == _assignedToId).firstOrNull?.name ??
        (_assignedToId == initial?.assignedToId
            ? initial?.assignedToName
            : null);

    final failure = _failure;
    return SpacePage(
      title: _creating ? l10n.newTaskTitle : l10n.editTask,
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
                if (failure != null &&
                    (failure is! ValidationFailure ||
                        failure.fieldErrors.isEmpty))
                  Padding(
                    padding: EdgeInsets.fromLTRB(side, 4, side, 4),
                    child: Notice(message: l10n.failureMessage(failure)),
                  ),
                if (_pickerNote case final note?)
                  Padding(
                    padding: EdgeInsets.fromLTRB(side, 4, side, 4),
                    child: Notice(message: note, tone: NoticeTone.info),
                  ),
                FormSection(l10n.sectionGeneral, [
                  SpaceTextField(
                    label: l10n.taskTitleLabel,
                    controller: _title,
                    enabled: !_saving,
                    hint: l10n.taskTitleHint,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    validator: _validator(
                      'title',
                      (v) => switch (v.trim()) {
                        '' => l10n.validationRequired,
                        final t when t.length > 200 => l10n.validationMaxLength(
                          '200',
                        ),
                        _ => null,
                      },
                    ),
                  ),
                  SpaceTextField(
                    label: l10n.taskDescriptionLabel,
                    controller: _description,
                    enabled: !_saving,
                    textCapitalization: TextCapitalization.sentences,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    minLines: 3,
                    maxLines: null,
                    validator: _validator(
                      'description',
                      (v) => v.trim().length > 4000
                          ? l10n.validationMaxLength('4000')
                          : null,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FieldLabel(l10n.priorityLabel),
                      ChoicePills<Priority>(
                        options: {
                          for (final p in Priority.choices)
                            p: l10n.priorityName(p),
                        },
                        selected: {_priority},
                        onToggle: _saving
                            ? null
                            : (p) => setState(() => _priority = p),
                      ),
                    ],
                  ),
                ]),
                FormSection(l10n.sectionDetails, [
                  PickerField(
                    label: l10n.taskDueDateLabel,
                    icon: Icons.calendar_today_outlined,
                    value: switch (_due) {
                      final day? => context.formatDate(day),
                      null => null,
                    },
                    errorText: _serverError('dueDate'),
                    onTap: _saving ? null : _pickDue,
                  ),
                  if (_due != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: LinkButton(
                        label: l10n.noDueDate,
                        onPressed: _saving
                            ? null
                            : () => setState(() => _due = null),
                      ),
                    ),
                  PickerField(
                    label: l10n.assignedToLabel,
                    value: assigneeName,
                    errorText: _serverError('assignedToUserId'),
                    onTap: _saving ? null : _pickAssignee,
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
