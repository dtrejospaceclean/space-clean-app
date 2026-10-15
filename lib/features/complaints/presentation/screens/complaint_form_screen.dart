import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design.dart';
import '../../../../core/domain/picked_photo.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../core/media/photo_picker.dart';
import '../../../../core/widgets/adaptive.dart';
import '../../../../core/widgets/priority_label.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../access/domain/entities/account_access.dart';
import '../../../access/presentation/controllers/account_access_provider.dart';
import '../../../clients/presentation/screens/accounts_screen.dart';
import '../../../jobs/domain/entities/job.dart';
import '../../../jobs/domain/usecases/job_usecases.dart';
import '../../../jobs/presentation/controllers/jobs_providers.dart';
import '../../../locations/domain/entities/location.dart';
import '../../../locations/presentation/controllers/locations_providers.dart';
import '../../../team/domain/entities/member.dart';
import '../../../team/presentation/controllers/team_providers.dart';
import '../../di/complaints_providers.dart';
import '../../domain/entities/complaint.dart';
import '../../domain/usecases/complaint_usecases.dart';
import '../controllers/complaints_providers.dart';
import 'complaints_screen.dart';

/// A new complaint ([complaintId] null) or an edit of one that isn't
/// resolved. Needs `complaints.edit`. A new one can start assigned (with
/// `complaints.assign`); after that, assigning is done from its page. A new
/// one can take up to [Complaint.maxPhotos] photos, uploaded once it's
/// saved; after that they're added and removed on its page. One reported
/// from a job's page ([jobId]) starts linked to it and goes back there when
/// saved.
class ComplaintFormScreen extends ConsumerWidget {
  const ComplaintFormScreen({
    super.key,
    required this.clientId,
    this.complaintId,
    this.jobId,
  });

  final String clientId;
  final String? complaintId;

  /// The job a new complaint is about.
  final String? jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final id = complaintId;
    if (id == null) return _ComplaintForm(clientId: clientId, jobId: jobId);
    // Wait for the complaint before building fields.
    return switch (ref.watch(complaintProvider((clientId, id)))) {
      AsyncValue(value: final complaint?) => _ComplaintForm(
        key: ValueKey(id),
        clientId: clientId,
        initial: complaint,
      ),
      final other => SpacePage(
        title: l10n.editComplaint,
        slivers: [
          AsyncSlivers<Complaint>(
            value: other,
            skeleton: SkeletonLayout.form,
            onRetry: () => ref.invalidate(complaintProvider((clientId, id))),
            builder: (_) => const SliverToBoxAdapter(),
          ),
        ],
      ),
    };
  }
}

class _ComplaintForm extends ConsumerStatefulWidget {
  const _ComplaintForm({
    super.key,
    required this.clientId,
    this.initial,
    this.jobId,
  });

  final String clientId;

  /// The complaint edited; null to create.
  final Complaint? initial;

  /// The job a new complaint starts linked to.
  final String? jobId;

  @override
  ConsumerState<_ComplaintForm> createState() => _ComplaintFormState();
}

class _ComplaintFormState extends ConsumerState<_ComplaintForm> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.initial?.title);
  late final _description = TextEditingController(
    text: widget.initial?.description,
  );
  late final _area = TextEditingController(text: widget.initial?.area);
  late Priority _priority = switch (widget.initial?.priority) {
    final p? when p != Priority.unknown => p,
    _ => Priority.medium,
  };
  late String? _locationId = widget.initial?.locationId;
  late String? _jobId = widget.initial?.jobId ?? widget.jobId;
  String? _assignedToId;

  /// Photos for a new complaint, uploaded after it's created.
  final _photos = <PickedPhoto>[];

  bool _saving = false;
  Failure? _failure;

  /// Why a picker had nothing to offer.
  String? _pickerNote;

  bool get _creating => widget.initial == null;

  @override
  void initState() {
    super.initState();
    // Started from a job: it says where, once it's loaded.
    if (widget.jobId case final jobId?) {
      ref.listenManual(jobProvider((widget.clientId, jobId)), (_, next) {
        if (next.value?.locationId case final locationId?
            when _locationId == null && _jobId == jobId) {
          setState(() => _locationId = locationId);
        }
      }, fireImmediately: true);
    }
  }

  /// The past month's jobs: what a complaint is usually about.
  JobQuery get _recentJobs => JobQuery(
    clientId: widget.clientId,
    period: JobPeriod.past,
    today: ref.read(clockProvider)(),
  );

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _area.dispose();
    super.dispose();
  }

  /// Shows a server-side error for [field] first, then the [local] rule.
  FormFieldValidator<String> _validator(
    String field, [
    String? Function(String value)? local,
  ]) => (value) {
    if (_failure case ValidationFailure(:final fieldErrors)) {
      if (fieldErrors[field] case final errors? when errors.isNotEmpty) {
        return AppLocalizations.of(context).fieldError(errors.first);
      }
    }
    return local?.call(value ?? '');
  };

  /// Waits for [list] (it may still be loading), then offers its items. A
  /// list that can't load (no access to it, offline) says why on top of the
  /// form; an empty one says so.
  Future<void> _pickFrom<T>({
    required String title,
    required Future<List<T>> list,
    required String Function(T item) id,
    required String Function(T item) label,
    required String empty,
    required bool hasValue,
    required void Function(T? item) apply,
  }) async {
    final List<T> items;
    try {
      items = await list;
    } on Failure catch (f) {
      if (mounted) setState(() => _failure = f);
      return;
    }
    if (!mounted) return;
    setState(() {
      _pickerNote = items.isEmpty && !hasValue ? empty : null;
      if (_failure is! ValidationFailure) _failure = null;
    });
    if (items.isEmpty && !hasValue) return;
    final picked = await showAppChoice(
      context,
      title: title,
      allowClear: hasValue,
      options: {for (final item in items) id(item): label(item)},
    );
    if (picked == null || !mounted) return;
    setState(
      () => apply(
        picked.isEmpty ? null : items.where((i) => id(i) == picked).firstOrNull,
      ),
    );
  }

  Future<void> _tell(String message) => showAdaptiveDialog<void>(
    context: context,
    builder: (context) => AlertDialog.adaptive(
      content: Text(message),
      actions: [
        adaptiveAction(
          context,
          label: AppLocalizations.of(context).doneButton,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );

  Future<void> _addPhoto() async {
    final l10n = AppLocalizations.of(context);
    const camera = 'camera';
    final choice = await showAppChoice(
      context,
      title: l10n.addPhoto,
      allowClear: false,
      options: {camera: l10n.takePhoto, 'library': l10n.chooseFromLibrary},
    );
    if (choice == null || !mounted) return;
    String problem;
    try {
      final photo = await ref
          .read(photoPickerProvider)
          .pick(choice == camera ? PhotoSource.camera : PhotoSource.library);
      if (photo == null || !mounted) return;
      if (!photo.isTooLarge) {
        setState(() => _photos.add(photo));
        return;
      }
      problem = l10n.messageForKey(AddComplaintPhoto.tooLargeKey);
    } on PhotoAccessDenied {
      problem = l10n.photoAccessDenied;
    } on Exception {
      problem = l10n.photoPickFailed;
    }
    if (mounted) await _tell(problem);
  }

  /// Uploads [_photos] to the new complaint one by one. A photo that fails
  /// doesn't undo the complaint: the user hears how many and why, and adds
  /// them again from its page.
  Future<void> _uploadPhotos(String complaintId) async {
    final upload = ref.read(addComplaintPhotoProvider);
    final complaint = ComplaintRef(
      clientId: widget.clientId,
      complaintId: complaintId,
    );
    Failure? first;
    var failed = 0;
    for (final photo in _photos) {
      try {
        await upload(
          AddComplaintPhotoParams(complaint: complaint, photo: photo),
        );
      } on Failure catch (f) {
        first ??= f;
        failed++;
      }
    }
    if (first == null || !mounted) return;
    // Saved: the button stops spinning while the user reads why.
    setState(() => _saving = false);
    final l10n = AppLocalizations.of(context);
    await _tell(
      l10n.complaintPhotosNotAdded(failed, l10n.failureMessage(first)),
    );
  }

  Future<void> _save() async {
    setState(() => _failure = null);
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }
    setState(() => _saving = true);
    try {
      final saved = await ref.read(saveComplaintProvider)(
        SaveComplaintParams(
          clientId: widget.clientId,
          complaintId: widget.initial?.id,
          draft: ComplaintDraft(
            title: _title.text,
            description: _description.text,
            priority: _priority,
            locationId: _locationId,
            area: _area.text,
            jobId: _jobId,
            assignedToId: _creating ? _assignedToId : null,
          ),
        ),
      );
      if (_creating && _photos.isNotEmpty) await _uploadPhotos(saved.id);
      invalidateComplaints(ref, widget.clientId);
      if (!mounted) return;
      if (_creating && widget.jobId != null) {
        // Back to the job, which lists it now.
        context.pop();
      } else if (_creating) {
        // A new complaint has its own page.
        context.go(
          '${AccountsScreen.path}/${widget.clientId}/'
          '${ComplaintsScreen.route}/${saved.id}',
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
    final canAssign =
        _creating &&
        (ref
                .watch(accountAccessProvider(widget.clientId))
                .value
                ?.can(Permissions.complaintsAssign) ??
            false);

    // Names for what's picked, from the lists once they're here. Watching
    // also keeps the lists alive for the pickers.
    final locations = ref.watch(allLocationsProvider(widget.clientId)).value;
    final jobs = ref.watch(accountJobsProvider(_recentJobs)).value;
    // The job it was reported from may be upcoming, outside that list.
    final fromJob = switch (widget.jobId) {
      final id? => ref.watch(jobProvider((widget.clientId, id))).value,
      null => null,
    };
    final members = canAssign
        ? ref.watch(membersProvider(widget.clientId)).value
        : null;
    final locationName =
        locations?.where((l) => l.id == _locationId).firstOrNull?.name ??
        (_locationId == initial?.locationId ? initial?.locationName : null);
    String jobLabel(Job j) =>
        '${j.title} · ${context.formatDate(j.scheduledStart)}';
    final jobName = switch (jobs?.where((j) => j.id == _jobId).firstOrNull ??
        (fromJob?.id == _jobId ? fromJob : null)) {
      final j? => jobLabel(j),
      null when _jobId != null && _jobId == initial?.jobId => [
        ?initial?.jobTitle,
        if (initial?.jobStart case final start?) context.formatDate(start),
      ].join(' · '),
      _ => null,
    };
    final memberName = members
        ?.where((m) => m.userId == _assignedToId)
        .firstOrNull
        ?.name;

    final failure = _failure;
    return SpacePage(
      title: _creating ? l10n.newComplaintTitle : l10n.editComplaint,
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
                    label: l10n.complaintTitleLabel,
                    controller: _title,
                    enabled: !_saving,
                    hint: l10n.complaintTitleHint,
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
                    label: l10n.complaintDescriptionLabel,
                    controller: _description,
                    enabled: !_saving,
                    hint: l10n.complaintDescriptionHint,
                    textCapitalization: TextCapitalization.sentences,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    minLines: 3,
                    maxLines: null,
                    validator: _validator(
                      'description',
                      (v) => switch (v.trim()) {
                        '' => l10n.validationRequired,
                        final t when t.length > 4000 =>
                          l10n.validationMaxLength('4000'),
                        _ => null,
                      },
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
                if (_creating)
                  FormSection(l10n.complaintPhotosSection, [
                    PhotoStrip(
                      images: [
                        for (final p in _photos) FileImage(File(p.path)),
                      ],
                      slots: Complaint.maxPhotos,
                      onAdd: _saving ? null : _addPhoto,
                      onRemove: _saving
                          ? null
                          : (i) => setState(() => _photos.removeAt(i)),
                      onOpen: (i) => showPhotoViewer(
                        context,
                        images: [
                          for (final p in _photos) FileImage(File(p.path)),
                        ],
                        initial: i,
                      ),
                    ),
                  ], footer: l10n.complaintPhotosHint(Complaint.maxPhotos)),
                FormSection(l10n.sectionWhere, [
                  PickerField(
                    label: l10n.locationLabel,
                    value: locationName,
                    onTap: _saving
                        ? null
                        : () => _pickFrom<Location>(
                            title: l10n.locationLabel,
                            list: ref.read(
                              allLocationsProvider(widget.clientId).future,
                            ),
                            id: (l) => l.id,
                            label: (l) => l.name,
                            empty: l10n.eventNoLocations,
                            hasValue: _locationId != null,
                            apply: (l) => _locationId = l?.id,
                          ),
                  ),
                  SpaceTextField(
                    label: l10n.areaNameLabel,
                    controller: _area,
                    enabled: !_saving,
                    hint: l10n.complaintAreaHint,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.done,
                    validator: _validator(
                      'area',
                      (v) => v.trim().length > 150
                          ? l10n.validationMaxLength('150')
                          : null,
                    ),
                  ),
                  PickerField(
                    label: l10n.complaintJobLabel,
                    value: jobName,
                    onTap: _saving
                        ? null
                        : () => _pickFrom<Job>(
                            title: l10n.complaintJobLabel,
                            list: ref.read(
                              accountJobsProvider(_recentJobs).future,
                            ),
                            id: (j) => j.id,
                            label: jobLabel,
                            empty: l10n.complaintNoJobs,
                            hasValue: _jobId != null,
                            apply: (j) {
                              _jobId = j?.id;
                              // A job says where, if nothing's picked yet.
                              if (j != null) _locationId ??= j.locationId;
                            },
                          ),
                  ),
                  if (canAssign)
                    PickerField(
                      label: l10n.assignedToLabel,
                      value: memberName,
                      onTap: _saving
                          ? null
                          : () => _pickFrom<Member>(
                              title: l10n.assignedToLabel,
                              list: ref
                                  .read(membersProvider(widget.clientId).future)
                                  .then(
                                    (all) => [
                                      for (final m in all)
                                        if (m.isActive &&
                                            m.baseRole != 'client')
                                          m,
                                    ],
                                  ),
                              id: (m) => m.userId,
                              label: (m) => m.name,
                              empty: l10n.eventNoMembers,
                              hasValue: _assignedToId != null,
                              apply: (m) => _assignedToId = m?.userId,
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
