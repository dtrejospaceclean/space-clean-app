import 'package:dio/dio.dart';

import '../../../../core/domain/picked_photo.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/paginated.dart';
import '../../domain/entities/complaint.dart';
import '../models/complaint_model.dart';

/// Talks to `/clients/:clientId/complaints`. Throws `ApiException`.
class ComplaintsRemoteDataSource {
  const ComplaintsRemoteDataSource(this._api);

  final ApiClient _api;

  static String _path(String clientId) => '/clients/$clientId/complaints';

  static Complaint _one(Object? data) =>
      ComplaintModel.fromJson((data! as Map).cast<String, dynamic>());

  Future<List<Complaint>> getComplaints(
    String clientId, {
    String? jobId,
  }) async => (await fetchAllPages(
    _api,
    _path(clientId),
    query: {'jobId': ?jobId},
  )).map(ComplaintModel.fromJson).toList();

  Future<Complaint> getComplaint(String clientId, String complaintId) async =>
      _one(await _api.get('${_path(clientId)}/$complaintId'));

  Future<Complaint> createComplaint(
    String clientId,
    ComplaintDraft draft,
  ) async => _one(
    await _api.post(
      _path(clientId),
      body: ComplaintDraftModel.toJson(draft, create: true),
    ),
  );

  Future<Complaint> updateComplaint(
    String clientId,
    String complaintId,
    ComplaintDraft draft,
  ) async => _one(
    await _api.patch(
      '${_path(clientId)}/$complaintId',
      body: ComplaintDraftModel.toJson(draft, create: false),
    ),
  );

  Future<Complaint> assignComplaint(
    String clientId,
    String complaintId,
    String userId,
  ) async => _one(
    await _api.post(
      '${_path(clientId)}/$complaintId/assign',
      body: {'assignedToUserId': userId},
    ),
  );

  Future<Complaint> resolveComplaint(
    String clientId,
    String complaintId,
    String notes,
  ) async => _one(
    await _api.post(
      '${_path(clientId)}/$complaintId/resolve',
      body: {'resolutionNotes': notes},
    ),
  );

  /// Takes no body.
  Future<Complaint> reopenComplaint(
    String clientId,
    String complaintId,
  ) async => _one(await _api.post('${_path(clientId)}/$complaintId/reopen'));

  /// One file per request, as multipart field `photo`.
  Future<ComplaintPhoto> addPhoto(
    String clientId,
    String complaintId,
    PickedPhoto photo,
  ) async {
    final form = FormData.fromMap({
      'photo': await MultipartFile.fromFile(photo.path),
    });
    final data = await _api.post(
      '${_path(clientId)}/$complaintId/photos',
      body: form,
    );
    return ComplaintModel.photoFromJson((data! as Map).cast<String, dynamic>());
  }

  Future<void> removePhoto(
    String clientId,
    String complaintId,
    String photoId,
  ) => _api.delete('${_path(clientId)}/$complaintId/photos/$photoId');
}
