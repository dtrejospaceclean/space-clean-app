import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/users/data/models/user_models.dart';
import 'package:sp_cln_app/features/users/domain/entities/managed_user.dart';

void main() {
  group('UserDraftModel', () {
    test('create sends only accepted fields, typed as the API wants', () {
      final body = UserDraftModel.toJson(
        UserDraft(
          email: ' ana@example.com ',
          password: 'correct-horse-battery',
          name: 'Ana Pérez',
          phoneNumber: '',
          payRate: '18.50',
          hireDate: DateTime(2026, 1, 5),
          employmentType: 'part_time',
          roleIds: const ['r1'],
        ),
        create: true,
      );

      expect(body, {
        'email': 'ana@example.com',
        'password': 'correct-horse-battery',
        'name': 'Ana Pérez',
        'employmentType': 'part_time',
        'payRate': 18.5,
        'hireDate': '2026-01-05',
        'roleIds': ['r1'],
      });
    });

    test('edit never sends roles and clears emptied fields with null', () {
      final body = UserDraftModel.toJson(
        const UserDraft(
          name: 'Ana',
          roleIds: ['r1'],
          cleared: {'phoneNumber', 'hireDate'},
        ),
        create: false,
      );

      expect(body, {'name': 'Ana', 'phoneNumber': null, 'hireDate': null});
    });
  });

  test('reads a user, keeping the pay rate as text and the hire day', () {
    final user = ManagedUserModel.fromJson({
      'id': 'u1',
      'email': 'ana@example.com',
      'name': 'Ana',
      'userType': 'internal',
      'isActive': false,
      'payRate': '18.5',
      'hireDate': '2026-01-15T00:00:00.000Z',
      'roles': [
        {'id': 'r1', 'name': 'supervisor'},
      ],
    });

    expect(user.isActive, isFalse);
    expect(user.payRate, '18.5');
    expect(user.hireDate, DateTime(2026, 1, 15));
    expect(user.roles.single.name, 'supervisor');
  });
}
