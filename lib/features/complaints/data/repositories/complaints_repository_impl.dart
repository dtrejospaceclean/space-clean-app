import '../../../../core/network/api_exception.dart';
import '../../domain/entities/complaint.dart';
import '../../domain/repositories/complaints_repository.dart';
import '../datasources/complaints_remote_data_source.dart';

class ComplaintsRepositoryImpl implements ComplaintsRepository {
  const ComplaintsRepositoryImpl(this._remote);

  final ComplaintsRemoteDataSource _remote;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException catch (e) {
      throw e.toFailure();
    }
  }

  @override
  Future<List<Complaint>> getComplaints(String clientId, {String? jobId}) =>
      _guard(() => _remote.getComplaints(clientId, jobId: jobId));

  @override
  Future<Complaint> getComplaint(String clientId, String complaintId) =>
      _guard(() => _remote.getComplaint(clientId, complaintId));

  @override
  Future<Complaint> createComplaint(String clientId, ComplaintDraft draft) =>
      _guard(() => _remote.createComplaint(clientId, draft));

  @override
  Future<Complaint> updateComplaint(
    String clientId,
    String complaintId,
    ComplaintDraft draft,
  ) => _guard(() => _remote.updateComplaint(clientId, complaintId, draft));

  @override
  Future<Complaint> assignComplaint(
    String clientId,
    String complaintId,
    String userId,
  ) => _guard(() => _remote.assignComplaint(clientId, complaintId, userId));

  @override
  Future<Complaint> resolveComplaint(
    String clientId,
    String complaintId,
    String notes,
  ) => _guard(() => _remote.resolveComplaint(clientId, complaintId, notes));

  @override
  Future<Complaint> reopenComplaint(String clientId, String complaintId) =>
      _guard(() => _remote.reopenComplaint(clientId, complaintId));
}
