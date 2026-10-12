import '../../../../core/usecase/usecase.dart';
import '../entities/complaint.dart';
import '../repositories/complaints_repository.dart';

class GetComplaints implements UseCase<List<Complaint>, String> {
  const GetComplaints(this._repository);

  final ComplaintsRepository _repository;

  /// [clientId]'s complaints.
  @override
  Future<List<Complaint>> call(String clientId) =>
      _repository.getComplaints(clientId);
}

class JobComplaintsParams {
  const JobComplaintsParams({required this.clientId, required this.jobId});

  final String clientId;
  final String jobId;
}

/// The complaints about one job, newest first.
class GetJobComplaints
    implements UseCase<List<Complaint>, JobComplaintsParams> {
  const GetJobComplaints(this._repository);

  final ComplaintsRepository _repository;

  @override
  Future<List<Complaint>> call(JobComplaintsParams p) =>
      _repository.getComplaints(p.clientId, jobId: p.jobId);
}

class ComplaintRef {
  const ComplaintRef({required this.clientId, required this.complaintId});

  final String clientId;
  final String complaintId;
}

class GetComplaint implements UseCase<Complaint, ComplaintRef> {
  const GetComplaint(this._repository);

  final ComplaintsRepository _repository;

  @override
  Future<Complaint> call(ComplaintRef params) =>
      _repository.getComplaint(params.clientId, params.complaintId);
}

class SaveComplaintParams {
  const SaveComplaintParams({
    required this.clientId,
    required this.draft,
    this.complaintId,
  });

  final String clientId;

  /// The complaint edited; null to create.
  final String? complaintId;
  final ComplaintDraft draft;
}

/// Reports a complaint or edits one; returns the saved complaint.
class SaveComplaint implements UseCase<Complaint, SaveComplaintParams> {
  const SaveComplaint(this._repository);

  final ComplaintsRepository _repository;

  @override
  Future<Complaint> call(SaveComplaintParams p) => switch (p.complaintId) {
    null => _repository.createComplaint(p.clientId, p.draft),
    final id => _repository.updateComplaint(p.clientId, id, p.draft),
  };
}

class AssignComplaintParams {
  const AssignComplaintParams({required this.complaint, required this.userId});

  final ComplaintRef complaint;
  final String userId;
}

class AssignComplaint implements UseCase<Complaint, AssignComplaintParams> {
  const AssignComplaint(this._repository);

  final ComplaintsRepository _repository;

  @override
  Future<Complaint> call(AssignComplaintParams p) => _repository
      .assignComplaint(p.complaint.clientId, p.complaint.complaintId, p.userId);
}

class ResolveComplaintParams {
  const ResolveComplaintParams({required this.complaint, required this.notes});

  final ComplaintRef complaint;

  /// What was done. Required: the form checks it isn't blank.
  final String notes;
}

/// Resolves with the notes, trimmed.
class ResolveComplaint implements UseCase<Complaint, ResolveComplaintParams> {
  const ResolveComplaint(this._repository);

  final ComplaintsRepository _repository;

  @override
  Future<Complaint> call(ResolveComplaintParams p) =>
      _repository.resolveComplaint(
        p.complaint.clientId,
        p.complaint.complaintId,
        p.notes.trim(),
      );
}

class ReopenComplaint implements UseCase<Complaint, ComplaintRef> {
  const ReopenComplaint(this._repository);

  final ComplaintsRepository _repository;

  @override
  Future<Complaint> call(ComplaintRef params) =>
      _repository.reopenComplaint(params.clientId, params.complaintId);
}
