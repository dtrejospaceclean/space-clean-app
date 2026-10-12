import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/domain/money.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../jobs/domain/entities/job.dart';
import '../../../jobs/domain/usecases/job_usecases.dart';
import '../../../jobs/presentation/controllers/jobs_providers.dart';
import '../../domain/entities/invoice.dart';

/// What the line page hands back to the invoice form: the line as edited,
/// or null [line] to remove it.
class InvoiceLineResult {
  const InvoiceLineResult(this.line);

  final InvoiceLineDraft? line;
}

/// Adds a line to the invoice being edited ([initial] null) or changes one:
/// what's billed, how many, at what price, and optionally the job it's
/// for. Nothing is saved here: "Done" hands the line back to the form,
/// whose Save sends the whole invoice.
class InvoiceLineScreen extends ConsumerStatefulWidget {
  const InvoiceLineScreen({super.key, required this.clientId, this.initial});

  /// Path segment under an invoice form.
  static const route = 'item';

  final String clientId;
  final InvoiceLineDraft? initial;

  @override
  ConsumerState<InvoiceLineScreen> createState() => _InvoiceLineScreenState();
}

class _InvoiceLineScreenState extends ConsumerState<InvoiceLineScreen> {
  /// Up to 2 decimals, like the API allows.
  static final _decimalPattern = RegExp(r'^\d+(\.\d{1,2})?$');

  final _formKey = GlobalKey<FormState>();
  late String? _jobId = widget.initial?.jobId;
  late String? _jobTitle = widget.initial?.jobTitle;
  late final _description = TextEditingController(
    text: widget.initial?.description,
  );

  /// One of something unless said otherwise: most lines bill a month or a
  /// visit.
  late final _quantity = TextEditingController(
    text: widget.initial?.quantity ?? '1',
  );
  late final _unitPrice = TextEditingController(
    text: widget.initial?.unitPrice,
  );
  Failure? _failure;

  /// Why the job picker didn't open (no recent jobs).
  String? _note;

  /// Jobs bill after the work, so the past month's are offered.
  late final JobQuery _recentJobs = JobQuery(
    clientId: widget.clientId,
    period: JobPeriod.past,
    today: ref.read(clockProvider)(),
  );

  @override
  void dispose() {
    _description.dispose();
    _quantity.dispose();
    _unitPrice.dispose();
    super.dispose();
  }

  String _jobLabel(Job j) =>
      '${j.title} · ${context.formatDate(j.scheduledStart)}';

  /// Links a job, filling the description with its title unless it was
  /// typed by hand.
  Future<void> _pickJob() async {
    final l10n = AppLocalizations.of(context);
    final List<Job> jobs;
    try {
      jobs = await ref.read(accountJobsProvider(_recentJobs).future);
    } on Failure catch (f) {
      setState(() => _failure = f);
      return;
    }
    if (!mounted) return;
    setState(() {
      _failure = null;
      _note = jobs.isEmpty && _jobId == null ? l10n.invoiceLineNoJobs : null;
    });
    if (_note != null) return;
    final picked = await showAppChoice(
      context,
      title: l10n.invoiceLineJobLabel,
      allowClear: _jobId != null,
      options: {for (final j in jobs) j.id: _jobLabel(j)},
    );
    if (picked == null || !mounted) return;
    final next = jobs.where((j) => j.id == picked).firstOrNull;
    final untouched =
        _description.text.trim().isEmpty || _description.text == _jobTitle;
    setState(() {
      _failure = null;
      _jobId = next?.id;
      if (next != null && untouched) _description.text = next.title;
      _jobTitle = next?.title;
    });
  }

  void _done() {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }
    context.pop(
      InvoiceLineResult(
        InvoiceLineDraft(
          jobId: _jobId,
          jobTitle: _jobTitle,
          description: _description.text.trim(),
          quantity: _quantity.text.trim(),
          unitPrice: _unitPrice.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final failure = _failure;
    // Watching keeps the list alive for the picker, and names the job.
    final jobs = ref.watch(accountJobsProvider(_recentJobs)).value;
    final job = jobs?.where((j) => j.id == _jobId).firstOrNull;
    String? decimal(String v, String message) => switch (v.trim()) {
      '' => l10n.validationRequired,
      final text => _decimalPattern.hasMatch(text) ? null : message,
    };
    const decimalKeyboard = TextInputType.numberWithOptions(decimal: true);
    final decimalOnly = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))];
    final total = centsToDecimal(
      lineTotalCents(_quantity.text, _unitPrice.text),
    );

    return SpacePage(
      title: widget.initial == null ? l10n.addLineItem : l10n.editLineItem,
      bottom: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            pageSide(context),
            8,
            pageSide(context),
            12,
          ),
          child: PrimaryButton(label: l10n.doneButton, onPressed: _done),
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
                    padding: EdgeInsets.fromLTRB(
                      pageSide(context),
                      4,
                      pageSide(context),
                      0,
                    ),
                    child: Notice(message: l10n.failureMessage(failure)),
                  ),
                if (_note case final note?)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      pageSide(context),
                      4,
                      pageSide(context),
                      0,
                    ),
                    child: Notice(message: note, tone: NoticeTone.info),
                  ),
                // One card: what's billed and what it costs.
                FormSection(null, [
                  PickerField(
                    label: l10n.invoiceLineJobLabel,
                    value: switch (job) {
                      final j? => _jobLabel(j),
                      // Older than the past month, or not loaded yet.
                      null => _jobTitle,
                    },
                    onTap: _pickJob,
                  ),
                  SpaceTextField(
                    label: l10n.lineItemDescriptionLabel,
                    controller: _description,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null,
                    validator: (v) => switch ((v ?? '').trim()) {
                      '' => l10n.validationRequired,
                      final t when t.length > 500 => l10n.validationMaxLength(
                        '500',
                      ),
                      _ => null,
                    },
                  ),
                  SpaceTextField(
                    label: l10n.lineItemQuantityLabel,
                    controller: _quantity,
                    hint: '1',
                    keyboardType: decimalKeyboard,
                    inputFormatters: decimalOnly,
                    onChanged: (_) => setState(() {}),
                    validator: (v) => decimal(v ?? '', l10n.invalidQuantity),
                  ),
                  SpaceTextField(
                    label: l10n.lineItemUnitPriceLabel,
                    controller: _unitPrice,
                    hint: '2400',
                    keyboardType: decimalKeyboard,
                    inputFormatters: decimalOnly,
                    textInputAction: TextInputAction.done,
                    onChanged: (_) => setState(() {}),
                    validator: (v) => decimal(v ?? '', l10n.invalidPrice),
                  ),
                ], footer: l10n.lineItemTotal(context.formatMoney(total))),
                // Only a line already on the invoice can be taken off it.
                if (widget.initial != null)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      pageSide(context),
                      24,
                      pageSide(context),
                      0,
                    ),
                    child: SecondaryButton(
                      label: l10n.removeLineItem,
                      icon: Icons.delete_outline_rounded,
                      destructive: true,
                      onPressed: () =>
                          context.pop(const InvoiceLineResult(null)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
