import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/scopes/data/models/scope_model.dart';
import 'package:sp_cln_app/features/scopes/domain/entities/scope.dart';

void main() {
  test('ScopeModel.fromJson reads the scope, its links and its windows', () {
    final s = ScopeModel.fromJson({
      'id': 's1',
      'contractId': 'k1',
      'locationId': 'l1',
      'serviceCatalogId': null,
      'areaName': 'Oficinas',
      'frequency': 'weekly',
      'instructions': null,
      'exclusions': 'Sala de servidores (piso 4)',
      'estimatedDurationMinutes': 60,
      'requiredSupplies': null,
      'location': {'id': 'l1', 'name': 'Torre Norte — Piso 3', 'city': 'CDMX'},
      'serviceCatalog': null,
      'contract': {
        'id': 'k1',
        'status': 'active',
        'startDate': '2026-03-01T00:00:00.000Z',
        'expirationDate': null,
      },
      'jobCount': 12,
      'schedules': [
        {
          'id': 'w2',
          'daysOfWeek': [5, 1, 3],
          'startTime': '18:30',
          'endTime': null,
          'nextGenerationDate': null,
          'isActive': false,
        },
        {
          'id': 'w1',
          'daysOfWeek': [1, 3, 5],
          'startTime': '07:00',
          'endTime': '08:00',
          'isActive': true,
        },
      ],
    });

    expect(s.frequency, ScopeFrequency.weekly);
    expect(s.locationName, 'Torre Norte — Piso 3');
    expect(s.contractStart, DateTime(2026, 3, 1));
    expect(s.contractEnd, isNull);
    expect(s.estimatedDurationMinutes, 60);
    expect(s.jobCount, 12);
    expect(s.canDelete, isFalse);
    // Sorted by start time, days sorted too.
    expect(s.schedules.first.startTime, const ClockTime(7, 0));
    expect(s.schedules.first.endTime, const ClockTime(8, 0));
    expect(s.schedules.last.daysOfWeek, [1, 3, 5]);
    expect(s.schedules.last.isActive, isFalse);
    expect(s.schedules.last.endTime, isNull);
  });

  test('ClockTime parses and writes "HH:MM"', () {
    expect(ClockTime.tryParse('07:05'), const ClockTime(7, 5));
    expect(ClockTime.tryParse('24:00'), isNull);
    expect(ClockTime.tryParse(null), isNull);
    expect(const ClockTime(7, 5).wire, '07:05');
  });

  group('ScopeDraftModel.toJson', () {
    const window = ScopeSchedule(
      daysOfWeek: [1, 3],
      startTime: ClockTime(7, 0),
      endTime: ClockTime(8, 30),
    );

    test('a create sends the contract and leaves empty fields out', () {
      const draft = ScopeDraft(
        contractId: 'k1',
        locationId: 'l1',
        frequency: ScopeFrequency.weekly,
        areaName: ' Lobby ',
        estimatedDurationMinutes: '45',
        instructions: '  ',
        schedules: [window],
      );
      expect(ScopeDraftModel.toJson(draft, create: true), {
        'contractId': 'k1',
        'locationId': 'l1',
        'frequency': 'weekly',
        'areaName': 'Lobby',
        'estimatedDurationMinutes': 45,
        'schedules': [
          {
            'daysOfWeek': [1, 3],
            'startTime': '07:00',
            'endTime': '08:30',
            'isActive': true,
          },
        ],
      });
    });

    test('an update clears empty fields and keeps windows when unsent', () {
      const draft = ScopeDraft(
        contractId: 'k1',
        locationId: 'l2',
        frequency: ScopeFrequency.daily,
      );
      expect(ScopeDraftModel.toJson(draft, create: false), {
        'locationId': 'l2',
        'frequency': 'daily',
        'serviceCatalogId': null,
        'areaName': null,
        'instructions': null,
        'exclusions': null,
        'estimatedDurationMinutes': null,
        'requiredSupplies': null,
      });
    });

    test('days go only with weekly and biweekly work', () {
      const draft = ScopeDraft(
        locationId: 'l1',
        frequency: ScopeFrequency.daily,
        schedules: [window],
      );
      final json = ScopeDraftModel.toJson(draft, create: false);
      expect((json['schedules'] as List).single, {
        'daysOfWeek': <int>[],
        'startTime': '07:00',
        'endTime': '08:30',
        'isActive': true,
      });
    });
  });
}
