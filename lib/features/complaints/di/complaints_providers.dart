import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/network_providers.dart';
import '../data/datasources/complaints_remote_data_source.dart';
import '../data/repositories/complaints_repository_impl.dart';
import '../domain/repositories/complaints_repository.dart';
import '../domain/usecases/complaint_usecases.dart';

final complaintsRepositoryProvider = Provider<ComplaintsRepository>(
  (ref) => ComplaintsRepositoryImpl(
    ComplaintsRemoteDataSource(ref.watch(apiClientProvider)),
  ),
);

final getComplaintsProvider = Provider(
  (ref) => GetComplaints(ref.watch(complaintsRepositoryProvider)),
);
final getJobComplaintsProvider = Provider(
  (ref) => GetJobComplaints(ref.watch(complaintsRepositoryProvider)),
);
final getComplaintProvider = Provider(
  (ref) => GetComplaint(ref.watch(complaintsRepositoryProvider)),
);
final saveComplaintProvider = Provider(
  (ref) => SaveComplaint(ref.watch(complaintsRepositoryProvider)),
);
final assignComplaintProvider = Provider(
  (ref) => AssignComplaint(ref.watch(complaintsRepositoryProvider)),
);
final resolveComplaintProvider = Provider(
  (ref) => ResolveComplaint(ref.watch(complaintsRepositoryProvider)),
);
final reopenComplaintProvider = Provider(
  (ref) => ReopenComplaint(ref.watch(complaintsRepositoryProvider)),
);
final addComplaintPhotoProvider = Provider(
  (ref) => AddComplaintPhoto(ref.watch(complaintsRepositoryProvider)),
);
final removeComplaintPhotoProvider = Provider(
  (ref) => RemoveComplaintPhoto(ref.watch(complaintsRepositoryProvider)),
);
