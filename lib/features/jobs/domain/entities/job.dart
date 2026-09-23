import '../../../clients/domain/entities/client.dart';

enum JobStatus { scheduled, inProgress, completed, cancelled, unknown }

class JobLocation {
  const JobLocation({required this.name, this.address, this.city});

  final String name;
  final String? address;
  final String? city;
}

class JobAssignee {
  const JobAssignee({required this.userId, required this.name});

  final String userId;
  final String name;
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
    this.location,
    this.assignees = const [],
    this.instructions,
    this.checklistTotal = 0,
    this.checklistDone = 0,
  });

  final String id;
  final String clientId;
  final String title;
  final JobStatus status;

  /// Local time.
  final DateTime scheduledStart;
  final DateTime? scheduledEnd;
  final JobLocation? location;
  final List<JobAssignee> assignees;
  final String? instructions;
  final int checklistTotal;
  final int checklistDone;
}

/// A job with the account it belongs to, for lists that span accounts.
class AccountJob {
  const AccountJob({required this.job, required this.client});

  final Job job;
  final Client client;
}
