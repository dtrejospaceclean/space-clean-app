import '../../../clients/domain/entities/client.dart';

enum JobStatus { scheduled, inProgress, completed, cancelled, unknown }

/// How a job came about.
enum JobType {
  /// From a scope's time window (through the calendar).
  recurring('recurring'),

  /// One-off work: made by hand, or from a one-off calendar event.
  special('special'),

  /// A type this app doesn't know yet.
  unknown('');

  const JobType(this.wire);

  /// The API's name for it.
  final String wire;

  static JobType fromWire(String? value) => values.firstWhere(
    (t) => t != unknown && t.wire == value,
    orElse: () => unknown,
  );
}

class JobLocation {
  const JobLocation({required this.name, this.address, this.city});

  final String name;
  final String? address;
  final String? city;
}

/// Someone on a job's crew.
class JobAssignee {
  const JobAssignee({
    required this.userId,
    required this.name,
    this.roleOnJob,
    this.checkInTime,
    this.checkOutTime,
  });

  final String userId;
  final String name;

  /// What they do on this job ("lead", "helper").
  final String? roleOnJob;

  /// Local time.
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
}

/// One thing to do on a job, ticked off by the crew.
class ChecklistItem {
  const ChecklistItem({
    required this.id,
    required this.description,
    this.isCompleted = false,
    this.completedByName,
    this.completedAt,
  });

  final String id;
  final String description;
  final bool isCompleted;
  final String? completedByName;

  /// Local time.
  final DateTime? completedAt;
}

/// A cleaning job on a client's site.
class Job {
  const Job({
    required this.id,
    required this.clientId,
    required this.title,
    required this.status,
    required this.scheduledStart,
    this.scheduledEnd,
    this.jobType = JobType.special,
    this.locationId,
    this.location,
    this.scopeId,
    this.scopeArea,
    this.assignees = const [],
    this.instructions,
    this.checklist = const [],
    this.actualStart,
    this.actualEnd,
    this.startedByName,
    this.completedByName,
    this.qualityScore,
    this.cleanerNotes,
    this.clientSignoffName,
  });

  final String id;
  final String clientId;
  final String title;
  final JobStatus status;
  final JobType jobType;

  /// Local time.
  final DateTime scheduledStart;
  final DateTime? scheduledEnd;
  final String? locationId;
  final JobLocation? location;
  final String? scopeId;

  /// The scope's area; null for a whole-site scope (or no scope).
  final String? scopeArea;
  final List<JobAssignee> assignees;
  final String? instructions;
  final List<ChecklistItem> checklist;

  /// Local time; set when it started and finished.
  final DateTime? actualStart;
  final DateTime? actualEnd;
  final String? startedByName;
  final String? completedByName;

  /// 0 to 5, given on completion.
  final num? qualityScore;
  final String? cleanerNotes;
  final String? clientSignoffName;

  int get checklistTotal => checklist.length;
  int get checklistDone => checklist.where((i) => i.isCompleted).length;

  /// Completed and cancelled jobs are a record of what happened: they can't
  /// be edited, nor their checklist or crew changed (`jobs.closed`).
  bool get isOpen =>
      status == JobStatus.scheduled || status == JobStatus.inProgress;

  /// Only a job that never started (`jobs.only_scheduled_deletable`).
  bool get canDelete => status == JobStatus.scheduled;

  /// Whether [userId] is on the crew.
  bool hasCrewMember(String userId) => assignees.any((a) => a.userId == userId);

  /// [userId]'s place on the crew, if they're on it.
  JobAssignee? crewMember(String userId) =>
      assignees.where((a) => a.userId == userId).firstOrNull;

  /// Anything not finished yet (`jobs.already_completed`).
  bool get canCancel => isOpen;
}

/// A job with the account it belongs to, for lists that span accounts.
class AccountJob {
  const AccountJob({required this.job, required this.client});

  final Job job;
  final Client client;
}

/// The fields of a job as typed. Empty optional fields clear them on an
/// edit. Crew and checklist have their own saves.
class JobDraft {
  const JobDraft({
    required this.title,
    required this.locationId,
    required this.scheduledStart,
    this.scheduledEnd,
    this.scopeId,
    this.instructions,
  });

  final String title;
  final String locationId;

  /// Local time.
  final DateTime scheduledStart;
  final DateTime? scheduledEnd;
  final String? scopeId;
  final String? instructions;
}

/// What the crew reports when they finish. Everything is optional.
class JobCompletion {
  const JobCompletion({
    this.qualityScore,
    this.cleanerNotes,
    this.clientSignoffName,
  });

  /// 0 to 5.
  final num? qualityScore;
  final String? cleanerNotes;

  /// Who signed off on site, when the client is there.
  final String? clientSignoffName;
}

/// Who goes on a job, and as what.
class CrewMember {
  const CrewMember({required this.userId, this.roleOnJob});

  final String userId;
  final String? roleOnJob;
}
