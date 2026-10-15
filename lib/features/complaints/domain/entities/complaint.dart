import '../../../../core/domain/priority.dart';

export '../../../../core/domain/priority.dart';

/// Where a complaint stands. It opens as [open], is [inProgress] once
/// someone is assigned, and [resolved] with notes on what was done.
enum ComplaintStatus {
  open('open'),
  inProgress('in_progress'),
  resolved('resolved'),

  /// A status this app doesn't know yet.
  unknown('');

  const ComplaintStatus(this.wire);

  /// The API's name for it.
  final String wire;

  static ComplaintStatus fromWire(String? value) => values.firstWhere(
    (s) => s != unknown && s.wire == value,
    orElse: () => unknown,
  );
}

/// A photo of what a complaint is about. The server re-encodes it (WebP,
/// at most 1600 px). [url] may be a signed link that expires within the
/// hour, so it's read fresh with the complaint, never kept.
class ComplaintPhoto {
  const ComplaintPhoto({
    required this.id,
    required this.url,
    required this.createdAt,
  });

  final String id;
  final String url;
  final DateTime createdAt;
}

/// A client's complaint about the service at one account, optionally tied
/// to a location, an area of it and the job it's about. Complaints are
/// never deleted: they're resolved, and can be reopened.
class Complaint {
  const Complaint({
    required this.id,
    required this.clientId,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.reportedDate,
    this.locationId,
    this.locationName,
    this.area,
    this.jobId,
    this.jobTitle,
    this.jobStart,
    this.assignedToId,
    this.assignedToName,
    this.reportedByName,
    this.resolvedByName,
    this.resolutionTime,
    this.resolutionNotes,
    this.resolutionHours,
    this.photos = const [],
  });

  /// The most photos a complaint can have (`complaints.photo_limit`).
  static const maxPhotos = 3;

  final String id;
  final String clientId;
  final String title;
  final String description;
  final Priority priority;
  final ComplaintStatus status;

  /// When it was reported (an instant).
  final DateTime reportedDate;

  final String? locationId;
  final String? locationName;

  /// Where on site, e.g. "Restrooms, floor 3".
  final String? area;

  final String? jobId;
  final String? jobTitle;
  final DateTime? jobStart;

  final String? assignedToId;
  final String? assignedToName;
  final String? reportedByName;

  /// Who resolved it and when; null unless resolved.
  final String? resolvedByName;
  final DateTime? resolutionTime;

  /// What was done. Kept when a complaint is reopened.
  final String? resolutionNotes;

  /// Hours from report to resolution (one decimal), worked out by the
  /// server; null unless resolved.
  final double? resolutionHours;

  /// In the order they were added.
  final List<ComplaintPhoto> photos;

  bool get isResolved => status == ComplaintStatus.resolved;

  /// A resolved complaint is read-only until it's reopened.
  bool get isEditable => !isResolved;

  /// Photos are added and removed only while it [isEditable], up to
  /// [maxPhotos].
  bool get canAddPhoto => isEditable && photos.length < maxPhotos;
}

/// What's typed in the form. Assigning has its own endpoint, so an edit
/// never sends [assignedToId]; a new complaint may start assigned.
class ComplaintDraft {
  const ComplaintDraft({
    required this.title,
    required this.description,
    required this.priority,
    this.locationId,
    this.area,
    this.jobId,
    this.assignedToId,
  });

  final String title;
  final String description;
  final Priority priority;
  final String? locationId;
  final String? area;
  final String? jobId;

  /// Only on a create.
  final String? assignedToId;
}

/// Complaints still being worked on, most urgent first: by priority, then
/// newest. Resolved ones are left out.
List<Complaint> openByUrgency(List<Complaint> all) {
  return [
    for (final c in all)
      if (!c.isResolved) c,
  ]..sort((a, b) {
    final byPriority = a.priority.rank.compareTo(b.priority.rank);
    return byPriority != 0
        ? byPriority
        : b.reportedDate.compareTo(a.reportedDate);
  });
}

/// Resolved complaints, latest resolved first.
List<Complaint> resolvedLatestFirst(List<Complaint> all) =>
    [
      for (final c in all)
        if (c.isResolved) c,
    ]..sort(
      (a, b) => (b.resolutionTime ?? b.reportedDate).compareTo(
        a.resolutionTime ?? a.reportedDate,
      ),
    );
