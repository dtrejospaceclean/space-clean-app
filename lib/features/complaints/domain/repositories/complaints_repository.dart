import '../entities/complaint.dart';

/// Every method throws a `Failure` on error.
abstract interface class ComplaintsRepository {
  /// Every complaint of an account, newest first, or only those about the
  /// job [jobId]. Needs `complaints.view`.
  Future<List<Complaint>> getComplaints(String clientId, {String? jobId});

  /// Needs `complaints.view`.
  Future<Complaint> getComplaint(String clientId, String complaintId);

  /// Reported by the signed-in user; open, or in progress when it starts
  /// assigned. Needs `complaints.edit`.
  Future<Complaint> createComplaint(String clientId, ComplaintDraft draft);

  /// Needs `complaints.edit`; refused once resolved
  /// (`complaints.already_resolved`).
  Future<Complaint> updateComplaint(
    String clientId,
    String complaintId,
    ComplaintDraft draft,
  );

  /// Gives it to [userId], an active user; an open complaint becomes in
  /// progress. Needs `complaints.assign`; refused once resolved.
  Future<Complaint> assignComplaint(
    String clientId,
    String complaintId,
    String userId,
  );

  /// Closes it with what was done, recording who and when. Needs
  /// `complaints.edit`.
  Future<Complaint> resolveComplaint(
    String clientId,
    String complaintId,
    String notes,
  );

  /// Opens a resolved complaint again (`complaints.not_resolved`
  /// otherwise). Needs `complaints.edit`.
  Future<Complaint> reopenComplaint(String clientId, String complaintId);
}
