import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/complaints/domain/entities/complaint.dart';

Complaint _complaint(
  String id, {
  Priority priority = Priority.medium,
  ComplaintStatus status = ComplaintStatus.open,
  required int reportedDay,
  int? resolvedDay,
}) => Complaint(
  id: id,
  clientId: 'c1',
  title: id,
  description: '',
  priority: priority,
  status: status,
  reportedDate: DateTime(2026, 9, reportedDay),
  resolutionTime: resolvedDay == null ? null : DateTime(2026, 9, resolvedDay),
);

void main() {
  final all = [
    _complaint('old-low', priority: Priority.low, reportedDay: 1),
    _complaint('new-medium', reportedDay: 20),
    _complaint('old-high', priority: Priority.high, reportedDay: 2),
    _complaint(
      'busy-high',
      priority: Priority.high,
      status: ComplaintStatus.inProgress,
      reportedDay: 15,
    ),
    _complaint('old-medium', reportedDay: 5),
    _complaint(
      'done-early',
      status: ComplaintStatus.resolved,
      reportedDay: 1,
      resolvedDay: 3,
    ),
    _complaint(
      'done-late',
      status: ComplaintStatus.resolved,
      reportedDay: 2,
      resolvedDay: 18,
    ),
  ];

  test('open complaints come most urgent first, then newest', () {
    expect(openByUrgency(all).map((c) => c.id), [
      'busy-high',
      'old-high',
      'new-medium',
      'old-medium',
      'old-low',
    ]);
  });

  test('resolved complaints come latest resolved first', () {
    expect(resolvedLatestFirst(all).map((c) => c.id), [
      'done-late',
      'done-early',
    ]);
  });
}
