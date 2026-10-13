import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../l10n/app_localizations.dart';
import '../../di/complaints_providers.dart';
import '../../domain/entities/complaint.dart';
import '../../domain/usecases/complaint_usecases.dart';
import '../controllers/complaints_providers.dart';
import '../widgets/complaint_labels.dart';

/// Closes a complaint with what was done (required); the server records who
/// resolved it and when. Needs `complaints.edit`.
class ResolveComplaintScreen extends ConsumerWidget {
  const ResolveComplaintScreen({
    super.key,
    required this.clientId,
    required this.complaintId,
  });

  /// Path segment under a complaint's page.
  static const route = 'resolve';

  final String clientId;
  final String complaintId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final key = (clientId, complaintId);
    return switch (ref.watch(complaintProvider(key))) {
      AsyncValue(value: final complaint?) => _ResolveForm(
        key: ValueKey(complaintId),
        clientId: clientId,
        complaint: complaint,
      ),
      final other => SpacePage(
        title: l10n.resolveComplaintTitle,
        slivers: [
          AsyncSlivers<Complaint>(
            value: other,
            skeleton: SkeletonLayout.form,
            onRetry: () => ref.invalidate(complaintProvider(key)),
            builder: (_) => const SliverToBoxAdapter(),
          ),
        ],
      ),
    };
  }
}

class _ResolveForm extends ConsumerStatefulWidget {
  const _ResolveForm({
    super.key,
    required this.clientId,
    required this.complaint,
  });

  final String clientId;
  final Complaint complaint;

  @override
  ConsumerState<_ResolveForm> createState() => _ResolveFormState();
}

class _ResolveFormState extends ConsumerState<_ResolveForm> {
  final _formKey = GlobalKey<FormState>();

  /// Starts from earlier notes, if it was resolved before and reopened.
  late final _notes = TextEditingController(
    text: widget.complaint.resolutionNotes,
  );
  bool _saving = false;
  Failure? _failure;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _resolve() async {
    setState(() => _failure = null);
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(resolveComplaintProvider)(
        ResolveComplaintParams(
          complaint: ComplaintRef(
            clientId: widget.clientId,
            complaintId: widget.complaint.id,
          ),
          notes: _notes.text,
        ),
      );
      invalidateComplaints(ref, widget.clientId);
      if (mounted) context.pop();
    } on Failure catch (f) {
      HapticFeedback.mediumImpact();
      if (!mounted) return;
      setState(() => _failure = f);
      // Re-run validators so a server field error shows on the notes.
      _formKey.currentState!.validate();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final failure = _failure;
    final side = pageSide(context);

    return SpacePage(
      title: l10n.resolveComplaintTitle,
      bottom: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(side, 8, side, 12),
          child: PrimaryButton(
            label: l10n.resolveComplaint,
            icon: Icons.task_alt_rounded,
            busy: _saving,
            onPressed: _resolve,
          ),
        ),
      ),
      slivers: [
        if (failure != null && failure is! ValidationFailure)
          PageBox(top: 4, child: Notice(message: l10n.failureMessage(failure))),
        PageBox(
          top: 4,
          child: ListCard(
            children: [ComplaintRow(complaint: widget.complaint)],
          ),
        ),
        SliverToBoxAdapter(
          child: Form(
            key: _formKey,
            child: FormSection(l10n.complaintResolutionSection, [
              SpaceTextField(
                label: l10n.resolutionNotesLabel,
                controller: _notes,
                enabled: !_saving,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                minLines: 4,
                maxLines: null,
                validator: (v) {
                  if (_failure case ValidationFailure(:final fieldErrors)) {
                    if (fieldErrors['resolutionNotes'] case final errors?
                        when errors.isNotEmpty) {
                      return l10n.fieldError(errors.first);
                    }
                  }
                  return switch ((v ?? '').trim()) {
                    '' => l10n.validationRequired,
                    final t when t.length > 4000 => l10n.validationMaxLength(
                      '4000',
                    ),
                    _ => null,
                  };
                },
              ),
            ], footer: l10n.resolveComplaintHelp),
          ),
        ),
      ],
    );
  }
}
