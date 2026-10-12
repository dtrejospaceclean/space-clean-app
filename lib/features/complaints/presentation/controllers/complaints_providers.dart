import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/complaints_providers.dart';
import '../../domain/entities/complaint.dart';
import '../../domain/usecases/complaint_usecases.dart';

/// An account's complaints, newest first.
final complaintsProvider = FutureProvider.autoDispose
    .family<List<Complaint>, String>(
      (ref, clientId) => ref.watch(getComplaintsProvider)(clientId),
    );

/// The complaints about one job: `(clientId, jobId)`.
final jobComplaintsProvider = FutureProvider.autoDispose
    .family<List<Complaint>, (String, String)>(
      (ref, key) => ref.watch(getJobComplaintsProvider)(
        JobComplaintsParams(clientId: key.$1, jobId: key.$2),
      ),
    );

/// One complaint: `(clientId, complaintId)`.
final complaintProvider = FutureProvider.autoDispose
    .family<Complaint, (String, String)>(
      (ref, key) => ref.watch(getComplaintProvider)(
        ComplaintRef(clientId: key.$1, complaintId: key.$2),
      ),
    );

/// Drops an account's cached complaints after any write.
void invalidateComplaints(WidgetRef ref, String clientId) => ref
  ..invalidate(complaintsProvider(clientId))
  ..invalidate(jobComplaintsProvider)
  ..invalidate(complaintProvider);
