import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/locations/data/models/location_model.dart';
import 'package:sp_cln_app/features/locations/domain/entities/location.dart';

void main() {
  test('reads a location with its usage counts', () {
    final location = LocationModel.fromJson({
      'id': 'l1',
      'clientAccountId': 'c1',
      'name': 'Tower A – Floor 3',
      'address': '1980 Post Oak Blvd',
      'city': 'Houston',
      'state': 'TX',
      'zipCode': '77056',
      'accessCodes': 'Door 4521',
      'squareFootage': '12000',
      'floorCount': 1,
      'specialInstructions': null,
      'scopeOfWorkCount': 2,
      'jobCount': 14,
    });

    expect(location.cityLine, 'Houston, TX 77056');
    expect(location.squareFootage, '12000');
    expect(location.floorCount, 1);
    expect(location.isInUse, isTrue);
  });

  test('a location nothing uses can be deleted', () {
    final location = LocationModel.fromJson({
      'id': 'l1',
      'name': 'Annex',
      'address': '1 Main St',
      'city': 'Houston',
      'state': 'TX',
      'zipCode': '77002',
    });

    expect(location.isInUse, isFalse);
  });

  const draft = LocationDraft(
    name: ' Tower A ',
    address: '1980 Post Oak Blvd',
    city: 'Houston',
    state: 'TX',
    zipCode: '77056',
    squareFootage: '850.5',
    floorCount: ' ',
    accessCodes: '',
  );

  test('a new location sends numbers and only filled-in fields', () {
    expect(LocationDraftModel.toJson(draft, create: true), {
      'name': 'Tower A',
      'address': '1980 Post Oak Blvd',
      'city': 'Houston',
      'state': 'TX',
      'zipCode': '77056',
      'squareFootage': 850.5,
    });
  });

  test('an update clears the optional fields left empty', () {
    expect(LocationDraftModel.toJson(draft, create: false), {
      'name': 'Tower A',
      'address': '1980 Post Oak Blvd',
      'city': 'Houston',
      'state': 'TX',
      'zipCode': '77056',
      'accessCodes': null,
      'squareFootage': 850.5,
      'floorCount': null,
      'specialInstructions': null,
    });
  });
}
