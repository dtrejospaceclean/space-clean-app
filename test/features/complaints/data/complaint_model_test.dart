import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/complaints/data/models/complaint_model.dart';
import 'package:sp_cln_app/features/complaints/domain/entities/complaint.dart';

void main() {
  test('reads a complaint with its links and resolution', () {
    final c = ComplaintModel.fromJson({
      'id': 'q1',
      'clientAccountId': 'c1',
      'jobId': 'j1',
      'externalMessageId': null,
      'title': 'Baños sin papel',
      'locationId': 'l1',
      'area': 'Baños piso 3',
      'reportedByUserId': 'u1',
      'resolvedByUserId': 'u2',
      'priority': 'high',
      'status': 'resolved',
      'assignedToUserId': 'u3',
      'reportedDate': '2026-09-26T15:00:00.000Z',
      'resolutionTime': '2026-09-26T19:30:00.000Z',
      'description': 'Sin papel desde la mañana.',
      'resolutionNotes': 'Se repuso y se dejó stock extra.',
      'location': {'id': 'l1', 'name': 'Torre Norte — Piso 3'},
      'job': {
        'id': 'j1',
        'title': 'Night clean',
        'scheduledStart': '2026-09-25T23:00:00.000Z',
      },
      'assignedTo': {'id': 'u3', 'name': 'Luis Gómez'},
      'reportedBy': {'id': 'u1', 'name': 'Ana Pérez'},
      'resolvedBy': {'id': 'u2', 'name': 'Marco Díaz'},
      'resolutionHours': 4.5,
    });

    expect(c.title, 'Baños sin papel');
    expect(c.priority, Priority.high);
    expect(c.status, ComplaintStatus.resolved);
    expect(c.isResolved, isTrue);
    expect(c.isEditable, isFalse);
    expect(c.reportedDate, DateTime.utc(2026, 9, 26, 15).toLocal());
    expect(c.locationName, 'Torre Norte — Piso 3');
    expect(c.area, 'Baños piso 3');
    expect(c.jobTitle, 'Night clean');
    expect(c.jobStart, DateTime.utc(2026, 9, 25, 23).toLocal());
    expect(c.assignedToId, 'u3');
    expect(c.assignedToName, 'Luis Gómez');
    expect(c.reportedByName, 'Ana Pérez');
    expect(c.resolvedByName, 'Marco Díaz');
    expect(c.resolutionHours, 4.5);
    expect(c.resolutionNotes, 'Se repuso y se dejó stock extra.');
  });

  test('an open complaint without links reads as unset', () {
    final c = ComplaintModel.fromJson({
      'id': 'q2',
      'clientAccountId': 'c1',
      'title': 'Carpet stains',
      'description': 'Lobby carpet.',
      'priority': 'medium',
      'status': 'open',
      'reportedDate': '2026-09-26T15:00:00.000Z',
      'resolutionHours': null,
    });

    expect(c.status, ComplaintStatus.open);
    expect(c.isEditable, isTrue);
    expect(c.locationName, isNull);
    expect(c.jobTitle, isNull);
    expect(c.assignedToName, isNull);
    expect(c.resolutionHours, isNull);
  });

  test('unknown statuses and priorities are kept as unknown', () {
    expect(ComplaintStatus.fromWire('escalated'), ComplaintStatus.unknown);
    expect(Priority.fromWire('urgent'), Priority.unknown);
  });

  group('ComplaintDraftModel', () {
    const draft = ComplaintDraft(
      title: '  Restrooms out of paper ',
      description: ' Since this morning. ',
      priority: Priority.high,
      area: '   ',
      assignedToId: 'u3',
    );

    test('a create trims text and leaves out what is empty', () {
      expect(ComplaintDraftModel.toJson(draft, create: true), {
        'title': 'Restrooms out of paper',
        'description': 'Since this morning.',
        'priority': 'high',
        'assignedToUserId': 'u3',
      });
    });

    test('an edit clears emptied fields and never sends the assignee', () {
      expect(ComplaintDraftModel.toJson(draft, create: false), {
        'title': 'Restrooms out of paper',
        'description': 'Since this morning.',
        'priority': 'high',
        'locationId': null,
        'area': null,
        'jobId': null,
      });
    });
  });
}
