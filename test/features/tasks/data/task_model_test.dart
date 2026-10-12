import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/tasks/data/models/task_model.dart';
import 'package:sp_cln_app/features/tasks/domain/entities/task.dart';

void main() {
  test('reads a task with its due day and derived fields', () {
    final t = TaskModel.fromJson({
      'id': 't1',
      'clientAccountId': 'c1',
      'title': 'Send the floor 3 quote',
      'description': 'Two options: weekly and nightly.',
      'externalMessageId': null,
      'assignedToUserId': 'u1',
      'dueDate': '2026-09-20T00:00:00.000Z',
      'priority': 'high',
      'status': 'in_progress',
      'assignedTo': {'id': 'u1', 'name': 'Ana Pérez'},
      'isOverdue': true,
      'daysUntilDue': -3,
    });

    expect(t.title, 'Send the floor 3 quote');
    expect(t.priority, Priority.high);
    expect(t.status, TaskStatus.inProgress);
    // The calendar day, whatever the device's time zone.
    expect(t.dueDate, DateTime(2026, 9, 20));
    expect(t.assignedToName, 'Ana Pérez');
    expect(t.isOverdue, isTrue);
    expect(t.daysUntilDue, -3);
    expect(t.isOpen, isTrue);
    expect(t.canStart, isFalse);
    expect(t.canReopen, isFalse);
  });

  test('a task without a date or assignee reads as unset', () {
    final t = TaskModel.fromJson({
      'id': 't2',
      'clientAccountId': 'c1',
      'title': 'File the permits',
      'priority': 'low',
      'status': 'cancelled',
      'dueDate': null,
      'isOverdue': false,
      'daysUntilDue': null,
    });

    expect(t.dueDate, isNull);
    expect(t.daysUntilDue, isNull);
    expect(t.assignedToName, isNull);
    expect(t.isOpen, isFalse);
    expect(t.canReopen, isTrue);
  });

  group('TaskDraftModel', () {
    final draft = TaskDraft(
      title: '  Send the quote ',
      description: '   ',
      priority: Priority.high,
      dueDate: DateTime(2026, 10, 1),
    );

    test('a create trims text and leaves out what is empty', () {
      expect(TaskDraftModel.toJson(draft, create: true), {
        'title': 'Send the quote',
        'priority': 'high',
        'dueDate': '2026-10-01',
      });
    });

    test('an edit clears emptied fields with null', () {
      expect(TaskDraftModel.toJson(draft, create: false), {
        'title': 'Send the quote',
        'priority': 'high',
        'description': null,
        'assignedToUserId': null,
        'dueDate': '2026-10-01',
      });
    });
  });
}
